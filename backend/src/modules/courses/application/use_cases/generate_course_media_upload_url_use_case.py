import uuid
from typing import Any, Dict

from src.core.errors.errors import AuthorizationError, NotFoundError, ValidationError
from src.core.storage.repositories import StorageRepository
from src.modules.courses.domain.repositories import CourseRepository

IMAGE_MIMES = {"image/jpeg": "jpg", "image/png": "png", "image/webp": "webp"}
VIDEO_MIMES = {"video/mp4", "video/quicktime", "video/x-m4v"}


class GenerateCourseMediaUploadUrlUseCase:
    def __init__(self, course_repository: CourseRepository, storage_repository: StorageRepository):
        self.courses = course_repository
        self.storage = storage_repository

    async def execute(
        self,
        *,
        user_id: str,
        role: str,
        course_id: str,
        asset_type: str,
        filename: str,
        content_type: str,
        size_bytes: int,
        alt_text: str = "",
        focal_x: float = 0.5,
        focal_y: float = 0.5,
    ) -> Dict[str, Any]:
        if role not in {"teacher", "admin", "super_admin"}:
            raise AuthorizationError()
        owner = await self.courses.get_instructor_id(course_id)
        if not owner:
            raise NotFoundError("Curso não encontrado.")
        if role == "teacher" and owner != user_id:
            raise AuthorizationError("Apenas o instrutor pode enviar esta mídia.")
        if ".." in filename or "/" in filename or "\\" in filename or size_bytes <= 0:
            raise ValidationError("Arquivo inválido.")
        upload_id = str(uuid.uuid4())
        if asset_type == "cover":
            if content_type not in IMAGE_MIMES or size_bytes > 10 * 1024 * 1024:
                raise ValidationError("Capa deve ser JPG, PNG ou WebP com até 10 MB.")
            if len(alt_text) > 240 or not 0 <= focal_x <= 1 or not 0 <= focal_y <= 1:
                raise ValidationError("Metadados da capa são inválidos.")
            path = f"courses/{course_id}/cover/{upload_id}.{IMAGE_MIMES[content_type]}"
            url = await self.storage.generate_media_signed_upload_url("course-images", path)
            await self.storage.register_cover_media(course_id, path, alt_text, focal_x, focal_y)
            return {
                "asset_type": asset_type,
                "bucket": "course-images",
                "path": path,
                "signed_url": url,
                "expires_in": 7200,
            }
        if asset_type == "trailer":
            if content_type not in VIDEO_MIMES or size_bytes > 2 * 1024 * 1024 * 1024:
                raise ValidationError("Trailer deve ser MP4, MOV ou M4V com até 2 GB.")
            path = f"course-trailers/{course_id}/{upload_id}.mp4"
            job_id = await self.storage.create_trailer_upload_job(
                course_id, user_id, upload_id, path, size_bytes
            )
            url = await self.storage.generate_media_signed_upload_url("raw-videos", path)
            return {
                "asset_type": asset_type,
                "bucket": "raw-videos",
                "path": path,
                "job_id": job_id,
                "signed_url": url,
                "expires_in": 7200,
            }
        raise ValidationError("Tipo de mídia não suportado.")
