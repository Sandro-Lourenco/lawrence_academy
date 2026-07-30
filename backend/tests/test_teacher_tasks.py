import pytest
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from src.main import app
from src.core.security.security import get_current_user, CurrentUser

client = TestClient(app)

@pytest.fixture
def mock_teacher_user():
    return CurrentUser(id="teacher_123", email="teacher@lawrence.com", role="teacher")

@pytest.fixture
def mock_student_user():
    return CurrentUser(id="student_123", email="student@lawrence.com", role="student")

@patch("src.shared.database.db")
def test_create_task_by_teacher(mock_db, mock_teacher_user):
    """Testa se o professor pode criar uma tarefa com sucesso."""
    app.dependency_overrides[get_current_user] = lambda: mock_teacher_user

    def mock_table(table_name):
        mock_builder = MagicMock()
        if table_name == "courses":
            mock_builder.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value.data = {
                "instructor_id": "teacher_123"
            }
        elif table_name == "lessons":
            mock_builder.select.return_value.eq.return_value.eq.return_value.is_.return_value.maybe_single.return_value.execute.return_value.data = {
                "id": "lesson_123",
                "course_id": "course_123",
                "module_id": "module_123",
                "title": "Aula Teste",
                "order_index": 1,
                "duration_seconds": 300,
                "hls_storage_path": None,
                "status": "draft",
                "is_required": True,
            }
        elif table_name == "tasks":
            mock_insert_res = MagicMock()
            mock_insert_res.data = [{
                "id": "task_abc",
                "course_id": "course_123",
                "lesson_id": "lesson_123",
                "title": "Nova Atividade Prática",
                "prompt_question": "Faça uma costura francesa",
                "task_type": "practical",
                "options": None,
                "correct_option": None,
                "max_attempts": 2,
                "passing_score": 7.0,
                "created_at": "2026-07-25T12:00:00Z",
                "updated_at": "2026-07-25T12:00:00Z"
            }]
            mock_builder.insert.return_value.execute.return_value = mock_insert_res
        return mock_builder

    mock_db.table.side_effect = mock_table

    payload = {
        "course_id": "course_123",
        "lesson_id": "lesson_123",
        "title": "Nova Atividade Prática",
        "task_type": "practical",
        "description": "Faça uma costura francesa",
        "max_attempts": 2,
        "passing_score": 7.0
    }

    try:
        response = client.post(
            "/api/v1/tasks",
            json=payload,
            headers={"Authorization": "Bearer fake-token"}
        )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 201
    assert response.json()["status"] == "success"
    assert response.json()["data"]["id"] == "task_abc"

def test_create_task_forbidden_for_student(mock_student_user):
    """Garante que alunos não podem criar tarefas."""
    app.dependency_overrides[get_current_user] = lambda: mock_student_user

    payload = {
        "course_id": "course_123",
        "lesson_id": "lesson_123",
        "title": "Tentativa Aluno",
        "task_type": "practical"
    }

    try:
        response = client.post(
            "/api/v1/tasks",
            json=payload,
            headers={"Authorization": "Bearer fake-token"}
        )
    finally:
        app.dependency_overrides.clear()
        
    assert response.status_code == 403

@patch("src.shared.database.db")
def test_create_task_bola_protection(mock_db, mock_teacher_user):
    """Testa se professor de outro curso é rejeitado (BOLA)."""
    app.dependency_overrides[get_current_user] = lambda: mock_teacher_user

    def mock_table(table_name):
        mock_builder = MagicMock()
        if table_name == "courses":
            mock_builder.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value.data = {
                "instructor_id": "teacher_different"
            }
        return mock_builder

    mock_db.table.side_effect = mock_table

    payload = {
        "course_id": "course_123",
        "lesson_id": "lesson_123",
        "title": "BOLA Test",
        "task_type": "practical"
    }

    try:
        response = client.post(
            "/api/v1/tasks",
            json=payload,
            headers={"Authorization": "Bearer fake-token"}
        )
    finally:
        app.dependency_overrides.clear()
        
    assert response.status_code == 403
    assert "Acesso negado" in response.json()["error"]["message"]

