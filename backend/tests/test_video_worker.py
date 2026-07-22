import sys
import os
import pytest
import asyncio
from unittest.mock import patch

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from src.workers.video_worker import transcriber
from src.workers.video_worker import worker as worker_main

# ============================================================
# Re-aproveitar testes legados
# ============================================================


def test_whisper_segment_cleanup():
    raw_segments = [
        {"start": 0.0, "end": 2.0, "text": "Olá a todos"},
        {"start": 2.0, "end": 4.0, "text": "Olá a todos"},
        {"start": 4.5, "end": 8.0, "text": "Hoje aprenderemos costura"},
        {"start": 7.0, "end": 10.0, "text": "Aprenderemos costura avançada"},
    ]
    cleaned = transcriber.clean_up_segments(raw_segments)
    assert len(cleaned) == 2
    assert cleaned[0]["text"] == "Olá a todos"
    assert cleaned[0]["start"] == 0.0
    assert cleaned[0]["end"] == 4.0


def test_context_compression_logic():
    mock_lines = [
        f"[{i:02d}:00] Linha de teste de costura numero {i} contendo termos de modelagem."
        for i in range(100)
    ]
    chunks = []
    current_chunk = []
    current_len = 0
    chunk_size = 500

    for line in mock_lines:
        current_chunk.append(line)
        current_len += len(line) + 1
        if current_len >= chunk_size:
            chunks.append("\n".join(current_chunk))
            overlap_lines = current_chunk[-2:]
            current_chunk = overlap_lines
            current_len = sum(len(line_text) + 1 for line_text in current_chunk)

    if current_chunk:
        chunks.append("\n".join(current_chunk))

    assert len(chunks) > 1


# ============================================================
# Novos testes da TASK-5D-004
# ============================================================


@pytest.fixture
def mock_job():
    return {
        "id": "job-uuid-1111",
        "lesson_id": "lesson-uuid-2222",
        "course_id": "course-uuid-3333",
        "raw_video_path": "uploads/course-uuid/job-uuid/lesson-uuid.mp4",
        "expected_size_bytes": 1000,
        "retry_count": 0,
        "max_retries": 3,
    }


@patch("src.workers.video_worker.worker.supabase_client.download_raw_video")
@patch("src.workers.video_worker.worker.supabase_client.update_job_status")
@patch("src.workers.video_worker.worker.supabase_client.upload_processed_file")
@patch("src.workers.video_worker.worker.supabase_client.activate_lesson_video")
@patch("src.workers.video_worker.worker.transcoder.analyze_video_file")
@patch("src.workers.video_worker.worker.transcoder.transcode_to_hls")
@patch("src.workers.video_worker.worker.transcoder.generate_poster_and_thumbnail")
@patch("src.workers.video_worker.worker.transcoder.extract_audio")
@patch("src.workers.video_worker.worker.transcriber.transcribe_audio_file")
@patch("src.workers.video_worker.worker.summarizer.summarize_transcription")
def test_process_job_success(
    mock_summarize,
    mock_transcribe,
    mock_extract,
    mock_generate_img,
    mock_transcode,
    mock_analyze,
    mock_activate,
    mock_upload,
    mock_update,
    mock_download,
    mock_job,
):
    # Setup mocks
    def side_effect_download(path, dest):
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with open(dest, "wb") as f:
            f.write(b"x" * 1000)
        return b"x" * 1000

    mock_download.side_effect = side_effect_download
    mock_analyze.return_value = {
        "codec": "h264",
        "duration": 120,
        "width": 1920,
        "height": 1080,
        "fps": 30.0,
        "bitrate": 3000000,
        "rotation": 0,
    }
    mock_transcribe.return_value = []
    mock_summarize.return_value = {"title": "Resumo Teste"}

    # Executar
    asyncio.run(worker_main.process_job(mock_job))

    # Verificar chamadas críticas
    mock_update.assert_any_call("job-uuid-1111", "validating")
    mock_update.assert_any_call("job-uuid-1111", "transcoding")
    mock_update.assert_any_call("job-uuid-1111", "generating_thumbnail")
    mock_activate.assert_called_once_with(
        lesson_id="lesson-uuid-2222",
        hls_storage_path="lessons/lesson-uuid-2222/job-uuid-1111/hls/master.m3u8",
        duration=120,
        ai_summary={"title": "Resumo Teste"},
    )
    # Status final 'completed'
    calls = mock_update.call_args_list
    completed_call = next(
        (c for c in calls if c[0] and len(c[0]) > 1 and c[0][1] == "completed"), None
    )
    if not completed_call:
        completed_call = next(
            (c for c in calls if c[1] and c[1].get("status") == "completed"), None
        )

    assert completed_call is not None
    if completed_call[1]:
        assert completed_call[1].get("real_size_bytes") == 1000


