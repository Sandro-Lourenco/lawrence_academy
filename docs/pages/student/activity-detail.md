---
id: PAGE-STUDENT-006
name: Activity Detail
route: /dashboard/activities/:activityId
layout: StudentDashboardLayout
platforms:
  - Web
  - Android
roles:
  - Student
authentication: true
responsive: true
status: Production
design-system: Lawrence Design System
navigation: Nested Route
state-management: Riverpod
architecture: Clean Architecture + DDD
security:
  ownership-required: true
---

# Activity Detail

## Objetivo

A página **Activity Detail** é onde o aluno realiza uma atividade proposta pelo professor.

Ela deve suportar todos os tipos de avaliação da plataforma, oferecendo uma experiência limpa, focada e intuitiva.

O aluno nunca deve sentir ansiedade durante a realização da atividade.

A interface deve transmitir concentração e clareza.

Inspirada em:

- Coursera
- Canvas LMS
- Google Classroom
- Apple Classroom
- Notion

A atividade deve ser o único foco da tela.

---

# Objetivos

- Exibir todas as informações da atividade.
- Permitir responder qualquer tipo de exercício.
- Salvar automaticamente o progresso.
- Mostrar feedback do professor.
- Mostrar nota.
- Garantir segurança contra perda de respostas.

---

# Fluxo

```
Activities

↓

Selecionar atividade

↓

Ler instruções

↓

Responder

↓

Salvar automaticamente

↓

Enviar

↓

Correção

↓

Feedback

↓

Nota

↓

Próxima atividade
```

---

# Layout Desktop

```
------------------------------------------------------------

Glass Header

------------------------------------------------------------

Sidebar Curso

|

|

Conteúdo Principal

|

|

Painel Informações

------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Informações

↓

Questões

↓

Botão Enviar

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Breadcrumb

↓

Activity Hero

↓

Status Banner

↓

Instructions

↓

Questions

↓

Attachments

↓

Teacher Notes

↓

Evaluation Criteria

↓

Submit Section

↓

Feedback

↓

Navigation Footer
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

---

Componentes

Logo

Pesquisar

Notificações

Perfil

---

# Activity Hero

Mostrar

Título

Curso

Professor

Categoria

Tipo

Tempo estimado

Peso da nota

Prazo

Status

---

# Status Banner

Exemplo

```
Prazo

Hoje às 23:59

Tempo restante

02h 18min

Status

Em andamento
```

---

Caso expirada

Banner vermelho.

---

Caso corrigida

Banner verde.

---

# Instructions

Mostrar

Descrição completa

Objetivos

Critérios

Formato esperado

Pontuação

---

Markdown

Suportado.

---

# Questões

Dependem do tipo da atividade.

---

## Quiz

Alternativas

A

B

C

D

E

Card grande

52px

Radius

16px

Selecionado

Borda azul

Background azul claro

Animação

Spring

---

## Verdadeiro ou Falso

Dois cards.

Verdadeiro

Falso

---

## Discursiva

Editor rico.

Markdown.

Mínimo

6 linhas.

Auto Save.

Contador de caracteres.

---

## Upload de Arquivo

Suportar

PDF

DOCX

ZIP

PNG

JPG

MP4 (quando permitido)

Limite

Configurável pelo professor.

---

Botão

Selecionar Arquivo

---

Preview

Nome

Tamanho

Excluir

---

## Projeto

Área para descrição.

Upload de arquivos.

Links externos.

Observações.

---

# Auto Save

Salvar automaticamente.

A cada

15 segundos.

ou

Ao alterar resposta.

---

Indicador

```
✔ Salvo automaticamente
```

---

# Attachments

Arquivos enviados pelo professor.

PDF

Imagem

ZIP

Planilha

Checklist

---

# Teacher Notes

Mostrar dicas.

Boas práticas.

Erros comuns.

---

Card

Cinza claro.

---

# Evaluation Criteria

Rubrica.

Tabela

Critério

Peso

Descrição

---

Exemplo

```
Precisão

40%

Acabamento

30%

Criatividade

30%
```

---

# Submit Section

Botão

Enviar Atividade

Azul

Pill

52px

---

Antes do envio

Confirmação.

```
Deseja realmente enviar?

