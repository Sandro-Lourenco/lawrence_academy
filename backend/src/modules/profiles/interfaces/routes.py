from fastapi import APIRouter, Depends
from src.core.security.security import get_current_user, CurrentUser
from src.core.database.database import get_admin_supabase_client
from src.modules.profiles.infrastructure.repositories.supabase_profile_repository import SupabaseProfileRepository
from src.modules.profiles.application.use_cases.get_my_profile_use_case import GetMyProfileUseCase
from src.modules.profiles.application.use_cases.update_my_profile_use_case import UpdateMyProfileUseCase
from src.modules.profiles.interfaces.schemas import ProfileUpdateSchema

router = APIRouter(prefix="/api/profiles", tags=["profiles"])

@router.get("/me")
async def get_my_profile(current_user: CurrentUser = Depends(get_current_user)):
    """Retorna o perfil do próprio usuário autenticado de forma BOLA-safe (Legacy route redirection)."""
    repo = SupabaseProfileRepository(get_admin_supabase_client())
    use_case = GetMyProfileUseCase(repo)
    profile = await use_case.execute(current_user.id)
    return {
        "id": profile.id,
        "email": profile.email,
        "full_name": profile.full_name,
        "referred_by": profile.referred_by,
        "role": profile.role
    }

@router.put("/me")
async def update_my_profile(
    profile_data: ProfileUpdateSchema, 
    current_user: CurrentUser = Depends(get_current_user)
):
    """Atualiza o perfil do próprio usuário autenticado de forma BOLA-safe (Legacy route redirection)."""
    repo = SupabaseProfileRepository(get_admin_supabase_client())
    use_case = UpdateMyProfileUseCase(repo)
    profile = await use_case.execute(
        user_id=current_user.id,
        full_name=profile_data.full_name,
        referred_by=profile_data.referred_by
    )
    return {
        "status": "success", 
        "data": [
            {
                "id": profile.id,
                "email": profile.email,
                "full_name": profile.full_name,
                "referred_by": profile.referred_by,
                "role": profile.role
            }
        ]
    }