@patch("src.workers.video_worker.worker.supabase_client.download_raw_video")
@patch("src.workers.video_worker.worker.supabase_client.update_job_status")
@patch("src.workers.video_worker.worker.transcoder.analyze_video_file")
def test_process_job_size_mismatch_fails_fatally(
    mock_analyze, mock_update, mock_download, mock_job
):
    def side_effect_download(path, dest):
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with open(dest, "wb") as f:
            f.write(b"x" * 500)
        return b"x" * 500

    mock_download.side_effect = side_effect_download

    asyncio.run(worker_main.process_job(mock_job))

    # Deve registrar como failed ou dead_letter diretamente por erro fatal de integridade
    calls = mock_update.call_args_list
    failed_call = next(
        (c for c in calls if c[0] and len(c[0]) > 1 and c[0][1] == "failed"), None
    )
    if not failed_call:
        failed_call = next(
            (c for c in calls if c[1] and c[1].get("status") == "failed"), None
        )

    assert failed_call is not None
    if failed_call[1]:
        assert "Tamanho do arquivo divergente" in failed_call[1].get(
            "error_message", ""
        )
    else:
        assert len(failed_call[0]) > 2
        assert "Tamanho do arquivo divergente" in failed_call[0][2]


@patch("src.workers.video_worker.worker.supabase_client.download_raw_video")
@patch("src.workers.video_worker.worker.supabase_client.update_job_status")
@patch("src.workers.video_worker.worker.transcoder.analyze_video_file")
def test_process_job_invalid_codec_fails_fatally(
    mock_analyze, mock_update, mock_download, mock_job
):
    def side_effect_download(path, dest):
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with open(dest, "wb") as f:
            f.write(b"x" * 1000)
        return b"x" * 1000

    mock_download.side_effect = side_effect_download
    # Codec não suportado (ex: wmv)
    mock_analyze.side_effect = ValueError("Codec de vídeo não suportado: wmv")

    asyncio.run(worker_main.process_job(mock_job))

    # Erro de validação deve ser fatal e marcar status 'failed' imediatamente
    calls = mock_update.call_args_list
    failed_call = next(
        (c for c in calls if c[0] and len(c[0]) > 1 and c[0][1] == "failed"), None
    )
    if not failed_call:
        failed_call = next(
            (c for c in calls if c[1] and c[1].get("status") == "failed"), None
        )

    assert failed_call is not None
    if failed_call[1]:
        assert "Codec de vídeo não suportado: wmv" in failed_call[1].get(
            "error_message", ""
        )
    else:
        assert len(failed_call[0]) > 2
        assert "Codec de vídeo não suportado: wmv" in failed_call[0][2]


@patch("src.workers.video_worker.worker.supabase_client.download_raw_video")
@patch("src.workers.video_worker.worker.supabase_client.update_job_status")
def test_process_job_transcode_network_error_retries(
    mock_update, mock_download, mock_job
):
    # Simula erro de conexão/transmissão temporário
    mock_download.side_effect = RuntimeError(
        "Conexão perdida temporariamente com o Storage"
    )

    asyncio.run(worker_main.process_job(mock_job))

    # Status deve ir para 'processing_pending' para retentativa futura
    # (exponential backoff)
    calls = []
    for c in mock_update.call_args_list:
        if c[1] and "status" in c[1]:
            calls.append(c[1]["status"])
        elif len(c[0]) > 1:
            calls.append(c[0][1])

    assert "processing_pending" in calls
