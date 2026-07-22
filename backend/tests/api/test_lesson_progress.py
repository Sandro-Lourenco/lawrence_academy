from datetime import datetime, timezone
from decimal import Decimal

from fastapi.testclient import TestClient

from src.core.security.security import CurrentUser, get_current_user
from src.main import app
from src.modules.sync.domain.entities import LessonProgress, LessonProgressContext
from src.modules.sync.interface.api.dependencies import (
    get_lesson_progress_repository,
)


class FakeProgressRepository:
    def __init__(self) -> None:
        now = datetime.now(timezone.utc)
        self.progress = LessonProgress(
            id="progress-1",
            student_id="student-1",
            course_id="course-1",
            lesson_id="lesson-1",
            watched_seconds=120,
            progress_percentage=Decimal("42.50"),
            completed=False,
            completed_at=None,
            last_synced_at=now,
            created_at=now,
            updated_at=now,
        )

    def list_for_student(self, student_id: str) -> list[LessonProgress]:
        return [self.progress] if student_id == "student-1" else []

    def get_lesson_context(self, lesson_id: str) -> LessonProgressContext | None:
        if lesson_id != "lesson-1":
            return None
        return LessonProgressContext(course_id="course-1", duration_seconds=1000)

    def merge_event(self, **values: object) -> LessonProgress:
        assert values["student_id"] == "student-1"
        return LessonProgress(
            id=self.progress.id,
            student_id=self.progress.student_id,
            course_id=self.progress.course_id,
            lesson_id=self.progress.lesson_id,
            watched_seconds=int(str(values["watched_seconds"])),
            progress_percentage=Decimal(str(values["progress_percentage"])),
            completed=bool(values["completed"]),
            completed_at=self.progress.completed_at,
            last_synced_at=self.progress.last_synced_at,
            created_at=self.progress.created_at,
            updated_at=self.progress.updated_at,
        )


client = TestClient(app)


def test_progress_requires_authentication() -> None:
    response = client.get("/api/v1/offline/progress")
    assert response.status_code == 401


def test_progress_reads_only_current_student() -> None:
    repository = FakeProgressRepository()

    async def current_user() -> CurrentUser:
        return CurrentUser(id="student-1", email="student@example.com", role="student")

    app.dependency_overrides[get_current_user] = current_user
    app.dependency_overrides[get_lesson_progress_repository] = lambda: repository
    try:
        response = client.get("/api/v1/offline/progress")
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert response.json()[0]["student_id"] == "student-1"


def test_progress_rejects_mismatched_lesson_id() -> None:
    repository = FakeProgressRepository()

    async def current_user() -> CurrentUser:
        return CurrentUser(id="student-1", email="student@example.com", role="student")

    app.dependency_overrides[get_current_user] = current_user
    app.dependency_overrides[get_lesson_progress_repository] = lambda: repository
    payload = {
        "course_id": "course-1",
        "lesson_id": "lesson-2",
        "watched_seconds": 120,
        "progress_percentage": 42.5,
        "completed": False,
        "completed_at": None,
        "device_id": "device-1",
        "correlation_id": "correlation-1",
        "event_id": "event-1",
        "idempotency_key": "key-1",
        "occurred_at": datetime.now(timezone.utc).isoformat(),
    }
    try:
        response = client.patch(
            "/api/v1/offline/progress/lesson-1", json=payload
        )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 422


def test_progress_patch_calculates_percentage_when_client_omits_it() -> None:
    repository = FakeProgressRepository()

    async def current_user() -> CurrentUser:
        return CurrentUser(id="student-1", email="student@example.com", role="student")

    app.dependency_overrides[get_current_user] = current_user
    app.dependency_overrides[get_lesson_progress_repository] = lambda: repository
    payload = {
        "course_id": "course-1",
        "lesson_id": "lesson-1",
        "watched_seconds": 250,
        "completed": False,
        "completed_at": None,
        "device_id": "device-1",
        "correlation_id": "correlation-1",
        "event_id": "event-1",
        "idempotency_key": "key-1",
        "occurred_at": datetime.now(timezone.utc).isoformat(),
    }
    try:
        response = client.patch(
            "/api/v1/offline/progress/lesson-1", json=payload
        )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert response.json()["progress_percentage"] == "25.00"


def test_progress_patch_rejects_inconsistent_percentage() -> None:
    repository = FakeProgressRepository()

    async def current_user() -> CurrentUser:
        return CurrentUser(id="student-1", email="student@example.com", role="student")

    app.dependency_overrides[get_current_user] = current_user
    app.dependency_overrides[get_lesson_progress_repository] = lambda: repository
    payload = {
        "course_id": "course-1",
        "lesson_id": "lesson-1",
        "watched_seconds": 250,
        "progress_percentage": 50,
        "completed": False,
        "completed_at": None,
        "device_id": "device-1",
        "correlation_id": "correlation-1",
        "event_id": "event-2",
        "idempotency_key": "key-2",
        "occurred_at": datetime.now(timezone.utc).isoformat(),
    }
    try:
        response = client.patch(
            "/api/v1/offline/progress/lesson-1", json=payload
        )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 422
    assert "inconsistent" in response.json()["detail"]


def test_progress_patch_rejects_watched_seconds_above_duration() -> None:
    repository = FakeProgressRepository()

    async def current_user() -> CurrentUser:
        return CurrentUser(id="student-1", email="student@example.com", role="student")

    app.dependency_overrides[get_current_user] = current_user
    app.dependency_overrides[get_lesson_progress_repository] = lambda: repository
    payload = {
        "course_id": "course-1",
        "lesson_id": "lesson-1",
        "watched_seconds": 1001,
        "progress_percentage": 100,
        "completed": False,
        "completed_at": None,
        "device_id": "device-1",
        "correlation_id": "correlation-1",
        "event_id": "event-3",
        "idempotency_key": "key-3",
        "occurred_at": datetime.now(timezone.utc).isoformat(),
    }
    try:
        response = client.patch(
            "/api/v1/offline/progress/lesson-1", json=payload
        )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 422
    assert "exceeds" in response.json()["detail"]
