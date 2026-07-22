````markdown
---
id: PAGE-PUBLIC-002
name: Course Catalog
route: /courses
layout: PublicLayout
platforms:
  - Web
  - Android
roles:
  - Guest
  - Student
authentication: false
responsive: true
status: Production
design-system: Lawrence Design System
seo: true
---

# Course Catalog

> Implementação canônica da fase de Catálogo: busca e filtros utilizam os query
> parameters `q`, `category`, `level` e `access`. Cards exibem somente campos
> presentes no contrato atual. Avaliação, quantidade de alunos, duração,
> certificado, ordenação e coleções editoriais não devem ser simulados.

## Composição aprovada

1. Título e descrição da tarefa.
2. Campo de pesquisa com label persistente e debounce de 300 ms.
3. Filtro de acesso: todos, gratuitos ou assinatura mensal.
4. Categoria e nível em sidebar no desktop ou bottom sheet nas demais faixas.
5. Quantidade de resultados.
6. Lista responsiva de cursos.

### Responsividade

- Mobile: uma coluna e filtros em bottom sheet.
- Tablet: duas colunas e filtros em bottom sheet.
- Desktop: sidebar de 280 px e até três colunas no espaço restante.

As colunas podem diminuir quando a escala de texto ou a largura disponível
exigirem. Não reduzir fonte para preservar uma quantidade fixa de cards.

### Estados

- loading: skeleton equivalente aos cards;
- success: quantidade e resultados;
- empty: explicação e ação “Limpar filtros”;
- error: mensagem humana e retry;
- offline: erro recuperável até existir cache de catálogo documentado.

### Acessibilidade

- busca possui label visível;
- filtros possuem nome de grupo, seleção e área adequada;
- resultado atualizado é anunciado como live region;
- card informa título, nível, aulas, preço e periodicidade;
- motion de pressão é removido quando `disableAnimations` estiver ativo.

## Objetivo

A página de catálogo é o principal ponto de descoberta da plataforma.

Seu objetivo é permitir que qualquer visitante encontre rapidamente um curso utilizando busca, filtros inteligentes e categorias.

A experiência deve ser extremamente simples, rápida e inspirada em plataformas premium como Apple Store, Apple TV e MasterClass.

O usuário nunca deve sentir que está navegando em um marketplace poluído.

A fotografia dos cursos é o elemento protagonista.

---

# Objetivos de Negócio

- Aumentar conversão dos cursos
- Facilitar descoberta de novos cursos
- Incentivar compra de assinatura
- Melhorar retenção
- Mostrar cursos recomendados
- Destacar lançamentos
- Destacar cursos mais vendidos

---

# Objetivos do Usuário

O visitante deve conseguir:

- Encontrar um curso rapidamente
- Pesquisar por nome
- Filtrar cursos
- Comparar cursos
- Ver avaliações
- Conhecer o professor
- Abrir detalhes
- Comprar

---

# Layout

Desktop

12 Columns

1440px

Tablet

8 Columns

Mobile

4 Columns

---

# Estrutura

```
Header

↓

Hero Search

↓

Categories

↓

Featured Collections

↓

Filter Bar

↓

Course Grid

↓

Pagination

↓

CTA

↓

Footer
```

---

# Header

## Tipo

Sticky

Liquid Glass

Transparent

---

## Componentes

Logo

Pesquisar

Categorias

Cursos

Ao Vivo

Entrar

Criar Conta

---

# Hero Search

## Objetivo

Permitir que o usuário encontre qualquer curso imediatamente.

---

## Componentes

Título

Barra de pesquisa

Sugestões

Botão Buscar

Imagem editorial

---

## Placeholder

Pesquisar cursos...

Exemplos

Costura

Modelagem

Alfaiataria

Vestido de Festa

Moulage

Modelagem Infantil

---

# Categorias

Categorias principais

- Costura
- Modelagem
- Alta Costura
- Moda Feminina
- Moda Masculina
- Moda Infantil
- Moulage
- Patchwork
- Bordado
- Estilo
- Consultorias
- Cursos Ao Vivo
- Mini Cursos

---

## Componente

CategoryChip

Formato

Pill

Radius

999px

Estado

Normal

Hover

Selected

Disabled

---

# Featured Collections

Coleções especiais

Mais vendidos

Novidades

Recomendados

Em alta

Cursos gratuitos

Cursos Premium

---

# Filter Bar

## Pesquisa

Texto

---

## Categoria

Dropdown

---

## Professor

Dropdown

---

## Dificuldade

Todos

Iniciante

Intermediário

Avançado

Especialista

