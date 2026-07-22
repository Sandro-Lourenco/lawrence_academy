from src.modules.invoices.domain.gateways import InvoiceGateway
from src.modules.invoices.infrastructure.stripe_invoice_gateway import (
    FakeInvoiceGateway,
    StripeInvoiceGateway,
)
from src.shared.config import settings


def get_invoice_gateway() -> InvoiceGateway:
    if settings.app_env == "test" or settings.payment_provider == "fake":
        return FakeInvoiceGateway()
    return StripeInvoiceGateway()
