import subprocess
import os
import json
import logging
from typing import Dict, Any

logger = logging.getLogger("video-worker")

# Codecs permitidos (segurança e conformidade de pipeline)
ALLOWED_VIDEO_CODECS = {"h264", "hevc", "vp9", "vp8", "mpeg4"}


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
        result = subprocess.run(
            cmd, capture_output=True, text=True, check=True, timeout=30
        )
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
    duration_str = metadata.get("format", {}).get("duration") or video_stream.get(
        "duration"
    )
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
    bitrate_str = metadata.get("format", {}).get("bit_rate") or video_stream.get(
        "bit_rate"
    )
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
    cmd_poster = [
        "ffmpeg",
        "-y",
        "-ss",
        str(time_offset),
        "-i",
        video_path,
        "-vframes",
        "1",
        "-f",
        "image2",
        poster_path,
    ]

    # Thumbnail em escala menor (ex: largura 320px)
    cmd_thumb = [
        "ffmpeg",
        "-y",
        "-ss",
        str(time_offset),
        "-i",
        video_path,
        "-vframes",
        "1",
        "-vf",
        "scale=320:-1",
        "-f",
        "image2",
        thumb_path,
    ]

    try:
        subprocess.run(cmd_poster, check=True, capture_output=True, timeout=20)
        subprocess.run(cmd_thumb, check=True, capture_output=True, timeout=20)
    except subprocess.SubprocessError as e:
        logger.error(f"Erro ao gerar poster/thumbnail com FFmpeg: {e}")
        # Criar arquivo mock caso o vídeo seja curto demais para o offset
        if time_offset > 0:
            generate_poster_and_thumbnail(
                video_path, poster_path, thumb_path, time_offset=0
            )
        else:
            raise RuntimeError("Falha ao gerar poster de pré-visualização.")


def transcode_to_hls(video_path: str, output_dir: str) -> str:
    """Converte o vídeo bruto em HLS multi-bitrate adaptativo (480p, 720p, 1080p)."""
    os.makedirs(output_dir, exist_ok=True)

    for q in ["480p", "720p", "1080p"]:
        os.makedirs(os.path.join(output_dir, q), exist_ok=True)

    cmd = [
        "ffmpeg",
        "-y",
        "-i",
        video_path,
        "-filter_complex",
        "[0:v]split=3[v1][v2][v3];[v1]scale=w=854:h=480[v1out];[v2]scale=w=1280:h=720[v2out];[v3]scale=w=1920:h=1080[v3out]",
        "-map",
        "[v1out]",
        "-map",
        "0:a?",
        "-c:v:0",
        "libx264",
        "-b:v:0",
        "800k",
        "-maxrate:v:0",
        "850k",
        "-bufsize:v:0",
        "1200k",
        "-c:a:0",
        "aac",
        "-b:a:0",
        "96k",
        "-map",
        "[v2out]",
        "-map",
        "0:a?",
        "-c:v:1",
        "libx264",
        "-b:v:1",
        "1500k",
        "-maxrate:v:1",
        "1600k",
        "-bufsize:v:1",
        "2200k",
        "-c:a:1",
        "aac",
        "-b:a:1",
        "128k",
        "-map",
        "[v3out]",
        "-map",
        "0:a?",
        "-c:v:2",
        "libx264",
        "-b:v:2",
        "3000k",
        "-maxrate:v:2",
        "3200k",
        "-bufsize:v:2",
        "4500k",
        "-c:a:2",
        "aac",
        "-b:a:2",
        "192k",
        "-f",
        "hls",
        "-hls_time",
        "6",
        "-hls_playlist_type",
        "vod",
        "-hls_segment_filename",
        os.path.join(output_dir, "%v", "segment_%03d.ts").replace(os.sep, "/"),
        "-master_pl_name",
        "master.m3u8",
        os.path.join(output_dir, "%v", "index.m3u8").replace(os.sep, "/"),
    ]

    try:
        subprocess.run(
            cmd, check=True, capture_output=True, timeout=600
        )  # Limite máximo de 10 min
    except subprocess.SubprocessError as e:
        logger.error(f"Erro ao transcodificar HLS com FFmpeg: {e}")
        raise RuntimeError("Falha na transcodificação do formato HLS.")

    return os.path.join(output_dir, "master.m3u8")
