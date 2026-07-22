from decimal import Decimal
from unittest.mock import AsyncMock

import pytest

from src.core.errors.errors import AuthorizationError
from src.modules.courses.application.use_cases.get_teacher_course_use_case import (
    GetTeacherCourseUseCase,
)
from src.modules.courses.application.use_cases.list_teacher_courses_use_case import (
    ListTeacherCoursesUseCase,
)
from src.modules.courses.domain.entities import Course


def _course(instructor_id: str = "teacher-1") -> Course:
    return Course(
        id="course-1",
        instructor_id=instructor_id,
        title="Curso de teste",
        slug="curso-de-teste",
        summary="Resumo do curso",
        monthly_price=Decimal("0"),
    )


@pytest.mark.asyncio
async def test_teacher_lists_only_owned_courses():
    repository = AsyncMock()
    repository.list_by_instructor.return_value = [_course()]

    result = await ListTeacherCoursesUseCase(repository).execute(
        user_id="teacher-1",
        role="teacher",
    )

    assert result == [_course()]
    repository.list_by_instructor.assert_awaited_once_with("teacher-1")
    repository.list_all.assert_not_awaited()


@pytest.mark.asyncio
async def test_teacher_cannot_read_another_teachers_course():
    repository = AsyncMock()
    repository.get_by_id.return_value = _course(instructor_id="teacher-2")

    with pytest.raises(AuthorizationError):
        await GetTeacherCourseUseCase(repository).execute(
            course_id="course-1",
            user_id="teacher-1",
            role="teacher",
        )


@pytest.mark.asyncio
async def test_super_admin_can_read_any_teacher_course():
    course = _course(instructor_id="teacher-2")
    repository = AsyncMock()
    repository.get_by_id.return_value = course

    result = await GetTeacherCourseUseCase(repository).execute(
        course_id="course-1",
        user_id="admin-1",
        role="super_admin",
    )

    assert result == course
