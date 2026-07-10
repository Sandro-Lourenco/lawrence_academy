---
id: PAGE-ADMIN-003
name: Teachers Management
route: /admin/teachers
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

teachers:
  approval: true
  verification: true
  courses_management: true
  revenue_tracking: true
  quality_control: true
  payouts: true
  moderation: true
---

# Teachers

## Objetivo

A página **Teachers Management** é o centro administrativo para gerenciamento dos professores da Lawrence Academy.

Ela permite que administradores acompanhem professores, aprovem novos instrutores, monitorem qualidade dos cursos, acompanhem faturamento, desempenho, avaliações, pagamentos e conformidade da plataforma.

O objetivo não é apenas listar professores, mas garantir a qualidade do ecossistema educacional.

A experiência deve seguir um padrão premium, simples e organizado.

Inspirado em:

- Apple Business Manager
- MasterClass Creator Dashboard
- YouTube Studio Partner
- Udemy Instructor Management
- Stripe Connect Dashboard
- Linear Admin

---

# Objetivos

- Gerenciar professores.
- Aprovar instrutores.
- Verificar identidade.
- Monitorar cursos.
- Analisar desempenho.
- Controlar pagamentos.
- Avaliar qualidade.
- Gerenciar permissões.

---

# Fluxo

```text
Admin

↓

Teachers

↓

Seleciona professor

↓

Analisa dados

↓

Executa ação administrativa

↓

Audit Log
```

---

# Layout Desktop

```text
----------------------------------------------------

Glass Header

----------------------------------------------------

Sidebar

|

Teachers Overview

|

Teachers Table

|

Teacher Details Panel

----------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Resumo

↓

Lista Professores

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

Teachers Overview

↓

Filters

↓

Teachers List

↓

Teacher Profile

↓

Courses

↓

Students

↓

Revenue

↓

Reviews

↓

Verification

↓

Actions
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur 20px

Opacity 72%

Contém:

- Search
- Notifications
- Admin Profile

---

# Teachers Overview

Cards superiores.

Mostrar:

- Professores cadastrados
- Professores ativos
- Novos professores
- Aguardando aprovação
- Receita gerada
- Avaliação média

---

Exemplo:

```text
430 Professores

380 ativos

24 aguardando aprovação

R$1.2M gerado
```

---

# Filters

Filtros:

Todos

Ativos

Pendentes

Verificados

Bloqueados

Mais vendidos

Melhores avaliados

---

Filtros avançados:

Categoria

Receita

Quantidade de alunos

Quantidade de cursos

Data cadastro

---

# Teachers Table

Desktop.

Colunas:

Foto

Nome

Especialidade

Cursos

Alunos

Receita

Avaliação

Status

---

Mobile:

Teacher Cards

---

# Teacher Card

Mostrar:

Foto

Nome

Especialidade

Badge

Cursos

Avaliação

---

Exemplo:

```text
Ariane Oliveira

Alta Costura

⭐ 4.9

8 cursos

12.400 alunos
```

---

# Teacher Status

Estados:

## Pending

Professor aguardando análise.

---

## Verified

Professor aprovado.

---

## Active

Pode publicar cursos.

---

## Suspended

Bloqueado temporariamente.

---

## Removed

Conta removida.

---

# Teacher Detail

Painel completo.

Mostrar:

Foto

Nome

Email

Especialidade

Bio

Status

Criado em

Último acesso

---

# Verification

Controle de aprovação.

Dados:

Documento

Certificações

Experiência

Portfólio

Redes sociais

---

Ações:

Aprovar

Solicitar alteração

Rejeitar

---

# Courses

Mostrar todos os cursos do professor.

Cada curso:

Nome

Status

Alunos

Receita

Avaliação

Conclusão

---

Exemplo:

```text
Modelagem Feminina

Publicado

2.400 alunos

