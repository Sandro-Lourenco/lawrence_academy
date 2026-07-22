from datetime import datetime, timezone
from typing import Any, Mapping, Optional

import stripe

from src.core.errors.errors import ExternalServiceError, NotFoundError
from src.modules.subscriptions.domain.entities import CheckoutStatus, Subscription
from src.shared.config import settings


def _value(resource: Any, name: str, default: Any = None) -> Any:
    if isinstance(resource, Mapping):
        return resource.get(name, default)
    return getattr(resource, name, default)


def _subscription_status(resource: Any) -> Optional[str]:
    subscription = _value(resource, "subscription")
    if isinstance(subscription, str) or subscription is None:
        return None
    value = _value(subscription, "status")
    return str(value) if value else None


def _canonical_checkout_status(
    session_status: str, payment_status: str, subscription_status: Optional[str]
) -> str:
    if session_status == "expired":
        return "expired"
    if subscription_status in ("canceled", "cancelled"):
        return "cancelled"
    if subscription_status == "incomplete_expired":
        return "failed"
    if session_status == "complete" and payment_status in (
        "paid",
        "no_payment_required",
    ):
        return "paid"
    if session_status == "open":
        return "pending"
    return "processing"


class StripeSubscriptionGateway:
    async def cancel_at_period_end(self, subscription: Subscription) -> None:
        if settings.app_env == "test" or settings.payment_provider == "fake":
            return
        if not subscription.provider_subscription_id:
            raise NotFoundError("Assinatura não vinculada ao provedor de pagamento.")
        try:
            stripe.Subscription.modify(
                subscription.provider_subscription_id,
                cancel_at_period_end=True,
            )
        except stripe.error.InvalidRequestError as exc:
            raise NotFoundError("Assinatura não encontrada no provedor.") from exc
        except stripe.error.StripeError as exc:
            raise ExternalServiceError(
                message="Não foi possível cancelar a assinatura no provedor.",
                provider="stripe",
                request_id=getattr(exc, "request_id", "unknown") or "unknown",
            ) from exc


class StripeCheckoutGateway:
    async def get_status(
        self, checkout_id: str, expected_owner_id: str
    ) -> CheckoutStatus:
        observed_at = datetime.now(timezone.utc)
        if settings.app_env == "test" or settings.payment_provider == "fake":
            return CheckoutStatus(
                checkout_id=checkout_id,
                owner_id=expected_owner_id,
                status="paid",
                payment_status="paid",
                subscription_status="active",
                created_at=observed_at,
                updated_at=observed_at,
            )

        try:
            session = stripe.checkout.Session.retrieve(
                checkout_id, expand=["subscription"]
            )
        except stripe.error.InvalidRequestError as exc:
            raise NotFoundError("Checkout não encontrado.") from exc
        except stripe.error.StripeError as exc:
            raise ExternalServiceError(
                message="Não foi possível consultar o checkout no provedor.",
                provider="stripe",
                request_id=getattr(exc, "request_id", "unknown") or "unknown",
            ) from exc

        metadata = _value(session, "metadata", {}) or {}
        owner_id = str(
            _value(session, "client_reference_id")
            or _value(metadata, "user_id", "")
        )
        session_status = str(_value(session, "status", "open"))
        payment_status = str(_value(session, "payment_status", "unpaid"))
        subscription_status = _subscription_status(session)
        created = _value(session, "created")
        created_at = (
            datetime.fromtimestamp(int(created), tz=timezone.utc)
            if created is not None
            else observed_at
        )

        return CheckoutStatus(
            checkout_id=str(_value(session, "id", checkout_id)),
            owner_id=owner_id,
            status=_canonical_checkout_status(
                session_status, payment_status, subscription_status
            ),
            payment_status=payment_status,
            subscription_status=subscription_status,
            created_at=created_at,
            updated_at=observed_at,
            checkout_url=_value(session, "url"),
        )
