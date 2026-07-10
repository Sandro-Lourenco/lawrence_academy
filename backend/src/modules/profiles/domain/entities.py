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
