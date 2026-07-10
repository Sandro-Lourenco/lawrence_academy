---
id: PAGE-TEACHER-005
name: Lessons
route: /teacher/courses/:courseId/modules/:moduleId/lessons
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

lessons:
  drag_and_drop: true
  autosave: true
  preview: true
  scheduling: true
  offline: false
  versioning: true
---

# Lessons

## Objetivo

A página **Lessons** é responsável pelo gerenciamento completo das aulas pertencentes a um módulo.

Aqui o professor cria, organiza e edita todas as aulas do curso, incluindo vídeos, materiais complementares, legendas, atividades, tempo estimado, requisitos e configurações de acesso.

Cada aula representa a menor unidade de aprendizado da plataforma.

A experiência deve ser extremamente intuitiva, permitindo criar uma aula completa em poucos minutos, mantendo o padrão minimalista inspirado no ecossistema Apple.

Inspirado em:

- Apple TV
- MasterClass
- Kajabi
- Thinkific
- Notion
- Linear

---

# Objetivos

- Criar aulas.
- Editar aulas.
- Organizar aulas.
- Fazer upload de vídeos.
- Adicionar materiais.
- Configurar acesso.
- Criar prévias gratuitas.
- Publicar rapidamente.

---

# Fluxo

```
Professor

↓

Seleciona Módulo

↓

Nova Aula

↓

Preenche informações

↓

Upload do vídeo

↓

Adicionar materiais

↓

Salvar

↓

Publicar
```

---

# Layout Desktop

```
--------------------------------------------------------------

Glass Header

--------------------------------------------------------------

Sidebar

|

Lesson List

|

Lesson Editor

|

Preview

--------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Lista de Aulas

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

Module Summary

↓

Lesson List

↓

Lesson Editor

↓

Video Upload

↓

Materials

↓

Access Settings

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

# Module Summary

Mostrar

Curso

Módulo

Quantidade de aulas

Carga horária

Professor

Status

---

# Lesson List

Lista lateral.

Cada item mostra

Thumbnail

Título

Duração

Status

Preview

Ordem

---

Ações

Editar

Duplicar

Mover

Excluir

---

Drag & Drop

Reordenar aulas.

Atualização imediata.

---

# Lesson Editor

## Informações Básicas

Campos

Título

Slug

Descrição

Resumo

Objetivos

Tempo estimado

Ordem

Professor

---

# Vídeo Principal

Upload

↓

Supabase Storage

↓

Conversão HLS

↓

AES-128

↓

Disponível

---

Mostrar

Thumbnail

Progresso

Tempo

Qualidade

Status

---

Nunca armazenar MP4 público.

---

# Legendas

Permitir upload

.vtt

.srt

Idiomas

Português

Inglês

Espanhol

---

# Materiais Complementares

Tipos

PDF

ZIP

Imagem

Molde

Planilha

Áudio

Links externos

Arquivos adicionais

---

# Configuração de Acesso

Permitir Preview Gratuito

Sim

Não

---

Disponibilidade

Imediata

Agendada

Após conclusão da aula anterior

Após pagamento

---

Downloads

Permitir

Bloquear

---

# Conteúdo da Aula

Editor Rich Text

Markdown

Imagens

Links

Código

Listas

Checklist

---

# Atividades Vinculadas

Adicionar

Questionário

Projeto

Exercício

Upload

Redação

Checklist

---

# Pré-visualização

Visualização idêntica à tela do aluno.

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

Oculto

↓

Arquivado

---

Botões

Salvar

Duplicar

Visualizar

Publicar

---

# APIs

GET /teacher/lessons

GET /teacher/lessons/{id}

POST /teacher/lessons

PATCH /teacher/lessons/{id}

DELETE /teacher/lessons/{id}

POST /teacher/lessons/reorder

POST /teacher/lessons/upload

POST /teacher/lessons/publish

POST /teacher/lessons/duplicate

---

# Providers

lessonProvider

lessonEditorProvider

lessonUploadProvider

lessonPreviewProvider

lessonMaterialProvider

lessonAccessProvider

autosaveProvider

---

# Componentes

GlassHeader

ModuleSummary

LessonList

LessonCard

LessonEditor

VideoUploadCard

UploadProgress

MaterialsCard

AccessSettingsCard

LessonPreview

BottomActions

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Sem aulas

Mostrar

```
Este módulo ainda não possui aulas.

Crie a primeira aula para começar.
```

Botão

Nova Aula

---

## Upload

Progress Bar

Percentual

Velocidade

Tempo restante

---

## Processando

```
Convertendo vídeo...
```

---

## Publicado

```
Aula publicada com sucesso.
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

Blur

Hero Animation

Shared Transition

Progress Animation

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Bottom Actions

Dialogs

Floating Buttons

Upload Overlay

Nunca aplicar em

Editor

Cards

Lista

Texto

Vídeo

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

Lista lateral fixa.

Editor central.

Preview à direita.

---

## Tablet

Preview recolhível.

---

## Mobile

Lista vertical.

Editor em tela cheia.

Bottom Sheet para ações.

Safe Area.

---

# Performance

Lazy Loading

Chunk Upload

Realtime

Autosave

Optimistic Update

Skeleton Loading

60 FPS

---

# Analytics

Quantidade de aulas

Tempo total

Vídeos enviados

Materiais adicionados

Prévias gratuitas

Tempo médio de edição

Publicações

---

# Segurança

Supabase Auth

JWT

HTTPS

Supabase Storage

HLS AES-128

Zero MP4 Público

Row Level Security

Teacher Guard

Versionamento

Logs de Auditoria

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

Legendas

Alto contraste

---

# Psicologia de Produto

## Clareza

O professor deve conseguir compreender toda a estrutura da aula imediatamente.

---

## Simplicidade

Adicionar uma nova aula deve exigir o menor número possível de etapas.

---

## Segurança

O autosave elimina o risco de perda de conteúdo durante a edição.

---

## Confiança

A pré-visualização deve representar exatamente a experiência do aluno.

---

# Critérios de Aceitação

- O professor deve criar, editar, duplicar, mover e excluir aulas.
- Deve existir suporte para upload de vídeos com conversão automática para **HLS criptografado (AES-128)**.
- Cada aula deve aceitar materiais complementares, legendas, atividades e configurações de acesso.
- Deve ser possível definir aulas gratuitas como prévia do curso.
- Todas as alterações devem ser salvas automaticamente.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado apenas em elementos flutuantes.
- A experiência deve ser minimalista, rápida e inspirada no Apple TV, MasterClass, Kajabi e Notion.