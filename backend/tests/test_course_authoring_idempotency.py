from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from fastapi.testclient import TestClient

from src.main import app
from src.modules.courses.application.use_cases.create_lesson_use_case import (
    CreateLessonUseCase,
)
from src.modules.courses.application.use_cases.publish_course_use_case import (
    CoursePublicationUseCase,
)
from src.modules.courses.interface.api.dependencies import get_course_repository

client = TestClient(app)


def test_teacher_authoring_post_routes_require_idempotency_header():
    schema = app.openapi()
    paths = [
        "/api/v1/teacher/courses",
        "/api/v1/teacher/courses/{course_id}/modules",
        "/api/v1/teacher/courses/{course_id}/modules/{module_id}/lessons",
        "/api/v1/teacher/courses/{course_id}/lessons/{lesson_id}/blocks",
        "/api/v1/teacher/courses/{course_id}/lessons/{lesson_id}/blocks/{block_id}/duplicate",
        "/api/v1/teacher/courses/{course_id}/publish",
    ]
    for path in paths:
        parameters = schema["paths"][path]["post"]["parameters"]
        header = next(item for item in parameters if item["name"] == "Idempotency-Key")
        assert header["required"] is True


@patch("src.shared.database.auth_db.auth.get_user")
def test_missing_idempotency_header_is_rejected_before_authoring(mock_get_user):
    user = MagicMock()
    user.id = "teacher-1"
    user.email = "teacher@example.test"
    user.app_metadata = {"role": "teacher"}
    auth_response = MagicMock()
    auth_response.user = user
    mock_get_user.return_value = auth_response
    response = client.post(
        "/api/v1/teacher/courses/course-1/modules",
        json={"title": "Módulo sem chave"},
        headers={"Authorization": "Bearer valid-test-token"},
    )
    assert response.status_code == 422
    assert any(
        item["loc"] == ["header", "Idempotency-Key"]
        for item in response.json()["detail"]
    )


@patch("src.shared.database.auth_db.auth.get_user")
def test_block_create_route_propagates_idempotency_key(mock_get_user):
    user = MagicMock()
    user.id = "00000000-0000-0000-0000-000000000001"
    user.email = "teacher@example.test"
    user.app_metadata = {"role": "teacher"}
    auth_response = MagicMock()
    auth_response.user = user
    mock_get_user.return_value = auth_response

    repository = AsyncMock()
    repository.get_lesson_by_id.return_value = MagicMock()
    repository.get_instructor_id.return_value = user.id
    repository.create_lesson_block.side_effect = lambda block, **_: block
    app.dependency_overrides[get_course_repository] = lambda: repository
    try:
        response = client.post(
            "/api/v1/teacher/courses/course-1/lessons/lesson-1/blocks",
            json={
                "block_type": "text",
                "content": {"text": "Conteúdo idempotente"},
                "order_index": 0,
            },
            headers={
                "Authorization": "Bearer valid-test-token",
                "Idempotency-Key": "block-attempt-0001",
            },
        )
    finally:
        app.dependency_overrides.pop(get_course_repository, None)

    assert response.status_code == 201
    kwargs = repository.create_lesson_block.await_args.kwargs
    assert kwargs["idempotency_key"] == "block-attempt-0001"
    assert kwargs["actor_id"] == user.id
    assert len(kwargs["request_hash"]) == 64


@patch("src.shared.database.auth_db.auth.get_user")
def test_block_duplicate_route_propagates_idempotency_key(mock_get_user):
    user = MagicMock()
    user.id = "00000000-0000-0000-0000-000000000001"
    user.email = "teacher@example.test"
    user.app_metadata = {"role": "teacher"}
    auth_response = MagicMock()
    auth_response.user = user
    mock_get_user.return_value = auth_response

    source = MagicMock()
    source.block_type = "tip"
    source.content = {"text": "Use régua."}
    source.order_index = 1
    repository = AsyncMock()
    repository.get_lesson_by_id.return_value = MagicMock()
    repository.get_instructor_id.return_value = user.id
    repository.get_lesson_block.return_value = source
    repository.create_lesson_block.side_effect = lambda block, **_: block
    app.dependency_overrides[get_course_repository] = lambda: repository
    try:
        response = client.post(
            "/api/v1/teacher/courses/course-1/lessons/lesson-1/blocks/block-1/duplicate",
            headers={
                "Authorization": "Bearer valid-test-token",
                "Idempotency-Key": "duplicate-attempt-0001",
            },
        )
    finally:
        app.dependency_overrides.pop(get_course_repository, None)

    assert response.status_code == 201
    kwargs = repository.create_lesson_block.await_args.kwargs
    assert kwargs["idempotency_key"] == "duplicate-attempt-0001"
    assert kwargs["actor_id"] == user.id
    assert len(kwargs["request_hash"]) == 64


@pytest.mark.asyncio
async def test_lesson_replay_uses_same_deterministic_resource_id():
    repository = AsyncMock()
    repository.get_module_by_id_and_course_id.return_value = object()
    repository.get_instructor_id.return_value = "teacher-1"
    repository.create_lesson.side_effect = lambda lesson, **_: lesson
    use_case = CreateLessonUseCase(repository)
    payload = {"title": "Aula idempotente", "order_index": 0}

    first = await use_case.execute(
        "course-1", "module-1", payload, "teacher-1", "teacher",
        idempotency_key="lesson-attempt-0001",
    )
    replay = await use_case.execute(
        "course-1", "module-1", payload, "teacher-1", "teacher",
        idempotency_key="lesson-attempt-0001",
    )

    assert first.id == replay.id
    assert repository.create_lesson.await_count == 2
    first_kwargs = repository.create_lesson.await_args_list[0].kwargs
    replay_kwargs = repository.create_lesson.await_args_list[1].kwargs
    assert first_kwargs["request_hash"] == replay_kwargs["request_hash"]


@pytest.mark.asyncio
async def test_publish_passes_stable_request_hash_and_revision():
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-1"
    repository.get_publication_snapshot.return_value = {
        "course": {
            "title": "Curso",
            "summary": "Resumo completo",
            "category": "costura",
            "level": "iniciante",
            "learning_objectives": ["Objetivo"],
            "target_audience": ["Alunos"],
            "cover_status": "ready",
            "monthly_price": 0,
            "modules": [{
                "id": "module-1",
                "title": "Módulo",
                "lessons": [{
                    "id": "lesson-1",
                    "title": "Aula",
                    "lesson_blocks": [{
                        "id": "block-1",
                        "block_type": "text",
                        "content": {"text": "Conteúdo"},
                    }],
                }],
            }],
        },
        "pending_jobs": [],
    }
    use_case = CoursePublicationUseCase(repository)

    await use_case.publish(
        course_id="course-1",
        user_id="teacher-1",
        role="teacher",
        idempotency_key="publish-attempt-0001",
        expected_updated_at="2026-07-24T12:00:00+00:00",
        change_summary="Primeira publicação",
    )

    args = repository.publish_course.await_args.args
    assert args[3] == "publish-attempt-0001"
    assert len(args[4]) == 64
    assert args[5] == "2026-07-24T12:00:00+00:00"
