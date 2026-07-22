````markdown
---
id: PAGE-PUBLIC-003
name: Course Detail
route: /courses/:slug
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

# Course Detail Page

> Implementação canônica da fase de curso não adquirido: a interface apresenta
> apenas campos disponíveis no contrato `Course` e usa a elegibilidade de
> checkout como autoridade para acesso e assinatura. Conteúdo ilustrativo não
> pode ser promovido a dado real.

## Composição aprovada

1. Voltar ao catálogo.
2. Categoria, nível, título e resumo.
3. Estado explícito da prévia; nenhum player falso.
4. Quantidade real de módulos e aulas.
5. Currículo público com conteúdo protegido identificado.
6. Painel comercial com preço mensal e recorrência.
7. CTA derivado de autenticação e elegibilidade.

Instrutor, avaliações, alunos, duração, materiais, requisitos, descontos e
trailer somente podem aparecer quando existirem no contrato retornado pela API.

### CTAs por estado

- anônimo: `Entrar para assinar` ou `Entrar para acessar`;
- elegível: `Assinar curso`;
- gratuito elegível: `Liberar acesso gratuito` pelo fluxo autorizado;
- com acesso: `Acessar curso`;
- pagamento vencido: `Regularizar assinatura`;
- elegibilidade indisponível: ação desativada e mensagem recuperável.

### Regras comerciais

- Cada curso possui assinatura mensal independente.
- Preço sempre vem do backend.
- A interface não calcula desconto.
- Cancelamento e gerenciamento são separados por curso.
- Certificado depende de conclusão e aprovação; não é liberado apenas por
  progresso visual.

### Responsividade

- Mobile/tablet estreito: conteúdo e painel comercial empilhados.
- Desktop: conteúdo principal e painel comercial lateral de 340 px.
- Texto ampliado pode aumentar a altura dos componentes sem truncamento.

### Segurança e acessibilidade

- Conteúdo protegido não possui URL pública ou MP4 exposto.
- Currículo informa textualmente o bloqueio.
- Estado de elegibilidade possui loading, error e retry acessíveis.
- Botões possuem label textual e área mínima de 48 dp.

## Objetivo

A página de detalhes do curso é a principal Landing Page de conversão da Lawrence Academy.

Seu objetivo é convencer o visitante de que aquele curso é a melhor escolha para sua evolução profissional.

Esta página deve seguir um estilo editorial, inspirado na Apple Store, Apple TV+, MasterClass e plataformas premium.

A fotografia e o vídeo são protagonistas.

A interface deve desaparecer.

A decisão de compra deve acontecer naturalmente.

---

# Objetivos de Negócio

- Converter visitantes em alunos
- Demonstrar autoridade do instrutor
- Explicar o conteúdo do curso
- Reduzir dúvidas antes da compra
- Aumentar a taxa de conversão
- Incentivar assinatura mensal
- Melhorar SEO

---

# Objetivos do Usuário

O visitante deve conseguir:

- Entender o curso
- Assistir ao trailer
- Conhecer o professor
- Ver o conteúdo completo
- Ler avaliações
- Ver requisitos
- Comprar imediatamente
- Compartilhar o curso

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

Video Trailer

↓

Purchase Card

↓

Course Overview

↓

Learning Outcomes

↓

Instructor

↓

Curriculum

↓

Requirements

↓

Materials Included

↓

Certificates

↓

Student Reviews

↓

FAQ

↓

Related Courses

↓

Final CTA

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

## Componentes

Logo

Pesquisar

Cursos

Ao Vivo

Entrar

Perfil

---

# Hero Section

Grande fotografia editorial.

Imagem do curso.

Título.

Categoria.

Professor.

Avaliação.

Quantidade de alunos.

Tempo total.

Certificado.

Nível.

Idioma.

Atualizado em.

---

## CTA Principal

Comprar Curso

---

## CTA Secundário

Adicionar aos Favoritos

Compartilhar

---

# Video Trailer

## Objetivo

Apresentar o curso.

Gerar confiança.

Mostrar a qualidade das aulas.

---

## Player

16:9

HLS Streaming

Poster

Thumbnail

Preview

---

## Segurança

Nunca utilizar MP4.

Nunca expor URL.

Streaming HLS.

URLs assinadas.

---

# Purchase Card

Desktop

Sidebar fixa.

Mobile

Bottom Sheet.

---

## Conteúdo

Preço

Plano

Benefícios

Garantia

Certificado

Quantidade de módulos

Quantidade de aulas

Carga horária

Atualizações futuras

Botão Comprar

---

# Benefícios

Acesso ilimitado

Certificado

Download de materiais

Acesso Mobile

Suporte

Lives

Comunidade

Atualizações

---

# Course Overview

Descrição completa.

Objetivos.

Metodologia.

Público-alvo.

---

# Learning Outcomes

Após concluir o curso o aluno será capaz de:

- Criar moldes
- Desenvolver peças
- Interpretar modelagens
- Trabalhar com diferentes tecidos
- Aplicar técnicas profissionais
- Finalizar projetos completos

---

# Instructor

Foto

Nome

Especialidade

Experiência

Biografia

