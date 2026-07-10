---
id: PAGE-TEACHER-004
name: Course Modules
route: /teacher/courses/:courseId/modules
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

modules:
  drag_and_drop: true
  nested_structure: true
  autosave: true
  versioning: true
---

# Modules

## Objetivo

A página **Modules** é responsável pelo gerenciamento completo da estrutura pedagógica de um curso.

Aqui o professor organiza toda a jornada de aprendizagem através de módulos, aulas, atividades, avaliações e materiais complementares.

A experiência deve ser extremamente simples, utilizando uma estrutura hierárquica semelhante ao Notion, permitindo reorganização por Drag & Drop, edição inline e salvamento automático.

Inspirado em:

- Notion
- Apple Reminders
- Apple Notes
- Kajabi
- Thinkific
- Linear

---

# Objetivos

- Criar módulos.
- Editar módulos.
- Reordenar módulos.
- Organizar aulas.
- Gerenciar atividades.
- Controlar materiais.
- Visualizar estrutura completa.

---

# Fluxo

```
Professor

↓

Abrir Curso

↓

Módulos

↓

Adicionar

↓

Organizar

↓

Salvar Automaticamente
```

---

# Layout Desktop

```
------------------------------------------------------------

Glass Header

------------------------------------------------------------

Sidebar

|

Course Header

|

Module Tree

|

Properties Panel

------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Course Header

↓

Module List

↓

Bottom Actions
```

---

# Estrutura

```
Glass Header

↓

Course Summary

↓

Module Tree

↓

Lesson List

↓

Activities

↓

Materials

↓

Properties Panel

↓

Preview

↓

Publish Changes
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur 20px

Opacity 72%

---

# Course Summary

Mostrar

Imagem

Título

Categoria

Quantidade de módulos

Quantidade de aulas

Carga horária

Status

---

# Module Tree

Estrutura hierárquica.

```
Curso

├── Módulo 1

│     ├── Aula 1

│     ├── Aula 2

│     └── Atividade

│

├── Módulo 2

│     ├── Aula

│     ├── PDF

│     └── Quiz

│

└── Módulo 3
```

---

# Operações

Adicionar módulo

Adicionar aula

Adicionar atividade

Adicionar material

Duplicar

Mover

Excluir

Ocultar

Expandir

Recolher

---

# Drag & Drop

Permitir mover

Módulos

↓

Aulas

↓

Atividades

↓

Materiais

Atualização imediata.

Autosave.

---

# Module Card

Cada módulo apresenta

Título

Descrição

Quantidade de aulas

Tempo estimado

Status

Professor

Última edição

---

Ações

Editar

Duplicar

Arquivar

Excluir

---

# Lesson Card

Mostrar

Título

Thumbnail

Duração

Preview Gratuito

Vídeo

Downloads

Legenda

Status

---

# Activities

Cada módulo pode possuir

Questionário

Exercício

Projeto

Upload

Redação

Checklist

---

Mostrar

Prazo

Pontuação

Status

---

# Materials

Tipos suportados

PDF

ZIP

Imagem

Molde

Áudio

Links

Arquivos adicionais

---

# Properties Panel

Painel lateral.

Campos

Título

Descrição

Cor

Ícone

Ordem

Pré-requisitos

Tempo estimado

Disponibilidade

---

# Disponibilidade

Imediata

Agendada

Liberar após conclusão

Bloqueada

---

# Preview

Visualização exatamente igual ao aluno.

Desktop

Tablet

Mobile

---

# Publicação

Alterações

↓

Validação

↓

Nova versão

↓

Atualização automática

---

# APIs

GET /teacher/courses/{courseId}/modules

POST /teacher/modules

PATCH /teacher/modules/{id}

DELETE /teacher/modules/{id}

POST /teacher/modules/reorder

POST /teacher/modules/duplicate

GET /teacher/modules/{id}

POST /teacher/lessons

PATCH /teacher/lessons/{id}

DELETE /teacher/lessons/{id}

---

# Providers

modulesProvider

moduleTreeProvider

lessonProvider

activitiesProvider

materialsProvider

previewProvider

autosaveProvider

---

# Componentes

GlassHeader

CourseSummaryCard

ModuleTreeView

ModuleCard

LessonCard

ActivityCard

MaterialCard

PropertiesPanel

PreviewCard

BottomActions

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Sem módulos

Mostrar

```
Este curso ainda não possui módulos.

Comece criando o primeiro módulo.
```

Botão

Criar Módulo

---

## Autosave

```
Alterações salvas automaticamente.
```

---

## Publicado

```
Estrutura atualizada com sucesso.
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

Drag Animation

Expand Animation

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Bottom Actions

Dialogs

Floating Buttons

Properties Panel (desktop)

Nunca aplicar em

Module Tree

Cards

Texto

Editor

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

Árvore de módulos à esquerda.

Painel de propriedades à direita.

Preview opcional.

---

## Tablet

Painel recolhível.

---

## Mobile

Lista vertical.

Bottom Sheet para propriedades.

Bottom Navigation.

Safe Area.

---

# Performance

Lazy Loading

Realtime

Optimistic Update

Autosave

Virtual Scrolling

Skeleton Loading

60 FPS

---

# Analytics

Quantidade de módulos

Quantidade de aulas

Carga horária total

Tempo médio por módulo

Materiais enviados

Atividades criadas

Alterações realizadas

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

Drag & Drop acessível

TalkBack

VoiceOver

Touch Target

44x44px

Focus Visible

Escala dinâmica

Alto contraste

---

# Psicologia de Produto

## Organização

Toda a estrutura do curso deve ser compreendida em poucos segundos através da árvore hierárquica.

---

## Simplicidade

O professor deve conseguir reorganizar módulos apenas arrastando os elementos.

---

## Controle

O painel lateral permite editar qualquer propriedade sem abrir novas páginas.

---

## Segurança

O autosave garante que nenhuma alteração seja perdida durante a edição.

---

# Critérios de Aceitação

- O professor deve visualizar toda a estrutura do curso em uma árvore hierárquica.
- Deve ser possível criar, editar, duplicar, mover e excluir módulos, aulas, atividades e materiais.
- A reorganização deve ocorrer por **Drag & Drop**, com atualização automática da ordem.
- Todas as alterações devem ser salvas automaticamente.
- A pré-visualização deve refletir exatamente a experiência do aluno.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado apenas em elementos flutuantes.
- A experiência deve ser minimalista, rápida e inspirada no Notion, Apple Notes e Linear.