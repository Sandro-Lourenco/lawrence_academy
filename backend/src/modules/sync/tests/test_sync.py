from datetime import datetime, timezone
from decimal import Decimal

import pytest

from src.modules.sync.application.dtos import SyncBatchRequest, SyncEventDTO
from src.modules.sync.application.usecases import ProcessSyncBatchUseCase
from src.modules.sync.domain.entities import LessonProgress, LessonProgressContext


class FakeProgressRepository:
    def __init__(self) -> None:
        self.state: LessonProgress | None = None
        self.keys: set[str] = set()

    def list_for_student(self, student_id: str) -> list[LessonProgress]:
        return [self.state] if self.state and self.state.student_id == student_id else []

    def get_lesson_context(self, lesson_id: str) -> LessonProgressContext | None:
        if lesson_id != "lesson-1":
            return None
        return LessonProgressContext(course_id="course-1", duration_seconds=1000)

    def merge_event(self, **values: object) -> LessonProgress:
        key = str(values["idempotency_key"])
        if key in self.keys and self.state is not None:
            return self.state
        self.keys.add(key)

        now = datetime.now(timezone.utc)
        previous = self.state
        completed = bool(values["completed"]) or bool(
            previous.completed if previous else False
        )
        percentage = max(
            Decimal(str(values["progress_percentage"])),
            previous.progress_percentage if previous else Decimal("0"),
        )
        self.state = LessonProgress(
            id=previous.id if previous else "progress-1",
            student_id=str(values["student_id"]),
            course_id=str(values["course_id"]),
            lesson_id=str(values["lesson_id"]),
            watched_seconds=max(
                int(str(values["watched_seconds"])),
                previous.watched_seconds if previous else 0,
            ),
            progress_percentage=Decimal("100") if completed else percentage,
            completed=completed,
            completed_at=(
                previous.completed_at
                if previous and previous.completed_at
                else values["completed_at"]
                if completed and isinstance(values["completed_at"], datetime)
                else None
            ),
            last_synced_at=now,
            created_at=previous.created_at if previous else now,
            updated_at=now,
        )
        return self.state


class FakeEventRepository:
    def append_event(self, **values: object) -> bool:
        return True


def progress_event(
    *,
    event_id: str,
    key: str,
    percentage: int,
    watched_seconds: int,
    completed: bool = False,
    device_id: str = "device-a",
) -> SyncEventDTO:
    return SyncEventDTO(
        id=event_id,
        action="LESSON_COMPLETED" if completed else "UPDATE_LESSON_PROGRESS",
        payload={
            "course_id": "course-1",
            "lesson_id": "lesson-1",
            "watched_seconds": watched_seconds,
            "progress_percentage": percentage,
            "completed": completed,
            "completed_at": datetime.now(timezone.utc).isoformat()
            if completed
            else None,
            "device_id": device_id,
            "correlation_id": f"correlation-{event_id}",
        },
        created_at=int(datetime.now(timezone.utc).timestamp()),
        idempotency_key=key,
    )


@pytest.mark.asyncio
async def test_out_of_order_multi_device_events_never_decrease_progress() -> None:
    repository = FakeProgressRepository()
    use_case = ProcessSyncBatchUseCase(repository, FakeEventRepository())
    request = SyncBatchRequest(
        events=[
            progress_event(
                event_id="newer", key="key-1", percentage=90,
                watched_seconds=900, device_id="device-a"
            ),
            progress_event(
                event_id="older", key="key-2", percentage=20,
                watched_seconds=200, device_id="device-b"
            ),
        ]
    )

    response = await use_case.execute("student-1", request)

    assert all(result.status == "COMPLETED" for result in response.results)
    assert repository.state is not None
    assert repository.state.progress_percentage == Decimal("90")
    assert repository.state.watched_seconds == 900


@pytest.mark.asyncio
async def test_replayed_idempotency_key_does_not_apply_second_event() -> None:
    repository = FakeProgressRepository()
    use_case = ProcessSyncBatchUseCase(repository, FakeEventRepository())
    request = SyncBatchRequest(
        events=[
            progress_event(
                event_id="first", key="same-key", percentage=40,
                watched_seconds=400
            ),
            progress_event(
                event_id="replay", key="same-key", percentage=80,
                watched_seconds=800
            ),
        ]
    )

    await use_case.execute("student-1", request)

    assert repository.state is not None
    assert repository.state.progress_percentage == Decimal("40")


@pytest.mark.asyncio
async def test_completion_is_irreversible_and_forces_full_progress() -> None:
    repository = FakeProgressRepository()
    use_case = ProcessSyncBatchUseCase(repository, FakeEventRepository())

    await use_case.execute(
        "student-1",
        SyncBatchRequest(
            events=[
                progress_event(
                    event_id="complete", key="key-complete", percentage=100,
                    watched_seconds=1000, completed=True
                ),
                progress_event(
                    event_id="stale", key="key-stale", percentage=10,
                    watched_seconds=100
                ),
            ]
        ),
    )

    assert repository.state is not None
    assert repository.state.completed is True
    assert repository.state.progress_percentage == Decimal("100")
    assert repository.state.completed_at is not None


@pytest.mark.asyncio
async def test_invalid_progress_is_reported_without_persistence() -> None:
    repository = FakeProgressRepository()
    use_case = ProcessSyncBatchUseCase(repository, FakeEventRepository())
    event = progress_event(
        event_id="invalid", key="key-invalid", percentage=50, watched_seconds=500
    )
    event.payload.pop("device_id")

    response = await use_case.execute(
        "student-1", SyncBatchRequest(events=[event])
    )

    assert response.results[0].status == "FAILED"
    assert repository.state is None


@pytest.mark.asyncio
async def test_client_percentage_must_match_server_calculation() -> None:
    repository = FakeProgressRepository()
    use_case = ProcessSyncBatchUseCase(repository, FakeEventRepository())

    response = await use_case.execute(
        "student-1",
        SyncBatchRequest(
            events=[
                progress_event(
                    event_id="inconsistent",
                    key="key-inconsistent",
                    percentage=75,
                    watched_seconds=500,
                )
            ]
        ),
    )

    assert response.results[0].status == "FAILED"
    assert repository.state is None


@pytest.mark.asyncio
async def test_watched_seconds_cannot_exceed_lesson_duration() -> None:
    repository = FakeProgressRepository()
    use_case = ProcessSyncBatchUseCase(repository, FakeEventRepository())

    response = await use_case.execute(
        "student-1",
        SyncBatchRequest(
            events=[
                progress_event(
                    event_id="too-long",
                    key="key-too-long",
                    percentage=100,
                    watched_seconds=1001,
                )
            ]
        ),
    )

    assert response.results[0].status == "FAILED"
    assert repository.state is None
