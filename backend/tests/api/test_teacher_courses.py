import sys
import os
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")))

os.environ["SUPABASE_URL"] = "https://mock.supabase.co"
os.environ["SUPABASE_SERVICE_KEY"] = "mock-key"

from src.main import app

client = TestClient(app)


def _mock_user(role="teacher", user_id="teacher_uuid"):
    mock_user = MagicMock()
    mock_user.id = user_id
    mock_user.email = f"{role}@lawrence.academy"
    mock_user.app_metadata = {"role": role}
    mock_auth_res = MagicMock()
    mock_auth_res.user = mock_user
    return mock_auth_res


@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_teacher_create_module_success(mock_db, mock_get_user):
    """Garante que um professor dono do curso pode criar módulo."""
    mock_get_user.return_value = _mock_user("teacher", "teacher_123")

    # Mock get_instructor_id
    mock_db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = MagicMock(
        data={"instructor_id": "teacher_123"}
    )

    # Mock insert
    mock_db.table.return_value.insert.return_value.execute.return_value = MagicMock(
        data=[
            {
                "id": "module_uuid_1",
                "course_id": "course_uuid_1",
                "title": "Módulo de Teste",
                "order_index": 0,
                "lessons": [],
            }
        ]
    )

    response = client.post(
        "/api/v1/teacher/courses/course_uuid_1/modules",
        json={"title": "Módulo de Teste", "order_index": 0},
        headers={"Authorization": "Bearer token"},
    )
    assert response.status_code == 201
    assert response.json()["title"] == "Módulo de Teste"


@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_student_cannot_create_module(mock_db, mock_get_user):
    """Garante que alunos tomam 403."""
    mock_get_user.return_value = _mock_user("student", "student_123")

    response = client.post(
        "/api/v1/teacher/courses/course_uuid_1/modules",
        json={"title": "Módulo de Teste"},
        headers={"Authorization": "Bearer token"},
    )
    assert response.status_code == 403


@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_non_owner_teacher_cannot_create_module(mock_db, mock_get_user):
    """Garante que um professor não-dono do curso não pode criar módulo."""
    mock_get_user.return_value = _mock_user("teacher", "teacher_456")

    # Mock get_instructor_id returning a DIFFERENT instructor
    mock_db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = MagicMock(
        data={"instructor_id": "teacher_123"}
    )

    response = client.post(
        "/api/v1/teacher/courses/course_uuid_1/modules",
        json={"title": "Módulo de Teste"},
        headers={"Authorization": "Bearer token"},
    )
    assert response.status_code == 403


@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_admin_can_create_module(mock_db, mock_get_user):
    """Garante que um super_admin pode criar módulo, mesmo não sendo dono."""
    mock_get_user.return_value = _mock_user("super_admin", "admin_123")

    # Mock get_instructor_id returning a DIFFERENT instructor
    mock_db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = MagicMock(
        data={"instructor_id": "teacher_123"}
    )

    # Mock insert
    mock_db.table.return_value.insert.return_value.execute.return_value = MagicMock(
        data=[
            {
                "id": "module_uuid_1",
                "course_id": "course_uuid_1",
                "title": "Módulo de Admin",
                "order_index": 0,
                "lessons": [],
            }
        ]
    )

    response = client.post(
        "/api/v1/teacher/courses/course_uuid_1/modules",
        json={"title": "Módulo de Admin"},
        headers={"Authorization": "Bearer token"},
    )
    assert response.status_code == 201


@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_patch_module_partial_update(mock_db, mock_get_user):
    """Testa atualização parcial de módulo."""
    mock_get_user.return_value = _mock_user("teacher", "teacher_123")

    # Mock get_module
    mock_db.table.return_value.select.return_value.eq.return_value.eq.return_value.is_.return_value.maybe_single.return_value.execute.return_value = MagicMock(
        data={
            "id": "module_uuid_1",
            "course_id": "course_uuid_1",
            "title": "Velho Titulo",
            "order_index": 1,
            "lessons": [],
        }
    )

    # Mock get_instructor_id
    mock_db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = MagicMock(
        data={"instructor_id": "teacher_123"}
    )

    # Mock update
    mock_db.table.return_value.update.return_value.eq.return_value.execute.return_value = MagicMock(
        data=[
            {
                "id": "module_uuid_1",
                "course_id": "course_uuid_1",
                "title": "Novo Titulo",
                "order_index": 1,
                "lessons": [],
            }
        ]
    )

    response = client.patch(
        "/api/v1/teacher/courses/course_uuid_1/modules/module_uuid_1",
        json={"title": "Novo Titulo"},
        headers={"Authorization": "Bearer token"},
    )
    assert response.status_code == 200
    assert response.json()["title"] == "Novo Titulo"


@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_module_from_another_course_bola(mock_db, mock_get_user):
    """Garante BOLA-safe check (modulo de outro curso)."""
    mock_get_user.return_value = _mock_user("teacher", "teacher_123")

    # Retorna None porque o curso especificado na url não bate com o do módulo
    mock_db.table.return_value.select.return_value.eq.return_value.eq.return_value.is_.return_value.maybe_single.return_value.execute.return_value = MagicMock(
        data=None
    )

    response = client.patch(
        "/api/v1/teacher/courses/course_wrong/modules/module_uuid_1",
        json={"title": "Hacker"},
        headers={"Authorization": "Bearer token"},
    )
    assert response.status_code == 404


@patch("src.shared.database.auth_db.auth.get_user")
@patch("src.shared.database.db")
def test_safe_deletion_module(mock_db, mock_get_user):
    """Testa deleção segura."""
    mock_get_user.return_value = _mock_user("teacher", "teacher_123")

    mock_db.table.return_value.select.return_value.eq.return_value.eq.return_value.is_.return_value.maybe_single.return_value.execute.return_value = MagicMock(
        data={
            "id": "module_uuid_1",
            "course_id": "course_uuid_1",
            "title": "Velho Titulo",
            "order_index": 1,
            "lessons": [],
        }
    )
    mock_db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = MagicMock(
        data={"instructor_id": "teacher_123"}
    )

    mock_db.table.return_value.update.return_value.eq.return_value.execute.return_value = MagicMock(
        data=[{"id": "module_uuid_1"}]
    )

    response = client.delete(
        "/api/v1/teacher/courses/course_uuid_1/modules/module_uuid_1",
        headers={"Authorization": "Bearer token"},
    )
    assert response.status_code == 200
