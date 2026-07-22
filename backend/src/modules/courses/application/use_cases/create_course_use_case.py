from decimal import Decimal
import uuid
from src.modules.courses.domain.entities import Course
from src.modules.courses.domain.repositories import CourseRepository


class CreateCourseUseCase:
    """Caso de Uso para criação de novos cursos por instrutores autorizados."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self, course_data: dict, instructor_id: str) -> Course:
        course = Course(
            id=course_data.get("id") or str(uuid.uuid4()),
            instructor_id=instructor_id,
            title=course_data["title"],
            slug=course_data["slug"],
            summary=course_data["summary"],
            category=course_data.get("category", "costura"),
            level=course_data.get("level", "iniciante"),
            description=course_data.get("description"),
            requirements=course_data.get("requirements", []),
            thumbnail_url=course_data.get("thumbnail_url"),
            trailer_hls_path=course_data.get("trailer_hls_path"),
            monthly_price=Decimal(str(course_data.get("monthly_price", "0.00"))),
            status=course_data.get("status", "draft"),
        )
        return await self.repository.create(course)