Após o envio não será possível editar.
```

---

# Feedback

Quando corrigida.

Mostrar

Nota

Professor

Comentários

Arquivos anexados

Data

---

Comentários destacados.

---

# Nota

Grande destaque.

Exemplo

```
9,8

Excelente trabalho.
```

---

# Histórico

Mostrar

Criada

Última edição

Enviada

Corrigida

---

# Navegação

Rodapé

```
← Atividade Anterior

Próxima →

```

---

# APIs

GET /activities/{id}

POST /activities/{id}/autosave

POST /activities/{id}/submit

GET /activities/{id}/feedback

GET /activities/{id}/attachments

POST /activities/{id}/upload

---

# Providers

activityProvider

questionProvider

autosaveProvider

submissionProvider

feedbackProvider

attachmentProvider

uploadProvider

---

# Componentes

ActivityHero

StatusBanner

InstructionCard

QuestionCard

EssayEditor

QuizCard

TrueFalseCard

UploadWidget

TeacherNotes

RubricTable

FeedbackCard

GradeCard

SubmitButton

SkeletonLoader

---

# Estados

Loading

Skeleton Apple Style

---

Sem anexos

Ocultar seção.

---

Enviada

Somente leitura.

---

Corrigida

Mostrar feedback.

---

Offline

Salvar localmente.

Sincronizar depois.

---

Erro

Botão

Tentar novamente.

---

# Motion

Fade

Scale

Blur

Spring

Hero Animation

Shared Transition

Hover

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Floating Submit Button

Bottom Navigation

Floating Toolbar

Modal

Nunca aplicar em

Questões

Texto

Editor

Feedback

Rubrica

Cards principais

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

Sucesso

#30D158

Erro

#FF453A

Aviso

#FF9F0A

---

# Responsividade

## Desktop

Sidebar fixa.

Painel lateral.

Área ampla para respostas.

---

## Tablet

Painel recolhível.

---

## Mobile

Uma coluna.

Questões empilhadas.

Botão Enviar fixo no final.

Safe Area.

---

# Performance

Auto Save local

Sincronização em background

Lazy Loading

Upload resumível

Cache

Skeleton

60 FPS

---

# Analytics

Tempo de resposta

Questões respondidas

Tentativas

Tempo médio

Uploads

Taxa de conclusão

Notas

Feedback recebido

---

# Segurança

Supabase Auth

JWT

HTTPS

OWASP Top 10

Role Guard

Ownership Guard

Proteção contra envio duplicado

Uploads validados

Arquivos escaneados

Rate Limit

Auto Save criptografado

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Screen Reader

Touch Target

44x44px

Focus Visible

Escala dinâmica de fonte

---

# Psicologia de Aprendizagem

## Redução da Ansiedade

Exibir continuamente:

- Tempo restante.
- Progresso da atividade.
- Status do Auto Save.

Sem cronômetros agressivos.

---

## Chunking

Questões longas devem ser divididas em blocos para reduzir a carga cognitiva.

---

## Feedback Imediato

Após envio:

✔ Atividade enviada.

✔ Recebida pelo professor.

✔ Aguarde a correção.

---

## Motivação

Após correção:

Mostrar comentários positivos.

Destacar pontos fortes.

Apresentar oportunidades de melhoria.

---

## Continuidade

Após concluir:

Sugerir automaticamente:

- Próxima atividade.
- Próxima aula.
- Próximo módulo.

---

# Critérios de Aceitação

- A página deve suportar todos os tipos de atividades da plataforma (Quiz, Verdadeiro/Falso, Discursiva, Upload de Arquivos e Projetos).
- O progresso deve ser salvo automaticamente durante a resolução da atividade.
- O aluno deve conseguir continuar uma atividade iniciada sem perder respostas.
- Após o envio, a atividade deve ficar bloqueada para edição, salvo quando permitido pelo professor.
- O feedback do professor deve exibir nota, comentários, rubrica de avaliação e anexos.
- O layout deve seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve ser aplicado apenas aos elementos flutuantes.
- A página deve oferecer uma experiência premium, minimalista, segura e centrada na aprendizagem, mantendo consistência entre Web e Android.
````
