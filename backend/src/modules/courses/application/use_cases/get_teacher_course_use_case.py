from src.core.errors.errors import AuthorizationError, NotFoundError
from src.modules.courses.domain.entities import Course
from src.modules.courses.domain.repositories import CourseRepository


class GetTeacherCourseUseCase:
    """ObtÃ©m um curso garantindo que o professor seja seu proprietÃ¡rio."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self, course_id: str, user_id: str, role: str) -> Course:
        course = await self.repository.get_by_id(course_id)
        if not course:
            raise NotFoundError("Curso nÃ£o encontrado.")
        if role != "super_admin" and course.instructor_id != user_id:
            raise AuthorizationError(
                "Acesso negado. VocÃª nÃ£o Ã© o instrutor deste curso."
            )
        return course
