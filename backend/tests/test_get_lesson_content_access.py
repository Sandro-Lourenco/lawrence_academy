from decimal import Decimal
from types import SimpleNamespace
from unittest.mock import AsyncMock

import pytest

from src.core.errors.errors import AuthorizationError
from src.modules.courses.application.use_cases.get_lesson_use_case import GetLessonUseCase


@pytest.mark.asyncio
async def test_paid_lesson_blocks_require_active_subscription():
    repository = AsyncMock()
    repository.get_published_by_id.return_value = SimpleNamespace(
        status="published", monthly_price=Decimal("59.90")
    )
    repository.has_active_subscription.return_value = False

    with pytest.raises(AuthorizationError):
        await GetLessonUseCase(repository).execute("student-1", "student", "course-1", "lesson-1")

    repository.get_lesson_by_id.assert_not_awaited()


@pytest.mark.asyncio
async def test_teacher_can_only_preview_own_lesson_content():
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "another-teacher"

    with pytest.raises(AuthorizationError):
        await GetLessonUseCase(repository).execute("teacher-1", "teacher", "course-1", "lesson-1")

    repository.get_lesson_by_id.assert_not_awaited()
