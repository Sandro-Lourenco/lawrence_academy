from pydantic import BaseModel, ConfigDict, Field
from typing import Optional


class ProfileUpdateSchema(BaseModel):
    """Payload de validação do input do usuário para atualização de perfil."""

    model_config = ConfigDict(frozen=True, extra="forbid")

    full_name: Optional[str] = Field(
        None, min_length=2, max_length=100, description="Nome completo"
    )
    referred_by: Optional[str] = Field(
        None, description="UUID do perfil indicador (opcional)"
    )
