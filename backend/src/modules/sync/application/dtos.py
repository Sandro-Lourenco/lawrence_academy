from datetime import datetime, timezone
from decimal import Decimal
from typing import Any, Dict, List, Literal, Optional

from pydantic import BaseModel, ConfigDict, Field


class SyncEventDTO(BaseModel):
    model_config = ConfigDict(extra="forbid")

    id: str = Field(min_length=1, max_length=200)
    action: Literal[
        "UPDATE_LESSON_PROGRESS",
        "LESSON_COMPLETED",
        "VIDEO_HEARTBEAT",
        "PLAYER_STOPPED",
        "PLAYER_RESUMED",
        "PLAYER_PAUSED",
        "PLAYER_SEEK",
        "PLAYER_ERROR",
        "DOWNLOAD_COMPLETED",
    ]
    payload: Dict[str, Any]
    created_at: int
    idempotency_key: str = Field(min_length=1, max_length=200)


class SyncBatchRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    events: List[SyncEventDTO] = Field(min_length=1, max_length=100)


class SyncEventResponseDTO(BaseModel):
    id: str
    status: str
    error_message: Optional[str] = None


class SyncBatchResponse(BaseModel):
    results: List[SyncEventResponseDTO]


class ProgressPayload(BaseModel):
    model_config = ConfigDict(extra="forbid")

    course_id: str
    lesson_id: str
    watched_seconds: int = Field(ge=0)
    progress_percentage: Decimal | None = Field(default=None, ge=0, le=100)
    completed: bool = False
    completed_at: datetime | None = None
    device_id: str = Field(min_length=1, max_length=200)
    correlation_id: str = Field(min_length=1, max_length=200)


class ProgressWriteRequest(ProgressPayload):
    event_id: str = Field(min_length=1, max_length=200)
    idempotency_key: str = Field(min_length=1, max_length=200)
    occurred_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class LessonProgressResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    student_id: str
    course_id: str
    lesson_id: str
    watched_seconds: int
    progress_percentage: Decimal
    completed: bool
    completed_at: datetime | None
    last_synced_at: datetime
    created_at: datetime
    updated_at: datetime


class DownloadTokenRequest(BaseModel):
    lesson_id: str
    course_id: str
    device_id: str


class DownloadTokenResponse(BaseModel):
    download_token: str
    signed_url: str
    expires_at: int
    license_expires_at: int
    download_id: str
