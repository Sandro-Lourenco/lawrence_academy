from src.core.errors.errors import AuthorizationError
from src.modules.subscriptions.domain.entities import CheckoutStatus
from src.modules.subscriptions.domain.gateways import CheckoutGateway


class GetCheckoutStatusUseCase:
    def __init__(self, gateway: CheckoutGateway) -> None:
        self.gateway = gateway

    async def execute(self, checkout_id: str, student_id: str) -> CheckoutStatus:
        checkout = await self.gateway.get_status(checkout_id, student_id)
        if checkout.owner_id != student_id:
            raise AuthorizationError("Este checkout pertence a outro usuário.")
        return checkout
