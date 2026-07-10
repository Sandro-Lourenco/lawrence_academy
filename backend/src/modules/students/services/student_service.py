from typing import Dict, Any
from src.shared import database
from src.core.exceptions import EntityNotFoundException

class StudentService:
    """Serviço que gerencia as operações de banco de dados do Supabase para Alunos (Profiles)."""

    async def get_student_profile(self, student_id: str) -> Dict[str, Any]:
        """Busca o perfil de um aluno pelo seu ID único."""
        res = database.db.table("profiles") \
            .select("*") \
            .eq("id", student_id) \
            .maybeSingle() \
            .execute()
            
        if not res.data:
            raise EntityNotFoundException(
                message=f"Perfil do aluno com ID {student_id} não encontrado."
            )
            
        return res.data

    async def update_student_profile(self, student_id: str, profile_data: Dict[str, Any]) -> Dict[str, Any]:
        """Atualiza os dados de perfil de um aluno."""
        if not profile_data:
            # Se não houver nada para atualizar, apenas retorna o perfil atual
            return await self.get_student_profile(student_id)
            
        res = database.db.table("profiles") \
            .update(profile_data) \
            .eq("id", student_id) \
            .execute()
            
        if not res.data:
            raise EntityNotFoundException(
                message=f"Perfil do aluno com ID {student_id} não encontrado para atualização."
            )
            
        return res.data[0]
