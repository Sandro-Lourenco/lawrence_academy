from src.modules.sync.domain.repositories import (
    LessonProgressRepository,
    SyncEventRepository,
)
from src.modules.sync.infrastructure.event_store_repository import (
    EventStoreRepository,
    SupabaseLessonProgressRepository,
)


def get_lesson_progress_repository() -> LessonProgressRepository:
    return SupabaseLessonProgressRepository()


def get_sync_event_repository() -> SyncEventRepository:
    return EventStoreRepository()
