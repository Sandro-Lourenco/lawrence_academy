import os
import logging
import socket
from datetime import datetime, timedelta, timezone
from typing import Optional, Any, Dict, cast
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()


# Configuração de logs estruturados com Job Correlation ID
class JobIdFilter(logging.Filter):
    def filter(self, record):
        if not hasattr(record, "job_id"):
            record.job_id = "system"
        return True


root_logger = logging.getLogger()
# Evita adicionar múltiplos handlers caso o módulo seja recarregado
if not root_logger.handlers:
    root_logger.setLevel(logging.INFO)
    handler = logging.StreamHandler()
    handler.setFormatter(
        logging.Formatter("%(asctime)s [%(levelname)s] [job_id=%(job_id)s] %(message)s")
    )
    handler.addFilter(JobIdFilter())
    root_logger.addHandler(handler)


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
SUPABASE_SERVICE_KEY = (
    os.getenv("SUPABASE_SERVICE_ROLE_KEY") or os.getenv("SUPABASE_SERVICE_KEY") or "placeholder-key"
)
WORKER_ID = os.getenv("VIDEO_WORKER_ID") or f"{socket.gethostname()}:{os.getpid()}"
JOB_LEASE_SECONDS = max(
    60,
    min(3600, int(os.getenv("VIDEO_JOB_LEASE_SECONDS", "1800"))),
)

# Cliente utilizando a Service Key para bypass de RLS nas atualizações administrativas
supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)


def validate_worker_configuration() -> None:
    """Fail fast instead of leaving uploaded jobs behind a broken worker."""
    missing = []
    if SUPABASE_URL == "https://placeholder-url.supabase.co":
        missing.append("SUPABASE_URL")
    if SUPABASE_SERVICE_KEY == "placeholder-key":
        missing.append("SUPABASE_SERVICE_ROLE_KEY")
    if missing:
        raise RuntimeError(
            "Configuração obrigatória ausente no video worker: " + ", ".join(missing)
        )


def get_next_job() -> Optional[Dict[str, Any]]:
    """
    Busca o próximo job elegível para processamento ou retentativa.
    Elegível se status = 'uploaded' ou status = 'processing_pending' e next_retry_at <= NOW().
    """
    try:
        # Busca prioritariamente jobs recém-carregados ou pendentes de retry vencidos
        res = supabase.rpc(
            "claim_next_video_processing_job",
            {
                "p_worker_id": WORKER_ID,
                "p_lease_seconds": JOB_LEASE_SECONDS,
            },
        ).execute()

        if isinstance(res.data, list) and res.data:
            return cast(Dict[str, Any], res.data[0])
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
    now_dt = datetime.now(timezone.utc)
    now = now_dt.isoformat()
    data: Dict[str, Any] = {"status": status, "updated_at": now}
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
        data["processing_started_at"] = now
    elif status == "completed":
        data["completed_at"] = now

    in_flight_statuses = {
        "processing",
        "validating",
        "transcoding",
        "generating_hls",
        "generating_thumbnail",
    }
    if status in in_flight_statuses:
        data["lease_expires_at"] = (now_dt + timedelta(seconds=JOB_LEASE_SECONDS)).isoformat()
    else:
        data["lease_expires_at"] = None
        data["claimed_by"] = None

    job_logger = JobLoggerAdapter(logging.getLogger("video-worker"), {"job_id": job_id})
    job_logger.info(f"Atualizando status do job para: {status}")

    try:
        query = (
            supabase.table("video_processing_jobs")
            .update(data)
            .eq("id", job_id)
            .eq("claimed_by", WORKER_ID)
        )
        response = query.execute()
        if isinstance(getattr(response, "data", None), list) and not response.data:
            raise RuntimeError(
                f"Lease lost while updating video job {job_id}; refusing stale write"
            )
        return response
    except Exception as e:
        job_logger.error(f"Falha ao atualizar status no banco: {e}")
        raise


def download_raw_video(storage_path: str, local_dest_path: str) -> int:
    """Realiza o download do vídeo bruto do Supabase Storage e retorna os bytes do arquivo."""
    try:
        res = supabase.storage.from_("raw-videos").download(storage_path)
        with open(local_dest_path, "wb") as f:
            f.write(res)
        return os.path.getsize(local_dest_path)
    except Exception as e:
        logger.error(f"Erro ao baixar raw video '{storage_path}': {e}")
        raise


