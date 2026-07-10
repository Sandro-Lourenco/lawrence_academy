---
id: PAGE-ADMIN-007
name: Subscriptions Management
route: /admin/subscriptions
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

subscriptions:
  course_based_subscription: true
  recurring_billing: true
  lifecycle_management: true
  cancellation_tracking: true
  retention_analysis: true
  renewal_control: true
  revenue_tracking: true
  churn_prediction: future
---

# Subscriptions

## Objetivo

A página **Subscriptions Management** é responsável pelo controle completo de todas as assinaturas existentes dentro da Lawrence Academy.

Esta página administra o modelo principal de negócio da plataforma:

**Cada curso possui uma assinatura mensal independente.**

O administrador consegue visualizar, controlar e analisar:

- Assinaturas ativas
- Cancelamentos
- Renovações
- Falhas de pagamento
- Receita recorrente
- Retenção
- Histórico do aluno
- Crescimento financeiro

---

# Regra de Negócio Principal

Um aluno pode comprar vários cursos.

Cada curso gera uma assinatura própria.

Exemplo:

```text
Aluno: Maria

Assinaturas:

Curso:
Modelagem Profissional

Preço:
R$59,90/mês

Status:
Ativo


Curso:
Alta Costura Premium

Preço:
R$89,90/mês

Status:
Ativo


Total pago mensalmente:

R$149,80
```

Não existe assinatura global liberando todos os cursos.

---

# Inspiração

- Netflix Billing
- Stripe Subscriptions
- Apple Subscriptions
- Patreon
- Kajabi
- Hotmart Club

---

# Objetivos

- Gerenciar assinaturas.
- Monitorar recorrência.
- Controlar pagamentos.
- Identificar cancelamentos.
- Acompanhar crescimento.
- Reduzir churn.
- Resolver problemas.
- Gerar relatórios.

---

# Fluxo

```text
Aluno

↓

Escolhe Curso

↓

Assina Curso

↓

Pagamento Recorrente

↓

Acesso Liberado

↓

Renovação Mensal

↓

Continuidade ou Cancelamento
```

---

# Layout Desktop

```text
------------------------------------------------

Glass Header

------------------------------------------------

Sidebar

|

Subscription Metrics

|

Subscriptions Table

|

Subscription Details

------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Resumo

↓

Assinaturas

↓

Detalhes

↓

Bottom Navigation
```

---

# Estrutura

```text
Glass Header

↓

Subscription Overview

↓

MRR Analytics

↓

Filters

↓

Subscriptions List

↓

Subscription Detail

↓

Payments

↓

Lifecycle

↓

Retention
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur 20px

Opacity 72%

---

# Subscription Overview

Cards principais.

Mostrar:

- Assinaturas totais
- Assinaturas ativas
- Novas assinaturas
- Cancelamentos
- Receita mensal
- Taxa de retenção

---

Exemplo:

```text
18.430 assinaturas

MRR

R$960.500

Churn

3.2%
```

---

# MRR Analytics

Monitorar:

Monthly Recurring Revenue

Annual Recurring Revenue

Crescimento mensal

Novos clientes

Cancelamentos

Expansão

Contração

---

Fórmula:

```text
MRR = soma de todas assinaturas ativas dos cursos
```

---

# Subscription Table

Campos:

ID

Aluno

Curso

Professor

Valor

Criada em

Próxima cobrança

Status

---

Exemplo:

```text
Ana Costa

Curso:
Costura Avançada

Professor:
Ariane

R$79,90/mês

Ativa
```

---

# Subscription Status

## Active

Aluno possui acesso.

---

## Trial

Período gratuito.

---

## Payment Failed

Pagamento recusado.

Sistema mantém acesso temporário conforme regra.

---

## Past Due

Pagamento atrasado.

---

## Canceled

Cancelada pelo aluno.

---

## Expired

Finalizada.

---

# Subscription Detail

Mostrar:

Aluno

Curso

Professor

Valor

Data início

Renovação

Gateway

Status

---

# Lifecycle Timeline

Linha do tempo.

Eventos:

Criada

Pagamento aprovado

Renovada

Pagamento falhou

Cancelada

Reativada

---

Exemplo:

```text
10 Janeiro

Assinatura criada


10 Fevereiro

Renovação realizada


15 Março

