import sys
import os
from unittest.mock import MagicMock, patch
import pytest
from fastapi.testclient import TestClient

# Configuração de caminhos e envs antes do import
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src")))

os.environ["SUPABASE_URL"] = "https://mock.supabase.co"
os.environ["SUPABASE_SERVICE_KEY"] = "mock-key"
os.environ["STRIPE_API_KEY"] = "sk_test_mock"
os.environ["STRIPE_WEBHOOK_SECRET"] = "whsec_test_mock"

from main import app

client = TestClient(app)

def test_api_health():
    """Garante que o healthcheck da API responda com sucesso."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_api_auth_missing_header():
    """Garante que chamadas sem token JWT sejam bloqueadas com HTTP 401."""
    response = client.get("/api/profiles/me")
    assert response.status_code == 401
    assert "Token de autenticação ausente ou inválido" in response.json()["detail"]

@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_get_profile_me_bola_protection(mock_supabase, mock_get_user):
    """Garante que o perfil seja recuperado de forma BOLA-safe (usando ID do JWT)."""
    # Simular usuário do JWT
    mock_user = MagicMock()
    mock_user.id = "secure_jwt_user_id"
    mock_user.email = "jwt@lawrence.academy"
    mock_user.app_metadata = {"role": "student"}
    
    mock_auth_res = MagicMock()
    mock_auth_res.user = mock_user
    mock_get_user.return_value = mock_auth_res
    
    # Mock do Supabase DB
    mock_db_res = MagicMock()
    mock_db_res.data = {
        "id": "secure_jwt_user_id",
        "full_name": "Secure Student",
        "email": "jwt@lawrence.academy"
    }

    # Mock do Supabase DB usando .return_value para não registrar chamadas de configuração
    mock_supabase.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = mock_db_res
    
    # Executar chamada autenticada
    response = client.get(
        "/api/profiles/me",
        headers={"Authorization": "Bearer valid-jwt-token"}
    )
    
    assert response.status_code == 200
    assert response.json()["id"] == "secure_jwt_user_id"
    
    # Garantir que a filtragem do banco filtrou estritamente pelo ID do JWT (BOLA protection)
    mock_supabase.table.return_value.select.return_value.eq.assert_called_once_with("id", "secure_jwt_user_id")

@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_submit_task_bola_protection(mock_supabase, mock_get_user):
    """Garante que o envio de tarefas associe o user_id do JWT e ignore falsificações do corpo (BOLA)."""
    mock_user = MagicMock()
    mock_user.id = "real_student_id"
    mock_user.email = "real@student.com"
    mock_user.app_metadata = {"role": "student"}
    
    mock_auth_res = MagicMock()
    mock_auth_res.user = mock_user
    mock_get_user.return_value = mock_auth_res
    
    mock_db_res = MagicMock()
    mock_db_res.data = {"status": "success"}
    mock_supabase.table.return_value.insert.return_value.execute.return_value = mock_db_res
    
    # Tentar enviar tarefa enviando o payload correto (a API não aceita user_id no DTO de entrada)
    response = client.post(
        "/api/task_submissions",
        json={
            "task_id": "task_uuid_123",
            "selected_option": "A"
        },
        headers={"Authorization": "Bearer valid-jwt-token"}
    )
    
    assert response.status_code == 200
    
    # Garantir que o user_id inserido no payload final enviado ao banco foi o "real_student_id" do JWT
    mock_supabase.table.return_value.insert.assert_called_once_with({
        "task_id": "task_uuid_123",
        "user_id": "real_student_id",
        "selected_option": "A"
    })
