from fastapi import APIRouter, Depends, HTTPException, status
from src.modules.auth.dependencies import get_current_user
from src.modules.profiles.interfaces.schemas import ProfileUpdateSchema
from src.modules.profiles.application.get_profile import GetMyProfileUseCase
from src.modules.profiles.application.update_profile import UpdateMyProfileUseCase
from src.core.exceptions import EntityNotFoundException, DomainException

router = APIRouter(prefix="/api/profiles", tags=["profiles"])

@router.get("/me")
async def get_my_profile(current_user: dict = Depends(get_current_user)):
    """Retorna o perfil do próprio usuário autenticado de forma BOLA-safe."""
    try:
        profile = GetMyProfileUseCase.execute(current_user["id"])
        # Retorna o dicionário para manter a compatibilidade direta com o formato do banco / testes
        return profile.model_dump()
    except EntityNotFoundException as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=e.message)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ocorreu um erro interno no processamento dos dados. Nossa equipe de engenharia foi notificada."
        )

@router.put("/me")
async def update_my_profile(
    profile_data: ProfileUpdateSchema, 
    current_user: dict = Depends(get_current_user)
):
    """Atualiza as informações do perfil do próprio usuário autenticado (BOLA-safe)."""
    try:
        updated_profile = UpdateMyProfileUseCase.execute(
            user_id=current_user["id"],
            full_name=profile_data.full_name,
            referred_by=profile_data.referred_by
        )
        return {
            "status": "success", 
            "data": [updated_profile.model_dump()]
        }
    except DomainException as e:
        status_code = status.HTTP_404_NOT_FOUND if e.code == "NOT_FOUND" else status.HTTP_400_BAD_REQUEST
        raise HTTPException(status_code=status_code, detail=e.message)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ocorreu um erro interno no processamento dos dados. Nossa equipe de engenharia foi notificada."
        )
