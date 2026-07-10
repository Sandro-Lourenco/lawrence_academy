from pydantic import BaseModel, ConfigDict, Field
from typing import Optional

class Profile(BaseModel):
    """Entidade do perfil do usuário na Lawrence Academy.
    Define as propriedades centrais e garante imutabilidade.
    """
    model_config = ConfigDict(frozen=True, extra="forbid")

    id: str = Field(..., description="UUID único do perfil")
    email: str = Field(..., description="Endereço de e-mail do perfil")
    full_name: Optional[str] = Field(None, min_length=2, max_length=100, description="Nome completo")
    referred_by: Optional[str] = Field(None, description="UUID do perfil que indicou este aluno")
    role: str = Field("student", description="Papel/permissão do usuário (student, teacher, admin)")
