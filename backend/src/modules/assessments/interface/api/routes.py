from fastapi import APIRouter, Depends, status
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, Dict, Any
from decimal import Decimal
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
from src.modules.assessments.application.use_cases.create_task_use_case import (
    CreateTaskUseCase,
)
from src.modules.assessments.application.use_cases.update_task_use_case import (
    UpdateTaskUseCase,
)
from src.modules.assessments.application.use_cases.delete_task_use_case import (
    DeleteTaskUseCase,
)
from src.modules.assessments.application.use_cases.list_student_activities_use_case import (
    ListStudentActivitiesUseCase,
)
from src.modules.profiles.domain.repositories import ProfileRepository
from src.modules.profiles.interface.api.dependencies import get_profile_repository

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


class TaskCreateInputSchema(BaseModel):
    """Payload de entrada para criação de tarefa."""

    model_config = ConfigDict(frozen=True, extra="forbid")
    course_id: str = Field(..., description="UUID do curso")
    lesson_id: str = Field(..., description="UUID da lição")
    title: str = Field(..., min_length=3, max_length=255, description="Título da tarefa")
    task_type: str = Field(..., description="Tipo de tarefa (ex: single_choice, essay)")
    description: Optional[str] = Field(None, description="Enunciado/pergunta da tarefa")
    options: Optional[Dict[str, Any]] = Field(None, description="Opções para múltipla escolha")
    correct_option: Optional[str] = Field(None, description="Opção correta")
    max_attempts: int = Field(default=1, ge=1, description="Máximo de tentativas")
    passing_score: Optional[Decimal] = Field(default=None, ge=0.0, le=10.0, description="Nota mínima para aprovação")


class TaskUpdateInputSchema(BaseModel):
    """Payload de entrada para atualização de tarefa."""

    model_config = ConfigDict(frozen=True, extra="forbid")
    title: Optional[str] = Field(None, min_length=3, max_length=255, description="Título da tarefa")
    task_type: Optional[str] = Field(None, description="Tipo de tarefa")
    description: Optional[str] = Field(None, description="Enunciado/pergunta da tarefa")
    options: Optional[Dict[str, Any]] = Field(None, description="Opções")
    correct_option: Optional[str] = Field(None, description="Opção correta")
    max_attempts: Optional[int] = Field(None, ge=1, description="Máximo de tentativas")
    passing_score: Optional[Decimal] = Field(None, ge=0.0, le=10.0, description="Nota mínima")


@router.get("/me", status_code=status.HTTP_200_OK)
async def list_my_activities(
    current_user: CurrentUser = Depends(get_current_user),
    assessment_repository: AssessmentRepository = Depends(get_assessment_repository),
    course_repository: CourseRepository = Depends(get_course_repository),
    profile_repository: ProfileRepository = Depends(get_profile_repository),
):
    use_case = ListStudentActivitiesUseCase(
        assessment_repository, course_repository, profile_repository
    )
    return await use_case.execute(current_user.id)


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
    course_repository: CourseRepository = Depends(get_course_repository),
):
    """Submete a resposta de um aluno para um determinado exercício (BOLA-safe)."""
    use_case = SubmitTaskUseCase(repository, course_repository)
    res = await use_case.execute(
        task_id=task_id,
        user_id=current_user.id,
        selected_option=payload.selected_option,
        text_answer=payload.text_answer,
        is_draft=payload.is_draft,
        idempotency_key=payload.idempotency_key,
    )
    task = await repository.get_task_by_id(task_id)
    reveals_answer = res.status == "graded" and task.task_type in [
        "multiple_choice",
        "true_false",
    ]
    return {
        "id": res.id,
        "task_id": res.task_id,
        "user_id": res.user_id,
        "selected_option": res.selected_option,
        "text_answer": res.text_answer,
        "score": float(res.score) if res.score is not None else None,
        "status": res.status,
        "teacher_feedback": res.teacher_feedback,
        "submitted_at": res.submitted_at,
        "idempotency_key": res.idempotency_key,
        "correct_option": task.correct_option if reveals_answer else None,
        "is_correct": (
            bool(
                res.selected_option
                and task.correct_option
                and res.selected_option.casefold() == task.correct_option.casefold()
            )
            if reveals_answer
            else None
        ),
    }


