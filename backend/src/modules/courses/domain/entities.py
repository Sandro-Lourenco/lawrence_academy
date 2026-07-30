from dataclasses import dataclass, field
from typing import List, Optional
from decimal import Decimal
from datetime import datetime


@dataclass(frozen=True)
class LessonBlock:
    id: str
    lesson_id: str
    course_id: str
    block_type: str
    content: dict
    order_index: int = 0
    status: str = "draft"
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


@dataclass(frozen=True)
class Lesson:
    """Entidade do conteúdo em vídeo (Aula) pertencente a um módulo (Domínio Puro)."""

    id: str
    module_id: str
    course_id: str
    title: str
    hls_storage_path: Optional[str]
    video_job_status: Optional[str] = None
    description: Optional[str] = None
    order_index: int = 0
    duration_seconds: int = 0
    estimated_duration_minutes: Optional[int] = None
    is_required: bool = True
    material_pdf_url: Optional[str] = None
    status: str = "draft"
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    blocks: List[LessonBlock] = field(default_factory=list)


@dataclass(frozen=True)
class Module:
    """Entidade de Módulo que agrupa aulas em um Curso (Domínio Puro)."""

    id: str
    course_id: str
    title: str
    order_index: int = 0
    description: Optional[str] = None
    status: str = "draft"
    updated_at: Optional[datetime] = None
    created_at: Optional[datetime] = None
    deleted_at: Optional[datetime] = None
    lessons: List[Lesson] = field(default_factory=list)


@dataclass(frozen=True)
class Course:
    """Entidade de Curso - Raiz do Agregado de Conteúdo (Domínio Puro)."""

    id: str
    instructor_id: str
    title: str
    slug: str
    summary: str
    course_type: str = "complete"
    subtitle: str = ""
    language: str = "pt-BR"
    estimated_duration_minutes: Optional[int] = None
    category: str = "costura"
    level: str = "iniciante"
    description: Optional[str] = None
    requirements: List[str] = field(default_factory=list)
    learning_objectives: List[str] = field(default_factory=list)
    target_audience: List[str] = field(default_factory=list)
    required_materials: List[str] = field(default_factory=list)
    competencies: List[str] = field(default_factory=list)
    expected_outcomes: List[str] = field(default_factory=list)
    thumbnail_url: Optional[str] = None
    trailer_hls_path: Optional[str] = None
    cover_image_path: Optional[str] = None
    cover_alt_text: Optional[str] = None
    cover_focal_x: float = 0.5
    cover_focal_y: float = 0.5
    cover_status: str = "empty"
    trailer_status: str = "empty"
    monthly_price: Decimal = Decimal("0.00")
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
    status: str = "draft"
    authoring_revision: int = 0
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    deleted_at: Optional[datetime] = None
    modules: List[Module] = field(default_factory=list)
