---
id: PAGE-STUDENT-004
name: Lesson
route: /dashboard/courses/:courseId/modules/:moduleId/lessons/:lessonId
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
navigation: Nested Route
state-management: Riverpod
architecture: Clean Architecture + DDD
security:
  authorization: true
  subscription-required: true
---

# Lesson

## Implementação canônica da fase de Aula

A rota implementada é
`/dashboard/courses/:courseId/lessons/:lessonId`. Ela combina o player seguro,
detalhes confirmados da aula, progresso local e navegação anterior/próxima.

O stream é solicitado somente pelo repositório autenticado e o URL temporário
não é exibido em mensagens. O progresso é persistido a cada 15 segundos, ao
pausar, ao trocar de aula e quando o aplicativo perde foco, com proteção contra
gravações concorrentes. A conclusão automática segue o contrato de 90%.

Materiais, comentários, anotações, atividades, legendas, velocidade e tela cheia
não aparecem como controles inertes. Essas capacidades dependem de contratos e
implementações específicas antes de serem adicionadas.

## Objetivo

A página **Lesson** representa a experiência completa de uma aula dentro da Lawrence Academy.

Enquanto o **Course Player** é responsável exclusivamente pela reprodução do vídeo, a **Lesson** reúne todo o contexto pedagógico da aula.

Ela deve funcionar como uma página de estudo completa.

O aluno precisa conseguir aprender sem sair dessa tela.

Inspirada em:

- Apple Education
- MasterClass
- Coursera
- Khan Academy
- Apple Books
- Notion

A filosofia é:

> **Um lugar para assistir, estudar, praticar e concluir.**

---

# Objetivos

- Centralizar toda a experiência da aula.
- Melhorar retenção.
- Incentivar conclusão.
- Facilitar revisão.
- Disponibilizar materiais.
- Permitir interação com professor.
- Registrar progresso automaticamente.

---

# Fluxo

```
Curso

↓

Módulo

↓

Lista de Aulas

↓

Lesson

↓

Assistir Vídeo

↓

Ler Conteúdo

↓

Baixar Materiais

↓

Responder Atividade

↓

Concluir Aula

↓

Próxima Aula
```

---

# Layout Desktop

```
-------------------------------------------------------------

Glass Header

-------------------------------------------------------------

Sidebar Curso

|

|

Conteúdo Principal

|

|

-------------------------------------------------------------

Player

↓

Informações

↓

Conteúdo

↓

Materiais

↓

Atividade

↓

Comentários

↓

Próxima Aula

-------------------------------------------------------------
```

---

# Layout Mobile

```
Player

↓

Título

↓

Tabs

Conteúdo

Materiais

Atividade

Comentários

↓

Botão Próxima Aula

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Breadcrumb

↓

Lesson Hero

↓

Video Player

↓

Progress

↓

Lesson Tabs

↓

Description

↓

Objectives

↓

Learning Content

↓

Materials

↓

Assignment

↓

Teacher Notes

↓

Comments

↓

Navigation Footer
```

---

# Lesson Hero

Exibe informações principais da aula.

### Conteúdo

- Nome da aula
- Professor
- Tempo estimado
- Categoria
- Nível
- Última atualização
- Tempo restante do curso

---

# Progress

Barra azul.

Animada.

Exemplo

```
Módulo 3

Aula 4 de 12

██████████░░░░░

72%
```

---

# Player

Integrado ao

Course Player.

Aspect Ratio

16:9

---

Controles

Play

Pause

Volume

Fullscreen

Legenda

Velocidade

Qualidade

Picture in Picture

Todos em

Liquid Glass.

---

# Lesson Tabs

Desktop

Tabs horizontais

```
Conteúdo

Materiais

Atividade

Comentários

Anotações
```

Mobile

Scroll horizontal.

---

# Conteúdo

Área editorial.

Utiliza Markdown.

Pode conter:

Texto

Imagem

Tabela

Checklist

Código

Vídeos incorporados

Alertas

Notas

Dicas

---

# Objetivos da Aula

Exemplo

Após concluir esta aula você será capaz de:

✔ Fazer modelagem básica.

✔ Cortar tecido corretamente.

✔ Interpretar moldes.

---

# Conteúdo Didático

Editor Markdown.

Suporta

H2

H3

Imagem

Vídeo

Tabela

Lista

Callout

Código

Checklist

Download

Galeria

---

# Galeria

Fotos

Tecidos

Costuras

Modelos

Croquis

Zoom

Fullscreen

---

# Materiais

Lista de arquivos.

Tipos

PDF

ZIP

Imagem

Moldes

Planilhas

Guia

Checklist

---

Cada item

