from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import AuthorizationError, NotFoundError

class GetLessonStreamUseCase:
    """Caso de Uso para recuperar a URL de streaming HLS assinada de forma BOLA-safe."""

    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def execute(self, user_id: str, role: str, course_id: str, lesson_id: str) -> str:
        # 1. Recuperar o caminho de armazenamento do HLS da aula
        storage_path = await self.repository.get_lesson_stream_path(course_id, lesson_id)
        if not storage_path:
            raise NotFoundError(f"Caminho HLS não encontrado para a aula {lesson_id}.")

        # 2. Controlar Autorização e Acesso
        if role in ["admin", "teacher"]:
            # Admin e professores têm acesso irrestrito
            return await self.repository.generate_signed_url(storage_path)

        # Se for aluno, verificar se há assinatura ativa (incluindo grace period)
        has_access = await self.repository.has_active_subscription(user_id, course_id)
        if not has_access:
            raise AuthorizationError("Acesso negado. Assinatura inativa para este curso.")

        # 3. Gerar URL assinada
        return await self.repository.generate_signed_url(storage_path)
