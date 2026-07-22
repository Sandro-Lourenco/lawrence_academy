from fastapi import APIRouter, Depends, status
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional
from src.core.security.security import get_current_user, require_role, CurrentUser
from src.modules.assessments.domain.repositories import AssessmentRepository
from src.modules.assessments.interface.api.dependencies import (
    get_assessment_repository,
)
from src.modules.courses.domain.repositories import CourseRepository
from src.modules.courses.interface.api.dependencies import get_course_repository
from src.modules.assessments.application.use_cases.submit_task_use_case import (
    SubmitTaskUseCase,
)
from src.modules.assessments.application.use_cases.grade_submission_use_case import (
    GradeSubmissionUseCase,
)
from src.modules.assessments.application.use_cases.get_lesson_tasks_use_case import (
    GetLessonTasksUseCase,
)

router = APIRouter(prefix="/api/v1/tasks", tags=["tasks"])


class TaskSubmissionInputSchema(BaseModel):
    """Payload de entrada para submissão de tarefa."""

    model_config = ConfigDict(frozen=True, extra="forbid")
    selected_option: Optional[str] = Field(
        None, min_length=1, max_length=10, description="Opção selecionada"
    )
    text_answer: Optional[str] = Field(None, description="Resposta discursiva")
    is_draft: bool = Field(False, description="Indica se é apenas um rascunho")
    idempotency_key: str = Field(
        ..., min_length=1, max_length=100, description="Chave de idempotência"
    )


class GradeReviewInputSchema(BaseModel):
    """Payload de entrada para revisão de tarefa pelo professor."""

    model_config = ConfigDict(frozen=True, extra="forbid")
    score: float = Field(..., ge=0.0, le=10.0, description="Nota de 0 a 10")
    teacher_comment: str = Field(..., min_length=3, description="Feedback textual")


@router.get("/lesson/{lesson_id}", status_code=status.HTTP_200_OK)
async def get_lesson_tasks(
    lesson_id: str,
    course_id: str,
    current_user: CurrentUser = Depends(get_current_user),
    assessment_repository: AssessmentRepository = Depends(get_assessment_repository),
    course_repository: CourseRepository = Depends(get_course_repository),
):
    """Busca as tarefas de uma aula e as submissões do aluno atual."""
    use_case = GetLessonTasksUseCase(assessment_repository, course_repository)
    return await use_case.execute(
        lesson_id=lesson_id,
        course_id=course_id,
        user_id=current_user.id,
    )


@router.post("/{task_id}/submissions", status_code=status.HTTP_201_CREATED)
async def submit_task(
    task_id: str,
    payload: TaskSubmissionInputSchema,
    current_user: CurrentUser = Depends(get_current_user),
    repository: AssessmentRepository = Depends(get_assessment_repository),
):
    """Submete a resposta de um aluno para um determinado exercício (BOLA-safe)."""
    use_case = SubmitTaskUseCase(repository)
    res = await use_case.execute(
        task_id=task_id,
        user_id=current_user.id,
        selected_option=payload.selected_option,
        text_answer=payload.text_answer,
        is_draft=payload.is_draft,
        idempotency_key=payload.idempotency_key,
    )
    return {
        "id": res.id,
        "task_id": res.task_id,
        "user_id": res.user_id,
        "selected_option": res.selected_option,
        "status": res.status,
    }


@router.put("/submissions/{submission_id}/review")
async def review_submission(
    submission_id: str,
    payload: GradeReviewInputSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "admin"])),
    repository: AssessmentRepository = Depends(get_assessment_repository),
):
    """Atribui nota e comentário a um exercício discursivo (BOLA-safe)."""
    use_case = GradeSubmissionUseCase(repository)
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
