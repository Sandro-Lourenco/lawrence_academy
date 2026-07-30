from src.modules.assessments.domain.repositories import AssessmentRepository
from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import AuthorizationError, NotFoundError

class DeleteTaskUseCase:
    """Caso de uso para professores/administradores excluírem logicamente tarefas."""

    def __init__(
        self, assessment_repo: AssessmentRepository, course_repo: CourseRepository
    ):
        self.assessment_repo = assessment_repo
        self.course_repo = course_repo

    async def execute(
        self,
        task_id: str,
        current_user_id: str,
        current_user_role: str,
    ) -> None:
        # Recuperar a tarefa existente para verificar a autoridade
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

        await self.assessment_repo.delete_task(task_id)
