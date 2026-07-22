from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from pydantic import BaseModel, ConfigDict

from src.core.security.security import CurrentUser, get_current_user
from src.modules.subscriptions.application.use_cases.cancel_subscription_use_case import (
    CancelSubscriptionUseCase,
)
from src.modules.subscriptions.domain.gateways import SubscriptionGateway
from src.modules.subscriptions.domain.repositories import SubscriptionRepository
from src.modules.subscriptions.interface.api.dependencies import (
    get_subscription_gateway,
    get_subscription_repository,
)

router = APIRouter(prefix="/api/v1/subscriptions", tags=["subscriptions"])


class SubscriptionResponseSchema(BaseModel):
    model_config = ConfigDict(frozen=True)

    id: str
    course_id: str
    status: str
    monthly_price: float
    currency: str
    current_period_end: Optional[datetime]
    created_at: datetime
    updated_at: datetime
    cancel_at_period_end: bool
    canceled_at: Optional[datetime]

    # Flags computadas no backend
    has_access: bool
    grace_period_ends_at: Optional[datetime]


@router.get(
    "/me",
    response_model=List[SubscriptionResponseSchema],
    status_code=status.HTTP_200_OK,
)
async def get_my_subscriptions(
    limit: int = Query(10, ge=1, le=50, description="Limite de registros a retornar"),
    current_user: CurrentUser = Depends(get_current_user),
    repository: SubscriptionRepository = Depends(get_subscription_repository),
):
    """
    Retorna a lista de assinaturas do usuário autenticado.
    Os resultados incluem flags computadas para carência e acesso.
    """
    # Aqui o get_by_student idealmente suportaria limit/pagination.
    # Como não temos certeza se o método suporta paginação, buscamos e aplicamos o limite manualmente
    # ou esperamos que o repositório seja atualizado.

    subs = await repository.get_by_student(current_user.id)

    # Ordenar por data decrescente (o repositório já deve fazer isso ou o DB)
    subs = sorted(
        subs,
        key=lambda s: s.created_at or datetime.min.replace(tzinfo=timezone.utc),
        reverse=True,
    )
    subs = subs[:limit]

    response = []
    now = datetime.now(timezone.utc)

    for sub in subs:
        has_access = False
        grace_period_ends_at = None

        if sub.status in ("active", "trialing"):
            has_access = True
        elif sub.status == "past_due" and sub.current_period_end:
            period_end = sub.current_period_end
            if period_end.tzinfo is None:
                period_end = period_end.replace(tzinfo=timezone.utc)

            diff = now - period_end
            if diff.days <= 5:
                has_access = True
                from datetime import timedelta

                grace_period_ends_at = period_end + timedelta(days=5)

        response.append(
            SubscriptionResponseSchema(
                id=sub.id or "",
                course_id=sub.course_id,
                status=sub.status,
                monthly_price=float(sub.monthly_price),
                currency=sub.currency,
                current_period_end=sub.current_period_end,
                created_at=sub.created_at or now,
                updated_at=sub.updated_at or now,
                cancel_at_period_end=sub.cancel_at_period_end,
                canceled_at=sub.canceled_at,
                has_access=has_access,
                grace_period_ends_at=grace_period_ends_at,
            )
        )

    return response


@router.patch(
    "/{subscription_id}/cancel",
    response_model=SubscriptionResponseSchema,
    status_code=status.HTTP_200_OK,
)
async def cancel_subscription(
    subscription_id: str,
    current_user: CurrentUser = Depends(get_current_user),
    repository: SubscriptionRepository = Depends(get_subscription_repository),
    gateway: SubscriptionGateway = Depends(get_subscription_gateway),
) -> SubscriptionResponseSchema:
    """Agenda o cancelamento para o fim do período já pago."""
    subscription = await CancelSubscriptionUseCase(repository, gateway).execute(
        subscription_id, current_user.id
    )
    now = datetime.now(timezone.utc)
    return SubscriptionResponseSchema(
        id=subscription.id or "",
        course_id=subscription.course_id,
        status=subscription.status,
        monthly_price=float(subscription.monthly_price),
        currency=subscription.currency,
        current_period_end=subscription.current_period_end,
        created_at=subscription.created_at or now,
        updated_at=subscription.updated_at or now,
        cancel_at_period_end=subscription.cancel_at_period_end,
        canceled_at=subscription.canceled_at,
        has_access=subscription.status in ("active", "trialing", "past_due"),
        grace_period_ends_at=None,
    )
