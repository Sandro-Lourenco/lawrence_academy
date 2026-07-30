import subprocess
import os
import json
import logging
from typing import Dict, Any, NamedTuple

logger = logging.getLogger("video-worker")

# Codecs permitidos (segurança e conformidade de pipeline)
ALLOWED_VIDEO_CODECS = {"h264", "hevc", "vp9", "vp8", "mpeg4"}


class HlsRendition(NamedTuple):
    name: str
    width: int
    height: int
    video_bitrate: str
    maxrate: str
    bufsize: str
    audio_bitrate: str


HLS_RENDITIONS = (
    HlsRendition("480p", 854, 480, "800k", "850k", "1200k", "96k"),
    HlsRendition("720p", 1280, 720, "1500k", "1600k", "2200k", "128k"),
    HlsRendition("1080p", 1920, 1080, "3000k", "3200k", "4500k", "192k"),
)


def select_hls_renditions(source_width: int, source_height: int) -> tuple[HlsRendition, ...]:
    """Avoid expensive, quality-degrading upscaling while always producing one rendition."""
    source_long_edge = max(source_width, source_height)
    selected = tuple(
        rendition
        for rendition in HLS_RENDITIONS
        if max(rendition.width, rendition.height) <= source_long_edge
    )
    return selected or (HLS_RENDITIONS[0],)


def analyze_video_file(video_path: str) -> Dict[str, Any]:
    """
    Executa ffprobe no arquivo de vídeo para extrair metadados técnicos de forma detalhada e segura.
    Valida se o arquivo está corrompido ou se usa codecs não suportados.
    """
    # Proteção contra injeção de parâmetros/comandos maliciosos
    if not os.path.exists(video_path):
        raise FileNotFoundError(f"Arquivo não existe: {video_path}")

    cmd = [
        "ffprobe",
        "-v",
        "quiet",
        "-print_format",
        "json",
        "-show_format",
        "-show_streams",
        video_path,
    ]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True, timeout=30)
        metadata = json.loads(result.stdout)
    except subprocess.SubprocessError as e:
        logger.error(f"Falha de execução do ffprobe: {e}")
        raise ValueError("Arquivo de vídeo inválido ou corrompido (falha no ffprobe).")
    except json.JSONDecodeError as e:
        logger.error(f"Falha ao decodificar saída do ffprobe: {e}")
        raise ValueError("Metadados do vídeo ilegíveis.")

    # Extrair streams
    streams = metadata.get("streams", [])
    video_stream = next((s for s in streams if s.get("codec_type") == "video"), None)
    audio_stream = next((s for s in streams if s.get("codec_type") == "audio"), None)

    if not video_stream:
        raise ValueError("Nenhum stream de vídeo encontrado no arquivo.")

    codec_name = video_stream.get("codec_name")
    if codec_name not in ALLOWED_VIDEO_CODECS:
        raise ValueError(f"Codec de vídeo não suportado: {codec_name}")

    # Extrair duração
    duration_str = metadata.get("format", {}).get("duration") or video_stream.get("duration")
    if not duration_str:
        raise ValueError("Não foi possível determinar a duração do vídeo.")
    duration = int(float(duration_str))

    # Extrair resolução e FPS
    width = int(video_stream.get("width", 0))
    height = int(video_stream.get("height", 0))

    # Extrair FPS
    fps_val = 0.0
    r_frame_rate = video_stream.get("r_frame_rate", "0/0")
    if "/" in r_frame_rate:
        try:
            num, den = map(int, r_frame_rate.split("/"))
            if den > 0:
                fps_val = num / den
        except Exception:
            pass

    # Rotação (se houver metadados de side data)
    rotation = 0
    # O ffprobe moderno coloca rotação em tags ou displaymatrix nas tags
    tags = video_stream.get("tags", {})
    if "rotate" in tags:
        try:
            rotation = int(tags["rotate"])
        except ValueError:
            pass

    # Bitrate
    bitrate_str = metadata.get("format", {}).get("bit_rate") or video_stream.get("bit_rate")
    bitrate = int(bitrate_str) if bitrate_str and bitrate_str.isdigit() else 0

    return {
        "codec": codec_name,
        "duration": duration,
        "width": width,
        "height": height,
        "fps": fps_val,
        "bitrate": bitrate,
        "rotation": rotation,
        "audio_codec": audio_stream.get("codec_name") if audio_stream else None,
    }


def extract_audio(video_path: str, audio_path: str):
    """Extrai áudio da faixa 0 para WAV mono de 16kHz."""
    cmd = [
        "ffmpeg",
        "-y",
        "-i",
        video_path,
        "-vn",
        "-ar",
        "16000",
        "-ac",
        "1",
        "-c:a",
        "pcm_s16le",
        audio_path,
    ]
    try:
        subprocess.run(cmd, check=True, capture_output=True, timeout=60)
    except subprocess.SubprocessError as e:
        logger.error(f"Erro ao extrair áudio com FFmpeg: {e}")
        raise RuntimeError("Falha na extração de áudio da lição.")


