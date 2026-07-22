import hashlib
from datetime import datetime

from fastapi import APIRouter, Header, Request, status
from pydantic import BaseModel, ConfigDict, Field, field_validator
from urllib.parse import urlparse
from decimal import Decimal, ROUND_HALF_UP

from src.core.errors.errors import ConflictError
from src.core.security.security import CurrentUser, get_current_user
from fastapi import Depends
from src.modules.payments.application.process_webhook import StripeWebhookProcessor
from src.modules.payments.application.use_cases.validate_checkout_eligibility_use_case import (
    ValidateCheckoutEligibilityUseCase,
)
from src.modules.payments.application.use_cases.get_checkout_status_use_case import (
    GetCheckoutStatusUseCase,
)
from src.modules.subscriptions.domain.gateways import CheckoutGateway
from src.modules.subscriptions.domain.repositories import SubscriptionRepository
from src.modules.subscriptions.interface.api.dependencies import (
    get_checkout_gateway,
    get_subscription_repository,
)
from src.modules.courses.domain.repositories import CourseRepository
from src.modules.courses.interface.api.dependencies import get_course_repository
from src.shared.config import settings
from src.infra.stripe.client import get_stripe_client
from fastapi import HTTPException

import logging

router = APIRouter(prefix="/api/v1/payments", tags=["payments"])
legacy_router = APIRouter(tags=["payments"])
logger = logging.getLogger(__name__)
stripe = get_stripe_client()


# ─── Schemas ────────────────────────────────────────────────────────────────


class CheckoutRequestSchema(BaseModel):
    model_config = ConfigDict(frozen=True, extra="forbid")

    price_id: str | None = Field(
        default=None,
        description="Campo legado ignorado; o preço é sempre obtido do curso no servidor.",
    )
    course_id: str = Field(..., description="UUID do Curso a assinar")
    success_url: str = Field(..., description="URL de retorno para sucesso")
    cancel_url: str = Field(..., description="URL de retorno para cancelamento")

    @field_validator("success_url", "cancel_url")
    @classmethod
    def validate_return_url(cls, value: str) -> str:
        parsed = urlparse(value)
        if parsed.scheme not in {"https", "lawrence"}:
            raise ValueError("URL de retorno deve usar HTTPS ou o app Lawrence.")
        if parsed.scheme == "https" and not parsed.netloc:
            raise ValueError("URL HTTPS de retorno inválida.")
        return value


class CheckoutEligibilityResponseSchema(BaseModel):
    model_config = ConfigDict(frozen=True)

    can_purchase: bool
    has_access: bool
    reason_code: str | None
    message: str | None
    subscription_status: str | None
    course_id: str


class CheckoutStatusResponseSchema(BaseModel):
    model_config = ConfigDict(frozen=True)

    status: str
    payment_status: str
    subscription_status: str | None
    created_at: datetime
    updated_at: datetime
    checkout_url: str | None


# ─── Endpoints ──────────────────────────────────────────────────────────────


@router.get(
    "/checkout/eligibility",
    response_model=CheckoutEligibilityResponseSchema,
    status_code=status.HTTP_200_OK,
)
async def check_checkout_eligibility(
    course_id: str,
    current_user: CurrentUser = Depends(get_current_user),
    repository: SubscriptionRepository = Depends(get_subscription_repository),
    course_repository: CourseRepository = Depends(get_course_repository),
):
    """Retorna a elegibilidade do usuário para iniciar um checkout deste curso."""
    use_case = ValidateCheckoutEligibilityUseCase(repository, course_repository)
    result = await use_case.execute(student_id=current_user.id, course_id=course_id)

    return CheckoutEligibilityResponseSchema(
        can_purchase=result.can_purchase,
        has_access=result.has_access,
        reason_code=result.reason_code,
        message=result.message,
        subscription_status=result.subscription_status,
        course_id=result.course_id,
    )


