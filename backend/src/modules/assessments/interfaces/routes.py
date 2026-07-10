from fastapi import APIRouter, Depends, HTTPException, status
from typing import Any
from pydantic import BaseModel, Field, ConfigDict
from src.modules.auth.dependencies import get_current_user, require_role
from src.modules.assessments.interfaces.schemas import TaskSubmissionSchema
from src.modules.assessments.application.submit_task import SubmitTaskUseCase
from src.modules.assessments.application.grade_submission import GradeSubmissionUseCase

router = APIRouter(tags=["assessments"])

class GradeReviewSchema(BaseModel):
    model_config = ConfigDict(frozen=True, extra="forbid")
    score: float = Field(..., ge=0.0, le=10.0, description="Nota de 0 a 10")
    teacher_comment: str = Field(..., min_length=3, description="Feedback pedagógico do professor")

@router.post("/api/task_submissions")
async def submit_task(
    submission: TaskSubmissionSchema,
    current_user: dict = Depends(get_current_user)
) -> Any:
    """Cria uma submissão de tarefa associada ao perfil aluno autenticado (BOLA-safe)."""
    try:
        res = SubmitTaskUseCase.execute(
            task_id=submission.task_id,
            user_id=current_user["id"],
            selected_option=submission.selected_option
        )
        return res
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ocorreu um erro interno ao salvar a submissão."
        )

@router.put("/api/teacher/submissions/{submission_id}/review")
async def review_submission(
    submission_id: str,
    payload: GradeReviewSchema,
    current_user: dict = Depends(require_role(["teacher", "admin"]))
) -> Any:
    """Atribui nota e feedback do professor a uma submissão de tarefa discursiva (BOLA-safe)."""
    try:
        res = GradeSubmissionUseCase.execute(
            submission_id=submission_id,
            score=payload.score,
            teacher_feedback=payload.teacher_comment,
            teacher_id=current_user["id"]
        )
        return {"status": "success", "data": res}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro interno ao avaliar submissão: {str(e)}"
        )
