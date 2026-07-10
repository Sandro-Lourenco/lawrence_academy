---
id: PAGE-ADMIN-004
name: Students Management
route: /admin/students
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

students:
  account_management: true
  subscription_management: true
  learning_tracking: true
  payments_tracking: true
  certificates_tracking: true
  support: true
  moderation: true
---

# Students

## Objetivo

A página **Students Management** permite ao administrador gerenciar todos os alunos da Lawrence Academy.

Diferente da visão do professor, onde aparecem apenas alunos dos seus cursos, o administrador possui visão global de todos os estudantes da plataforma.

Esta tela permite acompanhar:

- Crescimento da base de alunos
- Cursos comprados
- Assinaturas mensais
- Histórico financeiro
- Engajamento
- Certificados
- Suporte
- Segurança da conta

A experiência deve ser simples, organizada e poderosa, seguindo o padrão premium do Lawrence Design System.

Inspirado em:

- Apple Business Manager
- Stripe Customers
- Netflix Account Management
- Google Admin
- Notion Database

---

# Objetivos

- Gerenciar alunos.
- Visualizar assinaturas.
- Acompanhar progresso.
- Controlar pagamentos.
- Resolver problemas.
- Analisar engajamento.
- Consultar histórico.
- Administrar contas.

---

# Fluxo

```text
Admin

↓

Students

↓

Pesquisa aluno

↓

Abre perfil

↓

Executa ação

↓

Audit Log
```

---

# Layout Desktop

```text
--------------------------------------------------

Glass Header

--------------------------------------------------

Sidebar

|

Students Overview

|

Students Table

|

Student Detail Panel

--------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Resumo

↓

Lista Alunos

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

Students Overview

↓

Search

↓

Filters

↓

Students List

↓

Student Profile

↓

Subscriptions

↓

Courses

↓

Payments

↓

Progress

↓

Security

↓

Support
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

# Students Overview

Cards superiores.

Mostrar:

- Total de alunos
- Novos alunos
- Alunos ativos
- Alunos inativos
- Assinantes
- Cancelamentos

---

Exemplo:

```text
120.500 alunos

98.400 ativos

15.200 assinaturas
```

---

# Search

Pesquisa global.

Buscar por:

- Nome
- Email
- ID
- Curso
- Professor
- Pagamento

---

Recursos:

Autocomplete

Debounce 300ms

Histórico

---

# Filters

Disponíveis:

Todos

Ativos

Inativos

Novos

Assinantes

Cancelados

Bloqueados

---

Avançados:

Curso

Professor

Data cadastro

Valor gasto

Último acesso

Progresso

---

# Students Table

Desktop.

Colunas:

Foto

Nome

Email

Cursos

Assinaturas

Valor gasto

Status

Último acesso

---

Mobile:

Student Cards

---

# Student Card

Exemplo:

```text
Maria Oliveira

3 cursos

R$209,70/mês

Ativo

Hoje
```

---

# Student Profile

Informações:

Foto

Nome

Email

Telefone

Data cadastro

Status

Última atividade

---

# Courses

Todos os cursos adquiridos.

Mostrar:

Curso

Professor

Status

Progresso

Data início

---

Exemplo:

```text
Alta Costura Premium

Professor: Ariane

82% concluído
```

---

# Subscriptions

Como cada curso possui assinatura separada.

Mostrar:

```text
Curso:

Modelagem Feminina

Plano:

Mensal

Valor:

R$59,90/mês

Status:

