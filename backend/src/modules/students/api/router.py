from fastapi import APIRouter, Depends
from src.core.security.security import get_current_user, CurrentUser
from src.core.database.database import get_admin_supabase_client
from src.modules.profiles.infrastructure.repositories.supabase_profile_repository import (
    SupabaseProfileRepository,
)
from src.modules.profiles.application.use_cases.get_my_profile_use_case import (
    GetMyProfileUseCase,
)
from src.modules.profiles.application.use_cases.update_my_profile_use_case import (
    UpdateMyProfileUseCase,
)
from src.modules.students.api.schemas import StudentProfileUpdateSchema

router = APIRouter(prefix="/students", tags=["students"])


@router.get("/me")
async def get_me(current_user: CurrentUser = Depends(get_current_user)):
    """Retorna os dados do perfil do aluno autenticado (Legacy route redirection)."""
    repo = SupabaseProfileRepository(get_admin_supabase_client())
    use_case = GetMyProfileUseCase(repo)
    profile = await use_case.execute(current_user.id)
    return {
        "id": profile.id,
        "email": profile.email,
        "role": profile.role,
        "full_name": profile.full_name,
        "referred_by": profile.referred_by,
        "avatar_url": profile.avatar_url,
        "bio": profile.bio,
        "certificate_name": profile.certificate_name,
        "url_username": profile.url_username,
        "birth_date": profile.birth_date,
        "occupation": profile.occupation,
        "company": profile.company,
        "job_title": profile.job_title,
        "open_to_opportunities": profile.open_to_opportunities,
        "linkedin_url": profile.linkedin_url,
        "twitter_url": profile.twitter_url,
        "github_url": profile.github_url,
        "custom_url": profile.custom_url,
        "academic_formations": profile.academic_formations or [],
    }


@router.put("/me")
async def update_me(
    payload: StudentProfileUpdateSchema,
    current_user: CurrentUser = Depends(get_current_user),
):
    """Atualiza as informações de perfil do aluno autenticado (Legacy route redirection)."""
    repo = SupabaseProfileRepository(get_admin_supabase_client())
    use_case = UpdateMyProfileUseCase(repo)
    profile = await use_case.execute(
        user_id=current_user.id,
        full_name=payload.full_name,
        referred_by=payload.referred_by,
        avatar_url=payload.avatar_url,
        bio=payload.bio,
        certificate_name=payload.certificate_name,
        url_username=payload.url_username,
        birth_date=payload.birth_date,
        occupation=payload.occupation,
        company=payload.company,
        job_title=payload.job_title,
        open_to_opportunities=payload.open_to_opportunities,
        linkedin_url=payload.linkedin_url,
        twitter_url=payload.twitter_url,
        github_url=payload.github_url,
        custom_url=payload.custom_url,
        academic_formations=payload.academic_formations,
    )
    return {
        "id": profile.id,
        "email": profile.email,
        "role": profile.role,
        "full_name": profile.full_name,
        "referred_by": profile.referred_by,
        "avatar_url": profile.avatar_url,
        "bio": profile.bio,
        "certificate_name": profile.certificate_name,
        "url_username": profile.url_username,
        "birth_date": profile.birth_date,
        "occupation": profile.occupation,
        "company": profile.company,
        "job_title": profile.job_title,
        "open_to_opportunities": profile.open_to_opportunities,
        "linkedin_url": profile.linkedin_url,
        "twitter_url": profile.twitter_url,
        "github_url": profile.github_url,
        "custom_url": profile.custom_url,
        "academic_formations": profile.academic_formations or [],
    }
