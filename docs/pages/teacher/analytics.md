---
id: PAGE-TEACHER-010
name: Analytics
route: /teacher/analytics
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

analytics:
  realtime: true
  charts: true
  student_behavior: true
  course_metrics: true
  revenue_metrics: true
  engagement_metrics: true
  export_reports: true
  ai_insights: future
---

# Analytics

## Objetivo

A página **Analytics** é o centro de inteligência do professor dentro da Lawrence Academy.

Ela transforma dados brutos de cursos, alunos, vendas, assinaturas, engajamento e desempenho acadêmico em informações claras para ajudar o professor a tomar decisões.

O foco não é exibir muitos gráficos, mas responder perguntas importantes:

- Meus alunos estão aprendendo?
- Onde eles estão abandonando?
- Quais aulas geram mais engajamento?
- Quanto meus cursos estão faturando?
- Onde posso melhorar?

A experiência deve seguir um modelo executivo, minimalista e premium.

Inspirado em:

- Apple Health Analytics
- Stripe Dashboard
- YouTube Studio Analytics
- Linear Insights
- Notion Analytics
- Google Analytics 4

---

# Objetivos

- Monitorar cursos.
- Analisar alunos.
- Ver receita.
- Medir engajamento.
- Identificar abandono.
- Comparar períodos.
- Exportar relatórios.
- Melhorar decisões.

---

# Fluxo

```text
Professor

↓

Analytics

↓

Seleciona período

↓

Analisa indicadores

↓

Identifica oportunidade

↓

Melhora curso
```

---

# Layout Desktop

```text
------------------------------------------------------------

Glass Header

------------------------------------------------------------

Sidebar

|

Overview Metrics

|

Charts

|

Students Insights

|

Revenue

|

Course Performance

------------------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Resumo

↓

Cards

↓

Gráficos

↓

Insights

↓

Bottom Navigation
```

---

# Estrutura

```text
Glass Header

↓

Analytics Overview

↓

Date Filter

↓

Revenue Analytics

↓

Student Analytics

↓

Course Analytics

↓

Engagement Analytics

↓

Retention

↓

Insights

↓

Reports
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

# Analytics Overview

Cards principais.

Mostrar:

- Receita mensal
- Alunos ativos
- Novas assinaturas
- Taxa de conclusão
- Avaliação média
- Horas assistidas
- Crescimento

---

Exemplo:

```text
Receita

R$45.850

+18%

comparado ao mês passado
```

---

# Date Filter

Filtros:

Hoje

7 dias

30 dias

90 dias

Este ano

Personalizado

---

Comparação:

Período anterior

Mesmo período ano passado

---

# Revenue Analytics

Como cada curso possui assinatura própria, analisar individualmente.

Mostrar:

- Receita total
- Receita por curso
- Receita recorrente mensal
- Cancelamentos
- Novas assinaturas
- Crescimento
- Ticket médio

---

Exemplo:

```text
Modelagem Feminina

520 alunos ativos

R$59,90/mês

MRR

R$31.148
```

---

# Course Revenue Ranking

Ranking:

Curso

↓

Alunos

↓

Receita

↓

Crescimento

---

# Student Analytics

Indicadores:

Total de alunos

Novos alunos

Alunos ativos

Alunos inativos

Retenção

Abandono

Tempo médio estudado

---

# Student Behavior

Mostrar:

Aulas assistidas

Tempo assistido

Horários favoritos

Dispositivos usados

Downloads realizados

Lives assistidas

---

# Course Analytics

Cada curso possui:

Visualizações

Conversão

Assinantes

Avaliação

Conclusão

Abandono

Receita

---

# Course Card

Exemplo:

```text
Alta Costura Premium

⭐ 4.9

820 alunos

87% conclusão

R$72.500 receita
```

---

# Lesson Analytics

Analisar aulas.

Mostrar:

Mais assistidas

Menos assistidas

Taxa abandono

Replay

Comentários

Curtidas

---

Exemplo:

```text
Aula 12

