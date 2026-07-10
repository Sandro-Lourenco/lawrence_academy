````markdown
---
id: PAGE-AUTH-001
name: Splash Screen
route: /splash
layout: SplashLayout
platforms:
  - Android
authentication: false
responsive: true
status: Production
design-system: Lawrence Design System
navigation: Auto
---

# Splash Screen

## Objetivo

A Splash Screen é a primeira experiência visual do usuário com a Lawrence Academy.

Ela não é apenas uma tela de carregamento.

Ela representa a identidade da marca, transmite sofisticação e prepara o usuário para uma experiência premium.

A animação deve ser extremamente fluida, minimalista e inspirada nas animações de inicialização dos produtos Apple.

O carregamento nunca deve parecer travado.

---

# Objetivos

- Mostrar identidade da marca.
- Carregar configurações iniciais.
- Validar sessão.
- Verificar conexão.
- Inicializar serviços.
- Carregar preferências.
- Pré-carregar assets.
- Inicializar Firebase.
- Inicializar Supabase.
- Preparar autenticação.

---

# Fluxo

```
App Open

↓

Splash

↓

Initialize Services

↓

Check Internet

↓

Check Authentication

↓

Check Subscription

↓

Home

ou

Login
```

---

# Layout

Safe Area

Tela inteira

Background branco

---

# Estrutura

```
Background

↓

Animated Logo

↓

Brand Name

↓

Loading Indicator

↓

Version

```

---

# Background

Cor

White

#FFFFFF

Imagem

Nenhuma

Gradiente

Não utilizar.

---

# Logo

Posição

Centro

Tamanho

120px

Formato

SVG

Vetorial

---

## Animação

Fade In

↓

Scale

↓

Glow

↓

Leve movimento vertical

↓

Fade para Home

---

Tempo

1200ms

---

# Nome

LAWRENCE

Academy

---

Fonte

SF Pro Display

Bold

---

Cor

Deep Blue

#0A84FF

---

# Loading

Indicador minimalista.

Nunca utilizar spinner padrão Android.

Utilizar:

Linha fina animada

ou

Progress Indicator Apple Style

---

Texto

Carregando...

---

# Versão

Inferior da tela

Exemplo

Version 1.0.0

Build 100

---

# Inicialização

## Serviços

Supabase

Analytics

Crashlytics

Push Notification

Local Storage

Theme

Preferences

Riverpod Providers

Cache

---

## Segurança

Validar Token JWT

Renovar sessão

Verificar assinatura

Carregar perfil

Sincronizar preferências

---

# Estados

Loading

Offline

Atualizando

Erro

Manutenção

---

# Offline

Mensagem

Sem conexão.

Botão

Tentar novamente

---

# Atualização Obrigatória

Caso exista atualização obrigatória.

Tela bloqueada.

Botão

Atualizar Aplicativo

---

# Tempo

Mínimo

1.5 segundos

Máximo

3 segundos

Nunca manter Splash indefinidamente.

---

# Navegação

Caso usuário esteja autenticado

↓

Dashboard

---

Caso não esteja autenticado

↓

Login

---

Caso onboarding nunca tenha sido visto

↓

Onboarding

---

# Motion

Fade

Scale

Opacity

Blur

Spring

Smooth

Nunca utilizar animações exageradas.

---

# Liquid Glass

Não utilizar Glass na Splash.

A tela deve ser extremamente limpa.

---

# Cores

60%

Branco

30%

Azul

10%

Dourado

---

# Tipografia

Logo

SF Pro Display

32px

Bold

---

Versão

13px

Regular

---

Loading

15px

Regular

---

# Componentes

SplashLogo

LoadingIndicator

VersionLabel

SplashController

---

# Providers

appInitializationProvider

authProvider

subscriptionProvider

themeProvider

settingsProvider

---

# APIs

GET /auth/session

GET /user/profile

GET /subscription/status

GET /settings

---

# Performance

Carregar em paralelo

Cache

Pré-carregar fontes

Pré-carregar ícones

Pré-carregar imagens críticas

---

# Analytics

Tempo da Splash

Tempo de inicialização

Falhas

Crashes

Tempo de autenticação

---

# Acessibilidade

TalkBack

VoiceOver

Alto Contraste

Texto escalável

---

# Critérios de Aceitação

- A Splash deve abrir instantaneamente.
- O tempo máximo de exibição deve ser de 3 segundos.
- Todos os serviços devem inicializar em paralelo.
- O logo deve possuir animação suave inspirada na Apple.
- Não utilizar gradientes.
- Não utilizar ilustrações.
- Não utilizar excesso de texto.
- A interface deve transmitir elegância, minimalismo e alta qualidade.
- O carregamento nunca deve parecer travado.
- Após a inicialização, o usuário deve ser redirecionado automaticamente para Onboarding, Login ou Dashboard conforme seu estado de autenticação.
````
