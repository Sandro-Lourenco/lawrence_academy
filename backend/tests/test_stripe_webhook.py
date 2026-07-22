import sys
import os

# Definir mock secrets antes dos imports para o os.getenv
os.environ["STRIPE_API_KEY"] = "sk_test_mock"
os.environ["STRIPE_WEBHOOK_SECRET"] = "whsec_test_mock"
os.environ["SUPABASE_URL"] = "https://mock.supabase.co"
os.environ["SUPABASE_SERVICE_KEY"] = "mock-service-key"

from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src")))

from fastapi import FastAPI
from src.modules.payments.interface.api.routes import (
    router as payments_v1_router,
    legacy_router,
)
from src.core.errors.handlers import install_error_handlers

app = FastAPI()
app.include_router(payments_v1_router)
app.include_router(legacy_router)
install_error_handlers(app)

client = TestClient(app)


@patch("src.modules.payments.interface.api.routes.stripe.Webhook.construct_event")
def test_stripe_webhook_invalid_signature(mock_construct):
    """Testa se a API rejeita requisições com assinatura inválida no Stripe."""
    mock_construct.side_effect = Exception("Signature verification failed")

    response = client.post(
        "/api/v1/payments/webhook",
        content=b"invalid-payload",
        headers={"stripe-signature": "invalid-sig"},
    )

    assert response.status_code == 400
    assert "Falha na verifica" in response.json()["detail"]


@patch("src.modules.payments.interface.api.routes.stripe.Webhook.construct_event")
@patch("src.shared.database.db")
def test_stripe_webhook_idempotency_duplicate(mock_supabase, mock_construct):
    """Testa se a concorrência e processamento duplicado é evitado retornando 200."""
    mock_construct.return_value = {
        "id": "evt_duplicate",
        "type": "invoice.payment_succeeded",
        "data": {"object": {}},
    }

    mock_insert = MagicMock()
    mock_insert.execute.side_effect = Exception(
        "duplicate key value violates unique constraint"
    )
    mock_supabase.table().insert.return_value = mock_insert

    mock_select = MagicMock()
    mock_select.data = [{"status": "processed"}]
    mock_supabase.table().select().eq().eq().execute.return_value = mock_select

    response = client.post(
        "/api/v1/payments/webhook",
        content=b"payload",
        headers={"stripe-signature": "valid-sig"},
    )

    # 200 indica ao stripe que já foi recebido, evita retentativas eternas
    assert response.status_code == 200
    assert response.json()["message"] == "Duplicate event ignored."


@patch("src.modules.payments.interface.api.routes.stripe.Webhook.construct_event")
@patch("src.shared.database.db")
@patch("src.modules.payments.interface.api.routes.StripeWebhookProcessor.process_event")
def test_stripe_webhook_idempotency_retry_success(
    mock_process, mock_supabase, mock_construct
):
    """Testa retry seguro de um evento que estava como 'failed'."""
    mock_construct.return_value = {
        "id": "evt_failed_retry",
        "type": "invoice.payment_succeeded",
        "data": {"object": {}},
    }

    mock_insert = MagicMock()
    mock_insert.execute.side_effect = Exception("unique constraint")

    mock_select = MagicMock()
    mock_select.data = [{"status": "failed"}]

    mock_update = MagicMock()
    mock_update.data = [{"status": "processing"}]

    def table_router(t):
        mock_t = MagicMock()
        mock_t.insert.return_value = mock_insert
        mock_t.select().eq().eq().execute.return_value = mock_select
        mock_t.update().eq().eq().execute.return_value = mock_update
        return mock_t

    mock_supabase.table.side_effect = table_router

    response = client.post(
        "/api/v1/payments/webhook",
        content=b"payload",
        headers={"stripe-signature": "valid-sig"},
    )

    # O process_event foi mockado (não faz nada), então retorna 200 após retry
    assert response.status_code == 200
    mock_process.assert_called_once()


