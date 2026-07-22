---
id: PAGE-STUDENT-003
name: Course Player
route: /dashboard/courses/:courseId/lessons/:lessonId
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
navigation: Sidebar + Bottom Navigation
state-management: Riverpod
architecture: Clean Architecture + DDD
security:
  drm: true
  hls: true
  encrypted-storage: true
  offline-mobile-only: true
---

# Course Player

## Implementação canônica da fase do Player

O player atual possui estados de inicialização, reprodução, pausa, buffering,
conclusão, offline, acesso negado, sessão expirada e erro recuperável. Falhas
técnicas são convertidas em mensagens seguras, sem incluir URLs assinados ou
detalhes internos.

Os controles implementados são reprodução/pausa, scrubbing, tempo e recomeço.
Controles ainda não funcionais, como tela cheia, qualidade, velocidade, legenda
e picture-in-picture, não são apresentados nesta fase.

## Objetivo

O **Course Player** é o principal ambiente de aprendizagem da Lawrence Academy.

Toda a experiência deve ser construída para que o aluno permaneça totalmente focado no conteúdo.

A interface deve desaparecer.

Nada pode competir visualmente com o vídeo.

Inspirado em:

- Apple TV
- Apple Fitness+
- MasterClass
- Coursera
- Udemy (Player)
- Apple Developer

A navegação deve ser extremamente rápida.

O aluno nunca deve se perder.

---

# Objetivos

- Maximizar retenção.
- Facilitar o consumo das aulas.
- Minimizar distrações.
- Registrar progresso automaticamente.
- Disponibilizar materiais.
- Permitir anotações.
- Permitir assistir offline (Android).
- Garantir máxima segurança dos vídeos.

---

# Layout Desktop

```
-------------------------------------------------------------

Glass Header

-------------------------------------------------------------

Sidebar Curso

|

|

Player

|

Conteúdo Aula

-------------------------------------------------------------

Materiais

↓

Comentários

↓

Próxima Aula

-------------------------------------------------------------
```

Desktop

Sidebar fixa

Player ocupa aproximadamente 70% da tela.

---

# Layout Mobile

```
Player

↓

Título

↓

Professor

↓

Progress

↓

Tabs

Aula

Materiais

Comentários

Anotações

↓

Bottom Navigation
```

Player sempre no topo.

---

# Estrutura

```
Glass Header

↓

Breadcrumb

↓

Secure Video Player

↓

Lesson Header

↓

Progress

↓

Tabs

↓

Lesson Content

↓

Attachments

↓

Teacher Notes

↓

Comments

↓

Next Lesson

```

---

# Glass Header

Sticky

72px

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

# Breadcrumb

Cursos

>

Curso

>

Módulo

>

Aula

---

# Secure Video Player

Elemento principal.

---

Aspect Ratio

16:9

---

Desktop

Máximo

1600px

---

Mobile

100%

---

Background

#000000

---

Border Radius

Desktop

24px

---

Fullscreen

0px

---

# Controles

Play

Pause

Volume

Velocidade

Qualidade

Legenda

Picture-in-Picture

Fullscreen

Próxima Aula

Aula Anterior

---

Todos os controles

Liquid Glass

---

Blur

20px

---

Auto Hide

3 segundos

---

# Segurança

Streaming

HLS

DRM

AES-128

---

Nunca expor

MP4

URLs reais

Storage

Bucket

---

Tokens temporários

Assinados

---

Validação

JWT

Supabase

---

Android

Download criptografado.

Sandbox.

Nunca salvar MP4.

---

# Registro de Progresso

Atualização automática.

A cada

15 segundos

ou

5%

de progresso.

---

Concluir aula

Ao atingir

90%

assistido.

---

Marcar como concluída

Manual

Também disponível.

---

# Lesson Header

Título

Professor

Categoria

Tempo

Última atualização

---

Badge

Novo

Atualizado

Ao Vivo

---

# Progress

Linear Progress

Azul

---

Exemplo

72%

---

Texto

Você concluiu

18 de 25 aulas.

---

# Tabs

Aula

Materiais

Comentários

Anotações

Downloads (Android)

---

# Aula

Mostrar

Descrição

Resumo

Objetivos

Aprendizados

---

# Materiais

Lista

PDF

ZIP

Imagem

Molde

Arquivo

Checklist

---

Botões

Visualizar

Baixar

---

Android

Salvar Offline

---

# Comentários

Comentários do professor.

---

Aluno

Pode comentar.

---

Professor

Pode responder.

---

Curtir comentários.

---

Ordenação

Mais recentes

Mais relevantes

---

# Anotações

Editor rico.

Markdown.

Auto Save.

---

Cada anotação

Timestamp

Ex.:

12:35

↓

Ao clicar

Volta exatamente ao vídeo.

---

Pesquisa

Dentro das anotações.

---

# Downloads

(Android)

Mostrar

