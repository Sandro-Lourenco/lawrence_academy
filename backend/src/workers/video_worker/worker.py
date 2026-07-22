import os
import asyncio
import traceback
import shutil
import hashlib
from datetime import datetime, timedelta, timezone

from . import supabase_client
from .supabase_client import JobLoggerAdapter, logging
from . import transcoder
from . import transcriber
from . import summarizer

TEMP_DIR = "temp"

# Configuração global de logger
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("video-worker")


def calculate_file_checksum(file_path: str) -> str:
    """Calcula o checksum SHA-256 do arquivo local para integridade."""
    sha256 = hashlib.sha256()
    with open(file_path, "rb") as f:
        while chunk := f.read(8192):
            sha256.update(chunk)
    return sha256.hexdigest()


async def process_job(job: dict) -> None:
    job_id = job["id"]
    lesson_id = job["lesson_id"]
    raw_path = job["raw_video_path"]
    expected_size = job.get("expected_size_bytes")
    retry_count = job.get("retry_count", 0)
    max_retries = job.get("max_retries", 3)

    # Inicializar logger com correlation ID do job
    job_logger = JobLoggerAdapter(logger, {"job_id": job_id})
    job_logger.info(
        f"Iniciando processamento da lição {lesson_id} - Vídeo bruto: {raw_path}"
    )

    # Criar pasta temporária local de trabalho isolada
    job_temp_dir = os.path.join(TEMP_DIR, job_id)
    os.makedirs(job_temp_dir, exist_ok=True)

    local_raw_path = os.path.join(job_temp_dir, "raw_video.mp4")
    local_audio_path = os.path.join(job_temp_dir, "audio.wav")
    local_hls_dir = os.path.join(job_temp_dir, "hls")
    local_poster_path = os.path.join(job_temp_dir, "poster.jpg")
    local_thumb_path = os.path.join(job_temp_dir, "thumbnail.jpg")

    try:
        # 1. Atualizar para validating
        supabase_client.update_job_status(job_id, "validating")

        # 2. Download do vídeo bruto do Storage
        job_logger.info("Baixando vídeo do Storage...")
        file_bytes = supabase_client.download_raw_video(raw_path, local_raw_path)
        real_size = len(file_bytes)

        # Comparação expected_size vs real_size
        if expected_size and real_size != expected_size:
            raise ValueError(
                f"Tamanho do arquivo divergente. Esperado: {expected_size}, Real: {real_size}"
            )

        # 3. Executar ffprobe para validar conteúdo técnico real e obter metadados
        job_logger.info("Executando ffprobe para validar codec e estrutura técnica...")
        tech_meta = transcoder.analyze_video_file(local_raw_path)
        tech_meta["checksum_sha256"] = calculate_file_checksum(local_raw_path)

        # 4. Transcodificar para HLS Multi-bitrate (transcoding -> generating_hls)
        supabase_client.update_job_status(job_id, "transcoding")
        job_logger.info("Transcodificando para HLS...")
        transcoder.transcode_to_hls(local_raw_path, local_hls_dir)

        # 5. Gerar Poster e Thumbnail (generating_thumbnail)
        supabase_client.update_job_status(job_id, "generating_thumbnail")
        job_logger.info("Gerando poster e thumbnail do vídeo...")
        transcoder.generate_poster_and_thumbnail(
            local_raw_path, local_poster_path, local_thumb_path
        )

        # 6. Extrair áudio e executar Speech-to-Text (Whisper)
        job_logger.info("Extraindo áudio para transcrição...")
        transcoder.extract_audio(local_raw_path, local_audio_path)

        job_logger.info("Executando Speech-to-Text (Whisper)...")
        segments = transcriber.transcribe_audio_file(local_audio_path)

        # 7. Gerar resumo de IA (Gemini Pro)
        job_logger.info("Gerando resumo de IA (Gemini)...")
        ai_summary = summarizer.summarize_transcription(segments)

        # 8. Upload dos HLS, Poster e Thumbnail para lessons-hls (outputs versionados)
        job_logger.info("Realizando upload seguro dos arquivos de saída...")

        # Cada tentativa de processamento recebe um local versionado único usando o job_id
        storage_dest_prefix = f"lessons/{lesson_id}/{job_id}"

        # Upload dos fragmentos HLS
        for root, _, files in os.walk(local_hls_dir):
            for file in files:
                local_file = os.path.join(root, file)
                rel_path = os.path.relpath(local_file, local_hls_dir)
                storage_dest = (
                    f"{storage_dest_prefix}/hls/{rel_path.replace(os.sep, '/')}"
                )
                supabase_client.upload_processed_file(
                    local_file, storage_dest, supabase_client.get_mime_type(local_file)
                )

        # Upload do poster e thumbnail
        supabase_client.upload_processed_file(
            local_poster_path, f"{storage_dest_prefix}/poster.jpg", "image/jpeg"
        )
        supabase_client.upload_processed_file(
            local_thumb_path, f"{storage_dest_prefix}/thumbnail.jpg", "image/jpeg"
        )

        # 9. Ativação atômica da versão candidata
        #    A lição permanece inalterada até esse momento final.
        master_manifest_path = f"{storage_dest_prefix}/hls/master.m3u8"
        job_logger.info(f"Ativando nova versão do vídeo para a lição {lesson_id}...")
        supabase_client.activate_lesson_video(
            lesson_id=lesson_id,
            hls_storage_path=master_manifest_path,
            duration=tech_meta["duration"],
            ai_summary=ai_summary,
        )

        # 10. Concluir job com sucesso absoluto
        supabase_client.update_job_status(
            job_id=job_id,
            status="completed",
            real_size_bytes=real_size,
            video_metadata=tech_meta,
        )
        job_logger.info("Processamento concluído com sucesso!")

    except Exception as e:
        error_msg = f"Erro no pipeline: {str(e)}\n{traceback.format_exc()}"
        job_logger.error(f"Falha de processamento: {error_msg}")

        # Determinar se o erro é elegível para retry ou morte direta
        # Erros de validação técnica (ffprobe, tamanho, etc.) são fatais e não devem ser retentados
        is_fatal = isinstance(e, ValueError)

        if is_fatal or retry_count >= max_retries:
            status = "dead_letter" if not is_fatal else "failed"
            supabase_client.update_job_status(
                job_id=job_id, status=status, error_message=error_msg[:1000]
            )
            job_logger.warn(f"Job movido para {status} definitivamente.")
        else:
            # Retry com Exponential Backoff (10s, 20s, 40s...)
            new_retry_count = retry_count + 1
            backoff_sec = 10 * (2**new_retry_count)
            next_retry = (
                datetime.now(timezone.utc) + timedelta(seconds=backoff_sec)
            ).isoformat()

            supabase_client.update_job_status(
                job_id=job_id,
                status="processing_pending",
                error_message=error_msg[:200],
                retry_count=new_retry_count,
                next_retry_at=next_retry,
            )
            job_logger.info(
                f"Agendando nova tentativa #{new_retry_count} para {next_retry}"
            )

    finally:
        # Limpeza segura dos arquivos temporários locais
        if os.path.exists(job_temp_dir):
            try:
                shutil.rmtree(job_temp_dir)
            except Exception as clean_err:
                job_logger.error(f"Erro na limpeza temporária: {clean_err}")


async def process_jobs_loop():
    """Loop em background desacoplado que consome a fila do banco de dados."""
    logger.info("Iniciando loop do processador de vídeos...")
    while True:
        try:
            job = supabase_client.get_next_job()
            if job:
                await process_job(job)
            else:
                await asyncio.sleep(5)
        except Exception as e:
            logger.error(f"Erro no loop do processador: {e}")
            await asyncio.sleep(10)
