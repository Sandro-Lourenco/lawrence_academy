---
id: PAGE-ADMIN-011
name: Platform Settings
route: /admin/settings
layout: AdminDashboardLayout
platforms:
  - Web
  - Android
roles:
  - Super Admin
authentication: true
responsive: true
status: Production
design-system: Lawrence Design System
navigation: Sidebar + Top Navigation
state-management: Riverpod
architecture: Clean Architecture + DDD
real-time: Supabase Realtime

settings:
  platform_configuration: true
  branding: true
  security: true
  payments: true
  notifications: true
  storage: true
  integrations: true
  maintenance: true
  audit: true
---

# Settings

## Objetivo

A página **Settings** é o centro de configuração global da Lawrence Academy.

Ela controla parâmetros críticos da plataforma:

- Identidade visual
- Segurança
- Autenticação
- Pagamentos
- Armazenamento
- Vídeos
- Emails
- Notificações
- Integrações
- Regras de negócio

Apenas administradores autorizados podem acessar.

Inspirado em:

- Apple Settings
- Vercel Settings
- Stripe Settings
- GitHub Organization Settings
- Supabase Dashboard

---

# Objetivos

- Configurar plataforma.
- Controlar segurança.
- Ajustar regras.
- Gerenciar integrações.
- Configurar pagamentos.
- Personalizar marca.
- Monitorar recursos.

---

# Fluxo

```text
Super Admin

↓

Settings

↓

Seleciona categoria

↓

Altera configuração

↓

Confirma

↓

Audit Log
```

---

# Layout Desktop

```text
-------------------------------------------------

Glass Header

-------------------------------------------------

Sidebar

|

Settings Menu

|

Configuration Panel

-------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Categorias

↓

Configuração

↓

Salvar
```

---

# Estrutura

```text
Glass Header

↓

General Settings

↓

Brand Settings

↓

Security

↓

Authentication

↓

Payments

↓

Storage

↓

Video

↓

Notifications

↓

Integrations

↓

System
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur 20px

Opacity 72%

---

# General Settings

Configurações básicas.

Campos:

Nome plataforma

Descrição

URL principal

Idioma padrão

Timezone

País

Moeda

---

Exemplo:

```text
Platform:

Lawrence Academy

Currency:

BRL
```

---

# Branding Settings

Personalização visual.

Campos:

Logo

Ícone

Favicon

Cores

Tema

Fonte

---

Configura:

Primary Color

Secondary Color

Accent Color

---

Mantém:

Lawrence Design System

60-30-10

Liquid Glass

---

# Theme

Controle:

Light Mode

Dark Mode

System Mode

---

# Authentication

Gerenciado por:

Supabase Auth

---

Configurações:

Email login

Google Login

Apple Login

Magic Link

2FA

Reset Password

Email Verification

---

# User Rules

Configurar:

Cadastro aberto

Aprovação professores

Verificação email

Sessões simultâneas

Tempo sessão

---

# Security Settings

Controle:

2FA obrigatório Admin

Rate Limit

Bloqueio IP

Tentativas login

JWT Expiration

Device Management

---

Exemplo:

```text
Admin 2FA

Required
```

---

# Roles Settings

Atalho para:

Roles

Permissions

RBAC

Policies

---

# Payment Settings

Configurar gateways.

Suporte:

Stripe

Mercado Pago

Pagar.me

Google Pay

Apple Pay

---

Configurar:

Moeda

Taxas

Comissão plataforma

Repasses

---

Exemplo:

```text
Professor

70%

Plataforma

