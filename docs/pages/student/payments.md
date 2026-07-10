---
id: PAGE-STUDENT-015
name: Payments
route: /dashboard/payments
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

billing:
  model: Course Subscription
  provider:
    - Stripe
  future:
    - Google Play Billing
    - Apple In-App Purchase
---

# Payments

## Objetivo

A página **Payments** concentra todo o histórico financeiro do aluno.

Ela permite acompanhar todos os pagamentos realizados em cada curso, visualizar cobranças futuras, pagamentos pendentes, pagamentos recusados, reembolsos e recibos.

Esta página representa o extrato financeiro completo do aluno dentro da Lawrence Academy.

Inspirada em:

- Stripe Customer Portal
- Apple Payments
- Adobe Billing
- Notion Billing
- Netflix Billing

---

# Objetivos

- Visualizar pagamentos.
- Consultar cobranças.
- Baixar recibos.
- Ver pagamentos futuros.
- Acompanhar pagamentos recusados.
- Solicitar suporte financeiro.
- Exportar histórico.

---

# Fluxo

```
Aluno

↓

Payments

↓

Seleciona pagamento

↓

Visualiza detalhes

↓

Download do recibo

↓

Suporte (opcional)
```

---

# Layout Desktop

```
---------------------------------------------------------------

Glass Header

---------------------------------------------------------------

Sidebar

|

Resumo Financeiro

|

Timeline de Pagamentos

|

Detalhes

---------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Resumo

↓

Pagamentos

↓

Detalhes

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Payment Summary

↓

Upcoming Payments

↓

Payment History

↓

Payment Detail

↓

Receipts

↓

Support
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur 20px

Opacity 72%

---

# Payment Summary

Mostrar

Total investido

Total de pagamentos

Cursos ativos

Próxima cobrança

Último pagamento

---

Exemplo

```
Total Investido

R$ 2.480,00

24 pagamentos

3 cursos ativos

Próxima cobrança

15 Agosto

Último pagamento

15 Julho
```

---

# Upcoming Payments

Lista das próximas cobranças.

Cada item possui

Curso

Valor

Data

Método

Status

---

Exemplo

```
Modelagem Feminina

R$59,90

15 Agosto

Visa Final 4587
```

---

# Payment History

Timeline cronológica.

Cada pagamento mostra

Curso

Valor

Status

Data

Método

Número da cobrança

---

Status

Pago

Pendente

Processando

Recusado

Reembolsado

Cancelado

---

# Payment Card

Mostrar

Imagem do curso

Nome

Valor

Forma de pagamento

Data

Status

Número da transação

---

Exemplo

```
Alta Costura

R$89,90

Visa Final 4587

15 Julho

Pago
```

---

# Payment Detail

Ao abrir um pagamento.

Mostrar

Curso

Plano

Valor

Taxas

Descontos

Subtotal

Método

Data

ID Stripe

Status

---

Botões

Baixar Recibo

Visualizar Fatura

Solicitar Suporte

---

# Receipts

Lista de recibos.

Cada item

Curso

Número

Valor

PDF

Download

---

# Failed Payments

Caso exista pagamento recusado.

Banner discreto.

```
Seu pagamento não foi processado.

Atualize seu cartão para evitar interrupção no acesso ao curso.
```

Botões

Atualizar Cartão

Tentar Novamente

---

# Refund

Caso exista reembolso.

Mostrar

Curso

Valor

Data

Motivo

Status

---

# Support

Botão

Problemas com pagamento

↓

Abre suporte.

---

# APIs

GET /payments

GET /payments/{id}

GET /payments/upcoming

GET /payments/history

GET /payments/receipts

GET /payments/receipt/{id}

GET /payments/refunds

POST /payments/support

---

# Providers

paymentsProvider

paymentDetailProvider

paymentHistoryProvider

upcomingPaymentsProvider

receiptProvider

refundProvider

---

# Componentes

GlassHeader

PaymentSummaryCard

UpcomingPaymentCard

PaymentCard

PaymentTimeline

ReceiptCard

RefundCard

SupportCard

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Sem pagamentos

Mostrar

```
Nenhum pagamento encontrado.
```

---

## Pagamento aprovado

Ícone verde.

---

## Pagamento pendente

Ícone amarelo.

---

## Pagamento recusado

Ícone vermelho.

---

## Reembolso

Ícone azul.

---

## Offline

Mostrar histórico em cache.

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

---

# Liquid Glass

Aplicar apenas em

Glass Header

Bottom Navigation

Dialogs

Floating Filters

Floating Search

Nunca aplicar em

Cards

Timeline

Tabela

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

Text

#1D1D1F

---

# Responsividade

## Desktop

Timeline lateral.

Detalhes ao lado.

---

## Tablet

Layout híbrido.

---

## Mobile

Cards empilhados.

Bottom Navigation.

Safe Area.

---

# Performance

Lazy Loading

Realtime

Background Refresh

Cache

Optimistic Update

Skeleton Loading

60 FPS

---

# Analytics

Receita por aluno

Pagamentos aprovados

Pagamentos recusados

Tempo médio entre cobranças

Valor total investido

Lifetime Value

---

# Segurança

Supabase Auth

JWT

HTTPS

Stripe

Webhooks

OWASP Top 10

Row Level Security

Ownership Guard

Criptografia

Logs de Auditoria

PCI DSS

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

## Transparência

Todos os pagamentos devem exibir claramente:

- curso
- valor
- data
- método
- status

---

## Segurança

Transmitir confiança.

Evitar termos técnicos.

Exibir status claros.

---

## Organização

Agrupar pagamentos por data.

Permitir busca e filtros.

---

## Histórico Permanente

O aluno deve conseguir consultar qualquer pagamento realizado desde a criação da conta.

---

# Critérios de Aceitação

- O aluno deve visualizar o histórico completo de pagamentos realizados em todos os cursos.
- Cada pagamento deve estar associado a um curso específico, respeitando o modelo de assinatura individual por curso.
- Deve ser possível visualizar detalhes da transação, baixar recibos e consultar cobranças futuras.
- Pagamentos recusados e reembolsos devem possuir tratamento visual específico.
- A página deve integrar Stripe e estar preparada para futuras integrações com Google Play Billing e Apple In-App Purchase.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado exclusivamente em elementos flutuantes.
- A experiência deve transmitir organização, segurança e transparência financeira.