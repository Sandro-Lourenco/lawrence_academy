---
id: PAGE-STUDENT-012
name: Profile
route: /dashboard/profile
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

# Profile

## Implementação canônica da fase de Perfil

A rota `/dashboard/profile` consome o use case `GetMyProfileUseCase`, apoiado
por `GET /api/v1/profiles/me`, e apresenta somente nome, e-mail e papel
confirmados. O backend possui essa rota e testes, embora `SERVICE_API.md` ainda
cite `/users/me`; essa divergência documental deve ser reconciliada.

Métricas de aprendizagem, avatar, nível, dispositivos, 2FA, edição e exclusão
não são simulados. A tela oferece navegação apenas para assinaturas, faturas e
configurações já implementadas.

## Objetivo

A página **Profile** representa a identidade do aluno dentro da Lawrence Academy.

Ela vai muito além de um formulário de dados pessoais.

É o centro de identidade, evolução, configurações da conta e personalização da experiência.

Toda a interface deve transmitir:

- elegância
- confiança
- simplicidade
- exclusividade
- profissionalismo

Inspirada em:

- Apple ID
- Apple Fitness
- Apple Music
- Notion Settings
- Linear
- Arc Browser
- Stripe Dashboard

---

# Objetivos

- Gerenciar dados pessoais.
- Editar perfil.
- Gerenciar assinatura.
- Configurar preferências.
- Configurar notificações.
- Alterar senha.
- Gerenciar dispositivos.
- Visualizar estatísticas.
- Exibir conquistas.

---

# Fluxo

```
Aluno

↓

Perfil

↓

Editar Dados

↓

Salvar

↓

Sincronização

↓

Supabase

↓

Atualização em todos dispositivos
```

---

# Layout Desktop

```
---------------------------------------------------------------

Glass Header

---------------------------------------------------------------

Sidebar

|

|

Profile Hero

|

Informações

|

Estatísticas

|

Configurações

|

Segurança

---------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Avatar

↓

Resumo

↓

Configurações

↓

Segurança

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Profile Hero

↓

Personal Information

↓

Learning Statistics

↓

Achievements

↓

Subscription

↓

Security

↓

Devices

↓

Preferences

↓

Danger Zone
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

Notificações

Avatar

---

# Profile Hero

Área principal.

Mostrar

Foto

Nome

Email

Plano

Membro desde

Nível

---

Exemplo

```
Sandro Calebe

Aluno Premium

Membro desde Maio de 2026

Nível 18
```

---

Avatar grande.

120px.

Círculo.

Botão

Alterar foto.

---

# Learning Statistics

Cards.

Mostrar

Cursos concluídos

Cursos iniciados

Horas estudadas

Certificados

Dias consecutivos

Maior sequência

---

Exemplo

```
Cursos

18

↓

Horas

126h

↓

Certificados

8

↓

Streak

29 dias
```

---

# Progress Overview

Barra de progresso.

Mostrar

Objetivo anual.

Exemplo

```
72%

