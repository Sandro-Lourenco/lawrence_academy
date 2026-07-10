---
id: PAGE-TEACHER-006
name: Upload Video
route: /teacher/upload-video
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
  chunk_upload: true
  resumable: true
  background_upload: true
  auto_convert_hls: true
  thumbnails: true
  subtitles: true
  processing_queue: true
  max_file_size: 20GB
---

# Upload Video

## Objetivo

A página **Upload Video** é responsável pelo envio, processamento e publicação de vídeos utilizados nas aulas da Lawrence Academy.

Ela deve proporcionar uma experiência extremamente simples para o professor, escondendo toda a complexidade do processamento dos vídeos.

Após selecionar um vídeo, a plataforma será responsável automaticamente por:

- Upload em partes (Chunk Upload)
- Continuação automática em caso de falha
- Armazenamento no Supabase Storage
- Conversão automática para HLS
- Criptografia AES-128
- Geração de Thumbnail
- Extração da duração
- Geração de múltiplas resoluções
- Publicação do vídeo

O professor nunca precisará entender como funciona a infraestrutura.

Inspirado em:

- Vimeo Studio
- YouTube Studio
- Apple TV Connect
- Kajabi
- Loom
- Cloudflare Stream

---

# Objetivos

- Fazer upload de vídeos.
- Acompanhar processamento.
- Gerenciar vídeos.
- Enviar legendas.
- Gerar miniaturas.
- Configurar qualidade.
- Publicar vídeos.

---

# Fluxo

```
Professor

↓

Selecionar vídeo

↓

Upload em partes

↓

Supabase Storage

↓

Fila de processamento

↓

Conversão HLS

↓

Criptografia

↓

Thumbnail

↓

Publicado
```

---

# Layout Desktop

```
---------------------------------------------------------

Glass Header

---------------------------------------------------------

Upload Area

↓

Processing Queue

↓

Video Information

↓

Preview

↓

Publish
```

---

# Layout Mobile

```
Glass Header

↓

Upload

↓

Progress

↓

Processing

↓

Publish
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

Upload Queue

↓

Processing Status

↓

Video Metadata

↓

Thumbnail

↓

Subtitles

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

Blur

20px

Opacity

72%

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
Envie o vídeo da sua aula.

MP4 • MOV • AVI • MKV

Até 20 GB
```

---

# Upload Area

Suporte para

Drag and Drop

Selecionar Arquivo

Múltiplos uploads

Fila automática

---

Formatos

MP4

MOV

AVI

MKV

WEBM

MPEG

---

# Upload Queue

Cada item apresenta

Thumbnail

Nome

Tamanho

Velocidade

Tempo restante

Percentual

Status

---

Exemplo

```
Modelagem Básica.mp4

6.2 GB

68%

2 minutos restantes
```

---

# Estados

Upload

↓

Validando

↓

Enviando

↓

Processando

↓

Convertendo

↓

Gerando Thumbnail

↓

Gerando Qualidades

↓

Publicado

---

# Video Metadata

Extraído automaticamente

Nome

Duração

Resolução

Codec

FPS

Bitrate

Tamanho

Data

---

Campos editáveis

Título

Descrição

Tags

Categoria

Ordem

Professor

---

# Thumbnail

Gerada automaticamente.

Professor pode

Selecionar Frame

Enviar imagem

Recortar

Atualizar

---

# Legendas

Upload

.vtt

.srt

Idiomas

Português

Inglês

Espanhol

---

# Qualidades

Geradas automaticamente

240p

360p

480p

720p

1080p

4K (Future)

---

# Pipeline

```
Upload

↓

Supabase Storage

↓

Queue

↓

FFmpeg

↓

HLS

↓

AES-128

↓

Thumbnail

↓

Poster

↓

Manifest

↓

CDN

↓

Publicado
```

---

# Segurança

Nunca disponibilizar

MP4

MOV

AVI

Arquivos originais

O aluno acessará apenas

Playlist HLS

Arquivos TS criptografados

Token temporário

---

# Publicação

Após processamento

Botões

Visualizar

Associar à Aula

Salvar

Publicar

---

# APIs

POST /teacher/upload/video

GET /teacher/upload/status/{id}

POST /teacher/upload/cancel

POST /teacher/upload/resume

POST /teacher/upload/subtitles

POST /teacher/upload/thumbnail

POST /teacher/video/publish

GET /teacher/video/{id}

---

# Providers

videoUploadProvider

uploadQueueProvider

processingProvider

thumbnailProvider

subtitleProvider

previewProvider

publishProvider

---

# Componentes

GlassHeader

UploadHero

DropZone

UploadQueueCard

UploadProgress

ProcessingCard

MetadataCard

ThumbnailCard

SubtitleCard

VideoPreview

PublishCard

SkeletonLoader

Toast

---

# Estados

## Idle

Mostrar

```
Arraste um vídeo aqui

ou

Clique para selecionar.
```

---

## Upload

Barra de progresso.

Velocidade.

Tempo restante.

---

## Processando

Mostrar animação.

```
Convertendo vídeo...
```

---

## Publicado

Banner verde.

```
Vídeo publicado com sucesso.
```

---

## Falha

Mostrar motivo.

Botões

Tentar novamente

Continuar upload

Cancelar

---

## Offline

Upload pausado.

Retomar automaticamente.

---

# Motion

Fade

Scale

Slide

Blur

Spring

Hero Animation

Progress Animation

Shared Transition

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Dialogs

Floating Buttons

Bottom Actions

Processing Overlay

Nunca aplicar em

Drop Zone

Progress Bar

Cards

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

Fila lateral.

Preview.

Metadados.

---

## Tablet

Fila recolhível.

---

## Mobile

Fila vertical.

Bottom Actions.

Safe Area.

---

# Performance

Chunk Upload

Background Upload

Resumable Upload

Parallel Upload

Queue Processing

FFmpeg Workers

Lazy Loading

Realtime

Skeleton Loading

60 FPS

---

# Analytics

Vídeos enviados

Tempo médio de upload

Tempo de processamento

Falhas

Resoluções geradas

Espaço utilizado

---

# Segurança

Supabase Auth

JWT

HTTPS

Supabase Storage

Row Level Security

Upload Assinado

AES-128

HLS

URLs Temporárias

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

## Simplicidade

O professor deve perceber apenas que está enviando um vídeo. Todo o processamento técnico acontece em segundo plano.

---

## Confiança

O upload nunca deve ser perdido. Em caso de queda de conexão, ele continua automaticamente quando a internet retornar.

---

## Transparência

Sempre mostrar claramente em qual etapa o vídeo se encontra (Upload, Processando, Convertendo ou Publicado).

---

## Rapidez

O processamento deve ocorrer em background, permitindo que o professor continue utilizando a plataforma normalmente.

---

# Critérios de Aceitação

- O sistema deve suportar **upload resumível (Resumable Upload)** e **Chunk Upload**.
- Os vídeos devem ser armazenados no **Supabase Storage**.
- Todo vídeo enviado deve ser convertido automaticamente para **HLS criptografado (AES-128)**.
- O arquivo original nunca deve ser disponibilizado publicamente.
- O sistema deve gerar automaticamente miniaturas, poster, duração, metadados e múltiplas resoluções.
- O professor deve conseguir acompanhar o progresso em tempo real.
- A página deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado apenas em elementos flutuantes.
- A experiência deve ser minimalista, extremamente rápida e inspirada no YouTube Studio, Vimeo e Apple TV Connect.