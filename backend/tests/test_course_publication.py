from unittest.mock import AsyncMock

import pytest

from src.core.errors.errors import ConflictError
from src.modules.courses.application.use_cases.publish_course_use_case import (
    CoursePublicationUseCase,
)


def ready_snapshot():
    return {
        "course": {
            "title": "Modelagem completa",
            "summary": "Aprenda modelagem do zero.",
            "category": "modelagem",
            "level": "iniciante",
            "learning_objectives": ["Criar moldes"],
            "target_audience": ["Iniciantes"],
            "cover_status": "ready",
            "monthly_price": "0.00",
            "availability": "immediate",
            "description": "Curso completo.",
            "trailer_hls_path": "trailers/master.m3u8",
            "modules": [
                {
                    "id": "module-1",
                    "title": "Introdução",
                    "deleted_at": None,
                    "lessons": [
                        {
                            "id": "lesson-1",
                            "title": "Boas-vindas",
                            "deleted_at": None,
                            "lesson_blocks": [
                                {
                                    "id": "block-1",
                                    "block_type": "text",
                                    "content": {"text": "Olá"},
                                    "deleted_at": None,
                                }
                            ],
                        }
                    ],
                }
            ],
        },
        "pending_jobs": [],
        "failed_jobs": [],
    }


@pytest.mark.asyncio
async def test_ready_course_can_publish():
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-1"
    repository.get_publication_snapshot.return_value = ready_snapshot()
    repository.publish_course.return_value = "published"
    result = await CoursePublicationUseCase(repository).publish(
        course_id="course-1", user_id="teacher-1", role="teacher"
    )
    assert result == "published"
    repository.publish_course.assert_awaited_once_with("course-1", "teacher-1")


@pytest.mark.asyncio
async def test_checklist_exposes_real_block_structure_for_teacher_preview():
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-1"
    repository.get_publication_snapshot.return_value = ready_snapshot()

    checklist = await CoursePublicationUseCase(repository).checklist(
        course_id="course-1", user_id="teacher-1", role="teacher"
    )

    block = checklist["structure"][0]["lessons"][0]["blocks"][0]
    assert block["block_type"] == "text"
    assert block["content"] == {"text": "Olá"}


@pytest.mark.asyncio
async def test_course_with_empty_lesson_is_blocked():
    snapshot = ready_snapshot()
    snapshot["course"]["modules"][0]["lessons"][0]["lesson_blocks"] = []
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-1"
    repository.get_publication_snapshot.return_value = snapshot
    checklist = await CoursePublicationUseCase(repository).checklist(
        course_id="course-1", user_id="teacher-1", role="teacher"
    )
    assert checklist["ready"] is False
    with pytest.raises(ConflictError):
        await CoursePublicationUseCase(repository).publish(
            course_id="course-1", user_id="teacher-1", role="teacher"
        )


@pytest.mark.asyncio
async def test_image_without_alt_text_blocks_publication():
    snapshot = ready_snapshot()
    snapshot["course"]["modules"][0]["lessons"][0]["lesson_blocks"][0] = {
        "id": "image-1",
        "block_type": "image",
        "content": {"storage_path": "path"},
        "deleted_at": None,
    }
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-1"
    repository.get_publication_snapshot.return_value = snapshot
    checklist = await CoursePublicationUseCase(repository).checklist(
        course_id="course-1", user_id="teacher-1", role="teacher"
    )
    assert any(item["code"] == "alt:image-1" for item in checklist["issues"])


@pytest.mark.asyncio
async def test_scheduled_publication_is_explicitly_blocked_without_scheduler():
    snapshot = ready_snapshot()
    snapshot["course"]["availability"] = "scheduled"
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-1"
    repository.get_publication_snapshot.return_value = snapshot
    checklist = await CoursePublicationUseCase(repository).checklist(
        course_id="course-1", user_id="teacher-1", role="teacher"
    )
    assert any(item["code"] == "scheduling" for item in checklist["issues"])


@pytest.mark.asyncio
async def test_current_failed_video_job_blocks_publication_with_actionable_issue():
    snapshot = ready_snapshot()
    snapshot["failed_jobs"] = [
        {"id": "job-1", "lesson_id": "lesson-1", "status": "dead_letter"}
    ]
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-1"
    repository.get_publication_snapshot.return_value = snapshot

    checklist = await CoursePublicationUseCase(repository).checklist(
        course_id="course-1", user_id="teacher-1", role="teacher"
    )

    assert checklist["ready"] is False
    assert checklist["failed_uploads"] == 1
    assert any(item["code"] == "failed_uploads" for item in checklist["issues"])


@pytest.mark.asyncio
async def test_required_lesson_without_hls_blocks_even_when_job_is_missing():
    snapshot = ready_snapshot()
    lesson = snapshot["course"]["modules"][0]["lessons"][0]
    lesson["is_required"] = True
    lesson["hls_storage_path"] = None
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-1"
    repository.get_publication_snapshot.return_value = snapshot

    checklist = await CoursePublicationUseCase(repository).checklist(
        course_id="course-1", user_id="teacher-1", role="teacher"
    )

    assert checklist["ready"] is False
    assert any(
        item["code"] == "required-video:lesson-1" for item in checklist["issues"]
    )


@pytest.mark.asyncio
async def test_active_current_video_job_blocks_publication():
    snapshot = ready_snapshot()
    snapshot["pending_jobs"] = [
        {"id": "job-1", "lesson_id": "lesson-1", "status": "transcoding"}
    ]
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-1"
    repository.get_publication_snapshot.return_value = snapshot

    checklist = await CoursePublicationUseCase(repository).checklist(
        course_id="course-1", user_id="teacher-1", role="teacher"
    )

    assert checklist["ready"] is False
    assert checklist["pending_uploads"] == 1
    assert any(item["code"] == "uploads" for item in checklist["issues"])
