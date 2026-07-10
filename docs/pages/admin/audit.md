---
id: PAGE-ADMIN-009
name: Audit Logs
route: /admin/audit
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

audit:
  immutable_logs: true
  security_events: true
  financial_events: true
  user_tracking: true
  admin_actions: true
  compliance: true
  export: true
---

# Audit

## Objetivo

A página **Audit Logs** é responsável por registrar, consultar e monitorar todas as ações importantes realizadas dentro da Lawrence Academy.

Ela funciona como a "caixa preta" da plataforma.

Nenhuma alteração crítica deve acontecer sem deixar histórico.

A auditoria garante:

- Segurança
- Transparência
- Rastreabilidade
- Conformidade
- Investigação de problemas

Inspirado em:

- AWS CloudTrail
- GitHub Audit Log
- Stripe Audit Logs
- Google Admin Audit
- Apple Business Manager

---

# Objetivos

- Registrar eventos críticos.
- Rastrear alterações.
- Investigar problemas.
- Monitorar segurança.
- Identificar atividades suspeitas.
- Garantir conformidade.
- Gerar relatórios.

---

# Fluxo

```text
Usuário executa ação

↓

Sistema captura evento

↓

Cria Audit Log

↓

Armazena imutável

↓

Admin consulta
```

---

# Layout Desktop

```text
------------------------------------------------

Glass Header

------------------------------------------------

Sidebar

|

Audit Overview

|

Event Timeline

|

Event Details

------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Resumo

↓

Eventos

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

Audit Overview

↓

Filters

↓

Search

↓

Timeline

↓

Event Details

↓

Export
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur 20px

Opacity 72%

Contém:

- Pesquisa
- Exportação
- Alertas
- Admin Profile

---

# Audit Overview

Cards principais.

Mostrar:

- Eventos hoje
- Eventos críticos
- Logins suspeitos
- Alterações financeiras
- Falhas segurança

---

Exemplo:

```text
24.892 eventos

12 críticos

3 requerem atenção
```

---

# Eventos Monitorados

## Authentication

Registrar:

- Login
- Logout
- Tentativa falha
- Alteração senha
- Reset senha
- Alteração email
- Sessão encerrada

---

Exemplo:

```text
LOGIN_SUCCESS

Usuário:

Maria Silva

IP:

192.xxx.xxx
```

---

# User Events

Registrar:

- Cadastro
- Alteração perfil
- Exclusão conta
- Mudança role
- Bloqueio
- Suspensão

---

# Admin Events

Registrar:

Toda ação administrativa:

- Criar usuário
- Alterar permissões
- Aprovar professor
- Bloquear usuário
- Alterar configuração
- Editar dados sensíveis

---

Formato:

```text
Admin João

alterou

Role Maria

Student → Teacher
```

---

# Course Events

Registrar:

- Curso criado
- Curso editado
- Curso removido
- Curso aprovado
- Aula adicionada
- Vídeo alterado
- Material removido

---

# Financial Events

Obrigatório registrar:

- Pagamento aprovado
- Reembolso
- Cancelamento
- Alteração assinatura
- Alteração preço
- Repasses

---

Exemplo:

```text
SUBSCRIPTION_CANCELLED

Aluno:
Ana

Curso:
Alta Costura

Valor:
R$89,90
```

---

# Security Events

Eventos críticos:

- Muitas tentativas login
- Novo dispositivo
- IP suspeito
- Mudança permissão
- Acesso negado
- Token inválido

---

# Event Severity

## Info

Eventos comuns.

---

## Warning

Necessita atenção.

---

## Critical

Risco alto.

---

## Security

Evento de segurança.

---

# Audit Timeline

Cada registro mostra:

Ícone

Evento

Usuário

Horário

Origem

Severidade

---

Exemplo:

```text
Pagamento Alterado

por Admin Carlos

Hoje 14:32

Critical
```

---

# Event Detail

Ao abrir evento:

Mostrar:

ID

Tipo

Usuário responsável

Usuário afetado

Timestamp

IP

Dispositivo

Localização aproximada

Antes

Depois

---

# Before / After Diff

Para alterações.

Exemplo:

```diff
Nome:

- Maria

+ Maria Oliveira


Role:

- Student

+ Teacher
```

---

# Filters

Filtrar por:

Tipo evento

Usuário

Admin

Severidade

Data

IP

Módulo

---

# Search

Pesquisar:

ID

Email

Nome

Evento

Objeto alterado

---

# Export

Exportar auditoria:

PDF

CSV

XLSX

JSON

---

# Retention Policy

Guardar:

Logs segurança:

5 anos

Logs financeiros:

10 anos

Logs comuns:

2 anos

---

# Imutabilidade

Regras:

- Log nunca é editado.
- Log nunca é apagado diretamente.
- Alterações criam novos logs.
- Admin não pode modificar histórico.

---

# Alerts

Criar alerta quando:

- Muitos erros login
- Alteração financeira manual
- Admin muda permissão
- Volume anormal ações

---

# APIs

GET /admin/audit

GET /admin/audit/{id}

GET /admin/audit/search

GET /admin/audit/security

GET /admin/audit/financial

POST /admin/audit/export

GET /admin/audit/alerts

---

# Providers

auditProvider

auditSearchProvider

auditFilterProvider

securityAuditProvider

financialAuditProvider

auditExportProvider

alertProvider

---

# Componentes

GlassHeader

AuditOverviewCard

AuditTimeline

AuditEventCard

AuditDetailPanel

DiffViewer

SeverityBadge

FilterPanel

ExportDialog

SecurityAlert

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style

---

## Sem eventos

```text
Nenhum evento encontrado.
```

---

## Evento crítico

Destacar prioridade.

---

## Exportando

Mostrar progresso.

---

## Erro

Toast.

---

# Motion

Fade

Slide

Scale

Spring

Timeline Animation

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em:

- Glass Header
- Filters
- Export Dialog
- Event Modal
- Floating Actions

Nunca aplicar em:

- Logs
- Dados sensíveis
- Diferenças
- Tabelas

---

# Responsividade

## Desktop

Timeline + painel lateral.

---

## Tablet

Painel recolhível.

---

## Mobile

Timeline vertical.

Detalhe fullscreen.

---

# Performance

Virtual Scroll

Pagination

Realtime Streaming

Indexed Search

Cache

Lazy Loading

60 FPS

---

# Segurança

Supabase Auth

JWT

HTTPS

Row Level Security

Admin Guard

RBAC

2FA obrigatório

Encryption

Immutable Logs

IP Tracking

Session Tracking

---

# Banco de Dados

Tabela:

audit_logs


Campos:

id

actor_id

target_id

action

entity_type

entity_id

old_value

new_value

ip_address

device

severity

created_at

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

## Confiança

O administrador precisa saber exatamente quem fez cada ação.

---

## Transparência

Nada crítico acontece escondido.

---

## Segurança

Problemas precisam ser encontrados rapidamente.

---

## Controle

Histórico é permanente e verificável.

---

# Critérios de Aceitação

- Toda ação crítica da plataforma deve gerar Audit Log.
- Logs financeiros e administrativos devem ser imutáveis.
- Deve registrar quem fez, quando, onde e o que mudou.
- Deve existir visualização Before/After.
- Deve permitir busca avançada e exportação.
- Deve monitorar eventos suspeitos.
- Deve proteger logs contra alteração.
- Deve usar Supabase Auth + RLS + RBAC.
- Interface segue Lawrence Design System.
- Liquid Glass somente em elementos flutuantes.
- Experiência inspirada em AWS CloudTrail, Stripe e GitHub Audit Logs.