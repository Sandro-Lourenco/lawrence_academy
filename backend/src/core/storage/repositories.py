from typing import Optional, Protocol


class StorageRepository(Protocol):
    async def generate_signed_upload_url(self, storage_path: str) -> str: ...

    async def create_upload_job(
        self,
        lesson_id: str,
        course_id: str,
        initiated_by: str,
        idempotency_key: str,
        raw_video_path: str,
    ) -> str: ...

    async def get_upload_job_by_idempotency_key(
        self, idempotency_key: str
    ) -> Optional[dict]: ...
