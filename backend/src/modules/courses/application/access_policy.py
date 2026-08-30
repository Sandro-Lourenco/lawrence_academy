from src.core.errors.errors import AuthorizationError, NotFoundError
from src.modules.courses.domain.entities import Course
from src.modules.courses.domain.repositories import CourseRepository


async def ensure_student_course_access(
    repository: CourseRepository,
    *,
    student_id: str,
    course_id: str,
) -> Course:
    """Apply the canonical published/free/paid access policy for student flows."""
    course = await repository.get_published_by_id(course_id)
    if course is None:
        raise NotFoundError("Curso publicado não encontrado.")
    if course.monthly_price > 0 and not await repository.has_active_subscription(
        student_id=student_id,
        course_id=course_id,
    ):
        raise AuthorizationError("Usuário não tem acesso a este curso.")
    return course
