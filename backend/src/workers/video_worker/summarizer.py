import os
import json
from google import genai
from google.genai import types
from dotenv import load_dotenv

load_dotenv()

# Configuração da API do Gemini
gemini_key = os.getenv("GEMINI_API_KEY")
client = None
if gemini_key:
    client = genai.Client(api_key=gemini_key)

SYSTEM_PROMPT = """Você é o Assistente Pedagógico Principal da Lawrence Academy, uma plataforma de alta costura, modelagem e design de moda.
Sua missão é analisar a transcrição bruta de uma aula em vídeo e gerar um resumo técnico altamente estruturado e didático.

DIRETRIZES DE ESTILO:
1. Tom editorial, sofisticado, encorajador e extremamente preciso nos termos técnicos da costura (ex: fio reto, viés, pense, margem de costura, chuleado, sobreposição).
2. Evite introduções prolixas. Vá direto à estrutura solicitada.
3. Organize o conteúdo para fácil leitura visual (escaneabilidade).

SAÍDA OBRIGATÓRIA EM JSON ESTRUTURADO RESPONDENDO AO SEGUINTE ESQUEMA:
{
  "title": "Título otimizado da aula",
  "executive_summary": "Resumo de 2 a 3 parágrafos sobre o objetivo principal da lição.",
  "key_takeaways": [
    {
      "timestamp": "02:15",
      "seconds": 135,
      "topic": "Nome do Tópico",
      "description": "Explicação detalhada do ponto abordado."
    }
  ],
  "step_by_step_execution": [
    "Passo 1: Medição e traçado inicial da pense.",
    "Passo 2: Alinhamento do molde com o fio reto do tecido."
  ],
  "technical_glossary": [
    {
      "term": "Margem de Costura",
      "definition": "Distância entre a linha da costura e a borda do corte do tecido."
    }
  ]
}"""

CONSOLIDATION_PROMPT = """Você é o Diretor Pedagógico da Lawrence Academy.
Abaixo estão resumos parciais de partes de uma mesma aula em vídeo de modelagem/costura.
Sua missão é fundir estes resumos parciais em um único documento final consolidado e sem redundâncias, respeitando a estrutura do nosso padrão JSON.

REGRAS DE CONSOLIDAÇÃO:
1. Remova repetições de tópicos semelhantes nos "key_takeaways" e ordene-os por segundos de forma crescente.
2. Agrupe e ordene de forma lógica o "step_by_step_execution", garantindo que a sequência reflita o passo a passo completo da aula do início ao fim.
3. Combine os glossários e elimine termos duplicados.
4. Mantenha o tom de alta costura refinado.

SAÍDA OBRIGATÓRIA EM JSON ESTRUTURADO RESPONDENDO AO MESMO ESQUEMA ANTERIOR."""


def summarize_transcription(segments: list) -> dict:
    """Gera o resumo estruturado (ai_summary) da lição.
    Se o texto for muito longo, fragmenta e consolida as partes usando IA.
    """
    if not gemini_key:
        print("Aviso: GEMINI_API_KEY não definida. Utilizando resumo simulado (Mock).")
        return get_mock_summary()

    # Formatar os segmentos em blocos de texto legíveis com marcação de tempo
    text_blocks = []
    total_length = 0
    for seg in segments:
        m, s = divmod(int(seg["start"]), 60)
        timestamp = f"{m:02d}:{s:02d}"
        line = f"[{timestamp}] {seg['text']}"
        text_blocks.append(line)
        total_length += len(line)

    full_transcript = "\n".join(text_blocks)

    # Limite seguro de caracteres antes da fragmentação (aprox. 8000 caracteres)
    threshold = 8000
    if total_length <= threshold:
        return _call_gemini_api(
            SYSTEM_PROMPT, f"Transcrição da aula:\n\n{full_transcript}"
        )
    else:
        print(
            f"Transcrição longa ({total_length} caracteres). Iniciando pipeline de compressão de contexto..."
        )
        return _summarize_in_chunks(text_blocks, chunk_size=6000, overlap=1000)


