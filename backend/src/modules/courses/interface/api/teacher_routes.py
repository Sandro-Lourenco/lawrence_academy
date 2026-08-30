from fastapi import APIRouter, Body, Depends, Header, status
from datetime import datetime
from decimal import Decimal
from typing import Annotated, Literal, Optional, List
from pydantic import BaseModel, Field, field_validator, model_validator
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
from src.modules.courses.application.use_cases.generate_course_media_upload_url_use_case import (
    GenerateCourseMediaUploadUrlUseCase,
)
from src.modules.courses.application.use_cases.get_teacher_course_use_case import (
    GetTeacherCourseUseCase,
)
from src.modules.courses.application.use_cases.manage_lesson_block_use_case import (
    ManageLessonBlockUseCase,
)
from src.modules.courses.application.use_cases.generate_lesson_asset_upload_url_use_case import (
    GenerateLessonAssetUploadUrlUseCase,
)
from src.modules.courses.application.use_cases.publish_course_use_case import (
    CoursePublicationUseCase,
)
from src.modules.courses.application.use_cases.manage_course_lifecycle_use_case import (
    ManageCourseLifecycleUseCase,
)
from src.modules.courses.application.use_cases.list_course_versions_use_case import (
    ListCourseVersionsUseCase,
)
from src.modules.courses.application.use_cases.manage_course_version_use_case import (
    ManageCourseVersionUseCase,
)
from src.modules.courses.application.use_cases.list_teacher_courses_use_case import (
    ListTeacherCoursesUseCase,
)
from src.modules.courses.application.use_cases.list_course_students_use_case import (
    ListCourseStudentsUseCase,
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
    CourseId,
    ModuleResponseSchema,
    LessonResponseSchema,
)


router = APIRouter(prefix="/api/v1/teacher/courses", tags=["teacher", "courses"])

PlanningItem = Annotated[str, Field(min_length=2, max_length=240)]
IdempotencyKey = Annotated[
    str,
    Header(alias="Idempotency-Key", min_length=8, max_length=255),
]


class CourseVersionRestoreInputSchema(BaseModel):
    expected_authoring_updated_at: datetime
    reason: Optional[str] = Field(default=None, max_length=500)


class CoursePublishInputSchema(BaseModel):
    expected_updated_at: Optional[datetime] = None
    change_summary: Optional[str] = Field(default=None, max_length=500)


class CourseUpdateInputSchema(BaseModel):
    expected_authoring_revision: int = Field(ge=0)
    title: Optional[str] = None
    slug: Optional[str] = None
    summary: Optional[str] = None
    course_type: Optional[Literal["complete", "quick", "workshop"]] = None
    subtitle: Optional[str] = Field(default=None, max_length=160)
    language: Optional[Literal["pt-BR", "en", "es"]] = None
    estimated_duration_minutes: Optional[int] = Field(default=None, ge=1, le=100000)
    category: Optional[
        Literal[
            "corte",
            "costura",
            "modelagem",
            "fashion_design",
            "style_design",
            "mini_curso",
            "bordado",
            "negocios",
            "outros",
        ]
    ] = None
    level: Optional[str] = None
    description: Optional[str] = None
    requirements: Optional[List[PlanningItem]] = Field(default=None, max_length=20)
    prerequisite_course_ids: Optional[List[CourseId]] = Field(default=None, max_length=20)
    learning_objectives: Optional[List[PlanningItem]] = Field(default=None, max_length=20)
    target_audience: Optional[List[PlanningItem]] = Field(default=None, max_length=20)
    required_materials: Optional[List[PlanningItem]] = Field(default=None, max_length=20)
    competencies: Optional[List[PlanningItem]] = Field(default=None, max_length=20)
    expected_outcomes: Optional[List[PlanningItem]] = Field(default=None, max_length=20)
    thumbnail_url: Optional[str] = None
    trailer_hls_path: Optional[str] = None
    trailer_video_url: Optional[str] = Field(default=None, max_length=2048)
    remove_external_trailer: bool = False
    monthly_price: Optional[Decimal] = Field(default=None, ge=0, le=1000000)
    promotional_monthly_price: Optional[Decimal] = Field(default=None, ge=0)
    promotion_starts_at: Optional[datetime] = None
    promotion_ends_at: Optional[datetime] = None
    certificate_enabled: Optional[bool] = None
    reviews_enabled: Optional[bool] = None
    comments_enabled: Optional[bool] = None
    visibility: Optional[Literal["public", "private", "unlisted"]] = None
    availability: Optional[Literal["immediate", "scheduled"]] = None
    scheduled_publish_at: Optional[datetime] = None
    status: Optional[Literal["draft", "reviewing"]] = None

    @model_validator(mode="after")
    def validate_trailer_source_change(self):
        if self.trailer_video_url and self.remove_external_trailer:
            raise ValueError(
                "trailer_video_url e remove_external_trailer não podem ser usados juntos"
            )
        return self