@patch("src.shared.database.db")
def test_update_task_by_teacher(mock_db, mock_teacher_user):
    """Testa se o professor pode atualizar sua tarefa."""
    app.dependency_overrides[get_current_user] = lambda: mock_teacher_user

    def mock_table(table_name):
        mock_builder = MagicMock()
        if table_name == "courses":
            mock_builder.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value.data = {
                "instructor_id": "teacher_123"
            }
        elif table_name == "tasks":
            # select tasks
            mock_select_res = MagicMock()
            mock_select_res.data = [{
                "id": "task_abc",
                "course_id": "course_123",
                "lesson_id": "lesson_123",
                "title": "Atividade Prática Antiga",
                "prompt_question": "Pergunta",
                "task_type": "practical",
                "options": None,
                "correct_option": None,
                "max_attempts": 1,
                "passing_score": "5.00",
                "created_at": "2026-07-25T12:00:00Z",
                "updated_at": "2026-07-25T12:00:00Z"
            }]
            mock_builder.select.return_value.eq.return_value.is_.return_value.execute.return_value = mock_select_res

            # update tasks
            mock_update_res = MagicMock()
            mock_update_res.data = [{
                "id": "task_abc",
                "course_id": "course_123",
                "lesson_id": "lesson_123",
                "title": "Atividade Prática Atualizada",
                "prompt_question": "Pergunta",
                "task_type": "practical",
                "options": None,
                "correct_option": None,
                "max_attempts": 1,
                "passing_score": "5.00",
                "created_at": "2026-07-25T12:00:00Z",
                "updated_at": "2026-07-25T12:00:00Z"
            }]
            mock_builder.update.return_value.eq.return_value.execute.return_value = mock_update_res
        return mock_builder

    mock_db.table.side_effect = mock_table

    payload = {
        "title": "Atividade Prática Atualizada"
    }

    try:
        response = client.patch(
            "/api/v1/tasks/task_abc",
            json=payload,
            headers={"Authorization": "Bearer fake-token"}
        )
    finally:
        app.dependency_overrides.clear()
        
    assert response.status_code == 200
    assert response.json()["data"]["title"] == "Atividade Prática Atualizada"

@patch("src.shared.database.db")
def test_delete_task_by_teacher(mock_db, mock_teacher_user):
    """Testa se o professor pode deletar logicamente uma tarefa."""
    app.dependency_overrides[get_current_user] = lambda: mock_teacher_user

    def mock_table(table_name):
        mock_builder = MagicMock()
        if table_name == "courses":
            mock_builder.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value.data = {
                "instructor_id": "teacher_123"
            }
        elif table_name == "tasks":
            # select tasks
            mock_select_res = MagicMock()
            mock_select_res.data = [{
                "id": "task_abc",
                "course_id": "course_123",
                "lesson_id": "lesson_123",
                "title": "Atividade Prática",
                "prompt_question": "Pergunta",
                "task_type": "practical",
                "options": None,
                "correct_option": None,
                "max_attempts": 1,
                "passing_score": "5.00",
                "created_at": "2026-07-25T12:00:00Z",
                "updated_at": "2026-07-25T12:00:00Z"
            }]
            mock_builder.select.return_value.eq.return_value.is_.return_value.execute.return_value = mock_select_res

            # update tasks (soft delete)
            mock_delete_res = MagicMock()
            mock_delete_res.data = [{"id": "task_abc"}]
            mock_builder.update.return_value.eq.return_value.execute.return_value = mock_delete_res
        return mock_builder

    mock_db.table.side_effect = mock_table

    try:
        response = client.delete(
            "/api/v1/tasks/task_abc",
            headers={"Authorization": "Bearer fake-token"}
        )
    finally:
        app.dependency_overrides.clear()
        
    assert response.status_code == 200
    assert "excluída logicamente" in response.json()["message"]
