````markdown
---
id: PAGE-STUDENT-017
name: Referral Program
route: /dashboard/referral
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

feature:
  referral_program: true
  referral_type: Invite Friends
  reward_model:
    inviter: Coupon + Credits + Exclusive Rewards
    invited: First Purchase Discount
---

# Referral Program

## Objetivo

A página **Referral Program** permite que o aluno convide amigos para conhecer a Lawrence Academy e receba recompensas quando uma indicação resultar em uma assinatura ativa de um curso.

O programa deve incentivar o crescimento orgânico da plataforma através de uma experiência simples, transparente e motivadora.

Inspirado em:

- Dropbox Referral
- Notion Referral
- Revolut Invite Friends
- Nubank Indique Amigos
- Tesla Referral Program

---

# Objetivos

- Compartilhar link de indicação.
- Compartilhar código de convite.
- Acompanhar indicações.
- Visualizar recompensas.
- Resgatar benefícios.
- Consultar histórico.
- Compartilhar em redes sociais.

---

# Regras de Negócio

Cada aluno possui um código exclusivo.

Exemplo

```
LAWRENCE-AB45K9
```

ou

```
https://lawrenceacademy.com/r/AB45K9
```

Quando um novo aluno:

- cria uma conta;
- compra o primeiro curso;
- mantém a assinatura ativa pelo período mínimo definido;

a indicação é validada.

Após a validação o aluno recebe sua recompensa.

---

# Fluxo

```
Aluno

↓

Referral Program

↓

Compartilha Link

↓

Novo usuário cria conta

↓

Compra primeiro curso

↓

Pagamento aprovado

↓

Indicação validada

↓

Recompensa liberada
```

---

# Layout Desktop

```
------------------------------------------------------------

Glass Header

------------------------------------------------------------

Sidebar

|

Referral Hero

|

Meu Código

|

Resumo

|

Histórico

|

Ranking

|

Recompensas

------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Referral Hero

↓

Meu Código

↓

Resumo

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

Referral Hero

↓

Referral Code

↓

Share Actions

↓

Referral Summary

↓

Pending Referrals

↓

Rewards

↓

History

↓

Leaderboard (Future)

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

# Referral Hero

Mostrar

Imagem ilustrativa

Título

```
Convide amigos e ganhe recompensas.
```

Subtítulo

```
Quanto mais alunos você indicar, maiores serão seus benefícios.
```

CTA

```
Compartilhar Convite
```

---

# Referral Code

Card principal.

Mostrar

Código

Link

QR Code

Botões

Copiar

Compartilhar

Gerar QR

---

Exemplo

```
LAWRENCE-AB45K9
```

---

# Share Actions

Botões rápidos

WhatsApp

Telegram

Facebook

Instagram

Email

Copiar Link

Compartilhar Sistema

---

# Referral Summary

Mostrar

Convites enviados

Cadastros

Compras realizadas

Indicações válidas

Recompensas recebidas

Créditos disponíveis

---

Exemplo

```
28 Convites

15 Cadastros

9 Compras

7 Indicações válidas

R$350 em créditos
```

---

# Pending Referrals

Lista de indicações aguardando validação.

Cada item

Nome

Data

Status

---

Status

Cadastro realizado

↓

Primeira compra

↓

Pagamento aprovado

↓

Recompensa liberada

---

# Rewards

Lista de recompensas.

Exemplo

```
✔ Cupom de desconto

✔ Créditos

✔ Curso gratuito

✔ Certificado exclusivo

✔ Badge especial

✔ Conteúdo Premium
```

---

# Reward Card

Mostrar

Tipo

Descrição

Valor

Status

Botão

Resgatar

---

# History

Timeline.

Cada indicação mostra

Nome

Curso adquirido

Data

Valor

Status

Recompensa

---

# Leaderboard (Future)

Ranking mensal.

Mostrar

Top Indicadores

Quantidade

Recompensas

---

# FAQ

Perguntas rápidas.

Exemplo

Como funciona?

Quando recebo?

Quanto ganho?

Existe limite?

---

# APIs

GET /referrals

GET /referrals/history

GET /referrals/rewards

GET /referrals/pending

GET /referrals/code

POST /referrals/share

POST /referrals/redeem

GET /referrals/leaderboard

---

# Providers

referralProvider

referralHistoryProvider

referralRewardsProvider

pendingReferralProvider

leaderboardProvider

---

# Componentes

GlassHeader

ReferralHero

ReferralCodeCard

ShareButtons

ReferralSummaryCard

PendingReferralCard

RewardCard

HistoryTimeline

LeaderboardCard

FAQCard

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Sem indicações

Mostrar

```
Você ainda não realizou nenhuma indicação.
```

CTA

```
Compartilhar agora
```

---

## Recompensa disponível

Badge dourada.

Botão

Resgatar.

---

## Indicação pendente

Badge azul.

---

## Recompensa entregue

Badge verde.

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

Blur

Shared Transition

Confetti (somente ao liberar recompensa)

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Bottom Navigation

Floating Share Button

Dialogs

QR Code Modal

Nunca aplicar em

Cards principais

Listas

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

Resumo lateral.

Histórico completo.

Ranking em painel.

---

## Tablet

Layout híbrido.

---

## Mobile

Cards empilhados.

Bottom Navigation.

Safe Area.

Compartilhamento nativo.

---

# Performance

Lazy Loading

Realtime

Optimistic Update

Cache

Skeleton Loading

60 FPS

---

# Analytics

Convites enviados

Conversão

Cadastros

Compras

Receita gerada

Créditos distribuídos

Top Indicadores

Taxa de conversão

---

# Segurança

Supabase Auth

JWT

HTTPS

Row Level Security

Ownership Guard

Rate Limit

Anti-Fraud

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

## Gamificação

Mostrar progresso para a próxima recompensa.

Exemplo

```
Falta apenas 1 indicação válida para desbloquear um curso gratuito.
```

---

## Recompensa Imediata

Sempre informar claramente quando uma indicação foi validada.

---

## Compartilhamento Fácil

O compartilhamento deve acontecer em apenas um toque.

---

## Transparência

Cada indicação deve mostrar exatamente em qual etapa do processo está.

---

# Critérios de Aceitação

- Cada aluno deve possuir um código e um link exclusivos de indicação.
- O sistema deve permitir compartilhar convites por link, QR Code e aplicativos nativos.
- As recompensas devem ser liberadas somente após a validação das regras de negócio (cadastro, compra e pagamento aprovado).
- O aluno deve acompanhar em tempo real o status de todas as indicações e recompensas.
- A página deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado exclusivamente em elementos flutuantes.
- A experiência deve incentivar o crescimento orgânico da plataforma de forma clara, simples e transparente.
````
