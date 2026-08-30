from src.core.errors.errors import AuthorizationError, NotFoundError
from src.modules.courses.domain.entities import CourseStudent
from src.modules.courses.domain.repositories import CourseRepository


class ListCourseStudentsUseCase:
    """Expõe matrículas somente ao professor proprietário ou super admin."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self, *, course_id: str, user_id: str, role: str) -> list[CourseStudent]:
        instructor_id = await self.repository.get_instructor_id(course_id)
        if not instructor_id:
            raise NotFoundError("Curso não encontrado.")
        if role != "super_admin" and instructor_id != user_id:
            raise AuthorizationError("Apenas o professor do curso pode visualizar os alunos.")
        return await self.repository.list_course_students(course_id)
