from pydantic import BaseModel, ConfigDict, Field


class CourseCreateSchema(BaseModel):
    """Payload de validação para criação ou atualização de Cursos."""

    model_config = ConfigDict(frozen=True, extra="forbid")

    title: str = Field(..., min_length=3, max_length=255, description="Título do curso")
    slug: str = Field(
        ..., min_length=3, max_length=255, description="Slug legível único"
    )
    category: str = Field("costura", description="Categoria principal")
    level: str = Field("iniciante", description="Nível de dificuldade")
    summary: str = Field("", description="Breve resumo comercial do curso")
    status: str = Field("draft", description="Status de publicação")
