from pydantic import BaseModel, ConfigDict, Field
from typing import Any, Optional
from datetime import datetime, timezone

class ResponseMetaSchema(BaseModel):
    """Metadados inclusos no envelope padrão de resposta."""
    model_config = ConfigDict(frozen=True)
    
    timestamp: str = Field(
        default_factory=lambda: datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    )
    version: str = "1.0.0"

class StandardResponseSchema(BaseModel):
    """Envelope padrão de resposta com sucesso (REST/JSON)."""
    model_config = ConfigDict(frozen=True)
    
    status: str = "success"
    data: Any
    meta: ResponseMetaSchema = Field(default_factory=ResponseMetaSchema)

class ErrorDetailsSchema(BaseModel):
    """Detalhes de um erro ocorrido na requisição (RFC 7807)."""
    model_config = ConfigDict(frozen=True)
    
    code: str = Field(..., description="Código curto legível da falha")
    message: str = Field(..., description="Mensagem de erro amigável para o usuário")
    details: Optional[str] = Field(None, description="Detalhes técnicos ou de contexto")

class ErrorResponseSchema(BaseModel):
    """Envelope padrão de resposta com erro."""
    model_config = ConfigDict(frozen=True)
    
    status: str = "error"
    error: ErrorDetailsSchema
