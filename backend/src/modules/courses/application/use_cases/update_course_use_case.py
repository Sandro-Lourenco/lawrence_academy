from decimal import Decimal
from src.modules.courses.domain.entities import Course
from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import AuthorizationError, NotFoundError

class UpdateCourseUseCase:
    """Caso de Uso para atualizar um curso existente com verificação de autoridade do instrutor."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self, course_id: str, course_data: dict, current_user_id: str, current_user_role: str) -> Course:
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

        updated = Course(
            id=course_id,
            instructor_id=existing.instructor_id,
            title=course_data.get("title", existing.title),
            slug=course_data.get("slug", existing.slug),
            summary=course_data.get("summary", existing.summary),
            category=course_data.get("category", existing.category),
            level=course_data.get("level", existing.level),
            description=course_data.get("description", existing.description),
            requirements=course_data.get("requirements", existing.requirements),
            thumbnail_url=course_data.get("thumbnail_url", existing.thumbnail_url),
            trailer_hls_path=course_data.get("trailer_hls_path", existing.trailer_hls_path),
            monthly_price=Decimal(str(course_data.get("monthly_price", existing.monthly_price))),
            status=course_data.get("status", existing.status)
        )
        return await self.repository.update(course_id, updated)
