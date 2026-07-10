import os
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL") or "https://placeholder-url.supabase.co"
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY") or "placeholder-key"

# Cliente utilizando a Service Key para bypass de RLS nas atualizações administrativas
supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)

def get_next_pending_job():
    """Busca o próximo job pendente na fila."""
    response = supabase.table("video_processing_jobs") \
        .select("*, lessons(*)") \
        .eq("status", "pending") \
        .order("created_at") \
        .limit(1) \
        .execute()
    
    if response.data and len(response.data) > 0:
        return response.data[0]
    return None

def update_job_status(job_id: str, status: str, error_message: str = None):
    """Atualiza o status de um processamento na fila."""
    data = {
        "status": status,
        "updated_at": "now()"
    }
    if error_message:
        data["error_message"] = error_message
        
    return supabase.table("video_processing_jobs") \
        .update(data) \
        .eq("id", job_id) \
        .execute()

def download_raw_video(storage_path: str, local_dest_path: str):
    """Realiza o download do vídeo bruto do Supabase Storage."""
    # Assume que o bucket padrão para uploads brutos se chama 'raw-videos'
    with open(local_dest_path, "wb") as f:
        res = supabase.storage.from_("raw-videos").download(storage_path)
        f.write(res)

def upload_hls_file(local_file_path: str, storage_dest_path: str):
    """Realiza o upload de arquivos HLS (.m3u8 e .ts) para o Supabase Storage."""
    # Bucket de vídeos processados seguros
    bucket_name = "lessons-hls"
    with open(local_file_path, "rb") as f:
        supabase.storage.from_(bucket_name).upload(
            path=storage_dest_path,
            file=f,
            file_options={"cache-control": "31536000", "content-type": get_mime_type(local_file_path)}
        )

def get_mime_type(file_path: str) -> str:
    if file_path.endswith(".m3u8"):
        return "application/x-mpegURL"
    if file_path.endswith(".ts"):
        return "video/MP2T"
    if file_path.endswith(".vtt"):
        return "text/vtt"
    return "application/octet-stream"

def update_lesson_data(lesson_id: str, hls_storage_path: str, duration: int, ai_summary: dict):
    """Salva os resultados do processamento (vídeo e IA) na lição correspondente."""
    return supabase.table("lessons") \
        .update({
            "hls_storage_path": hls_storage_path,
            "duration_seconds": duration,
            "ai_summary": ai_summary,
            "status": "published",
            "updated_at": "now()"
        }) \
        .eq("id", lesson_id) \
        .execute()
