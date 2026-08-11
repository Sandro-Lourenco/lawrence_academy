from decimal import Decimal
from types import SimpleNamespace
from unittest.mock import AsyncMock, MagicMock

import pytest

from src.modules.courses.application.use_cases.get_course_use_case import GetCourseUseCase
from src.modules.courses.application.use_cases.get_lesson_stream_use_case import (
    GetLessonStreamUseCase,
)
from src.modules.courses.application.use_cases.get_lesson_use_case import GetLessonUseCase
from src.modules.courses.application.use_cases.list_course_versions_use_case import (
    ListCourseVersionsUseCase,
)
from src.modules.courses.infrastructure.repositories.supabase_course_repository import (
    SupabaseCourseRepository,
)


@pytest.mark.asyncio
async def test_public_course_reads_immutable_current_version():
    repository = AsyncMock()
    repository.get_published_by_id.return_value = "published-version"
    repository.get_by_id.return_value = "authoring-draft"

    result = await GetCourseUseCase(repository).execute("course-1")

    assert result == "published-version"
    repository.get_by_id.assert_not_awaited()


@pytest.mark.asyncio
async def test_legacy_published_course_without_snapshot_uses_live_record():
    client = MagicMock()
    version_response = MagicMock(data=None)
    client.table.return_value.select.return_value.eq.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        version_response
    )
    repository = SupabaseCourseRepository(client)
    legacy_course = SimpleNamespace(status="published")
    repository.get_by_id = AsyncMock(return_value=legacy_course)  # type: ignore[method-assign]

    result = await repository.get_published_by_id("legacy-course")

    assert result is legacy_course
    repository.get_by_id.assert_awaited_once_with("legacy-course")  # type: ignore[attr-defined]


@pytest.mark.asyncio
async def test_draft_course_without_snapshot_stays_private():
    client = MagicMock()
    version_response = MagicMock(data=None)
    client.table.return_value.select.return_value.eq.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        version_response
    )
    repository = SupabaseCourseRepository(client)
    repository.get_by_id = AsyncMock(  # type: ignore[method-assign]
        return_value=SimpleNamespace(status="draft")
    )

    assert await repository.get_published_by_id("draft-course") is None


@pytest.mark.asyncio
async def test_student_lesson_reads_version_while_teacher_reads_authoring_source():
    repository = AsyncMock()
    repository.get_published_by_id.return_value = SimpleNamespace(monthly_price=Decimal("0"))
    repository.get_published_lesson.return_value = "published-lesson"
    repository.get_instructor_id.return_value = "teacher-1"
    repository.get_lesson_by_id.return_value = "draft-lesson"

    student = await GetLessonUseCase(repository).execute(
        "student-1", "student", "course-1", "lesson-1"
    )
    teacher = await GetLessonUseCase(repository).execute(
        "teacher-1", "teacher", "course-1", "lesson-1"
    )

    assert student == "published-lesson"
    assert teacher == "draft-lesson"


@pytest.mark.asyncio
async def test_student_stream_uses_versioned_hls_path():
    repository = AsyncMock()
    repository.get_published_by_id.return_value = SimpleNamespace(monthly_price=Decimal("0"))
    repository.get_published_lesson_stream_path.return_value = "v1/master.m3u8"
    repository.generate_signed_url.return_value = "https://signed.example/v1"

    result = await GetLessonStreamUseCase(repository).execute(
        "student-1", "student", "course-1", "lesson-1"
    )

    assert result == "https://signed.example/v1"
    repository.get_lesson_stream_path.assert_not_awaited()


@pytest.mark.asyncio
async def test_owner_can_list_version_metadata_without_snapshot_payload():
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-1"
    repository.list_course_versions.return_value = [{"version_number": 2, "is_current": True}]

    result = await ListCourseVersionsUseCase(repository).execute(
        course_id="course-1", user_id="teacher-1", role="teacher"
    )

    assert result[0]["version_number"] == 2
