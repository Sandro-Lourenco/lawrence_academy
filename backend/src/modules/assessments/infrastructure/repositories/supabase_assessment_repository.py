from decimal import Decimal
from datetime import datetime, timezone
from supabase import Client
from src.modules.assessments.domain.entities import TaskSubmission
from src.modules.assessments.domain.repositories import AssessmentRepository
from src.core.errors.errors import NotFoundError


class SupabaseAssessmentRepository(AssessmentRepository):
    """Implementação Supabase para repositório de Avaliações."""

    def __init__(self, client: Client):
        self.client = client

    def _map_row(self, row: dict) -> TaskSubmission:
        return TaskSubmission(
            id=row.get("id"),
            task_id=row.get("task_id", ""),
            user_id=row.get("user_id", ""),
            selected_option=row.get("selected_option"),
            text_answer=row.get("text_answer"),
            score=Decimal(str(row["score"])) if row.get("score") is not None else None,
            status=row.get("status", "pending_auto"),
            teacher_feedback=row.get("teacher_feedback"),
            graded_by=row.get("graded_by"),
            submitted_at=datetime.fromisoformat(
                row["submitted_at"].replace("Z", "+00:00")
            )
            if row.get("submitted_at")
            else None,
            graded_at=datetime.fromisoformat(row["graded_at"].replace("Z", "+00:00"))
            if row.get("graded_at")
            else None,
        )

    async def save(self, submission: TaskSubmission) -> TaskSubmission:
        data = {
            "task_id": submission.task_id,
            "user_id": submission.user_id,
            "selected_option": submission.selected_option,
        }
        if submission.text_answer is not None:
            data["text_answer"] = submission.text_answer
        if submission.status != "pending_auto":
            data["status"] = submission.status
        res = self.client.table("task_submissions").insert(data).execute()
        if not res.data:
            raise NotFoundError("Falha ao salvar submissão.")
        row = res.data[0] if isinstance(res.data, list) else res.data
        return self._map_row(row)

    async def review(
        self, submission_id: str, score: float, teacher_feedback: str, graded_by: str
    ) -> TaskSubmission:
        update_data = {
            "score": score,
            "teacher_feedback": teacher_feedback,
            "graded_by": graded_by,
            "status": "graded",
            "graded_at": datetime.now(timezone.utc).isoformat(),
        }
        res = (
            self.client.table("task_submissions")
            .update(update_data)
            .eq("id", submission_id)
            .execute()
        )
        if not res.data:
            raise NotFoundError("Submissão não encontrada para avaliação.")
        return self._map_row(res.data[0])
