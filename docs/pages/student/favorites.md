---
id: PAGE-STUDENT-010
name: Favorites
route: /dashboard/favorites
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

# Favorites

## Objetivo

A página **Favorites** funciona como a biblioteca pessoal do aluno.

Ela reúne todos os cursos, aulas, artigos, materiais, lives e conteúdos que o usuário marcou como favoritos para acessar rapidamente no futuro.

A experiência deve transmitir organização, praticidade e continuidade do aprendizado.

Não é apenas uma lista de favoritos.

É uma **Biblioteca Inteligente**, organizada automaticamente de acordo com o comportamento do aluno.

Inspirada em:

- Apple Books Library
- Apple Music Library
- Netflix My List
- YouTube Watch Later
- Spotify Library
- Notion Favorites

---

# Objetivos

- Centralizar conteúdos favoritos.
- Facilitar acesso rápido.
- Organizar automaticamente.
- Permitir filtros.
- Permitir pesquisa.
- Mostrar progresso.
- Sincronizar entre dispositivos.

---

# Fluxo

```
Aluno

↓

Marca conteúdo como favorito

↓

Sincronização

↓

Biblioteca Favoritos

↓

Pesquisar

↓

Abrir conteúdo

↓

Continuar estudando
```

---

# Layout Desktop

```
----------------------------------------------------------

Glass Header

----------------------------------------------------------

Sidebar

|

Pesquisa

↓

Categorias

↓

Grid Favoritos

↓

Conteúdo Recomendado

----------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Search

↓

Categorias

↓

Cards

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Favorites Hero

↓

Search

↓

Category Filters

↓

Favorites Grid

↓

Continue Learning

↓

Recommendations

↓

Footer
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

Componentes

Logo

Pesquisar

Notificações

Perfil

---

# Favorites Hero

Mostrar

Título

Quantidade de favoritos

Último acesso

---

Exemplo

```
Minha Biblioteca

42 favoritos

Último acesso há 15 minutos
```

---

# Pesquisa

Pesquisar

Curso

Aula

Professor

Categoria

Material

Pesquisa instantânea.

Debounce

300ms.

---

# Category Filters

Filtros horizontais.

Categorias

Todos

Cursos

Aulas

Materiais

Artigos

Lives

Consultorias

Favoritos Recentes

Mais Assistidos

Concluídos

Não Iniciados

---

# Favorites Grid

Desktop

Grid

3 colunas.

---

Tablet

2 colunas.

---

Mobile

Lista vertical.

---

Cada Card

Imagem

Título

Professor

Categoria

Tempo

Progresso

Data favoritado

Botão Favorito

Botão Abrir

---

# Course Card

Imagem

16:9

Radius

24px

---

Informações

Título

Professor

Categoria

Progresso

Tempo restante

Badge

Favorito

---

# Lesson Card

Mostrar

Curso

Módulo

Aula

Tempo

Status

Botão

Continuar

---

# Material Card

Mostrar

Nome

Tipo

Curso

Professor

Botão

Abrir

Download

---

# Continue Learning

Seção inteligente.

Mostrar conteúdos favoritos iniciados.

Exemplo

```
Continue exatamente de onde parou.
```

Botão

Continuar

---

# Recommendations

IA recomenda novos cursos semelhantes aos favoritos.

Baseado em

Categoria

Professor

Histórico

Tempo assistido

Nível

---

# Organização Automática

Agrupar por

Curso

Professor

Categoria

Último acesso

Recentes

Mais vistos

Nunca acessados

---

# Favoritar

Todo conteúdo possui botão

❤️

ou

★

Ao clicar

Adicionar

↓

Biblioteca

Sincronização imediata.

---

# Remover Favorito

Confirmação opcional.

Animação

Scale

Fade

---

# APIs

GET /favorites

POST /favorites

DELETE /favorites/{id}

GET /favorites/recent

GET /favorites/recommendations

GET /favorites/search

---

# Providers

favoritesProvider

favoriteSearchProvider

favoriteFiltersProvider

recentFavoritesProvider

recommendationProvider

---

# Componentes

GlassHeader

FavoritesHero

SearchBar

CategoryChips

FavoriteCourseCard

FavoriteLessonCard

FavoriteMaterialCard

RecommendationCard

ContinueLearningCard

SkeletonLoader

EmptyState

---

# Estados

## Loading

Skeleton Apple Style.

---

## Sem favoritos

Mostrar ilustração.

Mensagem

```
Você ainda não possui favoritos.

Adicione cursos e aulas para encontrá-los rapidamente.
```

Botão

Explorar Cursos

---

## Pesquisa sem resultado

Mostrar

Nenhum favorito encontrado.

---

## Offline

Mostrar favoritos sincronizados.

---

## Erro

Botão

Tentar novamente.

---

# Motion

Fade

Slide

Scale

Shared Transition

Hero Animation

Spring

Hover

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Search

Floating Filters

Bottom Navigation

Floating Action Button

Modal

Nunca aplicar em

Cards

Texto

Lista

Conteúdo

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

Favorito

#FF375F

Sucesso

#30D158

Texto

#1D1D1F

---

# Responsividade

## Desktop

Grid 3 colunas.

Sidebar fixa.

---

## Tablet

Grid 2 colunas.

---

## Mobile

Cards empilhados.

Bottom Navigation.

Safe Area.

---

# Performance

Lazy Loading

Infinite Scroll

Cache Local

Shimmer

Image Cache

60 FPS

Busca instantânea

---

# Analytics

Quantidade de favoritos

Categorias favoritas

Cursos mais favoritados

Tempo até reabertura

Conteúdo mais acessado

Taxa de reutilização

---

# Segurança

Supabase Auth

JWT

HTTPS

OWASP Top 10

Role Guard

Ownership Guard

Sincronização criptografada

Controle de acesso por matrícula

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

Escala dinâmica de fonte

---

# Psicologia de Produto

## Endowment Effect

Quando um aluno adiciona um conteúdo aos favoritos, ele passa a percebê-lo como parte da sua biblioteca pessoal, aumentando o vínculo com a plataforma.

---

## Recognition Over Recall

A biblioteca elimina a necessidade de lembrar onde estava determinado conteúdo.

O aluno encontra tudo rapidamente.

---

## Continue Learning

Sempre mostrar primeiro os conteúdos iniciados.

Exemplo

```
Continue de onde você parou.
```

---

## Personalização

As recomendações utilizam IA para sugerir conteúdos relacionados aos favoritos do aluno.

---

## Redução da Carga Cognitiva

Agrupamento automático evita listas enormes e melhora a navegação.

---

# Critérios de Aceitação

- O aluno deve conseguir favoritar cursos, aulas, materiais, artigos e eventos.
- Todos os favoritos devem ser sincronizados entre Web e Android em tempo real.
- A página deve oferecer pesquisa instantânea e filtros por categoria, status e data.
- O sistema deve apresentar recomendações inteligentes baseadas nos favoritos do usuário.
- Os conteúdos iniciados devem aparecer em destaque na seção **Continue Learning**.
- O layout deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado exclusivamente em elementos flutuantes.
- A experiência deve transmitir a sensação de uma biblioteca pessoal premium, organizada e inteligente, mantendo a identidade visual minimalista inspirada no ecossistema Apple.