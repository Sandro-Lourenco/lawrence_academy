---
id: PAGE-TEACHER-009
name: Correction
route: /teacher/correction
layout: TeacherDashboardLayout
platforms:
  - Web
  - Android
roles:
  - Teacher
authentication: true
responsive: true
status: Production
design-system: Lawrence Design System
navigation: Sidebar + Top Navigation
state-management: Riverpod
architecture: Clean Architecture + DDD
real-time: Supabase Realtime

correction:
  manual_grading: true
  automatic_grading: true
  rubric_support: true
  teacher_feedback: true
  ai_assisted_feedback: future
  plagiarism_detection: future
---

# Correction

## Objetivo

A página **Correction** é o ambiente onde o professor corrige atividades enviadas pelos alunos.

Ela deve permitir avaliar respostas, atribuir nota, escrever feedback, revisar anexos, aplicar rubricas e publicar a correção de forma clara e organizada.

A correção não deve parecer uma tela burocrática.

Ela deve funcionar como uma experiência pedagógica, ajudando o professor a entregar feedback útil, construtivo e profissional.

Inspirada em:

- Google Classroom
- Canvas SpeedGrader
- GitHub Pull Request Review
- Notion Comments
- Linear Review
- Apple Education

---

# Objetivos

- Listar atividades pendentes de correção.
- Corrigir respostas dos alunos.
- Visualizar respostas e anexos.
- Aplicar rubricas.
- Atribuir nota.
- Escrever feedback.
- Publicar correção.
- Notificar aluno.
- Acompanhar histórico.

---

# Fluxo

```text
Professor

↓

Correction

↓

Seleciona envio

↓

Analisa resposta

↓

Atribui nota

↓

Escreve feedback

↓

Publica correção

↓

Aluno é notificado
```

---

# Layout Desktop

```text
------------------------------------------------------------

Glass Header

------------------------------------------------------------

Sidebar

|

Submission Queue

|

Correction Workspace

|

Rubric / Student Info Panel

------------------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Fila de Correções

↓

Resposta

↓

Nota e Feedback

↓

Publicar

↓

Bottom Actions
```

---

# Estrutura

```text
Glass Header

↓

Correction Summary

↓

Filters

↓

Submission Queue

↓

Correction Workspace

↓

Student Submission

↓

Rubric

↓

Grade

↓

Teacher Feedback

↓

Attachments Review

↓

Publish Correction
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur

20px

Opacity

72%

Componentes:

- Logo
- Pesquisa
- Notificações
- Perfil

---

# Correction Summary

Cards superiores.

Mostrar:

- Correções pendentes
- Corrigidas hoje
- Média da turma
- Tempo médio de correção
- Atividades atrasadas
- Feedbacks publicados

Exemplo:

```text
18 pendentes

7 corrigidas hoje

Média da turma: 8.4

