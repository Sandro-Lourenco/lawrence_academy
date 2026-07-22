from src.core.database.database import get_admin_supabase_client
from src.modules.subscriptions.domain.repositories import SubscriptionRepository
from src.modules.subscriptions.domain.gateways import CheckoutGateway, SubscriptionGateway
from src.modules.subscriptions.infrastructure.repositories.supabase_subscription_repository import (
    SupabaseSubscriptionRepository,
)
from src.modules.subscriptions.infrastructure.stripe_gateway import (
    StripeCheckoutGateway,
    StripeSubscriptionGateway,
)


def get_subscription_repository() -> SubscriptionRepository:
    return SupabaseSubscriptionRepository(get_admin_supabase_client())


def get_subscription_gateway() -> SubscriptionGateway:
    return StripeSubscriptionGateway()


def get_checkout_gateway() -> CheckoutGateway:
    return StripeCheckoutGateway()
