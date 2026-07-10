from src.modules.assessments.domain.entities import TaskSubmission
from src.modules.assessments.domain.repositories import AssessmentRepository

class SubmitTaskUseCase:
    """Caso de Uso para realizar submissão de respostas de tarefas de forma BOLA-safe."""

    def __init__(self, repository: AssessmentRepository):
        self.repository = repository

    async def execute(self, task_id: str, user_id: str, selected_option: str) -> TaskSubmission:
        submission = TaskSubmission(
            task_id=task_id,
            user_id=user_id,
            selected_option=selected_option
        )
        return await self.repository.save(submission)
