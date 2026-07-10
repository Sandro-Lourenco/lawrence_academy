import subprocess
import os
import shutil

def get_video_duration(video_path: str) -> int:
    """Retorna a duração do vídeo em segundos usando ffprobe."""
    cmd = [
        "ffprobe", "-v", "error", 
        "-show_entries", "format=duration", 
        "-of", "default=noprint_wrappers=1:nokey=1", 
        video_path
    ]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return int(float(result.stdout.strip()))
    except Exception as e:
        print(f"Erro ao obter duração do vídeo: {e}")
        return 0

def extract_audio(video_path: str, audio_path: str):
    """Extrai o áudio do vídeo em formato WAV de 16kHz mono (ideal para o Whisper)."""
    cmd = [
        "ffmpeg", "-y", "-i", video_path,
        "-ar", "16000",
        "-ac", "1",
        "-c:a", "pcm_s16le",
        audio_path
    ]
    subprocess.run(cmd, check=True, capture_output=True)

def transcode_to_hls(video_path: str, output_dir: str) -> str:
    """Converte o vídeo bruto em HLS multi-bitrate adaptativo (1080p, 720p, 480p).
    Gera playlists (.m3u8) e fragmentos (.ts).
    """
    os.makedirs(output_dir, exist_ok=True)
    
    # Criar sub-diretórios para as qualidades
    for q in ["480p", "720p", "1080p"]:
        os.makedirs(os.path.join(output_dir, q), exist_ok=True)
        
    # Comando ffmpeg para gerar os perfis HLS
    # 480p: 854x480, 800k bitrate
    # 720p: 1280x720, 1500k bitrate
    # 1080p: 1920x1080, 3000k bitrate
    # Usaremos fatias (segmentos) de 6 segundos
    cmd = [
        "ffmpeg", "-y", "-i", video_path,
        
        # Filtros de redimensionamento e bitrate
        "-filter_complex", "[0:v]split=3[v1][v2][v3];[v1]scale=w=854:h=480[v1out];[v2]scale=w=1280:h=720[v2out];[v3]scale=w=1920:h=1080[v3out]",
        
        # Mapeamento 480p
        "-map", "[v1out]", "-map", "0:a",
        "-c:v:0", "libx264", "-b:v:0", "800k", "-maxrate:v:0", "850k", "-bufsize:v:0", "1200k",
        "-c:a:0", "aac", "-b:a:0", "96k",
        
        # Mapeamento 720p
        "-map", "[v2out]", "-map", "0:a",
        "-c:v:1", "libx264", "-b:v:1", "1500k", "-maxrate:v:1", "1600k", "-bufsize:v:1", "2200k",
        "-c:a:1", "aac", "-b:a:1", "128k",
        
        # Mapeamento 1080p
        "-map", "[v3out]", "-map", "0:a",
        "-c:v:2", "libx264", "-b:v:2", "3000k", "-maxrate:v:2", "3200k", "-bufsize:v:2", "4500k",
        "-c:a:2", "aac", "-b:a:2", "192k",
        
        # Configurações HLS genéricas
        "-f", "hls",
        "-hls_time", "6",
        "-hls_playlist_type", "vod",
        "-hls_segment_filename", os.path.join(output_dir, "%v", "segment_%03d.ts").replace(os.sep, "/"),
        "-master_pl_name", "master.m3u8",
        os.path.join(output_dir, "%v", "index.m3u8").replace(os.sep, "/")
    ]
    
    subprocess.run(cmd, check=True, capture_output=True)
    return os.path.join(output_dir, "master.m3u8")
