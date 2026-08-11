import typing
from typing import Optional
from supabase import Client
from src.core.concurrency import run_sync_io
from src.modules.profiles.domain.entities import Profile
from src.modules.profiles.domain.repositories import ProfileRepository
from src.core.errors.errors import NotFoundError


class SupabaseProfileRepository(ProfileRepository):
    """Implementação Supabase para o repositório de perfis."""

    def __init__(self, client: Client):
        self.client = client

    async def get_by_id(self, user_id: str) -> Optional[Profile]:
        query = self.client.table("profiles").select("*").eq("id", user_id).maybe_single()
        res = await run_sync_io(query.execute)

        if res is None or not res.data:
            return None

        row = typing.cast(dict[str, typing.Any], res.data)
        return Profile(
            id=row["id"],
            email=row["email"],
            full_name=row.get("full_name"),
            referred_by=row.get("referred_by"),
            role=row.get("role", "student"),
            avatar_url=row.get("avatar_url"),
            bio=row.get("bio"),
            certificate_name=row.get("certificate_name"),
            url_username=row.get("url_username"),
            birth_date=str(row["birth_date"]) if row.get("birth_date") else None,
            occupation=row.get("occupation"),
            company=row.get("company"),
            job_title=row.get("job_title"),
            open_to_opportunities=row.get("open_to_opportunities", False),
            linkedin_url=row.get("linkedin_url"),
            twitter_url=row.get("twitter_url"),
            github_url=row.get("github_url"),
            custom_url=row.get("custom_url"),
            academic_formations=row.get("academic_formations", []),
        )

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
        update_data = {}
        if full_name is not None:
            update_data["full_name"] = full_name
        if referred_by is not None:
            update_data["referred_by"] = referred_by
        if avatar_url is not None:
            update_data["avatar_url"] = avatar_url
        if bio is not None:
            update_data["bio"] = bio
        if certificate_name is not None:
            update_data["certificate_name"] = certificate_name
        if url_username is not None:
            update_data["url_username"] = url_username
        if birth_date is not None:
            update_data["birth_date"] = birth_date if birth_date else None
        if occupation is not None:
            update_data["occupation"] = occupation
        if company is not None:
            update_data["company"] = company
        if job_title is not None:
            update_data["job_title"] = job_title
        if open_to_opportunities is not None:
            update_data["open_to_opportunities"] = open_to_opportunities
        if linkedin_url is not None:
            update_data["linkedin_url"] = linkedin_url
        if twitter_url is not None:
            update_data["twitter_url"] = twitter_url
        if github_url is not None:
            update_data["github_url"] = github_url
        if custom_url is not None:
            update_data["custom_url"] = custom_url
        if academic_formations is not None:
            update_data["academic_formations"] = academic_formations

        query = (
            self.client.table("profiles")
            .update(typing.cast(typing.Any, update_data))
            .eq("id", user_id)
        )
        res = await run_sync_io(query.execute)

        if not res.data:
            raise NotFoundError("Perfil não encontrado para atualização.")

        row = typing.cast(dict[str, typing.Any], res.data[0])
        return Profile(
            id=row["id"],
            email=row["email"],
            full_name=row.get("full_name"),
            referred_by=row.get("referred_by"),
            role=row.get("role", "student"),
            avatar_url=row.get("avatar_url"),
            bio=row.get("bio"),
            certificate_name=row.get("certificate_name"),
            url_username=row.get("url_username"),
            birth_date=str(row["birth_date"]) if row.get("birth_date") else None,
            occupation=row.get("occupation"),
            company=row.get("company"),
            job_title=row.get("job_title"),
            open_to_opportunities=row.get("open_to_opportunities", False),
            linkedin_url=row.get("linkedin_url"),
            twitter_url=row.get("twitter_url"),
            github_url=row.get("github_url"),
            custom_url=row.get("custom_url"),
            academic_formations=row.get("academic_formations", []),
        )
