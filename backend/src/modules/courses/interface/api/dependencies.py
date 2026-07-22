from src.core.database.database import get_admin_supabase_client
from src.core.storage.repositories import StorageRepository
from src.core.storage.supabase_storage_repository import SupabaseStorageRepository
from src.modules.courses.domain.repositories import CourseRepository
from src.modules.courses.infrastructure.repositories.supabase_course_repository import (
    SupabaseCourseRepository,
)


def get_course_repository() -> CourseRepository:
    return SupabaseCourseRepository(get_admin_supabase_client())


def get_storage_repository() -> StorageRepository:
    return SupabaseStorageRepository(get_admin_supabase_client())
