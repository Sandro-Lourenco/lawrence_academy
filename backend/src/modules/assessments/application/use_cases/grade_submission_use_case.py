from src.modules.assessments.domain.entities import TaskSubmission
from src.modules.assessments.domain.repositories import AssessmentRepository

class GradeSubmissionUseCase:
    """Caso de Uso para o professor atribuir nota e feedback a uma tarefa discursiva (BOLA-safe)."""

    def __init__(self, repository: AssessmentRepository):
        self.repository = repository

    async def execute(self, submission_id: str, score: float, teacher_feedback: str, teacher_id: str) -> TaskSubmission:
        return await self.repository.review(
            submission_id=submission_id,
            score=score,
            teacher_feedback=teacher_feedback,
            graded_by=teacher_id
        )
