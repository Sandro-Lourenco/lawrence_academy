import os
import time
import asyncio
import traceback
import shutil
from fastapi import FastAPI, BackgroundTasks
import uvicorn

import supabase_client
import transcoder
import transcriber
import summarizer

app = FastAPI(title="Lawrence Academy Video Pipeline Worker", version="1.0.0")

TEMP_DIR = "temp"

async def process_jobs_loop():
    """Loop em background que processa novos vídeos da fila de forma assíncrona."""
    print("Iniciando loop do processador de vídeos...")
    while True:
        try:
            job = supabase_client.get_next_pending_job()
            if job:
                job_id = job["id"]
                lesson_id = job["lesson_id"]
                raw_path = job["raw_video_path"]
                
                print(f"[{job_id}] Processando lição {lesson_id} - Vídeo bruto: {raw_path}")
                supabase_client.update_job_status(job_id, "processing")
                
                # Criar pasta temporária local de trabalho isolada
                job_temp_dir = os.path.join(TEMP_DIR, job_id)
                os.makedirs(job_temp_dir, exist_ok=True)
                
                local_raw_path = os.path.join(job_temp_dir, "raw_video.mp4")
                local_audio_path = os.path.join(job_temp_dir, "audio.wav")
                local_hls_dir = os.path.join(job_temp_dir, "hls")
                
                try:
                    # 1. Download do vídeo bruto do Storage
                    print(f"[{job_id}] Baixando vídeo do Storage...")
                    supabase_client.download_raw_video(raw_path, local_raw_path)
                    
                    # 2. Obter duração do vídeo
                    duration_sec = transcoder.get_video_duration(local_raw_path)
                    print(f"[{job_id}] Duração do vídeo: {duration_sec} segundos")
                    
                    # 3. Transcodificar para HLS Multi-bitrate
                    print(f"[{job_id}] Transcodificando para HLS...")
                    master_pl_path = transcoder.transcode_to_hls(local_raw_path, local_hls_dir)
                    
                    # 4. Extrair áudio para Speech-to-Text
                    print(f"[{job_id}] Extraindo áudio para transcrição...")
                    transcoder.extract_audio(local_raw_path, local_audio_path)
                    
                    # 5. Transcrever áudio usando Whisper e de-duplicar timestamps
                    print(f"[{job_id}] Executando Speech-to-Text (Whisper)...")
                    segments = transcriber.transcribe_audio_file(local_audio_path)
                    
                    # 6. Gerar resumo cognitivo estruturado via Gemini Pro
                    print(f"[{job_id}] Gerando resumo de IA (Gemini)...")
                    ai_summary = summarizer.summarize_transcription(segments)
                    
                    # 7. Upload dos arquivos HLS para o Storage
                    print(f"[{job_id}] Enviando arquivos HLS para o Storage...")
                    # Caminho base no bucket 'lessons-hls' será 'lessons/{lesson_id}/'
                    for root, dirs, files in os.walk(local_hls_dir):
                        for file in files:
                            local_file = os.path.join(root, file)
                            # Calcular o caminho relativo dentro da pasta 'hls'
                            rel_path = os.path.relpath(local_file, local_hls_dir)
                            # Trocar barras no Windows para barras no Storage (Linux/S3 standard)
                            storage_dest = f"lessons/{lesson_id}/{rel_path.replace(os.sep, '/')}"
                            
                            supabase_client.upload_hls_file(local_file, storage_dest)
                            
                    # 8. Salvar os resultados na lição e publicar
                    hls_manifest_path = f"lessons/{lesson_id}/master.m3u8"
                    print(f"[{job_id}] Atualizando dados da lição no banco...")
                    supabase_client.update_lesson_data(
                        lesson_id=lesson_id,
                        hls_storage_path=hls_manifest_path,
                        duration=duration_sec,
                        ai_summary=ai_summary
                    )
                    
                    # 9. Finalizar o Job com sucesso
                    print(f"[{job_id}] Processamento concluído com sucesso!")
                    supabase_client.update_job_status(job_id, "completed")
                    
                except Exception as inner_error:
                    error_msg = f"Erro interno no processamento: {str(inner_error)}\n{traceback.format_exc()}"
                    print(f"[{job_id}] {error_msg}")
                    supabase_client.update_job_status(job_id, "failed", error_msg[:1000])
                    
                finally:
                    # Limpeza dos arquivos temporários locais
                    if os.path.exists(job_temp_dir):
                        shutil.rmtree(job_temp_dir)
            else:
                # Se não houver jobs, aguardar antes da próxima verificação
                await asyncio.sleep(5)
                
        except Exception as outer_error:
            print(f"Erro no loop do processador: {outer_error}")
            traceback.print_exc()
            await asyncio.sleep(10)

@app.on_event("startup")
async def startup_event():
    """Inicia a fila de processamento ao carregar o FastAPI."""
    # Inicia a task em background sem bloquear a inicialização da API
    asyncio.create_task(process_jobs_loop())

@app.get("/health")
def health_check():
    """Endpoint de verificação de integridade do container."""
    return {"status": "healthy", "time": time.time()}
