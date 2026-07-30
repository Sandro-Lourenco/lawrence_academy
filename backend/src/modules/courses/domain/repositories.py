from typing import Protocol, List, Optional
from src.modules.courses.domain.entities import Course, Lesson, LessonBlock, Module


class CourseRepository(Protocol):
    """Interface (Protocol) de repositório de domínio para Cursos e Aulas.

    Nota: métodos de storage (gerar URLs de upload, registrar jobs) foram movidos
    para src.core.storage.StorageRepository seguindo separação de responsabilidades.
    """

    async def get_by_id(self, course_id: str) -> Optional[Course]:
        """Recupera detalhes de um curso pelo ID (com módulos e aulas)."""
        ...

    async def get_by_slug(self, slug: str) -> Optional[Course]:
        """Recupera detalhes de um curso pelo slug (com módulos e aulas)."""
        ...

    async def get_published_by_id(self, course_id: str) -> Optional[Course]: ...
    async def get_published_by_slug(self, slug: str) -> Optional[Course]: ...
    async def list_published_versions(self, *, limit: int = 50) -> List[Course]: ...
    async def get_published_lesson(self, course_id: str, lesson_id: str) -> Optional[Lesson]: ...
    async def get_published_lesson_stream_path(
        self, course_id: str, lesson_id: str
    ) -> Optional[str]: ...

    async def get_instructor_id(self, course_id: str) -> Optional[str]:
        """Recupera o ID do instrutor associado ao curso."""
        ...

    async def list_all(self) -> List[Course]:
        """Lista todos os cursos publicados e não removidos logicamente."""
        ...

    async def list_by_instructor(self, instructor_id: str) -> List[Course]:
        """Lista os cursos pertencentes a um instrutor, incluindo rascunhos."""
        ...

    async def create(
        self,
        course: Course,
        *,
        idempotency_key: str | None = None,
        request_hash: str | None = None,
    ) -> Course:
        """Persiste um novo curso."""
        ...

    async def update(
        self, course_id: str, course: Course, expected_authoring_revision: int
    ) -> Course:
        """Atualiza dados do curso."""
        ...

    async def delete(self, course_id: str) -> bool:
        """Marca o curso como removido logicamente."""
        ...

    async def get_lesson_by_id(self, course_id: str, lesson_id: str) -> Optional[Lesson]:
        """Recupera detalhes de uma aula específica pelo ID."""
        ...

    async def create_lesson(
        self,
        lesson: Lesson,
        *,
        idempotency_key: str | None = None,
        request_hash: str | None = None,
        actor_id: str | None = None,
    ) -> Lesson:
        """Cria uma aula em um mÃ³dulo existente."""
        ...

    async def update_lesson(self, lesson_id: str, lesson_data: dict) -> Lesson:
        """Atualiza parcialmente uma aula existente."""
        ...

    async def delete_lesson(self, lesson_id: str) -> bool:
        """Arquiva logicamente uma aula sem remover o módulo."""
        ...

    async def create_lesson_block(
        self,
        block: LessonBlock,
        *,
        idempotency_key: str | None = None,
        request_hash: str | None = None,
        actor_id: str | None = None,
    ) -> LessonBlock: ...
    async def update_lesson_block(self, block_id: str, data: dict) -> LessonBlock: ...
    async def get_lesson_block(
        self, course_id: str, lesson_id: str, block_id: str
    ) -> Optional[LessonBlock]: ...
    async def delete_lesson_block(self, block_id: str) -> bool: ...
    async def list_lesson_blocks(self, course_id: str, lesson_id: str) -> List[LessonBlock]: ...
    async def reorder_lesson_blocks(
        self,
        course_id: str,
        lesson_id: str,
        actor_id: str,
        block_ids: list[str],
        expected_revision: int,
    ) -> int: ...
    async def get_publication_snapshot(self, course_id: str) -> dict: ...
    async def publish_course(
        self,
        course_id: str,
        actor_id: str,
        change_summary: str | None = None,
        idempotency_key: str | None = None,
        request_hash: str | None = None,
        expected_updated_at: str | None = None,
    ) -> Course: ...
    async def list_course_versions(self, course_id: str) -> list[dict]: ...
    async def get_course_version(self, course_id: str, version_id: str) -> Optional[dict]: ...
    async def restore_course_version(
        self,
        course_id: str,
        version_id: str,
        actor_id: str,
        expected_updated_at: str,
        reason: str | None,
    ) -> Course: ...

    async def transition_course_status(
        self, course_id: str, actor_id: str, target_status: str, reason: str | None
    ) -> str: ...

    async def get_lesson_stream_path(self, course_id: str, lesson_id: str) -> Optional[str]:
        """Retorna o hls_storage_path associado a uma aula."""
        ...

    async def get_module_by_id_and_course_id(
        self, module_id: str, course_id: str
    ) -> Optional[Module]:
        """Busca um módulo verificando course_id (BOLA-safe)."""
        ...

    async def create_module(
        self,
        module: Module,
        *,
        idempotency_key: str | None = None,
        request_hash: str | None = None,
        actor_id: str | None = None,
    ) -> Module:
        """Cria um novo módulo no banco."""
        ...

    async def update_module(self, module_id: str, module_data: dict) -> Module:
        """Atualiza parcialmente um módulo."""
        ...

    async def delete_module(self, module_id: str) -> bool:
        """Deleção lógica de um módulo."""
        ...

    async def has_active_subscription(self, student_id: str, course_id: str) -> bool:
        """Verifica se o aluno possui assinatura ativa ou dentro do grace period para o curso."""
        ...

    async def generate_signed_url(self, storage_path: str) -> str:
        """Gera URL temporária assinada para o streaming HLS."""
        ...

    async def download_hls_asset(self, storage_path: str) -> bytes:
        """Lê um manifesto ou segmento do bucket HLS privado."""
        ...
