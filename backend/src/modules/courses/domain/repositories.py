from typing import Protocol, List, Optional
from src.modules.courses.domain.entities import Course, Lesson

class CourseRepository(Protocol):
    """Interface (Protocol) de repositório de domínio para Cursos e Aulas."""
    
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
        
    async def create(self, course: Course) -> Course:
        """Persiste um novo curso."""
        ...
        
    async def update(self, course_id: str, course: Course) -> Course:
        """Atualiza dados do curso."""
        ...
        
    async def delete(self, course_id: str) -> bool:
        """Marca o curso como removido logicamente."""
        ...
        
    async def get_lesson_by_id(self, course_id: str, lesson_id: str) -> Optional[Lesson]:
        """Recupera detalhes de uma aula específica pelo ID."""
        ...
        
    async def get_lesson_stream_path(self, course_id: str, lesson_id: str) -> Optional[str]:
        """Retorna o hls_storage_path associado a uma aula."""
        ...

    async def has_active_subscription(self, student_id: str, course_id: str) -> bool:
        """Verifica se o aluno possui assinatura ativa ou dentro do grace period para o curso."""
        ...

    async def generate_signed_url(self, storage_path: str) -> str:
        """Gera URL temporária assinada para o streaming HLS."""
        ...
