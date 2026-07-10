---
id: PAGE-ADMIN-002
name: Users Management
route: /admin/users
layout: AdminDashboardLayout
platforms:
  - Web
  - Android
roles:
  - Admin
authentication: true
responsive: true
status: Production
design-system: Lawrence Design System
navigation: Sidebar + Top Navigation
state-management: Riverpod
architecture: Clean Architecture + DDD
real-time: Supabase Realtime

users:
  students_management: true
  teachers_management: true
  admins_management: true
  permissions: true
  roles: true
  audit: true
  security: true
---

# Users

## Objetivo

A página **Users Management** é responsável pelo gerenciamento completo de usuários da Lawrence Academy.

Ela permite ao administrador controlar alunos, professores e outros administradores, visualizar histórico, permissões, assinaturas, segurança da conta e atividades dentro da plataforma.

A experiência deve ser semelhante a um painel corporativo premium: simples, rápido e seguro.

Inspirado em:

- Apple Business Manager
- Google Admin Console
- Stripe Customers
- Linear Admin
- Notion Workspace Members

---

# Objetivos

- Gerenciar usuários.
- Criar usuários.
- Editar contas.
- Controlar permissões.
- Alterar papéis.
- Ver histórico.
- Analisar atividade.
- Suspender contas.
- Garantir segurança.

---

# Fluxo

```text
Admin

↓

Users

↓

Pesquisa usuário

↓

Abre perfil

↓

Executa ação administrativa

↓

Audit Log registrado
```

---

# Layout Desktop

```text
------------------------------------------------------

Glass Header

------------------------------------------------------

Sidebar

|

Users Overview

|

Users Table

|

User Detail Panel

------------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Resumo

↓

Pesquisa

↓

Usuários

↓

Detalhes

↓

Bottom Navigation
```

---

# Estrutura

```text
Glass Header

↓

Users Overview

↓

Search

↓

Filters

↓

Users Table

↓

User Profile

↓

Permissions

↓

Subscriptions

↓

Activity Logs

↓

Security
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur 20px

Opacity 72%

Contém:

- Pesquisa global
- Notificações
- Perfil Admin

---

# Users Overview

Cards superiores.

Mostrar:

- Total usuários
- Alunos
- Professores
- Administradores
- Usuários ativos
- Bloqueados

---

Exemplo:

```text
125.450 usuários

118.000 alunos

430 professores

12 admins
```

---

# Search

Pesquisa instantânea.

Buscar por:

- Nome
- Email
- ID
- Telefone
- Curso
- Professor

---

Características:

Debounce

300ms

Autocomplete

---

# Filters

Filtros:

Todos

Alunos

Professores

Administradores

Ativos

Bloqueados

Pendentes

Verificados

---

Avançados:

Data cadastro

Último acesso

Assinatura

Curso

Status pagamento

---

# Users Table

Desktop.

Colunas:

Foto

Nome

Email

Role

Status

Cursos

Assinaturas

Criado em

Último acesso

---

Mobile:

User Cards

---

# User Card

Mostrar:

Avatar

Nome

Tipo

Status

Última atividade

---

Exemplo:

```text
Maria Silva

Student

Ativo

Online há 2 horas
```

---

# Roles

Papéis:

## Student

Permissões:

Assistir cursos

Enviar atividades

Comprar assinatura

Participar lives

---

## Teacher

Permissões:

Criar cursos

Gerenciar alunos

Criar lives

Ver analytics

Receber pagamentos

---

## Admin

Permissões:

Controle total

Usuários

Financeiro

Configurações

Auditoria

---

# User Detail

Painel lateral.

Mostrar:

Foto

Nome

Email

Role

Status

Criado em

Último login

---

# Profile Information

Campos:

Nome

Email

Telefone

Idioma

Localização

Timezone

---

# Account Status

Estados:

Ativo

Suspenso

Bloqueado

Excluído

Pendente

---

Ações:

Ativar

Suspender

Resetar senha

Forçar logout

---

# Permissions

Controle RBAC.

Mostrar:

Role atual

Permissões

Grupos

Políticas

---

Alterações exigem:

Confirmação

Registro Audit Log

---

# Student Data

Quando usuário é aluno.

Mostrar:

Cursos comprados

Assinaturas

Progresso

Certificados

Atividades

Pagamentos

---

# Teacher Data

Quando usuário é professor.

Mostrar:

Cursos publicados

Alunos

Receita

Avaliação

Documentação

Status verificação

---

# Subscriptions

Como cada curso possui assinatura própria.

Mostrar:

```text
Modelagem Feminina

