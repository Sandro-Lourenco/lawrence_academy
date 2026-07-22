from typing import Optional

from src.modules.invoices.domain.gateways import InvoiceData, InvoiceGateway


class ListInvoicesUseCase:
    def __init__(self, gateway: InvoiceGateway) -> None:
        self.gateway = gateway

    async def execute(self, email: str) -> list[InvoiceData]:
        return await self.gateway.list_by_customer_email(email)


class GetInvoiceUseCase:
    def __init__(self, gateway: InvoiceGateway) -> None:
        self.gateway = gateway

    async def execute(self, invoice_id: str, email: str) -> Optional[InvoiceData]:
        invoice = await self.gateway.get_by_id(invoice_id)
        if invoice is None:
            return None
        if invoice.get("customer_email") != email:
            raise PermissionError("Invoice does not belong to the current user.")
        return invoice