@router.put("/submissions/{submission_id}/review")
async def review_submission(
    submission_id: str,
    payload: GradeReviewInputSchema,
    current_user: CurrentUser = Depends(
        require_role(["teacher", "admin", "super_admin"])
    ),
    repository: AssessmentRepository = Depends(get_assessment_repository),
    course_repository: CourseRepository = Depends(get_course_repository),
):
    """Atribui nota e comentário a um exercício discursivo (BOLA-safe)."""
    use_case = GradeSubmissionUseCase(repository, course_repository)
    res = await use_case.execute(
        submission_id=submission_id,
        score=payload.score,
        teacher_feedback=payload.teacher_comment,
        teacher_id=current_user.id,
        teacher_role=current_user.role,
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


@router.post("", status_code=status.HTTP_201_CREATED)
async def create_task(
    payload: TaskCreateInputSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "admin", "super_admin"])),
    assessment_repository: AssessmentRepository = Depends(get_assessment_repository),
    course_repository: CourseRepository = Depends(get_course_repository),
):
    """Cria uma nova tarefa/atividade em uma lição (BOLA-safe)."""
    use_case = CreateTaskUseCase(assessment_repository, course_repository)
    task = await use_case.execute(
        course_id=payload.course_id,
        lesson_id=payload.lesson_id,
        title=payload.title,
        task_type=payload.task_type,
        description=payload.description,
        options=payload.options,
        correct_option=payload.correct_option,
        max_attempts=payload.max_attempts,
        passing_score=payload.passing_score,
        current_user_id=current_user.id,
        current_user_role=current_user.role,
    )
    return {
        "status": "success",
        "data": {
            "id": task.id,
            "course_id": task.course_id,
            "lesson_id": task.lesson_id,
            "title": task.title,
            "task_type": task.task_type,
            "description": task.description,
            "options": task.options,
            "max_attempts": task.max_attempts,
            "passing_score": float(task.passing_score) if task.passing_score else None,
        }
    }


@router.patch("/{task_id}")
async def update_task(
    task_id: str,
    payload: TaskUpdateInputSchema,
    current_user: CurrentUser = Depends(require_role(["teacher", "admin", "super_admin"])),
    assessment_repository: AssessmentRepository = Depends(get_assessment_repository),
    course_repository: CourseRepository = Depends(get_course_repository),
):
    """Atualiza as informações de uma tarefa/atividade existente (BOLA-safe)."""
    use_case = UpdateTaskUseCase(assessment_repository, course_repository)
    task = await use_case.execute(
        task_id=task_id,
        task_data=payload.model_dump(exclude_unset=True),
        current_user_id=current_user.id,
        current_user_role=current_user.role,
    )
    return {
        "status": "success",
        "data": {
            "id": task.id,
            "course_id": task.course_id,
            "lesson_id": task.lesson_id,
            "title": task.title,
            "task_type": task.task_type,
            "description": task.description,
            "options": task.options,
            "max_attempts": task.max_attempts,
            "passing_score": float(task.passing_score) if task.passing_score else None,
        }
    }


@router.delete("/{task_id}")
async def delete_task(
    task_id: str,
    current_user: CurrentUser = Depends(require_role(["teacher", "admin", "super_admin"])),
    assessment_repository: AssessmentRepository = Depends(get_assessment_repository),
    course_repository: CourseRepository = Depends(get_course_repository),
):
    """Exclui logicamente uma tarefa/atividade (BOLA-safe)."""
    use_case = DeleteTaskUseCase(assessment_repository, course_repository)
    await use_case.execute(
        task_id=task_id,
        current_user_id=current_user.id,
        current_user_role=current_user.role,
    )
    return {"status": "success", "message": "Tarefa excluída logicamente com sucesso."}
