from datetime import datetime
from decimal import Decimal
from collections.abc import Mapping
from typing import Any

from src.modules.sync.domain.entities import LessonProgress, LessonProgressContext
from src.shared import database


class EventStoreRepository:
    def __init__(self) -> None:
        self.db = database.db

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
    ) -> bool:
        data = {
            "event_id": event_id,
            "idempotency_key": idempotency_key,
            "correlation_id": correlation_id,
            "request_id": request_id,
            "device_id": device_id,
            "user_id": user_id,
            "course_id": course_id,
            "lesson_id": lesson_id,
            "event_type": event_type,
            "payload": payload,
            "occurred_at": occurred_at,
            "origin": origin,
        }
        self.db.table("event_store").upsert(
            {key: value for key, value in data.items() if value is not None},
            on_conflict="user_id,idempotency_key",
            ignore_duplicates=True,
        ).execute()
        return True


class SupabaseLessonProgressRepository:
    def __init__(self) -> None:
        self.db = database.db

    @staticmethod
    def _to_entity(data: dict[str, Any]) -> LessonProgress:
        def parse_datetime(value: object) -> datetime:
            return datetime.fromisoformat(str(value).replace("Z", "+00:00"))

        return LessonProgress(
            id=str(data["id"]),
            student_id=str(data["student_id"]),
            course_id=str(data["course_id"]),
            lesson_id=str(data["lesson_id"]),
            watched_seconds=int(data["watched_seconds"]),
            progress_percentage=Decimal(str(data["progress_percentage"])),
            completed=bool(data["completed"]),
            completed_at=(
                parse_datetime(data["completed_at"])
                if data.get("completed_at")
                else None
            ),
            last_synced_at=parse_datetime(data["last_synced_at"]),
            created_at=parse_datetime(data["created_at"]),
            updated_at=parse_datetime(data["updated_at"]),
        )

    def list_for_student(self, student_id: str) -> list[LessonProgress]:
        response = (
            self.db.table("lesson_progress")
            .select("*")
            .eq("student_id", student_id)
            .order("updated_at", desc=True)
            .execute()
        )
        rows = response.data
        if not isinstance(rows, list):
            raise RuntimeError("Progress list returned an invalid payload")
        return [
            self._to_entity(dict(row))
            for row in rows
            if isinstance(row, Mapping)
        ]

    def get_lesson_context(self, lesson_id: str) -> LessonProgressContext | None:
        response = (
            self.db.table("lessons")
            .select("course_id,duration_seconds")
            .eq("id", lesson_id)
            .maybe_single()
            .execute()
        )
        if response is None:
            return None
        row = response.data
        if not isinstance(row, Mapping):
            return None
        return LessonProgressContext(
            course_id=str(row["course_id"]),
            duration_seconds=int(str(row.get("duration_seconds") or 0)),
        )

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
    ) -> LessonProgress:
        response = self.db.rpc(
            "merge_lesson_progress_event",
            {
                "p_student_id": student_id,
                "p_course_id": course_id,
                "p_lesson_id": lesson_id,
                "p_watched_seconds": watched_seconds,
                "p_progress_percentage": str(progress_percentage),
                "p_completed": completed,
                "p_completed_at": completed_at.isoformat() if completed_at else None,
                "p_event_id": event_id,
                "p_idempotency_key": idempotency_key,
                "p_correlation_id": correlation_id,
                "p_device_id": device_id,
                "p_occurred_at": occurred_at.isoformat(),
                "p_payload": payload,
            },
        ).execute()
        rows = response.data
        if not isinstance(rows, list) or not rows or not isinstance(rows[0], Mapping):
            raise RuntimeError("Progress merge returned no state")
        return self._to_entity(dict(rows[0]))
