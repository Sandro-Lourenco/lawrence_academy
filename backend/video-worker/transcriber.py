import os
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

# Cliente OpenAI
api_key = os.getenv("OPENAI_API_KEY")
client = OpenAI(api_key=api_key) if api_key else None

def transcribe_audio_file(audio_path: str) -> list:
    """Usa a API da OpenAI (Whisper) para transcrever o áudio com timestamps."""
    if not client:
        # Mock de transcrição caso não haja chave da API (para testes ou demonstração)
        print("Aviso: OPENAI_API_KEY não definida. Utilizando transcrição simulada (Mock).")
        return get_mock_transcription()

    with open(audio_path, "rb") as audio_file:
        response = client.audio.transcriptions.create(
            model="whisper-1",
            file=audio_file,
            response_format="verbose_json",
            timestamp_granularities=["segment"]
        )
        
    segments = []
    if hasattr(response, "segments"):
        for seg in response.segments:
            if isinstance(seg, dict):
                start = seg.get("start", 0.0)
                end = seg.get("end", 0.0)
                text = seg.get("text", "")
            else:
                start = getattr(seg, "start", 0.0)
                end = getattr(seg, "end", 0.0)
                text = getattr(seg, "text", "")
                
            segments.append({
                "start": start,
                "end": end,
                "text": text.strip() if text else ""
            })
    return clean_up_segments(segments)

def clean_up_segments(segments: list) -> list:
    """Limpa redundâncias e marcadores de tempo sobrepostos do Whisper.
    Remove repetições contíguas e combina segmentos sobrepostos com texto similar.
    """
    if not segments:
        return []

    cleaned = []
    prev_text = ""
    
    for seg in segments:
        text = seg["text"].strip()
        if not text:
            continue
            
        # Remover repetições exatas consecutivas
        if text.lower() == prev_text.lower():
            if cleaned:
                cleaned[-1]["end"] = max(cleaned[-1]["end"], seg["end"])
            continue
            
        # Verificar se há sobreposição no tempo
        if cleaned and seg["start"] < cleaned[-1]["end"]:
            # Calcular a similaridade de tokens
            tokens1 = set(cleaned[-1]["text"].lower().split())
            tokens2 = set(text.lower().split())
            
            intersection = tokens1.intersection(tokens2)
            similarity = len(intersection) / max(1, min(len(tokens1), len(tokens2)))
            
            # Se a similaridade de termos for alta (> 50%)
            if similarity > 0.5:
                # Funde os dois segmentos combinando os textos
                merged_tokens = []
                # Une os tokens sem duplicar os adjacentes redundantes
                t1_list = cleaned[-1]["text"].split()
                t2_list = text.split()
                
                # Junta strings inteligentemente
                for t in t1_list:
                    merged_tokens.append(t)
                for t in t2_list:
                    if t not in merged_tokens[-3:]: # evita repetição de palavras no final
                        merged_tokens.append(t)
                        
                cleaned[-1]["text"] = " ".join(merged_tokens)
                cleaned[-1]["end"] = max(cleaned[-1]["end"], seg["end"])
                continue

        cleaned.append({
            "start": seg["start"],
            "end": seg["end"],
            "text": text
        })
        prev_text = text

    return cleaned

def get_mock_transcription() -> list:
    """Mock de transcrição realista de moda/modelagem para desenvolvimento local."""
    return [
        {"start": 0.0, "end": 4.5, "text": "Olá a todos! Sejam muito bem-vindos à Lawrence Academy."},
        {"start": 5.0, "end": 9.2, "text": "Hoje vamos aprender sobre a construção da pense de busto em alfaiataria feminina."},
        {"start": 10.0, "end": 14.5, "text": "O primeiro passo é posicionar a fita métrica a partir do ombro para localizar o ápice anatômico."},
        {"start": 15.0, "end": 19.8, "text": "Marque o centro com uma caneta de ponta fina, tomando muito cuidado para manter o alinhamento."},
        {"start": 20.5, "end": 26.0, "text": "Em seguida, faremos a transferência de pense abrindo a lateral e fechando a cintura no molde base."},
        {"start": 27.2, "end": 32.5, "text": "Lembre-se de manter uma folga de costura de 1.5 cm nas bordas do decote."},
        {"start": 33.0, "end": 37.8, "text": "Isso garante que o acabamento em viés na seda tenha elasticidade visual sem repuxar."}
    ]