Nome

Descrição

Tamanho

Botão

Visualizar

↓

Baixar

---

Android

Salvar Offline

---

# Atividade

Caso exista.

Tipos

Quiz

Dissertativa

Verdadeiro ou Falso

Envio de Arquivo

Projeto

---

Mostrar

Status

Nota

Prazo

Professor

---

Botão

Resolver

↓

Task Page

---

# Comentários

Professor

↓

Aluno

---

Suporta

Texto

Imagem

Emoji

Curtir

Responder

Fixar comentário

---

Comentários do professor ficam destacados.

---

# Teacher Notes

Área exclusiva.

Pode conter

Dicas

Observações

Erros comuns

Boas práticas

---

Background

Cinza muito claro.

---

# Navegação

Rodapé

```
← Aula Anterior

Próxima Aula →

```

Sempre visível.

---

# Sidebar Curso

Desktop

Lista de módulos.

↓

Lista de aulas.

↓

Status

Concluído

Atual

Bloqueado

Novo

---

Pesquisa

Pesquisar aula.

---

# APIs

GET /lesson

GET /lesson/content

GET /lesson/materials

GET /lesson/comments

POST /lesson/comments

GET /lesson/objectives

GET /lesson/progress

GET /lesson/navigation

---

# Providers

lessonProvider

lessonContentProvider

materialsProvider

commentsProvider

progressProvider

assignmentProvider

navigationProvider

---

# Componentes

LessonHero

LessonProgress

LessonTabs

LessonContent

ObjectivesCard

MaterialCard

Gallery

TeacherNotesCard

CommentCard

LessonNavigation

SkeletonLoader

---

# Estados

Loading

Skeleton Apple Style.

---

Sem materiais

Mostrar ilustração.

---

Sem comentários

Incentivar primeiro comentário.

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

Slide

Scale

Blur

Shared Transition

Hero Animation

Accordion

Lazy Fade

Spring

---

# Liquid Glass

Aplicar apenas em

Header

Player Controls

Floating Navigation

Bottom Navigation

Floating Buttons

Search

Nunca aplicar em

Texto

Cards

Conteúdo

Artigos

Markdown

Comentários

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

Conteúdo centralizado.

Largura máxima

1200px.

---

## Tablet

Sidebar recolhível.

---

## Mobile

Conteúdo em uma coluna.

Tabs horizontais.

Bottom Navigation.

Safe Area.

---

# Performance

Markdown Lazy Loading

Image Lazy Loading

Cache

Pré-carregar próxima aula

Shimmer

60 FPS

Compressão de imagens

---

# Analytics

Tempo de leitura

Tempo assistido

Downloads

Comentários

Atividades iniciadas

Atividades concluídas

Scroll Depth

Heatmap

Tempo na página

---

# Segurança

Supabase Auth

JWT

HTTPS

OWASP Top 10

Ownership Guard

Subscription Guard

Links temporários

Downloads protegidos

Streaming HLS

DRM

AES-128

Controle de acesso por assinatura

---

# Acessibilidade

WCAG AA

TalkBack

VoiceOver

Keyboard Navigation

Screen Reader

Closed Caption

Touch Target

44x44px

Focus Visible

Escala dinâmica de fonte

---

# Psicologia de Aprendizagem

## Chunking

O conteúdo deve ser dividido em blocos curtos para reduzir a carga cognitiva.

---

## Aprendizagem Ativa

Cada aula deve incentivar:

- Ler
- Assistir
- Praticar
- Comentar
- Fazer atividade
- Continuar

---

## Goal Gradient

Mostrar sempre:

"Você concluiu 72% desta aula."

"Faltam apenas 8 minutos."

---

## Zeigarnik Effect

Após terminar a aula:

Mostrar automaticamente a próxima aula.

Nunca deixar o aluno sem uma ação seguinte.

---

# Critérios de Aceitação

- A página deve reunir vídeo, conteúdo, materiais, comentários e atividades em uma única experiência integrada.
- O conteúdo da aula deve suportar Markdown enriquecido com imagens, tabelas, listas, callouts e galerias.
- O aluno deve conseguir navegar entre aulas sem retornar ao catálogo do curso.
- O progresso da aula deve ser sincronizado automaticamente com o backend.
- O Android deve permitir download seguro dos materiais e visualização offline quando permitido.
- Todos os componentes devem seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve ser aplicado apenas aos elementos flutuantes.
- A página deve manter desempenho de 60 FPS, carregamento progressivo e excelente legibilidade.
- A experiência deve ser focada em aprendizagem profunda, minimalismo e alta qualidade visual, reforçando a identidade premium da Lawrence Academy.
````
