from typing import Optional, Protocol


InvoiceData = dict[str, object]


class InvoiceGateway(Protocol):
    async def list_by_customer_email(self, email: str) -> list[InvoiceData]: ...

    async def get_by_id(self, invoice_id: str) -> Optional[InvoiceData]: ...
