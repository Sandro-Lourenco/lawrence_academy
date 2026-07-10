---
id: SHARED-007
name: Search System
path: /shared/search
type: Shared Component + Search Architecture
platforms:
  - Web
  - Android

usage:
  - Public Catalog
  - Student Dashboard
  - Teacher Dashboard
  - Admin Dashboard

framework:
  frontend: Flutter
  backend: Python
  database: Supabase PostgreSQL
  state_management: Riverpod

design-system: Lawrence Design System

style:
  minimal: true
  liquid_glass: true
  apple_inspired: true
  intelligent_search: true
---

# Search System

## Objetivo

O **Search System** define o padrão global de pesquisa da Lawrence Academy.

Toda busca da plataforma deve ser:

- Instantânea
- Inteligente
- Contextual
- Simples
- Visualmente limpa

O usuário nunca deve sentir que está pesquisando em um banco de dados.

A experiência deve parecer uma busca nativa Apple Spotlight.

Inspirado em:

- Apple Spotlight
- App Store Search
- Netflix Search
- YouTube Search
- Notion Search
- Linear Command Search

---

# Filosofia

A busca deve responder:

```text
"Estou procurando algo"

não:

"Preciso configurar filtros complexos"
```

---

# Tipos de Busca

A plataforma possui:

```text
Global Search

Course Search

Student Search

Teacher Search

Admin Search

Command Search

Filter Search

Recent Search
```

---

# Arquitetura

```text
Search UI

↓

Riverpod Controller

↓

Search UseCase

↓

Repository

↓

Python API

↓

Supabase PostgreSQL
```

---

# Search Component

Flutter:

```dart
SearchInput(
 hint,
 controller,
 filters,
 onChanged
)
```

---

# Visual

## Container

Formato:

Pill

---

Altura:

```text
52px
```

---

Radius:

```text
999px
```

---

Background:

```text
#F5F5F7
```

---

# Focus State

Quando ativo:

```text
Border:

#0A84FF

2px


Scale:

1.01
```

---

# Liquid Glass Search

Usado quando:

- Header fixo
- Floating Search
- Overlay Search

---

Config:

```text
Blur 20px

Opacity 72%

Radius 999px
```

---

Não aplicar:

- Resultado da busca
- Texto
- Cards

---

# Global Search

Atalho principal.

Busca:

- Cursos
- Aulas
- Professores
- Materiais
- Configurações

---

Exemplo:

```text
Pesquisar na Lawrence...
```

---

Resultado:

```text
Cursos

Alta Costura


Aulas

Como tirar medidas


Professores

Ariane Oliveira
```

---

# Public Search

Usado no catálogo.

Busca:

- Nome curso
- Categoria
- Professor
- Tags

---

Possui:

Sugestões

Filtros

Histórico

---

# Student Search

Busca:

```text
Meus cursos

Aulas

Materiais

Certificados

Lives

Atividades
```

---

Exemplo:

Aluno digita:

```text
molde saia
```

Retorna:

```text
Aula

Construção molde saia


PDF

Guia de medidas
```

---

# Teacher Search

Busca:

```text
Cursos

Alunos

Atividades

Materiais

Comentários

Relatórios
```

---

Exemplo:

```text
Maria Silva
```

Resultado:

```text
Aluno

Curso inscrito

Última atividade
```

---

# Admin Search

Busca global administrativa.

Buscar:

- Usuários
- Professores
- Cursos
- Pagamentos
- Assinaturas
- Logs

---

Exemplo:

```text
Pagamento Ana
```

Resultado:

```text
Aluno Ana

Curso Premium

R$89,90/mês

Pago
```

---

# Search Overlay

Quando abrir:

```text
Blur Background

↓

Search Bar

↓

Recentes

↓

Resultados
```

---

Usa:

Liquid Glass Background.

---

# Recent Searches

Salvar:

Localmente

Hive

---

Exemplo:

```text
Pesquisas recentes:

Alta Costura

Moldes

Certificados
```

---

# Suggestions

Antes do usuário terminar:

Mostrar:

Cursos populares

Categorias

Histórico

---

# Autocomplete

Após:

```text
300ms debounce
```

