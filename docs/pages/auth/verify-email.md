---
id: PAGE-AUTH-006
name: Verify Email
route: /verify-email
layout: AuthLayout
platforms:
  - Web
  - Android
roles:
  - Guest
authentication: false
responsive: true
status: Production
design-system: Lawrence Design System
navigation: Replace
---

# Verify Email

## Objetivo

A página **Verify Email** confirma que o endereço de e-mail informado pertence ao usuário e ativa sua conta na Lawrence Academy.

Ela é uma etapa obrigatória do processo de cadastro e faz parte da estratégia de segurança da plataforma.

A experiência deve transmitir confiança e simplicidade.

O usuário nunca deve ficar confuso sobre o que fazer em seguida.

Inspirada na experiência da Apple ID, Google Account e Stripe.

---

# Objetivos

- Confirmar identidade do usuário.
- Ativar a conta.
- Reduzir fraudes.
- Garantir segurança.
- Melhorar entregabilidade de e-mails.
- Preparar o primeiro acesso.

---

# Fluxo

```
Cadastro

↓

Conta criada

↓

Enviar Email

↓

Verify Email

↓

Usuário abre Email

↓

Clique no Link

↓

Supabase valida Token

↓

Conta Ativada

↓

Dashboard
```

---

# Layout

## Desktop

Grid

12 Columns

Tela dividida

```
+-------------------------------------------------------------+

Imagem Editorial (55%)

Verify Email (45%)

+-------------------------------------------------------------+
```

---

## Mobile

Tela única

Safe Area

Conteúdo centralizado

---

# Estrutura

```
Background

↓

Glass Header

↓

Logo

↓

Success Icon

↓

Título

↓

Descrição

↓

Email Informado

↓

Primary CTA

↓

Countdown

↓

Alterar Email

↓

Footer
```

---

# Background

Desktop

Imagem editorial.

Ateliê.

Costura.

Luz natural.

Blur suave.

---

Mobile

Branco puro

#FFFFFF

---

# Header

Logo

Botão Home

Tema

Idioma

Liquid Glass

Blur 20px

Opacity 72%

---

# Ícone

Envelope

Animação

Fade

Scale

Pulse suave

Cor

Primary Blue

---

# Título

Verifique seu e-mail

---

# Descrição

Enviamos um link de confirmação para:

**usuario@email.com**

Clique no link recebido para ativar sua conta.

---

# Avisos

Caso não encontre o e-mail:

✔ Verifique Spam

✔ Verifique Promoções

✔ Aguarde alguns minutos

---

# CTA Principal

Abrir Login

↓

Login

Disponível somente após confirmação.

---

# CTA Secundário

Reenviar Email

Disponível após

60 segundos

---

# CTA Terciário

Alterar Email

↓

Cadastro

---

# Estados

## Email Enviado

Mensagem

Tudo pronto!

Seu e-mail foi enviado com sucesso.

---

## Confirmado

Ícone

Check

Verde

Título

Conta verificada.

Descrição

Sua conta foi ativada.

Botão

Ir para Dashboard

---

## Link Expirado

Ícone

Warning

Mensagem

Este link expirou.

Botão

Enviar novo link

---

## Token Inválido

Mensagem

O link informado não é válido.

Botão

Solicitar novo email

---

## Offline

Sem conexão.

Botão

Tentar novamente

---

# Fluxo de Verificação

```
Abrir Link

↓

Supabase Auth

↓

Validar Token

↓

Ativar Conta

↓

Criar Sessão

↓

Dashboard
```

---

# Integração Supabase

Métodos

verifyOtp()

exchangeCodeForSession()

getSession()

---

# APIs

POST /auth/resend-email

GET /auth/verify

GET /auth/session

---

# Banco

users

```
id

email

email_confirmed

created_at

verified_at
```

---

# Providers

authProvider

userProvider

settingsProvider

themeProvider

---

# Componentes

GlassHeader

SuccessIcon

EmailCard

PrimaryButton

SecondaryButton

CountdownTimer

StatusCard

ErrorBanner

LoadingButton

---

# Motion

Fade

Scale

Opacity

Slide

Blur

Spring

Confetti discreto ao confirmar.

---

# Liquid Glass

Aplicar apenas em

Header

Desktop Card

Floating Actions

Bottom Sheet

Modal

Nunca aplicar em

Texto

Background

Cards principais

---

# Tipografia

Título

36px

Bold

SF Pro Display

---

Texto

17px

Regular

---

Botões

17px

Semibold

---

# Cores

60%

Branco

30%

Azul

10%

Dourado

Sucesso

#30D158

Erro

#FF453A

Aviso

#FF9F0A

---

# Responsividade

## Desktop

Imagem lateral

Card central

Máximo

520px

---

## Tablet

Imagem reduzida

---

## Mobile

Imagem removida

Conteúdo ocupa toda largura

Botões empilhados

---

# Performance

Tempo máximo

2 segundos

Cache

Validação automática

Pré-carregar Dashboard

---

# Analytics

Taxa de confirmação

Tempo médio

Reenvios

Links expirados

Conversão Cadastro → Conta Ativa

---

# Acessibilidade

WCAG AA

TalkBack

VoiceOver

Screen Reader

Keyboard Navigation

Focus Visible

Touch Target 44x44px

---

# Segurança

HTTPS

Supabase Auth

JWT

Refresh Token

Expiração automática

Rate Limit

OWASP Top 10

Proteção contra Replay Attack

Proteção contra Brute Force

Verificação única por token

---

# Psicologia de Conversão

## Clareza

Explicar exatamente o que o usuário precisa fazer.

Sem termos técnicos.

---

## Redução da Ansiedade

Mostrar mensagens positivas.

Exemplo

"Estamos quase lá."

"Falta apenas confirmar seu e-mail."

---

## Continuidade

Após confirmação:

Login automático quando suportado.

Caso contrário:

Redirecionar para Login.

---

## Segurança Invisível

Mostrar discretamente

✔ Conta protegida

✔ Confirmação segura

✔ Criptografia

---

# Critérios de Aceitação

- O e-mail de verificação deve ser enviado automaticamente após o cadastro.
- O botão "Reenviar Email" deve permanecer desabilitado durante 60 segundos após cada envio.
- O sistema deve utilizar exclusivamente o fluxo de verificação do Supabase Auth.
- Após a confirmação do e-mail, a conta deve ser ativada automaticamente.
- Caso o link esteja expirado ou inválido, o usuário deve conseguir solicitar um novo e-mail de verificação.
- Todos os estados (Email Enviado, Confirmado, Link Expirado, Token Inválido, Offline e Loading) devem estar implementados.
- O layout deve seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve ser utilizado apenas em superfícies flutuantes.
- A experiência deve transmitir confiança, simplicidade e segurança, permitindo que o usuário conclua a ativação da conta com o mínimo de esforço.