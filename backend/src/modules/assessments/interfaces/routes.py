from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field, ConfigDict
from src.core.security.security import get_current_user, require_role, CurrentUser
from src.modules.assessments.interfaces.schemas import TaskSubmissionSchema

router = APIRouter(tags=["assessments"])


class GradeReviewSchema(BaseModel):
    model_config = ConfigDict(frozen=True, extra="forbid")
    score: float = Field(..., ge=0.0, le=10.0, description="Nota de 0 a 10")
    teacher_comment: str = Field(
        ..., min_length=3, description="Feedback pedagógico do professor"
    )


@router.post("/api/task_submissions")
async def submit_task(
    submission: TaskSubmissionSchema,
    current_user: CurrentUser = Depends(get_current_user),
):
    """Cria uma submissão de tarefa associada ao perfil aluno autenticado (Legacy route redirection)."""
    raise HTTPException(
        status_code=status.HTTP_410_GONE,
        detail="Use POST /api/v1/tasks/{task_id}/submissions.",
    )


@router.put("/api/teacher/submissions/{submission_id}/review")
async def review_submission(
    submission_id: str,
    payload: GradeReviewSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "admin"])),
):
    """Desativa a rota legada para manter uma única política de autorização."""
    raise HTTPException(
        status_code=status.HTTP_410_GONE,
        detail="Use PUT /api/v1/tasks/submissions/{submission_id}/review.",
    )
