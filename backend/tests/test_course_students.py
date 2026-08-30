from unittest.mock import AsyncMock

import pytest

from src.core.errors.errors import AuthorizationError, NotFoundError
from src.modules.courses.application.use_cases.list_course_students_use_case import (
    ListCourseStudentsUseCase,
)
from src.modules.courses.domain.entities import CourseStudent


@pytest.mark.asyncio
async def test_teacher_lists_students_only_for_owned_course() -> None:
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-1"
    expected = [
        CourseStudent(
            id="student-1",
            full_name="Ana",
            email="ana@example.test",
            access_status="active",
            progress_percentage=50,
            completed_lessons=1,
            total_lessons=2,
        )
    ]
    repository.list_course_students.return_value = expected

    result = await ListCourseStudentsUseCase(repository).execute(
        course_id="course-1", user_id="teacher-1", role="teacher"
    )

    assert result == expected
    repository.list_course_students.assert_awaited_once_with("course-1")


@pytest.mark.asyncio
async def test_teacher_cannot_list_another_teachers_students() -> None:
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-2"

    with pytest.raises(AuthorizationError):
        await ListCourseStudentsUseCase(repository).execute(
            course_id="course-1", user_id="teacher-1", role="teacher"
        )
    repository.list_course_students.assert_not_awaited()


@pytest.mark.asyncio
async def test_missing_course_does_not_leak_student_data() -> None:
    repository = AsyncMock()
    repository.get_instructor_id.return_value = None

    with pytest.raises(NotFoundError):
        await ListCourseStudentsUseCase(repository).execute(
            course_id="missing", user_id="teacher-1", role="teacher"
        )
