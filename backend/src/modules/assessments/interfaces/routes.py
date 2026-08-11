from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field, ConfigDict
from src.core.security.security import get_current_user, require_role, CurrentUser
from src.core.database.database import get_admin_supabase_client
from src.modules.assessments.infrastructure.repositories.supabase_assessment_repository import (
    SupabaseAssessmentRepository,
)
from src.modules.assessments.application.use_cases.grade_submission_use_case import (
    GradeSubmissionUseCase,
)
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
    """Atribui nota e feedback do professor a uma submissão de tarefa discursiva (Legacy route redirection)."""
    repo = SupabaseAssessmentRepository(get_admin_supabase_client())
    use_case = GradeSubmissionUseCase(repo)
    res = await use_case.execute(
        submission_id=submission_id,
        score=payload.score,
        teacher_feedback=payload.teacher_comment,
        teacher_id=current_user.id,
    )
    return {
        "status": "success",
        "data": {
            "id": res.id,
            "score": float(res.score) if res.score is not None else None,
            "teacher_feedback": res.teacher_feedback,
            "status": res.status,
            "graded_by": res.graded_by,
        },
    }
