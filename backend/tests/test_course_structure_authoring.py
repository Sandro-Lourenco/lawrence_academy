from unittest.mock import AsyncMock

import pytest

from src.modules.courses.application.use_cases.create_lesson_use_case import CreateLessonUseCase
from src.modules.courses.application.use_cases.create_module_use_case import CreateModuleUseCase
from src.modules.courses.application.use_cases.update_lesson_use_case import UpdateLessonUseCase
from src.core.errors.errors import NotFoundError
from src.modules.courses.domain.entities import Lesson, Module


@pytest.mark.asyncio
async def test_create_module_keeps_pedagogical_metadata():
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher-1"
    repository.create_module.side_effect = lambda module: module
    module = await CreateModuleUseCase(repository).execute(
        "course-1",
        {
            "title": "Medidas",
            "description": "Como medir o corpo.",
            "status": "ready",
            "order_index": 2,
        },
        "teacher-1",
        "teacher",
    )
    assert module.description == "Como medir o corpo."
    assert module.status == "ready"


@pytest.mark.asyncio
async def test_create_lesson_keeps_estimate_and_requirement():
    repository = AsyncMock()
    repository.get_module_by_id_and_course_id.return_value = Module(
        "module-1", "course-1", "Medidas"
    )
    repository.get_instructor_id.return_value = "teacher-1"
    repository.create_lesson.side_effect = lambda lesson: lesson
    lesson = await CreateLessonUseCase(repository).execute(
        "course-1",
        "module-1",
        {"title": "Tirar medidas", "estimated_duration_minutes": 20, "is_required": False},
        "teacher-1",
        "teacher",
    )
    assert lesson.estimated_duration_minutes == 20
    assert lesson.is_required is False


@pytest.mark.asyncio
async def test_update_lesson_allows_structure_fields_only():
    repository = AsyncMock()
    repository.get_lesson_by_id.return_value = Lesson(
        id="lesson-1",
        module_id="module-1",
        course_id="course-1",
        title="Tirar medidas",
        hls_storage_path=None,
    )
    repository.get_instructor_id.return_value = "teacher-1"
    repository.update_lesson.return_value = repository.get_lesson_by_id.return_value
    await UpdateLessonUseCase(repository).execute(
        "course-1",
        "lesson-1",
        {"estimated_duration_minutes": 25, "is_required": True, "course_id": "attacker-course"},
        "teacher-1",
        "teacher",
    )
    changes = repository.update_lesson.await_args.args[1]
    assert changes == {"estimated_duration_minutes": 25, "is_required": True}


@pytest.mark.asyncio
async def test_move_lesson_rejects_module_from_another_course():
    repository = AsyncMock()
    repository.get_lesson_by_id.return_value = Lesson(
        id="lesson-1",
        module_id="module-1",
        course_id="course-1",
        title="Tirar medidas",
        hls_storage_path=None,
    )
    repository.get_instructor_id.return_value = "teacher-1"
    repository.get_module_by_id_and_course_id.return_value = None
    with pytest.raises(NotFoundError):
        await UpdateLessonUseCase(repository).execute(
            "course-1",
            "lesson-1",
            {"module_id": "foreign-module"},
            "teacher-1",
            "teacher",
        )
