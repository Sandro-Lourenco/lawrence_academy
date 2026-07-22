from typing import Protocol

from src.modules.subscriptions.domain.entities import CheckoutStatus, Subscription


class SubscriptionGateway(Protocol):
    """Contrato neutro para operações no provedor de assinaturas."""

    async def cancel_at_period_end(self, subscription: Subscription) -> None:
        ...


class CheckoutGateway(Protocol):
    """Contrato neutro para consultar uma sessão de checkout."""

    async def get_status(
        self, checkout_id: str, expected_owner_id: str
    ) -> CheckoutStatus:
        ...
