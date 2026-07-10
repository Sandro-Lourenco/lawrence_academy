---
id: PAGE-STUDENT-014
name: My Course Subscriptions
route: /dashboard/subscriptions
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

business-model:
  type: Course Subscription
  billing: Monthly Per Course
  multiple-active-subscriptions: true
  provider:
    - Stripe (Web)
    - Google Play Billing (Future)
---

# My Course Subscriptions

> **Importante**
>
> A Lawrence Academy **não possui uma assinatura global da plataforma**.
>
> Cada curso possui sua **própria assinatura mensal**, permitindo que o aluno tenha uma ou várias assinaturas simultaneamente.
>
> Exemplo:
>
> - Modelagem Feminina → R$59,90/mês
> - Alta Costura → R$89,90/mês
> - Alfaiataria → R$89,90/mês
>
> O aluno pode cancelar um curso sem perder acesso aos demais.

---

# Objetivo

A página **My Course Subscriptions** centraliza todas as assinaturas ativas, pausadas, canceladas e expiradas do aluno.

Ela deve permitir visualizar:

- cursos assinados
- valor individual
- próxima cobrança
- histórico
- status
- método de pagamento
- ações de gerenciamento

A experiência deve transmitir segurança, transparência e simplicidade.

Inspirada em:

- Apple Subscriptions
- Stripe Customer Portal
- Netflix Billing
- Adobe Creative Cloud
- Notion Billing

---

# Objetivos

- Gerenciar todas as assinaturas.
- Visualizar cobranças.
- Atualizar cartão.
- Cancelar apenas um curso.
- Renovar assinatura.
- Alterar método de pagamento.
- Consultar histórico.
- Baixar recibos.
- Visualizar benefícios.

---

# Fluxo

```
Aluno

↓

Dashboard

↓

Minhas Assinaturas

↓

Seleciona Curso

↓

Gerenciar Assinatura

↓

Pagamento

↓

Supabase

↓

Stripe

↓

Atualização automática
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

Cursos Assinados

|

Detalhes do Curso

|

Método de Pagamento

|

Histórico

--------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Resumo

↓

Cursos

↓

Detalhes

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

Subscription Summary

↓

Active Course Subscriptions

↓

Course Subscription Detail

↓

Payment Method

↓

Billing History

↓

Invoices

↓

Recommendations

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

# Subscription Summary

Resumo geral.

Mostrar:

Quantidade de cursos ativos

Valor total mensal

Próxima cobrança

Total economizado

---

Exemplo

```
3 Cursos Ativos

R$189,70/mês

Próxima cobrança

15 Agosto

Total investido

R$1.245,00
```

---

# Active Course Subscriptions

Grid.

Cada cartão representa uma assinatura.

Nunca agrupar tudo em uma única assinatura.

---

## Course Subscription Card

Mostrar:

Imagem do curso

Nome

Professor

Plano

Preço mensal

Status

Próxima cobrança

Tempo restante

Progresso do curso

Botão

Gerenciar

---

Exemplo

```
Modelagem Feminina

Premium

R$59,90/mês

Próxima cobrança

15 Agosto

72% concluído
```

---

# Status

Cada assinatura possui:

Ativa

↓

Em renovação

↓

Pagamento pendente

↓

Cancelada

↓

Expirada

↓

Pausada (futuro)

---

# Course Detail

Ao clicar em um curso.

Mostrar:

Nome

Descrição

Plano

Valor

Histórico

Método

Renovação

Professor

Data de compra

---

Botões

Abrir Curso

Alterar cartão

Cancelar assinatura

Renovar

---

# Cancelamento

O cancelamento afeta apenas aquele curso.

Nunca cancelar os demais.

Fluxo:

```
Cancelar

↓

Confirmar

↓

Último acesso

↓

Fim do período pago

↓

Curso encerrado
```

Mensagem

```
Você continuará com acesso ao curso até:

15 Setembro 2026
```

---

# Renewal

Mostrar:

Renovação automática

ON/OFF

Data

Valor

---

# Payment Method

Cartão utilizado.

Mostrar:

Visa

•••• 4587

Validade

Principal

---

Botões

Alterar

Adicionar

Remover

---

# Billing History

Timeline.

Cada cobrança mostra:

Curso

Valor

Status

Método

Data

---

Exemplo

```
Modelagem Feminina

R$59,90

Pago

15 Julho
```

---

# Invoices

Lista.

Mostrar:

Número

Curso

Valor

PDF

Download

---

# Recommendation

Caso um curso esteja quase concluído.

Mostrar

```
Você está quase terminando.

Conheça:

Modelagem Avançada.
```

---

# APIs

GET /student/subscriptions

GET /student/subscriptions/{id}

PATCH /student/subscriptions/{id}

POST /student/subscriptions/{id}/cancel

POST /student/subscriptions/{id}/resume

GET /student/subscriptions/{id}/history

GET /student/subscriptions/{id}/invoice

GET /student/payment-methods

PATCH /student/payment-method

GET /student/billing

---

# Providers

subscriptionsProvider

subscriptionDetailProvider

billingHistoryProvider

paymentMethodProvider

invoiceProvider

recommendationProvider

---

# Componentes

GlassHeader

SubscriptionSummaryCard

CourseSubscriptionCard

SubscriptionDetailCard

BillingTimeline

InvoiceCard

PaymentMethodCard

RecommendationCard

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Sem assinaturas

Mostrar:

```
Você ainda não possui cursos assinados.
```

Botão

Explorar Cursos

---

## Assinatura ativa

Mostrar normalmente.

---

## Pagamento pendente

Banner amarelo.

---

## Pagamento recusado

Banner discreto.

Botão

Atualizar cartão.

---

## Curso cancelado

Mostrar:

Acesso até

Data final.

---

## Erro

Toast.

Botão

Tentar novamente.

---

# Motion

Fade

Scale

Slide

Hero Animation

Spring

Progress Animation

Shared Transition

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Floating Action Buttons

Bottom Navigation

Dialogs

Floating Billing Card

Nunca aplicar em

Cards dos cursos

Texto

Tabela

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

Grid 2 colunas.

Sidebar fixa.

Painel lateral.

---

## Tablet

Grid responsivo.

---

## Mobile

Cards empilhados.

Bottom Navigation.

Safe Area.

---

# Performance

Lazy Loading

Realtime

Optimistic Update

Background Refresh

Image Cache

Skeleton Loading

60 FPS

---

# Analytics

Cursos ativos

Cursos cancelados

Receita recorrente

Renovações

Cancelamentos

Lifetime Value

Tempo médio por assinatura

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

---

# Psicologia de Produto

## Transparência

Cada curso deve deixar claro:

- quanto custa;
- quando será cobrado;
- qual cartão será utilizado.

---

## Sem Dark Patterns

Cancelar um curso deve ser simples.

No máximo dois passos.

Sem esconder botões.

---

## Reforço de Valor

Antes da renovação mostrar:

```
Neste curso você já assistiu:

✔ 42 aulas

✔ 31 horas

✔ 72% concluído
```

---

## Continuidade

Ao cancelar:

Mostrar o tempo restante de acesso.

Exemplo:

```
Seu acesso permanecerá disponível até 15/09/2026.
```

---

# Critérios de Aceitação

- O sistema deve permitir múltiplas assinaturas simultâneas, uma para cada curso adquirido.
- Cada assinatura deve possuir cobrança, renovação, histórico e gerenciamento independentes.
- O cancelamento de uma assinatura não pode afetar as demais.
- O aluno deve visualizar o resumo financeiro consolidado e os detalhes individuais de cada curso.
- O histórico de cobranças e as faturas devem ser acessíveis por curso.
- A página deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado exclusivamente em elementos flutuantes.
- A arquitetura deve suportar Flutter Web, Flutter Android, Python (FastAPI), Supabase e Stripe, permitindo futura integração com Google Play Billing.
````