@router.post("/checkout", status_code=status.HTTP_200_OK)
async def create_checkout_session(
    payload: CheckoutRequestSchema,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    current_user: CurrentUser = Depends(get_current_user),
    repository: SubscriptionRepository = Depends(get_subscription_repository),
    course_repository: CourseRepository = Depends(get_course_repository),
):
    """Cria uma sessão de checkout Stripe para assinatura de curso (BOLA-safe)."""
    use_case = ValidateCheckoutEligibilityUseCase(repository, course_repository)

    # Validar elegibilidade (levanta ConflictError se assinatura bloqueante existir)
    result = await use_case.execute(
        student_id=current_user.id, course_id=payload.course_id
    )
    if not result.can_purchase:
        raise ConflictError(
            result.message or "Não é possível comprar este curso no momento."
        )

    course = await course_repository.get_by_id(payload.course_id)
    if course is None or course.status != "published":
        raise HTTPException(status_code=404, detail="Curso publicado não encontrado.")
    if course.monthly_price <= 0:
        raise ConflictError("Cursos gratuitos não precisam de checkout.")

    if settings.app_env == "test" or settings.payment_provider == "fake":
        return {
            "status": "success",
            "data": {
                "checkout_url": f"{payload.success_url}?session_id=fake_session",
                "session_id": "fake_session",
            },
        }

    try:
        session = stripe.checkout.Session.create(
            payment_method_types=["card"],
            line_items=[
                {
                    "price_data": {
                        "currency": "brl",
                        "unit_amount": int(
                            (course.monthly_price * Decimal("100")).quantize(
                                Decimal("1"), rounding=ROUND_HALF_UP
                            )
                        ),
                        "recurring": {"interval": "month"},
                        "product_data": {"name": course.title},
                    },
                    "quantity": 1,
                }
            ],
            mode="subscription",
            subscription_data={
                "metadata": {
                    "course_id": payload.course_id,
                    "user_id": current_user.id,
                }
            },
            success_url=payload.success_url,
            cancel_url=payload.cancel_url,
            client_reference_id=current_user.id,
            customer_email=current_user.email,
            metadata={"course_id": payload.course_id, "user_id": current_user.id},
            idempotency_key=idempotency_key,
        )
        return {
            "status": "success",
            "data": {"checkout_url": session.url, "session_id": session.id},
        }
    except ConflictError:
        raise
    except Exception:
        logger.exception(
            "Falha ao criar checkout Stripe para o curso %s", payload.course_id
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Não foi possível iniciar o pagamento. Tente novamente.",
        )


@router.get(
    "/checkout/status/{checkout_id}",
    response_model=CheckoutStatusResponseSchema,
    status_code=status.HTTP_200_OK,
)
async def get_checkout_status(
    checkout_id: str,
    current_user: CurrentUser = Depends(get_current_user),
    gateway: CheckoutGateway = Depends(get_checkout_gateway),
) -> CheckoutStatusResponseSchema:
    """Consulta o estado canonico de um checkout pertencente ao usuario."""
    checkout = await GetCheckoutStatusUseCase(gateway).execute(
        checkout_id, current_user.id
    )
    return CheckoutStatusResponseSchema(
        status=checkout.status,
        payment_status=checkout.payment_status,
        subscription_status=checkout.subscription_status,
        created_at=checkout.created_at,
        updated_at=checkout.updated_at,
        checkout_url=checkout.checkout_url,
    )


@router.post("/webhook", status_code=status.HTTP_200_OK)
async def handle_stripe_webhook(
    request: Request,
    stripe_signature: str = Header(None, alias="stripe-signature"),
):
    """Recebe e processa eventos do Stripe com verificação de assinatura e idempotência."""
    if not stripe_signature or not settings.stripe_webhook_secret:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Assinatura ou segredo do webhook ausentes.",
        )

    body = await request.body()

    try:
        event = stripe.Webhook.construct_event(
            body, stripe_signature, settings.stripe_webhook_secret
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Falha na verificação da assinatura do webhook: {str(e)}",
        )

    event_id = event["id"]
    event_type = event.get("type", "unknown")
    payload_hash = hashlib.sha256(body).hexdigest()

    is_new = StripeWebhookProcessor.register_idempotency(
        provider="stripe",
        event_id=event_id,
        event_type=event_type,
        payload_hash=payload_hash,
    )
    if not is_new:
        return {"status": "success", "message": "Duplicate event ignored."}

    try:
        await StripeWebhookProcessor.process_event(event)
        StripeWebhookProcessor.mark_event_processed(
            provider="stripe", event_id=event_id
        )
        return {"status": "success", "event_processed": event_id}
    except Exception as proc_err:
        try:
            StripeWebhookProcessor.mark_event_failed(
                provider="stripe", event_id=event_id, error_message=str(proc_err)
            )
        except Exception:
            pass
        from src.core.errors.errors import ExternalServiceError

        raise ExternalServiceError(
            message=f"Erro ao processar webhook: {str(proc_err)}",
            provider="stripe",
            request_id=event_id,
        )


@legacy_router.post(
    "/webhooks/stripe", status_code=status.HTTP_200_OK, deprecated=True
)
async def handle_stripe_webhook_legacy(
    request: Request,
    stripe_signature: str = Header(None, alias="stripe-signature"),
):
    """[DEPRECATED] Rota legada de webhooks. Use /api/v1/payments/webhook."""
    logger.warning(
        "Rota /webhooks/stripe chamada. Esta rota está DEPRECIADA e será removida em breve. Atualize o Stripe Dashboard para /api/v1/payments/webhook."
    )
    return await handle_stripe_webhook(request, stripe_signature)
