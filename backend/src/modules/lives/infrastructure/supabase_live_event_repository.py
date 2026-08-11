from datetime import datetime
from typing import Any, cast

from supabase import Client

from src.core.concurrency import run_sync_io
from src.modules.lives.domain.entities import LiveEvent
from src.modules.lives.domain.repositories import LiveEventRepository


class SupabaseLiveEventRepository(LiveEventRepository):
    def __init__(self, client: Client):
        self.client = client

    async def list_public(self) -> list[LiveEvent]:
        query = (
            self.client.table("live_events")
            .select("*")
            .in_("status", ["scheduled", "live", "ended"])
            .order("scheduled_for", desc=True)
            .limit(100)
        )
        return await self._execute_list(query)

    async def list_for_teacher(self, teacher_id: str, is_super_admin: bool) -> list[LiveEvent]:
        query = self.client.table("live_events").select("*")
        if not is_super_admin:
            query = query.eq("instructor_id", teacher_id)
        return await self._execute_list(query.order("scheduled_for", desc=True).limit(100))

    async def get_by_id(self, event_id: str) -> LiveEvent | None:
        response = await run_sync_io(
            self.client.table("live_events").select("*").eq("id", event_id).maybe_single().execute
        )
        if not response or not response.data:
            return None
        names = await self._instructor_names([cast(dict[str, Any], response.data)["instructor_id"]])
        return self._from_row(cast(dict[str, Any], response.data), names)

    async def create(self, instructor_id: str, data: dict) -> LiveEvent:
        payload = {**data, "instructor_id": instructor_id}
        response = await run_sync_io(self.client.table("live_events").insert(payload).execute)
        row = cast(list[dict[str, Any]], response.data)[0]
        names = await self._instructor_names([instructor_id])
        return self._from_row(row, names)

    async def update(self, event_id: str, data: dict) -> LiveEvent:
        response = await run_sync_io(
            self.client.table("live_events").update(data).eq("id", event_id).execute
        )
        row = cast(list[dict[str, Any]], response.data)[0]
        names = await self._instructor_names([row["instructor_id"]])
        return self._from_row(row, names)

    async def delete(self, event_id: str) -> None:
        await run_sync_io(self.client.table("live_events").delete().eq("id", event_id).execute)

    async def _execute_list(self, query: Any) -> list[LiveEvent]:
        response = await run_sync_io(query.execute)
        rows = cast(list[dict[str, Any]], response.data or [])
        names = await self._instructor_names([row["instructor_id"] for row in rows])
        return [self._from_row(row, names) for row in rows]

    async def _instructor_names(self, instructor_ids: list[str]) -> dict[str, str]:
        ids = list(dict.fromkeys(instructor_ids))
        if not ids:
            return {}
        response = await run_sync_io(
            self.client.table("profiles").select("id,full_name,email").in_("id", ids).execute
        )
        return {
            row["id"]: (row.get("full_name") or row.get("email") or "Lawrence Academy")
            for row in cast(list[dict[str, Any]], response.data or [])
        }

    @staticmethod
    def _from_row(row: dict[str, Any], names: dict[str, str]) -> LiveEvent:
        return LiveEvent(
            id=row["id"],
            instructor_id=row["instructor_id"],
            instructor_name=names.get(row["instructor_id"], "Lawrence Academy"),
            title=row["title"],
            description=row.get("description", ""),
            tag=row["tag"],
            scheduled_for=datetime.fromisoformat(row["scheduled_for"].replace("Z", "+00:00")),
            timezone=row["timezone"],
            duration_minutes=row["duration_minutes"],
            status=row["status"],
            youtube_url=row["youtube_url"],
            banner_url=row.get("banner_url"),
            created_at=datetime.fromisoformat(row["created_at"].replace("Z", "+00:00")),
            updated_at=datetime.fromisoformat(row["updated_at"].replace("Z", "+00:00")),
        )
