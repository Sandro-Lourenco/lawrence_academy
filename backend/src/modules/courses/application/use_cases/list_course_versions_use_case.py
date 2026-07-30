from src.core.errors.errors import AuthorizationError, NotFoundError
from src.modules.courses.domain.repositories import CourseRepository


class ListCourseVersionsUseCase:
    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self, *, course_id: str, user_id: str, role: str) -> list[dict]:
        owner = await self.repository.get_instructor_id(course_id)
        if not owner:
            raise NotFoundError("Curso não encontrado.")
        if role not in {"admin", "super_admin"} and owner != user_id:
            raise AuthorizationError("Acesso negado ao histórico deste curso.")
        return await self.repository.list_course_versions(course_id)