30%
```

---

# Subscription Rules

Como o modelo é:

Cada curso possui sua assinatura.

Configurar:

Período cobrança

Trial

Cancelamento

Reembolso

Dias tolerância

---

# Storage Settings

Base:

Supabase Storage

---

Configurar:

Limite upload

Tamanho máximo

CDN

Cache

Backups

---

# Video Settings

Controle:

Upload

HLS

Criptografia

Processamento

---

Configurações:

Qualidades:

240p

360p

720p

1080p

---

HLS Encryption:

AES-128

---

# Email Settings

Configurar:

SMTP

Templates

Domínio

Assinatura

---

Templates:

Boas-vindas

Compra

Certificado

Reset senha

Pagamento

---

# Notification Settings

Canais:

Push

Email

In App

SMS (Future)

---

Eventos:

Nova aula

Live

Pagamento

Certificado

Mensagem

---

# Integrations

Gerenciar:

Supabase

Stripe

Mercado Pago

Google Analytics

Firebase

Sentry

Storage

CDN

---

Cada integração:

Status

Chave API

Logs

Último Sync

---

# Maintenance Mode

Permitir ativar:

```text
Sistema em manutenção
```

---

Opções:

Mensagem

Tempo previsto

Bloquear login

Permitir admins

---

# Backup Settings

Controle:

Banco

Storage

Configurações

---

Frequência:

Diário

Semanal

Mensal

---

# System Information

Mostrar:

API Version

Flutter Version

Python Version

Database

Storage Usage

Último deploy

---

# Danger Zone

Área crítica.

Ações:

Reset plataforma

Apagar dados

Desativar sistema

---

Sempre exigir:

Senha

2FA

Confirmação

---

# APIs

GET /admin/settings

PATCH /admin/settings


GET /admin/settings/security

PATCH /admin/settings/security


GET /admin/settings/payments

PATCH /admin/settings/payments


GET /admin/settings/integrations

PATCH /admin/settings/integrations


GET /admin/settings/system

---

# Providers

settingsProvider

generalSettingsProvider

brandProvider

securityProvider

paymentSettingsProvider

storageProvider

integrationProvider

systemProvider

---

# Componentes

GlassHeader

SettingsMenu

SettingSection

ToggleSetting

InputSetting

BrandUploader

IntegrationCard

SecurityCard

PaymentConfig

DangerZone

ConfirmDialog

Toast

SkeletonLoader

---

# Estados

## Loading

Skeleton Apple Style

---

## Salvando

Mostrar:

```text
Salvando alterações...
```

---

## Atualizado

Toast:

```text
Configurações atualizadas.
```

---

## Alteração crítica

Solicitar:

Senha

2FA

Confirmação

---

# Motion

Fade

Slide

Scale

Spring

Toggle Animation

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em:

- Glass Header
- Dialogs
- Confirmation Modal
- Floating Save Bar

Nunca aplicar em:

- Inputs
- Configurações críticas
- Dados sensíveis

---

# Responsividade

## Desktop

Menu lateral.

Painel principal.

---

## Tablet

Menu recolhível.

---

## Mobile

Lista estilo Apple Settings.

Navegação por páginas.

---

# Performance

Cache

Realtime Config

Lazy Loading

Optimistic Update

60 FPS

---

# Segurança

Supabase Auth

JWT

HTTPS

Admin Guard

Super Admin Guard

RBAC

RLS Policies

2FA

Audit Logs

Encryption

---

# Banco de Dados

Tabela:

platform_settings


Campos:

id

key

value

category

updated_by

updated_at

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Touch Target 44px

Focus Visible

Alto contraste

---

# Psicologia de Produto

## Controle

Configurações complexas devem parecer simples.

---

## Segurança

Ações perigosas devem criar fricção proposital.

---

## Confiança

Toda mudança deve ser rastreável.

---

## Familiaridade

Experiência semelhante ao aplicativo Ajustes da Apple.

---

# Critérios de Aceitação

- Somente Super Admin pode alterar configurações críticas.
- Deve existir gerenciamento global da plataforma.
- Deve configurar autenticação, pagamentos, vídeos e storage.
- Deve respeitar assinatura mensal individual por curso.
- Deve integrar Supabase Auth, Storage e Realtime.
- Alterações críticas exigem confirmação e 2FA.
- Toda alteração gera Audit Log.
- Deve seguir Lawrence Design System.
- Liquid Glass somente em elementos flutuantes.
- Experiência inspirada no Apple Settings, Stripe e Supabase Dashboard.