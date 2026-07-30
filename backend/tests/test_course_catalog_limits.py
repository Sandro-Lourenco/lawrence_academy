from unittest.mock import AsyncMock

import pytest

from src.modules.courses.application.use_cases.list_courses_use_case import (
    ListCoursesUseCase,
)


@pytest.mark.asyncio
async def test_catalog_caps_requested_page_size() -> None:
    repository = AsyncMock()
    repository.list_published_versions.return_value = []

    await ListCoursesUseCase(repository).execute(limit=5000)

    repository.list_published_versions.assert_awaited_once_with(limit=50)


@pytest.mark.asyncio
async def test_catalog_normalizes_zero_to_one() -> None:
    repository = AsyncMock()
    repository.list_published_versions.return_value = []

    await ListCoursesUseCase(repository).execute(limit=0)

    repository.list_published_versions.assert_awaited_once_with(limit=1)
