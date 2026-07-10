---
id: PAGE-ADMIN-008
name: Reports Management
route: /admin/reports
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

reports:
  financial_reports: true
  users_reports: true
  courses_reports: true
  subscriptions_reports: true
  teachers_reports: true
  platform_reports: true
  export:
    - PDF
    - CSV
    - XLSX
  scheduled_reports: true
  ai_analysis: future
---

# Reports

## Objetivo

A página **Reports Management** é o centro de geração de relatórios administrativos da Lawrence Academy.

Diferente do Analytics que mostra dados em tempo real, Reports cria documentos completos para:

- Análise estratégica
- Auditoria
- Contabilidade
- Gestão financeira
- Acompanhamento de crescimento
- Tomada de decisão

O administrador deve conseguir gerar relatórios completos da operação da plataforma.

Inspirado em:

- Apple Business Reports
- Stripe Reports
- Google Analytics Reports
- Power BI
- Notion Database Export
- Looker Studio

---

# Objetivos

- Gerar relatórios.
- Exportar informações.
- Acompanhar histórico.
- Criar relatórios recorrentes.
- Auditar dados.
- Compartilhar documentos.
- Analisar crescimento.

---

# Fluxo

```text
Admin

↓

Reports

↓

Seleciona Tipo

↓

Define Filtros

↓

Gera Relatório

↓

Preview

↓

Exporta
```

---

# Layout Desktop

```text
------------------------------------------------

Glass Header

------------------------------------------------

Sidebar

|

Report Builder

|

Report Preview

|

History

------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Tipos

↓

Filtros

↓

Preview

↓

Exportar
```

---

# Estrutura

```text
Glass Header

↓

Reports Overview

↓

Report Builder

↓

Categories

↓

Filters

↓

Preview

↓

Exports

↓

History

↓

Scheduled Reports
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur 20px

Opacity 72%

---

# Reports Overview

Mostrar:

- Relatórios gerados
- Exportações
- Relatórios automáticos
- Última geração
- Volume analisado

---

Exemplo:

```text
1.248 relatórios

120 automáticos

Último hoje 08:00
```

---

# Report Types

## Financial Report

Relatório financeiro global.

Inclui:

- Receita total
- MRR
- ARR
- Receita líquida
- Taxas
- Lucro plataforma
- Repasses professores
- Reembolsos

---

Exemplo:

```text
MRR

R$850.000

+18%

Mês anterior
```

---

# Subscription Report

Como cada curso possui assinatura própria.

Mostrar:

- Assinaturas por curso
- Crescimento
- Cancelamentos
- Churn
- Retenção
- LTV

---

Exemplo:

```text
Curso:

Alta Costura

Assinantes:

2.400

MRR:

R$215.760
```

---

# Course Report

Inclui:

Cursos publicados

Cursos pendentes

Vendas

Receita

Avaliações

Conclusão

Engajamento

---

# Teacher Report

Inclui:

Professores ativos

Cursos criados

Receita gerada

Repasses

Avaliações

Performance

---

# Student Report

Inclui:

Alunos cadastrados

Novos alunos

Atividade

Cursos comprados

Certificados

Retenção

---

# Payment Report

Inclui:

Transações

Gateway

Falhas

Chargebacks

Reembolsos

Métodos pagamento

---

# Platform Report

Saúde geral.

Inclui:

Usuários

Crescimento

Uso

Storage

Vídeos

Consumo

Custos

---

# Custom Report Builder

Permitir montar relatório.

Selecionar:

Métricas

+

Dimensões

+

Período

+

Formato

---

Exemplo:

```text
Quero:

Receita

por Curso

