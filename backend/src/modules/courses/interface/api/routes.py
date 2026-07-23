from fastapi import APIRouter, Depends, status
from typing import Annotated, List, Literal, Optional
from decimal import Decimal
from pydantic import BaseModel, Field
from src.core.security.security import get_current_user, require_role, CurrentUser
from src.modules.courses.domain.repositories import CourseRepository
from src.modules.courses.interface.api.dependencies import get_course_repository
from src.modules.courses.application.use_cases.list_courses_use_case import (
    ListCoursesUseCase,
)
from src.modules.courses.application.use_cases.get_course_use_case import (
    GetCourseUseCase,
)
from src.modules.courses.application.use_cases.get_course_by_slug_use_case import (
    GetCourseBySlugUseCase,
)
from src.modules.courses.application.use_cases.get_lesson_use_case import (
    GetLessonUseCase,
)
from src.modules.courses.application.use_cases.get_lesson_stream_use_case import (
    GetLessonStreamUseCase,
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

router = APIRouter(prefix="/api/v1/courses", tags=["courses"])

PlanningItem = Annotated[str, Field(min_length=2, max_length=240)]


class LessonCreateInputSchema(BaseModel):
    id: str
    module_id: str
    course_id: str
    title: str
    description: Optional[str] = None
    order_index: int
    duration_seconds: int
    hls_storage_path: Optional[str] = None
    material_pdf_url: Optional[str] = None
    status: str


class LessonResponseSchema(BaseModel):
    id: str
    module_id: str
    course_id: str
    title: str
    description: Optional[str] = None
    order_index: int
    duration_seconds: int
    hls_storage_path: Optional[str] = None
    material_pdf_url: Optional[str] = None
    status: str


class ModuleResponseSchema(BaseModel):
    id: str
    course_id: str
    title: str
    order_index: int
    lessons: List[LessonResponseSchema]


class CourseCreateInputSchema(BaseModel):
    title: str = Field(min_length=3, max_length=120)
    slug: str = Field(min_length=3, max_length=255, pattern=r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
    summary: str = Field(min_length=10, max_length=240)
    course_type: Literal["complete", "quick", "workshop"] = "complete"
    subtitle: str = Field(default="", max_length=160)
    language: Literal["pt-BR", "en", "es"] = "pt-BR"
    estimated_duration_minutes: Optional[int] = Field(default=None, ge=1, le=100000)
    category: Optional[str] = "costura"
    level: Optional[str] = "iniciante"
    description: Optional[str] = Field(default=None, max_length=5000)
    requirements: List[PlanningItem] = Field(default_factory=list, max_length=20)
    learning_objectives: List[PlanningItem] = Field(default_factory=list, max_length=20)
    target_audience: List[PlanningItem] = Field(default_factory=list, max_length=20)
    required_materials: List[PlanningItem] = Field(default_factory=list, max_length=20)
    competencies: List[PlanningItem] = Field(default_factory=list, max_length=20)
    expected_outcomes: List[PlanningItem] = Field(default_factory=list, max_length=20)
    thumbnail_url: Optional[str] = None
    trailer_hls_path: Optional[str] = None
    monthly_price: Decimal
    status: Optional[str] = "draft"


class CourseResponseSchema(BaseModel):
    id: str
    instructor_id: str
    title: str
    slug: str
    category: str
    level: str
    summary: str
    course_type: str = "complete"
    subtitle: str = ""
    language: str = "pt-BR"
    estimated_duration_minutes: Optional[int] = None
    description: Optional[str] = None
    requirements: List[str]
    learning_objectives: List[str] = Field(default_factory=list)
    target_audience: List[str] = Field(default_factory=list)
    required_materials: List[str] = Field(default_factory=list)
    competencies: List[str] = Field(default_factory=list)
    expected_outcomes: List[str] = Field(default_factory=list)
    thumbnail_url: Optional[str] = None
    trailer_hls_path: Optional[str] = None
    monthly_price: Decimal
    status: str
    modules: List[ModuleResponseSchema] = []


@router.get("", response_model=List[CourseResponseSchema])
async def list_courses(
    repo: CourseRepository = Depends(get_course_repository),
):
    """Retorna todos os cursos publicados ativos (BOLA-safe)."""
    use_case = ListCoursesUseCase(repo)
    courses = await use_case.execute()
    return courses


@router.get("/slug/{slug}", response_model=CourseResponseSchema)
async def get_course_by_slug(
    slug: str,
    repo: CourseRepository = Depends(get_course_repository),
):
    """Retorna detalhes do curso pelo slug amigável (BOLA-safe)."""
    use_case = GetCourseBySlugUseCase(repo)
    course = await use_case.execute(slug)
    return course


@router.get("/{course_id}", response_model=CourseResponseSchema)
async def get_course(
    course_id: str,
    repo: CourseRepository = Depends(get_course_repository),
):
    """Retorna detalhes completos do curso pelo seu UUID (BOLA-safe)."""
    use_case = GetCourseUseCase(repo)
    course = await use_case.execute(course_id)
    return course


@router.post("", response_model=CourseResponseSchema, status_code=status.HTTP_201_CREATED)
async def create_course(
    payload: CourseCreateInputSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "admin"])),
    repo: CourseRepository = Depends(get_course_repository),
):
    """Cria um novo curso no sistema (BOLA-safe). Apenas Professores e Admins."""
    use_case = CreateCourseUseCase(repo)
    course = await use_case.execute(payload.model_dump(), current_user.id)
    return course


