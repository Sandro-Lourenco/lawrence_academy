````markdown
---
id: PAGE-PUBLIC-008
name: Blog
route: /blog
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

# Blog Page

## Objetivo

O Blog da Lawrence Academy é uma plataforma de conteúdo editorial voltada para Costura, Modelagem, Moda, Alta Costura, Empreendedorismo e Desenvolvimento Profissional.

Seu principal objetivo é educar, gerar autoridade, melhorar o SEO orgânico da plataforma e converter leitores em alunos.

O blog deve transmitir a sensação de uma revista digital premium, inspirada no Apple News, Medium, Notion e MasterClass Journal.

A interface deve ser extremamente limpa, priorizando a leitura.

---

# Objetivos de Negócio

- Aumentar tráfego orgânico.
- Melhorar posicionamento SEO.
- Atrair novos alunos.
- Fortalecer autoridade.
- Gerar leads.
- Apoiar lançamentos.
- Alimentar redes sociais.
- Melhorar retenção.

---

# Objetivos do Usuário

O visitante deve conseguir:

- Encontrar artigos facilmente.
- Pesquisar conteúdos.
- Filtrar por categoria.
- Salvar artigos.
- Compartilhar.
- Ler confortavelmente.
- Descobrir cursos relacionados.

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

Hero

↓

Featured Articles

↓

Search

↓

Categories

↓

Latest Articles

↓

Popular Articles

↓

Newsletter

↓

Related Courses

↓

Footer
```

---

# Header

Tipo

Sticky

Transparent

Liquid Glass

---

# Hero

## Objetivo

Apresentar o blog como uma revista digital.

---

## Conteúdo

Título

Lawrence Journal

Subtítulo

Artigos, tendências, tutoriais e conteúdos exclusivos sobre Costura, Moda e Modelagem.

Imagem editorial premium.

Botão

Explorar Artigos

---

# Featured Articles

## Desktop

3 artigos grandes

---

## Mobile

Carousel

---

Cada artigo possui

Imagem

Categoria

Tempo de leitura

Título

Resumo

Autor

Data

Botão

Ler artigo

---

# Search

Pesquisa instantânea.

Placeholder

Pesquisar artigos...

---

Busca por

Título

Categoria

Autor

Tags

Conteúdo

---

# Categories

Chips horizontais

Costura

Modelagem

Moda

Alta Costura

Empreendedorismo

Negócios

Máquinas

Tecidos

Tendências

Dicas

Eventos

Tutoriais

---

# Latest Articles

Grid

Desktop

3 Colunas

Tablet

2 Colunas

Mobile

1 Coluna

---

# Estrutura do Card

Imagem

Categoria

Título

Resumo

Autor

Tempo de leitura

Data

Botão

Continuar lendo

---

# Popular Articles

Carousel

Mais Lidos

Mais Compartilhados

Mais Comentados

---

# Newsletter

Card Premium

Título

Receba novos conteúdos.

Descrição

Receba artigos e novidades diretamente no seu e-mail.

Campo

Email

Botão

Inscrever-se

---

# Related Courses

Carousel

Cursos relacionados ao artigo.

Cada card possui

Imagem

Título

Professor

Preço

Botão

Conhecer Curso

---

# Footer

Institucional

---

# Componentes Utilizados

GlobalHeader

GlassNavigation

HeroBanner

ArticleCard

FeaturedArticle

CategoryChip

SearchInput

NewsletterCard

CourseCarousel

Footer

---

# APIs

GET /api/blog

GET /api/blog/featured

GET /api/blog/latest

GET /api/blog/popular

GET /api/blog/categories

GET /api/blog/search

GET /api/blog/tags

POST /api/newsletter

---

# Query Parameters

search

category

author

tag

page

sort

---

# Estados

Loading

Skeleton

Offline

Erro

Nenhum artigo encontrado

---

# SEO

Meta Title

Meta Description

Canonical URL

Open Graph

Twitter Card

Schema.org Blog

Schema.org Article

Breadcrumb

RSS Feed

Sitemap

---

# Performance

Lazy Loading

Infinite Scroll

Compressão de imagens

Prefetch

Cache

SSR

---

# Motion

Fade

Card Hover

Smooth Scroll

Hero Reveal

Scale

Parallax

---

# Liquid Glass

Aplicar apenas em

Header

Search Bar

Floating Search

Floating Newsletter

Bottom Sheet Mobile

Nunca aplicar em

Cards

Artigos

Conteúdo

Texto

Categorias

---

# Responsividade

## Desktop

Grid 3 Colunas

Pesquisa expandida

Categorias em linha

---

## Tablet

Grid 2 Colunas

---

## Mobile

Grid 1 Coluna

Pesquisa fixa

Categorias em Scroll Horizontal

Bottom Navigation

---

# Analytics

Artigos mais lidos

Tempo médio de leitura

CTR

Compartilhamentos

Cliques em cursos

Newsletter

Origem do tráfego

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

Screen Reader

Texto escalável

Alto Contraste

Touch Target 44x44px

---

# Integração com Cursos

Cada artigo poderá possuir:

- Cursos relacionados
- Professor relacionado
- Categoria relacionada
- CTA para matrícula
- Banner contextual
- Produtos relacionados

---

# Integração com IA (Opcional)

A plataforma poderá oferecer:

- Resumo automático do artigo.
- Sugestão de leitura.
- Perguntas frequentes geradas por IA.
- Recomendações de cursos baseadas na leitura.
- Pesquisa semântica utilizando IA.

---

# Estrutura do Artigo

Cada artigo contém

Hero Image

Título

Autor

Data

Tempo de leitura

Categorias

Tags

Conteúdo

Imagens

Galerias

Vídeos

Blocos de destaque

Citações

Tabela

Código (quando necessário)

Downloads

Cursos relacionados

Comentários (opcional)

Compartilhar

Curtir

Salvar

---

# Psicologia de Conversão

## Educação antes da Venda

O blog deve ensinar primeiro e vender depois.

O CTA para cursos deve aparecer de forma contextual, relacionado ao conteúdo lido.

## Autoridade

Mostrar professores, especialistas e referências.

## Conteúdo Escaneável

Utilizar:

- Títulos claros
- Espaçamento generoso
- Listas
- Imagens grandes
- Destaques
- Blocos informativos

## Prova Social

Mostrar:

Quantidade de leituras

Curtidas

Compartilhamentos

Cursos relacionados

---

# Critérios de Aceitação

- A página deve carregar em menos de 2 segundos.
- O Hero deve destacar o posicionamento editorial da Lawrence Academy.
- A busca deve funcionar em tempo real com debounce.
- Os artigos devem utilizar lazy loading e paginação infinita.
- Todos os componentes devem seguir o Lawrence Design System.
- O efeito Liquid Glass deve ser aplicado apenas em elementos flutuantes.
- Os artigos devem ser altamente otimizados para SEO.
- A leitura deve ser confortável em qualquer dispositivo.
- A experiência deve lembrar uma revista digital premium, elegante, minimalista e focada em conteúdo de alta qualidade.
```
````
