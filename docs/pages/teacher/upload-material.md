---
id: PAGE-TEACHER-007
name: Upload Material
route: /teacher/upload-material
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
navigation: Modal + Fullscreen
state-management: Riverpod
architecture: Clean Architecture + DDD
real-time: Supabase Realtime

upload:
  multiple_files: true
  drag_and_drop: true
  resumable: true
  background_upload: true
  versioning: true
  antivirus_scan: true
  max_file_size: 2GB
---

# Upload Material

## Objetivo

A página **Upload Material** é responsável pelo gerenciamento de todos os materiais complementares disponibilizados aos alunos.

Além de permitir o envio de arquivos, ela organiza automaticamente os materiais por tipo, realiza verificação de segurança, gera miniaturas quando possível e integra os arquivos às aulas e módulos do curso.

O objetivo é oferecer uma experiência extremamente simples para o professor, semelhante ao Finder do macOS e ao Google Drive, mantendo o padrão visual do Lawrence Design System.

Inspirado em:

- Apple Files
- Finder (macOS)
- Google Drive
- Dropbox
- Notion
- Kajabi

---

# Objetivos

- Fazer upload de materiais.
- Organizar arquivos.
- Vincular materiais às aulas.
- Atualizar versões.
- Gerenciar downloads.
- Compartilhar arquivos.
- Controlar permissões.

---

# Fluxo

```
Professor

↓

Selecionar Arquivos

↓

Upload

↓

Supabase Storage

↓

Verificação

↓

Processamento

↓

Organização

↓

Associar à Aula

↓

Publicado
```

---

# Layout Desktop

```
------------------------------------------------------------

Glass Header

------------------------------------------------------------

Upload Area

↓

Recent Files

↓

Processing Queue

↓

File Details

↓

Preview

------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Upload

↓

Arquivos

↓

Fila

↓

Bottom Actions
```

---

# Estrutura

```
Glass Header

↓

Upload Hero

↓

Drop Zone

↓

Quick Upload

↓

Upload Queue

↓

Recent Files

↓

Preview

↓

File Details

↓

Permissions

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

# Upload Hero

Mostrar

Título

Descrição

Formatos suportados

Tamanho máximo

---

Exemplo

```
Envie materiais complementares.

PDF • ZIP • Imagens • Áudios • Planilhas

Até 2 GB por arquivo
```

---

# Drop Zone

Permitir

Drag & Drop

Selecionar Arquivo

Selecionar Pasta (Future)

Múltiplos arquivos

Upload em lote

---

# Formatos Suportados

## Documentos

PDF

DOCX

PPTX

XLSX

TXT

CSV

ODT

RTF

---

## Imagens

PNG

JPG

JPEG

SVG

WEBP

GIF

---

## Arquivos Compactados

ZIP

RAR

7Z

---

## Áudios

MP3

WAV

AAC

M4A

OGG

---

## Outros

STL

DXF

AI

PSD

JSON

---

# Upload Queue

Cada item mostra

Ícone

Nome

Tipo

Tamanho

Velocidade

Tempo restante

Percentual

Status

---

Estados

Validando

↓

Upload

↓

Escaneando

↓

Processando

↓

Publicado

---

# Processamento

Executado automaticamente

Antivírus

Extração de metadados

Thumbnail

Compressão (imagens)

Indexação

Versionamento

---

# File Details

Campos

Nome

Descrição

Categoria

Curso

Módulo

Aula

Tags

Autor

Idioma

Versão

---

# Categorias

Material Complementar

Molde

Exercício

Planilha

Projeto

PDF

Imagem

Checklist

Guia

Manual

E-book

Arquivo da Aula

---

# Preview

Disponível para

PDF

Imagens

Áudios

Vídeos

Documentos

---

# Permissões

Disponível para

Todos os alunos

Somente assinantes

Somente professores

Somente administradores

---

Downloads

Permitido

Bloqueado

---

# Versionamento

Cada atualização cria uma nova versão.

Mostrar

Versão

Autor

Data

Alterações

---

Botões

Visualizar

Restaurar

Baixar

---

# Organização

Cada material pode ser associado a

Curso

↓

Módulo

↓

Aula

↓

Atividade

---

# Busca

Pesquisar por

Nome

Categoria

Curso

Professor

Tag

Tipo

---

# APIs

POST /teacher/materials/upload

GET /teacher/materials

GET /teacher/materials/{id}

PATCH /teacher/materials/{id}

DELETE /teacher/materials/{id}

POST /teacher/materials/version

POST /teacher/materials/link

GET /teacher/materials/search

---

# Providers

materialUploadProvider

materialProvider

uploadQueueProvider

previewProvider

permissionProvider

versionProvider

searchProvider

---

# Componentes

GlassHeader

UploadHero

DropZone

UploadQueueCard

FileCard

FilePreview

FileDetailsCard

PermissionCard

VersionHistoryCard

SearchBar

BottomActions

SkeletonLoader

Toast

---

# Estados

## Idle

Mostrar

```
Arraste arquivos aqui

