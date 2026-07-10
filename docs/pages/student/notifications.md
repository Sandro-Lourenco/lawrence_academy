---
id: PAGE-STUDENT-011
name: Notifications
route: /dashboard/notifications
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
---

# Notifications

## Objetivo

A página **Notifications** é o centro de comunicação da Lawrence Academy.

Ela reúne todas as notificações importantes da plataforma, permitindo que o aluno acompanhe seu progresso, atividades, pagamentos, lives, novos cursos, mensagens do professor e eventos sem precisar procurar essas informações em diferentes áreas do sistema.

A experiência deve transmitir organização, tranquilidade e prioridade.

O usuário nunca deve sentir que perdeu alguma informação importante.

Inspirada em:

- Apple Notification Center
- Apple Mail
- Apple Calendar
- Notion Inbox
- Slack
- LinkedIn Notifications

---

# Objetivos

- Centralizar todas as notificações.
- Atualizar em tempo real.
- Priorizar informações importantes.
- Facilitar leitura.
- Facilitar ações rápidas.
- Organizar automaticamente.
- Sincronizar entre dispositivos.

---

# Fluxo

```
Sistema

↓

Evento

↓

Supabase Realtime

↓

Notificação

↓

Aluno recebe

↓

Ler

↓

Executar ação

↓

Arquivar
```

---

# Layout Desktop

```
-------------------------------------------------------------

Glass Header

-------------------------------------------------------------

Sidebar

|

Filtros

↓

Lista de Notificações

↓

Painel de Detalhes

-------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Filtros

↓

Lista

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Notification Summary

↓

Search

↓

Category Filters

↓

Notification Timeline

↓

Unread Section

↓

Read Section

↓

Quick Actions

↓

Footer
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

Componentes

Logo

Pesquisar

Notificações

Perfil

---

# Notification Summary

Resumo superior.

Mostrar

Não lidas

Lidas

Hoje

Esta Semana

---

Exemplo

```
18 notificações

5 não lidas

13 lidas
```

---

# Pesquisa

Pesquisar

Curso

Professor

Mensagem

Pagamento

Evento

Pesquisa instantânea.

---

# Category Filters

Categorias

Todos

Cursos

Professor

Atividades

Avaliações

Pagamentos

Lives

Consultorias

Eventos

Sistema

Promoções

Certificados

---

Filtros rápidos

Não lidas

Favoritas

Arquivadas

Urgentes

---

# Notification Timeline

Lista cronológica.

Agrupamento automático.

Hoje

Ontem

Esta Semana

Este Mês

---

Cada Notification Card

Ícone

Título

Mensagem

Data

Hora

Categoria

Prioridade

Status

Botão

Abrir

---

# Tipos

## Curso

Nova aula disponível.

---

## Professor

Novo comentário.

Correção publicada.

Feedback disponível.

---

## Atividade

Nova atividade.

Prazo próximo.

Entrega confirmada.

---

## Pagamento

Pagamento aprovado.

Pagamento recusado.

Renovação.

Assinatura próxima do vencimento.

---

## Eventos

Live iniciando.

Consultoria.

Workshop.

Calendário.

---

## Certificados

Novo certificado.

Curso concluído.

---

## Sistema

Atualizações.

Manutenção.

Segurança.

---

## Marketing

Novos cursos.

Promoções.

Cupons.

Campanhas.

(O usuário pode desativar.)

---

# Prioridade

Alta

Média

Baixa

---

Alta

Borda azul.

Badge.

---

Urgente

Borda dourada.

---

# Notification Card

Mostrar

Ícone

Título

Resumo

Data

Tempo relativo

Categoria

Botão

Abrir

---

Ações rápidas

Marcar como lida

Favoritar

Arquivar

Excluir

---

Swipe Mobile

Esquerda

Arquivar

Direita

Ler

---

# Notification Detail

Desktop

Painel lateral.

Mostrar

Mensagem completa.

Botão de ação.

Links.

Arquivos.

Professor.

Curso.

---

# Quick Actions

Marcar todas como lidas.

Arquivar todas.

Excluir lidas.

Atualizar.

---

# Configurações

Tipos

Receber

Email

Push

In-App

WhatsApp (futuro)

---

Categorias

Professor

Cursos

Lives

Eventos

Marketing

Pagamentos

Sistema

---

Horário silencioso

Configurar.

---

# APIs

GET /notifications

GET /notifications/unread

PATCH /notifications/{id}/read

PATCH /notifications/read-all

DELETE /notifications/{id}

PATCH /notifications/{id}/favorite

PATCH /notifications/{id}/archive

GET /notification-settings

PATCH /notification-settings

Realtime

Supabase Channel

notifications

---

# Providers

notificationsProvider

unreadNotificationsProvider

notificationSearchProvider

notificationFilterProvider

notificationSettingsProvider

realtimeNotificationsProvider

---

# Componentes

GlassHeader

NotificationSummaryCard

SearchBar

CategoryFilterChips

NotificationCard

NotificationTimeline

NotificationDetailPanel

QuickActionsCard

NotificationSettingsCard

SkeletonLoader

EmptyState

---

# Estados

## Loading

Skeleton Apple Style.

---

## Sem notificações

Mostrar ilustração.

Mensagem

```
Tudo em dia.

