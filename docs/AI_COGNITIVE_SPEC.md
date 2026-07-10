Excelente esclarecimento! Focar a Inteligência Artificial na **geração de resumos estruturados das aulas** e no **auxílio inteligente para anotações dos alunos** agrega um valor imenso à experiência de aprendizado, permitindo que o estudante foque nas mãos (corte e costura) enquanto a IA organiza a teoria técnica.

Com base nessa diretriz, desenvolvi o documento mestre **`AI_COGNITIVE_SPEC.md`**. Ele define a arquitetura de processamento audiovisual para extração de transcrições temporizadas, apresenta os **System Prompts** especializados no ecossistema de moda/modelagem e estabelece os contratos JSON estritos para consumo na interface do aluno.

Salve o bloco de código abaixo exatamente como **`./spec/AI_COGNITIVE_SPEC.md`**.

---

```markdown
---
version: 1.0.0
name: Lawrence-Academy-AI-Cognitive-Spec
type: Artificial Intelligence & Cognitive Services Specification
domain: Haute Couture, Sewing, Modeling & Fashion Design Education
ai_engines: OpenAI Whisper (Speech-to-Text) + Google Gemini Pro / OpenAI GPT-4o (Cognitive NLP)
architecture: Clean Architecture Infrastructure Adapter + Asynchronous Worker
---

# Lawrence Academy — AI & Cognitive Services Spec (`AI_COGNITIVE_SPEC.md`)

## 1. Visão Geral do Ecossistema Cognitivo

O motor de Inteligência Artificial da **Lawrence Academy** opera de forma desacoplada dentro do microserviço Python (`Video Pipeline Worker`), atuando como um **Adaptador de Infraestrutura** especializado em duas capacidades centrais de valor pedagógico:

1. **Resumo Automático de Aulas (Video Summarization):** Síntese estruturada do conteúdo técnico, dividindo o vídeo em tópicos-chave, passos práticos de costura/modelagem e glossário de termos aplicados.
2. **Assistente de Anotações Inteligentes (Smart Note-Taking):** Geração, formatação e aprofundamento em tempo real das anotações que o aluno realiza enquanto assiste à aula no player seguro.

```text
[ Áudio da Aula (.wav) ] ──► [ OpenAI Whisper ] ──► [ Transcrição Temporizada (.vtt / JSON) ]
                                                            │
                                                            ▼
                                                [ Google Gemini Pro / LLM ]
                                                            │
                   ┌────────────────────────────────────────┴────────────────────────────────────────┐
                   ▼                                                                                 ▼
     [ Gerador de Resumo Executivo ]                                                  [ Assistente de Anotações ]
(Tópicos, Passos de Costura, Glossário)                                          (Formatação, Timestamps, Insights)

```

---

## 2. Esteira de Transcrição Temporizada (`Speech-to-Text Pipeline`)

Antes de gerar resumos ou anotações, o áudio extraído da aula passa por reconhecimento de fala para mapeamento exato do tempo visual.

### 2.1. Configuração do Modelo (Whisper)

* **Modelo:** `whisper-large-v3` (otimizado para precisão técnica em português brasileiro).
* **Parâmetros:** `temperature: 0.0` (determinístico), `word_timestamps: true`.
* **Saída Intermediária:** Arquivo de transcrição estruturada contendo blocos temporizados (*start* e *end* em segundos).

---

## 3. Motor de Resumo Audiovisual (`Video Summarizer Engine`)

Acionado automaticamente pelo backend assim que a aula é processada pelo professor no painel. O resumo gerado fica disponível na aba "Visão Geral" do player do aluno.

### 3.1. System Prompt Especializado (Especialista em Moda e Modelagem)

```text
Você é o Assistente Pedagógico Principal da Lawrence Academy, uma plataforma de alta costura, modelagem e design de moda.
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
}