---

## Tipo

Curso

Mini Curso

Consultoria

Workshop

Ao Vivo

---

## Duração

Até 2 horas

2-5 horas

5-10 horas

Mais de 10 horas

---

## Certificado

Sim

Não

---

## Ordenação

Mais relevantes

Mais vendidos

Mais recentes

Melhor avaliados

Menor preço

Maior preço

Alfabética

---

# Course Grid

Desktop

4 Cards

Tablet

3 Cards

Mobile

2 Cards

---

# Estrutura do Card

Imagem

Categoria

Título

Professor

Avaliação

Quantidade de alunos

Tempo

Quantidade de aulas

Certificado

Preço

Botão

---

# Informações do Card

Imagem 16:9

Border Radius

24px

Borda

1px

Shadow

Muito suave

Nunca utilizar gradientes.

---

# Hover

Desktop

Leve elevação

Scale

1.02

Shadow Soft

Imagem com pequeno zoom

---

# Clique

Scale

0.98

---

# Indicadores

NOVO

MAIS VENDIDO

PREMIUM

AO VIVO

PROMOÇÃO

CERTIFICADO

---

# Barra de Pesquisa

Busca instantânea

Autocomplete

Histórico

Sugestões

Correção ortográfica

Busca por:

Curso

Professor

Categoria

Tema

---

# Resultados

Quantidade encontrada

Tempo da busca

Filtros ativos

---

# Empty State

Ilustração minimalista

Mensagem

Nenhum curso encontrado.

Botão

Limpar filtros

---

# Loading

Skeleton

Cards

Imagem

Título

Professor

Preço

---

# Offline

Mensagem

Sem conexão.

Botão

Tentar novamente.

---

# Error

Mensagem

Erro ao carregar catálogo.

Botão

Atualizar.

---

# Paginação

Desktop

Infinite Scroll

Mobile

Infinite Scroll

Sempre utilizar Lazy Loading.

---

# CTA

Título

Não encontrou o curso ideal?

Botão

Fale com nossa equipe.

---

# Footer

Institucional

---

# Componentes Utilizados

GlobalHeader

GlassNavigation

HeroSearch

SearchInput

CategoryChip

FilterBar

Dropdown

CourseCard

Badge

Pagination

Footer

FloatingSearch

---

# APIs

GET /api/courses

GET /api/categories

GET /api/instructors

GET /api/course-tags

GET /api/course-levels

GET /api/recommended

---

# Query Parameters

search

category

teacher

level

price

duration

certificate

type

sort

page

limit

---

# Analytics

Pesquisar curso

Filtro aplicado

Curso aberto

Tempo de navegação

Categoria mais acessada

CTR dos cards

Conversão

---

# Motion

Fade

Scale

Blur

Hero Transition

Card Elevation

Chip Animation

Smooth Scroll

---

# Liquid Glass

Aplicar apenas em

Header

Search Bar

Floating Filter

Bottom Sheet (Mobile)

Quick Actions

Nunca aplicar em

Cards

Grid

Conteúdo

Categorias

---

# Segurança

Nunca expor vídeos.

Nunca exibir URLs privadas.

Todas as imagens devem utilizar URLs assinadas quando necessário.

Respeitar permissões de cursos privados.

---

# Acessibilidade

WCAG AA

Navegação por teclado

Leitor de tela

TalkBack

Alto contraste

Touch Target mínimo de 44x44px

Texto alternativo para imagens

---

# Performance

Lazy Loading

Infinite Scroll

Cache

Prefetch de imagens

Compressão

Busca otimizada

Debounce de pesquisa

Virtualização da lista

---

# Responsividade

## Desktop

Grid de 4 colunas

Sidebar de filtros opcional

Pesquisa expandida

Hover disponível

---

## Tablet

Grid de 3 colunas

Filtros recolhíveis

---

## Mobile

Grid de 2 colunas

Pesquisa fixa

Filtros em Bottom Sheet

Categorias em Scroll Horizontal

FAB para filtros

Bottom Navigation

---

# Critérios de Aceitação

- O catálogo deve carregar em menos de 2 segundos.
- A pesquisa deve responder em tempo real com debounce.
- Os filtros devem ser combináveis.
- O grid deve ser totalmente responsivo.
- Os cartões devem seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve existir apenas nos elementos flutuantes.
- As imagens devem utilizar lazy loading.
- Infinite Scroll deve funcionar sem recarregar a página.
- O estado vazio, erro, loading e offline devem estar implementados.
- A experiência deve transmitir a sensação de uma plataforma premium, organizada e minimalista.
```
````
