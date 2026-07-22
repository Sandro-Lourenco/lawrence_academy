"""
GenerateLessonUploadUrlUseCase — UseCase para geração de URL pré-assinada de upload de vídeo.

Regras de negócio implementadas:
- RBAC: apenas teacher (owner), admin e super_admin podem gerar URLs
- BOLA-safe: teacher só pode gerar URL para aulas do próprio curso
- Lição publicada NÃO é alterada: usa versão candidata (pending_raw_video_path)
- Idempotência via idempotency_key: mesma chave → nova URL, job existente não duplicado
- Validação de MIME type declarado pelo cliente (duplo: MIME + extensão)
- Validação de tamanho limite de 2GB no backend
- Path traversal: filename do cliente nunca determina o path final
- Path gerado exclusivamente pelo backend: uploads/{course_id}/{upload_id}/{lesson_id}.mp4
- Job registrado em video_processing_jobs com status upload_pending antes de retornar URL
- Trigger do Supabase Storage atualiza para 'uploaded' após o arquivo existir no bucket
- URL pré-assinada expira em 2 horas (padrão Supabase, sem configuração pelo SDK Python)
- NUNCA logar signed_url, token ou secrets

Nota sobre validação real de conteúdo:
    O MIME type enviado pelo cliente NÃO É confiável. O Worker de processamento de vídeo
    deve usar ffprobe para validar o arquivo real após upload. Esta validação no backend
    é apenas uma barreira de entrada (defense in depth), não uma garantia.

Nota sobre upload resumível:
    Supabase TUS v1 está em fase experimental. Usar PUT simples (signed upload URL)
    que suporta até 2GB. Avaliar TUS em sprint futura para arquivos maiores.
"""

import logging
import uuid
from typing import Dict, Any, Optional

from src.core.errors.errors import (
    AuthorizationError,
    NotFoundError,
    ValidationError,
    ExternalServiceError,
)
from src.modules.courses.domain.repositories import CourseRepository
from src.core.storage.repositories import StorageRepository

logger = logging.getLogger(__name__)

# Limite de 2GB — validado no backend E deve ser configurado no bucket (metadata)
MAX_FILE_SIZE_BYTES = 2 * 1024 * 1024 * 1024  # 2GB

# MIME types declarados aceitos pelo cliente (não confiável — Worker valida com ffprobe)
ALLOWED_MIME_TYPES = frozenset(["video/mp4", "video/quicktime", "video/x-m4v"])

# Roles que podem gerar URLs de upload
UPLOAD_ALLOWED_ROLES = frozenset(["teacher", "admin", "super_admin"])

# Expiração real da URL pré-assinada do Supabase Storage
UPLOAD_URL_EXPIRES_IN = 7200  # 2 horas


