---
id: PAGE-STUDENT-021
name: Search
route: /dashboard/search
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
real-time: Supabase Realtime

search:
  global: true
  instant: true
  semantic: true
  full_text: true
  voice_search: future
---

# Search

## Objetivo

A página **Search** funciona como o centro inteligente de pesquisa da Lawrence Academy, permitindo que o aluno encontre rapidamente qualquer conteúdo disponível na plataforma.

A busca deve ser extremamente rápida, inteligente e contextual, pesquisando simultaneamente cursos, módulos, aulas, atividades, materiais complementares, certificados, professores, artigos do blog, lives e downloads.

O sistema deve utilizar **busca semântica**, autocomplete e histórico recente para reduzir o tempo necessário para encontrar qualquer informação.

Toda a experiência deve seguir o conceito **Search First**, inspirado na Apple Spotlight, Raycast, Linear e Notion Search.

Inspirado em:

- Apple Spotlight
- Raycast
- Notion Search
- Linear Search
- Google Search
- Netflix Search

---

# Objetivos

- Buscar cursos.
- Buscar aulas.
- Buscar professores.
- Buscar atividades.
- Buscar materiais.
- Buscar certificados.
- Buscar lives.
- Buscar artigos.
- Buscar downloads.
- Buscar qualquer conteúdo.

---

# Fluxo

```
Aluno

↓

Search

↓

Digita pesquisa

↓

Resultados Instantâneos

↓

Seleciona item

↓

Abre Conteúdo
```

---

# Layout Desktop

```
------------------------------------------------------------

Glass Header

------------------------------------------------------------

Sidebar

|

Search Bar

|

Recent Searches

|

Suggestions

|

Search Results

------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Search Bar

↓

Recentes

↓

Sugestões

↓

Resultados

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Global Search

↓

Quick Filters

↓

Recent Searches

↓

Trending

↓

Suggestions

↓

Search Results

↓

Empty State
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

# Global Search

Campo principal.

Altura

56px

Radius

16px

Placeholder

```
Pesquisar cursos, aulas, professores...
```

Ícones

🔍 Pesquisar

❌ Limpar

🎤 Busca por voz (Future)

---

# Pesquisa Instantânea

Enquanto o usuário digita.

Atualização

300ms debounce

Mostrar

Autocomplete

Sugestões

Resultados rápidos

---

# Quick Filters

Filtros rápidos.

Todos

Cursos

Aulas

Atividades

Lives

Materiais

Professores

Blog

Downloads

Certificados

Favoritos

---

# Recent Searches

Últimas pesquisas.

Exemplo

```
Modelagem

Molde Base

Calça Feminina

Costura Industrial
```

Botões

Pesquisar novamente

Remover

Limpar histórico

---

# Trending

Mostrar pesquisas populares.

Exemplo

```
Alta Costura

Modelagem Feminina

Curso Completo

Moldes

Vestido de Festa
```

---

# Suggestions

Sugestões inteligentes.

Exemplo

```
Você pode estar procurando:

Modelagem Plana

Molde Base

Tabela de Medidas
```

---

# Search Results

Agrupar por categoria.

## Cursos

Imagem

Título

Professor

Categoria

Botão

Abrir

---

## Aulas

Título

Curso

Duração

Progresso

---

## Atividades

Título

Curso

Status

Prazo

---

## Materiais

PDF

Imagem

Molde

Arquivo

---

## Professores

Foto

Nome

Especialidade

---

## Lives

Título

Data

Status

---

## Blog

Imagem

Título

Categoria

---

## Certificados

Curso

Data

Download

---

# Search Result Card

Mostrar

Imagem

Título

Descrição

Categoria

Professor

Curso

Ícone

---

# Empty State

Caso nenhuma informação seja encontrada.

Mostrar

```
Nenhum resultado encontrado.
```

Sugestões

Verificar ortografia

Limpar filtros

Explorar catálogo

---

# APIs

GET /search

GET /search/suggestions

GET /search/recent

GET /search/trending

POST /search/history

DELETE /search/history

GET /courses/search

GET /lessons/search

GET /activities/search

GET /teachers/search

GET /materials/search

GET /blog/search

GET /live/search

---

# Providers

searchProvider

searchSuggestionsProvider

recentSearchProvider

trendingSearchProvider

searchHistoryProvider

searchFilterProvider

---

# Componentes

GlassHeader

SearchBar

QuickFilterBar

RecentSearchCard

TrendingCard

SuggestionCard

SearchResultCard

EmptyState

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Digitando

Atualização em tempo real.

---

## Sem resultados

Exibir Empty State.

---

## Offline

Pesquisar apenas conteúdo armazenado localmente.

---

## Erro

Toast.

Botão

Tentar novamente.

---

# Motion

Fade

Slide

Scale

Blur

Spring

Hero Animation

Shared Transition

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Floating Search Bar

Bottom Navigation

Dialogs

Floating Filter

Nunca aplicar em

Lista de resultados

Cards

Texto

Grid

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

Info

#64D2FF

Text

#1D1D1F

---

# Responsividade

## Desktop

Resultados em duas colunas.

Filtros laterais.

Busca fixa.

---

## Tablet

Layout híbrido.

---

## Mobile

Busca fixa no topo.

Cards empilhados.

Bottom Navigation.

Safe Area.

---

# Performance

Instant Search

Semantic Search

Debounce

Lazy Loading

Cache

Background Refresh

Realtime

Skeleton Loading

60 FPS

---

# Analytics

Pesquisas realizadas

Consultas sem resultado

Termos mais pesquisados

Tempo médio de busca

Conteúdos mais acessados

Taxa de conversão da busca

---

# Segurança

Supabase Auth

JWT

HTTPS

Row Level Security

Rate Limit

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

Escala dinâmica

Alto contraste

Leitura por voz (Future)

---

# Psicologia de Produto

## Zero Fricção

A busca deve ser a forma mais rápida de encontrar qualquer conteúdo da plataforma.

---

## Antecipação

As sugestões devem prever a intenção do usuário antes da conclusão da digitação.

---

## Clareza

Os resultados devem ser organizados por categorias para reduzir a carga cognitiva.

---

## Continuidade

As pesquisas recentes e tendências incentivam o retorno ao conteúdo e facilitam a navegação.

---

# Critérios de Aceitação

- A busca deve pesquisar simultaneamente cursos, aulas, atividades, lives, materiais, professores, certificados, downloads e artigos do blog.
- Os resultados devem ser atualizados em tempo real com debounce de aproximadamente **300 ms**.
- O sistema deve oferecer autocomplete, histórico de pesquisas e sugestões inteligentes.
- Deve existir suporte para busca semântica e filtros por categoria.
- A página deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado exclusivamente em elementos flutuantes.
- A experiência deve ser extremamente rápida, minimalista e inspirada na Apple Spotlight, Raycast e Notion Search.