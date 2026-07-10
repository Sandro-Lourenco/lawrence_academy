from typing import List, Optional
from src.shared import database
from src.core.entities.course import Course
from src.core.exceptions import EntityNotFoundException

class CourseRepository:
    """Repositório de persistência para as entidades do agregado de Cursos."""

    @staticmethod
    def get_published() -> List[Course]:
        """Busca todos os cursos com status 'published' que não sofreram soft delete."""
        res = database.db.table("courses") \
            .select("*, modules(*, lessons(*))") \
            .eq("status", "published") \
            .is_("deleted_at", "null") \
            .execute()
            
        return [Course(**item) for item in res.data]

    @staticmethod
    def get_by_id(course_id: str) -> Optional[Course]:
        """Busca um curso específico pelo ID (incluindo módulos e aulas) se não estiver deletado."""
        res = database.db.table("courses") \
            .select("*, modules(*, lessons(*))") \
            .eq("id", course_id) \
            .is_("deleted_at", "null") \
            .maybeSingle() \
            .execute()
            
        if not res.data:
            return None
            
        return Course(**res.data)

    @staticmethod
    def get_by_slug(slug: str) -> Optional[Course]:
        """Busca um curso específico pelo slug (incluindo módulos e aulas) se não estiver deletado."""
        res = database.db.table("courses") \
            .select("*, modules(*, lessons(*))") \
            .eq("slug", slug) \
            .is_("deleted_at", "null") \
            .maybeSingle() \
            .execute()
            
        if not res.data:
            return None
            
        return Course(**res.data)

    @staticmethod
    def get_instructor_id(course_id: str) -> Optional[str]:
        """Recupera apenas o ID do instrutor associado ao curso."""
        res = database.db.table("courses") \
            .select("instructor_id") \
            .eq("id", course_id) \
            .maybeSingle() \
            .execute()
            
        if not res.data:
            return None
        return res.data["instructor_id"]

    @staticmethod
    def create(course_data: dict) -> Course:
        """Cria um novo curso no banco de dados."""
        res = database.db.table("courses").insert(course_data).execute()
        if not res.data:
            raise ValueError("Falha ao criar o curso.")
        return Course(**res.data[0])

    @staticmethod
    def update(course_id: str, course_data: dict) -> Course:
        """Atualiza os dados de um curso existente."""
        res = database.db.table("courses") \
            .update(course_data) \
            .eq("id", course_id) \
            .execute()
            
        if not res.data:
            raise EntityNotFoundException("Curso não encontrado para atualização.")
        return Course(**res.data[0])

    @staticmethod
    def soft_delete(course_id: str) -> Course:
        """Marca logicamente um curso como excluído (soft delete)."""
        res = database.db.table("courses") \
            .update({"deleted_at": "now()"}) \
            .eq("id", course_id) \
            .execute()
            
        if not res.data:
            raise EntityNotFoundException("Curso não encontrado para deleção lógica.")
        return Course(**res.data[0])
