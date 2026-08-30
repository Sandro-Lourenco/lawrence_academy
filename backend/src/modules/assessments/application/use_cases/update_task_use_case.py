from src.modules.assessments.domain.entities import Task
from src.modules.assessments.domain.repositories import AssessmentRepository
from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import AuthorizationError, NotFoundError
from src.modules.assessments.domain.task_validation import validate_task_definition

class UpdateTaskUseCase:
    """Caso de uso para professores/administradores atualizarem tarefas em lições."""

    def __init__(
        self, assessment_repo: AssessmentRepository, course_repo: CourseRepository
    ):
        self.assessment_repo = assessment_repo
        self.course_repo = course_repo

    async def execute(
        self,
        task_id: str,
        task_data: dict,
        current_user_id: str,
        current_user_role: str,
    ) -> Task:
        # Recuperar a tarefa existente para saber a qual curso ela pertence
        task = await self.assessment_repo.get_task_by_id(task_id)
        if not task:
            raise NotFoundError("Tarefa não encontrada.")

        # Validar permissão
        if current_user_role == "teacher":
            instructor_id = await self.course_repo.get_instructor_id(task.course_id)
            if not instructor_id:
                raise NotFoundError("Curso associado à tarefa não encontrado.")
            if instructor_id != current_user_id:
                raise AuthorizationError("Acesso negado. Você não é o instrutor do curso associado.")

        # Construir tarefa atualizada
        updated_task = Task(
            id=task_id,
            course_id=task.course_id,
            lesson_id=task_data.get("lesson_id", task.lesson_id),
            title=task_data.get("title", task.title),
            task_type=task_data.get("task_type", task.task_type),
            description=task_data.get("description", task.description),
            options=task_data.get("options", task.options),
            correct_option=task_data.get("correct_option", task.correct_option),
            max_attempts=task_data.get("max_attempts", task.max_attempts),
            passing_score=task_data.get("passing_score", task.passing_score),
            created_at=task.created_at,
            updated_at=task.updated_at,
        )

        validate_task_definition(
            task_type=updated_task.task_type,
            options=updated_task.options,
            correct_option=updated_task.correct_option,
        )

        return await self.assessment_repo.save_task(updated_task)
