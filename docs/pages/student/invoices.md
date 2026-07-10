---
id: PAGE-STUDENT-016
name: Invoices
route: /dashboard/invoices
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

# Invoices

## Objetivo

A página **Invoices** centraliza todas as faturas geradas pelas assinaturas dos cursos.

Cada assinatura de curso gera suas próprias faturas, permitindo ao aluno consultar documentos fiscais, baixar recibos em PDF, acompanhar pagamentos pendentes e manter um histórico financeiro organizado.

Esta página é exclusivamente voltada para **documentos de cobrança**, diferente da página **Payments**, que representa as transações financeiras.

Inspirada em:

- Stripe Billing
- Apple Subscription Invoices
- Adobe Billing
- AWS Billing
- Notion Billing

---

# Objetivos

- Visualizar todas as faturas.
- Baixar PDF.
- Consultar situação.
- Visualizar detalhes.
- Compartilhar comprovante.
- Reemitir faturas.
- Pesquisar documentos.

---

# Fluxo

```
Aluno

↓

Invoices

↓

Seleciona Fatura

↓

Visualiza detalhes

↓

Download PDF

↓

Compartilhar
```

---

# Layout Desktop

```
--------------------------------------------------------------

Glass Header

--------------------------------------------------------------

Sidebar

|

Resumo Financeiro

|

Lista de Faturas

|

Detalhes

--------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Resumo

↓

Faturas

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

Invoice Summary

↓

Invoice Filters

↓

Invoice List

↓

Invoice Detail

↓

Download Area

↓

Support
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

# Invoice Summary

Mostrar

Total de faturas

Faturas pagas

Pendentes

Valor faturado

Última emissão

---

Exemplo

```
36 Faturas

34 Pagas

2 Pendentes

R$2.480,00

Última emissão

15 Julho 2026
```

---

# Invoice Filters

Filtros disponíveis

Curso

Status

Ano

Mês

Valor

Pesquisar

Ordenação

---

# Invoice List

Tabela (Desktop)

Cards (Mobile)

Cada item mostra

Número

Curso

Plano

Valor

Data de emissão

Vencimento

Status

PDF

---

Exemplo

```
INV-2026-001254

Modelagem Feminina

R$59,90

Emitida

10 Julho

Vence

15 Julho

Pago
```

---

# Status

Cada fatura pode possuir

Emitida

↓

Pendente

↓

Paga

↓

Atrasada

↓

Cancelada

↓

Reembolsada

---

Cada status possui cor própria.

Verde

Pago

Amarelo

Pendente

Vermelho

Atrasada

Cinza

Cancelada

Azul

Reembolso

---

# Invoice Detail

Ao abrir uma fatura.

Mostrar

Número

Curso

Professor

Plano

Assinatura

Valor

Descontos

Taxas

Subtotal

Total

Método de pagamento

Data

Data de vencimento

Status

ID Stripe

Observações

---

Botões

Baixar PDF

Compartilhar

Imprimir

Abrir Pagamento

Solicitar Suporte

---

# Download Area

Permitir

Baixar PDF

Enviar por Email

Compartilhar

Copiar Número

---

# Support

Caso exista problema.

Botão

Solicitar ajuda financeira

↓

Central de atendimento

---

# APIs

GET /invoices

GET /invoices/{id}

GET /invoices/{id}/pdf

GET /invoices/course/{courseId}

GET /invoices/search

GET /invoices/filter

POST /invoices/share

POST /invoices/support

---

# Providers

invoiceProvider

invoiceDetailProvider

invoiceFilterProvider

invoiceSearchProvider

invoicePdfProvider

---

# Componentes

GlassHeader

InvoiceSummaryCard

InvoiceFilterBar

InvoiceTable

InvoiceCard

InvoiceStatusBadge

InvoiceDetailCard

DownloadCard

SupportCard

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Sem faturas

Mostrar

```
Nenhuma fatura encontrada.
```

Botão

Explorar Cursos

---

## Fatura paga

Badge verde.

---

## Fatura pendente

Badge amarela.

---

## Fatura vencida

Banner discreto.

Botão

Regularizar pagamento.

---

## Reembolso

Badge azul.

---

## Offline

Exibir últimas faturas em cache.

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

Floating Filter

Floating Search

Floating Download Button

Nunca aplicar em

Tabela

Cards principais

Texto

PDF Viewer

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

Tabela completa.

Filtros laterais.

Painel de detalhes.

---

## Tablet

Tabela reduzida.

---

## Mobile

Cards empilhados.

Bottom Navigation.

Safe Area.

Filtros em Bottom Sheet.

---

# Performance

Lazy Loading

Realtime

Cache

Optimistic Update

Skeleton Loading

Background Refresh

60 FPS

---

# Analytics

Quantidade de faturas

Valor faturado

Faturas pagas

Faturas pendentes

Cursos com maior faturamento

Tempo médio para pagamento

---

# Segurança

Supabase Auth

JWT

HTTPS

Stripe Billing

Stripe Webhooks

OWASP Top 10

Row Level Security

Ownership Guard

Logs de Auditoria

Criptografia

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

## Clareza

Cada documento deve ser facilmente compreendido.

Evitar termos fiscais complexos.

---

## Organização

Agrupar faturas por ano e mês.

Permitir filtros rápidos.

---

## Confiança

Sempre exibir:

- número da fatura
- curso
- valor
- vencimento
- situação

---

## Facilidade

O download do PDF deve acontecer em apenas um clique.

---

# Critérios de Aceitação

- Cada assinatura de curso deve gerar suas próprias faturas independentes.
- O aluno deve visualizar, pesquisar, filtrar e baixar todas as faturas emitidas.
- Deve ser possível consultar detalhes completos da cobrança e acessar o PDF da fatura.
- A página deve integrar Stripe Billing e estar preparada para futuras integrações com Google Play Billing e Apple In-App Purchase.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado exclusivamente em elementos flutuantes.
- A experiência deve transmitir organização, transparência e confiabilidade financeira.