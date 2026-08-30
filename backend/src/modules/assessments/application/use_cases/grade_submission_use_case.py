from src.modules.assessments.domain.entities import TaskSubmission
from src.modules.assessments.domain.repositories import AssessmentRepository
from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import AuthorizationError, ValidationError


class GradeSubmissionUseCase:
    """Caso de Uso para o professor atribuir nota e feedback a uma tarefa discursiva (BOLA-safe)."""

    def __init__(
        self,
        repository: AssessmentRepository,
        course_repository: CourseRepository,
    ):
        self.repository = repository
        self.course_repository = course_repository

    async def execute(
        self,
        submission_id: str,
        score: float,
        teacher_feedback: str,
        teacher_id: str,
        teacher_role: str,
    ) -> TaskSubmission:
        submission = await self.repository.get_submission_by_id(submission_id)
        task = await self.repository.get_task_by_id(submission.task_id)
        if task.task_type != "essay" or submission.status != "pending_review":
            raise ValidationError(
                "Somente atividades discursivas pendentes podem ser corrigidas."
            )

        if teacher_role not in {"admin", "super_admin"}:
            owner_id = await self.course_repository.get_instructor_id(task.course_id)
            if owner_id != teacher_id:
                raise AuthorizationError("Esta atividade pertence a outro professor.")

        return await self.repository.review(
            submission_id=submission_id,
            score=score,
            teacher_feedback=teacher_feedback,
            graded_by=teacher_id,
        )