Cursos publicados

Quantidade de alunos

Avaliação média

Redes sociais

Botão

Ver Perfil

---

# Curriculum

Accordion

Módulos

↓

Aulas

↓

Tempo

↓

Preview

↓

Material

↓

Exercícios

↓

Downloads

---

Cada aula mostra

Ícone

Título

Tempo

Prévia disponível

Arquivo PDF

Exercício

Status

---

# Lesson Preview

Aulas gratuitas possuem

Badge

FREE PREVIEW

Botão

Assistir

---

# Requirements

Lista

Máquina de Costura

Tecidos

Tesoura

Fita Métrica

Papel Kraft

Régua

Lápis

Conhecimentos prévios

---

# Materials Included

PDF

Modelos

Moldes

Planilhas

Arquivos ZIP

Exercícios

Lista de materiais

Checklist

---

# Activities Included

Questões

Múltipla Escolha

Verdadeiro ou Falso

Dissertativas

Envio de Arquivos

Projetos Práticos

Avaliação pelo Professor

Feedback

Notas

---

# Certificate

Imagem do certificado.

Explicação.

QR Code.

Validação.

Carga Horária.

---

# Student Reviews

Lista

Foto

Nome

Curso

Nota

Comentário

Data

---

## Filtros

Mais recentes

Melhores avaliações

Mais úteis

---

# FAQ

Accordion

Perguntas frequentes.

---

# Related Courses

Carousel

Mesmo professor

Mesma categoria

Mesmo nível

Recomendados

---

# Final CTA

Título

Comece hoje mesmo.

Botão

Comprar Curso

Botão

Criar Conta

---

# Footer

Institucional

---

# Componentes Utilizados

GlobalHeader

GlassNavigation

HeroBanner

VideoPlayer

PurchaseCard

PrimaryButton

SecondaryButton

Accordion

LessonItem

InstructorCard

CertificateCard

ReviewCard

FAQAccordion

RelatedCourseCarousel

Footer

---

# APIs

Implementação confirmada para o detalhe:

```http
GET /api/v1/courses/slug/{slug}
```

A elegibilidade e a criação do checkout devem seguir os contratos canônicos de
assinatura e pagamento. Há divergência histórica entre `SERVICE_API.md`, o
contrato de assinaturas e o datasource Flutter; essa divergência deve ser
resolvida antes de alterar endpoints.

Reviews, instrutor detalhado, materiais, relacionados, carrinho, favoritos e
compartilhamento não possuem suporte confirmado para esta página e não devem
ser chamados ou simulados.

---

# Estado da Página

Loading

Skeleton

Error

Offline

Course Not Found

Course Unavailable

Private Course

---

# Segurança

Streaming HLS

URLs Assinadas

JWT

Validação de Compra

Sem acesso às aulas protegidas

Proteção contra Hotlink

Sem download direto

Downloads apenas pelo aplicativo

---

# SEO

Meta Title

Meta Description

Canonical URL

Open Graph

Twitter Card

Breadcrumb

Schema.org Course

Schema.org Instructor

Rich Snippets

---

# Motion

Fade

Hero Animation

Shared Element

Scroll Reveal

Accordion Animation

Button Press

Scale

Blur

Smooth Scroll

---

# Liquid Glass

Aplicar apenas em

Header

Purchase Floating Card

Floating Buy Button

Bottom Sheet

Video Controls

Floating Share Button

Nunca aplicar em

Descrição

Accordion

Currículo

Cards

Conteúdo

Reviews

---

# Responsividade

## Desktop

Vídeo à esquerda

Purchase Card fixa à direita

Currículo em Accordion

Reviews em Grid

---

## Tablet

Purchase Card abaixo do vídeo

Grid reduzido

---

## Mobile

Hero vertical

Player responsivo

Purchase Card fixa na parte inferior

Accordion otimizado

Reviews em lista

Bottom Navigation

---

# Analytics

Visualizações

Tempo na página

Cliques em Comprar

Cliques no Trailer

Compartilhamentos

Favoritos

Conversão

Abandono

Scroll Depth

CTR

---

# Acessibilidade

WCAG AA

Closed Captions

Keyboard Navigation

TalkBack

Screen Reader

Alto Contraste

Touch Target 44x44

Texto alternativo para imagens

---

# Performance

Lazy Loading

Pré-carregamento do trailer

Compressão de imagens

Cache

Infinite Reviews

Skeleton Loading

Prefetch de cursos relacionados

Streaming adaptativo

---

# Critérios de Aceitação

- O trailer deve iniciar em menos de 2 segundos.
- O vídeo deve utilizar exclusivamente HLS com URLs assinadas.
- O botão "Comprar Curso" deve permanecer acessível durante toda a navegação (Sticky no desktop e Bottom CTA no mobile).
- O currículo deve permitir expansão e recolhimento de módulos sem recarregar a página.
- O layout deve seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve ser utilizado apenas em elementos flutuantes.
- Todos os estados (Loading, Offline, Erro e Curso Não Encontrado) devem estar implementados.
- A página deve atingir excelente desempenho em dispositivos móveis e desktop, mantendo uma experiência premium e minimalista.
````
