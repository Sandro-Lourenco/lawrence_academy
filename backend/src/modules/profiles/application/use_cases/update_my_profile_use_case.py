from typing import Optional
from src.modules.profiles.domain.entities import Profile
from src.modules.profiles.domain.repositories import ProfileRepository
from src.core.errors.errors import ValidationError


class UpdateMyProfileUseCase:
    """Caso de Uso para atualizar o perfil do próprio usuário de forma BOLA-safe."""

    def __init__(self, repository: ProfileRepository):
        self.repository = repository

    async def execute(
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
        if all(
            v is None
            for v in [
                full_name,
                referred_by,
                avatar_url,
                bio,
                certificate_name,
                url_username,
                birth_date,
                occupation,
                company,
                job_title,
                open_to_opportunities,
                linkedin_url,
                twitter_url,
                github_url,
                custom_url,
                academic_formations,
            ]
        ):
            raise ValidationError(message="Nenhum dado informado para atualização.")
        return await self.repository.update(
            user_id=user_id,
            full_name=full_name,
            referred_by=referred_by,
            avatar_url=avatar_url,
            bio=bio,
            certificate_name=certificate_name,
            url_username=url_username,
            birth_date=birth_date,
            occupation=occupation,
            company=company,
            job_title=job_title,
            open_to_opportunities=open_to_opportunities,
            linkedin_url=linkedin_url,
            twitter_url=twitter_url,
            github_url=github_url,
            custom_url=custom_url,
            academic_formations=academic_formations,
        )
