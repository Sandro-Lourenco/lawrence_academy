from src.core.database.database import get_admin_supabase_client
from src.modules.lives.domain.repositories import LiveEventRepository
from src.modules.lives.infrastructure.supabase_live_event_repository import (
    SupabaseLiveEventRepository,
)


def get_live_event_repository() -> LiveEventRepository:
    return SupabaseLiveEventRepository(get_admin_supabase_client())
