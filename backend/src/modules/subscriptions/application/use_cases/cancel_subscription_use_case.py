from datetime import datetime, timezone

from src.core.errors.errors import AuthorizationError, ConflictError, NotFoundError
from src.modules.subscriptions.domain.entities import Subscription
from src.modules.subscriptions.domain.gateways import SubscriptionGateway
from src.modules.subscriptions.domain.repositories import SubscriptionRepository


class CancelSubscriptionUseCase:
    def __init__(
        self,
        repository: SubscriptionRepository,
        gateway: SubscriptionGateway,
    ) -> None:
        self.repository = repository
        self.gateway = gateway

    async def execute(self, subscription_id: str, student_id: str) -> Subscription:
        subscription = await self.repository.get_by_id(subscription_id)
        if subscription is None:
            raise NotFoundError("Assinatura não encontrada.")
        if subscription.student_id != student_id:
            raise AuthorizationError("Esta assinatura pertence a outro usuário.")
        if subscription.cancel_at_period_end or subscription.status in (
            "canceled",
            "cancelled",
        ):
            raise ConflictError("Esta assinatura já foi cancelada.")

        await self.gateway.cancel_at_period_end(subscription)
        return await self.repository.mark_cancel_at_period_end(
            subscription_id, datetime.now(timezone.utc)
        )