Ativo
```

---

Estados:

Ativa

Cancelada

Pagamento atrasado

Expirada

Reembolso

---

# Payments

Histórico financeiro.

Mostrar:

Data

Curso

Valor

Método

Status

Transação

---

Status:

Pago

Pendente

Falhou

Reembolsado

---

# Learning Progress

Acompanhamento.

Mostrar:

Cursos iniciados

Cursos concluídos

Aulas assistidas

Atividades entregues

Certificados

Horas estudadas

---

# Activity Timeline

Linha do tempo.

Eventos:

Cadastro

Compra

Login

Aula assistida

Atividade enviada

Certificado emitido

Cancelamento

---

# Certificates

Mostrar:

Curso

Código

Data emissão

Validade

Download

---

# Support

Histórico:

Tickets

Mensagens

Reclamações

Solicitações

Reembolsos

---

# Account Actions

Administrador pode:

Alterar dados

Resetar senha

Bloquear conta

Liberar acesso

Cancelar assinatura

Emitir reembolso

Enviar mensagem

---

# Security

Mostrar:

Últimos logins

Dispositivos

Sessões

IP

2FA

---

Ações:

Encerrar sessão

Bloquear dispositivo

Forçar troca senha

---

# Risk Detection

Identificar:

Possível abandono

Problemas pagamento

Baixo engajamento

Muitos cancelamentos

---

# AI Insights (Future)

Exemplo:

```text
Aluno possui alta chance de cancelar.

Motivo:

14 dias sem acessar.
```

---

# Audit Log

Registrar:

Admin

Aluno

Ação

Data

IP

Alteração

---

# APIs

GET /admin/students

GET /admin/students/{id}

PATCH /admin/students/{id}

GET /admin/students/{id}/courses

GET /admin/students/{id}/subscriptions

GET /admin/students/{id}/payments

GET /admin/students/{id}/progress

GET /admin/students/{id}/certificates

GET /admin/students/{id}/security

POST /admin/students/{id}/action

---

# Providers

studentsProvider

studentDetailProvider

studentCoursesProvider

studentSubscriptionProvider

studentPaymentProvider

studentProgressProvider

studentSecurityProvider

auditProvider

---

# Componentes

GlassHeader

StudentsOverviewCard

StudentTable

StudentCard

StudentProfile

SubscriptionCard

PaymentHistory

ProgressChart

CertificateCard

ActivityTimeline

SecurityPanel

SupportPanel

ConfirmDialog

Toast

SkeletonLoader

---

# Estados

## Loading

Skeleton Apple Style

---

## Sem alunos

```text
Nenhum aluno encontrado.
```

---

## Aluno ativo

Badge verde.

---

## Pagamento atrasado

Badge amarelo.

---

## Bloqueado

Badge vermelho.

---

# Motion

Fade

Slide

Scale

Spring

Blur

Counter Animation

Skeleton

---

# Liquid Glass

Aplicar apenas em:

- Glass Header
- Search
- Filters
- Dialogs
- Action Menu

Nunca aplicar em:

- Dados financeiros
- Histórico
- Tabelas
- Métricas

---

# Responsividade

## Desktop

Tabela completa.

Painel lateral.

---

## Tablet

Layout híbrido.

---

## Mobile

Cards.

Detalhes em tela dedicada.

Bottom Navigation.

---

# Performance

Realtime

Pagination

Virtual Scroll

Cache

Lazy Loading

Background Refresh

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

## Clareza

Encontrar qualquer aluno deve ser instantâneo.

---

## Controle

O administrador precisa entender toda a jornada do aluno.

---

## Segurança

Toda ação sensível deve gerar registro.

---

## Suporte

A tela deve permitir resolver problemas rapidamente sem trocar de módulo.

---

# Critérios de Aceitação

- O administrador deve visualizar todos os alunos da plataforma.
- Deve acompanhar cursos, progresso e certificados.
- Deve respeitar o modelo onde cada curso possui sua própria assinatura mensal.
- Deve mostrar pagamentos e histórico financeiro.
- Deve permitir ações administrativas seguras.
- Todas alterações críticas precisam gerar Audit Log.
- Deve utilizar Supabase Auth + RLS + RBAC.
- A interface deve seguir o Lawrence Design System.
- Liquid Glass deve aparecer apenas em elementos flutuantes.
- Experiência inspirada em Apple Business Manager + Stripe Customers.