@patch("src.modules.payments.interface.api.routes.stripe.Webhook.construct_event")
@patch("src.shared.database.db")
@patch("src.modules.payments.interface.api.routes.StripeWebhookProcessor.process_event")
def test_stripe_webhook_processing_failure(mock_process, mock_supabase, mock_construct):
    """Testa falha após efeito parcial onde a transação realça o erro e marca como failed."""
    mock_construct.return_value = {
        "id": "evt_fail_partial",
        "type": "invoice.payment_succeeded",
        "data": {"object": {}},
    }

    # processamento do evento causa erro
    mock_process.side_effect = Exception("Partial effect error")

    mock_insert = MagicMock()
    mock_insert.data = [{"id": 1}]

    def table_router(t):
        mock_t = MagicMock()
        mock_t.insert.return_value = mock_insert
        return mock_t

    mock_supabase.table.side_effect = table_router

    response = client.post(
        "/api/v1/payments/webhook",
        content=b"payload",
        headers={"stripe-signature": "valid-sig"},
    )

    assert response.status_code == 502
    assert "Erro ao processar webhook" in response.json()["error"]["message"]


@patch("src.modules.payments.interface.api.routes.stripe.Webhook.construct_event")
@patch("src.shared.database.db")
@patch("src.modules.payments.application.process_webhook.stripe.Subscription.retrieve")
@patch(
    "src.modules.payments.application.process_webhook.stripe.Customer.create_balance_transaction"
)
def test_stripe_webhook_payment_succeeded_referral(
    mock_create_balance, mock_retrieve_sub, mock_supabase, mock_construct
):
    """Testa os eventos principais sem assinatura ou comissão duplicada."""
    mock_construct.return_value = {
        "id": "evt_success_999",
        "type": "invoice.payment_succeeded",
        "data": {
            "object": {
                "subscription": "sub_test_999",
                "customer": "cust_new_student",
                "customer_email": "new@student.com",
                "billing_reason": "subscription_create",
            }
        },
    }

    mock_sub = MagicMock()
    mock_sub.current_period_start = 1717171717
    mock_sub.current_period_end = 1717271717
    mock_sub.metadata = {"user_id": "student_uuid"}
    mock_retrieve_sub.return_value = mock_sub

    mock_lock_res = MagicMock()
    mock_lock_res.data = [{"event_id": "evt_success_999"}]

    mock_profile_res = MagicMock()
    mock_profile_res.data = [{"referred_by": "indicator_uuid"}]

    mock_ind_sub_res = MagicMock()
    mock_ind_sub_res.data = [{"stripe_customer_id": "cust_indicator_stripe"}]

    def mock_table_routing(table_name):
        mock_query = MagicMock()
        if table_name == "payment_events":
            mock_query.insert().execute.return_value = mock_lock_res
        elif table_name == "profiles":
            mock_query.select().eq().limit().execute.return_value = mock_profile_res
        elif table_name == "subscriptions":
            mock_query.select().eq().eq().order().limit().execute.return_value = (
                mock_ind_sub_res
            )
            mock_query.upsert().execute.return_value = mock_ind_sub_res
        elif table_name == "notifications":
            mock_query.insert().execute.return_value = MagicMock()
        return mock_query

    mock_supabase.table.side_effect = mock_table_routing

    response = client.post(
        "/api/v1/payments/webhook",
        content=b"payload",
        headers={"stripe-signature": "valid-sig"},
    )

    assert response.status_code == 200
    assert response.json()["event_processed"] == "evt_success_999"

    # Verifica se idempotency_key foi passada
    mock_create_balance.assert_called_once_with(
        "cust_indicator_stripe",
        amount=-2000,
        currency="brl",
        description="Crédito de indicação do aluno indicado: new@student.com",
        idempotency_key="referral_evt_success_999",
    )


@patch("src.modules.payments.interface.api.routes.stripe.Webhook.construct_event")
@patch("src.shared.database.db")
def test_stripe_webhook_legacy_endpoint(mock_supabase, mock_construct):
    """Garante que a rota legada mantenha o comportamento compatível."""
    mock_construct.return_value = {
        "id": "evt_legacy_123",
        "type": "customer.subscription.deleted",
        "data": {"object": {"id": "sub_test_001"}},
    }

    mock_lock = MagicMock()
    mock_lock.data = [{"id": 1}]

    mock_update = MagicMock()
    mock_update.data = [{"student_id": "student-123"}]

    def table_router(t):
        mock_query = MagicMock()
        if t == "payment_events":
            mock_query.insert().execute.return_value = mock_lock
        elif t == "subscriptions":
            mock_query.update().eq().execute.return_value = mock_update
        return mock_query

    mock_supabase.table.side_effect = table_router

    response = client.post(
        "/webhooks/stripe",
        content=b"payload_legacy",
        headers={"stripe-signature": "valid-sig"},
    )

    assert response.status_code == 200
    assert response.json()["event_processed"] == "evt_legacy_123"
