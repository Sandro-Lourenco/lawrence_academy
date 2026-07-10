from fastapi import APIRouter, Depends, status
from src.core.security.security import get_current_user, require_role, CurrentUser
from src.core.database.database import get_admin_supabase_client
from src.modules.courses.infrastructure.repositories.supabase_course_repository import (
    SupabaseCourseRepository,
)
from src.modules.courses.application.use_cases.list_courses_use_case import (
    ListCoursesUseCase,
)
from src.modules.courses.application.use_cases.get_course_use_case import (
    GetCourseUseCase,
)
from src.modules.courses.application.use_cases.get_course_by_slug_use_case import (
    GetCourseBySlugUseCase,
)
from src.modules.courses.application.use_cases.create_course_use_case import (
    CreateCourseUseCase,
)
from src.modules.courses.application.use_cases.update_course_use_case import (
    UpdateCourseUseCase,
)
from src.modules.courses.application.use_cases.delete_course_use_case import (
    DeleteCourseUseCase,
)
from src.modules.courses.interfaces.schemas import CourseCreateSchema

router = APIRouter(prefix="/api/courses", tags=["courses"])


def _to_legacy_dict(course):
    return {
        "id": course.id,
        "instructor_id": course.instructor_id,
        "title": course.title,
        "slug": course.slug,
        "category": course.category,
        "level": course.level,
        "summary": course.summary,
        "description": course.description,
        "requirements": course.requirements,
        "thumbnail_url": course.thumbnail_url,
        "trailer_hls_path": course.trailer_hls_path,
        "monthly_price": float(course.monthly_price),
        "status": course.status,
        "modules": [
            {
                "id": m.id,
                "course_id": m.course_id,
                "title": m.title,
                "order_index": m.order_index,
                "lessons": [
                    {
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
                    for lesson in m.lessons
                ],
            }
            for m in course.modules
        ],
    }


@router.get("/slug/{slug}")
async def get_course_by_slug(
    slug: str, current_user: CurrentUser = Depends(get_current_user)
):
    """Retorna os detalhes completos de um curso pelo Slug (Legacy route redirection)."""
    repo = SupabaseCourseRepository(get_admin_supabase_client())
    use_case = GetCourseBySlugUseCase(repo)
    course = await use_case.execute(slug)
    return _to_legacy_dict(course)


@router.get("", response_model=list[dict])
async def get_published_courses(current_user: CurrentUser = Depends(get_current_user)):
    """Retorna todos os cursos publicados e não deletados (Legacy route redirection)."""
    repo = SupabaseCourseRepository(get_admin_supabase_client())
    use_case = ListCoursesUseCase(repo)
    courses = await use_case.execute()
    return [_to_legacy_dict(course) for course in courses]


@router.get("/{course_id}")
async def get_course_details(
    course_id: str, current_user: CurrentUser = Depends(get_current_user)
):
    """Retorna os detalhes completos de um curso pelo ID (Legacy route redirection)."""
    repo = SupabaseCourseRepository(get_admin_supabase_client())
    use_case = GetCourseUseCase(repo)
    course = await use_case.execute(course_id)
    return _to_legacy_dict(course)


@router.post("", status_code=status.HTTP_201_CREATED)
async def create_course(
    course_data: CourseCreateSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "admin"])),
):
    """Cria um novo curso no sistema. Apenas Professores e Admins (Legacy route redirection)."""
    repo = SupabaseCourseRepository(get_admin_supabase_client())
    use_case = CreateCourseUseCase(repo)
    course = await use_case.execute(course_data.model_dump(), current_user.id)
    return _to_legacy_dict(course)


@router.put("/{course_id}")
async def update_course(
    course_id: str,
    course_data: CourseCreateSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "admin"])),
):
    """Atualiza as informações de um curso existente (Legacy route redirection)."""
    repo = SupabaseCourseRepository(get_admin_supabase_client())
    use_case = UpdateCourseUseCase(repo)
    course = await use_case.execute(
        course_id=course_id,
        course_data=course_data.model_dump(),
        current_user_id=current_user.id,
        current_user_role=current_user.role,
    )
    return _to_legacy_dict(course)


@router.delete("/{course_id}")
async def soft_delete_course(
    course_id: str,
    current_user: CurrentUser = Depends(require_role(["teacher", "admin"])),
):
    """Arquiva logicamente um curso. Apenas instrutor do curso ou Admins (Legacy route redirection)."""
    repo = SupabaseCourseRepository(get_admin_supabase_client())
    use_case = DeleteCourseUseCase(repo)
    await use_case.execute(
        course_id=course_id,
        current_user_id=current_user.id,
        current_user_role=current_user.role,
    )
    return {"status": "success", "message": "Curso arquivado logicamente com sucesso."}
