---
id: PAGE-ADMIN-006
name: Payments Management
route: /admin/payments
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

payments:
  subscriptions: true
  course_based_billing: true
  transactions: true
  refunds: true
  invoices: true
  payouts: true
  gateway_integration: true
  audit: true
---

# Payments

## Objetivo

A página **Payments Management** é o centro financeiro da Lawrence Academy.

Ela permite ao administrador acompanhar toda movimentação financeira da plataforma:

- Assinaturas mensais dos cursos
- Pagamentos dos alunos
- Receita dos professores
- Repasses
- Reembolsos
- Falhas de cobrança
- Notas/Faturas
- Auditoria financeira

O modelo financeiro da plataforma segue a regra:

**Cada curso possui sua própria assinatura mensal independente.**

Um aluno pode assinar vários cursos ao mesmo tempo.

Exemplo:

```text
Aluno Maria

Curso Modelagem Feminina
R$59,90/mês

Curso Alta Costura
R$89,90/mês

Total mensal:
R$149,80
```

---

# Inspiração

- Stripe Dashboard
- Apple App Store Connect
- Shopify Payments
- Paddle
- Hotmart
- Netflix Billing

---

# Objetivos

- Monitorar receita.
- Controlar assinaturas.
- Gerenciar transações.
- Resolver falhas.
- Processar reembolsos.
- Controlar repasses.
- Emitir relatórios financeiros.

---

# Fluxo

```text
Aluno compra curso

↓

Pagamento Gateway

↓

Confirmação

↓

Libera Curso

↓

Registra Receita

↓

Calcula Comissão

↓

Repassa Professor
```

---

# Layout Desktop

```text
------------------------------------------------

Glass Header

------------------------------------------------

Sidebar

|

Financial Overview

|

Transactions

|

Subscription Details

|

Revenue Analytics

------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Resumo Financeiro

↓

Transações

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

Financial Overview

↓

Revenue Metrics

↓

Transactions

↓

Subscriptions

↓

Invoices

↓

Refunds

↓

Teacher Payouts

↓

Reports

↓

Audit Logs
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur 20px

Opacity 72%

---

# Financial Overview

Cards principais.

Mostrar:

- Receita mensal (MRR)
- Receita anual (ARR)
- Pagamentos hoje
- Assinaturas ativas
- Cancelamentos
- Reembolsos

---

Exemplo:

```text
MRR

R$850.400

+14%

comparado mês anterior
```

---

# Revenue Metrics

Indicadores:

MRR

ARR

Ticket médio

Churn

Lifetime Value

Receita líquida

Taxas gateway

Lucro estimado

---

# Transactions

Tabela de pagamentos.

Campos:

ID

Aluno

Curso

Professor

Valor

Método

Status

Data

---

Exemplo:

```text
Maria Silva

Alta Costura

R$89,90

Cartão

Pago
```

---

# Payment Status

## Paid

Pagamento aprovado.

---

## Pending

Aguardando confirmação.

---

## Failed

Falha.

Motivos:

Cartão recusado

Saldo insuficiente

Erro gateway

---

## Refunded

Valor devolvido.

---

## Disputed

Contestação aberta.

---

# Subscription Management

Gerenciar assinaturas por curso.

Cada registro possui:

Aluno

Curso

Professor

Valor mensal

Próxima cobrança

Status

---

Exemplo:

```text
Assinatura

Curso:
Modelagem Feminina

Aluno:
Ana

Valor:
R$59,90/mês

Renova:
10/08/2026
```

---

# Subscription Status

Active

Trial

Canceled

Expired

Payment Failed

Paused

---

# Course Revenue

Ranking financeiro.

Mostrar:

Curso

Professor

Assinantes

MRR

Churn

---

Tabela:

```text
Alta Costura

820 alunos

R$73.718/mês
```

---

# Teacher Revenue

Mostrar:

Professor

Receita gerada

Comissão

Valor disponível

Valor pago

---

# Commission System

Configuração:

Exemplo:

```text
Venda

