import stripe

from src.modules.invoices.domain.gateways import InvoiceData


def _serialize_invoice(invoice: object) -> InvoiceData:
    return {
        "id": getattr(invoice, "id"),
        "amount_paid": getattr(invoice, "amount_paid") / 100.0,
        "currency": getattr(invoice, "currency").upper(),
        "status": getattr(invoice, "status"),
        "invoice_pdf": getattr(invoice, "invoice_pdf"),
        "hosted_invoice_url": getattr(invoice, "hosted_invoice_url"),
        "created_at": getattr(invoice, "created"),
        "customer_email": getattr(invoice, "customer_email", None),
    }


class StripeInvoiceGateway:
    async def list_by_customer_email(self, email: str) -> list[InvoiceData]:
        customers = stripe.Customer.search(query=f"email:'{email}'")
        if not customers.data:
            return []
        invoices = stripe.Invoice.list(customer=customers.data[0].id)
        return [_serialize_invoice(invoice) for invoice in invoices.data]

    async def get_by_id(self, invoice_id: str) -> InvoiceData:
        return _serialize_invoice(stripe.Invoice.retrieve(invoice_id))


class FakeInvoiceGateway:
    async def list_by_customer_email(self, email: str) -> list[InvoiceData]:
        return []

    async def get_by_id(self, invoice_id: str) -> None:
        return None
