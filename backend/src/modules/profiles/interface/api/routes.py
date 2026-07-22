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
    referred_by: Optional[str] = Field(
        None, description="UUID do perfil indicador (opcional)"
    )


class ProfileResponseSchema(BaseModel):
    """Schema de resposta representando os dados públicos/privados autorizados do perfil."""

    id: str
    email: str
    full_name: Optional[str] = None
    referred_by: Optional[str] = None
    role: str


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
        full_name=profile.full_name,
        referred_by=profile.referred_by,
        role=profile.role,
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
    )
    return {
        "status": "success",
        "data": [
            {
                "id": profile.id,
                "email": profile.email,
                "full_name": profile.full_name,
                "referred_by": profile.referred_by,
                "role": profile.role,
            }
        ],
    }
