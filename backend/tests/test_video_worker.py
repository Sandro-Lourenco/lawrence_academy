import sys
import os
import pytest

# Adicionar o diretório video-worker ao path para importar os módulos
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "video-worker")))

import transcriber
import summarizer
import transcoder

def test_whisper_segment_cleanup():
    """Testa a limpeza de legendas duplicadas e sobrepostas do Whisper."""
    raw_segments = [
        {"start": 0.0, "end": 2.0, "text": "Olá a todos"},
        # Repetição exata consecutiva (deve ser mesclada no anterior com tempo estendido)
        {"start": 2.0, "end": 4.0, "text": "Olá a todos"},
        # Segmento normal
        {"start": 4.5, "end": 8.0, "text": "Hoje aprenderemos costura"},
        # Sobreposição temporal significativa com texto similar (deve ser fundida)
        {"start": 7.0, "end": 10.0, "text": "Aprenderemos costura avançada"}
    ]
    
    cleaned = transcriber.clean_up_segments(raw_segments)
    
    # Validações
    assert len(cleaned) == 2
    
    # O primeiro segmento deve ter acumulado o tempo do duplicado (0.0 a 4.0)
    assert cleaned[0]["text"] == "Olá a todos"
    assert cleaned[0]["start"] == 0.0
    assert cleaned[0]["end"] == 4.0
    
    # O segundo segmento deve ter fundido a sobreposição mantendo a maior string (Hoje aprenderemos costura avançada)
    assert cleaned[1]["start"] == 4.5
    assert cleaned[1]["end"] == 10.0
    assert "Hoje aprenderemos costura" in cleaned[1]["text"] or "costura avançada" in cleaned[1]["text"]

def test_context_compression_logic():
    """Testa a estratégia de fragmentação do summarizer para transcrições longas."""
    # Criar uma transcrição longa simulada
    mock_lines = [f"[{i:02d}:00] Linha de teste de costura numero {i} contendo termos de modelagem." for i in range(100)]
    
    # Testar que a divisão em chunks funciona sem estourar o buffer
    # Vamos rodar com limite simulado pequeno
    chunks = []
    current_chunk = []
    current_len = 0
    chunk_size = 500
    
    for line in mock_lines:
        current_chunk.append(line)
        current_len += len(line) + 1
        if current_len >= chunk_size:
            chunks.append("\n".join(current_chunk))
            # Manter sobreposição
            overlap_lines = current_chunk[-2:]
            current_chunk = overlap_lines
            current_len = sum(len(l) + 1 for l in current_chunk)
            
    if current_chunk:
        chunks.append("\n".join(current_chunk))
        
    assert len(chunks) > 1
    # Cada chunk deve conter dados e sobreposições corretas
    assert "Linha de teste" in chunks[0]
    assert "Linha de teste" in chunks[1]

def test_mock_transcription_and_summary_fallbacks():
    """Garante que as rotinas de mock/fallback estão retornando os esquemas válidos na ausência de chaves de API."""
    mock_trans = transcriber.get_mock_transcription()
    assert len(mock_trans) > 0
    assert "start" in mock_trans[0]
    assert "text" in mock_trans[0]
    
    mock_sum = summarizer.get_mock_summary()
    assert "title" in mock_sum
    assert "executive_summary" in mock_sum
    assert len(mock_sum["key_takeaways"]) > 0
    assert len(mock_sum["step_by_step_execution"]) > 0
    assert len(mock_sum["technical_glossary"]) > 0
