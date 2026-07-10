from pydantic import BaseModel, ConfigDict, Field
from typing import Optional

class StudentProfileResponseSchema(BaseModel):
    """Schema de retorno para os dados de perfil do aluno."""
    model_config = ConfigDict(from_attributes=True)

    id: str = Field(..., description="UUID único do perfil")
    email: str = Field(..., description="E-mail do aluno")
    full_name: Optional[str] = Field(None, description="Nome completo")
    referred_by: Optional[str] = Field(None, description="UUID do indicador")
    role: str = Field("student", description="Papel de acesso")

class StudentProfileUpdateSchema(BaseModel):
    """Schema de validação para atualização do perfil do aluno."""
    model_config = ConfigDict(frozen=True, extra="forbid")

    full_name: Optional[str] = Field(None, min_length=2, max_length=100, description="Nome completo")
    referred_by: Optional[str] = Field(None, description="UUID do perfil indicador")