```

### 3.2. Contrato JSON de Persistência (`Lesson Summary Payload`)

O retorno validado da LLM é armazenado diretamente no PostgreSQL (Supabase) na coluna `ai_summary` (tipo `JSONB`) dentro da tabela `lessons`:

```json
{
  "executive_summary": "Nesta aula avançada, exploramos a construção da pense de busto em alfaiataria feminina, focando na precisão do traçado para evitar defeitos de caimento em tecidos encorpados.",
  "key_takeaways": [
    {
      "timestamp": "01:20",
      "seconds": 80,
      "topic": "Identificação do Ponto Altura de Busto",
      "description": "Como posicionar a fita métrica a partir do ombro para localizar o ápice anatômico."
    },
    {
      "timestamp": "05:45",
      "seconds": 345,
      "topic": "Transferência de Pense no Papel",
      "description": "Técnica de recorte e rotação do molde base para direcionar o volume para a lateral."
    }
  ],
  "step_by_step_execution": [
    "Marque o centro do busto no molde de corpo frente com caneta de ponta fina.",
    "Trace uma linha reta do ponto mais alto do ombro até o ápice da pense.",
    "Abra a pense lateral e feche a pense de cintura fixando com fita crepe."
  ],
  "technical_glossary": [
    {
      "term": "Ápice da Pense",
      "definition": "O ponto mais agudo da pense, que deve terminar cerca de 2cm antes do volume real do busto."
    }
  ]
}

```

---

## 4. Assistente Cognitivo de Anotações (`Smart Note-Taking Assistant`)

Durante a reprodução da aula no player, o aluno possui uma aba lateral chamada **"Minhas Anotações"**. O assistente de IA opera de forma interativa para organizar e enriquecer os apontamentos do estudante.

### 4.1. Modos de Operação do Assistente

* **Modo Formatação e Correção (Format & Polish):** O aluno digita ideias rápidas e desorganizadas (ex: *"cortar 1,5 cm margem tecido seda cuidado agulha finha"*). A IA formata em um *bullet point* técnico perfeito, corrigindo termos de costura.
* **Modo Anotação Temporal (Smart Snapshot):** O aluno clica no botão ✨ **"Gerar Anotação Deste Momento"**. A IA captura o *timestamp* atual do vídeo (ex: `04:12`), lê a transcrição dos últimos 30 segundos e elabora uma nota explicativa automática.
* **Modo Expansão Conceitual (Deepen Note):** O aluno seleciona uma nota escrita e solicita aprofundamento. A IA complementa com dicas de manuseio do tecido ou regulagem da máquina.

### 4.2. System Prompt para Auxílio de Anotações

```text
Você é o Copiloto de Estudos de Moda da Lawrence Academy.
Seu objetivo é transformar rascunhos rápidos de alunos ou trechos de transcrição de vídeo em notas de estudo organizadas, claras e tecnicamente impecáveis.

REGRAS:
1. Mantenha a voz no formato de anotação de estudo (objetiva, em tópicos ou passos curtos).
2. Se o aluno pedir para resumir o minuto atual da aula, utilize o trecho da transcrição fornecido no prompt para extrair a lição exata explicada pelo instrutor naquele momento.
3. Não adicione informações que contradigam a metodologia de costura apresentada.

RETORNO ESPERADO (JSON):
{
  "formatted_note": "Anotação clara e bem redigida em Markdown limpo.",
  "suggested_tags": ["modelagem", "pense-busto", "alfaiataria"]
}

```

---

## 5. Integração com Casos de Uso (`Application Layer`)

Na arquitetura da aplicação, os serviços de IA são expostos como interfaces de porta (`Ports`) consumidas pelos Casos de Uso:

### 5.1. Contrato da Interface (`Domain Port`)

```python
# app/domain/repositories/ai_cognitive_port.py
from typing import Dict, Any, List
from typing_extensions import Protocol

class AICognitivePort(Protocol):
    async def generate_lesson_summary(self, transcript_text: str) -> Dict[str, Any]:
        """Gera o resumo executivo, passos e glossário da aula."""
        ...

    async def assist_student_note(
        self, 
        raw_input: str, 
        current_timestamp_sec: int, 
        recent_transcript_context: str
    ) -> Dict[str, Any]:
        """Formata ou gera notas inteligentes baseadas no tempo do player."""
        ...

```

### 5.2. Rota API para Assistente de Anotação em Tempo Real

* **Endpoint:** `POST /api/v1/lessons/{lesson_id}/notes/assist`
* **Payload Request:**
```json
{
  "raw_note_text": "fazer acabamento em vies no decote",
  "timestamp_seconds": 210,
  "action_type": "format" // "format" | "generate_from_timestamp" | "expand"
}

```


* **Response (200 OK):**
```json
{
  "status": "success",
  "data": {
    "timestamp_formatted": "03:30",
    "enhanced_note": "✨ **Acabamento em Viés no Decote:** Corte a tira de viés no ângulo exato de 45° em relação ao fio reto para garantir elasticidade visual sem repuxar a curva do colo.",
    "tags": ["acabamento", "viés", "decote"]
  }
}

```



```

```