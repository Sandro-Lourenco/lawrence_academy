import sys
import os
import pytest
import asyncio
from unittest.mock import patch

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from src.workers.video_worker import transcriber
from src.workers.video_worker import transcoder
from src.workers.video_worker import worker as worker_main
from src.workers.video_worker import healthcheck
from src.workers.video_worker import supabase_client

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


def test_healthcheck_rejects_missing_heartbeat(tmp_path, monkeypatch):
    monkeypatch.setattr(healthcheck, "HEARTBEAT_FILE", tmp_path / "missing")

    assert healthcheck.is_worker_alive() is False


def test_healthcheck_accepts_recent_heartbeat(tmp_path, monkeypatch):
    heartbeat_file = tmp_path / "heartbeat"
    heartbeat_file.touch()
    monkeypatch.setattr(healthcheck, "HEARTBEAT_FILE", heartbeat_file)

    assert healthcheck.is_worker_alive() is True


def test_healthcheck_rejects_heartbeat_far_in_the_future(tmp_path, monkeypatch):
    heartbeat_file = tmp_path / "future-heartbeat"
    heartbeat_file.touch()
    monkeypatch.setattr(healthcheck, "HEARTBEAT_FILE", heartbeat_file)

    assert healthcheck.is_worker_alive(now=heartbeat_file.stat().st_mtime - 10) is False


def test_healthcheck_rejects_unresolvable_supabase(monkeypatch):
    monkeypatch.setenv("SUPABASE_URL", "https://unresolvable.invalid")

    def raise_dns_error(*_args, **_kwargs):
        raise healthcheck.socket.gaierror()

    monkeypatch.setattr(healthcheck.socket, "getaddrinfo", raise_dns_error)

    assert healthcheck.can_resolve_supabase() is False


def test_worker_configuration_fails_fast_without_supabase(monkeypatch):
    monkeypatch.setattr(
        supabase_client,
        "SUPABASE_URL",
        "https://placeholder-url.supabase.co",
    )
    monkeypatch.setattr(supabase_client, "SUPABASE_SERVICE_KEY", "placeholder-key")

    with pytest.raises(RuntimeError, match="SUPABASE_URL"):
        supabase_client.validate_worker_configuration()


def test_renditions_do_not_upscale_small_source():
    renditions = transcoder.select_hls_renditions(640, 360)

    assert [rendition.name for rendition in renditions] == ["480p"]


def test_renditions_keep_adaptive_ladder_for_full_hd():
    renditions = transcoder.select_hls_renditions(1920, 1080)

    assert [rendition.name for rendition in renditions] == [
        "480p",
        "720p",
        "1080p",
    ]


@patch("src.workers.video_worker.transcoder.subprocess.run")
def test_transcode_uses_storage_efficient_quality_and_preserves_aspect_ratio(mock_run, tmp_path):
    transcoder.transcode_to_hls(
        "input.mp4",
        str(tmp_path),
        source_width=1280,
        source_height=720,
        has_audio=True,
    )

    command = mock_run.call_args.args[0]
    assert command[command.index("-preset") + 1] == "slow"
    assert "-crf:v:0" in command
    assert "-b:v:0" not in command
    assert command[command.index("-hls_flags") + 1] == "independent_segments"
    filter_graph = command[command.index("-filter_complex") + 1]
    assert "force_original_aspect_ratio=decrease" in filter_graph
    assert "1920:1080" not in filter_graph
    stream_map = command[command.index("-var_stream_map") + 1]
    assert stream_map == "v:0,a:0,name:480p v:1,a:1,name:720p"


@patch("src.workers.video_worker.transcoder.subprocess.run")
def test_poster_and_thumbnail_limit_each_output_video_stream_zero(mock_run, tmp_path):
    transcoder.generate_poster_and_thumbnail(
        "input.mp4",
        str(tmp_path / "poster.jpg"),
        str(tmp_path / "thumbnail.jpg"),
    )

    command = mock_run.call_args.args[0]
    assert "-frames:v:0" not in command
    assert "-frames:v:1" not in command
    assert command.count("-frames:v") == 2


def test_processed_upload_is_idempotent_for_partial_retry(tmp_path):
    local_file = tmp_path / "master.m3u8"
    local_file.write_text("#EXTM3U", encoding="utf-8")
    bucket = type(
        "Bucket",
        (),
        {
            "upload": lambda self, **kwargs: setattr(self, "upload_args", kwargs),
        },
    )()
    storage = type("Storage", (), {"from_": lambda self, _name: bucket})()

    client = type("Client", (), {"storage": storage})()
    with patch.object(supabase_client, "supabase", client):
        supabase_client.upload_processed_file(
            str(local_file),
            "lessons/lesson/job/hls/master.m3u8",
            "application/x-mpegURL",
        )

    assert bucket.upload_args["file_options"]["upsert"] == "true"


def test_get_next_job_uses_atomic_claim():
    response = type("Response", (), {"data": [{"id": "job-1"}]})()
    rpc_result = type("RpcResult", (), {"execute": lambda self: response})()
    rpc = patch.object(
        supabase_client.supabase,
        "rpc",
        return_value=rpc_result,
    )
    with rpc as mock_rpc:
        job = supabase_client.get_next_job()

    assert job == {"id": "job-1"}
    mock_rpc.assert_called_once_with(
        "claim_next_video_processing_job",
        {
            "p_worker_id": supabase_client.WORKER_ID,
            "p_lease_seconds": supabase_client.JOB_LEASE_SECONDS,
        },
    )


