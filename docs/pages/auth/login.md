---
id: PAGE-AUTH-003
name: Login
route: /login
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

# Login

## Objetivo

A tela de Login é o principal ponto de entrada da Lawrence Academy.

Ela deve transmitir elegância, confiança e simplicidade.

Inspirada na Apple ID, iCloud, Apple TV+, Arc Browser e Notion.

O usuário deve conseguir acessar sua conta em poucos segundos.

A interface deve praticamente desaparecer, permitindo que o foco permaneça na autenticação.

Toda a experiência deve ser extremamente minimalista.

Não utilizar ilustrações infantis.

Não utilizar gradientes exagerados.

Não utilizar excesso de informações.

---

# Objetivos

- Login rápido.
- Reduzir abandono.
- Facilitar recuperação de senha.
- Incentivar cadastro.
- Manter segurança.
- Experiência Premium.

---

# Fluxo

```
Splash

↓

Onboarding

↓

Login

↓

2FA (Opcional)

↓

Dashboard
```

---

# Layout

## Desktop

Grid

12 Columns

1440px

Tela dividida em duas áreas.

```
+------------------------------------------------------+

Imagem Editorial (60%)        Formulário (40%)

+------------------------------------------------------+
```

---

## Mobile

Tela única.

Conteúdo centralizado.

Safe Area.

Rolagem apenas quando necessário.

---

# Estrutura

```
Background

↓

Glass Navigation

↓

Logo

↓

Título

↓

Descrição

↓

Login Form

↓

Forgot Password

↓

Primary Button

↓

Social Login

↓

Register Link

↓

Footer
```

---

# Background

Cor

White

#FFFFFF

Imagem

Fotografia editorial relacionada à moda.

Pouco contraste.

Levemente desfocada.

Desktop apenas.

No Android utilizar fundo branco.

---

# Header

Desktop

Logo

Botão Home

Idioma

Tema

---

Mobile

Logo

---

Header utiliza

Liquid Glass

Blur 20px

Opacidade 72%

---

# Logo

Centro superior.

SVG.

Escala responsiva.

---

# Título

Bem-vindo de volta.

---

# Descrição

Entre para continuar seus estudos.

Acompanhe seu progresso, atividades e certificados.

---

# Login Form

## Campo

Email

Tipo

Email

Placeholder

Digite seu e-mail

Validação

Tempo real.

---

## Campo

Senha

Tipo

Password

Placeholder

Digite sua senha

---

## Recursos

Mostrar senha.

Ocultar senha.

Indicador Caps Lock.

Validação instantânea.

---

# Remember Me

Checkbox

Manter conectado.

---

# Forgot Password

Link

Esqueci minha senha

↓

Forgot Password

---

# Primary CTA

Entrar

Botão Pill

52px

Azul

#0A84FF

Hover

Scale 1.02

Pressed

Scale 0.97

---

# Social Login

Opcional.

Google

Apple (iOS)

Microsoft

---

Cada botão

Outline

Radius

999px

52px

---

# Divider

──────── ou continue com ────────

---

# Register

Texto

Ainda não possui conta?

Botão

Criar Conta

↓

Register

---

# Footer

Termos

Privacidade

Ajuda

Versão

---

# Estados

## Loading

Botão bloqueado.

Spinner Apple Style.

---

## Error

Mensagem discreta.

Email ou senha inválidos.

---

## Offline

Sem conexão.

---

## Locked

Conta temporariamente bloqueada.

---

## 2FA

Caso habilitado.

Enviar código.

SMS

Email

Authenticator

---

# Segurança

HTTPS

JWT

Refresh Token

Supabase Auth

Rate Limiting

Fingerprint

Device Tracking

OWASP Top 10

Proteção CSRF

Proteção XSS

Sessão segura

Logout remoto

Detecção de múltiplos dispositivos

---

# Validação

Email obrigatório.

Formato válido.

Senha obrigatória.

Senha mínima.

Bloqueio após múltiplas tentativas.

---

# Fluxo de Autenticação

```
Login

↓

Supabase Auth

↓

JWT

↓

Buscar Perfil

↓

Buscar Assinatura

↓

Buscar Cursos

↓

Dashboard
```

---

# APIs

POST /auth/login

POST /auth/logout

POST /auth/refresh

GET /auth/session

GET /user/profile

GET /subscription

---

# Providers

authProvider

userProvider

subscriptionProvider

settingsProvider

themeProvider

---

# Componentes

GlassHeader

LogoWidget

InputField

PasswordInput

PrimaryButton

SocialLoginButton

Divider

TextButton

ErrorBanner

LoadingButton

---

# Motion

Fade

Scale

Blur

Slide Up

Opacity

Spring

Shared Transition

---

# Liquid Glass

Aplicar apenas em

Header

Floating Login Card (Desktop)

Floating Action Button

Modal

Bottom Sheet

Nunca aplicar em

Campos

Botões

Texto

Background

---

# Tipografia

Título

SF Pro Display

36px

Bold

---

Descrição

17px

Regular

---

Inputs

17px

Regular

---

Botão

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

---

# Responsividade

## Desktop

Imagem ocupa 60%.

Formulário ocupa 40%.

Card centralizado verticalmente.

---

## Tablet

Imagem reduzida.

Formulário maior.

---

## Mobile

Imagem removida.

Logo central.

Formulário ocupa largura total.

Botão fixo inferior apenas quando teclado estiver fechado.

---

# Performance

Cache de sessão.

Login biométrico (Android futuro).

Pré-carregar Dashboard.

Validação local.

Animações 60fps.

---

# Analytics

Tentativas de login.

Tempo de autenticação.

Falhas.

Login Social.

Conversão Login → Dashboard.

---

# Acessibilidade

WCAG AA

TalkBack

VoiceOver

Screen Reader

Touch Target 44x44px

Keyboard Navigation

Focus Visible

Labels semânticas

Mensagens de erro acessíveis

---

# Psicologia de Conversão

## Clarity First

A tela deve conter apenas os elementos essenciais.

Nada deve competir com o formulário.

## Redução de Atrito

Solicitar apenas:

- Email
- Senha

Todo o restante fica para depois.

## Confiança

Mostrar discretamente:

- Conexão segura
- Dados protegidos
- Criptografia
- Política de Privacidade

## Continuidade

Caso exista uma sessão válida, redirecionar automaticamente para o Dashboard sem exibir esta tela.

---

# Critérios de Aceitação

- O login deve ser concluído em menos de 2 segundos em condições normais de rede.
- O layout deve seguir integralmente o Lawrence Design System.
- O formulário deve possuir validação em tempo real.
- A autenticação deve utilizar exclusivamente Supabase Auth com JWT e Refresh Token.
- O efeito Liquid Glass deve ser utilizado apenas no Header e em superfícies flutuantes.
- O botão "Entrar" deve permanecer desabilitado enquanto o formulário for inválido.
- Todos os estados (Loading, Offline, Erro, Conta Bloqueada e 2FA) devem estar implementados.
- A experiência deve transmitir segurança, minimalismo e sofisticação, seguindo a identidade visual premium da Lawrence Academy.