Você não possui notificações no momento.
```

---

## Offline

Mostrar cache.

Sincronizar quando voltar.

---

## Erro

Botão

Tentar novamente.

---

# Motion

Fade

Slide

Scale

Hero Animation

Shared Transition

Swipe Animation

Spring

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Search

Floating Filters

Bottom Navigation

Floating Action Button

Notification Detail Toolbar

Modal

Nunca aplicar em

Lista

Cards

Texto

Timeline

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

Sucesso

#30D158

Aviso

#FF9F0A

Erro

#FF453A

Texto

#1D1D1F

---

# Responsividade

## Desktop

Lista + painel lateral.

Sidebar fixa.

---

## Tablet

Painel recolhível.

---

## Mobile

Lista única.

Swipe Actions.

Bottom Navigation.

Safe Area.

---

# Performance

Supabase Realtime

Cache Local

Lazy Loading

Infinite Scroll

Image Cache

60 FPS

Sincronização em Background

---

# Analytics

Notificações abertas

Tempo até leitura

Categorias mais acessadas

CTR

Notificações ignoradas

Tempo médio de resposta

Eventos clicados

---

# Segurança

Supabase Auth

JWT

HTTPS

OWASP Top 10

Role Guard

Ownership Guard

Notificações criptografadas

Controle por usuário

Rate Limit

Auditoria

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Screen Reader

Touch Target

44x44px

Focus Visible

Escala dinâmica

---

# Psicologia de Produto

## Calm Technology

As notificações devem informar sem interromper.

Evitar excesso de alertas.

---

## Progressive Disclosure

Mostrar apenas o resumo.

Abrir detalhes somente quando necessário.

---

## Priorização Inteligente

A ordem das notificações deve considerar:

1. Atividades com prazo.
2. Feedback do professor.
3. Pagamentos.
4. Lives.
5. Eventos.
6. Marketing.

---

## Zero Anxiety

Nunca utilizar linguagem alarmista.

Exemplo

❌ Seu pagamento falhou!

✔ Não foi possível concluir seu pagamento. Atualize seus dados para continuar acessando seus cursos.

---

## Continuidade

Cada notificação deve possuir uma ação clara.

Exemplos

- Assistir Aula
- Resolver Atividade
- Ver Feedback
- Atualizar Pagamento
- Entrar na Live
- Baixar Certificado

---

# Critérios de Aceitação

- Todas as notificações devem ser sincronizadas em tempo real utilizando Supabase Realtime.
- O aluno deve conseguir pesquisar, filtrar, favoritar, arquivar e marcar notificações como lidas.
- O sistema deve agrupar notificações automaticamente por período e categoria.
- O layout deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser aplicado exclusivamente aos elementos flutuantes.
- A experiência deve ser minimalista, silenciosa e organizada, inspirada no Notification Center da Apple.
- O sistema deve manter excelente desempenho tanto no Flutter Web quanto no Android.