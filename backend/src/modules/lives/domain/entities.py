from dataclasses import dataclass
from datetime import datetime


@dataclass(frozen=True)
class LiveEvent:
    id: str
    instructor_id: str
    instructor_name: str
    title: str
    description: str
    tag: str
    scheduled_for: datetime
    timezone: str
    duration_minutes: int
    status: str
    youtube_url: str
    banner_url: str | None
    created_at: datetime
    updated_at: datetime
