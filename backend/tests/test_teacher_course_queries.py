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


def test_supabase_course_repository_mapping_with_null_and_missing_values():
    from src.modules.courses.infrastructure.repositories.supabase_course_repository import SupabaseCourseRepository
    from unittest.mock import MagicMock

    repo = SupabaseCourseRepository(MagicMock())

    data = {
        "id": "course-123",
        "instructor_id": "teacher-123",
        "title": "Robust Course Test",
        "slug": "robust-course-test",
        "cover_focal_x": None,
        "cover_focal_y": None,
        "monthly_price": None,
        "promotional_monthly_price": None,
        "certificate_enabled": None,
        "reviews_enabled": None,
        "comments_enabled": None,
        "modules": None,
    }

    course = repo._map_course(data)
    assert course.id == "course-123"
    assert course.summary == ""
    assert course.course_type == "complete"
    assert course.cover_focal_x == 0.5
    assert course.cover_focal_y == 0.5
    assert course.monthly_price == Decimal("0.00")
    assert course.promotional_monthly_price is None
    assert course.certificate_enabled is True
    assert course.reviews_enabled is True
    assert course.comments_enabled is True
    assert course.modules == []
