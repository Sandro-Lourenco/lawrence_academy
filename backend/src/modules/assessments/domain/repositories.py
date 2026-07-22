from typing import Protocol, List
from src.modules.assessments.domain.entities import Task, TaskSubmission


class AssessmentRepository(Protocol):
    """Interface (Protocol) de repositório de domínio para Avaliações (Assessments)."""

    async def get_tasks_by_lesson_id(self, lesson_id: str) -> List[Task]:
        """Recupera todas as tarefas (exercícios) associadas a uma aula."""
        ...

    async def get_task_by_id(self, task_id: str) -> Task:
        """Busca uma tarefa específica pelo ID."""
        ...

    async def get_user_submissions_for_tasks(
        self, user_id: str, task_ids: List[str]
    ) -> List[TaskSubmission]:
        """Busca as submissões do usuário para uma lista de tarefas."""
        ...

    async def save(self, submission: TaskSubmission) -> TaskSubmission:
        """Salva uma nova submissão de exercício ou tarefa."""
        ...

    async def review(
        self, submission_id: str, score: float, teacher_feedback: str, graded_by: str
    ) -> TaskSubmission:
        """Atribui nota e feedback à submissão discursiva pelo professor."""
        ...
