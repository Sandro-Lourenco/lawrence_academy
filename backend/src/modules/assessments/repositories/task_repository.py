from typing import Any
from src.shared import database

class TaskRepository:
    """Repositório de persistência para as submissões de tarefas."""

    @staticmethod
    def save_submission(submission_data: dict) -> Any:
        """Insere uma nova submissão de tarefa no Supabase e retorna os dados brutos."""
        res = database.db.table("task_submissions").insert(submission_data).execute()
        return res.data

    @staticmethod
    def review_submission(submission_id: str, score: float, teacher_feedback: str, graded_by: str) -> Any:
        """Atualiza a submissão discursiva com nota e feedback do professor."""
        from datetime import datetime
        res = database.db.table("task_submissions").update({
            "score": score,
            "teacher_feedback": teacher_feedback,
            "graded_by": graded_by,
            "status": "graded",
            "graded_at": datetime.utcnow().isoformat()
        }).eq("id", submission_id).execute()
        return res.data
