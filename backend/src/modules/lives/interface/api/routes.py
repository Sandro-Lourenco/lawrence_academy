from datetime import datetime
from typing import Literal
from urllib.parse import urlparse

from fastapi import APIRouter, Depends, Response, status
from pydantic import BaseModel, Field, field_validator

from src.core.security.security import CurrentUser, get_current_user, require_role
from src.modules.lives.application.use_cases import (
    CreateLiveEventUseCase, DeleteLiveEventUseCase, ListPublicLiveEventsUseCase,
    ListTeacherLiveEventsUseCase, UpdateLiveEventUseCase,
)
from src.modules.lives.domain.repositories import LiveEventRepository
from src.modules.lives.interface.api.dependencies import get_live_event_repository

router = APIRouter(prefix="/api/v1/live-events", tags=["live-events"])
teacher_router = APIRouter(prefix="/api/v1/teacher/live-events", tags=["teacher", "live-events"])
LiveStatus = Literal["draft", "scheduled", "live", "ended", "cancelled"]
SUPPORTED_TIMEZONES = {"America/Sao_Paulo", "America/Manaus", "Europe/Paris"}


def _youtube_url(value: str) -> str:
    parsed = urlparse(value)
    host = (parsed.hostname or "").lower()
    if parsed.scheme != "https" or host not in {"youtube.com", "www.youtube.com", "m.youtube.com", "youtu.be"}:
        raise ValueError("Informe um link HTTPS oficial do YouTube.")
    if host == "youtu.be" and not parsed.path.strip("/"):
        raise ValueError("O link do YouTube precisa conter o vídeo ou a live.")
    if host != "youtu.be" and not (parsed.path.startswith("/live/") or (parsed.path == "/watch" and "v=" in parsed.query)):
        raise ValueError("Use um link youtube.com/watch ou youtube.com/live.")
    return value


class LiveEventInput(BaseModel):
    title: str = Field(min_length=3, max_length=160)
    description: str = Field(default="", max_length=2000)
    tag: str = Field(default="Alta-costura", min_length=2, max_length=60)
    scheduled_for: datetime
    timezone: str = Field(default="America/Sao_Paulo", max_length=80)
    duration_minutes: int = Field(default=60, ge=10, le=480)
    status: LiveStatus = "draft"
    youtube_url: str = Field(max_length=500)
    banner_url: str | None = Field(default=None, max_length=1000)

    _validate_youtube = field_validator("youtube_url")(_youtube_url)

    @field_validator("timezone")
    @classmethod
    def validate_timezone(cls, value: str) -> str:
        if value not in SUPPORTED_TIMEZONES:
            raise ValueError("Fuso horário IANA não suportado nesta versão.")
        return value

    @field_validator("banner_url")
    @classmethod
    def validate_banner_url(cls, value: str | None) -> str | None:
        if value and urlparse(value).scheme != "https":
            raise ValueError("A imagem deve usar HTTPS.")
        return value


class LiveEventPatch(BaseModel):
    title: str | None = Field(default=None, min_length=3, max_length=160)
    description: str | None = Field(default=None, max_length=2000)
    tag: str | None = Field(default=None, min_length=2, max_length=60)
    scheduled_for: datetime | None = None
    timezone: str | None = Field(default=None, max_length=80)
    duration_minutes: int | None = Field(default=None, ge=10, le=480)
    status: LiveStatus | None = None
    youtube_url: str | None = Field(default=None, max_length=500)
    banner_url: str | None = Field(default=None, max_length=1000)

    @field_validator("youtube_url")
    @classmethod
    def validate_youtube(cls, value: str | None) -> str | None:
        return _youtube_url(value) if value else value

    @field_validator("timezone")
    @classmethod
    def validate_timezone(cls, value: str | None) -> str | None:
        if value and value not in SUPPORTED_TIMEZONES:
            raise ValueError("Fuso horário IANA não suportado nesta versão.")
        return value


class LiveEventResponse(BaseModel):
    id: str
    instructor_id: str
    instructor_name: str
    title: str
    description: str
    tag: str
    scheduled_for: datetime
    timezone: str
    duration_minutes: int
    status: LiveStatus
    youtube_url: str
    banner_url: str | None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


@router.get("", response_model=list[LiveEventResponse])
async def list_live_events(
    _: CurrentUser = Depends(get_current_user),
    repository: LiveEventRepository = Depends(get_live_event_repository),
):
    return await ListPublicLiveEventsUseCase(repository).execute()


@teacher_router.get("", response_model=list[LiveEventResponse])
async def list_teacher_live_events(
    user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: LiveEventRepository = Depends(get_live_event_repository),
):
    return await ListTeacherLiveEventsUseCase(repository).execute(user.id, user.role)


@teacher_router.post("", response_model=LiveEventResponse, status_code=status.HTTP_201_CREATED)
async def create_live_event(
    payload: LiveEventInput,
    user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: LiveEventRepository = Depends(get_live_event_repository),
):
    return await CreateLiveEventUseCase(repository).execute(user.id, payload.model_dump(mode="json"))


@teacher_router.patch("/{event_id}", response_model=LiveEventResponse)
async def update_live_event(
    event_id: str, payload: LiveEventPatch,
    user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: LiveEventRepository = Depends(get_live_event_repository),
):
    return await UpdateLiveEventUseCase(repository).execute(
        event_id, payload.model_dump(exclude_unset=True, mode="json"), user.id, user.role
    )


@teacher_router.delete("/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_live_event(
    event_id: str,
    user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: LiveEventRepository = Depends(get_live_event_repository),
):
    await DeleteLiveEventUseCase(repository).execute(event_id, user.id, user.role)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