def test_job_status_uses_real_iso_timestamp_instead_of_postgrest_expression():
    query = type(
        "Query",
        (),
        {
            "update": lambda self, data: setattr(self, "payload", data) or self,
            "eq": lambda self, column, value: self.filters.append((column, value)) or self,
            "execute": lambda self: None,
            "payload": {},
            "filters": [],
        },
    )()
    query.filters = []
    with patch.object(supabase_client.supabase, "table", return_value=query):
        supabase_client.update_job_status("job-1", "processing")

    assert query.payload["updated_at"] != "now()"
    assert query.payload["processing_started_at"].endswith("+00:00")
    assert query.payload["lease_expires_at"].endswith("+00:00")
    assert ("claimed_by", supabase_client.WORKER_ID) in query.filters


def test_lesson_activation_is_scoped_to_current_upload_job():
    query = type(
        "Query",
        (),
        {
            "update": lambda self, data: setattr(self, "payload", data) or self,
            "eq": lambda self, column, value: self.filters.append((column, value)) or self,
            "execute": lambda self: None,
            "filters": [],
            "payload": {},
        },
    )()
    query.filters = []
    with patch.object(
        supabase_client.supabase,
        "table",
        return_value=query,
    ):
        supabase_client.activate_lesson_video(
            lesson_id="lesson-1",
            job_id="job-current",
            hls_storage_path="lessons/lesson-1/job-current/hls/master.m3u8",
            duration=60,
            ai_summary=None,
        )

    assert ("pending_upload_job_id", "job-current") in query.filters
    assert "status" not in query.payload
    assert query.payload["video_source_type"] == "upload"
    assert query.payload["external_video_id"] is None


def test_trailer_terminal_failure_is_reflected_on_current_course():
    query = type(
        "Query",
        (),
        {
            "update": lambda self, data: setattr(self, "payload", data) or self,
            "eq": lambda self, column, value: self.filters.append((column, value)) or self,
            "execute": lambda self: None,
            "filters": [],
            "payload": {},
        },
    )()
    query.filters = []
    with patch.object(supabase_client.supabase, "table", return_value=query):
        supabase_client.mark_asset_failed(
            asset_kind="course_trailer",
            course_id="course-1",
            job_id="job-current",
        )

    assert query.payload["trailer_status"] == "failed"
    assert ("trailer_upload_job_id", "job-current") in query.filters


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
def test_process_job_success(
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
        return 1000

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
    # Executar
    asyncio.run(worker_main.process_job(mock_job))

    # Verificar chamadas críticas
    mock_update.assert_any_call("job-uuid-1111", "validating")
    mock_update.assert_any_call("job-uuid-1111", "transcoding")
    mock_update.assert_any_call("job-uuid-1111", "generating_thumbnail")
    mock_activate.assert_called_once_with(
        lesson_id="lesson-uuid-2222",
        job_id="job-uuid-1111",
        hls_storage_path="lessons/lesson-uuid-2222/job-uuid-1111/hls/master.m3u8",
        duration=120,
        ai_summary=None,
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
    mock_extract.assert_not_called()


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
        return 500

    mock_download.side_effect = side_effect_download

    asyncio.run(worker_main.process_job(mock_job))

    # Deve registrar como failed ou dead_letter diretamente por erro fatal de integridade
    calls = mock_update.call_args_list
    failed_call = next((c for c in calls if c[0] and len(c[0]) > 1 and c[0][1] == "failed"), None)
    if not failed_call:
        failed_call = next((c for c in calls if c[1] and c[1].get("status") == "failed"), None)

    assert failed_call is not None
    if failed_call[1]:
        assert "Tamanho do arquivo divergente" in failed_call[1].get("error_message", "")
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
        return 1000

    mock_download.side_effect = side_effect_download
    # Codec não suportado (ex: wmv)
    mock_analyze.side_effect = ValueError("Codec de vídeo não suportado: wmv")

    asyncio.run(worker_main.process_job(mock_job))

    # Erro de validação deve ser fatal e marcar status 'failed' imediatamente
    calls = mock_update.call_args_list
    failed_call = next((c for c in calls if c[0] and len(c[0]) > 1 and c[0][1] == "failed"), None)
    if not failed_call:
        failed_call = next((c for c in calls if c[1] and c[1].get("status") == "failed"), None)

    assert failed_call is not None
    if failed_call[1]:
        assert "Codec de vídeo não suportado: wmv" in failed_call[1].get("error_message", "")
    else:
        assert len(failed_call[0]) > 2
        assert "Codec de vídeo não suportado: wmv" in failed_call[0][2]


@patch("src.workers.video_worker.worker.supabase_client.download_raw_video")
@patch("src.workers.video_worker.worker.supabase_client.update_job_status")
def test_process_job_transcode_network_error_retries(mock_update, mock_download, mock_job):
    # Simula erro de conexão/transmissão temporário
    mock_download.side_effect = RuntimeError("Conexão perdida temporariamente com o Storage")

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
