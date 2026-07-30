from unittest.mock import MagicMock, patch

import pytest

from src.core.errors.errors import ExternalServiceError
from src.modules.sync.application.dtos import DownloadTokenRequest
from src.modules.sync.application.usecases import GenerateDownloadTokenUseCase


def _request() -> DownloadTokenRequest:
    return DownloadTokenRequest(
        course_id="course-1",
        lesson_id="lesson-1",
        device_id="device-1",
    )


@pytest.mark.asyncio
async def test_download_token_fails_closed_when_storage_signing_fails(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("ENV", "test")
    with (
        patch(
            "src.modules.sync.infrastructure.repositories.DownloadTokenRepository.register_token",
            return_value=True,
        ),
        patch("src.shared.database.db") as database,
    ):
        database.storage.from_().create_signed_url.side_effect = RuntimeError(
            "storage unavailable"
        )

        with pytest.raises(ExternalServiceError):
            await GenerateDownloadTokenUseCase().execute("student-1", _request())


@pytest.mark.asyncio
async def test_download_token_is_not_returned_when_registration_fails(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("ENV", "test")
    storage = MagicMock()
    with (
        patch(
            "src.modules.sync.infrastructure.repositories.DownloadTokenRepository.register_token",
            return_value=False,
        ),
        patch("src.shared.database.db", storage),
    ):
        with pytest.raises(ExternalServiceError):
            await GenerateDownloadTokenUseCase().execute("student-1", _request())

    storage.storage.from_.assert_not_called()
