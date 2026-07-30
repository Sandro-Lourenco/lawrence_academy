from unittest.mock import AsyncMock

import pytest

from src.core.errors.errors import AuthorizationError, ValidationError
from src.modules.courses.application.use_cases.manage_course_lifecycle_use_case import (
    ManageCourseLifecycleUseCase,
)


@pytest.mark.asyncio
async def test_owner_can_unpublish_course_with_auditable_reason():
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-1"
    repository.transition_course_status.return_value = "unpublished"

    result = await ManageCourseLifecycleUseCase(repository).execute(
        course_id="course-1",
        user_id="teacher-1",
        role="teacher",
        target_status="unpublished",
        reason="  Atualização do módulo final  ",
    )

    assert result == {"course_id": "course-1", "status": "unpublished"}
    repository.transition_course_status.assert_awaited_once_with(
        "course-1",
        "teacher-1",
        "unpublished",
        "Atualização do módulo final",
    )


@pytest.mark.asyncio
async def test_teacher_cannot_transition_another_teachers_course():
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-2"

    with pytest.raises(AuthorizationError):
        await ManageCourseLifecycleUseCase(repository).execute(
            course_id="course-1",
            user_id="teacher-1",
            role="teacher",
            target_status="archived",
        )

    repository.transition_course_status.assert_not_awaited()


@pytest.mark.asyncio
async def test_arbitrary_status_is_rejected_before_repository_write():
    repository = AsyncMock()

    with pytest.raises(ValidationError):
        await ManageCourseLifecycleUseCase(repository).execute(
            course_id="course-1",
            user_id="teacher-1",
            role="teacher",
            target_status="published",
        )

    repository.get_instructor_id.assert_not_awaited()
