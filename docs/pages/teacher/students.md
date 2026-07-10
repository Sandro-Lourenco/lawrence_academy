---
id: PAGE-TEACHER-011
name: Students Management
route: /teacher/students
layout: TeacherDashboardLayout
platforms:
  - Web
  - Android
roles:
  - Teacher
authentication: true
responsive: true
status: Production
design-system: Lawrence Design System
navigation: Sidebar + Top Navigation
state-management: Riverpod
architecture: Clean Architecture + DDD
real-time: Supabase Realtime

students:
  management: true
  progress_tracking: true
  engagement_tracking: true
  subscriptions_tracking: true
  certificates_tracking: true
  communication: true
  ai_insights: future
---

# Students

## Objetivo

A página **Students** é o centro de gerenciamento dos alunos vinculados aos cursos do professor.

Ela permite acompanhar evolução, engajamento, atividades, certificados, assinaturas dos cursos, dificuldades e comportamento de aprendizagem.

O objetivo não é apenas listar alunos, mas oferecer ao professor uma visão completa para melhorar o acompanhamento educacional.

A experiência deve ser simples, humana e analítica, seguindo o Lawrence Design System.

Inspirado em:

- Apple Classroom
- Google Classroom
- Canvas LMS
- Notion Database
- Linear
- MasterClass

---

# Objetivos

- Visualizar alunos.
- Acompanhar progresso.
- Identificar dificuldades.
- Ver atividades.
- Consultar histórico.
- Enviar mensagens.
- Gerenciar acompanhamento.
- Melhorar retenção.

---

# Fluxo

```text
Professor

↓

Students

↓

Seleciona aluno

↓

Analisa progresso

↓

Executa ação
```

---

# Layout Desktop

```text
------------------------------------------------------------

Glass Header

------------------------------------------------------------

Sidebar

|

Students Overview

|

Students Table

|

Student Detail Panel

------------------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Resumo

↓

Lista de alunos

↓

Perfil do aluno

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

Filters

↓

Student List

↓

Student Profile

↓

Learning Progress

↓

Subscriptions

↓

Activities

↓

Certificates

↓

Engagement

↓

Actions
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
- Alunos ativos
- Novos alunos
- Alunos em risco
- Conclusões
- Certificados emitidos

---

Exemplo:

```text
1.248 alunos

924 ativos

+82 este mês

96 em risco
```

---

# Filters

Filtros:

Todos

Ativos

Inativos

Novos

Em risco

Concluídos

Certificados

---

Filtros avançados:

Curso

Progresso

Assinatura

Último acesso

Nota média

Engajamento

---

# Student List

Desktop:

Tabela.

Mobile:

Cards.

---

Cada aluno mostra:

- Foto
- Nome
- Curso
- Status
- Progresso
- Último acesso
- Nota média
- Engajamento

---

Exemplo:

```text
Maria Oliveira

Alta Costura

72% concluído

Último acesso hoje

Nota média 9.4
```

---

# Status do Aluno

Ativo

↓

Estudando

↓

Finalizando

↓

Concluído

↓

Inativo

↓

Risco de abandono

---

# Student Profile

Ao selecionar aluno.

Mostrar:

Perfil

Foto

Nome

Email

Data de entrada

Cursos comprados

Tempo na plataforma

---

# Course Enrollment

Como a plataforma utiliza assinatura por curso:

Cada aluno pode possuir vários cursos.

Mostrar:

```text
Maria Oliveira

Cursos:

✓ Modelagem Feminina

R$59,90/mês

Ativo


✓ Alta Costura

R$89,90/mês

Ativo


✕ Moda Praia

Cancelado
```

---

# Learning Progress

Mostrar:

Por curso:

- progresso
- módulos concluídos
- aulas assistidas
- atividades entregues
- certificado

---

Exemplo:

```text
Modelagem Feminina

72%

42/60 aulas

