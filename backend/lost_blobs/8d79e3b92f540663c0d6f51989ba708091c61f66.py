from src.core.database.database import get_admin_supabase_client
from src.modules.courses.domain.repositories import CourseRepository
from src.modules.courses.infrastructure.repositories.supabase_course_repository import (
    SupabaseCourseRepository,
)


def get_course_repository() -> CourseRepository:
    return SupabaseCourseRepository(get_admin_supabase_client())
