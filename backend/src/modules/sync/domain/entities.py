from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal


@dataclass(frozen=True)
class LessonProgress:
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


@dataclass(frozen=True)
class LessonProgressContext:
    course_id: str
    duration_seconds: int
