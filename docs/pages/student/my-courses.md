---
id: PAGE-STUDENT-002
name: My Courses
route: /dashboard/my-courses
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

# My Courses

## Objetivo

A página **Meus Cursos** concentra todos os cursos adquiridos pelo aluno.

Ela funciona como uma biblioteca pessoal premium, permitindo continuar rapidamente os estudos, acompanhar o progresso, acessar cursos concluídos, cursos offline e descobrir novos conteúdos relacionados.

A experiência deve ser extremamente limpa, inspirada em:

- Apple TV+
- Apple Books
- Apple Fitness+
- MasterClass
- Coursera
- Notion

A interface nunca deve parecer uma lista administrativa.

O foco sempre é o conteúdo.

---

# Objetivos

- Facilitar o acesso aos cursos.
- Continuar exatamente da última aula.
- Mostrar progresso.
- Mostrar certificados.
- Mostrar cursos baixados.
- Organizar cursos.
- Melhorar retenção.

---

# Layout Desktop

```
-------------------------------------------------------------

Glass Header

-------------------------------------------------------------

Sidebar

↓

Filtros

↓

Grid de Cursos

-------------------------------------------------------------
```

Grid

12 colunas

Cards grandes

3 colunas

---

# Layout Mobile

```
Glass Header

↓

Pesquisa

↓

Filtros Horizontais

↓

Lista de Cursos

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

Category Filter

↓

Status Filter

↓

Sorting

↓

Continue Learning

↓

Course Grid

↓

Recommendations

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

Pesquisa

Notificações

Perfil

---

# Search

Pesquisar cursos

Pesquisar professor

Pesquisar categoria

Pesquisar módulo

Pesquisar aula

Pesquisa em tempo real

Debounce

300ms

---

# Filters

Categorias

Todos

Costura

Modelagem

Moda

Alta Costura

Style Design

Mini Cursos

Consultorias

Lives

---

Status

Todos

Em andamento

Concluído

Não iniciado

Offline

Favoritos

---

Ordenação

Mais recentes

Mais acessados

Nome

Professor

Progresso

Última atividade

---

# Continue Learning

Sempre o primeiro card.

Grande destaque.

---

Conteúdo

Imagem

Curso

Professor

Última aula

Tempo restante

Barra de progresso

Botão

Continuar

---

Ao clicar

↓

Abrir última aula.

---

# Grid de Cursos

Desktop

3 colunas

Tablet

2 colunas

Mobile

Lista vertical

---

# Course Card

Imagem

16:9

Border Radius

24px

---

Informações

Título

Professor

Categoria

Avaliação

Progresso

Tempo restante

Última aula

---

Botões

Continuar

Detalhes

Mais opções

---

Badge

Novo

Offline

Concluído

Atualizado

Favorito

---

# Menu do Card

Continuar

Ver detalhes

Baixar

Compartilhar

Favoritar

Adicionar à lista

Ocultar

---

# Página de Detalhes

Ao clicar

↓

Course Detail

---

# Progresso

Linear Progress

Azul

Spring Animation

---

Texto

72%

Concluído

---

Mensagem

Faltam apenas

4 aulas.

---

# Downloads

(Android)

Mostrar

Disponível Offline

Espaço ocupado

Atualizar Download

Excluir Download

---

Web

Mensagem

Disponível somente no aplicativo.

---

# Cursos Concluídos

Separados em seção própria.

---

Card

Imagem

Nome

Professor

Data

Nota

Certificado

Botão

Visualizar Certificado

---

# Cursos Favoritos

Opcional

Lista personalizada.

---

# Recomendações

IA

Cursos relacionados

Próximo nível

Especializações

Lives

---

Carousel

---

# Estados

Loading

Skeleton Apple Style

---

Sem cursos

Mostrar

Ilustração

Mensagem

Você ainda não possui cursos.

Botão

Explorar Catálogo

---

Offline

Mostrar cache.

---

Erro

Mensagem elegante.

Botão

Tentar novamente.

---

# APIs

GET /student/courses

GET /student/course-progress

GET /student/downloads

GET /student/favorites

GET /student/recommendations

GET /student/history

---

# Providers

myCoursesProvider

courseProgressProvider

favoritesProvider

downloadsProvider

recommendationsProvider

filtersProvider

searchProvider

---

# Componentes

GlassHeader

SearchBar

FilterChips

SortingButton

CourseCard

ContinueLearningCard

ProgressBar

FavoriteButton

DownloadBadge

RecommendationCarousel

SkeletonLoader

EmptyState

ErrorCard

---

# Motion

Fade

Scale

Slide

Shared Transition

Hero Animation

Spring

Blur

Hover

Skeleton

---

# Liquid Glass

Aplicar apenas em

Glass Header

Search Bar

Floating Filters

Bottom Navigation

Floating Action Button

Modal

Nunca aplicar em

Cards

Grid

Texto

Imagens

Conteúdo principal

---

# Tipografia

Título

36px

Bold

---

Heading

28px

Semibold

---

Subheading

22px

Semibold

---

Body

17px

Regular

---

Caption

13px

Regular

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

---

Status

Concluído

#30D158

---

Offline

#8E8E93

---

Erro

#FF453A

---

# Responsividade

## Desktop

Sidebar fixa

Grid 3 colunas

Cards grandes

Hover

---

## Tablet

Grid 2 colunas

Sidebar recolhida

---

## Mobile

Bottom Navigation

Cards verticais

Filtros horizontais

Scroll infinito

Safe Area

---

# Performance

Lazy Loading

Cache Inteligente

Pré-carregar thumbnails

Pré-carregar progresso

Infinite Scroll

60 FPS

Shimmer

Hero Animation GPU

---

# Analytics

Cursos iniciados

Cursos concluídos

Tempo estudado

Última atividade

Cursos favoritos

Downloads

CTR das recomendações

Abandono

Retenção

---

# Segurança

Supabase Auth

JWT

HTTPS

OWASP Top 10

Validação de assinatura

Validação de compra

Proteção contra acesso não autorizado

Downloads criptografados (Android)

Zero MP4 exposto

Streaming HLS + DRM

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Screen Reader

Focus Visible

Touch Target

44x44px

Escala dinâmica de fontes

Alto contraste

---

# Psicologia de Conversão

## Efeito Zeigarnik

O curso em andamento deve sempre aparecer em primeiro lugar, incentivando o aluno a concluir o que já iniciou.

---

## Goal Gradient Effect

Exibir mensagens motivacionais:

- "Você está a apenas 2 aulas do certificado."
- "Continue, faltam apenas 15 minutos."

---

## Personalização

As recomendações devem considerar:

- Histórico de estudo
- Categorias favoritas
- Cursos concluídos
- Tempo de permanência
- Avaliações realizadas

---

## Gamificação

Exibir discretamente:

- Sequência de estudos
- Dias consecutivos
- Certificados conquistados
- Conquistas
- Medalhas
- Barra de progresso

Sem poluir a interface.

---

# Critérios de Aceitação

- O curso em andamento deve ser sempre exibido no topo da página.
- O aluno deve conseguir pesquisar cursos por nome, professor, categoria ou conteúdo.
- Os filtros devem funcionar em tempo real sem recarregar a página.
- Os cards devem apresentar progresso, última aula, status e ações rápidas.
- O layout deve seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve ser aplicado apenas em elementos flutuantes.
- O Android deve permitir visualizar e gerenciar cursos baixados para uso offline.
- A Web deve ocultar funcionalidades exclusivas de download offline.
- Todas as listas devem utilizar Skeleton Loading durante o carregamento.
- A experiência deve ser premium, minimalista e centrada no aprendizado.
````