def delete_raw_video(storage_path: str) -> None:
    """Remove o original somente depois da ativação atômica da versão HLS."""
    try:
        supabase.storage.from_("raw-videos").remove([storage_path])
    except Exception as e:
        logger.error(f"Erro ao remover raw video já processado '{storage_path}': {e}")
        raise


def upload_processed_file(local_file_path: str, storage_dest_path: str, content_type: str):
    """Upload idempotente de uma saída candidata no bucket privado.

    A versão só é ativada depois que todos os arquivos terminam. O upsert torna
    a retentativa capaz de continuar após um upload parcialmente concluído.
    """
    try:
        with open(local_file_path, "rb") as f:
            supabase.storage.from_("lessons-hls").upload(
                path=storage_dest_path,
                file=f,
                file_options={
                    "cache-control": "31536000",
                    "content-type": content_type,
                    "upsert": "true",
                },
            )
    except Exception as e:
        logger.error(f"Erro ao fazer upload do arquivo processado '{storage_dest_path}': {e}")
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
    lesson_id: str,
    job_id: str,
    hls_storage_path: str,
    duration: int,
    ai_summary: Optional[dict],
):
    """
    Ativa a nova versão do vídeo de forma atômica no banco de dados.
    A lição passa a apontar para o novo manifesto de forma limpa e segura.
    """
    try:
        response = (
            supabase.table("lessons")
            .update(
                {
                    "video_source_type": "upload",
                    "external_video_id": None,
                    "hls_storage_path": hls_storage_path,
                    "duration_seconds": duration,
                    "ai_summary": ai_summary,
                    "updated_at": datetime.now(timezone.utc).isoformat(),
                    "pending_raw_video_path": None,
                    "pending_upload_job_id": None,
                }
            )
            .eq("id", lesson_id)
            .eq("pending_upload_job_id", job_id)
            .execute()
        )
        if isinstance(getattr(response, "data", None), list) and not response.data:
            raise RuntimeError(
                f"A aula {lesson_id} não aceita mais o job {job_id} como candidato atual."
            )
        return response
    except Exception as e:
        logger.error(f"Erro ao ativar lição {lesson_id}: {e}")
        raise


def activate_course_trailer(course_id: str, job_id: str, hls_storage_path: str):
    """Ativa o trailer somente se o job ainda for o candidato atual do curso."""
    try:
        response = (
            supabase.table("courses")
            .update(
                  {
                      "trailer_source_type": "upload",
                      "trailer_external_video_id": None,
                      "trailer_hls_path": hls_storage_path,
                    "trailer_status": "ready",
                    "updated_at": datetime.now(timezone.utc).isoformat(),
                }
            )
            .eq("id", course_id)
            .eq("trailer_upload_job_id", job_id)
            .execute()
        )
        if isinstance(getattr(response, "data", None), list) and not response.data:
            raise RuntimeError(
                f"O curso {course_id} não aceita mais o job {job_id} como trailer atual."
            )
        return response
    except Exception as e:
        logger.error(f"Erro ao ativar trailer do curso {course_id}: {e}")
        raise


def mark_asset_processing(*, asset_kind: str, course_id: str, job_id: str) -> Any:
    """Reflete no agregado o início real do processamento do trailer atual."""
    if asset_kind != "course_trailer":
        return None
    return (
        supabase.table("courses")
        .update(
            {
                "trailer_status": "processing",
                "updated_at": datetime.now(timezone.utc).isoformat(),
            }
        )
        .eq("id", course_id)
        .eq("trailer_upload_job_id", job_id)
        .execute()
    )


def mark_asset_failed(*, asset_kind: str, course_id: str, job_id: str) -> Any:
    """Evita que um trailer terminal permaneça indefinidamente como uploaded."""
    if asset_kind != "course_trailer":
        return None
    return (
        supabase.table("courses")
        .update(
            {
                "trailer_status": "failed",
                "updated_at": datetime.now(timezone.utc).isoformat(),
            }
        )
        .eq("id", course_id)
        .eq("trailer_upload_job_id", job_id)
        .execute()
    )