---

Exemplo:

Digite:

```text
mod
```

Sugere:

```text
Modelagem Feminina

Modelagem Infantil
```

---

# Filters

Pesquisa avançada.

Aparece via:

Bottom Sheet Mobile

Popover Desktop

---

Filtros:

Categoria

Preço

Avaliação

Professor

Data

Status

---

# Sorting

Opções:

Mais relevante

Mais recente

Mais popular

Melhor avaliado

---

# Search Empty State

Nunca:

```text
0 resultados
```

---

Usar:

```text
Não encontramos "xyz".

Tente outro termo ou ajuste filtros.
```

---

# Search Loading

Sempre:

Skeleton.

---

Fluxo:

```text
Digitando

↓

Debounce

↓

Skeleton

↓

Resultados
```

---

# Search Error

Mensagem:

```text
Não conseguimos buscar agora.

Tente novamente.
```

---

# Offline Search

Android.

Buscar local:

SQLite

Hive Cache

---

Disponível:

Cursos baixados

Aulas offline

Materiais

Favoritos

---

# Inteligência

Preparado para:

AI Search Future

---

Futuro:

```text
"Quero aprender fazer vestido de festa"
```

Resultado:

Cursos recomendados.

---

# Ranking Algorithm

Ordenação considera:

```text
Texto

+

Popularidade

+

Avaliação

+

Histórico

+

Engajamento
```

---

# Backend Search

Python:

Serviço:

```text
SearchService
```

---

Responsável:

Normalização

Ranking

Filtros

Paginação

---

# Supabase

Utilizar:

PostgreSQL Full Text Search

Indexes

Views

RPC Functions

---

# Search Index

Criar:

```text
search_index
```

Campos:

```text
id

entity_type

entity_id

title

description

keywords

ranking

created_at
```

---

# APIs

GET /search

GET /search/suggestions

GET /search/recent

DELETE /search/recent


GET /admin/search

GET /teacher/search

GET /student/search

---

# Providers

```dart
searchProvider

searchControllerProvider

recentSearchProvider

suggestionProvider

filterProvider
```

---

# Components

```text
SearchInput

GlassSearchBar

SearchOverlay

SearchResultCard

SearchSuggestion

SearchFilterSheet

RecentSearchList

SearchEmptyState
```

---

# Flutter Structure

```text
shared/

 search/

   search_input.dart

   glass_search.dart

   search_overlay.dart

   search_controller.dart

   search_result.dart
```

---

# Motion

Abrir:

```text
Scale + Fade
250ms
```

---

Digitação:

Instant feedback.

---

Resultados:

Fade list.

---

# Responsividade

## Desktop

Command Palette.

Shortcut:

CTRL + K

---

## Mobile

Full Search View.

Keyboard automático.

Bottom Sheet Filters.

---

# Performance

Obrigatório:

Debounce

Cache

Pagination

Indexes

Lazy Loading

Virtual List

---

Meta:

```text
Resultado < 300ms
```

---

# Segurança

Admin Search respeita:

RBAC

RLS

---

Usuário nunca encontra:

Dados sem permissão.

---

Não indexar:

Senha

Tokens

Dados sensíveis

---

# Acessibilidade

WCAG AA

Suporte:

TalkBack

VoiceOver

Keyboard Navigation

---

Estados anunciados:

```text
10 resultados encontrados.
```

---

# Psicologia de Produto

## Rapidez

O usuário deve encontrar antes de navegar.

---

## Descoberta

Pesquisa também recomenda.

---

## Simplicidade

Não parecer consulta técnica.

---

## Inteligência

Quanto mais usa, melhor fica.

---

# Critérios de Aceitação

- Deve existir busca global reutilizável.
- Deve funcionar em aluno, professor e admin.
- Deve usar debounce.
- Deve possuir sugestões e recentes.
- Deve funcionar parcialmente offline no Android.
- Deve usar PostgreSQL Full Text Search.
- Deve respeitar Supabase RLS.
- Deve seguir Clean Architecture.
- Liquid Glass somente em Search flutuante.
- Deve funcionar em Flutter Web e Android.
- Experiência inspirada em Apple Spotlight.