8/10 atividades
```

---

# Activity History

Timeline.

Mostrar:

Aulas assistidas

Atividades enviadas

Comentários

Lives assistidas

Downloads

Certificados

---

# Assignments

Mostrar:

Atividade

Nota

Status

Feedback enviado

Data

---

Estados:

Pendente

Entregue

Corrigido

Revisão

---

# Certificates

Mostrar:

Certificados conquistados

Curso

Data

Código

Download

---

# Engagement

Indicadores:

Dias ativos

Horas estudadas

Sequência

Participação em lives

Perguntas enviadas

Materiais baixados

---

# Risk Detection

Identificar alunos em risco.

Critérios:

- Muitos dias sem acessar
- Baixo progresso
- Atividades atrasadas
- Cancelamento próximo

---

Exemplo:

```text
Este aluno está há 21 dias sem estudar.
```

---

# Communication

Professor pode:

Enviar mensagem

Enviar aviso

Enviar feedback

Recomendar aula

---

# AI Insights (Future)

Exemplos:

```text
Este aluno costuma abandonar aulas acima de 40 minutos.
```

---

```text
Recomende uma revisão do módulo 3.
```

---

# APIs

GET /teacher/students

GET /teacher/students/{id}

GET /teacher/students/{id}/courses

GET /teacher/students/{id}/progress

GET /teacher/students/{id}/activities

GET /teacher/students/{id}/certificates

GET /teacher/students/{id}/engagement

POST /teacher/students/{id}/message

---

# Providers

studentsProvider

studentDetailProvider

studentProgressProvider

studentCoursesProvider

studentActivityProvider

studentCertificateProvider

studentEngagementProvider

---

# Componentes

GlassHeader

StudentsOverviewCard

StudentTable

StudentCard

StudentProfile

ProgressCard

CourseEnrollmentCard

ActivityTimeline

CertificateCard

EngagementCard

RiskAlert

MessageDialog

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Sem alunos

Mostrar:

```text
Nenhum aluno matriculado ainda.
```

---

## Aluno ativo

Badge verde.

---

## Baixo engajamento

Alerta discreto.

---

## Offline

Exibir cache.

---

## Erro

Toast.

Tentar novamente.

---

# Motion

Fade

Slide

Scale

Spring

Counter Animation

Progress Animation

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em:

- Glass Header
- Floating Search
- Filters
- Message Dialog
- Bottom Navigation

Nunca aplicar em:

- Tabelas
- Lista de alunos
- Métricas
- Histórico

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

Tabela de alunos.

Painel lateral de detalhes.

---

## Tablet

Painel recolhível.

---

## Mobile

Cards empilhados.

Perfil abre em página dedicada.

Bottom Navigation.

Safe Area.

---

# Performance

Realtime

Pagination

Virtual Scroll

Cache

Lazy Loading

Background Refresh

Skeleton Loading

60 FPS

---

# Analytics

Total alunos

Novos alunos

Retenção

Abandono

Conclusões

Certificados

Engajamento médio

---

# Segurança

Supabase Auth

JWT

HTTPS

Row Level Security

Teacher Guard

Course Ownership

Logs de Auditoria

Criptografia

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Touch Target

44x44px

Focus Visible

Alto contraste

---

# Psicologia de Produto

## Visão Humana

O professor deve enxergar pessoas, não apenas números.

---

## Prevenção

Destacar alunos que precisam de atenção antes que abandonem.

---

## Evolução

Mostrar progresso e conquistas para incentivar acompanhamento.

---

## Produtividade

O professor deve encontrar qualquer aluno rapidamente.

---

# Critérios de Aceitação

- O professor deve visualizar todos os alunos vinculados aos seus cursos.
- Deve existir acompanhamento individual por curso comprado.
- O sistema deve respeitar o modelo onde cada curso possui sua própria assinatura.
- Deve mostrar progresso, atividades, certificados e engajamento.
- Deve permitir comunicação entre professor e aluno.
- Deve suportar identificação futura de risco usando IA.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve ser utilizado apenas em elementos flutuantes.
- A experiência deve ser organizada, humana e inspirada em Apple Classroom e Notion.