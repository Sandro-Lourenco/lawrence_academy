from typing import Dict, Any
from src.modules.assessments.domain.repositories import AssessmentRepository
from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import AuthorizationError, NotFoundError


class GetLessonTasksUseCase:
    """Caso de uso para buscar as tarefas de uma aula para um aluno específico.
    Garante as regras de acesso antes de retornar os dados (Omitindo respostas corretas).
    """

    def __init__(
        self, assessment_repo: AssessmentRepository, course_repo: CourseRepository
    ):
        self.assessment_repo = assessment_repo
        self.course_repo = course_repo

    async def execute(
        self, lesson_id: str, course_id: str, user_id: str
    ) -> Dict[str, Any]:
        """
        1. Valida a aula e o curso.
        2. Valida se o aluno tem acesso (matrícula ativa).
        3. Busca as tarefas da aula.
        4. Busca as submissões do aluno para essas tarefas.
        5. Combina e retorna os dados de forma segura (sem correct_option).
        """
        # Valida aula e acesso
        lesson = await self.course_repo.get_lesson_by_id(course_id, lesson_id)
        if not lesson:
            raise NotFoundError("Aula não encontrada.")

        has_access = await self.course_repo.has_active_subscription(
            student_id=user_id, course_id=course_id
        )
        if not has_access:
            raise AuthorizationError("Usuário não tem acesso a este curso.")

        # Busca as tarefas
        tasks = await self.assessment_repo.get_tasks_by_lesson_id(lesson_id)
        if not tasks:
            return {"tasks": [], "submissions": []}

        task_ids = [t.id for t in tasks]
        submissions = await self.assessment_repo.get_user_submissions_for_tasks(
            user_id, task_ids
        )

        # Remove dados sensíveis das tarefas antes de retornar ao client
        safe_tasks = []
        for t in tasks:
            safe_task = {
                "id": t.id,
                "lesson_id": t.lesson_id,
                "title": t.title,
                "task_type": t.task_type,
                "description": t.description,
                "options": t.options,
                "max_attempts": t.max_attempts,
                "passing_score": float(t.passing_score) if t.passing_score else None,
            }
            safe_tasks.append(safe_task)

        safe_submissions = []
        for s in submissions:
            safe_submissions.append(
                {
                    "id": s.id,
                    "task_id": s.task_id,
                    "selected_option": s.selected_option,
                    "text_answer": s.text_answer,
                    "score": float(s.score) if s.score else None,
                    "status": s.status,
                    "teacher_feedback": s.teacher_feedback,
                    "submitted_at": s.submitted_at.isoformat()
                    if s.submitted_at
                    else None,
                }
            )

        return {"tasks": safe_tasks, "submissions": safe_submissions}
