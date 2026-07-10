---
id: PAGE-STUDENT-019
name: Calendar
route: /dashboard/calendar
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

calendar:
  sync:
    - Google Calendar
    - Apple Calendar (Future)
    - Outlook Calendar (Future)
  reminders: true
---

# Calendar

## Objetivo

A página **Calendar** centraliza toda a agenda acadêmica do aluno.

Ela reúne em um único lugar todas as atividades importantes da plataforma, incluindo aulas ao vivo, prazos de atividades, datas de renovação das assinaturas, liberações de novos módulos, eventos especiais, mentorias, webinars e lembretes personalizados.

O calendário deve reduzir esquecimentos e aumentar o engajamento do aluno através de uma experiência visual limpa, organizada e elegante.

Inspirado em:

- Apple Calendar
- Google Calendar
- Notion Calendar
- Linear Timeline
- Apple Reminders

---

# Objetivos

- Visualizar agenda.
- Acompanhar eventos.
- Receber lembretes.
- Visualizar atividades.
- Organizar rotina.
- Sincronizar calendários.
- Criar lembretes pessoais.

---

# Fluxo

```
Aluno

↓

Calendar

↓

Seleciona Data

↓

Visualiza Eventos

↓

Abre Evento

↓

Entrar na Aula
ou
Abrir Atividade
```

---

# Layout Desktop

```
---------------------------------------------------------------

Glass Header

---------------------------------------------------------------

Sidebar

|

Mini Calendar

|

Calendar View

|

Agenda do Dia

|

Upcoming Events

---------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Mini Calendar

↓

Agenda

↓

Eventos

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Calendar Hero

↓

Mini Calendar

↓

Agenda View

↓

Today's Events

↓

Upcoming Events

↓

Deadlines

↓

Live Classes

↓

Reminders

↓

Sync Calendar
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

# Calendar Hero

Mostrar

Data atual

Dia da semana

Mensagem personalizada

---

Exemplo

```
Bom dia, Sandro.

Hoje é terça-feira.

Você possui 3 atividades programadas.
```

---

# Mini Calendar

Calendário mensal.

Mostrar

Dias

Eventos

Indicadores

Hoje

Selecionado

---

Cada dia pode possuir

• Live

• Atividade

• Aula

• Renovação

• Mentoria

---

# Agenda View

Alternar

Dia

Semana

Mês

Agenda

---

Desktop

Visualização completa.

---

Mobile

Agenda vertical.

---

# Today's Events

Lista dos eventos do dia.

Cada evento mostra

Horário

Categoria

Curso

Título

Professor

Status

---

Exemplo

```
09:00

Live

Modelagem Feminina

Ajustes de Molde

Professor Ariane
```

---

# Upcoming Events

Mostrar

Próximos 7 dias.

Cada card apresenta

Curso

Evento

Data

Hora

Botão

Abrir

---

# Deadlines

Mostrar

Atividades

Projetos

Questionários

Avaliações

Renovações

---

Cada item exibe

Data

Dias restantes

Prioridade

---

# Live Classes

Eventos ao vivo.

Mostrar

Título

Professor

Início

Fim

Status

Botão

Entrar Agora

---

Status

Agendada

Ao Vivo

Finalizada

---

# Reminders

Lembretes automáticos.

Exemplos

```
Sua atividade vence amanhã.

```

```
Sua assinatura será renovada em 3 dias.

```

```
Nova aula liberada.
```

---

# Personal Reminders

O aluno pode criar lembretes próprios.

Campos

Título

Descrição

Data

Hora

Categoria

Cor

---

# Calendar Sync

Permitir sincronização com

Google Calendar

Apple Calendar (Future)

Outlook Calendar (Future)

---

Botões

Sincronizar

Desconectar

Atualizar

---

# Event Detail

Ao abrir um evento.

Mostrar

Título

Curso

Professor

Descrição

Data

Hora

Local

Categoria

Status

Materiais

Participantes (quando aplicável)

---

Botões

Entrar

Adicionar lembrete

Compartilhar

Abrir Curso

---

# Categorias

Aulas

Lives

Mentorias

Atividades

Avaliações

Projetos

Renovações

Certificados

Eventos

Lembretes

---

# APIs

GET /calendar

GET /calendar/events

GET /calendar/today

GET /calendar/upcoming

GET /calendar/reminders

POST /calendar/reminders

PATCH /calendar/reminders/{id}

DELETE /calendar/reminders/{id}

GET /calendar/live-events

POST /calendar/sync/google

DELETE /calendar/sync/google

---

# Providers

calendarProvider

todayEventsProvider

upcomingEventsProvider

liveEventsProvider

remindersProvider

calendarSyncProvider

selectedDateProvider

---

# Componentes

GlassHeader

CalendarHero

MiniCalendar

AgendaView

EventCard

DeadlineCard

ReminderCard

LiveEventCard

CalendarSyncCard

EventDetailModal

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Sem eventos

Mostrar

```
Nenhum evento programado para esta data.
```

---

## Evento ao vivo

Badge verde pulsante.

Botão

Entrar Agora.

---

## Evento futuro

Mostrar contagem regressiva.

---

## Evento concluído

Badge cinza.

---

## Offline

Exibir calendário local.

Sincronizar posteriormente.

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

Blur

Hero Animation

Shared Transition

Skeleton

Countdown Animation

---

# Liquid Glass

Aplicar apenas em

Glass Header

Bottom Navigation

Floating Action Button

Dialogs

Event Detail Modal

Floating Filter

Nunca aplicar em

Calendário

Cards principais

Texto

Grade mensal

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

Calendário completo.

Agenda lateral.

Eventos detalhados.

---

## Tablet

Visualização híbrida.

---

## Mobile

Agenda vertical.

Cards empilhados.

Bottom Navigation.

Safe Area.

---

# Performance

Lazy Loading

Realtime

Optimistic Update

Cache

Background Refresh

Skeleton Loading

60 FPS

---

# Analytics

Eventos acessados

Lives assistidas

Atividades entregues

Lembretes criados

Taxa de participação

Dias ativos

Sincronizações

---

# Segurança

Supabase Auth

JWT

HTTPS

Row Level Security

Ownership Guard

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

Descrição para leitores de tela

---

# Psicologia de Produto

## Organização

O calendário deve transmitir sensação de controle e previsibilidade.

---

## Antecipação

Sempre mostrar ao aluno os próximos compromissos relevantes.

---

## Redução de Ansiedade

Eventos vencidos não devem ocupar destaque.

O foco da interface deve estar no presente e nos próximos passos.

---

## Engajamento

Utilizar lembretes inteligentes para incentivar a continuidade dos estudos, sem excesso de notificações.

---

# Critérios de Aceitação

- O calendário deve consolidar todos os eventos acadêmicos do aluno em uma única interface.
- Deve permitir visualizar aulas, lives, atividades, avaliações, mentorias, vencimentos e renovações de assinaturas.
- O aluno deve poder criar lembretes pessoais e sincronizar sua agenda com provedores externos.
- A página deve suportar visualizações por dia, semana, mês e agenda.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado exclusivamente em elementos flutuantes.
- A experiência deve ser minimalista, organizada e inspirada nos aplicativos Apple Calendar e Notion Calendar.