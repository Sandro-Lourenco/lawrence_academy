from pathlib import PurePosixPath
import re
from urllib.parse import quote

import jwt
from fastapi import APIRouter, Depends, Header, HTTPException, Query, Request, Response, status
from fastapi.responses import RedirectResponse
from typing import Annotated, List, Literal, Optional
from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel, Field
from src.core.security.security import get_current_user, require_role, CurrentUser
from src.core.security.jwt_playback_service import JwtPlaybackService
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


class LessonBlockResponseSchema(BaseModel):
    id: str
    lesson_id: str
    course_id: str
    block_type: str
    content: dict
    order_index: int = 0
    status: str


class LessonResponseSchema(BaseModel):
    id: str
    module_id: str
    course_id: str
    title: str
    description: Optional[str] = None
    order_index: int
    duration_seconds: int
    estimated_duration_minutes: Optional[int] = None
    is_required: bool = True
    hls_storage_path: Optional[str] = None
    video_job_status: Optional[str] = None
    material_pdf_url: Optional[str] = None
    status: str
    blocks: List[LessonBlockResponseSchema] = Field(default_factory=list)


class ModuleResponseSchema(BaseModel):
    id: str
    course_id: str
    title: str
    order_index: int
    description: Optional[str] = None
    status: str = "draft"
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
    cover_image_path: Optional[str] = None
    cover_alt_text: Optional[str] = None
    cover_focal_x: float = 0.5
    cover_focal_y: float = 0.5
    trailer_status: str = "empty"
    monthly_price: Decimal = Field(ge=0, le=1000000)
    promotional_monthly_price: Optional[Decimal] = Field(default=None, ge=0)
    promotion_starts_at: Optional[datetime] = None
    promotion_ends_at: Optional[datetime] = None
    certificate_enabled: bool = True
    reviews_enabled: bool = True
    comments_enabled: bool = True
    visibility: Literal["public", "private", "unlisted"] = "public"
    availability: Literal["immediate", "scheduled"] = "immediate"
    scheduled_publish_at: Optional[datetime] = None
    status: Literal["draft"] = "draft"


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
    cover_image_path: Optional[str] = None
    cover_alt_text: Optional[str] = None
    cover_focal_x: float = 0.5
    cover_focal_y: float = 0.5
    trailer_status: str = "empty"
    cover_status: str = "empty"
    monthly_price: Decimal
    promotional_monthly_price: Optional[Decimal] = None
    promotion_starts_at: Optional[datetime] = None
    promotion_ends_at: Optional[datetime] = None
    certificate_enabled: bool = True
    reviews_enabled: bool = True
    comments_enabled: bool = True
    visibility: str = "public"
    availability: str = "immediate"
    scheduled_publish_at: Optional[datetime] = None
    is_featured: bool = False
    status: str
    authoring_revision: int = 0
    modules: List[ModuleResponseSchema] = []


@router.get("", response_model=List[CourseResponseSchema])
async def list_courses(
    limit: int = Query(default=50, ge=1, le=50),
    repo: CourseRepository = Depends(get_course_repository),
):
    """Retorna uma página limitada de cursos publicados ativos."""
    use_case = ListCoursesUseCase(repo)
    courses = await use_case.execute(limit=limit)
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
    expected_authoring_revision: int = Header(alias="If-Match-Authoring-Revision", ge=0),
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
        expected_authoring_revision=expected_authoring_revision,
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
    lesson = await use_case.execute(
        current_user.id,
        current_user.role,
        course_id,
        lesson_id,
    )
    return lesson


@router.get("/{course_id}/lessons/{lesson_id}/stream")
async def get_lesson_stream(
    course_id: str,
    lesson_id: str,
    request: Request,
    current_user: CurrentUser = Depends(get_current_user),
    repo: CourseRepository = Depends(get_course_repository),
):
    """Returns an authenticated HLS proxy URL; child manifests keep the JWT header."""
    use_case = GetLessonStreamUseCase(repo)
    master_path = await use_case.authorize_and_get_path(
        user_id=current_user.id,
        role=current_user.role,
        course_id=course_id,
        lesson_id=lesson_id,
    )
    token = JwtPlaybackService().generate(
        user_id=current_user.id,
        course_id=course_id,
        lesson_id=lesson_id,
        master_path=master_path,
    )
    playback_url = request.url_for(
        "get_lesson_hls_asset",
        course_id=course_id,
        lesson_id=lesson_id,
        asset_path="master.m3u8",
    )
    # Return an origin-relative URL. Reverse proxies commonly expose FastAPI
    # through HTTPS while the application itself sees an internal HTTP hop.
    # Serializing request.url_for() in that setup creates a mixed-content URL
    # which browsers reject before loading the first HLS manifest. The client
    # already knows the canonical API origin and resolves this path against it.
    return {"signedUrl": f"{playback_url.path}?token={quote(token, safe='')}"}


@router.get(
    "/{course_id}/lessons/{lesson_id}/hls/{asset_path:path}",
    name="get_lesson_hls_asset",
)
async def get_lesson_hls_asset(
    course_id: str,
    lesson_id: str,
    asset_path: str,
    token: str = Query(min_length=20),
    repo: CourseRepository = Depends(get_course_repository),
) -> Response:
    try:
        playback = JwtPlaybackService().validate(
            token,
            course_id=course_id,
            lesson_id=lesson_id,
        )
    except jwt.PyJWTError as exc:
        raise HTTPException(status_code=401, detail="Sessão de vídeo inválida.") from exc

    requested = PurePosixPath(asset_path)
    if (
        requested.is_absolute()
        or ".." in requested.parts
        or requested.suffix.lower() not in {".m3u8", ".ts", ".vtt", ".key", ".bin"}
    ):
        raise HTTPException(status_code=404, detail="Mídia não encontrada.")

    master_path = playback.get("master_path")
    if not isinstance(master_path, str) or not master_path:
        raise HTTPException(status_code=404, detail="Mídia não encontrada.")
    storage_path = str(PurePosixPath(master_path).parent / requested)
    if requested.suffix.lower() != ".m3u8":
        signed_url = await repo.generate_signed_url(storage_path)
        return RedirectResponse(
            signed_url,
            status_code=status.HTTP_307_TEMPORARY_REDIRECT,
            headers={"Cache-Control": "private, max-age=60"},
        )

    content = await repo.download_hls_asset(storage_path)
    media_type = {
        ".m3u8": "application/vnd.apple.mpegurl",
        ".ts": "video/mp2t",
        ".vtt": "text/vtt",
    }[requested.suffix.lower()]
    if requested.suffix.lower() == ".m3u8":
        text = content.decode("utf-8")
        text = "\n".join(
            line if not line or line.startswith("#") else _append_playback_token(line, token)
            for line in text.splitlines()
        )
        text = re.sub(
            r'URI="([^"]+)"',
            lambda match: f'URI="{_append_playback_token(match.group(1), token)}"',
            text,
        )
        content = text.encode("utf-8")
    return Response(
        content=content,
        media_type=media_type,
        headers={"Cache-Control": "private, max-age=60"},
    )


def _append_playback_token(uri: str, token: str) -> str:
    separator = "&" if "?" in uri else "?"
    return f"{uri}{separator}token={quote(token, safe='')}"