class CourseStudentResponseSchema(BaseModel):
    id: str
    full_name: str
    email: str
    access_status: str
    enrolled_at: Optional[datetime] = None
    current_period_end: Optional[datetime] = None
    avatar_url: Optional[str] = None
    progress_percentage: float = Field(ge=0, le=100)
    completed_lessons: int = Field(ge=0)
    total_lessons: int = Field(ge=0)


class ModuleCreateInputSchema(BaseModel):
    title: str = Field(min_length=3, max_length=160)
    order_index: int = Field(default=0, ge=0)
    description: Optional[str] = Field(default=None, max_length=1000)
    status: Literal["draft", "ready"] = "draft"


class ModuleUpdateInputSchema(BaseModel):
    title: Optional[str] = Field(default=None, min_length=3, max_length=160)
    order_index: Optional[int] = Field(default=None, ge=0)
    description: Optional[str] = Field(default=None, max_length=1000)
    status: Optional[Literal["draft", "ready"]] = None


class LessonCreateInputSchema(BaseModel):
    title: str = Field(min_length=3, max_length=255)
    description: Optional[str] = Field(default=None, max_length=5000)
    order_index: int = Field(default=0, ge=0)
    status: str = Field(default="draft", pattern="^(draft|published)$")
    estimated_duration_minutes: Optional[int] = Field(default=None, ge=1, le=1440)
    is_required: bool = True
    video_url: Optional[str] = Field(default=None, max_length=2048)


class LessonUpdateInputSchema(BaseModel):
    title: Optional[str] = Field(default=None, min_length=3, max_length=255)
    description: Optional[str] = Field(default=None, max_length=5000)
    order_index: Optional[int] = Field(default=None, ge=0)
    status: Optional[str] = Field(default=None, pattern="^(draft|published|hidden)$")
    estimated_duration_minutes: Optional[int] = Field(default=None, ge=1, le=1440)
    is_required: Optional[bool] = None
    module_id: Optional[str] = None
    video_url: Optional[str] = Field(default=None, max_length=2048)
    remove_external_video: bool = False

    @model_validator(mode="after")
    def validate_video_source_change(self):
        if self.video_url and self.remove_external_video:
            raise ValueError("video_url e remove_external_video não podem ser usados juntos")
        return self


class UploadUrlRequestSchema(BaseModel):
    filename: str = Field(min_length=1, max_length=255)
    content_type: str
    size_bytes: int = Field(gt=0, le=50 * 1024 * 1024)
    idempotency_key: Optional[str] = Field(default=None, min_length=8, max_length=255)


class UploadUrlResponseSchema(BaseModel):
    job_id: str  # ID do job registrado em video_processing_jobs
    signed_url: str
    path: str
    expires_in: int  # 7200 segundos = 2 horas (padrão Supabase Storage)


class CourseMediaUploadRequestSchema(BaseModel):
    asset_type: Literal["cover", "trailer"]
    filename: str = Field(min_length=1, max_length=255)
    content_type: str
    size_bytes: int = Field(gt=0)
    alt_text: str = Field(default="", max_length=240)
    focal_x: float = Field(default=0.5, ge=0, le=1)
    focal_y: float = Field(default=0.5, ge=0, le=1)


