from unittest.mock import AsyncMock, Mock

import pytest

from src.core.errors.errors import AuthorizationError
from src.modules.courses.application.use_cases.delete_module_use_case import (
    DeleteModuleUseCase,
)


@pytest.mark.asyncio
async def test_repeated_delete_is_success_for_course_owner():
    repository = Mock()
    repository.get_instructor_id = AsyncMock(return_value="teacher-1")
    repository.get_module_by_id_and_course_id = AsyncMock(return_value=None)
    repository.delete_module = AsyncMock()

    result = await DeleteModuleUseCase(repository).execute(
        "course-1", "module-already-deleted", "teacher-1", "teacher"
    )

    assert result is True
    repository.delete_module.assert_not_awaited()


@pytest.mark.asyncio
async def test_repeated_delete_still_denies_non_owner():
    repository = Mock()
    repository.get_instructor_id = AsyncMock(return_value="teacher-1")

    with pytest.raises(AuthorizationError):
        await DeleteModuleUseCase(repository).execute(
            "course-1", "module-already-deleted", "attacker", "teacher"
        )
