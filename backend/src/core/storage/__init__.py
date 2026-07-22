"""
StorageRepository Protocol — abstração de storage separada do domínio de Courses.

Segue Clean Architecture: Domain não depende de infraestrutura.
Este módulo é injetado via DI nas camadas de Application (UseCases).
"""

from typing import Protocol, Optional


class StorageRepository(Protocol):
    """Contrato de repositório de storage para geração de URLs assinadas e gerenciamento de jobs."""

    async def generate_signed_upload_url(self, storage_path: str) -> str:
        """
        Gera uma URL pré-assinada para upload direto ao bucket raw-videos.

        Nota sobre expiração:
            O Supabase Storage define a validade da URL pré-assinada de upload como
            **2 horas** (7200 segundos) por padrão, sem configuração no SDK Python atual.
            Não é possível alterar esse valor via create_signed_upload_url.

        Nota sobre upload resumível:
            O Supabase TUS v1 (upload resumível) está em fase experimental.
            Por ora, usa-se upload simples (PUT) compatível com arquivos até 2GB.
            Avaliar habilitação do TUS em sprint futura para suporte a arquivos maiores.

        Args:
            storage_path: Caminho completo no bucket (gerado pelo backend).
                Formato: uploads/{course_id}/{upload_id}/{lesson_id}.mp4
                - Nunca conter '..' ou separadores de path do cliente.
                - Gerado exclusivamente pelo backend com UUID para evitar sobrescrita.

        Returns:
            URL assinada (não logar esta URL; contém token temporário).
        """
        ...

    async def create_upload_job(
        self,
        lesson_id: str,
        course_id: str,
        initiated_by: str,
        idempotency_key: str,
        raw_video_path: str,
    ) -> str:
        """
        Registra uma nova intenção de upload em video_processing_jobs com status upload_pending.

        A trigger do Supabase Storage (handle_storage_video_upload) irá atualizar
        automaticamente o status para 'uploaded' quando o arquivo existir no bucket.

        Args:
            lesson_id: UUID da aula.
            course_id: UUID do curso.
            initiated_by: user_id do professor.
            idempotency_key: Chave única por tentativa de upload.
            raw_video_path: Path completo no bucket.

        Returns:
            job_id (UUID) do job criado.
        """
        ...

    async def get_upload_job_by_idempotency_key(
        self, idempotency_key: str
    ) -> Optional[dict]:
        """
        Busca um job existente por idempotency_key.

        Args:
            idempotency_key: Chave única da tentativa.

        Returns:
            Dicionário com dados do job ou None se não existir.
        """
        ...
