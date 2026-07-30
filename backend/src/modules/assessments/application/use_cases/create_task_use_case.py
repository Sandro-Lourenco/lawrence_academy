from decimal import Decimal
from typing import Optional, Dict, Any
from src.modules.assessments.domain.entities import Task
from src.modules.assessments.domain.repositories import AssessmentRepository
from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import AuthorizationError, NotFoundError

class CreateTaskUseCase:
    """Caso de uso para professores/administradores criarem tarefas em lições."""

    def __init__(
        self, assessment_repo: AssessmentRepository, course_repo: CourseRepository
    ):
        self.assessment_repo = assessment_repo
        self.course_repo = course_repo

    async def execute(
        self,
        course_id: str,
        lesson_id: str,
        title: str,
        task_type: str,
        description: Optional[str],
        options: Optional[Dict[str, Any]],
        correct_option: Optional[str],
        max_attempts: int,
        passing_score: Optional[Decimal],
        current_user_id: str,
        current_user_role: str,
    ) -> Task:
        # Validar curso e obter instrutor para verificar autoridade
        if current_user_role == "teacher":
            instructor_id = await self.course_repo.get_instructor_id(course_id)
            if not instructor_id:
                raise NotFoundError("Curso não encontrado.")
            if instructor_id != current_user_id:
                raise AuthorizationError("Acesso negado. Você não é o instrutor deste curso.")

        lesson = await self.course_repo.get_lesson_by_id(course_id, lesson_id)
        if not lesson:
            raise NotFoundError("Aula não encontrada.")

        task = Task(
            id="",
            course_id=course_id,
            lesson_id=lesson_id,
            title=title,
            task_type=task_type,
            description=description,
            options=options,
            correct_option=correct_option,
            max_attempts=max_attempts,
            passing_score=passing_score,
        )
        return await self.assessment_repo.save_task(task)
