from decimal import Decimal
import uuid
from src.modules.courses.domain.entities import Course
from src.modules.courses.domain.offer_rules import validate_course_offer
from src.modules.courses.domain.repositories import CourseRepository
from src.modules.courses.application.idempotency import (
    deterministic_resource_id,
    request_fingerprint,
)


class CreateCourseUseCase:
    """Caso de Uso para criação de novos cursos por instrutores autorizados."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(
        self,
        course_data: dict,
        instructor_id: str,
        idempotency_key: str | None = None,
    ) -> Course:
        course = Course(
            id=course_data.get("id") or (
                deterministic_resource_id(f"course:{instructor_id}", idempotency_key)
                if idempotency_key else str(uuid.uuid4())
            ),
            instructor_id=instructor_id,
            title=course_data["title"],
            slug=course_data["slug"],
            summary=course_data["summary"],
            course_type=course_data.get("course_type", "complete"),
            subtitle=course_data.get("subtitle", ""),
            language=course_data.get("language", "pt-BR"),
            estimated_duration_minutes=course_data.get("estimated_duration_minutes"),
            category=course_data.get("category", "costura"),
            level=course_data.get("level", "iniciante"),
            description=course_data.get("description"),
            requirements=course_data.get("requirements", []),
            learning_objectives=course_data.get("learning_objectives", []),
            target_audience=course_data.get("target_audience", []),
            required_materials=course_data.get("required_materials", []),
            competencies=course_data.get("competencies", []),
            expected_outcomes=course_data.get("expected_outcomes", []),
            thumbnail_url=course_data.get("thumbnail_url"),
            trailer_hls_path=course_data.get("trailer_hls_path"),
            monthly_price=Decimal(str(course_data.get("monthly_price", "0.00"))),
            promotional_monthly_price=(
                Decimal(str(course_data["promotional_monthly_price"]))
                if course_data.get("promotional_monthly_price") is not None
                else None
            ),
            promotion_starts_at=course_data.get("promotion_starts_at"),
            promotion_ends_at=course_data.get("promotion_ends_at"),
            certificate_enabled=course_data.get("certificate_enabled", True),
            reviews_enabled=course_data.get("reviews_enabled", True),
            comments_enabled=course_data.get("comments_enabled", True),
            visibility=course_data.get("visibility", "public"),
            availability=course_data.get("availability", "immediate"),
            scheduled_publish_at=course_data.get("scheduled_publish_at"),
            status=course_data.get("status", "draft"),
        )
        validate_course_offer(course)
        if not idempotency_key:
            return await self.repository.create(course)
        return await self.repository.create(
            course,
            idempotency_key=idempotency_key,
            request_hash=request_fingerprint(course_data) if idempotency_key else None,
        )
