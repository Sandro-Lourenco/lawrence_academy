---
id: PAGE-ADMIN-010
name: Roles & Permissions
route: /admin/roles
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

roles:
  rbac: true
  permissions: true
  custom_roles: true
  hierarchy: true
  access_control: true
  audit: true
  security_level: critical
---

# Roles

## Objetivo

A página **Roles & Permissions** é responsável por controlar todas as permissões e níveis de acesso dentro da Lawrence Academy.

Ela implementa o modelo:

**RBAC — Role Based Access Control**

Ou seja:

Usuários não recebem permissões diretamente.

Eles recebem papéis (Roles), e cada papel possui permissões específicas.

A página garante:

- Segurança
- Separação de responsabilidades
- Controle administrativo
- Escalabilidade da plataforma

Inspirado em:

- Apple Business Manager
- GitHub Organizations
- Google Workspace Admin
- AWS IAM
- Linear Workspace

---

# Objetivos

- Criar papéis.
- Editar permissões.
- Controlar acessos.
- Criar roles customizadas.
- Gerenciar privilégios.
- Auditar mudanças.
- Proteger recursos críticos.

---

# Modelo Principal

```text
USER

↓

ROLE

↓

PERMISSIONS

↓

RESOURCE
```

---

# Roles Base

A plataforma possui inicialmente:

```text
SUPER_ADMIN

ADMIN

TEACHER

STUDENT

SUPPORT

FINANCE
```

---

# Hierarquia

```text
Super Admin

        ↓

Admin

        ↓

Teacher

        ↓

Student
```

---

# Layout Desktop

```text
------------------------------------------------

Glass Header

------------------------------------------------

Sidebar

|

Roles List

|

Permission Matrix

|

Users Assigned

------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Roles

↓

Permissões

↓

Usuários

↓

Bottom Navigation
```

---

# Estrutura

```text
Glass Header

↓

Roles Overview

↓

Roles List

↓

Role Detail

↓

Permission Matrix

↓

Assigned Users

↓

Audit Logs
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur 20px

Opacity 72%

---

# Roles Overview

Mostrar:

- Total roles
- Usuários administradores
- Permissões existentes
- Alterações recentes

---

Exemplo:

```text
6 Roles

15 Admin Users

128 Permissions
```

---

# Default Roles

## SUPER_ADMIN

Controle completo.

Permissões:

```text
*
```

Pode:

- Gerenciar admins
- Alterar permissões
- Configurar plataforma
- Financeiro total
- Segurança

---

# ADMIN

Gerencia operação.

Pode:

- Usuários
- Cursos
- Professores
- Categorias
- Relatórios
- Suporte

Não pode:

- Excluir Super Admin
- Alterar permissões críticas

---

# TEACHER

Criador de conteúdo.

Pode:

- Criar cursos
- Criar aulas
- Upload vídeos
- Corrigir atividades
- Ver alunos
- Ver receita própria

---

Não pode:

- Ver dados de outros professores
- Alterar pagamentos globais

---

# STUDENT

Aluno.

Pode:

- Comprar cursos
- Assistir aulas
- Enviar atividades
- Baixar materiais
- Participar lives

---

# SUPPORT

Equipe suporte.

Pode:

- Visualizar usuários
- Abrir tickets
- Resolver problemas

Não pode:

- Alterar financeiro
- Alterar permissões

---

# FINANCE

Equipe financeira.

Pode:

- Pagamentos
- Reembolsos
- Relatórios financeiros
- Repasses

Não pode:

- Editar cursos
- Alterar usuários críticos

---

# Permission System

Formato:

```text
resource.action
```

---

Exemplos:

```text
users.create

users.update

users.delete


courses.approve

courses.delete


payments.refund


roles.update
```

---

# Permission Categories

## Users

Permissões:

create

read

update

delete

ban

---

## Courses

create

approve

publish

delete

moderate

---

## Payments

view

refund

export

modify

---

## Reports

view

generate

export

---

## System

settings

security

audit

roles

---

# Permission Matrix

Tabela:

```text
              Admin Teacher Student

