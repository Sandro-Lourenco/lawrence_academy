from typing import Optional
from decimal import Decimal
from datetime import datetime, timezone
from src.modules.assessments.domain.entities import TaskSubmission
from src.modules.assessments.domain.repositories import AssessmentRepository
from src.core.errors.errors import AuthorizationError


class SubmitTaskUseCase:
    """Caso de Uso para realizar submissão de respostas de tarefas de forma BOLA-safe."""

    def __init__(self, repository: AssessmentRepository):
        self.repository = repository

    async def execute(
        self,
        task_id: str,
        user_id: str,
        selected_option: Optional[str] = None,
        text_answer: Optional[str] = None,
        is_draft: bool = False,
        idempotency_key: str = "",
    ) -> TaskSubmission:
        # Busca a tarefa para obter regras (tipo, max_attempts, resposta certa)
        task = await self.repository.get_task_by_id(task_id)

        # Checa limite de tentativas
        existing_subs = await self.repository.get_user_submissions_for_tasks(
            user_id, [task_id]
        )

        # Filtra submissões que não são rascunho
        finalized_subs = [s for s in existing_subs if s.status != "draft"]
        draft_subs = [s for s in existing_subs if s.status == "draft"]

        if len(finalized_subs) >= task.max_attempts:
            raise AuthorizationError("Limite de tentativas excedido.")

        # Determina o status da submissão
        status = "draft"
        score: Optional[Decimal] = None

        if not is_draft:
            if task.task_type in ["multiple_choice", "true_false"]:
                status = "graded"
                if (
                    selected_option
                    and task.correct_option
                    and selected_option.lower() == task.correct_option.lower()
                ):
                    score = (
                        Decimal("10.0")
                        if task.passing_score is None
                        else Decimal("10.0")
                    )  # ou qualquer nota máxima
                else:
                    score = Decimal("0.0")
            elif task.task_type == "essay":
                status = "under_review"
            else:
                status = "submitted"

        # Se existe um rascunho, atualizá-lo via upsert no repositório.
        submission_id = draft_subs[0].id if draft_subs else None

        submission = TaskSubmission(
            id=submission_id,
            task_id=task_id,
            user_id=user_id,
            selected_option=selected_option,
            text_answer=text_answer,
            score=score,
            status=status,
            submitted_at=datetime.now(timezone.utc) if not is_draft else None,
            graded_at=datetime.now(timezone.utc) if status == "graded" else None,
        )
        return await self.repository.save(submission)