Ativo

R$59,90/mês


Alta Costura

Cancelado

R$89,90/mês
```

---

# Payments

Histórico:

Data

Valor

Curso

Status

Método

---

# Activity Timeline

Registrar:

Login

Compra

Curso iniciado

Aula assistida

Alteração perfil

Ação administrativa

---

# Security

Mostrar:

Últimos acessos

Dispositivos

IP

Sessões

2FA

---

Ações:

Encerrar sessão

Exigir troca senha

Bloquear conta

---

# Audit Log

Toda alteração administrativa gera:

Admin responsável

Usuário afetado

Ação

Antes

Depois

Data

IP

---

# Bulk Actions

Selecionar vários.

Ações:

Exportar

Alterar status

Enviar aviso

Adicionar tag

---

# APIs

GET /admin/users

GET /admin/users/{id}

POST /admin/users

PATCH /admin/users/{id}

PATCH /admin/users/{id}/role

PATCH /admin/users/{id}/status

GET /admin/users/{id}/activity

GET /admin/users/{id}/security

GET /admin/users/{id}/subscriptions

GET /admin/users/{id}/audit

---

# Providers

usersProvider

userDetailProvider

roleProvider

permissionProvider

securityProvider

activityProvider

auditProvider

subscriptionProvider

---

# Componentes

GlassHeader

UsersOverviewCard

UserTable

UserCard

UserDetailPanel

RoleManager

PermissionEditor

SubscriptionList

ActivityTimeline

SecurityPanel

AuditLog

ConfirmDialog

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style

---

## Sem usuários

```text
Nenhum usuário encontrado.
```

---

## Usuário bloqueado

Badge vermelho.

---

## Usuário ativo

Badge verde.

---

## Alteração crítica

Solicitar confirmação.

---

# Motion

Fade

Slide

Scale

Spring

Blur

Shared Transition

Skeleton

---

# Liquid Glass

Aplicar apenas em:

- Glass Header
- Search Floating
- Filters
- Dialogs
- Action Menu

Nunca aplicar em:

- Tabelas
- Dados sensíveis
- Métricas
- Histórico

---

# Responsividade

## Desktop

Tabela completa.

Painel lateral.

---

## Tablet

Tabela compacta.

---

## Mobile

Cards.

Detalhes em página separada.

Bottom Navigation.

---

# Performance

Pagination

Virtual Scroll

Realtime

Cache

Lazy Loading

Optimistic Update

60 FPS

---

# Segurança

Supabase Auth

JWT

HTTPS

Row Level Security

Admin Guard

RBAC

2FA

Audit Logs

Rate Limit

Session Control

Encryption

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

## Segurança

Toda ação crítica precisa gerar confiança e confirmação.

---

## Clareza

O administrador deve encontrar qualquer usuário em segundos.

---

## Controle

Alterações importantes sempre deixam histórico.

---

## Simplicidade

Gerenciar milhares de usuários deve parecer simples como gerenciar contatos.

---

# Critérios de Aceitação

- O administrador deve gerenciar alunos, professores e administradores.
- Deve existir controle completo por roles e permissões.
- Toda alteração crítica deve gerar Audit Log.
- Deve mostrar cursos e assinaturas individuais dos alunos.
- Deve mostrar desempenho e receita dos professores.
- Deve possuir busca instantânea e filtros avançados.
- Deve utilizar Supabase Auth + RLS + RBAC.
- A interface deve seguir o Lawrence Design System.
- Liquid Glass somente em elementos flutuantes.
- A experiência deve ser inspirada no Apple Business Manager.