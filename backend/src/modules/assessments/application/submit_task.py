from typing import Any
from src.modules.assessments.repositories.task_repository import TaskRepository


class SubmitTaskUseCase:
    """Caso de Uso para realizar submissão de respostas de tarefas de forma BOLA-safe."""

    @staticmethod
    def execute(task_id: str, user_id: str, selected_option: str) -> Any:
        # Injeta obrigatoriamente o user_id extraído com segurança do token (BOLA-safe)
        payload = {
            "task_id": task_id,
            "user_id": user_id,
            "selected_option": selected_option,
        }
        return TaskRepository.save_submission(payload)