Espaço ocupado

Download

Excluir

Atualizar

---

Web

Mensagem

Disponível apenas no aplicativo.

---

# Próxima Aula

Card grande.

---

Imagem

Título

Tempo

Professor

Botão

Continuar

---

# Sidebar Curso

Desktop

Lista completa

Módulos

↓

Aulas

---

Cada aula

Ícone

Título

Tempo

Status

---

Status

Concluído

Atual

Bloqueado

Novo

---

Expandir módulos.

---

# Pesquisa

Pesquisar aula.

Pesquisar módulo.

---

# APIs

GET /courses/{id}

GET /lessons/{id}

GET /attachments

GET /comments

POST /comments

GET /notes

POST /notes

PATCH /progress

POST /lesson/complete

GET /downloads

---

# Providers

playerProvider

lessonProvider

progressProvider

attachmentsProvider

notesProvider

commentsProvider

downloadProvider

courseSidebarProvider

---

# Componentes

GlassHeader

VideoPlayer

ProgressBar

LessonSidebar

LessonTabs

AttachmentCard

CommentCard

NoteEditor

DownloadCard

NextLessonCard

SkeletonLoader

---

# Motion

Fade

Scale

Blur

Hero Animation

Spring

Shared Transition

Auto Hide Controls

Mini Player Animation

---

# Liquid Glass

Aplicar apenas em

Header

Player Controls

Floating Buttons

Bottom Navigation

Picture in Picture Controls

Volume Controls

Speed Menu

Quality Menu

Nunca aplicar em

Vídeo

Texto

Descrição

Materiais

Lista de aulas

Comentários

---

# Tipografia

Título

32px

Bold

---

Heading

24px

Semibold

---

Body

17px

Regular

---

Caption

13px

Regular

---

# Cores

60%

White

30%

Primary Blue

10%

Premium Gold

---

Player

Black

#000000

---

# Responsividade

## Desktop

Sidebar fixa

Player centralizado

Tabs laterais

---

## Tablet

Sidebar recolhível

---

## Mobile

Player ocupa largura total

Tabs horizontais

Bottom Navigation

Gestos

Safe Area

---

# Performance

Adaptive Streaming

Pré-carregar próxima aula

Lazy Loading

Cache

Shimmer

GPU Rendering

60 FPS

Thumbnail Cache

---

# Analytics

Tempo assistido

Velocidade

Pausas

Abandono

Conclusão

Materiais baixados

Comentários

Anotações

Tempo por aula

Mapa de calor

---

# Segurança

Supabase Auth

JWT

HTTPS

OWASP Top 10

Role Guard

Ownership Guard

Subscription Guard

DRM

HLS

AES-128

Refresh Token

Screen Recording Detection (Android)

Root Detection

Emulator Detection

Device Binding

Downloads criptografados

Sem exposição de MP4

Links temporários assinados

Validação contínua da assinatura

---

# Acessibilidade

WCAG AA

Keyboard Navigation

Closed Caption (.vtt)

Legendas

TalkBack

VoiceOver

Screen Reader

Picture in Picture

Controle por teclado

Touch Target

44x44px

Alto contraste

Escala dinâmica de fontes

---

# Psicologia de Aprendizagem

## Deep Focus

A interface deve desaparecer para que o aluno concentre sua atenção exclusivamente na aula.

---

## Zeigarnik Effect

Mostrar continuamente o progresso:

"Faltam apenas 2 aulas para concluir este módulo."

---

## Goal Gradient

Exibir metas próximas:

- Próximo certificado
- Próximo módulo
- Próxima conquista

---

## Motivação

Ao concluir uma aula:

✔ Pequena animação.

✔ Check azul.

✔ Som discreto (opcional).

✔ Atualização imediata do progresso.

---

## Aprendizagem Ativa

O aluno deve conseguir:

- Fazer anotações sincronizadas com o vídeo.
- Baixar materiais.
- Comentar.
- Responder dúvidas.
- Retornar a qualquer momento do vídeo através das anotações.

---

# Critérios de Aceitação

- O vídeo deve utilizar exclusivamente streaming HLS protegido por DRM, sem expor arquivos MP4.
- O progresso deve ser salvo automaticamente durante a reprodução e sincronizado com o backend.
- A aula deve ser marcada como concluída ao atingir pelo menos 90% de visualização ou por ação manual do aluno.
- O Android deve permitir download criptografado para visualização offline apenas dentro do aplicativo.
- O Web deve bloquear funcionalidades de download offline.
- O aluno deve acessar materiais, comentários e anotações sem sair da página.
- O layout deve seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve ser aplicado apenas aos elementos flutuantes e controles do player.
- O Player deve manter desempenho de 60 FPS, carregamento rápido e experiência premium em todas as plataformas.
- Toda a navegação deve transmitir foco, fluidez e continuidade, reforçando a identidade sofisticada da Lawrence Academy.
````
