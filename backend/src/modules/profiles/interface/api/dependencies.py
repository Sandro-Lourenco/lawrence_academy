from src.core.database.database import get_admin_supabase_client
from src.modules.profiles.domain.repositories import ProfileRepository
from src.modules.profiles.infrastructure.repositories.supabase_profile_repository import (
    SupabaseProfileRepository,
)


def get_profile_repository() -> ProfileRepository:
    return SupabaseProfileRepository(get_admin_supabase_client())
