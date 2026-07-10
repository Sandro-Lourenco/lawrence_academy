from pydantic import BaseModel, ConfigDict, Field
from typing import List, Optional
from decimal import Decimal
from datetime import datetime

class LessonResponseSchema(BaseModel):
    """Schema de retorno para os dados de uma Aula (Lesson)."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    module_id: str
    course_id: str
    title: str
    description: Optional[str] = None
    order_index: int
    duration_seconds: int
    hls_storage_path: str
    material_pdf_url: Optional[str] = None
    status: str
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

class CourseResponseSchema(BaseModel):
    """Schema de retorno para os dados básicos de um Curso (Course)."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    instructor_id: str
    title: str
    slug: str
    category: str
    level: str
    summary: str
    description: Optional[str] = None
    requirements: Optional[List[str]] = None
    thumbnail_url: Optional[str] = None
    trailer_hls_path: Optional[str] = None
    monthly_price: Decimal
    status: str
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
