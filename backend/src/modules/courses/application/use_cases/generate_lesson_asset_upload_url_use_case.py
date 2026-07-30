import uuid

from src.core.errors.errors import AuthorizationError, NotFoundError, ValidationError
from src.core.storage.repositories import StorageRepository
from src.modules.courses.domain.repositories import CourseRepository

ALLOWED = {
    "image/jpeg": "jpg",
    "image/png": "png",
    "image/webp": "webp",
    "application/pdf": "pdf",
    "audio/mpeg": "mp3",
    "audio/mp4": "m4a",
    "audio/wav": "wav",
    "audio/ogg": "ogg",
    "application/zip": "zip",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document": "docx",
}
MAX_SIZE = 100 * 1024 * 1024


class GenerateLessonAssetUploadUrlUseCase:
    def __init__(self, courses: CourseRepository, storage: StorageRepository):
        self.courses, self.storage = courses, storage

    async def execute(
        self,
        *,
        course_id: str,
        lesson_id: str,
        user_id: str,
        role: str,
        filename: str,
        content_type: str,
        size_bytes: int,
    ):
        lesson = await self.courses.get_lesson_by_id(course_id, lesson_id)
        if not lesson:
            raise NotFoundError("Aula não encontrada neste curso.")
        owner = await self.courses.get_instructor_id(course_id)
        if role != "super_admin" and owner != user_id:
            raise AuthorizationError("Apenas o instrutor pode enviar materiais para esta aula.")
        if content_type not in ALLOWED or size_bytes <= 0 or size_bytes > MAX_SIZE:
            raise ValidationError("Arquivo não permitido ou maior que 100 MB.")
        if ".." in filename or "/" in filename or "\\" in filename:
            raise ValidationError("Nome de arquivo inválido.")
        path = f"courses/{course_id}/lessons/{lesson_id}/{uuid.uuid4()}.{ALLOWED[content_type]}"
        url = await self.storage.generate_media_signed_upload_url("lesson-assets", path)
        return {"bucket": "lesson-assets", "path": path, "signed_url": url, "expires_in": 7200}
