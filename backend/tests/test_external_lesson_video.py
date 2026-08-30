from decimal import Decimal
from types import SimpleNamespace
from unittest.mock import AsyncMock

import pytest

from src.core.errors.errors import ValidationError
from src.modules.courses.application.use_cases.create_lesson_use_case import (
    CreateLessonUseCase,
)
from src.modules.courses.application.use_cases.get_lesson_stream_use_case import (
    GetLessonStreamUseCase,
)
from src.modules.courses.application.use_cases.update_lesson_use_case import (
    UpdateLessonUseCase,
)
from src.modules.courses.domain.entities import Lesson, Module
from src.modules.courses.domain.external_video import parse_external_video_url


@pytest.mark.parametrize(
    ("url", "provider", "video_id"),
    [
        ("https://youtu.be/dQw4w9WgXcQ", "youtube", "dQw4w9WgXcQ"),
        ("https://www.youtube.com/watch?v=dQw4w9WgXcQ", "youtube", "dQw4w9WgXcQ"),
        ("https://vimeo.com/123456789", "vimeo", "123456789"),
    ],
)
def test_external_video_url_is_normalized(url, provider, video_id):
    result = parse_external_video_url(url)
    assert result.provider == provider
    assert result.video_id == video_id


@pytest.mark.parametrize(
    "url",
    [
        "http://youtu.be/dQw4w9WgXcQ",
        "https://youtube.example/watch?v=dQw4w9WgXcQ",
        "https://user:pass@youtube.com/watch?v=dQw4w9WgXcQ",
        "https://vimeo.com/not-a-number",
    ],
)
def test_external_video_url_rejects_untrusted_or_invalid_hosts(url):
    with pytest.raises(ValidationError):
        parse_external_video_url(url)


@pytest.mark.asyncio
async def test_teacher_creates_external_video_lesson_with_normalized_id():
    repository = AsyncMock()
    repository.get_module_by_id_and_course_id.return_value = Module(
        id="module-1", course_id="course-1", title="Introdução"
    )
    repository.get_instructor_id.return_value = "teacher-1"
    repository.create_lesson.side_effect = lambda lesson: lesson

    lesson = await CreateLessonUseCase(repository).execute(
        "course-1",
        "module-1",
        {
            "title": "Aula por link",
            "video_url": "https://youtu.be/dQw4w9WgXcQ",
            "estimated_duration_minutes": 12,
        },
        "teacher-1",
        "teacher",
    )

    assert lesson.video_source_type == "youtube"
    assert lesson.external_video_id == "dQw4w9WgXcQ"
    assert lesson.duration_seconds == 720


@pytest.mark.asyncio
async def test_external_video_requires_estimated_duration():
    repository = AsyncMock()
    repository.get_module_by_id_and_course_id.return_value = Module(
        id="module-1", course_id="course-1", title="Introdução"
    )
    repository.get_instructor_id.return_value = "teacher-1"

    with pytest.raises(ValidationError, match="duração estimada"):
        await CreateLessonUseCase(repository).execute(
            "course-1",
            "module-1",
            {"title": "Aula por link", "video_url": "https://vimeo.com/123456789"},
            "teacher-1",
            "teacher",
        )


@pytest.mark.asyncio
async def test_updating_external_video_clears_private_upload_candidate():
    repository = AsyncMock()
    repository.get_lesson_by_id.return_value = Lesson(
        id="lesson-1",
        module_id="module-1",
        course_id="course-1",
        title="Aula",
        hls_storage_path="old/master.m3u8",
        estimated_duration_minutes=10,
    )
    repository.get_instructor_id.return_value = "teacher-1"
    repository.update_lesson.return_value = repository.get_lesson_by_id.return_value

    await UpdateLessonUseCase(repository).execute(
        "course-1",
        "lesson-1",
        {"video_url": "https://vimeo.com/123456789"},
        "teacher-1",
        "teacher",
    )

    changes = repository.update_lesson.await_args.args[1]
    assert changes["video_source_type"] == "vimeo"
    assert changes["external_video_id"] == "123456789"
    assert changes["hls_storage_path"] is None
    assert changes["pending_upload_job_id"] is None


@pytest.mark.asyncio
async def test_external_playback_url_is_returned_only_after_student_access_check():
    repository = AsyncMock()
    repository.get_published_by_id.return_value = SimpleNamespace(
        monthly_price=Decimal("49.90")
    )
    repository.has_active_subscription.return_value = True
    repository.get_published_lesson.return_value = Lesson(
        id="lesson-1",
        module_id="module-1",
        course_id="course-1",
        title="Aula",
        hls_storage_path=None,
        video_source_type="youtube",
        external_video_id="dQw4w9WgXcQ",
    )

    result = await GetLessonStreamUseCase(repository).authorize_and_get_source(
        "student-1", "student", "course-1", "lesson-1"
    )

    assert result.source_type == "external"
    assert result.external_url == "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    repository.has_active_subscription.assert_awaited_once_with("student-1", "course-1")
