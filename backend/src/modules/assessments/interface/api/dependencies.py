from src.core.database.database import get_admin_supabase_client
from src.modules.assessments.domain.repositories import AssessmentRepository
from src.modules.assessments.infrastructure.repositories.supabase_assessment_repository import (
    SupabaseAssessmentRepository,
)


def get_assessment_repository() -> AssessmentRepository:
    return SupabaseAssessmentRepository(get_admin_supabase_client())
