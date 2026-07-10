from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from src.modules.auth.dependencies import get_current_user
from src.modules.courses.services.course_service import CourseService
from src.modules.courses.api.schemas import CourseResponseSchema, LessonResponseSchema
from src.core.exceptions import EntityNotFoundException

from src.shared import database

router = APIRouter(prefix="/courses", tags=["courses"])

@router.get("", response_model=List[CourseResponseSchema])
async def list_courses(current_user: dict = Depends(get_current_user)):
    """Retorna a lista de todos os cursos ativos cadastrados no sistema."""
    try:
        service = CourseService()
        courses = await service.get_all_courses()
        return courses
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro interno ao buscar cursos: {str(e)}"
        )

@router.get("/{id}/lessons/{lesson_id}", response_model=LessonResponseSchema)
async def get_lesson(id: str, lesson_id: str, current_user: dict = Depends(get_current_user)):
    """Retorna os detalhes de uma aula específica associada a um curso."""
    try:
        service = CourseService()
        lesson = await service.get_lesson_by_id(course_id=id, lesson_id=lesson_id)
        return lesson
    except EntityNotFoundException as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=e.message
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro interno ao buscar aula: {str(e)}"
        )

@router.get("/{id}/lessons/{lesson_id}/stream")
async def get_lesson_stream(
    id: str,
    lesson_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Retorna a URL do manifesto HLS assinada de forma segura (Zero MP4 + RLS DRM).
    Valida se o usuário tem assinatura ativa no Stripe ou perfil docente/admin.
    """
    try:
        service = CourseService()
        
        # 1. Verificar autorização
        is_authorized = False
        role = current_user.get("role", "student")
        
        if role in ["teacher", "admin"]:
            is_authorized = True
        else:
            # Consultar tabela public.subscriptions para estudante
            sub_res = database.db.table("subscriptions")\
                .select("*")\
                .eq("user_id", current_user["id"])\
                .execute()
                
            if sub_res.data:
                for sub in sub_res.data:
                    if sub.get("status") in ["active", "trialing"]:
                        is_authorized = True
                        break
                        
        if not is_authorized:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Sua assinatura mensal não está ativa. Renove para acessar esta lição."
            )
            
        # 2. Obter hls_storage_path da lição
        storage_path = await service.get_lesson_stream_path(course_id=id, lesson_id=lesson_id)
        
        # 3. Gerar URL temporária assinada no Storage
        signed_url = service.generate_signed_url(storage_path)
        
        return {
            "status": "success",
            "data": {
                "lesson_id": lesson_id,
                "hls_manifest_url": signed_url,
                "expires_in_seconds": 3600,
                "watermark_text": f"{current_user['email']}"
            }
        }
    except EntityNotFoundException as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=e.message
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao gerar stream da lição: {str(e)}"
        )