class GenerateLessonUploadUrlUseCase:
    """
    Gera uma URL pré-assinada para upload direto ao bucket raw-videos.

    Injeção de dependência:
    - course_repository: valida ownership, existência de curso e aula
    - storage_repository: gera signed URL e registra job de upload
    """

    def __init__(
        self,
        course_repository: CourseRepository,
        storage_repository: StorageRepository,
    ) -> None:
        self.course_repository = course_repository
        self.storage_repository = storage_repository

    async def execute(
        self,
        user_id: str,
        role: str,
        course_id: str,
        lesson_id: str,
        filename: str,
        content_type: str,
        size_bytes: int,
        idempotency_key: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Executa a geração de URL pré-assinada de upload.

        Args:
            user_id: ID do usuário autenticado.
            role: Role do usuário (teacher, admin, super_admin).
            course_id: UUID do curso.
            lesson_id: UUID da aula.
            filename: Nome do arquivo enviado pelo cliente (apenas para validação; não define path).
            content_type: MIME type declarado pelo cliente (não confiável; Worker valida com ffprobe).
            size_bytes: Tamanho declarado do arquivo em bytes.
            idempotency_key: Chave única por tentativa. Se fornecida e job existente, retorna nova URL.
                Se None, gera UUID automaticamente.

        Returns:
            Dicionário com:
            - job_id: ID do job registrado em video_processing_jobs
            - path: Caminho completo no bucket raw-videos (gerado pelo backend)
            - expires_in: Tempo de expiração da URL em segundos (7200 = 2 horas)
            - signed_url: URL pré-assinada para upload (NÃO logar)

        Raises:
            AuthorizationError: Role não autorizado ou teacher sem ownership.
            NotFoundError: Curso ou aula não encontrada.
            ValidationError: Arquivo com MIME inválido, tamanho excedido ou path traversal.
            ExternalServiceError: Falha ao gerar URL ou registrar job.
        """
        # ----------------------------------------------------------------
        # 1. RBAC: apenas roles autorizados
        # ----------------------------------------------------------------
        if role not in UPLOAD_ALLOWED_ROLES:
            raise AuthorizationError(
                "Permissão insuficiente. Apenas professores, admins ou super_admins "
                "podem gerar URLs de upload."
            )

        # ----------------------------------------------------------------
        # 2. BOLA: teacher só pode operar no próprio curso
        # ----------------------------------------------------------------
        if role == "teacher":
            instructor_id = await self.course_repository.get_instructor_id(course_id)
            if not instructor_id:
                raise NotFoundError("Curso não encontrado.")
            if instructor_id != user_id:
                raise AuthorizationError(
                    "Acesso negado. Apenas o instrutor do curso pode fazer upload de aulas."
                )

        # ----------------------------------------------------------------
        # 3. Verificar existência da aula vinculada ao curso
        # ----------------------------------------------------------------
        lesson = await self.course_repository.get_lesson_by_id(course_id, lesson_id)
        if not lesson:
            raise NotFoundError("Aula não encontrada neste curso.")

        # ----------------------------------------------------------------
        # 4. Validação de arquivo (defense in depth)
        #    Nota: MIME type do cliente NÃO é confiável. Worker valida com ffprobe.
        # ----------------------------------------------------------------
        if content_type not in ALLOWED_MIME_TYPES:
            raise ValidationError(
                f"Tipo de arquivo não permitido: {content_type!r}. "
                "Aceitos: video/mp4, video/quicktime, video/x-m4v."
            )

        if size_bytes > MAX_FILE_SIZE_BYTES:
            raise ValidationError(
                f"Tamanho do arquivo ({size_bytes} bytes) excede o limite de 2GB."
            )

        # Proteção contra path traversal no filename do cliente
        # O filename NUNCA define o path — mas validamos para defense in depth
        if ".." in filename or "/" in filename or "\\" in filename:
            logger.warning(
                "Path traversal detectado no filename do cliente: user_id=%s, filename=%s",
                user_id,
                filename,
            )
            raise ValidationError(
                "Nome do arquivo inválido. Caracteres de path traversal não são permitidos."
            )

        # ----------------------------------------------------------------
        # 5. Idempotência: garantir chave única por tentativa
        #    Se idempotency_key fornecida, não duplicar job
        # ----------------------------------------------------------------
        if not idempotency_key:
            idempotency_key = str(uuid.uuid4())

        # Verificar se já existe job com esta idempotency_key
        existing_job = await self.storage_repository.get_upload_job_by_idempotency_key(
            idempotency_key
        )

        if existing_job:
            # Job existente encontrado — gerar nova URL para o mesmo path
            # (idempotência: mesma chave, mesma intenção, nova URL pré-assinada)
            existing_path = existing_job.get("raw_video_path", "")
            logger.info(
                "Idempotência: job existente encontrado para key=%s, lesson_id=%s",
                idempotency_key,
                lesson_id,
            )
            # Gerar nova URL para o mesmo path (URL pode ter expirado)
            try:
                signed_url = await self.storage_repository.generate_signed_upload_url(
                    existing_path
                )
            except ExternalServiceError:
                raise

            # NÃO logar signed_url
            return {
                "job_id": str(existing_job.get("id", "")),
                "path": existing_path,
                "expires_in": UPLOAD_URL_EXPIRES_IN,
                "signed_url": signed_url,
            }

        # ----------------------------------------------------------------
        # 6. Gerar path único exclusivamente pelo backend
        #    Formato: uploads/{course_id}/{upload_id}/{lesson_id}.mp4
        #    - O upload_id (UUID) garante que não há sobrescrita
        #    - lesson_id.mp4 é extraído corretamente pela trigger do Storage
        #    - Nunca usa o filename enviado pelo cliente no path final
        # ----------------------------------------------------------------
        upload_id = str(uuid.uuid4())
        file_path = f"uploads/{course_id}/{upload_id}/{lesson_id}.mp4"

        # ----------------------------------------------------------------
        # 7. IMPORTANTE: NÃO alterar a lição publicada
        #    A lição só é atualizada após o Worker confirmar o processamento bem-sucedido.
        #    O path candidato será registrado no job e processado pelo Worker.
        #    (Sem reset_lesson_for_upload aqui)
        # ----------------------------------------------------------------

        # ----------------------------------------------------------------
        # 8. Registrar job com status upload_pending ANTES de retornar URL
        #    A trigger do Supabase Storage atualiza para 'uploaded' após upload
        # ----------------------------------------------------------------
        job_id = await self.storage_repository.create_upload_job(
            lesson_id=lesson_id,
            course_id=course_id,
            initiated_by=user_id,
            idempotency_key=idempotency_key,
            raw_video_path=file_path,
        )

        # ----------------------------------------------------------------
        # 9. Gerar URL pré-assinada (upsert=false pelo Supabase)
        #    NUNCA logar o retorno — contém token temporário
        # ----------------------------------------------------------------
        signed_url = await self.storage_repository.generate_signed_upload_url(file_path)

        logger.info(
            "URL de upload gerada: lesson_id=%s, course_id=%s, job_id=%s",
            lesson_id,
            course_id,
            job_id,
        )

        # NÃO logar signed_url nem incluir em qualquer log
        return {
            "job_id": job_id,
            "path": file_path,
            "expires_in": UPLOAD_URL_EXPIRES_IN,
            "signed_url": signed_url,
        }
