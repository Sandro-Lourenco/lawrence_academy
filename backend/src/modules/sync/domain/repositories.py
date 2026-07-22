from datetime import datetime
from decimal import Decimal
from typing import Any, Protocol

from .entities import LessonProgress, LessonProgressContext


class LessonProgressRepository(Protocol):
    def list_for_student(self, student_id: str) -> list[LessonProgress]: ...

    def get_lesson_context(self, lesson_id: str) -> LessonProgressContext | None: ...

    def merge_event(
        self,
        *,
        student_id: str,
        course_id: str,
        lesson_id: str,
        watched_seconds: int,
        progress_percentage: Decimal,
        completed: bool,
        completed_at: datetime | None,
        event_id: str,
        idempotency_key: str,
        correlation_id: str,
        device_id: str,
        occurred_at: datetime,
        payload: dict[str, object],
    ) -> LessonProgress: ...


class SyncEventRepository(Protocol):
    def append_event(
        self,
        *,
        event_type: str,
        event_id: str,
        idempotency_key: str,
        correlation_id: str,
        device_id: str,
        user_id: str,
        payload: dict[str, Any],
        occurred_at: str,
        origin: str,
        lesson_id: str | None = None,
        course_id: str | None = None,
        request_id: str | None = None,
    ) -> bool: ...
