from unittest.mock import AsyncMock

import pytest

from src.core.errors.errors import AuthorizationError, NotFoundError, ValidationError
from src.modules.courses.application.use_cases.manage_lesson_block_use_case import (
    ManageLessonBlockUseCase,
)
from src.modules.courses.domain.entities import Lesson, LessonBlock
from src.modules.courses.interface.api.teacher_routes import BlockContentSchema
from pydantic import ValidationError as PydanticValidationError


def lesson():
    return Lesson(
        id="lesson-1",
        module_id="module-1",
        course_id="course-1",
        title="Introdução",
        hls_storage_path=None,
    )


@pytest.mark.asyncio
async def test_teacher_creates_structured_block_in_own_lesson():
    repo = AsyncMock()
    repo.get_lesson_by_id.return_value = lesson()
    repo.get_instructor_id.return_value = "teacher-1"
    repo.create_lesson_block.side_effect = lambda block: block
    block = await ManageLessonBlockUseCase(repo).create(
        course_id="course-1",
        lesson_id="lesson-1",
        user_id="teacher-1",
        role="teacher",
        data={
            "block_type": "learn_more",
            "content": {"title": "Tabela de medidas", "text": "Compare as medidas."},
            "order_index": 2,
        },
    )
    assert block.block_type == "learn_more"
    assert block.content["title"] == "Tabela de medidas"


@pytest.mark.asyncio
async def test_teacher_cannot_edit_blocks_from_another_course():
    repo = AsyncMock()
    repo.get_lesson_by_id.return_value = lesson()
    repo.get_instructor_id.return_value = "teacher-2"
    with pytest.raises(AuthorizationError):
        await ManageLessonBlockUseCase(repo).create(
            course_id="course-1",
            lesson_id="lesson-1",
            user_id="teacher-1",
            role="teacher",
            data={"block_type": "text", "content": {}},
        )


@pytest.mark.asyncio
async def test_update_requires_block_inside_same_lesson():
    repo = AsyncMock()
    repo.get_lesson_by_id.return_value = lesson()
    repo.get_instructor_id.return_value = "teacher-1"
    repo.get_lesson_block.return_value = None
    with pytest.raises(NotFoundError):
        await ManageLessonBlockUseCase(repo).update(
            course_id="course-1",
            lesson_id="lesson-1",
            block_id="foreign",
            user_id="teacher-1",
            role="teacher",
            data={"order_index": 1},
        )


@pytest.mark.asyncio
async def test_duplicate_creates_draft_copy():
    repo = AsyncMock()
    repo.get_lesson_by_id.return_value = lesson()
    repo.get_instructor_id.return_value = "teacher-1"
    repo.get_lesson_block.return_value = LessonBlock(
        id="block-1",
        lesson_id="lesson-1",
        course_id="course-1",
        block_type="tip",
        content={"text": "Use régua."},
        order_index=1,
        status="ready",
    )
    repo.create_lesson_block.side_effect = lambda block: block
    copy = await ManageLessonBlockUseCase(repo).duplicate(
        course_id="course-1",
        lesson_id="lesson-1",
        block_id="block-1",
        user_id="teacher-1",
        role="teacher",
    )
    assert copy.order_index == 2
    assert copy.status == "draft"


def test_block_content_rejects_insecure_external_url():
    with pytest.raises(PydanticValidationError):
        BlockContentSchema(url="http://example.com/file.pdf")


def test_block_rejects_storage_path_from_another_lesson():
    with pytest.raises(ValidationError):
        ManageLessonBlockUseCase._validate_storage_path(
            "course-1", "lesson-1", {"storage_path": "courses/course-2/lessons/lesson-9/file.pdf"}
        )


@pytest.mark.asyncio
async def test_reorder_is_one_repository_operation_with_optimistic_revision():
    repo = AsyncMock()
    repo.get_lesson_by_id.return_value = lesson()
    repo.get_instructor_id.return_value = "teacher-1"
    repo.reorder_lesson_blocks.return_value = 9
    result = await ManageLessonBlockUseCase(repo).reorder(
        course_id="course-1",
        lesson_id="lesson-1",
        block_ids=["block-2", "block-1"],
        expected_revision=7,
        user_id="teacher-1",
        role="teacher",
    )
    repo.reorder_lesson_blocks.assert_awaited_once_with(
        "course-1", "lesson-1", "teacher-1", ["block-2", "block-1"], 7
    )
    assert result == {"authoring_revision": 9}


@pytest.mark.asyncio
async def test_reorder_rejects_duplicate_ids_before_repository():
    repo = AsyncMock()
    repo.get_lesson_by_id.return_value = lesson()
    repo.get_instructor_id.return_value = "teacher-1"
    with pytest.raises(ValidationError):
        await ManageLessonBlockUseCase(repo).reorder(
            course_id="course-1",
            lesson_id="lesson-1",
            block_ids=["block-1", "block-1"],
            expected_revision=7,
            user_id="teacher-1",
            role="teacher",
        )
    repo.reorder_lesson_blocks.assert_not_awaited()