Tempo médio: 4min
```

---

# Filters

Filtros disponíveis:

- Todos
- Pendentes
- Em correção
- Corrigidos
- Revisão solicitada
- Atrasados
- Por curso
- Por atividade
- Por turma
- Por nota
- Por data de envio

Ordenação:

- Mais recentes
- Mais antigos
- Maior nota
- Menor nota
- Prazo
- Curso
- Aluno

---

# Submission Queue

Lista lateral de envios.

Cada item mostra:

- Foto do aluno
- Nome do aluno
- Curso
- Atividade
- Data de envio
- Status
- Tipo de atividade
- Indicador de anexos

Status:

- Pendente
- Em correção
- Corrigido
- Revisão solicitada
- Publicado

---

# Correction Workspace

Área central.

Deve mostrar a submissão completa do aluno.

Tipos suportados:

- Múltipla escolha
- Verdadeiro/Falso
- Discursiva
- Projeto prático
- Upload de arquivo
- Imagem
- PDF
- ZIP
- Vídeo
- Checklist

---

# Student Submission

Mostrar:

- Enunciado da atividade
- Resposta do aluno
- Arquivos enviados
- Data de envio
- Tempo gasto
- Tentativa
- Histórico de versões

---

# Multiple Choice Correction

Quando a atividade for objetiva:

Mostrar:

- Alternativa marcada pelo aluno
- Alternativa correta
- Resultado
- Pontuação automática
- Opção para ajuste manual

---

# Essay Correction

Quando for discursiva:

Mostrar:

- Texto do aluno
- Comentários inline
- Destaques
- Sugestões
- Nota manual
- Feedback final

O professor pode selecionar trechos do texto e adicionar comentários.

---

# Project Correction

Quando for projeto prático:

Mostrar:

- Descrição enviada
- Arquivos anexados
- Imagens
- PDFs
- Vídeos
- Links externos
- Checklist de critérios

---

# Attachments Review

Visualizadores:

- PDF Viewer
- Image Viewer
- Video Preview
- File List
- Download seguro
- Comentários por arquivo

Cada anexo mostra:

- Nome
- Tipo
- Tamanho
- Data
- Status de segurança

---

# Rubric

Rubrica de avaliação.

Cada critério possui:

- Nome
- Descrição
- Peso
- Pontuação máxima
- Nota atribuída
- Comentário específico

Exemplo:

| Critério | Peso | Nota |
|---|---:|---:|
| Técnica | 40% | 38 |
| Acabamento | 30% | 27 |
| Criatividade | 20% | 18 |
| Organização | 10% | 10 |

---

# Grade

Campos:

- Nota final
- Pontuação máxima
- Conceito
- Status
- Aprovado/Reprovado

Cálculo:

```text
Nota final = soma dos critérios da rubrica
```

ou

```text
Nota manual definida pelo professor
```

---

# Teacher Feedback

Campo principal de feedback.

Suporta:

- Texto
- Markdown
- Lista
- Destaques
- Links
- Anexos
- Áudio feedback (futuro)
- Vídeo feedback (futuro)

Estrutura recomendada:

```text
1. Pontos fortes

2. Pontos a melhorar

