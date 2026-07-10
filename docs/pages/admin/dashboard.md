---
id: PAGE-ADMIN-001
name: Admin Dashboard
route: /admin/dashboard
layout: AdminDashboardLayout
platforms:
  - Web
  - Android
roles:
  - Admin
authentication: true
responsive: true
status: Production
design-system: Lawrence Design System
navigation: Sidebar + Top Navigation
state-management: Riverpod
architecture: Clean Architecture + DDD
real-time: Supabase Realtime

admin:
  platform_management: true
  analytics: true
  users_management: true
  courses_management: true
  financial_control: true
  moderation: true
  audit_logs: true
---

# Admin Dashboard

## Objetivo

O **Admin Dashboard** é o centro de controle principal da Lawrence Academy.

Ele permite que administradores acompanhem toda a operação da plataforma:

- Crescimento da plataforma
- Professores
- Alunos
- Cursos
- Assinaturas mensais por curso
- Receita
- Pagamentos
- Conteúdo publicado
- Suporte
- Segurança

A tela deve funcionar como um painel executivo, mostrando somente as informações necessárias para tomada rápida de decisão.

Inspirado em:

- Apple Business Manager
- Stripe Dashboard
- Linear Admin
- Vercel Dashboard
- YouTube Studio
- Notion

---

# Objetivos

- Monitorar plataforma.
- Gerenciar usuários.
- Controlar cursos.
- Visualizar receita.
- Acompanhar crescimento.
- Identificar problemas.
- Controlar segurança.
- Tomar decisões.

---

# Fluxo

```text
Admin

↓

Dashboard

↓

Analisa indicadores

↓

Seleciona módulo

↓

Executa ação administrativa
```

---

# Layout Desktop

```text
------------------------------------------------------------

Glass Header

------------------------------------------------------------

Sidebar

|

Platform Overview

|

Revenue

|

Users Growth

|

Courses Status

|

System Health

------------------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Resumo Geral

↓

Indicadores

↓

Alertas

↓

Ações

↓

Bottom Navigation
```

---

# Estrutura

```text
Glass Header

↓

Admin Overview

↓

Financial Metrics

↓

Users Analytics

↓

Courses Overview

↓

Teachers Overview

↓

Subscriptions

↓

Pending Actions

↓

System Status

↓

Audit
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

Contém:

- Search Global
- Notifications
- Admin Profile
- Quick Actions

---

# Admin Overview

Cards principais.

Mostrar:

- Receita mensal
- Usuários totais
- Alunos ativos
- Professores ativos
- Cursos publicados
- Assinaturas ativas

---

Exemplo:

```text
Lawrence Academy

125.000 usuários

R$850.000 MRR

340 cursos ativos
```

---

# Financial Metrics

Como cada curso possui assinatura independente:

Monitorar:

- MRR Total
- ARR
- Receita por curso
- Receita por professor
- Novas assinaturas
- Cancelamentos
- Churn
- Crescimento

---

Exemplo:

```text
Curso:
Alta Costura Premium

820 assinantes

R$89,90/mês

Receita:
R$73.718/mês
```

---

# Users Analytics

Separar:

## Students

Mostrar:

- Total
- Novos
- Ativos
- Inativos
- Retenção
- Certificados

---

## Teachers

Mostrar:

- Professores cadastrados
- Professores ativos
- Cursos publicados
- Receita gerada
- Avaliações

---

# Course Overview

Indicadores:

Cursos publicados

Cursos em revisão

Cursos bloqueados

Mais vendidos

Melhores avaliados

Baixo desempenho

---

# Course Ranking

Tabela:

Curso

Professor

Alunos

Receita

Avaliação

Status

---

# Subscriptions

Controle das assinaturas.

Mostrar:

Ativas

Canceladas

Expiradas

Falhas pagamento

Reembolsos

---

# Pending Actions

Fila administrativa.

Exemplos:

```
12 cursos aguardando aprovação