def generate_poster_and_thumbnail(
    video_path: str, poster_path: str, thumb_path: str, time_offset: int = 2
):
    """Gera o Poster da lição (imagem completa) e a miniatura (thumbnail) de forma otimizada."""
    # Poster completo da aula (mantendo resolução de origem)
    cmd = [
        "ffmpeg",
        "-y",
        "-ss",
        str(time_offset),
        "-i",
        video_path,
        "-filter_complex",
        "[0:v]split=2[poster][thumb];"
        "[poster]scale=w='min(1920,iw)':h=-2[poster_out];"
        "[thumb]scale=320:-2[thumb_out]",
        "-map",
        "[poster_out]",
        # Each image is a separate ffmpeg output. Stream indexes are scoped to
        # the current output, so both outputs expose video stream 0.
        "-frames:v",
        "1",
        poster_path,
        "-map",
        "[thumb_out]",
        "-frames:v",
        "1",
        thumb_path,
    ]

    try:
        subprocess.run(cmd, check=True, capture_output=True, timeout=20)
    except subprocess.SubprocessError as e:
        logger.error(f"Erro ao gerar poster/thumbnail com FFmpeg: {e}")
        # Criar arquivo mock caso o vídeo seja curto demais para o offset
        if time_offset > 0:
            generate_poster_and_thumbnail(video_path, poster_path, thumb_path, time_offset=0)
        else:
            raise RuntimeError("Falha ao gerar poster de pré-visualização.")


def transcode_to_hls(
    video_path: str,
    output_dir: str,
    *,
    source_width: int,
    source_height: int,
    has_audio: bool,
) -> str:
    """Converte o vídeo bruto em HLS multi-bitrate adaptativo (480p, 720p, 1080p)."""
    os.makedirs(output_dir, exist_ok=True)

    renditions = select_hls_renditions(source_width, source_height)
    for rendition in renditions:
        os.makedirs(os.path.join(output_dir, rendition.name), exist_ok=True)

    cmd = [
        "ffmpeg",
        "-y",
        "-i",
        video_path,
        "-filter_complex",
        _build_filter_complex(renditions),
    ]
    for index, rendition in enumerate(renditions):
        cmd.extend(
            [
                "-map",
                f"[v{index}out]",
                f"-c:v:{index}",
                "libx264",
                f"-b:v:{index}",
                rendition.video_bitrate,
                f"-maxrate:v:{index}",
                rendition.maxrate,
                f"-bufsize:v:{index}",
                rendition.bufsize,
            ]
        )
        if has_audio:
            cmd.extend(
                [
                    "-map",
                    "0:a:0",
                    f"-c:a:{index}",
                    "aac",
                    f"-b:a:{index}",
                    rendition.audio_bitrate,
                ]
            )
    cmd.extend(
        [
            "-preset",
            os.getenv("VIDEO_FFMPEG_PRESET", "veryfast"),
            "-sc_threshold",
            "0",
            "-f",
            "hls",
            "-hls_time",
            "6",
            "-hls_playlist_type",
            "vod",
            "-var_stream_map",
            " ".join(
                f"v:{index},a:{index},name:{rendition.name}"
                if has_audio
                else f"v:{index},name:{rendition.name}"
                for index, rendition in enumerate(renditions)
            ),
            "-hls_segment_filename",
            os.path.join(output_dir, "%v", "segment_%03d.ts").replace(os.sep, "/"),
            "-master_pl_name",
            "master.m3u8",
            os.path.join(output_dir, "%v", "index.m3u8").replace(os.sep, "/"),
        ]
    )

    try:
        subprocess.run(cmd, check=True, capture_output=True, timeout=600)  # Limite máximo de 10 min
    except subprocess.SubprocessError as e:
        logger.error(f"Erro ao transcodificar HLS com FFmpeg: {e}")
        raise RuntimeError("Falha na transcodificação do formato HLS.")

    return os.path.join(output_dir, "master.m3u8")


def _build_filter_complex(renditions: tuple[HlsRendition, ...]) -> str:
    inputs = "".join(f"[v{index}]" for index in range(len(renditions)))
    filters = [f"[0:v]split={len(renditions)}{inputs}"]
    for index, rendition in enumerate(renditions):
        filters.append(
            f"[v{index}]scale=w={rendition.width}:h={rendition.height}:"
            "force_original_aspect_ratio=decrease,"
            f"pad={rendition.width}:{rendition.height}:(ow-iw)/2:(oh-ih)/2"
            f"[v{index}out]"
        )
    return ";".join(filters)
