from unittest.mock import AsyncMock, MagicMock

import pytest

from src.modules.courses.application.use_cases.update_course_use_case import (
    UpdateCourseUseCase,
)
from src.modules.courses.domain.entities import Course
from src.core.errors.errors import ConflictError
from src.modules.courses.infrastructure.repositories.supabase_course_repository import (
    SupabaseCourseRepository,
)
from src.modules.courses.interface.api.teacher_routes import CourseUpdateInputSchema


def test_autosave_requires_expected_authoring_revision():
    schema = CourseUpdateInputSchema.model_json_schema()
    assert "expected_authoring_revision" in schema["required"]


@pytest.mark.asyncio
async def test_autosave_propagates_expected_revision_to_atomic_repository_update():
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-1"
    repository.get_by_id.return_value = Course(
        id="course-1",
        instructor_id="teacher-1",
        title="Curso",
        slug="curso",
        summary="Resumo",
        authoring_revision=4,
    )
    repository.update.side_effect = lambda _id, course, _revision: course

    result = await UpdateCourseUseCase(repository).execute(
        course_id="course-1",
        course_data={"title": "Curso atualizado"},
        current_user_id="teacher-1",
        current_user_role="teacher",
        expected_authoring_revision=4,
    )

    args = repository.update.await_args.args
    assert args[2] == 4
    assert result.title == "Curso atualizado"


@pytest.mark.asyncio
async def test_stale_repository_update_raises_conflict():
    client = MagicMock()
    builder = client.table.return_value.update.return_value
    builder.eq.return_value = builder
    builder.execute.return_value.data = []
    repository = SupabaseCourseRepository(client)
    course = Course(
        id="course-1",
        instructor_id="teacher-1",
        title="Curso",
        slug="curso",
        summary="Resumo",
        authoring_revision=5,
    )

    with pytest.raises(ConflictError):
        await repository.update("course-1", course, expected_authoring_revision=4)
