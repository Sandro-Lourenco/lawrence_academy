---
id: PAGE-TEACHER-008
name: Assignments
route: /teacher/courses/:courseId/assignments
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

assignments:
  autosave: true
  draft: true
  grading: automatic_and_manual
  plagiarism_detection: future
  ai_assisted_feedback: future
---

# Assignments

## Objetivo

A página **Assignments** permite ao professor criar, organizar, publicar e corrigir todas as atividades de um curso.

As atividades são um dos principais mecanismos de avaliação da plataforma e podem ser utilizadas para validar o aprendizado dos alunos, gerar certificados e acompanhar o desempenho da turma.

A interface deve ser extremamente simples, permitindo criar uma atividade em poucos minutos, sem sobrecarregar o usuário com opções desnecessárias.

Inspirado em:

- Google Classroom
- Canvas LMS
- Moodle
- Apple Classroom
- Notion
- Linear

---

# Objetivos

- Criar atividades.
- Editar atividades.
- Organizar avaliações.
- Corrigir respostas.
- Definir notas.
- Acompanhar desempenho.
- Publicar atividades.
- Gerenciar feedbacks.

---

# Fluxo

```
Professor

↓

Criar Atividade

↓

Selecionar Tipo

↓

Configurar

↓

Publicar

↓

Aluno responde

↓

Correção

↓

Nota

↓

Feedback
```

---

# Layout Desktop

```
------------------------------------------------------------

Glass Header

------------------------------------------------------------

Sidebar

|

Assignments List

|

Assignment Editor

|

Preview

------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Lista

↓

Editor

↓

Bottom Actions
```

---

# Estrutura

```
Glass Header

↓

Assignments Overview

↓

Assignment List

↓

Assignment Editor

↓

Evaluation Rules

↓

Preview

↓

Publish
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur 20px

Opacity 72%

---

# Assignments Overview

Mostrar

Total de atividades

Publicadas

Rascunhos

Pendentes de correção

Taxa média de conclusão

---

# Lista de Atividades

Cada item apresenta

Título

Tipo

Módulo

Data

Prazo

Status

Quantidade de respostas

---

Ações

Editar

Duplicar

Arquivar

Excluir

Visualizar

---

# Criar Atividade

Tipos disponíveis

---

## Questionário

Múltipla escolha

Verdadeiro/Falso

Resposta única

Resposta múltipla

---

## Discursiva

Texto livre

Correção manual

---

## Projeto

Entrega de arquivos

PDF

ZIP

Imagem

Vídeo

---

## Upload

Enviar documentos

Enviar imagens

Enviar vídeos

---

## Checklist

Lista de tarefas

---

## Exercício Prático

Resposta aberta

---

# Informações Básicas

Campos

Título

Descrição

Curso

Módulo

Aula

Categoria

Pontuação máxima

Tempo estimado

---

# Configuração

Permitir tentativas

Número máximo

Nota mínima

Peso da atividade

Obrigatória

Opcional

---

# Datas

Disponível em

Data de encerramento

Data limite

Liberação automática

---

# Questões

Adicionar

Editar

Duplicar

Excluir

Mover

Drag & Drop

---

# Correção

## Automática

Questionários

Verdadeiro/Falso

Múltipla escolha

---

## Manual

Dissertações

Projetos

Uploads

---

## Futuro

Correção assistida por IA

Sugestão de nota

Sugestão de feedback

Detecção de plágio

---

# Rubrica de Avaliação

Critérios

Peso

Pontuação

Comentários

---

# Feedback

Texto

Áudio

Vídeo

Anexos

Comentários privados

Comentários públicos

---

# Preview

Mostrar exatamente como o aluno visualizará a atividade.

Desktop

Tablet

Mobile

---

# Publicação

Estados

Rascunho

↓

Publicado

↓

Agendado

↓

Encerrado

↓

Arquivado

---

Botões

Salvar

Publicar

Duplicar

Cancelar

---

# APIs

GET /teacher/assignments

GET /teacher/assignments/{id}

POST /teacher/assignments

PATCH /teacher/assignments/{id}

DELETE /teacher/assignments/{id}

POST /teacher/assignments/publish

POST /teacher/assignments/duplicate

GET /teacher/submissions

POST /teacher/grade

POST /teacher/feedback

---

# Providers

assignmentProvider

assignmentEditorProvider

submissionProvider

gradingProvider

feedbackProvider

previewProvider

autosaveProvider

---

# Componentes

GlassHeader

AssignmentOverview

AssignmentCard

AssignmentEditor

QuestionBuilder

RubricCard

FeedbackCard

PreviewCard

BottomActions

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Sem atividades

Mostrar

```
Este curso ainda não possui atividades.

Crie a primeira atividade.
```

Botão

Nova Atividade

---

## Autosave

```
Alterações salvas automaticamente.
```

---

## Publicado

```
Atividade publicada com sucesso.
```

---

## Correção concluída

Banner verde

```
Notas publicadas.
```

---

## Erro

Toast

Botão

Tentar novamente

---

# Motion

Fade

Slide

Scale

Spring

Shared Transition

Blur

Progress Animation

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Dialogs

Bottom Actions

Floating Buttons

Floating Filters

Nunca aplicar em

Lista

Editor

Cards principais

Texto

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

Lista lateral.

Editor central.

Preview lateral.

---

## Tablet

Preview recolhível.

---

## Mobile

Editor em tela cheia.

Bottom Sheet para ações.

Safe Area.

---

# Performance

Lazy Loading

Autosave

Realtime

Optimistic Update

Cache

Skeleton Loading

60 FPS

---

# Analytics

Atividades criadas

Taxa de conclusão

Tempo médio de resposta

Nota média

Questões mais erradas

Questões mais fáceis

Pendências de correção

---

# Segurança

Supabase Auth

JWT

HTTPS

Row Level Security

Teacher Guard

Versionamento

Logs de Auditoria

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

---

# Psicologia de Produto

## Simplicidade

Criar uma atividade deve exigir o menor número possível de etapas.

---

## Clareza

O professor deve identificar rapidamente quais atividades estão pendentes de correção.

---

## Organização

Separar claramente criação, correção e feedback reduz a carga cognitiva.

---

## Motivação

Exibir estatísticas de desempenho da turma ajuda o professor a melhorar continuamente seus cursos.

---

# Critérios de Aceitação

- O professor deve criar atividades de múltipla escolha, verdadeiro/falso, discursivas, projetos, uploads e checklists.
- O sistema deve permitir correção automática e manual.
- Deve existir suporte para rubricas de avaliação e feedback textual, por áudio e vídeo.
- Todas as alterações devem ser salvas automaticamente.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser aplicado apenas em elementos flutuantes.
- A experiência deve ser minimalista, intuitiva e inspirada no Google Classroom, Apple Classroom e Notion.
- A arquitetura deve ser compatível com futuras funcionalidades de IA para correção assistida e detecção de plágio.