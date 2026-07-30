from types import SimpleNamespace
from unittest.mock import AsyncMock

import pytest

from src.core.errors.errors import AuthorizationError, ConflictError, NotFoundError
from src.modules.courses.application.use_cases.manage_course_version_use_case import (
    ManageCourseVersionUseCase,
)


@pytest.mark.asyncio
async def test_version_detail_compares_snapshot_with_current_authoring():
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher"
    repository.get_course_version.return_value = {
        "id": "version",
        "snapshot": {
            "title": "Título publicado",
            "modules": [{"lessons": [{"lesson_blocks": [{}, {}]}]}],
        },
    }
    repository.get_by_id.return_value = SimpleNamespace(updated_at="2026-07-23T12:00:00Z")
    repository.get_publication_snapshot.return_value = {
        "course": {"title": "Título em edição", "modules": []}
    }

    result = await ManageCourseVersionUseCase(repository).detail(
        course_id="course", version_id="version", user_id="teacher", role="teacher"
    )

    assert result["comparison"]["changed_fields"] == ["title"]
    assert result["comparison"]["version"] == {"modules": 1, "lessons": 1, "blocks": 2}
    assert result["comparison"]["authoring"] == {"modules": 0, "lessons": 0, "blocks": 0}


@pytest.mark.asyncio
async def test_version_detail_blocks_other_teacher():
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "owner"

    with pytest.raises(AuthorizationError):
        await ManageCourseVersionUseCase(repository).detail(
            course_id="course", version_id="version", user_id="other", role="teacher"
        )


@pytest.mark.asyncio
async def test_restore_rejects_archived_course():
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher"
    repository.get_by_id.return_value = SimpleNamespace(status="archived")

    with pytest.raises(ConflictError):
        await ManageCourseVersionUseCase(repository).restore(
            course_id="course",
            version_id="version",
            user_id="teacher",
            role="teacher",
            expected_updated_at="2026-07-23T12:00:00Z",
            reason=None,
        )


@pytest.mark.asyncio
async def test_missing_version_returns_not_found():
    repository = AsyncMock()
    repository.get_instructor_id.return_value = "teacher"
    repository.get_course_version.return_value = None

    with pytest.raises(NotFoundError):
        await ManageCourseVersionUseCase(repository).detail(
            course_id="course", version_id="missing", user_id="teacher", role="teacher"
        )