R$143.000/mês
```

---

# Course Quality

Indicadores:

Avaliação média

Taxa conclusão

Reclamações

Reembolsos

Engajamento

---

# Students

Resumo:

Total alunos

Alunos ativos

Retenção

Certificados

---

# Revenue

Como o modelo utiliza assinatura por curso.

Mostrar:

Receita total professor

MRR

Receita por curso

Cancelamentos

Crescimento

---

Exemplo:

```text
MRR Professor

R$92.500


Alta Costura

R$45.000/mês
```

---

# Payouts

Controle de repasses.

Mostrar:

Saldo disponível

Pago

Pendente

Histórico

Conta bancária

---

Estados:

Pago

Processando

Falhou

---

# Reviews

Mostrar avaliações recebidas.

Cada avaliação:

Aluno

Curso

Nota

Comentário

Data

---

# Performance

Indicadores:

Cursos publicados

Horas de conteúdo

Lives realizadas

Tempo resposta

Feedbacks enviados

---

# Moderation

Controle:

Denúncias

Comentários

Problemas

Violação de regras

---

# Actions

Admin pode:

Aprovar professor

Suspender professor

Destacar professor

Editar dados

Enviar mensagem

Bloquear publicação

Resetar senha

---

# Audit Logs

Registrar:

Admin

Professor

Ação

Data

IP

Antes/depois

---

# APIs

GET /admin/teachers

GET /admin/teachers/{id}

PATCH /admin/teachers/{id}

POST /admin/teachers/{id}/approve

POST /admin/teachers/{id}/suspend

GET /admin/teachers/{id}/courses

GET /admin/teachers/{id}/revenue

GET /admin/teachers/{id}/reviews

GET /admin/teachers/{id}/payouts

GET /admin/teachers/{id}/audit

---

# Providers

teachersProvider

teacherDetailProvider

teacherVerificationProvider

teacherCoursesProvider

teacherRevenueProvider

teacherPayoutProvider

teacherReviewsProvider

auditProvider

---

# Componentes

GlassHeader

TeacherOverviewCard

TeacherTable

TeacherCard

TeacherProfilePanel

VerificationPanel

CoursePerformanceCard

RevenueCard

PayoutCard

ReviewCard

AuditTimeline

ConfirmDialog

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style

---

## Sem professores

```text
Nenhum professor encontrado.
```

---

## Aguardando aprovação

Badge amarelo.

---

## Verificado

Badge azul.

---

## Suspenso

Badge vermelho.

---

# Motion

Fade

Slide

Scale

Spring

Counter Animation

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em:

- Glass Header
- Filters
- Dialogs
- Action Menu
- Floating Search

Nunca aplicar em:

- Tabelas
- Dados financeiros
- Perfil
- Métricas

---

# Responsividade

## Desktop

Tabela completa.

Painel lateral.

Gráficos.

---

## Tablet

Painéis recolhíveis.

---

## Mobile

Teacher Cards.

Perfil em tela dedicada.

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

Financial Protection

Encryption

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Touch Target

44px

Focus Visible

Alto contraste

---

# Psicologia de Produto

## Qualidade

A plataforma deve valorizar bons professores e identificar problemas rapidamente.

---

## Confiança

Toda decisão administrativa precisa ser rastreável.

---

## Crescimento

Mostrar dados que ajudem professores a evoluírem.

---

## Controle

O administrador deve entender rapidamente a saúde de cada instrutor.

---

# Critérios de Aceitação

- O administrador deve gerenciar todo ciclo de vida do professor.
- Deve existir aprovação e verificação antes da publicação.
- Deve acompanhar cursos, alunos, avaliações e receita.
- Deve controlar repasses financeiros.
- Todas ações críticas precisam gerar Audit Log.
- Deve respeitar o modelo de assinatura mensal por curso.
- Deve utilizar Supabase Auth + RLS + RBAC.
- A interface deve seguir o Lawrence Design System.
- Liquid Glass apenas em elementos flutuantes.
- A experiência deve ser inspirada em Apple Business Manager, Stripe Connect e MasterClass.