Modelagem de Manga

35% dos alunos abandonam no minuto 18
```

---

# Engagement Analytics

Métricas:

Comentários

Perguntas

Atividades entregues

Lives assistidas

Downloads

Favoritos

Certificados emitidos

---

# Retention

Mostrar:

D1

D7

D30

Mensal

---

Identificar:

Alunos engajados

Risco de abandono

Cancelamentos

---

# Assignments Analytics

Mostrar:

Quantidade enviada

Média das notas

Questões difíceis

Taxa aprovação

Tempo médio

---

# Certificates Analytics

Mostrar:

Certificados emitidos

Cursos concluídos

Taxa de conclusão

---

# Reviews Analytics

Avaliações.

Mostrar:

Nota média

Comentários

Evolução

Feedback dos alunos

---

# AI Insights (Future)

Sistema analisa dados.

Exemplos:

```text
A aula 7 possui abandono acima da média.

Considere dividir em duas partes.
```

---

```text
Alunos que assistem lives possuem 43% mais conclusão.
```

---

# Reports

Exportar:

PDF

CSV

XLSX

---

Relatórios:

Financeiro

Alunos

Cursos

Engajamento

Vendas

---

# APIs

GET /teacher/analytics

GET /teacher/analytics/revenue

GET /teacher/analytics/students

GET /teacher/analytics/courses

GET /teacher/analytics/lessons

GET /teacher/analytics/engagement

GET /teacher/analytics/retention

GET /teacher/analytics/reports

POST /teacher/analytics/export

---

# Providers

analyticsProvider

revenueAnalyticsProvider

studentAnalyticsProvider

courseAnalyticsProvider

lessonAnalyticsProvider

engagementProvider

retentionProvider

reportProvider

---

# Componentes

GlassHeader

AnalyticsOverviewCard

MetricCard

RevenueChart

StudentChart

CoursePerformanceCard

EngagementChart

RetentionGraph

InsightCard

ReportExporter

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Sem dados

Mostrar:

```text
Ainda não existem dados suficientes.
```

---

## Crescimento positivo

Indicador verde.

---

## Queda

Indicador discreto.

Mostrar recomendação.

---

## Erro

Toast

Tentar novamente.

---

# Motion

Fade

Slide

Scale

Spring

Counter Animation

Chart Animation

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em:

- Glass Header
- Date Picker
- Floating Filters
- Export Dialog
- Notification Panel

Nunca aplicar em:

- Gráficos
- Métricas
- Tabelas
- Cards principais

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

Dashboard analítico completo.

Cards superiores.

Gráficos grandes.

---

## Tablet

Grid adaptativo.

---

## Mobile

Cards empilhados.

Gráficos simplificados.

Bottom Navigation.

---

# Performance

Realtime

Cache

Lazy Loading

Background Refresh

Pagination

Data Aggregation

Skeleton Loading

60 FPS

---

# Segurança

Supabase Auth

JWT

HTTPS

Row Level Security

Teacher Guard

Data Ownership

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

Descrição textual dos gráficos

Alto contraste

---

# Psicologia de Produto

## Clareza acima de números

O professor não precisa ver centenas de métricas.

Ele precisa entender o que fazer.

---

## Ação

Todo problema deve gerar uma possível ação.

Exemplo:

Problema:

```text
Baixa conclusão
```

Sugestão:

```text
Revise aulas acima de 30 minutos.
```

---

## Motivação

Sempre destacar:

- crescimento
- alunos impactados
- progresso

---

# Critérios de Aceitação

- O professor deve acompanhar métricas financeiras, acadêmicas e comportamentais.
- Cada curso deve possuir análise independente porque cada assinatura pertence a um curso.
- Os dados devem atualizar em tempo real pelo Supabase Realtime.
- Deve ser possível exportar relatórios.
- Deve existir suporte futuro para insights com IA.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve ser utilizado somente em elementos flutuantes.
- A experiência deve ser simples, visual e inspirada em Apple, Stripe e YouTube Studio.