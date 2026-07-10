---
id: PAGE-TEACHER-003
name: Edit Course
route: /teacher/courses/:courseId/edit
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

editing:
  autosave: true
  versioning: true
  draft: true
  rollback: true
  collaborative: future
---

# Edit Course

## Objetivo

A página **Edit Course** permite ao professor atualizar continuamente um curso já publicado ou em rascunho.

Diferente da criação inicial, esta tela é focada em **edições rápidas**, preservando a experiência dos alunos já matriculados e permitindo que novas versões sejam publicadas com segurança.

Toda alteração deve ser salva automaticamente, possuir histórico de versões e possibilitar restaurar versões anteriores.

Inspirado em:

- Notion
- Linear
- Figma
- Apple Pages
- Kajabi
- Teachable

---

# Objetivos

- Editar informações do curso.
- Atualizar módulos.
- Adicionar aulas.
- Editar vídeos.
- Atualizar materiais.
- Alterar preço da assinatura.
- Publicar alterações.
- Restaurar versões.

---

# Fluxo

```
Professor

↓

Abrir Curso

↓

Editar

↓

Autosave

↓

Revisar

↓

Publicar Alterações

↓

Nova Versão
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

Editor

|

Preview

------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Resumo do Curso

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

Course Header

↓

Status Card

↓

Quick Actions

↓

Basic Information

↓

Course Structure

↓

Lessons

↓

Media

↓

Pricing

↓

Settings

↓

SEO

↓

Version History

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

Blur

20px

Opacity

72%

---

# Course Header

Mostrar

Imagem

Título

Categoria

Professor

Status

Última atualização

Versão atual

---

Exemplo

```
Modelagem Feminina

Publicado

Versão 1.4

Atualizado há 2 dias
```

---

# Status Card

Estados

Rascunho

Publicado

Em Revisão

Arquivado

Pré-venda

---

Mostrar

Data da publicação

Última edição

Quantidade de alunos

Avaliação média

---

# Quick Actions

Botões

Salvar

Duplicar Curso

Visualizar

Histórico

Arquivar

Excluir

---

# Informações Básicas

Campos

Título

Slug

Categoria

Subcategoria

Nível

Professor

Idioma

Imagem da Capa

Banner

Descrição Curta

Descrição Completa

---

# Estrutura do Curso

Visualização em árvore.

```
Curso

↓

Módulo

↓

Lição

↓

Atividade

↓

Material
```

---

Operações

Adicionar

Editar

Duplicar

Mover

Excluir

Drag and Drop

---

# Aulas

Cada aula possui

Título

Descrição

Vídeo

Legenda

Tempo

Prévia gratuita

Downloads

Status

---

# Upload de Vídeos

Fluxo

```
Upload

↓

Supabase Storage

↓

Conversão HLS

↓

AES-128

↓

Disponível
```

Mostrar

Progresso

Processamento

Erro

---

# Materiais

Permitir

PDF

ZIP

Imagem

Molde

Áudio

Links

---

# Assinatura

Modelo único da plataforma.

Curso vendido por assinatura mensal.

Campos

Preço mensal

Moeda

Promoção

Cupom

Data inicial

Data final

---

Exemplo

```
R$59,90/mês
```

---

# Configurações

Emitir certificado

Permitir comentários

Ativar fórum

Downloads

Atividades

Curso privado

Curso público

Pré-venda

---

# SEO

Título

Descrição

Keywords

Imagem Open Graph

Slug

---

# Histórico de Versões

Lista cronológica.

Mostrar

Versão

Autor

Data

Descrição

Status

---

Ações

Visualizar

Comparar

Restaurar

---

# Preview

Mostrar exatamente a página que o aluno verá.

Desktop

Tablet

Mobile

---

# Publicar Alterações

Fluxo

```
Editar

↓

Validar

↓

Publicar

↓

Atualizar alunos
```

Após publicação

Enviar notificação

Atualizar catálogo

Registrar versão

---

# APIs

GET /teacher/courses/{id}

PATCH /teacher/courses/{id}

POST /teacher/courses/{id}/publish

POST /teacher/courses/{id}/draft

POST /teacher/courses/{id}/duplicate

POST /teacher/courses/{id}/archive

GET /teacher/courses/{id}/versions

POST /teacher/courses/{id}/restore-version

POST /teacher/upload

---

# Providers

courseProvider

courseEditProvider

courseVersionProvider

moduleProvider

lessonProvider

uploadProvider

pricingProvider

settingsProvider

previewProvider

---

# Componentes

GlassHeader

CourseHeader

StatusCard

QuickActionsBar

CourseForm

ModuleTree

LessonCard

UploadZone

PricingCard

SettingsCard

SeoCard

VersionHistory

PreviewCard

PublishDialog

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Autosave

Mensagem discreta

```
Alterações salvas automaticamente.
```

---

## Publicando

Progress Indicator

---

## Publicado

Banner verde

```
Curso atualizado com sucesso.
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

Blur

Spring

Hero Animation

Shared Transition

Progress Animation

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Dialogs

Bottom Actions

Floating Preview

Floating Save

Quick Actions

Nunca aplicar em

Editor

Inputs

Cards principais

Árvore de módulos

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

Editor em duas colunas.

Preview fixa.

Sidebar fixa.

---

## Tablet

Preview recolhível.

---

## Mobile

Editor em coluna única.

Bottom Actions.

Safe Area.

---

# Performance

Autosave

Lazy Loading

Realtime

Optimistic Update

Chunk Upload

Background Upload

Skeleton Loading

60 FPS

---

# Analytics

Cursos editados

Tempo de edição

Versões publicadas

Uploads realizados

Alterações por módulo

Taxa de atualização

---

# Segurança

Supabase Auth

JWT

HTTPS

Supabase Storage

Row Level Security

Teacher Guard

Versionamento

Rollback

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

## Segurança

Nenhuma alteração deve ser perdida graças ao autosave.

---

## Controle

O professor sempre pode visualizar e restaurar versões anteriores.

---

## Clareza

As alterações devem ser organizadas em seções independentes, evitando formulários longos.

---

## Confiança

A pré-visualização deve mostrar exatamente como o aluno verá o curso após a publicação.

---

# Critérios de Aceitação

- O professor deve editar qualquer informação do curso sem interromper o acesso dos alunos.
- Todas as alterações devem ser salvas automaticamente.
- Deve existir histórico completo de versões com possibilidade de restauração.
- Os vídeos devem continuar utilizando Supabase Storage com conversão automática para HLS criptografado (AES-128).
- O modelo comercial deve manter **assinatura mensal individual por curso**.
- A pré-visualização deve refletir fielmente a experiência do aluno.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado apenas em elementos flutuantes.
- A experiência deve ser rápida, minimalista e inspirada no Apple Pages, Notion e Linear.