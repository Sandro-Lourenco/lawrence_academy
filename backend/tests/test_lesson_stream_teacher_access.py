from unittest.mock import AsyncMock

import pytest

from src.core.errors.errors import AuthorizationError
from src.modules.courses.application.use_cases.get_lesson_stream_use_case import (
    GetLessonStreamUseCase,
)


@pytest.mark.asyncio
async def test_teacher_cannot_stream_another_teachers_lesson():
    repository = AsyncMock()
    repository.get_lesson_stream_path.return_value = "course/lesson/master.m3u8"
    repository.get_instructor_id.return_value = "another-teacher"

    with pytest.raises(AuthorizationError):
        await GetLessonStreamUseCase(repository).execute(
            "teacher-1", "teacher", "course-1", "lesson-1"
        )

    repository.generate_signed_url.assert_not_awaited()
