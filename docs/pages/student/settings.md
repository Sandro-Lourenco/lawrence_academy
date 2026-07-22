---
id: PAGE-STUDENT-013
name: Settings
route: /dashboard/settings
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
---

# Settings

## Implementação canônica da fase de Configurações

A rota `/dashboard/settings` funciona como central progressiva das opções que
possuem fluxo real: downloads offline, assinaturas, faturas e encerramento de
sessão. O logout exige confirmação e utiliza o `LogoutUseCase` existente.

Tema, idioma, notificações, reprodução, privacidade, dispositivos e contas
conectadas não possuem providers e contratos completos nesta versão. Por isso,
nenhum switch ou valor fictício é apresentado e não há promessa de autosave.

## Objetivo

A página **Settings** concentra todas as configurações globais da Lawrence Academy.

Diferentemente da página **Profile**, que representa a identidade do usuário, **Settings** controla o comportamento da aplicação.

Toda a experiência deve transmitir:

- Simplicidade
- Clareza
- Controle
- Segurança
- Organização

Inspirada em:

- Apple Settings
- macOS System Settings
- Notion Settings
- Linear Preferences
- Arc Browser
- Stripe Dashboard

---

# Objetivos

- Configurar preferências da aplicação.
- Gerenciar notificações.
- Personalizar experiência.
- Configurar reprodução.
- Configurar downloads.
- Configurar privacidade.
- Gerenciar segurança.
- Gerenciar integração da conta.

---

# Fluxo

```
Usuário

↓

Settings

↓

Seleciona categoria

↓

Altera configuração

↓

Salvar automaticamente

↓

Sincronizar Supabase

↓

Todos os dispositivos atualizados
```

---

# Layout Desktop

```
----------------------------------------------------------

Glass Header

----------------------------------------------------------

Sidebar

|

Categorias

|

Painel Configuração

|

Preview

----------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Categorias

↓

Configurações

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Settings Overview

↓

General

↓

Appearance

↓

Notifications

↓

Playback

↓

Downloads

↓

Privacy

↓

Security

↓

Accessibility

↓

Connected Accounts

↓

About App
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

Componentes

Logo

Pesquisa

Perfil

---

# Settings Overview

Mostrar

Última sincronização

Versão

Plano

Dispositivo

Idioma

---

Exemplo

```
Configurações

Sincronizado agora

Versão 1.0.0

