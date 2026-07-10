---
id: PAGE-STUDENT-005
name: Activities
route: /dashboard/activities
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
---

# Activities

## Objetivo

A página **Activities** reúne todas as atividades acadêmicas do aluno em um único local.

Ela centraliza tarefas, questionários, projetos práticos, avaliações, exercícios discursivos, provas, atividades pendentes e já concluídas.

O objetivo é reduzir a ansiedade do aluno mostrando exatamente o que precisa ser feito hoje.

Inspirada em:

- Apple Classroom
- Coursera
- Canvas LMS
- Google Classroom
- Notion
- Todoist

A experiência deve transmitir organização, clareza e produtividade.

---

# Objetivos

- Centralizar todas as atividades.
- Facilitar o acompanhamento.
- Incentivar a conclusão.
- Mostrar prazos.
- Mostrar notas.
- Reduzir abandono.
- Melhorar retenção.
- Facilitar feedback do professor.

---

# Fluxo

```
Dashboard

↓

Activities

↓

Filtros

↓

Selecionar Atividade

↓

Abrir Detalhes

↓

Responder

↓

Enviar

↓

Correção

↓

Feedback

↓

Nota

↓

Próxima Atividade
```

---

# Layout Desktop

```
-------------------------------------------------------------

Glass Header

-------------------------------------------------------------

Sidebar

|

Filtros

|

Lista de Atividades

|

Painel de Informações

-------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Search

↓

Filtros Horizontais

↓

Cards de Atividades

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Search

↓

Today's Tasks

↓

Filters

↓

Activities List

↓

Upcoming Activities

↓

Completed Activities

↓

Grades Summary

↓

Footer
```

---

# Glass Header

Sticky

72px

Background

Liquid Glass

Blur

20px

Opacity

72%

---

Componentes

Logo

Pesquisar

Notificações

Perfil

---

# Search

Pesquisar

Atividade

Curso

Professor

Categoria

Pesquisa instantânea.

Debounce

300ms

---

# Today's Tasks

Card destaque.

Sempre aparece primeiro.

---

Conteúdo

Título

Prazo

Curso

Professor

Tempo restante

Prioridade

Botão

Resolver Agora

---

# Filters

Categorias

Todos

Pendentes

Hoje

Esta Semana

Atrasadas

Concluídas

Corrigidas

Projetos

Quiz

Dissertativas

Verdadeiro ou Falso

Envio de Arquivo

---

Ordenação

Mais recentes

Prazo

Curso

Professor

Nota

---

# Lista de Atividades

Desktop

Lista vertical.

---

Mobile

Cards empilhados.

---

Cada Card

Título

Curso

Professor

Tipo

Prazo

Tempo restante

Nota

Status

Botão

Abrir

---

# Tipos

Quiz

Questão Discursiva

Verdadeiro ou Falso

Projeto

Entrega de Arquivo

Avaliação

Exercício

Desafio

---

# Status

Pendente

Em andamento

Enviada

Corrigida

Concluída

Atrasada

Expirada

---

# Cores de Status

Pendente

Azul

---

Concluída

Verde

---

Atrasada

Laranja

---

Expirada

Vermelho

---

Corrigida

Dourado

---

# Card da Atividade

Imagem (opcional)

Título

Professor

Curso

Prazo

Tempo estimado

Tipo

Nota

Status

Botão

Resolver

---

# Painel de Informações

Desktop

Lateral direita.

Mostrar

Descrição

Objetivos

Critérios de avaliação

Professor

Peso

Prazo

Anexos

---

# Upcoming Activities

Mostrar próximas entregas.

Timeline.

---

# Completed Activities

Lista separada.

Mostrar

Nota

Data

Professor

Feedback

Botão

Visualizar Correção

---

# Grades Summary

Resumo geral.

Mostrar

Nota Média

Quantidade

Pendentes

Concluídas

Corrigidas

Aprovadas

Reprovadas

---

Gráfico

Circular

ou

Linear

---

# APIs

GET /activities

GET /activities/today

GET /activities/upcoming

GET /activities/completed

GET /activities/statistics

GET /activities/search

---

# Providers

activitiesProvider

todayActivitiesProvider

completedActivitiesProvider

statisticsProvider

filtersProvider

searchProvider

---

# Componentes

GlassHeader

SearchBar

FilterChips

ActivityCard

Today'sTaskCard

UpcomingTimeline

StatisticsCard

ProgressCircle

GradeCard

SkeletonLoader

EmptyState

ErrorCard

---

# Estados

Loading

Skeleton Apple Style.

---

Sem atividades

Ilustração.

Mensagem

Você está em dia!

---

Offline

Mostrar cache.

---

Erro

Botão

Tentar novamente.

---

# Motion

Fade

Scale

Slide

Hero Animation

Shared Transition

Spring

Blur

Hover

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Search

Floating Filters

Bottom Navigation

Floating FAB

Modal

Nunca aplicar em

Cards

Texto

Lista

Gráficos

Conteúdo principal

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

Sucesso

#30D158

Erro

#FF453A

Aviso

#FF9F0A

---

# Responsividade

## Desktop

Sidebar fixa.

Lista + painel lateral.

---

## Tablet

Painel recolhível.

---

## Mobile

Cards empilhados.

Filtros horizontais.

Bottom Navigation.

Safe Area.

---

# Performance

Lazy Loading

Infinite Scroll

Cache

Pré-carregar atividades

Shimmer

60 FPS

---

# Analytics

Atividades concluídas

Pendentes

Tempo médio

Nota média

Tempo de resposta

Taxa de entrega

Correções recebidas

Dias em atraso

---

# Segurança

Supabase Auth

JWT

HTTPS

OWASP Top 10

Role Guard

Ownership Guard

Controle de acesso por matrícula

Validação de entrega

Proteção contra alterações após prazo

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Screen Reader

Touch Target

44x44px

Focus Visible

Escala dinâmica de fontes

---

# Psicologia de Aprendizagem

## Zeigarnik Effect

As atividades pendentes devem sempre aparecer primeiro, incentivando o aluno a concluí-las.

---

## Goal Gradient

Exibir mensagens como:

- "Faltam apenas 2 atividades para concluir este módulo."
- "Você está com 92% das atividades concluídas."

---

## Progressão

Mostrar pequenas conquistas ao concluir cada atividade.

Exibir check animado.

Atualizar estatísticas imediatamente.

---

## Organização Mental

Agrupar atividades por:

- Hoje
- Esta Semana
- Próximas
- Concluídas

Facilitando a tomada de decisão.

---

## Feedback

Sempre destacar o comentário do professor quando existir.

A nota nunca deve aparecer isolada.

Ela deve estar acompanhada do feedback pedagógico.

---

# Critérios de Aceitação

- O aluno deve visualizar todas as atividades em um único local.
- As atividades devem ser organizadas por status, prazo e curso.
- O sistema deve suportar filtros e pesquisa em tempo real.
- Cada atividade deve exibir prazo, tipo, status, nota (quando disponível) e botão para resolução.
- O painel lateral (desktop) deve apresentar detalhes completos da atividade selecionada.
- O layout deve seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve ser aplicado apenas aos elementos flutuantes.
- A página deve utilizar Skeleton Loading, Lazy Loading e cache para alta performance.
- Toda a experiência deve reforçar organização, foco e produtividade, mantendo a identidade premium da Lawrence Academy.
```