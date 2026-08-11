from typing import Protocol, Optional
from src.modules.profiles.domain.entities import Profile


class ProfileRepository(Protocol):
    """Interface (Protocol) de repositório de domínio para perfis."""

    async def get_by_id(self, user_id: str) -> Optional[Profile]:
        """Busca o perfil pelo ID do usuário."""
        ...

    async def update(
        self,
        user_id: str,
        full_name: Optional[str] = None,
        referred_by: Optional[str] = None,
        avatar_url: Optional[str] = None,
        bio: Optional[str] = None,
        certificate_name: Optional[str] = None,
        url_username: Optional[str] = None,
        birth_date: Optional[str] = None,
        occupation: Optional[str] = None,
        company: Optional[str] = None,
        job_title: Optional[str] = None,
        open_to_opportunities: Optional[bool] = None,
        linkedin_url: Optional[str] = None,
        twitter_url: Optional[str] = None,
        github_url: Optional[str] = None,
        custom_url: Optional[str] = None,
        academic_formations: Optional[list] = None,
    ) -> Profile:
        """Atualiza os dados de perfil do usuário."""
        ...