def _summarize_in_chunks(text_lines: list, chunk_size: int, overlap: int) -> dict:
    """Fragmenta a transcrição longa em pedaços sobrepostos, resume cada um e depois os consolida."""
    chunks = []
    current_chunk = []
    current_len = 0

    for line in text_lines:
        current_chunk.append(line)
        current_len += len(line) + 1
        if current_len >= chunk_size:
            chunks.append("\n".join(current_chunk))
            # Manter sobreposição voltando algumas linhas
            overlap_lines = current_chunk[-(len(current_chunk) // 5) :]
            current_chunk = overlap_lines
            current_len = sum(len(line_item) + 1 for line_item in current_chunk)

    if current_chunk:
        chunks.append("\n".join(current_chunk))

    # Resumir cada pedaço individualmente
    partial_summaries = []
    for idx, chunk in enumerate(chunks):
        print(f"Processando fragmento {idx + 1}/{len(chunks)}...")
        partial_json = _call_gemini_api(
            SYSTEM_PROMPT,
            f"Este é o fragmento {idx + 1} de uma aula de modelagem. Resuma tecnicamente esta parte:\n\n{chunk}",
        )
        partial_summaries.append(json.dumps(partial_json, ensure_ascii=False))

    # Consolidar todos os resumos em um só
    print("Consolidando resumos parciais em um payload unificado...")
    consolidation_input = "\n\n=== Resumo Parcial ===\n".join(partial_summaries)

    return _call_gemini_api(
        CONSOLIDATION_PROMPT,
        f"Resumos parciais para consolidação:\n\n{consolidation_input}",
    )


def _call_gemini_api(system_instruction: str, prompt: str) -> dict:
    """Realiza a chamada direta para o modelo do Gemini, forçando resposta JSON."""
    try:
        if not client:
            raise ValueError("Gemini Client não inicializado")
        response = client.models.generate_content(
            model="gemini-1.5-pro",
            contents=prompt,
            config=types.GenerateContentConfig(
                system_instruction=system_instruction,
                response_mime_type="application/json",
            ),
        )
        text_val = getattr(response, "text", "") or ""
        summary_text = text_val.strip()
        return json.loads(summary_text)
    except Exception as e:
        print(f"Erro ao chamar API do Gemini: {e}")
        # Retorna estrutura de erro básica para evitar quebra do pipeline
        return {
            "title": "Aula de Alta Costura",
            "executive_summary": "Erro de processamento da IA ao gerar o resumo executivo.",
            "key_takeaways": [],
            "step_by_step_execution": [],
            "technical_glossary": [],
        }


def get_mock_summary() -> dict:
    """Resumo de IA simulado idêntico às especificações do projeto."""
    return {
        "title": "Modelagem de Pense de Busto em Alfaiataria",
        "executive_summary": "Nesta aula avançada, exploramos a construção da pense de busto em alfaiataria feminina, focando na precisão do traçado para evitar defeitos de caimento em tecidos encorpados.",
        "key_takeaways": [
            {
                "timestamp": "01:20",
                "seconds": 80,
                "topic": "Identificação do Ponto Altura de Busto",
                "description": "Como posicionar a fita métrica a partir do ombro para localizar o ápice anatômico.",
            },
            {
                "timestamp": "05:45",
                "seconds": 345,
                "topic": "Transferência de Pense no Papel",
                "description": "Técnica de recorte e rotação do molde base para direcionar o volume para a lateral.",
            },
        ],
        "step_by_step_execution": [
            "Marque o centro do busto no molde de corpo frente com caneta de ponta fina.",
            "Trace uma linha reta do ponto mais alto do ombro até o ápice da pense.",
            "Abra a pense lateral e feche a pense de cintura fixando com fita crepe.",
        ],
        "technical_glossary": [
            {
                "term": "Ápice da Pense",
                "definition": "O ponto mais agudo da pense, que deve terminar cerca de 2cm antes do volume real do busto.",
            }
        ],
    }
