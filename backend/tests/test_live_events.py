from datetime import datetime, timezone

import pytest
from pydantic import ValidationError as PydanticValidationError

from src.core.errors.errors import AuthorizationError
from src.modules.lives.application.use_cases import (
    DeleteLiveEventUseCase,
    UpdateLiveEventUseCase,
)
from src.modules.lives.domain.entities import LiveEvent
from src.modules.lives.interface.api.routes import LiveEventInput


def _event(instructor_id: str = "teacher-1") -> LiveEvent:
    now = datetime.now(timezone.utc)
    return LiveEvent(
        id="event-1", instructor_id=instructor_id, instructor_name="Marisa",
        title="Moulage ao vivo", description="", tag="Moulage",
        scheduled_for=now, timezone="America/Sao_Paulo", duration_minutes=60,
        status="scheduled", youtube_url="https://youtube.com/live/abc_123",
        banner_url=None, created_at=now, updated_at=now,
    )


class FakeRepository:
    def __init__(self, event: LiveEvent | None = None):
        self.event = event
        self.deleted = False

    async def get_by_id(self, event_id): return self.event
    async def update(self, event_id, data):
        return self.event
    async def delete(self, event_id): self.deleted = True


def test_live_event_input_accepts_youtube_and_iana_timezone():
    value = LiveEventInput(
        title="Moulage ao vivo", scheduled_for=datetime.now(timezone.utc),
        youtube_url="https://www.youtube.com/watch?v=abc_123",
        timezone="America/Sao_Paulo",
    )
    assert value.status == "draft"


@pytest.mark.parametrize("url", [
    "http://youtube.com/watch?v=abc", "https://evil.example/live/abc",
    "https://youtube.com/channel/test",
])
def test_live_event_input_rejects_unsafe_youtube_urls(url):
    with pytest.raises(PydanticValidationError):
        LiveEventInput(title="Live segura", scheduled_for=datetime.now(timezone.utc), youtube_url=url)


@pytest.mark.asyncio
async def test_teacher_cannot_update_another_instructors_event():
    repo = FakeRepository(_event("teacher-owner"))
    with pytest.raises(AuthorizationError):
        await UpdateLiveEventUseCase(repo).execute("event-1", {"title": "Ataque"}, "teacher-other", "teacher")


@pytest.mark.asyncio
async def test_super_admin_can_delete_any_event():
    repo = FakeRepository(_event("teacher-owner"))
    await DeleteLiveEventUseCase(repo).execute("event-1", "admin-1", "super_admin")
    assert repo.deleted is True
