---
id: PAGE-AUTH-005
name: Forgot Password
route: /forgot-password
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

# Forgot Password

## Objetivo

A página **Forgot Password** permite que usuários recuperem o acesso à sua conta de forma simples, rápida e segura.

A experiência deve transmitir tranquilidade ao usuário. A interface deve ser extremamente minimalista, seguindo a filosofia **Clarity First** da Lawrence Academy.

Inspirada nas páginas de recuperação de senha da Apple ID, Google Account e Notion.

Nenhuma informação técnica deve ser exibida ao usuário.

---

# Objetivos

- Recuperar o acesso à conta.
- Reduzir solicitações ao suporte.
- Garantir segurança.
- Evitar enumeração de usuários.
- Manter experiência premium.

---

# Fluxo Geral

```
Login

↓

Esqueci minha senha

↓

Informar Email

↓

Enviar Link

↓

Verificar Caixa de Entrada

↓

Abrir Link

↓

Nova Senha

↓

Senha Alterada

↓

Login
```

---

# Layout

## Desktop

Grid

12 Columns

Layout dividido

```
+-------------------------------------------------------------+

Imagem Editorial (55%)

Recuperação de Senha (45%)

+-------------------------------------------------------------+
```

---

## Mobile

Tela única

Safe Area

Conteúdo centralizado

Rolagem apenas quando necessário.

---

# Estrutura

```
Background

↓

Glass Header

↓

Logo

↓

Título

↓

Descrição

↓

Campo Email

↓

Primary Button

↓

Voltar ao Login

↓

Footer
```

---

# Background

Desktop

Fotografia editorial

Ateliê

Tecidos

Mesa de Costura

Pouco contraste

Blur leve

---

Mobile

Branco

Sem imagens

---

# Header

Logo

Botão Voltar

Idioma

Tema

Liquid Glass

Blur 20px

Opacity 72%

---

# Logo

SVG

Centro

Responsivo

---

# Título

Esqueceu sua senha?

---

# Descrição

Informe o e-mail utilizado em sua conta.

Enviaremos um link seguro para redefinição da senha.

---

# Campo

## Email

Tipo

Email

Placeholder

Digite seu e-mail

Obrigatório

Validação em tempo real.

---

# CTA Principal

Enviar Link

Botão Pill

52px

Azul

#0A84FF

---

# CTA Secundário

Voltar para Login

↓

Login

---

# Fluxo de Recuperação

```
Usuário informa Email

↓

Validação

↓

Supabase Auth

↓

Gerar Recovery Token

↓

Enviar Email

↓

Mensagem de sucesso

↓

Usuário abre o link

↓

Nova Senha

↓

Atualizar Senha

↓

Login
```

---

# Tela de Sucesso

Após envio

Mostrar

Ícone

Email enviado

---

Título

Verifique sua caixa de entrada.

---

Descrição

Caso exista uma conta cadastrada com este e-mail, enviaremos um link para redefinir sua senha.

Verifique também sua caixa de spam.

---

Botões

Abrir Login

↓

Reenviar Email

(Disponível após 60 segundos)

---

# Nova Senha

Quando o usuário abrir o link recebido.

Campos

Nova Senha

Confirmar Senha

---

Validação

Mínimo

8 caracteres

Maiúscula

Minúscula

Número

Especial

Indicador visual

Fraca

Boa

Forte

Excelente

---

# Estados

Loading

Offline

Erro

Email enviado

Link expirado

Token inválido

Senha alterada

---

# Segurança

Nunca informar se o email existe.

Sempre responder:

"Se existir uma conta cadastrada, enviaremos um e-mail."

---

Recovery Token

JWT

Expiração

30 minutos

---

HTTPS obrigatório

---

Proteção contra

OWASP Top 10

CSRF

XSS

SQL Injection

Brute Force

Rate Limiting

---

# APIs

POST /auth/forgot-password

POST /auth/reset-password

GET /auth/validate-reset-token

---

# Integração Supabase

Utilizar

Supabase Auth

Métodos

resetPasswordForEmail()

updateUser()

---

# Providers

authProvider

forgotPasswordProvider

themeProvider

settingsProvider

---

# Componentes

GlassHeader

LogoWidget

EmailInput

PasswordInput

PrimaryButton

SecondaryButton

LoadingButton

SuccessCard

ErrorBanner

CountdownTimer

---

# Motion

Fade

Scale

Opacity

Slide Up

Spring

Blur

Shared Transition

---

# Liquid Glass

Aplicar apenas em

Header

Desktop Recovery Card

Bottom Sheet

Modal

Floating Actions

Nunca aplicar em

Campos

Texto

Botões

Background

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

Inputs

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

Erro

#FF453A

Sucesso

#30D158

Aviso

#FF9F0A

---

# Responsividade

## Desktop

Imagem lateral

Card centralizado

Largura máxima

500px

---

## Tablet

Imagem reduzida

---

## Mobile

Sem imagem

Conteúdo ocupa largura total

Botão fixo inferior quando teclado estiver fechado

---

# Performance

Validação local

Pré-carregar tela Login

Cache

Animações 60fps

Tempo máximo de resposta inferior a 2 segundos

---

# Analytics

Quantidade de solicitações

Taxa de recuperação

Tempo médio

Falhas

Links expirados

Conversão Recuperação → Login

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Focus Visible

Screen Reader

Touch Target mínimo 44x44px

Labels semânticas

Mensagens acessíveis

---

# Psicologia de Conversão

## Redução da Ansiedade

A linguagem deve ser positiva e acolhedora.

Evitar mensagens alarmantes.

Exemplo:

"Não se preocupe. Vamos ajudá-lo a recuperar sua conta."

---

## Segurança sem Complexidade

O usuário deve sentir que seus dados estão protegidos sem precisar entender aspectos técnicos.

Exibir discretamente:

✔ Link seguro

✔ Criptografia

✔ Expiração automática

---

## Clareza

A tela deve conter apenas:

- Logo
- Título
- Descrição
- Campo Email
- Botão Enviar
- Link Voltar

Nada mais.

---

# Critérios de Aceitação

- A tela deve solicitar apenas o endereço de e-mail.
- Nunca deve revelar se um e-mail está ou não cadastrado.
- O envio deve utilizar exclusivamente o fluxo de recuperação do Supabase Auth.
- O link de redefinição deve expirar automaticamente após 30 minutos.
- A nova senha deve obedecer às regras de segurança definidas pela plataforma.
- O botão "Enviar Link" deve permanecer desabilitado enquanto o e-mail for inválido.
- Todos os estados (Loading, Offline, Token Inválido, Link Expirado e Sucesso) devem estar implementados.
- O layout deve seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve ser aplicado apenas em elementos flutuantes.
- A experiência deve transmitir segurança, simplicidade e confiança, permitindo que o usuário recupere sua conta com o mínimo de esforço.