---
id: PAGE-AUTH-007
name: Reset Password
route: /reset-password
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

# Reset Password

## Objetivo

A página **Reset Password** permite que o usuário defina uma nova senha após validar o link enviado por e-mail.

Esta página somente pode ser acessada através do **Recovery Link** enviado pelo Supabase Auth.

Ela representa a última etapa do processo de recuperação de conta.

A experiência deve transmitir segurança, simplicidade e confiança.

Inspirada no fluxo de redefinição de senha da Apple ID, Google e Stripe.

---

# Objetivos

- Permitir redefinição segura da senha.
- Validar o Recovery Token.
- Atualizar a senha no Supabase Auth.
- Encerrar sessões antigas.
- Direcionar o usuário novamente para a plataforma.

---
# Fluxo

```
Forgot Password

↓

Email enviado

↓

Usuário abre o link

↓

Supabase valida Recovery Token

↓

Reset Password

↓

Nova Senha

↓

Atualizar Senha

↓

Senha Alterada

↓

Login

↓

Dashboard
```

---

# Layout

## Desktop

Grid

12 Columns

```
+------------------------------------------------------------+

Imagem Editorial (55%)

Reset Password (45%)

+------------------------------------------------------------+
```

---

## Mobile

Safe Area

Tela única

Conteúdo centralizado

Rolagem vertical

---

# Estrutura

```
Background

↓

Glass Header

↓

Logo

↓

Security Illustration

↓

Título

↓

Descrição

↓

Nova Senha

↓

Confirmar Senha

↓

Password Strength

↓

Primary Button

↓

Footer
```

---

# Background

Desktop

Imagem editorial.

Ateliê.

Mesa de corte.

Luz natural.

Blur suave.

---

Mobile

Branco puro

#FFFFFF

---

# Header

Logo

Tema

Idioma

Home

Liquid Glass

Blur 20px

Opacity 72%

---

# Ícone

Shield

Lock

Check

Animação

Fade

Scale

---

# Título

Crie uma nova senha

---

# Descrição

Sua nova senha substituirá a anterior.

Após a alteração, todas as sessões antigas serão encerradas automaticamente.

---

# Campo

## Nova Senha

Tipo

Password

Placeholder

Digite sua nova senha

Mostrar senha

Ocultar senha

---

## Confirmar Senha

Tipo

Password

Placeholder

Confirme sua nova senha

---

# Password Strength

Indicador visual

Muito Fraca

Fraca

Boa

Forte

Excelente

---

# Regras da Senha

✔ Mínimo 8 caracteres

✔ 1 letra maiúscula

✔ 1 letra minúscula

✔ 1 número

✔ 1 caractere especial

✔ Não pode ser igual à senha anterior

---

# CTA Principal

Salvar Nova Senha

Botão Pill

52px

Azul

#0A84FF

Hover

Scale 1.02

Pressed

Scale 0.97

---

# Tela de Sucesso

Após alteração

Ícone

Check Circle

Verde

---

Título

Senha alterada com sucesso

---

Descrição

Sua conta foi protegida com sua nova senha.

Agora você pode acessar normalmente.

---

Botão

Entrar

↓

Login

---

# Estados

## Loading

Botão bloqueado

Spinner Apple Style

---

## Senha Fraca

Mensagem

Sua senha não atende aos requisitos mínimos.

---

## Senhas Diferentes

Mensagem

As senhas informadas não coincidem.

---

## Token Inválido

Mensagem

Este link não é mais válido.

Botão

Solicitar novo link

↓

Forgot Password

---

## Token Expirado

Mensagem

Este link expirou.

Botão

Enviar novo email

---

## Offline

Mensagem

Sem conexão.

Botão

Tentar novamente

---

## Sucesso

Mensagem

Senha atualizada.

---

# Fluxo Técnico

```
Recovery Link

↓

Supabase Auth

↓

Validar Token

↓

updateUser()

↓

Atualizar Password

↓

Invalidar Sessões

↓

Login
```

---

# APIs

POST /auth/reset-password

GET /auth/session

POST /auth/logout-all-devices

---

# Integração Supabase

Métodos

exchangeCodeForSession()

updateUser()

signOut()

---

# Providers

authProvider

sessionProvider

settingsProvider

themeProvider

---

# Componentes

GlassHeader

LogoWidget

PasswordInput

PasswordStrength

RequirementList

PrimaryButton

LoadingButton

SuccessCard

ErrorBanner

---

# Motion

Fade

Scale

Blur

Slide Up

Spring

Opacity

Shared Transition

---

# Liquid Glass

Aplicar apenas em

Header

Desktop Card

Bottom Sheet

Floating Button

Modal

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

Sem imagem

Conteúdo ocupa largura total

Botão fixo inferior quando teclado estiver fechado

---

# Performance

Validação local

Atualização em tempo real

Pré-carregar Login

Cache

Animações 60fps

Tempo máximo de resposta inferior a 2 segundos

---

# Analytics

Quantidade de redefinições

Tempo médio

Links expirados

Falhas

Conversão Reset → Login

---

# Segurança

HTTPS obrigatório

Supabase Auth

JWT

Recovery Token

Refresh Token

Rate Limiting

OWASP Top 10

Proteção contra Replay Attack

Proteção contra Brute Force

Proteção contra CSRF

Proteção contra XSS

Logout automático de todas as sessões antigas

Obrigar novo login em todos os dispositivos

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Screen Reader

Focus Visible

Touch Target mínimo 44x44px

Labels semânticas

Mensagens acessíveis

---

# Psicologia de Conversão

## Segurança Visível

Mostrar discretamente:

✔ Sua senha é criptografada.

✔ Todas as sessões anteriores serão encerradas.

✔ Sua conta ficará protegida.

---

## Clareza

A página deve conter apenas:

- Logo
- Título
- Descrição
- Nova Senha
- Confirmar Senha
- Indicador de força
- Botão Salvar

Nada além disso.

---

## Feedback Imediato

As regras da senha devem ser validadas em tempo real.

Cada requisito deve receber um check verde conforme for atendido.

---

## Continuidade

Após a redefinição:

Senha alterada

↓

Login

↓

Dashboard

---

# Critérios de Aceitação

- A página deve ser acessível apenas através de um Recovery Token válido do Supabase Auth.
- A nova senha deve atender a todas as regras de segurança da plataforma.
- O botão **Salvar Nova Senha** deve permanecer desabilitado até que todas as validações sejam concluídas.
- Após a alteração da senha, todas as sessões anteriores devem ser encerradas automaticamente.
- O usuário deve ser redirecionado para a tela de Login após a redefinição bem-sucedida.
- Todos os estados (Loading, Token Inválido, Token Expirado, Offline, Erro e Sucesso) devem estar implementados.
- O layout deve seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve ser aplicado apenas em superfícies flutuantes.
- A experiência deve transmitir segurança, minimalismo e confiança, mantendo a identidade premium da Lawrence Academy.
````
