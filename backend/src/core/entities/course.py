from pydantic import BaseModel, ConfigDict, Field
from typing import List, Optional
from decimal import Decimal
from datetime import datetime

class Lesson(BaseModel):
    """Entidade do conteúdo em vídeo (Aula) pertencente a um módulo."""
    model_config = ConfigDict(frozen=True, extra="forbid")

    id: str = Field(..., description="UUID único da aula")
    module_id: str = Field(..., description="UUID do módulo associado")
    course_id: str = Field(..., description="UUID do curso associado")
    title: str = Field(..., description="Título da aula")
    description: Optional[str] = Field(None, description="Descrição detalhada")
    order_index: int = Field(0, description="Índice de ordenação da aula no módulo")
    duration_seconds: int = Field(0, description="Duração do vídeo em segundos")
    hls_storage_path: str = Field(..., description="Caminho no storage protegido para o arquivo .m3u8")
    material_pdf_url: Optional[str] = Field(None, description="Caminho/URL do material complementar em PDF")
    status: str = Field("draft", description="Status do conteúdo (draft, reviewing, published, archived)")
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class Module(BaseModel):
    """Entidade de Módulo que agrupa aulas em um Curso."""
    model_config = ConfigDict(frozen=True, extra="forbid")

    id: str = Field(..., description="UUID único do módulo")
    course_id: str = Field(..., description="UUID do curso associado")
    title: str = Field(..., description="Título do módulo")
    order_index: int = Field(0, description="Índice de ordenação do módulo no curso")
    created_at: Optional[datetime] = None
    lessons: List[Lesson] = Field(default_factory=list, description="Lista de aulas contidas neste módulo")

class Course(BaseModel):
    """Entidade de Curso (Raiz do Agregado de Conteúdo)."""
    model_config = ConfigDict(frozen=True, extra="forbid")

    id: str = Field(..., description="UUID único do curso")
    instructor_id: str = Field(..., description="UUID do instrutor que criou o curso")
    title: str = Field(..., description="Título do curso")
    slug: str = Field(..., description="Slug único amigável do curso")
    category: str = Field("costura", description="Categoria do curso")
    level: str = Field("iniciante", description="Nível de dificuldade do curso")
    summary: str = Field(..., description="Breve resumo comercial do curso")
    description: Optional[str] = Field(None, description="Descrição longa do curso")
    requirements: Optional[List[str]] = Field(default_factory=list, description="Pré-requisitos de tecidos/máquinas")
    thumbnail_url: Optional[str] = Field(None, description="Caminho/URL da imagem de capa")
    trailer_hls_path: Optional[str] = Field(None, description="Caminho do trailer HLS no storage")
    monthly_price: Decimal = Field(Decimal("0.00"), description="Preço da mensalidade do curso")
    status: str = Field("draft", description="Status de publicação (draft, reviewing, published, archived)")
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    deleted_at: Optional[datetime] = Field(None, description="Timestamp de arquivamento lógico")
    modules: List[Module] = Field(default_factory=list, description="Módulos pertencentes ao curso")
