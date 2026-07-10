import sys
import os

# Definir mock secrets antes dos imports para o os.getenv
os.environ["STRIPE_API_KEY"] = "sk_test_mock"
os.environ["STRIPE_WEBHOOK_SECRET"] = "whsec_test_mock"
os.environ["SUPABASE_URL"] = "https://mock.supabase.co"
os.environ["SUPABASE_SERVICE_KEY"] = "mock-service-key"

from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient

# Adicionar caminhos para importação correta
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src")))

# Criamos uma mini-aplicação FastAPI para testar a rota do webhook
from fastapi import FastAPI
from src.modules.payments.interfaces.routes import router

app = FastAPI()
app.include_router(router)

client = TestClient(app)


@patch("src.modules.payments.interfaces.routes.stripe.Webhook.construct_event")
@patch("src.shared.database.db")
def test_stripe_webhook_invalid_signature(mock_supabase, mock_construct):
    """Garante que assinaturas inválidas no cabeçalho retornem status 400."""
    mock_construct.side_effect = Exception("Signature verification failed")

    response = client.post(
        "/webhooks/stripe",
        content=b"invalid-payload",
        headers={"stripe-signature": "invalid-sig"},
    )

    assert response.status_code == 400
    assert "Webhook signature verification failed" in response.json()["detail"]


@patch("src.modules.payments.interfaces.routes.stripe.Webhook.construct_event")
@patch("src.shared.database.db")
def test_stripe_webhook_idempotency_duplicate(mock_supabase, mock_construct):
    """Garante que eventos duplicados já registrados retornem sucesso e parem a execução."""
    # Configurar mock do evento do Stripe
    mock_construct.return_value = {
        "id": "evt_test_123",
        "type": "invoice.payment_succeeded",
        "data": {"object": {}},
    }

    # Simular Unique Constraint violation do Postgres no Supabase
    mock_supabase.table().insert().execute.side_effect = Exception(
        "duplicate key value violates unique constraint"
    )

    response = client.post(
        "/webhooks/stripe",
        content=b"payload",
        headers={"stripe-signature": "valid-sig"},
    )

    assert response.status_code == 200
    assert response.json()["message"] == "Duplicate event ignored."


@patch("src.modules.payments.interfaces.routes.stripe.Webhook.construct_event")
@patch("src.shared.database.db")
@patch("src.modules.payments.application.process_webhook.stripe.Subscription.retrieve")
@patch(
    "src.modules.payments.application.process_webhook.stripe.Customer.create_balance_transaction"
)
def test_stripe_webhook_payment_succeeded_referral(
    mock_create_balance, mock_retrieve_sub, mock_supabase, mock_construct
):
    """Valida o fluxo completo de pagamento confirmado com indicação e aplicação de créditos."""
    # Mocks de dados
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

    # Mock do Stripe Subscription
    mock_sub = MagicMock()
    mock_sub.current_period_start = 1717171717
    mock_sub.current_period_end = 1717271717
    mock_sub.metadata = {"user_id": "student_uuid"}
    mock_retrieve_sub.return_value = mock_sub

    # Mocks do Supabase para processamento do referral e profiles
    # 1. Registro da trava de idempotência (sucesso)
    # 2. Busca do perfil do indicado para ver o referred_by
    # 3. Busca da assinatura ativa do indicador para obter o stripe_customer_id
    # 4. Upsert da nova assinatura
    # 5. Insert de notificações

    mock_lock_res = MagicMock()
    mock_lock_res.data = [{"event_id": "evt_success_999"}]

    mock_profile_res = MagicMock()
    mock_profile_res.data = [{"referred_by": "indicator_uuid"}]

    mock_ind_sub_res = MagicMock()
    mock_ind_sub_res.data = [{"stripe_customer_id": "cust_indicator_stripe"}]

    # Mock de encadeamento das chamadas da API do Supabase
    mock_supabase.table.side_effect = lambda table_name: mock_table_routing(
        table_name, mock_lock_res, mock_profile_res, mock_ind_sub_res
    )

    response = client.post(
        "/webhooks/stripe",
        content=b"payload",
        headers={"stripe-signature": "valid-sig"},
    )

    assert response.status_code == 200
    assert response.json()["event_processed"] == "evt_success_999"

    # Verificar se aplicou o crédito de R$ 20.00 (2000 centavos) na conta Stripe do indicador
    mock_create_balance.assert_called_once_with(
        "cust_indicator_stripe",
        amount=-2000,
        currency="brl",
        description="Crédito de indicação do aluno indicado: new@student.com",
    )


def mock_table_routing(table_name, mock_lock_res, mock_profile_res, mock_ind_sub_res):
    mock_query = MagicMock()

    if table_name == "stripe_processed_events":
        mock_query.insert.return_value = mock_query
        mock_query.execute.return_value = mock_lock_res
    elif table_name == "profiles":
        mock_query.select.return_value = mock_query
        mock_query.eq.return_value = mock_query
        mock_query.limit.return_value = mock_query
        mock_query.execute.return_value = mock_profile_res
    elif table_name == "subscriptions":
        mock_query.select.return_value = mock_query
        mock_query.eq.return_value = mock_query
        mock_query.order.return_value = mock_query
        mock_query.limit.return_value = mock_query
        mock_query.upsert.return_value = mock_query
        mock_query.execute.return_value = mock_ind_sub_res
    elif table_name == "notifications":
        mock_query.insert.return_value = mock_query
        mock_query.execute.return_value = MagicMock()

    return mock_query
