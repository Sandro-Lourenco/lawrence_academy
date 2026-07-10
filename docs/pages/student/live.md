---
id: PAGE-STUDENT-020
name: Live Classes
route: /dashboard/live
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
real-time: Supabase Realtime

streaming:
  protocol: HLS
  drm: AES-128
  latency: Low Latency HLS
  chat: true
  reactions: true
  questions: true
---

# Live Classes

## Objetivo

A página **Live Classes** reúne todas as aulas ao vivo, workshops, mentorias, webinars e eventos exclusivos da Lawrence Academy.

Ela permite que o aluno descubra eventos futuros, participe de transmissões ao vivo, interaja com professores e acompanhe gravações disponibilizadas após o encerramento.

A experiência deve transmitir a sensação de estar em uma sala de aula premium, organizada e livre de distrações, utilizando o minimalismo inspirado na Apple e o Lawrence Design System.

Inspirado em:

- Apple Events
- MasterClass Live
- Coursera Live Sessions
- Zoom Events
- YouTube Live
- Notion Calendar

---

# Objetivos

- Visualizar lives.
- Participar de eventos.
- Assistir mentorias.
- Fazer perguntas.
- Interagir no chat.
- Receber lembretes.
- Assistir gravações.

---

# Fluxo

```
Aluno

↓

Live Classes

↓

Seleciona Evento

↓

Visualiza detalhes

↓

Entrar na Live

↓

Participar

↓

Live Finalizada

↓

Assistir Gravação
```

---

# Layout Desktop

```
------------------------------------------------------------

Glass Header

------------------------------------------------------------

Sidebar

|

Live Hero

|

Próximas Lives

|

Live em Destaque

|

Calendário

|

Histórico

------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Live Hero

↓

Live Atual

↓

Próximas Lives

↓

Histórico

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Live Hero

↓

Featured Live

↓

Upcoming Lives

↓

Today's Schedule

↓

Live Calendar

↓

Past Lives

↓

Notifications

↓

FAQ
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

# Live Hero

Mostrar

Título

Próxima Live

Professor

Data

Horário

Countdown

CTA

```
Entrar na Aula
```

---

# Featured Live

Card principal.

Mostrar

Thumbnail

Professor

Categoria

Tempo restante

Participantes

Status

---

Botão

Entrar Agora

---

# Upcoming Lives

Lista das próximas transmissões.

Cada item apresenta

Imagem

Curso

Professor

Data

Hora

Duração

Status

Botão

Detalhes

---

# Status

Agendada

↓

Em Breve

↓

Ao Vivo

↓

Encerrada

↓

Gravação Disponível

---

Cada status possui cor própria.

Verde

Ao Vivo

Azul

Agendada

Cinza

Encerrada

Dourado

Replay Disponível

---

# Today's Schedule

Mostrar

Agenda completa do dia.

Cada evento

Horário

Curso

Professor

Categoria

---

# Live Calendar

Calendário simplificado.

Mostrar

Dias com transmissões.

Filtros

Todos

Mentorias

Workshops

Lives

Masterclass

Eventos

---

# Live Player

Ao entrar na transmissão.

Interface

Modo Escuro

Fundo Preto

Player 16:9

Controles em Liquid Glass

---

Componentes

Player

Chat

Perguntas

Materiais

Participantes

Reações

---

# Chat

Permitir

Enviar mensagens

Responder professor

Curtir mensagens

Fixar mensagens do professor

---

# Perguntas

Aluno pode

Enviar pergunta

Curtir perguntas

Professor marca como respondida

---

# Reações

Disponíveis

👏

❤️

🔥

🎉

👍

---

# Materiais

Durante a live

Disponibilizar

PDF

Molde

Imagem

Checklist

Links

Downloads

---

# Past Lives

Lista de gravações.

Cada card

Thumbnail

Curso

Professor

Data

Duração

Botão

Assistir Replay

---

# Notifications

Lembretes automáticos.

Exemplo

```
Sua live começa em 30 minutos.
```

```
A gravação já está disponível.
```

---

# APIs

GET /live

GET /live/upcoming

GET /live/today

GET /live/{id}

GET /live/replay

POST /live/{id}/join

POST /live/chat

POST /live/question

POST /live/reaction

GET /live/materials

POST /live/reminder

---

# Providers

liveProvider

featuredLiveProvider

todayLiveProvider

replayProvider

chatProvider

questionProvider

materialProvider

---

# Componentes

GlassHeader

LiveHero

FeaturedLiveCard

UpcomingLiveCard

LiveCalendar

LivePlayer

ChatPanel

QuestionsPanel

MaterialsPanel

ReplayCard

ReminderCard

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Nenhuma live

Mostrar

```
Nenhuma transmissão agendada.
```

CTA

Explorar Cursos

---

## Live em andamento

Badge verde pulsante.

Countdown ocultado.

Botão

Entrar Agora

---

## Replay disponível

Badge dourada.

Botão

Assistir

---

## Offline

Permitir apenas visualizar agenda.

---

## Erro

Toast.

Botão

Tentar novamente.

---

# Motion

Fade

Slide

Scale

Spring

Hero Animation

Blur

Shared Transition

Skeleton

Countdown Animation

---

# Liquid Glass

Aplicar apenas em

Glass Header

Player Controls

Bottom Navigation

Floating Chat Button

Dialogs

Floating Reminder Button

Nunca aplicar em

Player

Chat

Lista

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

Player central.

Chat lateral.

Calendário lateral.

---

## Tablet

Chat recolhível.

---

## Mobile

Player no topo.

Chat em Bottom Sheet.

Bottom Navigation.

Safe Area.

---

# Performance

Low Latency HLS

Adaptive Streaming

Lazy Loading

Realtime

Cache

Background Refresh

Skeleton Loading

60 FPS

---

# Analytics

Lives assistidas

Tempo assistido

Mensagens enviadas

Perguntas realizadas

Replays assistidos

Participação

Taxa de presença

---

# Segurança

Supabase Auth

JWT

HTTPS

HLS AES-128

Zero MP4 Público

Row Level Security

Ownership Guard

Proteção contra compartilhamento de links

Logs de Auditoria

---

# Acessibilidade

WCAG AA

Closed Captions (.vtt)

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

## Exclusividade

Eventos ao vivo devem transmitir a sensação de acesso privilegiado.

---

## Engajamento

Countdown discreto aumenta a expectativa sem causar ansiedade.

---

## Participação

Destacar perguntas respondidas pelo professor para incentivar interação.

---

## Continuidade

Após o encerramento da live, direcionar naturalmente o aluno para o replay e para o próximo evento.

---

# Critérios de Aceitação

- O aluno deve visualizar todas as transmissões futuras, em andamento e gravadas.
- O player deve utilizar exclusivamente **HLS criptografado (AES-128)**, sem exposição de arquivos MP4.
- Deve existir suporte para chat em tempo real, perguntas, reações e materiais complementares.
- O sistema deve enviar lembretes automáticos antes do início das transmissões.
- Após o encerramento, a gravação deve ser disponibilizada automaticamente para os alunos autorizados.
- A página deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado exclusivamente em elementos flutuantes.
- A experiência deve transmitir elegância, foco no conteúdo e sensação de evento premium.