ou

Clique para selecionar.
```

---

## Upload

Barra de progresso.

Tempo restante.

Velocidade.

---

## Processando

```
Processando arquivo...
```

---

## Publicado

Banner verde

```
Arquivo enviado com sucesso.
```

---

## Arquivo duplicado

Mostrar

```
Este arquivo já existe.

Deseja substituir ou criar uma nova versão?
```

Botões

Substituir

Nova Versão

Cancelar

---

## Erro

Toast

Botão

Tentar novamente

---

## Offline

Fila pausada.

Retomar automaticamente quando houver conexão.

---

# Motion

Fade

Scale

Slide

Blur

Spring

Shared Transition

Progress Animation

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Dialogs

Bottom Actions

Floating Upload Button

Floating Search

Nunca aplicar em

Lista de arquivos

Cards

Texto

Drop Zone

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

Upload à esquerda.

Preview e detalhes à direita.

Pesquisa fixa.

---

## Tablet

Painéis recolhíveis.

---

## Mobile

Lista vertical.

Bottom Sheet para detalhes.

Bottom Actions.

Safe Area.

---

# Performance

Chunk Upload

Background Upload

Resumable Upload

Lazy Loading

Realtime

Cache

Versionamento

Skeleton Loading

60 FPS

---

# Analytics

Arquivos enviados

Espaço utilizado

Downloads

Materiais mais acessados

Tipos de arquivos

Tempo médio de upload

---

# Segurança

Supabase Auth

JWT

HTTPS

Supabase Storage

Row Level Security

Upload Assinado

Antivírus

Versionamento

Criptografia

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

Alto contraste

---

# Psicologia de Produto

## Organização

Os materiais devem ser encontrados rapidamente através de categorias e busca inteligente.

---

## Segurança

Todo upload deve transmitir confiança ao professor, exibindo claramente o progresso e a confirmação de envio.

---

## Continuidade

A criação automática de versões evita perda de materiais antigos e permite recuperação rápida.

---

## Simplicidade

A experiência deve ser semelhante a arrastar arquivos para uma pasta do computador, escondendo toda a complexidade do armazenamento em nuvem.

---

# Critérios de Aceitação

- O sistema deve permitir upload de múltiplos arquivos simultaneamente com suporte a **Chunk Upload** e **Resumable Upload**.
- Todos os materiais devem ser armazenados no **Supabase Storage**.
- Deve existir verificação automática de segurança (antivírus), geração de miniaturas e extração de metadados quando aplicável.
- O professor deve conseguir organizar materiais por curso, módulo, aula e atividade.
- O sistema deve suportar histórico de versões e restauração de arquivos.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado apenas em elementos flutuantes.
- A experiência deve ser minimalista, rápida e inspirada no Finder, Apple Files e Google Drive.