5 solicitações de professores

8 tickets suporte
```

---

# Moderation

Controle:

Comentários denunciados

Avaliações denunciadas

Conteúdo pendente

Usuários bloqueados

---

# Support Overview

Mostrar:

Tickets abertos

Tempo médio resposta

Problemas críticos

Solicitações

---

# System Health

Monitoramento técnico.

Mostrar:

API Status

Banco Supabase

Storage

Processamento HLS

Fila de vídeos

Erros

---

Estados:

Online

Instável

Offline

---

# Recent Activity

Timeline:

Novo usuário

Novo curso

Nova assinatura

Pagamento

Cancelamento

Alteração administrativa

---

# Audit Logs

Registrar:

Admin

Ação

Data

IP

Objeto alterado

Antes/depois

---

# Quick Actions

Botões:

Adicionar usuário

Aprovar curso

Criar anúncio

Ver pagamentos

Abrir relatórios

Gerenciar suporte

---

# APIs

GET /admin/dashboard

GET /admin/metrics

GET /admin/revenue

GET /admin/users

GET /admin/teachers

GET /admin/courses

GET /admin/subscriptions

GET /admin/moderation

GET /admin/system-health

GET /admin/audit

---

# Providers

adminDashboardProvider

platformMetricsProvider

adminRevenueProvider

adminUsersProvider

adminCoursesProvider

adminTeachersProvider

subscriptionProvider

systemHealthProvider

auditProvider

---

# Componentes

GlassHeader

AdminMetricCard

RevenueChart

UserGrowthChart

CourseRankingTable

TeacherOverviewCard

SubscriptionCard

SystemStatusCard

AuditTimeline

QuickActionCard

NotificationPanel

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style

---

## Plataforma saudável

Mostrar:

```text
Todos os sistemas funcionando.
```

---

## Atenção necessária

Exibir alerta discreto.

---

## Erro crítico

Mostrar prioridade alta.

---

## Sem dados

Empty State.

---

# Motion

Fade

Slide

Scale

Spring

Counter Animation

Chart Animation

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em:

- Glass Header
- Notification Center
- Floating Actions
- Dialogs
- Filters

Nunca aplicar em:

- Métricas
- Tabelas
- Gráficos
- Dados financeiros

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

Text

#1D1D1F

---

# Responsividade

## Desktop

Dashboard executivo.

Grid analítico.

Sidebar fixa.

---

## Tablet

Cards adaptativos.

---

## Mobile

Cards verticais.

Bottom Navigation.

Safe Area.

---

# Performance

Realtime

Caching

Lazy Loading

Pagination

Background Refresh

Aggregation Queries

Skeleton Loading

60 FPS

---

# Segurança

Supabase Auth

JWT

HTTPS

Row Level Security

Admin Guard

RBAC

2FA

Audit Logs

Rate Limit

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

Descrição dos gráficos

Alto contraste

---

# Psicologia de Produto

## Controle

O administrador deve entender a saúde da plataforma em segundos.

---

## Prioridade

Problemas importantes aparecem primeiro.

---

## Simplicidade

Evitar excesso de gráficos.

Mostrar ações necessárias.

---

## Confiança

Métricas financeiras precisam ser claras e auditáveis.

---

# Critérios de Aceitação

- O administrador deve visualizar toda a operação da Lawrence Academy em uma única tela.
- Deve exibir métricas de usuários, professores, cursos, assinaturas e receita.
- O modelo financeiro deve considerar assinatura mensal individual por curso.
- Deve mostrar alertas administrativos e status do sistema.
- Deve possuir auditoria completa das ações.
- Dados críticos devem atualizar em tempo real usando Supabase Realtime.
- A interface deve seguir o Lawrence Design System.
- Liquid Glass deve ser utilizado somente em elementos flutuantes.
- A experiência deve parecer um painel executivo Apple + Stripe + Linear.