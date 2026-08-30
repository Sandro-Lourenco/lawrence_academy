from decimal import Decimal
from src.modules.courses.domain.entities import Course
from src.modules.courses.domain.offer_rules import validate_course_offer
from src.modules.courses.domain.external_video import parse_external_video_url
from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import AuthorizationError, NotFoundError


class UpdateCourseUseCase:
    """Caso de Uso para atualizar um curso existente com verificação de autoridade do instrutor."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(
        self,
        course_id: str,
        course_data: dict,
        current_user_id: str,
        current_user_role: str,
        expected_authoring_revision: int,
    ) -> Course:
        # Professores só podem atualizar os próprios cursos
        if current_user_role == "teacher":
            instructor_id = await self.repository.get_instructor_id(course_id)
            if not instructor_id:
                raise NotFoundError("Curso não encontrado.")
            if instructor_id != current_user_id:
                raise AuthorizationError("Acesso negado. Você não é o instrutor deste curso.")

        # Buscar entidade para preservar campos não atualizados ou criar nova
        existing = await self.repository.get_by_id(course_id)
        if not existing:
            raise NotFoundError("Curso não encontrado.")

        requested_trailer_url = course_data.get("trailer_video_url")
        remove_external_trailer = bool(course_data.get("remove_external_trailer"))
        external_trailer = (
            parse_external_video_url(requested_trailer_url)
            if requested_trailer_url
            else None
        )
        if external_trailer is not None:
            trailer_hls_path = None
            trailer_source_type = external_trailer.provider
            trailer_external_video_id = external_trailer.video_id
            trailer_status = "ready"
        elif remove_external_trailer:
            trailer_hls_path = None
            trailer_source_type = "upload"
            trailer_external_video_id = None
            trailer_status = "empty"
        else:
            trailer_hls_path = course_data.get(
                "trailer_hls_path", existing.trailer_hls_path
            )
            trailer_source_type = existing.trailer_source_type
            trailer_external_video_id = existing.trailer_external_video_id
            trailer_status = existing.trailer_status

        updated = Course(
            id=course_id,
            instructor_id=existing.instructor_id,
            title=course_data.get("title", existing.title),
            slug=course_data.get("slug", existing.slug),
            summary=course_data.get("summary", existing.summary),
            course_type=course_data.get("course_type", existing.course_type),
            subtitle=course_data.get("subtitle", existing.subtitle),
            language=course_data.get("language", existing.language),
            estimated_duration_minutes=course_data.get(
                "estimated_duration_minutes", existing.estimated_duration_minutes
            ),
            category=course_data.get("category", existing.category),
            level=course_data.get("level", existing.level),
            description=course_data.get("description", existing.description),
            requirements=course_data.get("requirements", existing.requirements),
            learning_objectives=course_data.get(
                "learning_objectives", existing.learning_objectives
            ),
            target_audience=course_data.get("target_audience", existing.target_audience),
            required_materials=course_data.get("required_materials", existing.required_materials),
            competencies=course_data.get("competencies", existing.competencies),
            expected_outcomes=course_data.get("expected_outcomes", existing.expected_outcomes),
            thumbnail_url=course_data.get("thumbnail_url", existing.thumbnail_url),
            trailer_hls_path=trailer_hls_path,
            trailer_source_type=trailer_source_type,
            trailer_external_video_id=trailer_external_video_id,
            trailer_status=trailer_status,
            monthly_price=Decimal(str(course_data.get("monthly_price", existing.monthly_price))),
            promotional_monthly_price=(
                Decimal(str(course_data["promotional_monthly_price"]))
                if "promotional_monthly_price" in course_data
                and course_data["promotional_monthly_price"] is not None
                else existing.promotional_monthly_price
            ),
            promotion_starts_at=course_data.get(
                "promotion_starts_at", existing.promotion_starts_at
            ),
            promotion_ends_at=course_data.get("promotion_ends_at", existing.promotion_ends_at),
            certificate_enabled=course_data.get(
                "certificate_enabled", existing.certificate_enabled
            ),
            reviews_enabled=course_data.get("reviews_enabled", existing.reviews_enabled),
            comments_enabled=course_data.get("comments_enabled", existing.comments_enabled),
            visibility=course_data.get("visibility", existing.visibility),
            availability=course_data.get("availability", existing.availability),
            scheduled_publish_at=course_data.get(
                "scheduled_publish_at", existing.scheduled_publish_at
            ),
            is_featured=existing.is_featured,
            status=course_data.get("status", existing.status),
            authoring_revision=existing.authoring_revision,
        )
        validate_course_offer(updated)
        saved = await self.repository.update(course_id, updated, expected_authoring_revision)
        if "prerequisite_course_ids" in course_data:
            await self.repository.replace_course_prerequisites(
                course_id=course_id,
                instructor_id=existing.instructor_id,
                prerequisite_course_ids=list(dict.fromkeys(course_data["prerequisite_course_ids"])),
            )
            return await self.repository.get_by_id(course_id) or saved
        return saved