class CourseMediaUploadResponseSchema(BaseModel):
    asset_type: str
    bucket: str
    path: str
    signed_url: str
    expires_in: int
    job_id: Optional[str] = None


BlockType = Literal[
    "video",
    "text",
    "heading",
    "pdf",
    "image",
    "gallery",
    "download",
    "audio",
    "material",
    "notice",
    "tip",
    "summary",
    "learn_more",
    "activity",
]


class BlockContentSchema(BaseModel):
    title: Optional[str] = Field(default=None, max_length=200)
    text: Optional[str] = Field(default=None, max_length=20000)
    url: Optional[str] = Field(default=None, max_length=2000)
    storage_path: Optional[str] = Field(
        default=None,
        max_length=1000,
        pattern=r"^courses/[0-9a-f-]+/lessons/[0-9a-f-]+/[0-9a-f-]+\.[a-z0-9]+$",
    )
    filename: Optional[str] = Field(default=None, max_length=255)
    content_type: Optional[str] = Field(default=None, max_length=120)
    alt_text: Optional[str] = Field(default=None, max_length=240)
    caption: Optional[str] = Field(default=None, max_length=500)
    button_label: Optional[str] = Field(default=None, max_length=80)
    items: List[str] = Field(default_factory=list, max_length=50)
    references: List[str] = Field(default_factory=list, max_length=30)
    activity_type: Optional[
        Literal[
            "single_choice",
            "multiple_choice",
            "true_false",
            "short_answer",
            "essay",
            "photo_upload",
            "pdf_upload",
            "practical",
            "project",
        ]
    ] = None
    question: Optional[str] = Field(default=None, max_length=5000)
    # Links the visual lesson block to the formal task used for grading and
    # progress. If this field is absent from the schema, Pydantic silently
    # discards the identifier received from the course wizard.
    task_id: Optional[str] = Field(
        default=None,
        pattern=(
            r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-"
            r"[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$"
        ),
    )
    # Zero-based index of the option used by the automatic grader. This must
    # be part of the API contract; undeclared Pydantic fields are discarded.
    correct_index: Optional[int] = Field(default=None, ge=0, le=49)

    @model_validator(mode="after")
    def validate_correct_index(self):
        if self.correct_index is not None and self.correct_index >= len(self.items):
            raise ValueError("A alternativa correta deve existir na lista de opções.")
        if (
            self.activity_type in {"single_choice", "multiple_choice"}
            and self.items
            and self.correct_index is None
        ):
            raise ValueError("Selecione a alternativa correta da atividade.")
        return self

    @field_validator("url")
    @classmethod
    def validate_https_url(cls, value: Optional[str]) -> Optional[str]:
        if value in (None, ""):
            return value
        assert value is not None
        if not value.startswith("https://"):
            raise ValueError("Links e arquivos externos devem usar HTTPS.")
        return value


class LessonBlockInputSchema(BaseModel):
    block_type: BlockType
    content: BlockContentSchema
    order_index: int = Field(default=0, ge=0)
    status: Literal["draft", "ready"] = "draft"


class LessonBlockPatchSchema(BaseModel):
    block_type: Optional[BlockType] = None
    content: Optional[BlockContentSchema] = None
    order_index: Optional[int] = Field(default=None, ge=0)
    status: Optional[Literal["draft", "ready"]] = None


class LessonBlockReorderSchema(BaseModel):
    block_ids: List[str] = Field(min_length=1, max_length=500)
    expected_revision: int = Field(ge=0)


class LessonAssetUploadRequestSchema(BaseModel):
    filename: str = Field(min_length=1, max_length=255)
    content_type: str
    size_bytes: int = Field(gt=0, le=104857600)


class CourseLifecycleInputSchema(BaseModel):
    reason: Optional[str] = Field(default=None, max_length=500)


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


