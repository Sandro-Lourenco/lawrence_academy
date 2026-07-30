from unittest.mock import AsyncMock

import pytest

from src.core.errors.errors import AuthorizationError, ValidationError
from src.modules.courses.application.use_cases.generate_course_media_upload_url_use_case import (
    GenerateCourseMediaUploadUrlUseCase,
)


@pytest.mark.asyncio
async def test_cover_uses_private_image_bucket_and_backend_path():
    courses = AsyncMock()
    courses.get_instructor_id.return_value = "teacher-1"
    storage = AsyncMock()
    storage.generate_media_signed_upload_url.return_value = "signed"
    use_case = GenerateCourseMediaUploadUrlUseCase(courses, storage)

    result = await use_case.execute(
        user_id="teacher-1",
        role="teacher",
        course_id="course-1",
        asset_type="cover",
        filename="capa.webp",
        content_type="image/webp",
        size_bytes=1024,
        alt_text="Molde sobre tecido.",
    )

    assert result["bucket"] == "course-images"
    assert result["path"].startswith("courses/course-1/cover/")
    storage.register_cover_media.assert_awaited_once()


@pytest.mark.asyncio
async def test_trailer_creates_course_job_without_lesson():
    courses = AsyncMock()
    courses.get_instructor_id.return_value = "teacher-1"
    storage = AsyncMock()
    storage.create_trailer_upload_job.return_value = "job-1"
    storage.generate_media_signed_upload_url.return_value = "signed"
    result = await GenerateCourseMediaUploadUrlUseCase(courses, storage).execute(
        user_id="teacher-1",
        role="teacher",
        course_id="course-1",
        asset_type="trailer",
        filename="intro.mp4",
        content_type="video/mp4",
        size_bytes=2048,
    )
    assert result["job_id"] == "job-1"
    storage.create_trailer_upload_job.assert_awaited_once()


@pytest.mark.asyncio
async def test_teacher_cannot_upload_to_another_course():
    courses = AsyncMock()
    courses.get_instructor_id.return_value = "teacher-2"
    with pytest.raises(AuthorizationError):
        await GenerateCourseMediaUploadUrlUseCase(courses, AsyncMock()).execute(
            user_id="teacher-1",
            role="teacher",
            course_id="course-1",
            asset_type="cover",
            filename="capa.jpg",
            content_type="image/jpeg",
            size_bytes=100,
        )


@pytest.mark.asyncio
async def test_rejects_oversized_cover():
    courses = AsyncMock()
    courses.get_instructor_id.return_value = "teacher-1"
    with pytest.raises(ValidationError):
        await GenerateCourseMediaUploadUrlUseCase(courses, AsyncMock()).execute(
            user_id="teacher-1",
            role="teacher",
            course_id="course-1",
            asset_type="cover",
            filename="capa.jpg",
            content_type="image/jpeg",
            size_bytes=11 * 1024 * 1024,
        )
