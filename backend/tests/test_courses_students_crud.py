import sys
import os
from unittest.mock import MagicMock, patch
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


def test_api_root():
    """Garante que a rota raiz retorne o status operacional correto."""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"status": "API da Lawrence Academy Operacional"}


@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_get_all_courses(mock_db, mock_get_user):
    """Garante que a listagem de cursos retorne a lista mockada do banco."""
    # Mock de autenticação
    mock_user = MagicMock()
    mock_user.id = "user_id_123"
    mock_user.email = "student@gmail.com"
    mock_user.app_metadata = {"role": "student"}
    mock_auth_res = MagicMock()
    mock_auth_res.user = mock_user
    mock_get_user.return_value = mock_auth_res

    # Mock do banco
    mock_db_res = MagicMock()
    mock_db_res.data = [
        {
            "id": "course_uuid_1",
            "instructor_id": "inst_123",
            "title": "Introdução à Costura",
            "slug": "introducao-costura",
            "category": "costura",
            "level": "iniciante",
            "summary": "Resumo do curso",
            "monthly_price": 49.90,
            "status": "published",
        }
    ]
    mock_db.table.return_value.select.return_value.is_.return_value.execute.return_value = mock_db_res

    response = client.get("/courses", headers={"Authorization": "Bearer token"})
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["id"] == "course_uuid_1"
    assert data[0]["title"] == "Introdução à Costura"


@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_get_lesson_by_id_success(mock_db, mock_get_user):
    """Garante o retorno correto da aula se encontrada."""
    mock_user = MagicMock()
    mock_user.id = "user_id_123"
    mock_user.email = "student@gmail.com"
    mock_user.app_metadata = {"role": "student"}
    mock_auth_res = MagicMock()
    mock_auth_res.user = mock_user
    mock_get_user.return_value = mock_auth_res

    mock_db_res = MagicMock()
    mock_db_res.data = {
        "id": "lesson_uuid_1",
        "module_id": "mod_uuid_1",
        "course_id": "course_uuid_1",
        "title": "Aula 1: Introdução",
        "order_index": 1,
        "duration_seconds": 120,
        "hls_storage_path": "path/to/hls.m3u8",
        "status": "published",
    }
    mock_db.table.return_value.select.return_value.eq.return_value.eq.return_value.maybe_single.return_value.execute.return_value = mock_db_res

    response = client.get(
        "/courses/course_uuid_1/lessons/lesson_uuid_1",
        headers={"Authorization": "Bearer token"},
    )
    assert response.status_code == 200
    assert response.json()["id"] == "lesson_uuid_1"
    assert response.json()["title"] == "Aula 1: Introdução"


@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_get_lesson_by_id_not_found(mock_db, mock_get_user):
    """Garante HTTP 404 se a aula não existir para o curso."""
    mock_user = MagicMock()
    mock_user.id = "user_id_123"
    mock_user.email = "student@gmail.com"
    mock_user.app_metadata = {"role": "student"}
    mock_auth_res = MagicMock()
    mock_auth_res.user = mock_user
    mock_get_user.return_value = mock_auth_res

    mock_db_res = MagicMock()
    mock_db_res.data = None
    mock_db.table.return_value.select.return_value.eq.return_value.eq.return_value.maybe_single.return_value.execute.return_value = mock_db_res

    response = client.get(
        "/courses/course_uuid_1/lessons/lesson_uuid_999",
        headers={"Authorization": "Bearer token"},
    )
    assert response.status_code == 404
    assert "não encontrada" in response.json()["error"]["message"]


@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_get_student_profile_success(mock_db, mock_get_user):
    """Garante o retorno correto do perfil do aluno autenticado."""
    mock_user = MagicMock()
    mock_user.id = "student_uuid_123"
    mock_user.email = "student@lawrence.academy"
    mock_user.app_metadata = {"role": "student"}
    mock_auth_res = MagicMock()
    mock_auth_res.user = mock_user
    mock_get_user.return_value = mock_auth_res

    mock_db_res = MagicMock()
    mock_db_res.data = {
        "id": "student_uuid_123",
        "email": "student@lawrence.academy",
        "full_name": "Fulano de Tal",
        "referred_by": None,
        "role": "student",
    }
    mock_db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = mock_db_res

    response = client.get("/students/me", headers={"Authorization": "Bearer token"})
    assert response.status_code == 200
    assert response.json()["id"] == "student_uuid_123"
    assert response.json()["full_name"] == "Fulano de Tal"


@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_update_student_profile_success(mock_db, mock_get_user):
    """Garante a atualização correta do perfil do aluno."""
    mock_user = MagicMock()
    mock_user.id = "student_uuid_123"
    mock_user.email = "student@lawrence.academy"
    mock_user.app_metadata = {"role": "student"}
    mock_auth_res = MagicMock()
    mock_auth_res.user = mock_user
    mock_get_user.return_value = mock_auth_res

    mock_db_res = MagicMock()
    mock_db_res.data = [
        {
            "id": "student_uuid_123",
            "email": "student@lawrence.academy",
            "full_name": "Novo Nome",
            "referred_by": "indicator_uuid",
            "role": "student",
        }
    ]
    mock_db.table.return_value.update.return_value.eq.return_value.execute.return_value = mock_db_res

    response = client.put(
        "/students/me",
        json={"full_name": "Novo Nome", "referred_by": "indicator_uuid"},
        headers={"Authorization": "Bearer token"},
    )
    assert response.status_code == 200
    assert response.json()["full_name"] == "Novo Nome"
    assert response.json()["referred_by"] == "indicator_uuid"
