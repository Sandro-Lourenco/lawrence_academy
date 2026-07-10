---
id: PAGE-TEACHER-001
name: Teacher Dashboard
route: /teacher/dashboard
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

teacher:
  analytics: true
  live_monitoring: true
  submissions: true
  earnings: true
  notifications: true
---

# Teacher Dashboard

## Objetivo

O **Teacher Dashboard** é o centro de comando do professor dentro da Lawrence Academy.

Toda a experiência foi projetada para que o professor consiga administrar seus cursos, acompanhar alunos, corrigir atividades, organizar aulas ao vivo, publicar conteúdos e analisar métricas sem precisar navegar por diversas telas.

O dashboard deve transmitir sensação de organização, produtividade e controle, inspirado nas interfaces do **Linear**, **Notion**, **Apple Business Manager** e **Stripe Dashboard**, mantendo o visual minimalista do Lawrence Design System.

---

# Objetivos

- Visualizar métricas dos cursos.
- Acompanhar alunos.
- Corrigir atividades.
- Gerenciar aulas.
- Criar novos conteúdos.
- Organizar lives.
- Monitorar receita.
- Visualizar notificações.

---

# Fluxo

```
Professor

↓

Dashboard

↓

Seleciona módulo

↓

Executa ação

↓

Atualização em tempo real
```

---

# Layout Desktop

```
----------------------------------------------------------------

Glass Header

----------------------------------------------------------------

Sidebar

|

Welcome

|

Analytics

|

Quick Actions

|

Pending Reviews

|

Upcoming Lives

|

Recent Students

|

Revenue

----------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Resumo

↓

Analytics

↓

Pendências

↓

Lives

↓

Alunos

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Welcome Hero

↓

Analytics Cards

↓

Quick Actions

↓

Pending Activities

↓

Upcoming Live Classes

↓

Recent Students

↓

Recent Sales

↓

Revenue Overview

↓

Notifications

↓

Calendar

↓

Announcements
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

Exibe

Logo

Pesquisa

Notificações

Perfil

---

# Welcome Hero

Mostrar

Nome do professor

Foto

Mensagem personalizada

Quantidade de cursos publicados

Quantidade de alunos

---

Exemplo

```
Bom dia, Ariane.

Você possui

8 cursos publicados

1.248 alunos

3 atividades aguardando correção.
```

---

# Analytics Cards

Grid responsivo.

Cards

Alunos ativos

Cursos publicados

Novas matrículas

Receita do mês

Avaliação média

Taxa de conclusão

Lives agendadas

Atividades pendentes

---

# Quick Actions

Botões rápidos

Criar Curso

Nova Aula

Nova Atividade

Criar Live

Enviar Aviso

Gerenciar Materiais

Ver Analytics

---

# Pending Activities

Lista das atividades aguardando correção.

Cada item

Aluno

Curso

Atividade

Data

Botão

Corrigir

---

# Upcoming Live Classes

Mostrar

Título

Curso

Data

Hora

Participantes

Status

Botão

Entrar

Editar

---

# Recent Students

Lista dos últimos alunos.

Cada card

Foto

Nome

Curso

Última atividade

Progresso

---

# Revenue Overview

Mostrar

Receita mensal

Receita anual

Assinaturas ativas

Cursos vendidos

Ticket médio

Gráfico

---

# Recent Sales

Lista

Aluno

Curso

Plano

Valor

Data

Status

---

# Notifications

Exibir

Novas matrículas

Perguntas

Comentários

Mensagens

Avaliações

Problemas técnicos

---

# Calendar

Agenda do professor.

Mostrar

Lives

Correções

Publicações

Eventos

Mentorias

---

# Announcements

Últimos avisos enviados aos alunos.

Botão

Criar novo aviso

---

# APIs

GET /teacher/dashboard

GET /teacher/analytics

GET /teacher/courses

GET /teacher/students

GET /teacher/revenue

GET /teacher/sales

GET /teacher/activities/pending

GET /teacher/live

GET /teacher/calendar

GET /teacher/notifications

---

# Providers

teacherDashboardProvider

teacherAnalyticsProvider

teacherStudentsProvider

teacherRevenueProvider

teacherSalesProvider

teacherLiveProvider

teacherCalendarProvider

teacherNotificationProvider

---

# Componentes

GlassHeader

TeacherHero

AnalyticsCard

RevenueChart

QuickActionCard

PendingActivityCard

StudentCard

LiveCard

NotificationCard

CalendarCard

AnnouncementCard

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
Nenhuma atividade aguardando correção.
```

---

## Sem lives

Mostrar

```
Nenhuma live agendada.
```

Botão

Criar Live

---

## Sem alunos

Mostrar

```
Você ainda não possui alunos inscritos.
```

---

## Offline

Mostrar dados em cache.

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

Shared Transition

Blur

Skeleton

Counter Animation

---

# Liquid Glass

Aplicar apenas em

Glass Header

Floating Search

Dialogs

Bottom Navigation

Floating Quick Actions

Notification Panel

Nunca aplicar em

Cards principais

Analytics

Gráficos

Tabelas

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

Layout assimétrico.

Analytics em grid.

Sidebar fixa.

Gráficos completos.

---

## Tablet

Grid reduzido.

Sidebar recolhível.

---

## Mobile

Cards empilhados.

Bottom Navigation.

Safe Area.

Quick Actions horizontais.

---

# Performance

Realtime

Cache

Lazy Loading

Optimistic Update

Background Refresh

Skeleton Loading

60 FPS

---

# Analytics

Total de alunos

Receita

Cursos ativos

Novas matrículas

Taxa de conclusão

Avaliação média

Horas assistidas

Lives realizadas

---

# Segurança

Supabase Auth

JWT

HTTPS

Row Level Security

Role Guard

Teacher Guard

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

## Clareza

As informações mais importantes devem aparecer imediatamente após o login.

---

## Produtividade

As ações mais frequentes devem estar acessíveis em um único clique.

---

## Motivação

Mostrar métricas positivas como crescimento de alunos, avaliações e conclusão de cursos para incentivar a produção contínua.

---

## Organização

Agrupar informações por contexto (Cursos, Alunos, Financeiro, Lives e Correções), reduzindo a carga cognitiva.

---

# Critérios de Aceitação

- O dashboard deve fornecer uma visão geral completa da atividade do professor.
- Todas as métricas devem ser atualizadas em tempo real através do Supabase Realtime.
- O professor deve acessar rapidamente as principais ações da plataforma sem navegar por múltiplas páginas.
- Deve exibir indicadores de cursos, alunos, receita, avaliações, lives e atividades pendentes.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado exclusivamente em elementos flutuantes.
- A experiência deve ser minimalista, extremamente organizada e inspirada nos dashboards da Apple, Stripe, Linear e Notion.