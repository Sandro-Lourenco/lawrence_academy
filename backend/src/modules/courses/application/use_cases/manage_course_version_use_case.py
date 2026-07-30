from src.core.errors.errors import AuthorizationError, ConflictError, NotFoundError
from src.modules.courses.domain.repositories import CourseRepository


def _counts(snapshot: dict) -> dict[str, int]:
    modules = snapshot.get("modules") or []
    lessons = [lesson for module in modules for lesson in (module.get("lessons") or [])]
    blocks = [
        block
        for lesson in lessons
        for block in (lesson.get("lesson_blocks") or [])
    ]
    return {"modules": len(modules), "lessons": len(lessons), "blocks": len(blocks)}


class ManageCourseVersionUseCase:
    _comparison_fields = (
        "title", "subtitle", "summary", "description", "category", "level",
        "monthly_price", "promotional_monthly_price", "visibility",
        "certificate_enabled", "reviews_enabled", "comments_enabled",
    )

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def _authorize(self, course_id: str, user_id: str, role: str):
        owner = await self.repository.get_instructor_id(course_id)
        if not owner:
            raise NotFoundError("Curso não encontrado.")
        if role not in {"admin", "super_admin"} and owner != user_id:
            raise AuthorizationError("Acesso negado à versão deste curso.")

    async def detail(
        self, *, course_id: str, version_id: str, user_id: str, role: str
    ) -> dict:
        await self._authorize(course_id, user_id, role)
        version = await self.repository.get_course_version(course_id, version_id)
        if not version:
            raise NotFoundError("Versão do curso não encontrada.")
        authoring = await self.repository.get_by_id(course_id)
        if not authoring:
            raise NotFoundError("Curso não encontrado.")
        current = await self.repository.get_publication_snapshot(course_id)
        live = current.get("course") or {}
        snapshot = version["snapshot"]
        changed_fields = [
            field for field in self._comparison_fields
            if snapshot.get(field) != live.get(field)
        ]
        return {
            **version,
            "authoring_updated_at": authoring.updated_at,
            "comparison": {
                "changed_fields": changed_fields,
                "version": _counts(snapshot),
                "authoring": _counts(live),
            },
        }

    async def restore(
        self,
        *,
        course_id: str,
        version_id: str,
        user_id: str,
        role: str,
        expected_updated_at: str,
        reason: str | None,
    ):
        await self._authorize(course_id, user_id, role)
        course = await self.repository.get_by_id(course_id)
        if not course:
            raise NotFoundError("Curso não encontrado.")
        if course.status == "archived":
            raise ConflictError("Restaure o curso arquivado antes de restaurar conteúdo.")
        return await self.repository.restore_course_version(
            course_id, version_id, user_id, expected_updated_at, reason
        )
