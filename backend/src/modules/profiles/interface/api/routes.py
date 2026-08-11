from fastapi import APIRouter, Depends
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict
from src.core.security.security import get_current_user, CurrentUser
from src.modules.profiles.domain.repositories import ProfileRepository
from src.modules.profiles.interface.api.dependencies import get_profile_repository
from src.modules.profiles.application.use_cases.get_my_profile_use_case import (
    GetMyProfileUseCase,
)
from src.modules.profiles.application.use_cases.update_my_profile_use_case import (
    UpdateMyProfileUseCase,
)

router = APIRouter(prefix="/api/v1/profiles", tags=["profiles"])


class ProfileUpdateInputSchema(BaseModel):
    """Payload de validação de entrada para atualização de perfil."""

    model_config = ConfigDict(frozen=True, extra="forbid")
    full_name: Optional[str] = Field(
        None, min_length=2, max_length=100, description="Nome completo"
    )
    referred_by: Optional[str] = Field(None, description="UUID do perfil indicador (opcional)")
    avatar_url: Optional[str] = Field(None, description="URL do avatar")
    bio: Optional[str] = Field(None, description="Biografia")
    certificate_name: Optional[str] = Field(None, description="Nome nos certificados")
    url_username: Optional[str] = Field(None, description="Usuário na URL")
    birth_date: Optional[str] = Field(None, description="Data de nascimento")
    occupation: Optional[str] = Field(None, description="Ocupação")
    company: Optional[str] = Field(None, description="Empresa")
    job_title: Optional[str] = Field(None, description="Cargo")
    open_to_opportunities: Optional[bool] = Field(None, description="Aberto a oportunidades")
    linkedin_url: Optional[str] = Field(None, description="URL do LinkedIn")
    twitter_url: Optional[str] = Field(None, description="URL do Twitter")
    github_url: Optional[str] = Field(None, description="URL do GitHub")
    custom_url: Optional[str] = Field(None, description="Link personalizado")
    academic_formations: Optional[list] = Field(None, description="Formações acadêmicas")


class ProfileResponseSchema(BaseModel):
    """Schema de resposta representando os dados públicos/privados autorizados do perfil."""

    id: str
    email: str
    role: str
    full_name: Optional[str] = None
    referred_by: Optional[str] = None
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    certificate_name: Optional[str] = None
    url_username: Optional[str] = None
    birth_date: Optional[str] = None
    occupation: Optional[str] = None
    company: Optional[str] = None
    job_title: Optional[str] = None
    open_to_opportunities: bool = False
    linkedin_url: Optional[str] = None
    twitter_url: Optional[str] = None
    github_url: Optional[str] = None
    custom_url: Optional[str] = None
    academic_formations: list = []


@router.get("/me", response_model=ProfileResponseSchema)
async def get_my_profile(
    current_user: CurrentUser = Depends(get_current_user),
    repository: ProfileRepository = Depends(get_profile_repository),
):
    """Retorna os dados do próprio perfil do usuário autenticado de forma BOLA-safe."""
    use_case = GetMyProfileUseCase(repository)
    profile = await use_case.execute(current_user.id)
    return ProfileResponseSchema(
        id=profile.id,
        email=profile.email,
        role=profile.role,
        full_name=profile.full_name,
        referred_by=profile.referred_by,
        avatar_url=profile.avatar_url,
        bio=profile.bio,
        certificate_name=profile.certificate_name,
        url_username=profile.url_username,
        birth_date=profile.birth_date,
        occupation=profile.occupation,
        company=profile.company,
        job_title=profile.job_title,
        open_to_opportunities=profile.open_to_opportunities,
        linkedin_url=profile.linkedin_url,
        twitter_url=profile.twitter_url,
        github_url=profile.github_url,
        custom_url=profile.custom_url,
        academic_formations=profile.academic_formations or [],
    )


@router.put("/me")
async def update_my_profile(
    payload: ProfileUpdateInputSchema,
    current_user: CurrentUser = Depends(get_current_user),
    repository: ProfileRepository = Depends(get_profile_repository),
):
    """Atualiza as informações de perfil do próprio usuário autenticado (BOLA-safe)."""
    use_case = UpdateMyProfileUseCase(repository)
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
        "status": "success",
        "data": [
            {
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
        ],
    }