@router.put("/{course_id}", response_model=CourseResponseSchema)
async def update_course(
    course_id: str,
    payload: CourseCreateInputSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "admin"])),
    repo: CourseRepository = Depends(get_course_repository),
):
    """Atualiza as informações de um curso existente (BOLA-safe). Apenas instrutor ou Admins."""
    use_case = UpdateCourseUseCase(repo)
    course = await use_case.execute(
        course_id=course_id,
        course_data=payload.model_dump(),
        current_user_id=current_user.id,
        current_user_role=current_user.role,
    )
    return course


@router.delete("/{course_id}")
async def delete_course(
    course_id: str,
    current_user: CurrentUser = Depends(require_role(["teacher", "admin"])),
    repo: CourseRepository = Depends(get_course_repository),
):
    """Arquiva logicamente um curso (BOLA-safe). Apenas instrutor ou Admins."""
    use_case = DeleteCourseUseCase(repo)
    await use_case.execute(
        course_id=course_id,
        current_user_id=current_user.id,
        current_user_role=current_user.role,
    )
    return {"status": "success", "message": "Curso arquivado logicamente com sucesso."}


@router.get("/{course_id}/lessons/{lesson_id}", response_model=LessonResponseSchema)
async def get_lesson(
    course_id: str,
    lesson_id: str,
    current_user: CurrentUser = Depends(get_current_user),
    repo: CourseRepository = Depends(get_course_repository),
):
    """Retorna os detalhes de uma aula específica (BOLA-safe)."""
    use_case = GetLessonUseCase(repo)
    lesson = await use_case.execute(course_id, lesson_id)
    return lesson


@router.get("/{course_id}/lessons/{lesson_id}/stream")
async def get_lesson_stream(
    course_id: str,
    lesson_id: str,
    current_user: CurrentUser = Depends(get_current_user),
    repo: CourseRepository = Depends(get_course_repository),
):
    """Gera link assinado seguro HLS para reprodução do vídeo da aula (BOLA-safe com controle de acesso)."""
    use_case = GetLessonStreamUseCase(repo)
    signed_url = await use_case.execute(
        user_id=current_user.id,
        role=current_user.role,
        course_id=course_id,
        lesson_id=lesson_id,
    )
    return {"signedUrl": signed_url}