Users            ✓      -       -

Courses          ✓      ✓       -

Lessons          ✓      ✓       ✓

Payments         ✓      -       -

Reports          ✓      ✓       -
```

---

# Criar Role

Campos:

Nome

Descrição

Nível

Permissões

Usuários

Status

---

Exemplo:

```text
Role:

Course Reviewer


Permissões:

courses.read

courses.approve
```

---

# Assigned Users

Mostrar:

Usuário

Role

Data atribuída

Quem atribuiu

---

Ações:

Adicionar usuário

Remover

Alterar role

---

# Security Rules

Proteções:

SUPER_ADMIN não pode ser removido.

Sistema deve sempre possuir pelo menos 1 SUPER_ADMIN.

Usuário não pode remover sua própria permissão crítica.

---

# Critical Actions

Exigir confirmação:

Alterar Admin

Remover Role

Dar permissão financeira

Excluir Role

---

# Audit Logs

Toda mudança registra:

Quem alterou

Role alterada

Permissão

Antes

Depois

Data

IP

---

Exemplo:

```text
Admin João

adicionou:

payments.refund

para:

Finance
```

---

# APIs

GET /admin/roles

GET /admin/roles/{id}

POST /admin/roles

PATCH /admin/roles/{id}

DELETE /admin/roles/{id}

GET /admin/permissions

PATCH /admin/roles/{id}/permissions

POST /admin/users/{id}/role

GET /admin/roles/audit

---

# Providers

rolesProvider

roleDetailProvider

permissionProvider

permissionMatrixProvider

assignedUsersProvider

roleAuditProvider

---

# Componentes

GlassHeader

RolesOverviewCard

RolesList

RoleCard

PermissionMatrix

PermissionSwitch

AssignedUsersTable

RoleEditor

ConfirmDialog

AuditTimeline

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style

---

## Role protegida

Mostrar:

```text
Esta role não pode ser removida.
```

---

## Permissão crítica

Solicitar confirmação.

---

## Atualizado

Toast:

```text
Permissões atualizadas.
```

---

# Motion

Fade

Slide

Scale

Spring

Switch Animation

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em:

- Glass Header
- Permission Dialog
- Confirmation Modal
- Floating Actions

Nunca aplicar em:

- Permission Matrix
- Dados sensíveis
- Tabelas

---

# Responsividade

## Desktop

Lista roles esquerda.

Matriz central.

Usuários direita.

---

## Tablet

Painéis recolhíveis.

---

## Mobile

Fluxo:

1. Escolher Role

2. Editar Permissões

3. Salvar

---

# Performance

Realtime

Cache

Optimistic Update

Lazy Loading

Virtual Scroll

60 FPS

---

# Segurança

Supabase Auth

JWT

HTTPS

Row Level Security

RBAC

Policies

2FA obrigatório para Admin

Audit Logs

Encryption

---

# Banco de Dados

## roles

Campos:

id

name

description

level

created_at

---

## permissions

Campos:

id

resource

action

---

## role_permissions

Campos:

role_id

permission_id

---

## user_roles

Campos:

user_id

role_id

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

Permissões devem evitar erros humanos.

---

## Simplicidade

Gerenciar acesso deve ser visual.

---

## Controle

Toda mudança precisa ser rastreável.

---

## Confiança

Usuário entende exatamente o impacto da permissão.

---

# Critérios de Aceitação

- Sistema deve implementar RBAC completo.
- Usuários recebem roles, não permissões diretas.
- Deve existir hierarquia de acesso.
- Deve permitir roles personalizadas.
- Deve possuir matriz visual de permissões.
- Alterações críticas precisam de confirmação.
- Toda mudança gera Audit Log.
- Deve proteger Super Admin.
- Deve utilizar Supabase Auth + RLS Policies.
- Interface segue Lawrence Design System.
- Liquid Glass somente em elementos flutuantes.
- Experiência inspirada em AWS IAM, GitHub Organizations e Apple Business Manager.