Cancelamento solicitado
```

---

# Course Access Control

Controle automático.

Regras:

Pagamento aprovado

↓

Libera curso


Cancelamento

↓

Mantém até fim do período pago


Expiração

↓

Remove acesso

---

# Renewal System

Mostrar próximas cobranças.

Campos:

Aluno

Curso

Valor

Data

Status

---

# Failed Payments

Controle:

Cartão recusado

Sem saldo

Erro gateway

Expirado

---

Ações:

Tentar novamente

Enviar aviso

Atualizar pagamento

Cancelar

---

# Cancellation Management

Registrar:

Quem cancelou

Data

Motivo

Curso

Tempo de assinatura

---

Motivos:

Preço

Falta tempo

Não gostou

Terminou curso

Outro

---

# Retention

Métricas:

Retenção mensal

Churn

Tempo médio assinatura

Lifetime Value

---

# Churn Prediction (Future AI)

Exemplo:

```text
Risco alto:

Aluno sem acessar há 25 dias.

Probabilidade cancelamento:

82%
```

---

# Subscription Actions

Admin pode:

Pausar

Reativar

Cancelar

Alterar preço

Aplicar desconto

Estender acesso

---

Todas ações geram Audit Log.

---

# Search

Buscar por:

Aluno

Curso

Professor

Email

Status

Pagamento

---

# Filters

Filtros:

Ativas

Canceladas

Falhas

Trial

Curso

Professor

Valor

Período

---

# Export

Formatos:

PDF

CSV

XLSX

---

# APIs

GET /admin/subscriptions

GET /admin/subscriptions/{id}

PATCH /admin/subscriptions/{id}

POST /admin/subscriptions/{id}/cancel

POST /admin/subscriptions/{id}/pause

POST /admin/subscriptions/{id}/resume

GET /admin/subscriptions/analytics

GET /admin/subscriptions/churn

GET /admin/subscriptions/export

---

# Providers

subscriptionsProvider

subscriptionDetailProvider

subscriptionAnalyticsProvider

renewalProvider

failedPaymentProvider

churnProvider

retentionProvider

---

# Componentes

GlassHeader

SubscriptionMetricCard

MRRChart

SubscriptionTable

SubscriptionDetailPanel

LifecycleTimeline

PaymentStatusCard

RetentionChart

CancelReasonCard

ExportDialog

ConfirmDialog

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style

---

## Active

Badge verde.

---

## Payment Failed

Badge vermelho.

---

## Trial

Badge azul.

---

## Canceled

Badge cinza.

---

# Motion

Fade

Slide

Scale

Spring

Chart Animation

Counter Animation

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em:

- Glass Header
- Floating Filters
- Dialogs
- Date Picker
- Action Menu

Nunca aplicar em:

- Valores financeiros
- Tabelas
- Relatórios
- Métricas

---

# Responsividade

## Desktop

Tabela completa.

Detalhes lateral.

Gráficos.

---

## Tablet

Cards adaptativos.

---

## Mobile

Lista de assinaturas.

Detalhes fullscreen.

Bottom Navigation.

---

# Performance

Realtime

Pagination

Virtual Scroll

Cache

Background Refresh

Lazy Loading

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

Gateway Validation

Webhook Validation

Audit Logs

Encryption

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Touch Target 44px

Focus Visible

Alto contraste

---

# Psicologia de Produto

## Clareza Financeira

O administrador deve entender imediatamente a saúde das assinaturas.

---

## Prevenção

Identificar problemas antes do cancelamento.

---

## Transparência

Toda assinatura possui histórico completo.

---

## Controle

Nenhuma alteração acontece sem rastreamento.

---

# Critérios de Aceitação

- Cada curso deve possuir sua própria assinatura mensal independente.
- Um aluno pode possuir múltiplas assinaturas simultâneas.
- O sistema deve controlar ciclo completo da assinatura.
- Deve monitorar MRR, churn e retenção.
- Deve gerenciar falhas de pagamento.
- Cancelamento não remove acesso antes do fim do período pago.
- Todas ações administrativas precisam gerar Audit Log.
- Deve integrar gateways como Stripe/Mercado Pago.
- Deve usar Supabase Auth + RLS + RBAC.
- Interface segue Lawrence Design System.
- Liquid Glass somente em elementos flutuantes.
- Experiência inspirada em Stripe Subscriptions e Apple Services.