3. Próximo passo recomendado
```

---

# Feedback Templates

Modelos rápidos:

- Excelente trabalho
- Melhorar acabamento
- Revisar técnica
- Corrigir medidas
- Reenviar atividade
- Aprovado
- Reprovado com orientação
- Solicitar revisão

---

# Inline Comments

Permitir comentários em:

- Texto discursivo
- PDF
- Imagem
- Checklist
- Arquivos enviados

Cada comentário possui:

- Autor
- Trecho relacionado
- Mensagem
- Data
- Status

---

# Publish Correction

Antes de publicar:

Mostrar resumo:

- Nota
- Feedback
- Rubrica
- Status
- Aluno
- Atividade

Botões:

- Salvar rascunho
- Publicar correção
- Solicitar reenvio
- Marcar como revisado

Após publicar:

- aluno recebe notificação
- nota fica visível
- feedback fica visível
- progresso pode ser atualizado
- certificado pode ser liberado se todos os requisitos forem concluídos

---

# APIs

GET /teacher/corrections

GET /teacher/corrections/{submissionId}

PATCH /teacher/corrections/{submissionId}

POST /teacher/corrections/{submissionId}/grade

POST /teacher/corrections/{submissionId}/feedback

POST /teacher/corrections/{submissionId}/publish

POST /teacher/corrections/{submissionId}/request-resubmission

GET /teacher/corrections/{submissionId}/attachments

POST /teacher/corrections/{submissionId}/comments

GET /teacher/corrections/templates

---

# Providers

correctionProvider

submissionQueueProvider

submissionDetailProvider

rubricProvider

gradeProvider

teacherFeedbackProvider

attachmentReviewProvider

inlineCommentProvider

publishCorrectionProvider

feedbackTemplateProvider

---

# Componentes

GlassHeader

CorrectionSummaryCard

CorrectionFilterBar

SubmissionQueue

SubmissionQueueItem

CorrectionWorkspace

StudentSubmissionViewer

RubricTable

GradeInput

FeedbackEditor

FeedbackTemplatePicker

AttachmentViewer

InlineComment

PublishCorrectionDialog

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Sem correções

Mostrar:

```text
Nenhuma atividade aguardando correção.
```

Botão:

```text
Ver atividades
```

---

## Em correção

Salvar automaticamente.

Mensagem:

```text
Correção salva como rascunho.
```

---

## Publicado

Banner verde:

```text
Correção publicada com sucesso.
```

---

## Reenvio solicitado

Banner azul:

```text
O aluno foi notificado para reenviar a atividade.
```

---

## Erro

Toast:

```text
Não foi possível salvar a correção.
```

Botão:

```text
Tentar novamente
```

---

# Motion

Fade

Slide

Scale

Spring

Blur

Shared Transition

Skeleton

Progress Animation

Inline Comment Animation

---

# Liquid Glass

Aplicar apenas em:

- Glass Header
- Floating Correction Toolbar
- Publish Dialog
- Feedback Template Picker
- Bottom Actions
- Notification Panel

Nunca aplicar em:

- Resposta do aluno
- Rubrica
- Editor de feedback
- Tabelas
- Cards principais
- Lista de envios

---

# Tipografia

Hero

36px

Heading

28px

Subheading

22px

Body

17px

Caption

13px

Micro

11px

---

# Cores

60%

White

#FFFFFF

30%

Primary Blue

#0A84FF

10%

Premium Gold

#D4AF37

Success

#30D158

Warning

#FF9F0A

Danger

#FF453A

Info

#64D2FF

Text

#1D1D1F

---

# Responsividade

## Desktop

Fila de submissões à esquerda.

Workspace central.

Rubrica e informações do aluno à direita.

---

## Tablet

Painel direito recolhível.

---

## Mobile

Fluxo em etapas:

1. Selecionar envio
2. Visualizar resposta
3. Corrigir
4. Publicar

Bottom Actions fixo.

Safe Area.

---

# Performance

Autosave

Realtime

Optimistic Update

Lazy Loading

Attachment Preview Cache

Skeleton Loading

Virtual Scroll

60 FPS

---

# Analytics

Correções pendentes

Correções publicadas

Tempo médio de correção

Notas médias

Atividades com maior dificuldade

Feedbacks enviados

Reenvios solicitados

---

# Segurança

Supabase Auth

JWT

HTTPS

Row Level Security

Teacher Guard

Ownership Guard

Logs de Auditoria

Controle de acesso por curso

Validação de anexos

Proteção contra alteração após publicação

Criptografia

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Touch Target

44x44px

Focus Visible

Escala dinâmica

Alto contraste

Comentários acessíveis

---

# Psicologia de Produto

## Feedback Construtivo

A interface deve incentivar o professor a começar pelos pontos fortes antes das melhorias.

---

## Redução de Carga Cognitiva

Separar claramente:

- resposta do aluno
- rubrica
- nota
- feedback

---

## Produtividade

Templates de feedback reduzem repetição e aceleram correções.

---

## Confiança

Autosave e rascunho garantem que nenhuma correção seja perdida.

---

# Critérios de Aceitação

- O professor deve conseguir visualizar todas as atividades pendentes de correção.
- O sistema deve suportar correção de respostas objetivas, discursivas, projetos e uploads.
- Deve existir suporte a rubricas, nota manual, comentários inline e feedback final.
- O professor deve conseguir salvar rascunho, publicar correção ou solicitar reenvio.
- Após a publicação, o aluno deve receber notificação em tempo real.
- A correção publicada não deve ser alterada sem registrar nova versão ou log de auditoria.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado exclusivamente em elementos flutuantes.
- A experiência deve ser produtiva, clara e pedagógica, mantendo o padrão premium da Lawrence Academy.