import asyncio

import pytest

from src.core.errors.errors import AuthorizationError, NotFoundError
from src.modules.courses.application.use_cases.delete_lesson_use_case import (
    DeleteLessonUseCase,
)
from src.modules.courses.application.use_cases.update_lesson_use_case import (
    UpdateLessonUseCase,
)
from src.modules.courses.domain.entities import Lesson, Module


class LessonRepositoryFake:
    def __init__(self) -> None:
        self.instructor_id = "teacher-owner"
        self.lesson = Lesson(
            id="lesson-1",
            module_id="module-1",
            course_id="course-1",
            title="Aula 01",
            description="Introdução",
            hls_storage_path=None,
        )
        self.updated_data: dict | None = None
        self.deleted_id: str | None = None

    async def get_lesson_by_id(self, course_id: str, lesson_id: str):
        if course_id == "course-1" and lesson_id == "lesson-1":
            return self.lesson
        return None

    async def get_instructor_id(self, course_id: str):
        return self.instructor_id if course_id == "course-1" else None

    async def get_module_by_id_and_course_id(self, module_id: str, course_id: str):
        if module_id == "module-2" and course_id == "course-1":
            return Module(id=module_id, course_id=course_id, title="Módulo 2")
        return None

    async def update_lesson(self, lesson_id: str, lesson_data: dict):
        self.updated_data = lesson_data
        return Lesson(
            id=lesson_id,
            module_id=lesson_data.get("module_id", self.lesson.module_id),
            course_id=self.lesson.course_id,
            title=lesson_data.get("title", self.lesson.title),
            description=lesson_data.get("description", self.lesson.description),
            order_index=lesson_data.get("order_index", self.lesson.order_index),
            status=lesson_data.get("status", self.lesson.status),
            hls_storage_path=self.lesson.hls_storage_path,
        )

    async def delete_lesson(self, lesson_id: str):
        self.deleted_id = lesson_id
        return True


def test_teacher_moves_only_selected_lesson_to_valid_course_module():
    repository = LessonRepositoryFake()
    result = asyncio.run(
        UpdateLessonUseCase(repository).execute(
            course_id="course-1",
            lesson_id="lesson-1",
            lesson_data={
                "title": "Aula 01 atualizada",
                "order_index": 2,
                "module_id": "module-2",
            },
            current_user_id="teacher-owner",
            current_user_role="teacher",
        )
    )

    assert result.title == "Aula 01 atualizada"
    assert result.module_id == "module-2"
    assert repository.updated_data == {
        "title": "Aula 01 atualizada",
        "order_index": 2,
        "module_id": "module-2",
    }


def test_non_owner_cannot_update_lesson():
    repository = LessonRepositoryFake()
    with pytest.raises(AuthorizationError):
        asyncio.run(
            UpdateLessonUseCase(repository).execute(
                course_id="course-1",
                lesson_id="lesson-1",
                lesson_data={"title": "Acesso indevido"},
                current_user_id="other-teacher",
                current_user_role="teacher",
            )
        )


def test_teacher_archives_lesson_without_deleting_module():
    repository = LessonRepositoryFake()
    result = asyncio.run(
        DeleteLessonUseCase(repository).execute(
            course_id="course-1",
            lesson_id="lesson-1",
            current_user_id="teacher-owner",
            current_user_role="teacher",
        )
    )

    assert result is True
    assert repository.deleted_id == "lesson-1"


def test_missing_lesson_is_not_found():
    repository = LessonRepositoryFake()
    with pytest.raises(NotFoundError):
        asyncio.run(
            DeleteLessonUseCase(repository).execute(
                course_id="course-1",
                lesson_id="missing",
                current_user_id="teacher-owner",
                current_user_role="teacher",
            )
        )
