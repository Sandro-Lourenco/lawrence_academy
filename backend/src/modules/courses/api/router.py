from fastapi import APIRouter, Depends
from typing import List
from src.core.security.security import get_current_user, CurrentUser
from src.core.database.database import get_admin_supabase_client
from src.modules.courses.infrastructure.repositories.supabase_course_repository import (
    SupabaseCourseRepository,
)
from src.modules.courses.application.use_cases.list_courses_use_case import (
    ListCoursesUseCase,
)
from src.modules.courses.application.use_cases.get_lesson_use_case import (
    GetLessonUseCase,
)
from src.modules.courses.application.use_cases.get_lesson_stream_use_case import (
    GetLessonStreamUseCase,
)
from src.modules.courses.api.schemas import CourseResponseSchema, LessonResponseSchema

router = APIRouter(prefix="/courses", tags=["courses"])


@router.get("", response_model=List[CourseResponseSchema])
async def list_courses(current_user: CurrentUser = Depends(get_current_user)):
    """Retorna a lista de todos os cursos ativos cadastrados no sistema (Legacy route redirection)."""
    repo = SupabaseCourseRepository(get_admin_supabase_client())
    use_case = ListCoursesUseCase(repo)
    courses = await use_case.execute()
    return [
        {
            "id": c.id,
            "instructor_id": c.instructor_id,
            "title": c.title,
            "slug": c.slug,
            "category": c.category,
            "level": c.level,
            "summary": c.summary,
            "monthly_price": float(c.monthly_price),
            "status": c.status,
        }
        for c in courses
    ]


@router.get("/{id}/lessons/{lesson_id}", response_model=LessonResponseSchema)
async def get_lesson(
    id: str, lesson_id: str, current_user: CurrentUser = Depends(get_current_user)
):
    """Retorna os detalhes de uma aula específica associada a um curso (Legacy route redirection)."""
    repo = SupabaseCourseRepository(get_admin_supabase_client())
    use_case = GetLessonUseCase(repo)
    lesson = await use_case.execute(course_id=id, lesson_id=lesson_id)
    return {
        "id": lesson.id,
        "module_id": lesson.module_id,
        "course_id": lesson.course_id,
        "title": lesson.title,
        "description": lesson.description,
        "order_index": lesson.order_index,
        "duration_seconds": lesson.duration_seconds,
        "hls_storage_path": lesson.hls_storage_path,
        "material_pdf_url": lesson.material_pdf_url,
        "status": lesson.status,
    }


@router.get("/{id}/lessons/{lesson_id}/stream")
async def get_lesson_stream(
    id: str, lesson_id: str, current_user: CurrentUser = Depends(get_current_user)
):
    """Retorna a URL do manifesto HLS assinada de forma segura (Legacy route redirection)."""
    repo = SupabaseCourseRepository(get_admin_supabase_client())
    use_case = GetLessonStreamUseCase(repo)
    signed_url = await use_case.execute(
        user_id=current_user.id,
        role=current_user.role,
        course_id=id,
        lesson_id=lesson_id,
    )
    return {
        "status": "success",
        "data": {
            "lesson_id": lesson_id,
            "hls_manifest_url": signed_url,
            "expires_in_seconds": 3600,
            "watermark_text": f"{current_user.email}",
        },
    }
