---
id: PAGE-ADMIN-005
name: Categories Management
route: /admin/categories
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

categories:
  course_categories: true
  hierarchy: true
  ordering: true
  seo: true
  visibility_control: true
  analytics: true
---

# Categories

## Objetivo

A página **Categories Management** permite ao administrador organizar toda a estrutura de categorias da Lawrence Academy.

As categorias são responsáveis pela organização dos cursos, descoberta de conteúdos, filtros do catálogo, recomendações e experiência de navegação dos alunos.

O objetivo é criar uma estrutura simples para o aluno, mas poderosa para a administração.

A experiência deve seguir o padrão minimalista:

- Apple App Store
- Netflix Categories
- MasterClass Categories
- Notion Database
- Shopify Collections

---

# Objetivos

- Criar categorias.
- Editar categorias.
- Organizar catálogo.
- Controlar visibilidade.
- Definir destaque.
- Melhorar descoberta.
- Configurar SEO.
- Analisar desempenho.

---

# Fluxo

```text
Admin

↓

Categories

↓

Criar / Editar

↓

Organizar

↓

Publicar

↓

Atualiza catálogo
```

---

# Layout Desktop

```text
------------------------------------------------

Glass Header

------------------------------------------------

Sidebar

|

Categories Tree

|

Category Details

|

Analytics

------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Categorias

↓

Detalhes

↓

Configurações

↓

Bottom Navigation
```

---

# Estrutura

```text
Glass Header

↓

Categories Overview

↓

Search

↓

Category Tree

↓

Category Editor

↓

Courses Linked

↓

SEO

↓

Analytics
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur 20px

Opacity 72%

---

# Categories Overview

Cards superiores.

Mostrar:

- Total categorias
- Categorias ativas
- Cursos cadastrados
- Mais acessada
- Conversão

---

Exemplo:

```text
24 categorias

18 ativas

340 cursos vinculados
```

---

# Estrutura Hierárquica

Categorias possuem níveis.

Exemplo:

```text
Moda

├── Modelagem

│      ├── Feminina

│      ├── Masculina

│      └── Infantil


├── Costura

│      ├── Básica

│      ├── Industrial

│      └── Alta Costura


└── Negócios de Moda
```

---

# Category Tree

Permitir:

Criar

Editar

Excluir

Duplicar

Reordenar

Mover

Ocultar

---

Drag & Drop:

Ativo

Atualização:

Realtime

---

# Criar Categoria

Campos:

Nome

Slug

Descrição

Categoria Pai

Ícone

Imagem

Cor

Ordem

Status

---

# Status

## Active

Visível no catálogo.

---

## Hidden

Oculta para usuários.

---

## Draft

Em configuração.

---

## Archived

Arquivada.

---

# Category Detail

Mostrar:

Nome

Descrição

Imagem

Cursos vinculados

Número de alunos

Receita gerada

Taxa conversão

---

# Featured Category

Categorias podem aparecer em:

Home

Catálogo

Recomendações

Landing Pages

---

Configurações:

Destaque

Ordem

Imagem Banner

Texto Comercial

---

# Courses Linked

Lista cursos da categoria.

Mostrar:

Curso

Professor

Preço mensal

Alunos

Avaliação

Status

---

Exemplo:

```text
Alta Costura Premium

Professor Ariane

R$89,90/mês

⭐ 4.9
```

---

# SEO Settings

Campos:

SEO Title

Meta Description

Keywords

Open Graph Image

URL Slug

Canonical URL

---

Exemplo:

```text
/modelagem-feminina
```

---

# Category Analytics

Métricas:

Visualizações

Cliques

Cursos vendidos

Conversão

Receita

Assinantes

---

# Ranking

Mostrar:

Categorias mais acessadas

Categorias que mais vendem

Categorias com maior retenção

---

# Permissions

Somente Admin pode:

Criar

Excluir

Arquivar

---

Professor pode:

Selecionar categorias disponíveis.

---

# APIs

GET /admin/categories

GET /admin/categories/{id}

POST /admin/categories

PATCH /admin/categories/{id}

DELETE /admin/categories/{id}

POST /admin/categories/reorder

GET /admin/categories/{id}/courses

GET /admin/categories/{id}/analytics

---

# Providers

categoriesProvider

categoryTreeProvider

categoryEditorProvider

categoryCoursesProvider

categoryAnalyticsProvider

seoProvider

---

# Componentes

GlassHeader

CategoryOverviewCard

CategoryTree

CategoryNode

CategoryEditor

CourseLinkedTable

SeoCard

CategoryAnalytics

ConfirmDialog

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style

---

## Sem categorias

Mostrar:

```text
Nenhuma categoria criada.
```

CTA:

Criar categoria

---

## Categoria ativa

Badge verde.

---

## Categoria oculta

Badge cinza.

---

## Erro

Toast.

---

# Motion

Fade

Slide

Scale

Spring

Drag Animation

Tree Expand Animation

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em:

- Glass Header
- Floating Actions
- Dialogs
- Filters

Nunca aplicar em:

- Árvore de categorias
- Tabelas
- Dados analíticos

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

Árvore lateral.

Editor central.

Analytics lateral.

---

## Tablet

Painéis recolhíveis.

---

## Mobile

Lista simples.

Editor fullscreen.

Bottom Navigation.

---

# Performance

Realtime

Cache

Lazy Loading

Optimistic Update

Virtual Scroll

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

Audit Logs

Versionamento

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Touch Target

44px

Focus Visible

Alto contraste

---

# Psicologia de Produto

## Organização

Categorias precisam ajudar o aluno a encontrar rapidamente o conteúdo certo.

---

## Simplicidade

Mesmo existindo hierarquia complexa, a navegação deve parecer simples.

---

## Descoberta

Boas categorias aumentam vendas e engajamento.

---

## Controle

Toda alteração deve poder ser rastreada.

---

# Critérios de Aceitação

- Administradores devem criar e organizar categorias em árvore.
- Deve existir suporte para categorias e subcategorias.
- Deve permitir Drag & Drop.
- Categorias alimentam catálogo, busca e recomendações.
- Deve possuir configurações SEO.
- Deve medir desempenho das categorias.
- Todas alterações críticas geram Audit Log.
- Deve utilizar Supabase Auth + RLS.
- Deve seguir o Lawrence Design System.
- Liquid Glass somente em elementos flutuantes.
- Experiência inspirada em Apple App Store + Netflix + Notion.