@router.get("/{course_id}/students", response_model=List[CourseStudentResponseSchema])
async def list_course_students(
    course_id: str,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    """Lista alunos matriculados e seu progresso, com verificação de propriedade."""
    return await ListCourseStudentsUseCase(repository).execute(
        course_id=course_id,
        user_id=current_user.id,
        role=current_user.role,
    )


@router.post("", response_model=CourseResponseSchema, status_code=status.HTTP_201_CREATED)
async def create_course(
    payload: CourseCreateInputSchema,
    idempotency_key: IdempotencyKey,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    """Cria um novo curso no sistema (BOLA-safe). Apenas Professores e Admins."""
    use_case = CreateCourseUseCase(repository)
    course = await use_case.execute(
        payload.model_dump(), current_user.id, idempotency_key=idempotency_key
    )
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
        course_data=payload.model_dump(exclude_unset=True, exclude={"expected_authoring_revision"}),
        current_user_id=current_user.id,
        current_user_role=current_user.role,
        expected_authoring_revision=payload.expected_authoring_revision,
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
    idempotency_key: IdempotencyKey,
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
        idempotency_key=idempotency_key,
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
    idempotency_key: IdempotencyKey,
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
        idempotency_key=idempotency_key,
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


@router.post("/{course_id}/lessons/{lesson_id}/upload", response_model=UploadUrlResponseSchema)
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


@router.post("/{course_id}/media/upload", response_model=CourseMediaUploadResponseSchema)
async def generate_course_media_upload_url(
    course_id: str,
    payload: CourseMediaUploadRequestSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    course_repository: CourseRepository = Depends(get_course_repository),
    storage_repository: StorageRepository = Depends(get_storage_repository),
):
    """Reserva path privado para a imagem-mestre ou o trailer público."""
    use_case = GenerateCourseMediaUploadUrlUseCase(course_repository, storage_repository)
    return await use_case.execute(
        user_id=current_user.id,
        role=current_user.role,
        course_id=course_id,
        **payload.model_dump(),
    )


@router.post("/{course_id}/lessons/{lesson_id}/blocks", status_code=status.HTTP_201_CREATED)
async def create_lesson_block(
    course_id: str,
    lesson_id: str,
    payload: LessonBlockInputSchema,
    idempotency_key: IdempotencyKey,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    data = payload.model_dump()
    data["content"] = payload.content.model_dump(exclude_none=True)
    return await ManageLessonBlockUseCase(repository).create(
        course_id=course_id,
        lesson_id=lesson_id,
        data=data,
        user_id=current_user.id,
        role=current_user.role,
        idempotency_key=idempotency_key,
    )


@router.get("/{course_id}/lessons/{lesson_id}/blocks")
async def list_lesson_blocks(
    course_id: str,
    lesson_id: str,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    use_case = ManageLessonBlockUseCase(repository)
    return await use_case.list(
        course_id=course_id,
        lesson_id=lesson_id,
        user_id=current_user.id,
        role=current_user.role,
    )


@router.post("/{course_id}/lessons/{lesson_id}/assets/upload")
async def generate_lesson_asset_upload_url(
    course_id: str,
    lesson_id: str,
    payload: LessonAssetUploadRequestSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    course_repository: CourseRepository = Depends(get_course_repository),
    storage_repository: StorageRepository = Depends(get_storage_repository),
):
    return await GenerateLessonAssetUploadUrlUseCase(course_repository, storage_repository).execute(
        course_id=course_id,
        lesson_id=lesson_id,
        user_id=current_user.id,
        role=current_user.role,
        **payload.model_dump(),
    )


@router.patch("/{course_id}/lessons/{lesson_id}/blocks/{block_id}")
async def update_lesson_block(
    course_id: str,
    lesson_id: str,
    block_id: str,
    payload: LessonBlockPatchSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    data = payload.model_dump(exclude_unset=True)
    if payload.content is not None:
        data["content"] = payload.content.model_dump(exclude_none=True)
    return await ManageLessonBlockUseCase(repository).update(
        course_id=course_id,
        lesson_id=lesson_id,
        block_id=block_id,
        data=data,
        user_id=current_user.id,
        role=current_user.role,
    )


@router.post(
    "/{course_id}/lessons/{lesson_id}/blocks/{block_id}/duplicate",
    status_code=status.HTTP_201_CREATED,
)
async def duplicate_lesson_block(
    course_id: str,
    lesson_id: str,
    block_id: str,
    idempotency_key: IdempotencyKey,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    return await ManageLessonBlockUseCase(repository).duplicate(
        course_id=course_id,
        lesson_id=lesson_id,
        block_id=block_id,
        user_id=current_user.id,
        role=current_user.role,
        idempotency_key=idempotency_key,
    )


@router.put("/{course_id}/lessons/{lesson_id}/blocks/reorder")
async def reorder_lesson_blocks(
    course_id: str,
    lesson_id: str,
    payload: LessonBlockReorderSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    return await ManageLessonBlockUseCase(repository).reorder(
        course_id=course_id,
        lesson_id=lesson_id,
        block_ids=payload.block_ids,
        expected_revision=payload.expected_revision,
        user_id=current_user.id,
        role=current_user.role,
    )


@router.delete("/{course_id}/lessons/{lesson_id}/blocks/{block_id}")
async def delete_lesson_block(
    course_id: str,
    lesson_id: str,
    block_id: str,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    await ManageLessonBlockUseCase(repository).delete(
        course_id=course_id,
        lesson_id=lesson_id,
        block_id=block_id,
        user_id=current_user.id,
        role=current_user.role,
    )
    return {"status": "success"}


@router.get("/{course_id}/publication-checklist")
async def get_publication_checklist(
    course_id: str,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    return await CoursePublicationUseCase(repository).checklist(
        course_id=course_id, user_id=current_user.id, role=current_user.role
    )


@router.post("/{course_id}/publish", response_model=CourseResponseSchema)
async def publish_course(
    course_id: str,
    idempotency_key: IdempotencyKey,
    payload: Optional[CoursePublishInputSchema] = Body(default=None),
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    """Publicação idempotente, autorizada e condicionada ao checklist server-side."""
    return await CoursePublicationUseCase(repository).publish(
        course_id=course_id,
        user_id=current_user.id,
        role=current_user.role,
        idempotency_key=idempotency_key,
        expected_updated_at=(
            payload.expected_updated_at.isoformat()
            if payload and payload.expected_updated_at
            else None
        ),
        change_summary=payload.change_summary if payload else None,
    )


@router.get("/{course_id}/versions")
async def list_course_versions(
    course_id: str,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    return await ListCourseVersionsUseCase(repository).execute(
        course_id=course_id,
        user_id=current_user.id,
        role=current_user.role,
    )


@router.get("/{course_id}/versions/{version_id}")
async def get_course_version(
    course_id: str,
    version_id: str,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    return await ManageCourseVersionUseCase(repository).detail(
        course_id=course_id,
        version_id=version_id,
        user_id=current_user.id,
        role=current_user.role,
    )


@router.post("/{course_id}/versions/{version_id}/restore", response_model=CourseResponseSchema)
async def restore_course_version(
    course_id: str,
    version_id: str,
    payload: CourseVersionRestoreInputSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    return await ManageCourseVersionUseCase(repository).restore(
        course_id=course_id,
        version_id=version_id,
        user_id=current_user.id,
        role=current_user.role,
        expected_updated_at=payload.expected_authoring_updated_at.isoformat(),
        reason=payload.reason,
    )


async def _transition_course(
    course_id: str,
    target_status: str,
    payload: CourseLifecycleInputSchema,
    current_user: CurrentUser,
    repository: CourseRepository,
):
    return await ManageCourseLifecycleUseCase(repository).execute(
        course_id=course_id,
        user_id=current_user.id,
        role=current_user.role,
        target_status=target_status,
        reason=payload.reason,
    )


@router.post("/{course_id}/unpublish")
async def unpublish_course(
    course_id: str,
    payload: CourseLifecycleInputSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    return await _transition_course(course_id, "unpublished", payload, current_user, repository)


@router.post("/{course_id}/archive")
async def archive_course(
    course_id: str,
    payload: CourseLifecycleInputSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    return await _transition_course(course_id, "archived", payload, current_user, repository)


@router.post("/{course_id}/restore")
async def restore_course(
    course_id: str,
    payload: CourseLifecycleInputSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "super_admin"])),
    repository: CourseRepository = Depends(get_course_repository),
):
    return await _transition_course(course_id, "unpublished", payload, current_user, repository)
