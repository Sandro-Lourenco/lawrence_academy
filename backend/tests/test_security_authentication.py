from types import SimpleNamespace
from unittest.mock import AsyncMock, Mock

import pytest
from fastapi import HTTPException

from src.core.security import security


@pytest.mark.asyncio
async def test_current_user_validation_offloads_supabase_auth(monkeypatch) -> None:
    get_user = Mock()
    auth_db = SimpleNamespace(auth=SimpleNamespace(get_user=get_user))
    user = SimpleNamespace(
        id="student-1",
        email="student@example.com",
        app_metadata={"role": "student", "amr": ["mfa"]},
    )
    run_sync_io = AsyncMock(return_value=SimpleNamespace(user=user))
    monkeypatch.setattr(security.database, "auth_db", auth_db)
    monkeypatch.setattr(security, "run_sync_io", run_sync_io)

    current_user = await security.get_current_user("Bearer valid-token")

    assert current_user.id == "student-1"
    assert current_user.role == "student"
    assert current_user.mfa_enabled is True
    run_sync_io.assert_awaited_once_with(get_user, "valid-token")


@pytest.mark.asyncio
async def test_current_user_rejects_stale_session_without_leaking_error(
    monkeypatch,
) -> None:
    auth_db = SimpleNamespace(auth=SimpleNamespace(get_user=Mock()))
    monkeypatch.setattr(security.database, "auth_db", auth_db)
    monkeypatch.setattr(
        security,
        "run_sync_io",
        AsyncMock(side_effect=RuntimeError("sensitive upstream error")),
    )

    with pytest.raises(HTTPException) as caught:
        await security.get_current_user("Bearer stale-token")

    assert caught.value.status_code == 401
    assert "sensitive upstream error" not in caught.value.detail


@pytest.mark.asyncio
async def test_current_user_rejects_missing_authorization_header() -> None:
    with pytest.raises(HTTPException) as caught:
        await security.get_current_user(None)

    assert caught.value.status_code == 401
