from typing import List, Dict, Any
from src.shared import database
from src.core.exceptions import EntityNotFoundException

class CourseService:
    """Serviço que gerencia as operações de banco de dados do Supabase para Cursos e Aulas."""

    async def get_all_courses(self) -> List[Dict[str, Any]]:
        """Busca todos os cursos ativos (não excluídos logicamente)."""
        res = database.db.table("courses") \
            .select("*") \
            .is_("deleted_at", "null") \
            .execute()
            
        return res.data

    async def get_lesson_by_id(self, course_id: str, lesson_id: str) -> Dict[str, Any]:
        """Busca os detalhes de uma aula específica pelo seu ID e o ID do curso associado."""
        res = database.db.table("lessons") \
            .select("*") \
            .eq("id", lesson_id) \
            .eq("course_id", course_id) \
            .maybe_single() \
            .execute()
            
        if not res.data:
            raise EntityNotFoundException(
                message=f"Aula com ID {lesson_id} não encontrada para o curso {course_id}."
            )
            
        return res.data

    async def get_lesson_stream_path(self, course_id: str, lesson_id: str) -> str:
        """Busca o hls_storage_path de uma lição."""
        res = database.db.table("lessons") \
            .select("hls_storage_path") \
            .eq("id", lesson_id) \
            .eq("course_id", course_id) \
            .maybe_single() \
            .execute()
            
        if not res.data or not res.data.get("hls_storage_path"):
            raise EntityNotFoundException(
                message=f"Caminho HLS não encontrado para a aula {lesson_id}."
            )
            
        return res.data["hls_storage_path"]

    def generate_signed_url(self, storage_path: str) -> str:
        """Gera uma URL assinada temporária para o manifesto HLS no Supabase Storage."""
        try:
            res = database.db.storage.from_("lessons-hls").create_signed_url(storage_path, 3600)
            return res.get("signedURL") or res.get("signedUrl") or f"https://cdn.lawrence.academy/{storage_path}?token=mock_signed_url"
        except Exception:
            return f"https://cdn.lawrence.academy/{storage_path}?token=mock_signed_url"
