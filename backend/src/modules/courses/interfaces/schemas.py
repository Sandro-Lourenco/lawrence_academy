from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class CourseCreateSchema(BaseModel):
    """Payload de validação para criação ou atualização de Cursos."""

    model_config = ConfigDict(frozen=True, extra="forbid")

    title: str = Field(..., min_length=3, max_length=255, description="Título do curso")
    slug: str = Field(..., min_length=3, max_length=255, description="Slug legível único")
    category: str = Field("costura", description="Categoria principal")
    level: str = Field("iniciante", description="Nível de dificuldade")
    summary: str = Field("", description="Breve resumo comercial do curso")
    course_type: Literal["complete", "quick", "workshop"] = "complete"
    subtitle: str = Field("", max_length=160)
    language: Literal["pt-BR", "en", "es"] = "pt-BR"
    estimated_duration_minutes: int | None = Field(default=None, ge=1, le=100000)
    learning_objectives: list[str] = Field(default_factory=list, max_length=20)
    target_audience: list[str] = Field(default_factory=list, max_length=20)
    required_materials: list[str] = Field(default_factory=list, max_length=20)
    competencies: list[str] = Field(default_factory=list, max_length=20)
    expected_outcomes: list[str] = Field(default_factory=list, max_length=20)
    status: str = Field("draft", description="Status de publicação")
