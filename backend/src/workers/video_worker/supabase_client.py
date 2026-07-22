import os
import logging
from typing import Optional, Any, Dict
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

# Configuração de logs estruturados com Job Correlation ID
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] [job_id=%(job_id)s] %(message)s",
)


class JobLoggerAdapter(logging.LoggerAdapter):
    from typing import MutableMapping

    def process(
        self, msg: str, kwargs: MutableMapping[str, Any]
    ) -> tuple[str, MutableMapping[str, Any]]:
        if self.extra:
            kwargs["extra"] = {"job_id": self.extra.get("job_id", "system")}
        else:
            kwargs["extra"] = {"job_id": "system"}
        return msg, kwargs


logger = JobLoggerAdapter(logging.getLogger("video-worker"), {"job_id": "system"})

SUPABASE_URL = os.getenv("SUPABASE_URL") or "https://placeholder-url.supabase.co"
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY") or "placeholder-key"

# Cliente utilizando a Service Key para bypass de RLS nas atualizações administrativas
supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)


def get_next_job() -> Optional[Dict[str, Any]]:
    """
    Busca o próximo job elegível para processamento ou retentativa.
    Elegível se status = 'uploaded' ou status = 'processing_pending' e next_retry_at <= NOW().
    """
    try:
        # Busca prioritariamente jobs recém-carregados ou pendentes de retry vencidos
        res = (
            supabase.table("video_processing_jobs")
            .select("*, lessons(*)")
            .or_(
                "status.eq.uploaded,and(status.eq.processing_pending,next_retry_at.lte.now())"
            )
            .order("created_at")
            .limit(1)
            .execute()
        )

        if res.data and len(res.data) > 0:
            import typing

            return typing.cast(Dict[str, Any], res.data[0])
    except Exception as e:
        logger.error(f"Erro ao buscar próximo job: {e}")
    return None


def update_job_status(
    job_id: str,
    status: str,
    error_message: Optional[str] = None,
    retry_count: Optional[int] = None,
    next_retry_at: Optional[str] = None,
    real_size_bytes: Optional[int] = None,
    video_metadata: Optional[Dict[str, Any]] = None,
) -> Any:
    """Atualiza de forma robusta e granular os estados e métricas do job no banco de dados."""
    data: Dict[str, Any] = {"status": status, "updated_at": "now()"}
    if error_message is not None:
        data["error_message"] = error_message
    if retry_count is not None:
        data["retry_count"] = retry_count
    if next_retry_at is not None:
        data["next_retry_at"] = next_retry_at
    if real_size_bytes is not None:
        data["real_size_bytes"] = real_size_bytes
    if video_metadata is not None:
        data["video_metadata"] = video_metadata

    # Registrar marcas temporais nos estados específicos
    if status == "processing":
        data["processing_started_at"] = "now()"
    elif status == "completed":
        data["completed_at"] = "now()"

    job_logger = JobLoggerAdapter(logging.getLogger("video-worker"), {"job_id": job_id})
    job_logger.info(f"Atualizando status do job para: {status}")

    try:
        return (
            supabase.table("video_processing_jobs")
            .update(data)
            .eq("id", job_id)
            .execute()
        )
    except Exception as e:
        job_logger.error(f"Falha ao atualizar status no banco: {e}")
        raise


def download_raw_video(storage_path: str, local_dest_path: str) -> bytes:
    """Realiza o download do vídeo bruto do Supabase Storage e retorna os bytes do arquivo."""
    try:
        res = supabase.storage.from_("raw-videos").download(storage_path)
        with open(local_dest_path, "wb") as f:
            f.write(res)
        return res
    except Exception as e:
        logger.error(f"Erro ao baixar raw video '{storage_path}': {e}")
        raise


def upload_processed_file(
    local_file_path: str, storage_dest_path: str, content_type: str
):
    """Faz o upload de um arquivo final processado para o bucket seguro lessons-hls (privado)."""
    try:
        with open(local_file_path, "rb") as f:
            supabase.storage.from_("lessons-hls").upload(
                path=storage_dest_path,
                file=f,
                file_options={
                    "cache-control": "31536000",
                    "content-type": content_type,
                    "upsert": "false",  # Impedir sobrescritas acidentais
                },
            )
    except Exception as e:
        logger.error(
            f"Erro ao fazer upload do arquivo processado '{storage_dest_path}': {e}"
        )
        raise


def get_mime_type(file_path: str) -> str:
    if file_path.endswith(".m3u8"):
        return "application/x-mpegURL"
    if file_path.endswith(".ts"):
        return "video/MP2T"
    if file_path.endswith(".vtt"):
        return "text/vtt"
    if file_path.endswith(".png"):
        return "image/png"
    if file_path.endswith(".jpg") or file_path.endswith(".jpeg"):
        return "image/jpeg"
    return "application/octet-stream"


def activate_lesson_video(
    lesson_id: str, hls_storage_path: str, duration: int, ai_summary: dict
):
    """
    Ativa a nova versão do vídeo de forma atômica no banco de dados.
    A lição passa a apontar para o novo manifesto de forma limpa e segura.
    """
    try:
        return (
            supabase.table("lessons")
            .update(
                {
                    "hls_storage_path": hls_storage_path,
                    "duration_seconds": duration,
                    "ai_summary": ai_summary,
                    "status": "published",
                    "updated_at": "now()",
                    "pending_raw_video_path": None,
                    "pending_upload_job_id": None,
                }
            )
            .eq("id", lesson_id)
            .execute()
        )
    except Exception as e:
        logger.error(f"Erro ao ativar lição {lesson_id}: {e}")
        raise
