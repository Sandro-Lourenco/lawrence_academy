from typing import Protocol, List, Optional
from src.modules.courses.domain.entities import Course, Lesson, Module


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

    async def get_instructor_id(self, course_id: str) -> Optional[str]:
        """Recupera o ID do instrutor associado ao curso."""
        ...

    async def list_all(self) -> List[Course]:
        """Lista todos os cursos publicados e não removidos logicamente."""
        ...

    async def list_by_instructor(self, instructor_id: str) -> List[Course]:
        """Lista os cursos pertencentes a um instrutor, incluindo rascunhos."""
        ...

    async def create(self, course: Course) -> Course:
        """Persiste um novo curso."""
        ...

    async def update(self, course_id: str, course: Course) -> Course:
        """Atualiza dados do curso."""
        ...

    async def delete(self, course_id: str) -> bool:
        """Marca o curso como removido logicamente."""
        ...

    async def get_lesson_by_id(
        self, course_id: str, lesson_id: str
    ) -> Optional[Lesson]:
        """Recupera detalhes de uma aula específica pelo ID."""
        ...

    async def create_lesson(self, lesson: Lesson) -> Lesson:
        """Cria uma aula em um mÃ³dulo existente."""
        ...

    async def update_lesson(self, lesson_id: str, lesson_data: dict) -> Lesson:
        """Atualiza parcialmente uma aula existente."""
        ...

    async def delete_lesson(self, lesson_id: str) -> bool:
        """Arquiva logicamente uma aula sem remover o módulo."""
        ...

    async def get_lesson_stream_path(
        self, course_id: str, lesson_id: str
    ) -> Optional[str]:
        """Retorna o hls_storage_path associado a uma aula."""
        ...

    async def get_module_by_id_and_course_id(
        self, module_id: str, course_id: str
    ) -> Optional[Module]:
        """Busca um módulo verificando course_id (BOLA-safe)."""
        ...

    async def create_module(self, module: Module) -> Module:
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
