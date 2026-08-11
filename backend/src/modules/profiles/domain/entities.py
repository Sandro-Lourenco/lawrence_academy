from dataclasses import dataclass
from typing import Optional


@dataclass(frozen=True)
class Profile:
    """Entidade do perfil do usuário na Lawrence Academy (Domínio Puro)."""

    id: str
    email: str
    full_name: Optional[str] = None
    referred_by: Optional[str] = None
    role: str = "student"
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    certificate_name: Optional[str] = None
    url_username: Optional[str] = None
    birth_date: Optional[str] = None
    occupation: Optional[str] = None
    company: Optional[str] = None
    job_title: Optional[str] = None
    open_to_opportunities: bool = False
    linkedin_url: Optional[str] = None
    twitter_url: Optional[str] = None
    github_url: Optional[str] = None
    custom_url: Optional[str] = None
    academic_formations: Optional[list] = None
