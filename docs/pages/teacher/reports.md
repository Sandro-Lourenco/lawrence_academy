---
id: PAGE-TEACHER-012
name: Reports
route: /teacher/reports
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

reports:
  financial: true
  students: true
  courses: true
  engagement: true
  certificates: true
  export:
    - PDF
    - CSV
    - XLSX
  scheduled_reports: true
  ai_summary: future
---

# Reports

## Objetivo

A página **Reports** é responsável pela geração, visualização e exportação de relatórios completos para professores da Lawrence Academy.

Enquanto **Analytics** responde "o que está acontecendo agora", a página **Reports** cria documentos organizados e históricos que podem ser utilizados para análise, planejamento, auditoria e acompanhamento profissional.

A experiência deve ser simples, elegante e extremamente objetiva, permitindo gerar relatórios complexos em poucos cliques.

Inspirado em:

- Apple Business Reports
- Stripe Reports
- YouTube Studio Export
- Google Analytics Reports
- Notion Database Export

---

# Objetivos

- Criar relatórios.
- Exportar dados.
- Gerar documentos PDF.
- Analisar histórico.
- Compartilhar resultados.
- Criar relatórios recorrentes.
- Filtrar informações.
- Arquivar documentos.

---

# Fluxo

```text
Professor

↓

Reports

↓

Seleciona Tipo

↓

Define Filtros

↓

Gerar Relatório

↓

Visualizar

↓

Exportar
```

---

# Layout Desktop

```text
------------------------------------------------------------

Glass Header

------------------------------------------------------------

Sidebar

|

Report Generator

|

Recent Reports

|

Preview Panel

------------------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Gerador

↓

Histórico

↓

Preview

↓

Download
```

---

# Estrutura

```text
Glass Header

↓

Reports Overview

↓

Report Generator

↓

Report Categories

↓

Filters

↓

Preview

↓

Export

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

Blur

20px

Opacity

72%

---

# Reports Overview

Cards superiores.

Mostrar:

- Relatórios gerados
- Exportações realizadas
- Último relatório
- Cursos analisados
- Período analisado

Exemplo:

```text
128 Relatórios

Último gerado

Hoje 14:32

8 cursos analisados
```

---

# Report Categories

## Finance Report

Relatório financeiro.

Inclui:

- Receita total
- Receita por curso
- Assinaturas ativas
- Cancelamentos
- MRR
- Crescimento
- Histórico de pagamentos

---

Exemplo:

```text
Alta Costura

820 assinantes

R$89,90/mês

MRR:

R$73.718
```

---

# Student Report

Relatório dos alunos.

Inclui:

- Total de alunos
- Novos alunos
- Atividade
- Progresso
- Engajamento
- Certificados
- Notas

---

# Course Report

Relatório dos cursos.

Inclui:

- Visualizações
- Matrículas
- Assinaturas
- Receita
- Avaliação
- Conclusão
- Retenção

---

# Engagement Report

Inclui:

- Aulas assistidas
- Tempo médio
- Comentários
- Perguntas
- Downloads
- Lives
- Favoritos

---

# Assignment Report

Inclui:

- Atividades criadas
- Atividades entregues
- Média das notas
- Aprovação
- Questões difíceis
- Pendências

---

# Certificate Report

Inclui:

- Certificados emitidos
- Cursos concluídos
- Taxa conclusão
- Código certificado
- Datas

---

# Custom Report

O professor pode escolher:

Métricas

↓

Período

↓

Curso

↓

Formato

↓

Exportar

---

# Filters

Disponíveis:

Data inicial

Data final

Curso

Aluno

Status

Categoria

Módulo

Tipo de conteúdo

---

Períodos rápidos:

Hoje

7 dias

30 dias

90 dias

Ano atual

Personalizado

---

# Report Preview

Antes de exportar mostrar:

Resumo

Gráficos

Tabelas

Indicadores

---

Visualização:

Desktop

Tablet

Mobile

PDF Preview

---

# Export

Formatos:

PDF

CSV

XLSX

---

Opções:

Baixar

Enviar por Email

Salvar

Compartilhar

---

# Scheduled Reports

Relatórios automáticos.

Exemplo:

```text
Enviar relatório financeiro

Todo dia 01

08:00
```

Frequência:

Diário

Semanal

Mensal

Trimestral

---

# Report History

Histórico.

Cada item:

Nome

Tipo

Criado em

Formato

Tamanho

Autor

---

Ações:

Baixar

Duplicar

Excluir

Gerar novamente

---

# AI Summary (Future)

Gerar resumo inteligente.

Exemplo:

```text
Seu curso cresceu 18% este mês.

O maior crescimento veio de novos alunos em Modelagem Feminina.
```

---

# APIs

GET /teacher/reports

GET /teacher/reports/{id}

POST /teacher/reports/generate

GET /teacher/reports/history

POST /teacher/reports/export

POST /teacher/reports/schedule

DELETE /teacher/reports/{id}

---

# Providers

reportsProvider

reportGeneratorProvider

financialReportProvider

studentReportProvider

courseReportProvider

exportProvider

scheduledReportProvider

---

# Componentes

GlassHeader

ReportsOverviewCard

ReportTypeCard

ReportGenerator

FilterPanel

ReportPreview

ExportDialog

ReportHistory

ScheduledReportCard

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style

---

## Gerando relatório

Mostrar:

```text
Preparando relatório...
```

Progress Indicator

---

## Exportado

Banner:

```text
Relatório exportado com sucesso.
```

---

## Sem relatórios

Mostrar:

```text
Nenhum relatório criado ainda.
```

CTA:

Criar primeiro relatório

---

## Erro

Toast

Tentar novamente

---

# Motion

Fade

Slide

Scale

Spring

Progress Animation

Export Animation

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em:

- Glass Header
- Export Dialog
- Filter Floating Panel
- Date Picker
- Bottom Actions

Nunca aplicar em:

- Relatórios
- Tabelas
- Gráficos
- Dados financeiros

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

Gerador lateral.

Preview grande.

Histórico.

---

## Tablet

Painéis recolhíveis.

---

## Mobile

Fluxo guiado:

1. Tipo
2. Filtros
3. Preview
4. Exportar

---

# Performance

Background Processing

Cache

Pagination

Lazy Loading

Streaming Data

Realtime

Skeleton Loading

60 FPS

---

# Segurança

Supabase Auth

JWT

HTTPS

Row Level Security

Teacher Guard

Course Ownership

Export Permissions

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

Descrição de gráficos

Alto contraste

---

# Psicologia de Produto

## Decisão rápida

O relatório deve transformar dados em decisões.

---

## Organização

Cada documento deve ter objetivo claro.

---

## Confiança

Dados financeiros devem sempre indicar período e origem.

---

## Simplicidade

Criar um relatório não deve exigir conhecimento técnico.

---

# Critérios de Aceitação

- O professor deve gerar relatórios financeiros, acadêmicos e de engajamento.
- Cada curso deve possuir relatórios individuais devido ao modelo de assinatura por curso.
- O sistema deve permitir exportação PDF, CSV e XLSX.
- Deve existir histórico de relatórios gerados.
- Deve permitir relatórios automáticos recorrentes.
- Deve estar preparado para geração futura de resumos com IA.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve ser aplicado somente em elementos flutuantes.
- A experiência deve ser minimalista, profissional e inspirada em Apple Business, Stripe e Notion.