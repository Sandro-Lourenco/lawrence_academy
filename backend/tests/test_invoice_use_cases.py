import pytest

from src.modules.invoices.application.use_cases import (
    GetInvoiceUseCase,
    ListInvoicesUseCase,
)


class InvoiceGatewayStub:
    def __init__(self, invoices: list[dict[str, object]]) -> None:
        self.invoices = invoices

    async def list_by_customer_email(self, email: str) -> list[dict[str, object]]:
        return [invoice for invoice in self.invoices if invoice["customer_email"] == email]

    async def get_by_id(self, invoice_id: str) -> dict[str, object] | None:
        return next(
            (invoice for invoice in self.invoices if invoice["id"] == invoice_id),
            None,
        )


@pytest.mark.asyncio
async def test_list_invoices_uses_authenticated_email() -> None:
    gateway = InvoiceGatewayStub(
        [
            {"id": "inv_1", "customer_email": "student@example.com"},
            {"id": "inv_2", "customer_email": "other@example.com"},
        ]
    )

    result = await ListInvoicesUseCase(gateway).execute("student@example.com")

    assert [invoice["id"] for invoice in result] == ["inv_1"]


@pytest.mark.asyncio
async def test_get_invoice_rejects_other_customer() -> None:
    gateway = InvoiceGatewayStub(
        [{"id": "inv_1", "customer_email": "other@example.com"}]
    )

    with pytest.raises(PermissionError):
        await GetInvoiceUseCase(gateway).execute("inv_1", "student@example.com")


@pytest.mark.asyncio
async def test_get_invoice_returns_none_when_missing() -> None:
    gateway = InvoiceGatewayStub([])

    result = await GetInvoiceUseCase(gateway).execute(
        "missing", "student@example.com"
    )

    assert result is None
