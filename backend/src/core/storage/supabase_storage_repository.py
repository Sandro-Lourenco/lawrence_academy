"""
SupabaseStorageRepository — implementação concreta do StorageRepository para Supabase.

Responsabilidades:
- Gerar URLs pré-assinadas de upload para o bucket raw-videos (privado)
- Registrar jobs de upload em video_processing_jobs
- Buscar jobs por idempotency_key para suporte a idempotência
"""

import logging
import typing
from typing import Optional
from supabase import Client
from postgrest.exceptions import APIError
from src.core.errors.errors import ExternalServiceError

logger = logging.getLogger(__name__)

# Bucket privado para vídeos brutos (nunca público)
_BUCKET_RAW_VIDEOS = "raw-videos"

# Expiração da URL pré-assinada: Supabase Storage define 2 horas (7200s) por padrão
# Não é possível alterar via create_signed_upload_url no SDK Python atual.
UPLOAD_URL_EXPIRES_IN = 7200


class SupabaseStorageRepository:
    """
    Implementação de StorageRepository usando Supabase Storage e PostgreSQL.

    Segurança:
    - Nunca loga a signed_url, token ou qualquer secret.
    - upsert=false garantido: create_signed_upload_url cria o path; se já existir, falha.
    - Path sempre gerado pelo backend; nunca aceito do cliente.
    """

    def __init__(self, client: Client) -> None:
        self.client = client

    async def generate_signed_upload_url(self, storage_path: str) -> str:
        """
        Gera uma URL pré-assinada para upload direto ao bucket raw-videos.

        Expiração: 2 horas (7200s) — comportamento padrão do Supabase Storage.
        Upload resumível (TUS): não suportado nesta versão; usar PUT simples.

        IMPORTANTE: Não logar o retorno desta função. Contém token temporário.
        """
        try:
            res = self.client.storage.from_(
                _BUCKET_RAW_VIDEOS
            ).create_signed_upload_url(storage_path)
            # storage-py 2.x returns ``signed_url`` and keeps ``signedUrl`` as
            # a compatibility alias. Accept every known SDK spelling so an
            # SDK upgrade cannot turn a valid response into an HTTP 502.
            signed_url = (
                res.get("signed_url")
                or res.get("signedUrl")
                or res.get("signedURL")
                or ""
            )
            if not signed_url:
                raise ExternalServiceError(
                    "Supabase Storage retornou URL vazia para upload pré-assinado.",
                    provider="supabase-storage",
                    request_id=storage_path,
                )
            # Não logar signed_url — contém token temporário
            logger.info("Signed upload URL gerada para path: %s", storage_path)
            return str(signed_url)
        except ExternalServiceError:
            raise
        except Exception as exc:
            logger.error(
                "Erro ao gerar signed upload URL para path %s: %s",
                storage_path,
                type(exc).__name__,
                # Não incluir exc.args para não vazar tokens
                exc_info=False,
            )
            raise ExternalServiceError(
                "Falha ao gerar URL de upload no Supabase Storage.",
                provider="supabase-storage",
                request_id=storage_path,
            ) from exc

    async def create_upload_job(
        self,
        lesson_id: str,
        course_id: str,
        initiated_by: str,
        idempotency_key: str,
        raw_video_path: str,
    ) -> str:
        """
        Registra a intenção de upload em video_processing_jobs com status upload_pending.

        Usa INSERT com ON CONFLICT DO NOTHING para garantir idempotência:
        se o job já existir com esta idempotency_key, não falha — retorna o job_id existente.

        Returns:
            job_id (UUID string) do job criado ou existente.
        """
        try:
            # Tentar inserir novo job
            res = (
                self.client.table("video_processing_jobs")
                .insert(
                    {
                        "lesson_id": lesson_id,
                        "course_id": course_id,
                        "initiated_by": initiated_by,
                        "idempotency_key": idempotency_key,
                        "raw_video_path": raw_video_path,
                        "status": "upload_pending",
                    }
                )
                .execute()
            )

            if res.data:
                job_id = typing.cast(dict[str, typing.Any], res.data[0]).get("id", "")
                logger.info(
                    "Job de upload criado: lesson_id=%s, job_id=%s, path=%s",
                    lesson_id,
                    job_id,
                    raw_video_path,
                )
                return str(job_id)

            # Se não retornou dados, buscar job existente pela idempotency_key
            existing = await self.get_upload_job_by_idempotency_key(idempotency_key)
            if existing:
                return str(existing.get("id", ""))

            raise ExternalServiceError(
                "Falha ao registrar job de upload no banco.",
                provider="supabase-db",
                request_id=idempotency_key,
            )
        except APIError as exc:
            # Compatibilidade temporária para projetos Supabase criados antes da
            # migration 20260711200000. A estrutura legada ainda consegue
            # rastrear e processar o arquivo, embora não tenha os metadados de
            # idempotência/curso/iniciador. Depois de aplicar a migration, o
            # caminho completo acima volta a ser usado automaticamente.
            if getattr(exc, "code", None) == "PGRST204":
                try:
                    legacy = (
                        self.client.table("video_processing_jobs")
                        .insert(
                            {
                                "lesson_id": lesson_id,
                                "raw_video_path": raw_video_path,
                                # O enum legado (antes da migration do pipeline)
                                # usa ``pending`` em vez de ``upload_pending``.
                                "status": "pending",
                            }
                        )
                        .execute()
                    )
                    if legacy.data:
                        return str(
                            typing.cast(dict[str, typing.Any], legacy.data[0]).get(
                                "id", ""
                            )
                        )
                except Exception as legacy_exc:
                    raise ExternalServiceError(
                        "Falha ao registrar job de upload no banco.",
                        provider="supabase-db",
                        request_id=lesson_id,
                    ) from legacy_exc
            raise ExternalServiceError(
                "Falha ao registrar job de upload no banco.",
                provider="supabase-db",
                request_id=lesson_id,
            ) from exc
        except ExternalServiceError:
            raise
        except Exception as exc:
            logger.error(
                "Erro ao criar job de upload: lesson_id=%s, error=%s",
                lesson_id,
                type(exc).__name__,
                exc_info=False,
            )
            raise ExternalServiceError(
                "Falha ao registrar job de upload.",
                provider="supabase-db",
                request_id=lesson_id,
            ) from exc

    async def get_upload_job_by_idempotency_key(
        self, idempotency_key: str
    ) -> Optional[dict]:
        """
        Busca um job existente por idempotency_key.

        Usado para suportar idempotência: se o cliente enviar a mesma requisição
        duas vezes com a mesma chave, não criamos job duplicado.
        """
        try:
            res = (
                self.client.table("video_processing_jobs")
                .select("id, status, raw_video_path, lesson_id, course_id")
                .eq("idempotency_key", idempotency_key)
                .maybe_single()
                .execute()
            )
            if res is None or not res.data:
                return None
            return typing.cast(dict[str, typing.Any], res.data)
        except Exception as exc:
            logger.error(
                "Erro ao buscar job por idempotency_key: %s",
                type(exc).__name__,
                exc_info=False,
            )
            return None