Plano Premium
```

---

# Sidebar (Desktop)

Categorias

- Geral
- Aparência
- Notificações
- Reprodução
- Downloads
- Privacidade
- Segurança
- Acessibilidade
- Contas Conectadas
- Sobre

---

# General

Campos

Idioma

Fuso horário

Formato da data

Formato da hora

Idioma do conteúdo

País

---

# Appearance

Opções

Modo Claro

Modo Escuro

Sistema

---

Escala da interface

100%

110%

125%

150%

---

Densidade

Compacta

Confortável

---

Animações

Ativar

Desativar

Reduzidas

---

# Notifications

Push

Email

Lives

Professor

Cursos

Atividades

Correções

Pagamentos

Marketing

Sistema

Certificados

Novidades

Cada opção com Switch.

---

# Playback

Qualidade padrão

Auto

1080p

720p

480p

360p

---

Velocidade padrão

0.75x

1.0x

1.25x

1.5x

2x

---

Autoplay

Ativar

---

Lembrar posição

Ativar

---

Pular introdução

Ativar

---

Legendas

Sempre

Nunca

Automático

---

# Downloads

Somente Wi-Fi

Qualidade Offline

Alta

Média

Baixa

---

Excluir cursos concluídos automaticamente

---

Sincronizar apenas Wi-Fi

---

Limite de armazenamento

---

# Privacy

Mostrar perfil

Mostrar certificados

Mostrar progresso

Participar do ranking

Receber recomendações

Uso de analytics

Cookies

Exportar dados

---

# Security

Autenticação em dois fatores

Sessões

Dispositivos

Alterar senha

PIN do aplicativo

Biometria Android

Face ID (futuro)

---

# Accessibility

Fonte maior

Contraste elevado

Redução de movimento

Legendas automáticas

Descrição de imagens

Compatibilidade com leitor de tela

---

# Connected Accounts

Google

Apple

Facebook

Microsoft

GitHub

---

Mostrar

Status

Conectado

Desconectado

---

# About

Mostrar

Versão

Build

Licença

Política de Privacidade

Termos

Código aberto

Contato

---

# Save Strategy

Todas as configurações utilizam

Auto Save.

Não existe botão

Salvar.

Mostrar

```
Alterações salvas automaticamente.
```

---

# APIs

GET /settings

PATCH /settings

GET /settings/appearance

PATCH /settings/appearance

GET /settings/privacy

PATCH /settings/privacy

GET /settings/notifications

PATCH /settings/notifications

GET /settings/playback

PATCH /settings/playback

GET /settings/downloads

PATCH /settings/downloads

GET /settings/security

PATCH /settings/security

GET /settings/accounts

PATCH /settings/accounts

---

# Providers

settingsProvider

appearanceProvider

notificationSettingsProvider

privacySettingsProvider

playbackSettingsProvider

downloadSettingsProvider

securitySettingsProvider

accessibilityProvider

connectedAccountsProvider

---

# Componentes

GlassHeader

SettingsSidebar

SettingsSection

ToggleTile

DropdownTile

SliderTile

SettingCard

AccountCard

StorageCard

VersionCard

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Sincronizando

Indicador discreto.

---

## Offline

Editar localmente.

Sincronizar depois.

---

## Erro

Toast

```
Não foi possível salvar.
```

Botão

Tentar novamente.

---

# Motion

Fade

Slide

Scale

Spring

Shared Transition

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Sidebar flutuante

Toolbar

Bottom Navigation

Dialogs

Floating Save Indicator

Nunca aplicar em

Cards

Inputs

Listas

Textos

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

Sidebar fixa

Painel lateral

Configurações em duas colunas

---

## Tablet

Sidebar recolhível

---

## Mobile

Lista vertical

Bottom Navigation

Safe Area

---

# Performance

Auto Save

Optimistic Update

Cache Local

Background Sync

Realtime

Lazy Loading

60 FPS

---

# Analytics

Configurações mais utilizadas

Idioma

Tema

Modo escuro

Notificações

Downloads

Dispositivos

---

# Segurança

Supabase Auth

JWT

HTTPS

OWASP Top 10

Row Level Security

Role Guard

Ownership Guard

Rate Limit

Criptografia

Logs de Auditoria

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Focus Visible

Touch Target

44x44px

Escala dinâmica

Alto contraste

---

# Psicologia de Produto

## Progressive Disclosure

Mostrar apenas as configurações necessárias.

As opções avançadas permanecem recolhidas por padrão.

---

## Calm Interface

Evitar excesso de controles visíveis.

Agrupar opções por categoria.

---

## Immediate Feedback

Toda alteração deve apresentar feedback instantâneo através de animações suaves e mensagens discretas.

---

## User Control

O usuário deve sentir que possui controle total sobre a plataforma, sem medo de alterar configurações.

---

## Consistência

Todos os switches, seletores e controles seguem exatamente o mesmo padrão visual definido pelo Lawrence Design System.

---

# Critérios de Aceitação

- Todas as configurações devem ser sincronizadas automaticamente entre Web e Android utilizando Supabase.
- As alterações devem utilizar **Auto Save**, sem necessidade de botão "Salvar".
- A página deve permitir configurar aparência, notificações, reprodução, downloads, privacidade, segurança, acessibilidade e contas conectadas.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado exclusivamente em elementos flutuantes.
- A experiência deve ser minimalista, organizada e inspirada no aplicativo Ajustes (Settings) da Apple, mantendo excelente desempenho e usabilidade em Flutter Web e Android.
