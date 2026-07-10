from typing import Protocol
from src.modules.assessments.domain.entities import TaskSubmission


class AssessmentRepository(Protocol):
    """Interface (Protocol) de repositório de domínio para Avaliações (Assessments)."""

    async def save(self, submission: TaskSubmission) -> TaskSubmission:
        """Salva uma nova submissão de exercício ou tarefa."""
        ...

    async def review(
        self, submission_id: str, score: float, teacher_feedback: str, graded_by: str
    ) -> TaskSubmission:
        """Atribui nota e feedback à submissão discursiva pelo professor."""
        ...
