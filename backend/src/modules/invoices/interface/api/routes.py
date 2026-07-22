from fastapi import APIRouter, Depends, HTTPException, status

from src.core.security.security import CurrentUser, get_current_user
from src.modules.invoices.application.use_cases import (
    GetInvoiceUseCase,
    ListInvoicesUseCase,
)
from src.modules.invoices.domain.gateways import InvoiceGateway
from src.modules.invoices.interface.api.dependencies import get_invoice_gateway

router = APIRouter(prefix="/api/v1/invoices", tags=["invoices"])


def _public_invoice(invoice: dict[str, object]) -> dict[str, object]:
    return {key: value for key, value in invoice.items() if key != "customer_email"}


@router.get("", status_code=status.HTTP_200_OK)
async def list_invoices(
    current_user: CurrentUser = Depends(get_current_user),
    gateway: InvoiceGateway = Depends(get_invoice_gateway),
):
    try:
        invoices = await ListInvoicesUseCase(gateway).execute(current_user.email)
        return {
            "status": "success",
            "data": [_public_invoice(invoice) for invoice in invoices],
        }
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Falha ao consultar faturas no provedor de pagamentos.",
        ) from exc


@router.get("/{invoice_id}", status_code=status.HTTP_200_OK)
async def get_invoice(
    invoice_id: str,
    current_user: CurrentUser = Depends(get_current_user),
    gateway: InvoiceGateway = Depends(get_invoice_gateway),
):
    try:
        invoice = await GetInvoiceUseCase(gateway).execute(
            invoice_id, current_user.email
        )
    except PermissionError as exc:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Acesso negado a esta fatura.",
        ) from exc
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Falha ao consultar a fatura no provedor de pagamentos.",
        ) from exc

    if invoice is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Fatura não encontrada.",
        )
    return {"status": "success", "data": _public_invoice(invoice)}