R$100


Professor

70%


Plataforma

30%
```

---

# Payouts

Repasses professores.

Campos:

Professor

Valor

Período

Status

Data

---

Estados:

Processando

Pago

Falhou

Cancelado

---

# Refunds

Gerenciar:

Solicitações

Aprovação

Motivo

Valor

Histórico

---

Fluxo:

```text
Solicitado

↓

Análise

↓

Aprovado

↓

Reembolsado
```

---

# Invoices

Controle:

Número

Cliente

Valor

Curso

Data

Status

Download

---

# Payment Gateway

Integrações:

Stripe

Mercado Pago

Pagar.me

Google Pay

Apple Pay

---

Guardar:

Transaction ID

Gateway Response

Logs

---

# Fraud Detection

Monitorar:

Pagamentos suspeitos

Muitos reembolsos

Chargeback

Múltiplas tentativas

---

# Search

Buscar:

Aluno

Professor

Curso

Transação

Email

Valor

---

# Filters

Filtros:

Período

Status

Gateway

Curso

Professor

Valor

---

# Export

Exportar:

PDF

CSV

XLSX

---

# Audit Logs

Registrar:

Pagamento alterado

Reembolso

Cancelamento

Mudança manual

---

Campos:

Admin

Ação

Data

IP

Antes

Depois

---

# APIs

GET /admin/payments

GET /admin/payments/{id}

GET /admin/subscriptions

PATCH /admin/subscriptions/{id}

GET /admin/revenue

GET /admin/refunds

POST /admin/refunds/{id}/approve

GET /admin/payouts

POST /admin/payouts/process

GET /admin/invoices

GET /admin/payments/audit

---

# Providers

paymentsProvider

transactionProvider

subscriptionProvider

revenueProvider

refundProvider

payoutProvider

invoiceProvider

auditProvider

---

# Componentes

GlassHeader

FinancialOverviewCard

RevenueChart

TransactionTable

SubscriptionCard

PaymentDetailPanel

RefundManager

PayoutCard

InvoiceTable

AuditTimeline

ExportDialog

Toast

SkeletonLoader

---

# Estados

## Loading

Skeleton Apple Style

---

## Pagamento aprovado

Badge verde.

---

## Pagamento pendente

Badge amarelo.

---

## Pagamento recusado

Badge vermelho.

---

## Processando

Progress Indicator.

---

## Erro

Toast

Tentar novamente

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
- Filter Panel
- Export Dialog
- Confirmation Dialog
- Floating Actions

Nunca aplicar em:

- Valores financeiros
- Tabelas
- Gráficos
- Relatórios

---

# Responsividade

## Desktop

Dashboard financeiro completo.

Tabela avançada.

Painel lateral.

---

## Tablet

Cards adaptativos.

---

## Mobile

Cards financeiros.

Lista de transações.

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

2FA obrigatório

Audit Logs

Criptografia

PCI Compliance

Webhook Validation

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

## Confiança

Dados financeiros precisam parecer claros e seguros.

---

## Transparência

Toda movimentação deve possuir origem e histórico.

---

## Controle

Nenhuma alteração financeira ocorre sem registro.

---

## Velocidade

O administrador deve encontrar qualquer pagamento em segundos.

---

# Critérios de Aceitação

- Administrador deve visualizar toda movimentação financeira.
- O sistema deve trabalhar com assinatura mensal independente por curso.
- Deve controlar pagamentos, reembolsos e repasses.
- Deve calcular receita de professores e plataforma.
- Deve possuir histórico financeiro completo.
- Todas ações financeiras precisam gerar Audit Log.
- Deve integrar gateways como Stripe/Mercado Pago.
- Deve seguir Lawrence Design System.
- Liquid Glass apenas em elementos flutuantes.
- Experiência inspirada no Stripe Dashboard e Apple App Store Connect.