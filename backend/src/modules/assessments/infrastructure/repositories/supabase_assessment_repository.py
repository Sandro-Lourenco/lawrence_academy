from typing import List
import typing
from decimal import Decimal
from datetime import datetime, timezone
from supabase import Client
from src.modules.assessments.domain.entities import Task, TaskSubmission
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

    def _map_task_row(self, row: dict) -> Task:
        return Task(
            id=row.get("id", ""),
            lesson_id=row.get("lesson_id", ""),
            title=row.get("title", ""),
            task_type=row.get("task_type", ""),
            description=row.get("description"),
            options=row.get("options"),
            correct_option=row.get("correct_option"),
            max_attempts=row.get("max_attempts", 1),
            passing_score=Decimal(str(row["passing_score"]))
            if row.get("passing_score") is not None
            else None,
            created_at=datetime.fromisoformat(row["created_at"].replace("Z", "+00:00"))
            if row.get("created_at")
            else None,
            updated_at=datetime.fromisoformat(row["updated_at"].replace("Z", "+00:00"))
            if row.get("updated_at")
            else None,
        )

    async def get_tasks_by_lesson_id(self, lesson_id: str) -> List[Task]:
        res = (
            self.client.table("tasks")
            .select("*")
            .eq("lesson_id", lesson_id)
            .is_("deleted_at", "null")
            .execute()
        )
        if not res.data:
            return []
        return [
            self._map_task_row(typing.cast(dict[str, typing.Any], row))
            for row in res.data
        ]

    async def get_task_by_id(self, task_id: str) -> Task:
        res = (
            self.client.table("tasks")
            .select("*")
            .eq("id", task_id)
            .is_("deleted_at", "null")
            .execute()
        )
        if not res.data:
            raise NotFoundError("Tarefa não encontrada.")
        return self._map_task_row(typing.cast(dict[str, typing.Any], res.data[0]))

    async def get_user_submissions_for_tasks(
        self, user_id: str, task_ids: List[str]
    ) -> List[TaskSubmission]:
        if not task_ids:
            return []
        res = (
            self.client.table("task_submissions")
            .select("*")
            .eq("user_id", user_id)
            .in_("task_id", task_ids)
            .execute()
        )
        if not res.data:
            return []
        return [
            self._map_row(typing.cast(dict[str, typing.Any], row)) for row in res.data
        ]

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
        if submission.score is not None:
            data["score"] = str(submission.score)
        if submission.submitted_at is not None:
            data["submitted_at"] = submission.submitted_at.isoformat()
        if submission.graded_at is not None:
            data["graded_at"] = submission.graded_at.isoformat()

        if submission.id:
            # Atualiza rascunho existente
            res = (
                self.client.table("task_submissions")
                .update(typing.cast(typing.Any, data))
                .eq("id", submission.id)
                .execute()
            )
        else:
            # Cria nova submissão
            res = (
                self.client.table("task_submissions")
                .insert(typing.cast(typing.Any, data))
                .execute()
            )

        if not res.data:
            raise NotFoundError("Falha ao salvar submissão.")
        row = res.data[0] if isinstance(res.data, list) else res.data
        return self._map_row(typing.cast(dict[str, typing.Any], row))

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
            .update(typing.cast(typing.Any, update_data))
            .eq("id", submission_id)
            .execute()
        )
        if not res.data:
            raise NotFoundError("Submissão não encontrada para avaliação.")
        return self._map_row(typing.cast(dict[str, typing.Any], res.data[0]))
