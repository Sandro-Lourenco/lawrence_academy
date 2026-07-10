from fastapi import APIRouter, Depends, HTTPException, status
from src.modules.auth.dependencies import get_current_user
from src.modules.students.services.student_service import StudentService
from src.modules.students.api.schemas import StudentProfileResponseSchema, StudentProfileUpdateSchema
from src.core.exceptions import EntityNotFoundException

router = APIRouter(prefix="/students", tags=["students"])

@router.get("/me", response_model=StudentProfileResponseSchema)
async def get_me(current_user: dict = Depends(get_current_user)):
    """Retorna os dados de perfil do aluno autenticado (BOLA-safe)."""
    try:
        service = StudentService()
        profile = await service.get_student_profile(student_id=current_user["id"])
        return profile
    except EntityNotFoundException as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=e.message
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro interno ao buscar perfil: {str(e)}"
        )

@router.put("/me", response_model=StudentProfileResponseSchema)
async def update_me(
    payload: StudentProfileUpdateSchema,
    current_user: dict = Depends(get_current_user)
):
    """Atualiza as informações de perfil do aluno autenticado (BOLA-safe)."""
    try:
        service = StudentService()
        updated_profile = await service.update_student_profile(
            student_id=current_user["id"],
            profile_data=payload.model_dump(exclude_unset=True)
        )
        return updated_profile
    except EntityNotFoundException as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=e.message
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro interno ao atualizar perfil: {str(e)}"
        )
