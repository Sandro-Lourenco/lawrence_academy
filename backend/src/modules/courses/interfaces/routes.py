from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from src.modules.auth.dependencies import get_current_user, require_role
from src.modules.courses.interfaces.schemas import CourseCreateSchema
from src.modules.courses.application.list_courses import ListCoursesUseCase
from src.modules.courses.application.get_course import GetCourseUseCase
from src.modules.courses.application.create_course import CreateCourseUseCase
from src.modules.courses.application.update_course import UpdateCourseUseCase
from src.modules.courses.application.delete_course import DeleteCourseUseCase
from src.modules.courses.application.get_course_by_slug import GetCourseBySlugUseCase
from src.core.exceptions import EntityNotFoundException, AccessDeniedException, DomainException

router = APIRouter(prefix="/api/courses", tags=["courses"])

@router.get("/slug/{slug}")
async def get_course_by_slug(slug: str, current_user: dict = Depends(get_current_user)):
    """Retorna os detalhes completos de um curso pelo Slug."""
    try:
        course = GetCourseBySlugUseCase.execute(slug)
        return course.model_dump()
    except EntityNotFoundException as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=e.message)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ocorreu um erro interno no processamento dos dados."
        )

@router.get("", response_model=List[dict])
async def get_published_courses(current_user: dict = Depends(get_current_user)):
    """Retorna todos os cursos publicados e não deletados."""
    try:
        courses = ListCoursesUseCase.execute()
        return [course.model_dump() for course in courses]
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ocorreu um erro interno no processamento dos dados."
        )

@router.get("/{course_id}")
async def get_course_details(course_id: str, current_user: dict = Depends(get_current_user)):
    """Retorna os detalhes completos de um curso pelo ID."""
    try:
        course = GetCourseUseCase.execute(course_id)
        return course.model_dump()
    except EntityNotFoundException as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=e.message)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ocorreu um erro interno no processamento dos dados."
        )

@router.post("", status_code=status.HTTP_201_CREATED)
async def create_course(
    course_data: CourseCreateSchema,
    current_user: dict = Depends(require_role(["teacher", "admin"]))
):
    """Cria um novo curso no sistema. Apenas Professores e Admins."""
    try:
        course = CreateCourseUseCase.execute(
            course_data=course_data.model_dump(),
            instructor_id=current_user["id"]
        )
        return course.model_dump()
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ocorreu um erro interno ao criar o curso."
        )

@router.put("/{course_id}")
async def update_course(
    course_id: str,
    course_data: CourseCreateSchema,
    current_user: dict = Depends(require_role(["teacher", "admin"]))
):
    """Atualiza as informações de um curso existente. Apenas instrutor do curso ou Admins."""
    try:
        course = UpdateCourseUseCase.execute(
            course_id=course_id,
            course_data=course_data.model_dump(),
            current_user=current_user
        )
        return course.model_dump()
    except AccessDeniedException as e:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=e.message)
    except EntityNotFoundException as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=e.message)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ocorreu um erro interno ao atualizar o curso."
        )

@router.delete("/{course_id}")
async def soft_delete_course(
    course_id: str,
    current_user: dict = Depends(require_role(["teacher", "admin"]))
):
    """Arquiva logicamente um curso. Apenas instrutor do curso ou Admins."""
    try:
        DeleteCourseUseCase.execute(course_id=course_id, current_user=current_user)
        return {"status": "success", "message": "Curso arquivado logicamente com sucesso."}
    except AccessDeniedException as e:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=e.message)
    except EntityNotFoundException as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=e.message)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ocorreu um erro interno ao tentar arquivar o curso."
        )
