from unittest.mock import AsyncMock

import pytest

from src.core.errors.errors import AuthorizationError, ValidationError
from src.modules.courses.application.use_cases.generate_lesson_asset_upload_url_use_case import (
    GenerateLessonAssetUploadUrlUseCase,
)
from src.modules.courses.domain.entities import Lesson


def lesson():
    return Lesson(
        id="lesson-1",
        module_id="module-1",
        course_id="course-1",
        title="Molde",
        hls_storage_path=None,
    )


@pytest.mark.asyncio
async def test_asset_upload_uses_private_bucket_and_backend_path():
    courses = AsyncMock()
    courses.get_lesson_by_id.return_value = lesson()
    courses.get_instructor_id.return_value = "teacher-1"
    storage = AsyncMock()
    storage.generate_media_signed_upload_url.return_value = "signed"
    result = await GenerateLessonAssetUploadUrlUseCase(courses, storage).execute(
        course_id="course-1",
        lesson_id="lesson-1",
        user_id="teacher-1",
        role="teacher",
        filename="molde.pdf",
        content_type="application/pdf",
        size_bytes=1024,
    )
    assert result["bucket"] == "lesson-assets"
    assert result["path"].startswith("courses/course-1/lessons/lesson-1/")


@pytest.mark.asyncio
async def test_asset_upload_rejects_non_owner():
    courses = AsyncMock()
    courses.get_lesson_by_id.return_value = lesson()
    courses.get_instructor_id.return_value = "teacher-2"
    with pytest.raises(AuthorizationError):
        await GenerateLessonAssetUploadUrlUseCase(courses, AsyncMock()).execute(
            course_id="course-1",
            lesson_id="lesson-1",
            user_id="teacher-1",
            role="teacher",
            filename="molde.pdf",
            content_type="application/pdf",
            size_bytes=10,
        )


@pytest.mark.asyncio
async def test_asset_upload_rejects_executable():
    courses = AsyncMock()
    courses.get_lesson_by_id.return_value = lesson()
    courses.get_instructor_id.return_value = "teacher-1"
    with pytest.raises(ValidationError):
        await GenerateLessonAssetUploadUrlUseCase(courses, AsyncMock()).execute(
            course_id="course-1",
            lesson_id="lesson-1",
            user_id="teacher-1",
            role="teacher",
            filename="virus.exe",
            content_type="application/x-msdownload",
            size_bytes=10,
        )