últimos 90 dias
```

---

# Filters

Disponíveis:

Período

Curso

Professor

Aluno

Categoria

Status

Gateway

País

---

Datas rápidas:

Hoje

7 dias

30 dias

90 dias

Ano

Personalizado

---

# Report Preview

Antes de exportar.

Mostrar:

Resumo executivo

Cards

Tabelas

Gráficos

Indicadores

---

# Export Options

Formatos:

PDF

CSV

XLSX

---

Ações:

Baixar

Enviar email

Salvar

Agendar

---

# Scheduled Reports

Automação.

Exemplos:

```text
Relatório financeiro

Todo dia 01

Enviar para admin
```

---

Frequência:

Diário

Semanal

Mensal

Trimestral

---

# Report History

Lista.

Mostrar:

Nome

Tipo

Criador

Data

Formato

Tamanho

---

Ações:

Baixar

Duplicar

Excluir

Gerar novamente

---

# AI Reports (Future)

IA interpreta dados.

Exemplo:

```text
Sua plataforma cresceu 22%.

Principal causa:

Aumento das assinaturas em cursos de modelagem.
```

---

Sugestões:

```text
Cursos com aulas menores tiveram 35% mais conclusão.
```

---

# Audit Reports

Relatórios administrativos.

Mostrar:

Alterações

Admins

Permissões

Usuários

Segurança

---

# APIs

GET /admin/reports

GET /admin/reports/{id}

POST /admin/reports/generate

POST /admin/reports/export

GET /admin/reports/history

POST /admin/reports/schedule

DELETE /admin/reports/{id}

GET /admin/reports/templates

---

# Providers

reportsProvider

reportBuilderProvider

financialReportProvider

subscriptionReportProvider

teacherReportProvider

studentReportProvider

exportProvider

scheduledReportProvider

---

# Componentes

GlassHeader

ReportsOverviewCard

ReportBuilder

ReportTypeCard

FilterPanel

ReportPreview

ChartPreview

ExportDialog

ReportHistory

ScheduleCard

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style

---

## Gerando

Mensagem:

```text
Gerando relatório...
```

---

## Exportado

Mensagem:

```text
Relatório exportado com sucesso.
```

---

## Sem relatórios

```text
Nenhum relatório criado ainda.
```

CTA:

Criar relatório

---

## Erro

Toast.

---

# Motion

Fade

Slide

Scale

Spring

Chart Animation

Export Animation

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em:

- Glass Header
- Filters
- Export Dialog
- Date Picker
- Floating Actions

Nunca aplicar em:

- Relatórios
- Tabelas
- Gráficos
- Dados financeiros

---

# Responsividade

## Desktop

Builder lateral.

Preview grande.

Histórico.

---

## Tablet

Painéis adaptativos.

---

## Mobile

Wizard:

1. Tipo
2. Filtro
3. Preview
4. Exportação

Bottom Navigation.

---

# Performance

Background Processing

Realtime

Cache

Lazy Loading

Pagination

Streaming Export

Skeleton Loading

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

Export Permission

Audit Logs

Data Encryption

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Touch Target 44px

Focus Visible

Descrição de gráficos

Alto contraste

---

# Psicologia de Produto

## Decisão

Relatórios devem responder perguntas, não apenas mostrar números.

---

## Confiança

Dados financeiros e administrativos precisam ser auditáveis.

---

## Simplicidade

Gerar relatório complexo deve parecer simples.

---

## Inteligência

O futuro com IA deve transformar dados em recomendações.

---

# Critérios de Aceitação

- Administrador deve gerar relatórios completos da plataforma.
- Deve suportar relatórios financeiros, cursos, professores e alunos.
- Deve respeitar assinatura mensal individual por curso.
- Deve permitir exportação PDF, CSV e XLSX.
- Deve possuir relatórios agendados.
- Deve registrar histórico de geração.
- Deve estar preparado para análise futura com IA.
- Deve usar Supabase Auth + RLS + RBAC.
- Deve seguir Lawrence Design System.
- Liquid Glass somente em elementos flutuantes.
- Experiência inspirada em Apple Business Reports, Stripe e Power BI.