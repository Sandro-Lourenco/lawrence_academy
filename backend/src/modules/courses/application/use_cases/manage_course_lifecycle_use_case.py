from src.core.errors.errors import AuthorizationError, NotFoundError, ValidationError
from src.modules.courses.domain.repositories import CourseRepository


class ManageCourseLifecycleUseCase:
    _allowed_targets = {"unpublished", "archived", "draft"}

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(
        self,
        *,
        course_id: str,
        user_id: str,
        role: str,
        target_status: str,
        reason: str | None = None,
    ) -> dict:
        if target_status not in self._allowed_targets:
            raise ValidationError("Transição de status não permitida.")
        owner = await self.repository.get_instructor_id(course_id)
        if not owner:
            raise NotFoundError("Curso não encontrado.")
        if role not in {"admin", "super_admin"} and owner != user_id:
            raise AuthorizationError("Apenas o instrutor pode alterar este curso.")
        normalized_reason = reason.strip() if reason else None
        status = await self.repository.transition_course_status(
            course_id, user_id, target_status, normalized_reason
        )
        return {"course_id": course_id, "status": status}