Meta anual de aprendizado.
```

---

# Personal Information

Campos

Nome

Sobrenome

Email

Telefone

Data nascimento

Cidade

Estado

País

Idioma

Fuso horário

Biografia

---

Campos somente leitura

ID

Data cadastro

Último acesso

---

# Avatar

Upload

Crop

Preview

Compressão

---

Formatos

PNG

JPEG

WEBP

---

Máximo

5MB

---

# Subscription

Mostrar

Plano atual

Status

Renovação

Pagamento

Histórico

---

Botões

Gerenciar assinatura

Atualizar plano

Cancelar assinatura

---

# Learning Preferences

Configurações

Idioma

Tema

Velocidade padrão do vídeo

Legenda

Autoplay

Qualidade padrão

Downloads automáticos

---

# Appearance

Modo

Claro

Escuro

Sistema

---

Accent Color

(opcional futuro)

---

# Accessibility

Configurações

Fonte maior

Contraste

Motion Reduction

Legendas

Leitor de tela

---

# Security

Mostrar

Senha

Última alteração

Autenticação em dois fatores

Sessões ativas

Dispositivos

---

Botões

Alterar senha

Ativar 2FA

Encerrar outras sessões

---

# Devices

Lista

Desktop

Android

Tablet

---

Mostrar

Modelo

Sistema

Último acesso

IP

Cidade

---

Botão

Desconectar dispositivo

---

# Notifications

Configurações

Push

Email

SMS (futuro)

Marketing

Professor

Cursos

Lives

Sistema

---

# Privacy

Permissões

Perfil público

Ranking

Compartilhar certificados

Compartilhar progresso

---

# Achievements

Mostrar

Badges

Conquistas

Certificados

Níveis

Medalhas

---

Grid.

---

# Danger Zone

Área isolada.

Fundo suave.

Mostrar

Excluir conta

Solicitar exportação de dados

Desativar conta

---

Sempre solicitar confirmação.

---

# APIs

GET /profile

PATCH /profile

POST /profile/avatar

DELETE /profile/avatar

GET /profile/statistics

GET /profile/preferences

PATCH /profile/preferences

GET /profile/devices

DELETE /profile/devices/{id}

POST /profile/change-password

POST /profile/enable-2fa

DELETE /profile/account

---

# Providers

profileProvider

profileStatisticsProvider

preferencesProvider

securityProvider

devicesProvider

subscriptionProvider

achievementProvider

---

# Componentes

GlassHeader

ProfileHero

AvatarUploader

StatisticsCard

ProgressCard

ProfileForm

SubscriptionCard

SecurityCard

DevicesCard

PreferenceCard

AchievementGrid

DangerZoneCard

SkeletonLoader

---

# Estados

## Loading

Skeleton Apple Style.

---

## Offline

Mostrar cache.

Editar quando reconectar.

---

## Erro

Mensagem amigável.

Botão

Tentar novamente.

---

## Atualização

Toast

```
Perfil atualizado com sucesso.
```

---

# Motion

Fade

Scale

Hero Animation

Shared Transition

Spring

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Floating Save Button

Bottom Navigation

Dialogs

Floating Toolbar

Nunca aplicar em

Cards principais

Inputs

Textos

Estatísticas

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

Sidebar fixa.

Grid de estatísticas.

Formulário em duas colunas.

---

## Tablet

Grid reduzido.

---

## Mobile

Cards empilhados.

Avatar centralizado.

Bottom Navigation.

Safe Area.

---

# Performance

Lazy Loading

Image Compression

Image Cache

Optimistic Update

Background Sync

Skeleton Loading

60 FPS

---

# Analytics

Perfil atualizado

Avatar alterado

Plano atualizado

2FA ativado

Dispositivos conectados

Preferências alteradas

---

# Segurança

Supabase Auth

JWT

HTTPS

OWASP Top 10

Role Guard

Ownership Guard

RLS

Upload seguro

Validação de imagem

2FA

Sessões monitoradas

Logs de auditoria

Proteção contra CSRF

Rate Limit

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

Redução de movimento

---

# Psicologia de Produto

## Identity

O perfil deve transmitir pertencimento.

O aluno deve sentir que possui um espaço pessoal dentro da plataforma.

---

## Progress Principle

Mostrar sempre a evolução.

Horas.

Cursos.

Certificados.

Sequências.

Conquistas.

---

## Personal Ownership

Permitir personalização suficiente para criar identificação sem aumentar a complexidade.

---

## Positive Reinforcement

Sempre destacar conquistas antes das configurações.

O topo da página deve celebrar o progresso do aluno.

---

## Trust

Toda ação crítica (senha, dispositivos, exclusão da conta) deve transmitir segurança, clareza e controle.

---

# Critérios de Aceitação

- O aluno deve conseguir editar seus dados pessoais, foto, preferências e configurações de segurança.
- O sistema deve sincronizar automaticamente todas as alterações utilizando Supabase.
- A página deve apresentar estatísticas de aprendizado, conquistas, certificados e informações da assinatura.
- Deve ser possível gerenciar dispositivos conectados, autenticação em dois fatores e privacidade da conta.
- O layout deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado exclusivamente em elementos flutuantes.
- A experiência deve ser minimalista, elegante e inspirada nos aplicativos da Apple, priorizando clareza, organização e sensação de produto premium.
