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
    avatar_url: Optional[str] = Field(None, description="URL do avatar")
    bio: Optional[str] = Field(None, description="Biografia")
    certificate_name: Optional[str] = Field(None, description="Nome nos certificados")
    url_username: Optional[str] = Field(None, description="Usuário na URL")
    birth_date: Optional[str] = Field(None, description="Data de nascimento")
    occupation: Optional[str] = Field(None, description="Ocupação")
    company: Optional[str] = Field(None, description="Empresa")
    job_title: Optional[str] = Field(None, description="Cargo")
    open_to_opportunities: bool = Field(False, description="Aberto a oportunidades")
    linkedin_url: Optional[str] = Field(None, description="URL do LinkedIn")
    twitter_url: Optional[str] = Field(None, description="URL do Twitter")
    github_url: Optional[str] = Field(None, description="URL do GitHub")
    custom_url: Optional[str] = Field(None, description="Link personalizado")
    academic_formations: list = Field([], description="Formações acadêmicas")


class StudentProfileUpdateSchema(BaseModel):
    """Schema de validação para atualização do perfil do aluno."""

    model_config = ConfigDict(frozen=True, extra="forbid")

    full_name: Optional[str] = Field(
        None, min_length=2, max_length=100, description="Nome completo"
    )
    referred_by: Optional[str] = Field(None, description="UUID do perfil indicador")
    avatar_url: Optional[str] = Field(None, description="URL do avatar")
    bio: Optional[str] = Field(None, description="Biografia")
    certificate_name: Optional[str] = Field(None, description="Nome nos certificados")
    url_username: Optional[str] = Field(None, description="Usuário na URL")
    birth_date: Optional[str] = Field(None, description="Data de nascimento")
    occupation: Optional[str] = Field(None, description="Ocupação")
    company: Optional[str] = Field(None, description="Empresa")
    job_title: Optional[str] = Field(None, description="Cargo")
    open_to_opportunities: Optional[bool] = Field(None, description="Aberto a oportunidades")
    linkedin_url: Optional[str] = Field(None, description="URL do LinkedIn")
    twitter_url: Optional[str] = Field(None, description="URL do Twitter")
    github_url: Optional[str] = Field(None, description="URL do GitHub")
    custom_url: Optional[str] = Field(None, description="Link personalizado")
    academic_formations: Optional[list] = Field(None, description="Formações acadêmicas")
