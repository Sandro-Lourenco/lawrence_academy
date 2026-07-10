from typing import Any
from src.modules.assessments.repositories.task_repository import TaskRepository


class GradeSubmissionUseCase:
    """Caso de Uso para o professor atribuir nota e feedback a uma tarefa discursiva (BOLA-safe)."""

    @staticmethod
    def execute(
        submission_id: str, score: float, teacher_feedback: str, teacher_id: str
    ) -> Any:
        return TaskRepository.review_submission(
            submission_id=submission_id,
            score=score,
            teacher_feedback=teacher_feedback,
            graded_by=teacher_id,
        )
