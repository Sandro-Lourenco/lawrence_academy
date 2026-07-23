from fastapi import APIRouter, Depends, status
from typing import Literal, Optional, List
from pydantic import BaseModel, Field
from src.core.security.security import require_role, CurrentUser
from src.core.storage.repositories import StorageRepository
from src.modules.courses.domain.repositories import CourseRepository
from src.modules.courses.interface.api.dependencies import (
    get_course_repository,
    get_storage_repository,
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
from src.modules.courses.application.use_cases.create_module_use_case import (
    CreateModuleUseCase,
)
from src.modules.courses.application.use_cases.update_module_use_case import (
    UpdateModuleUseCase,
)
from src.modules.courses.application.use_cases.delete_module_use_case import (
    DeleteModuleUseCase,
)
from src.modules.courses.application.use_cases.generate_lesson_upload_url_use_case import (
    GenerateLessonUploadUrlUseCase,
)
from src.modules.courses.application.use_cases.get_teacher_course_use_case import (
    GetTeacherCourseUseCase,
)
from src.modules.courses.application.use_cases.list_teacher_courses_use_case import (
    ListTeacherCoursesUseCase,
)
from src.modules.courses.application.use_cases.create_lesson_use_case import (
    CreateLessonUseCase,
)
from src.modules.courses.application.use_cases.update_lesson_use_case import (
    UpdateLessonUseCase,
)
from src.modules.courses.application.use_cases.delete_lesson_use_case import (
    DeleteLessonUseCase,
)
from src.modules.courses.interface.api.routes import (
    CourseResponseSchema,
    CourseCreateInputSchema,
    ModuleResponseSchema,
    LessonResponseSchema,
)


router = APIRouter(prefix="/api/v1/teacher/courses", tags=["teacher", "courses"])


class CourseUpdateInputSchema(BaseModel):
    title: Optional[str] = None
    slug: Optional[str] = None
    summary: Optional[str] = None
    course_type: Optional[Literal["complete", "quick", "workshop"]] = None
    subtitle: Optional[str] = Field(default=None, max_length=160)
    language: Optional[Literal["pt-BR", "en", "es"]] = None
    estimated_duration_minutes: Optional[int] = Field(default=None, ge=1, le=100000)
    category: Optional[str] = None
    level: Optional[str] = None
    description: Optional[str] = None
    requirements: Optional[List[str]] = None
    learning_objectives: Optional[List[str]] = Field(default=None, max_length=20)
    target_audience: Optional[List[str]] = Field(default=None, max_length=20)
    required_materials: Optional[List[str]] = Field(default=None, max_length=20)
    competencies: Optional[List[str]] = Field(default=None, max_length=20)
    expected_outcomes: Optional[List[str]] = Field(default=None, max_length=20)
    thumbnail_url: Optional[str] = None
    trailer_hls_path: Optional[str] = None
    monthly_price: Optional[float] = None
    status: Optional[str] = None


class ModuleCreateInputSchema(BaseModel):
    title: str
    order_index: Optional[int] = 0


class ModuleUpdateInputSchema(BaseModel):
    title: Optional[str] = None
    order_index: Optional[int] = None


class LessonCreateInputSchema(BaseModel):
    title: str = Field(min_length=3, max_length=255)
    description: Optional[str] = Field(default=None, max_length=5000)
    order_index: int = Field(default=0, ge=0)
    status: str = Field(default="draft", pattern="^(draft|published)$")


class LessonUpdateInputSchema(BaseModel):
    title: Optional[str] = Field(default=None, min_length=3, max_length=255)
    description: Optional[str] = Field(default=None, max_length=5000)
    order_index: Optional[int] = Field(default=None, ge=0)
    status: Optional[str] = Field(default=None, pattern="^(draft|published|hidden)$")


class UploadUrlRequestSchema(BaseModel):
    filename: str
    content_type: str
    size_bytes: int
    idempotency_key: Optional[str] = (
        None  # Chave única por tentativa (UUID recomendado)
    )


class UploadUrlResponseSchema(BaseModel):
    job_id: str  # ID do job registrado em video_processing_jobs
    signed_url: str
    path: str
    expires_in: int  # 7200 segundos = 2 horas (padrão Supabase Storage)


@router.get("", response_model=List[CourseResponseSchema])
async def list_teacher_courses(
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    """Lista somente os cursos administrÃ¡veis pelo professor autenticado."""
    use_case = ListTeacherCoursesUseCase(repository)
    return await use_case.execute(current_user.id, current_user.role)


@router.get("/{course_id}", response_model=CourseResponseSchema)
async def get_teacher_course(
    course_id: str,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    """Retorna um curso apenas ao instrutor proprietÃ¡rio ou super admin."""
    use_case = GetTeacherCourseUseCase(repository)
    return await use_case.execute(
        course_id=course_id,
        user_id=current_user.id,
        role=current_user.role,
    )


@router.post(
    "", response_model=CourseResponseSchema, status_code=status.HTTP_201_CREATED
)
async def create_course(
    payload: CourseCreateInputSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    """Cria um novo curso no sistema (BOLA-safe). Apenas Professores e Admins."""
    use_case = CreateCourseUseCase(repository)
    course = await use_case.execute(payload.model_dump(), current_user.id)
    return course


@router.patch("/{course_id}", response_model=CourseResponseSchema)
async def update_course(
    course_id: str,
    payload: CourseUpdateInputSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    """Atualiza parcialmente as informações de um curso (BOLA-safe). Apenas instrutor ou Admins."""
    use_case = UpdateCourseUseCase(repository)
    course = await use_case.execute(
        course_id=course_id,
        course_data=payload.model_dump(exclude_unset=True),
        current_user_id=current_user.id,
        current_user_role=current_user.role,
    )
    return course


@router.delete("/{course_id}")
async def delete_course(
    course_id: str,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    """Arquiva logicamente um curso (BOLA-safe). Apenas instrutor ou Admins."""
    use_case = DeleteCourseUseCase(repository)
    await use_case.execute(
        course_id=course_id,
        current_user_id=current_user.id,
        current_user_role=current_user.role,
    )
    return {"status": "success", "message": "Curso arquivado logicamente com sucesso."}


@router.post(
    "/{course_id}/modules",
    response_model=ModuleResponseSchema,
    status_code=status.HTTP_201_CREATED,
)
async def create_module(
    course_id: str,
    payload: ModuleCreateInputSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    """Cria um módulo para o curso (BOLA-safe). Apenas instrutor do curso ou Admin."""
    use_case = CreateModuleUseCase(repository)
    module = await use_case.execute(
        course_id=course_id,
        module_data=payload.model_dump(),
        current_user_id=current_user.id,
        current_user_role=current_user.role,
    )
    return module


@router.patch("/{course_id}/modules/{module_id}", response_model=ModuleResponseSchema)
async def update_module(
    course_id: str,
    module_id: str,
    payload: ModuleUpdateInputSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    """Atualiza parcialmente um módulo (BOLA-safe). Apenas instrutor ou Admin."""
    use_case = UpdateModuleUseCase(repository)
    module = await use_case.execute(
        course_id=course_id,
        module_id=module_id,
        module_data=payload.model_dump(exclude_unset=True),
        current_user_id=current_user.id,
        current_user_role=current_user.role,
    )
    return module


@router.delete("/{course_id}/modules/{module_id}")
async def delete_module(
    course_id: str,
    module_id: str,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    """Arquiva logicamente um módulo (BOLA-safe). Apenas instrutor ou Admin."""
    use_case = DeleteModuleUseCase(repository)
    await use_case.execute(
        course_id=course_id,
        module_id=module_id,
        current_user_id=current_user.id,
        current_user_role=current_user.role,
    )
    return {"status": "success", "message": "Módulo arquivado logicamente com sucesso."}


@router.post(
    "/{course_id}/modules/{module_id}/lessons",
    response_model=LessonResponseSchema,
    status_code=status.HTTP_201_CREATED,
)
async def create_lesson(
    course_id: str,
    module_id: str,
    payload: LessonCreateInputSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    use_case = CreateLessonUseCase(repository)
    return await use_case.execute(
        course_id=course_id,
        module_id=module_id,
        lesson_data=payload.model_dump(),
        current_user_id=current_user.id,
        current_user_role=current_user.role,
    )


@router.patch(
    "/{course_id}/lessons/{lesson_id}",
    response_model=LessonResponseSchema,
)
async def update_lesson(
    course_id: str,
    lesson_id: str,
    payload: LessonUpdateInputSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    use_case = UpdateLessonUseCase(repository)
    return await use_case.execute(
        course_id=course_id,
        lesson_id=lesson_id,
        lesson_data=payload.model_dump(exclude_none=True),
        current_user_id=current_user.id,
        current_user_role=current_user.role,
    )


@router.delete("/{course_id}/lessons/{lesson_id}")
async def delete_lesson(
    course_id: str,
    lesson_id: str,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    use_case = DeleteLessonUseCase(repository)
    await use_case.execute(
        course_id=course_id,
        lesson_id=lesson_id,
        current_user_id=current_user.id,
        current_user_role=current_user.role,
    )
    return {"status": "success", "message": "Aula arquivada com sucesso."}


@router.post(
    "/{course_id}/lessons/{lesson_id}/upload", response_model=UploadUrlResponseSchema
)
async def generate_upload_url(
    course_id: str,
    lesson_id: str,
    payload: UploadUrlRequestSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    course_repository: CourseRepository = Depends(get_course_repository),
    storage_repository: StorageRepository = Depends(get_storage_repository),
):
    """
    Gera uma URL pré-assinada para upload direto ao bucket raw-videos (privado).

    - Apenas instrutor do curso ou admin/super_admin podem chamar este endpoint.
    - O path do arquivo é gerado exclusivamente pelo backend (nunca pelo cliente).
    - A URL expira em 2 horas (padrão Supabase Storage; não configurável pelo SDK Python).
    - Um job é registrado em video_processing_jobs com status upload_pending.
    - A trigger do Storage atualiza o job para uploaded após o arquivo existir no bucket.
    - A lição publicada NÃO é alterada até o Worker confirmar o processamento.
    - MIME type declarado é validado aqui, mas o Worker usa ffprobe para validação real.
    - Para idempotência: enviar idempotency_key única por tentativa (UUID recomendado).
    """
    use_case = GenerateLessonUploadUrlUseCase(
        course_repository=course_repository,
        storage_repository=storage_repository,
    )
    result = await use_case.execute(
        user_id=current_user.id,
        role=current_user.role,
        course_id=course_id,
        lesson_id=lesson_id,
        filename=payload.filename,
        content_type=payload.content_type,
        size_bytes=payload.size_bytes,
        idempotency_key=payload.idempotency_key,
    )
    return result
