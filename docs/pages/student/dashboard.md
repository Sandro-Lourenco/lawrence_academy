---
id: PAGE-STUDENT-001
name: Student Dashboard
route: /dashboard
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
navigation: ShellRoute
state-management: Riverpod
architecture: Clean Architecture + DDD
---

# Student Dashboard

## Objetivo

O Dashboard é o coração da experiência do aluno.

Toda a plataforma deve ser construída em torno do conceito de **Continue Aprendendo**.

O aluno nunca deve sentir que entrou em um sistema administrativo.

Ele deve sentir que entrou em uma plataforma premium de aprendizagem.

Inspirado em:

- Apple TV+
- Apple Fitness+
- Apple Education
- MasterClass
- Coursera
- Notion
- Arc Browser

A interface deve ser extremamente minimalista.

Muito espaço em branco.

Cards grandes.

Pouquíssimos elementos por tela.

Hierarquia visual muito clara.

A interface praticamente desaparece.

O conteúdo é o protagonista.

---

# Objetivos

- Continuar rapidamente o curso.
- Mostrar progresso.
- Mostrar próximas atividades.
- Mostrar eventos ao vivo.
- Mostrar certificados.
- Mostrar recomendações.
- Aumentar retenção.
- Reduzir abandono.
- Incentivar conclusão dos cursos.

---

# Layout

Desktop

```
----------------------------------------------------------

Glass Header

----------------------------------------------------------

Sidebar      |          Conteúdo Principal

240px        |          1fr

----------------------------------------------------------
```

Mobile

```
Glass Header

↓

Conteúdo

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Welcome Banner

↓

Continue Learning

↓

Progress Banner

↓

Live Events

↓

Today's Tasks

↓

My Courses

↓

Recommended Courses

↓

Certificates

↓

Referral Card

↓

Footer
```

---

# Glass Header

Altura

72px

Sticky

Sempre visível.

---

Componentes

Logo

Pesquisa

Notificações

Mensagens

Perfil

---

Background

Liquid Glass

Blur

20px

Opacity

72%

---

# Welcome Banner

Objetivo

Recepcionar o aluno.

---

Conteúdo

Bom dia, Sandro 👋

Continue aprendendo.

Você está a apenas 18% do seu próximo certificado.

---

Avatar

Foto do usuário.

---

Quick Actions

Continuar Curso

Calendário

Downloads

Perfil

---

# Continue Learning

Maior componente da página.

Sempre aparece primeiro.

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

Última aula assistida

---

# Progress Banner

Card grande.

---

Conteúdo

Título

Seu progresso

---

Circular Progress

ou

Linear Progress

---

Exemplo

72%

---

Texto

Faltam apenas

6 aulas

para concluir.

---

Animação

Spring

---

# Live Events

Mostrar

Próximas Lives

Consultorias

Eventos

---

Cada Card

Imagem

Título

Professor

Data

Hora

Botão

Adicionar ao Calendário

---

Caso exista Live acontecendo

Badge

LIVE

Verde

Pulsando.

---

# Today's Tasks

Lista

---

Exibir

Tarefas

Questionários

Projetos

Provas

---

Cada item

Título

Curso

Prazo

Status

Botão

Resolver

---

# My Courses

Grid

Desktop

3 colunas

Tablet

2

Mobile

1

---

Cada Card

Thumbnail

Título

Professor

Progresso

Próxima Aula

Tempo Restante

Botão

Continuar

---

Caso concluído

Badge

Concluído

Dourado

---

# Recommended Courses

Carousel

Baseado em IA

Sugestões

Relacionados

Categorias

---

Cada Card

Imagem

Título

Professor

Avaliação

Preço

Botão

Conhecer

---

# Certificates

Mostrar últimos certificados.

---

Cada Card

Nome

Curso

Professor

Data

Botão

Visualizar

Baixar PDF

Compartilhar

---

# Referral Card

Objetivo

Indique e Ganhe.

---

Conteúdo

Indique amigos.

Ganhe descontos.

---

Botão

Compartilhar

---

# Search

Pesquisa Global

Pesquisar

Cursos

Aulas

Professores

Materiais

Eventos

FAQ

---

Pesquisa instantânea.

Debounce

300ms

---

# Notifications

Tipos

Nova Aula

Nova Live

Correção

Pagamento

Mensagem

Certificado

Sistema

---

# Downloads

(Android)

Mostrar

Cursos Offline

Espaço ocupado

Gerenciar downloads

---

Web

Mostrar

Disponível apenas no aplicativo.

---

# Sidebar Desktop

Itens

Dashboard

Meus Cursos

Atividades

Downloads

Eventos

Mensagens

Certificados

Pagamentos

Perfil

Configurações

Suporte

Logout

---

# Bottom Navigation

(Android)

Dashboard

Cursos

Pesquisar

Eventos

Perfil

---

# APIs

GET /dashboard

GET /courses/progress

GET /courses/continue

GET /events

GET /tasks

GET /notifications

GET /certificates

GET /recommendations

GET /downloads

---

# Providers

dashboardProvider

coursesProvider

progressProvider

eventsProvider

tasksProvider

notificationsProvider

certificatesProvider

downloadsProvider

recommendationProvider

---

# Estados

Loading

Skeleton Apple Style

---

Empty

Nenhum curso.

↓

Explorar Catálogo.

---

Offline

Mostrar cache.

---

Erro

Card elegante.

Botão

Tentar novamente.

---

# Motion

Fade

Scale

Shared Transition

Spring

Blur

Hero Animation

Card Hover

Progress Animation

Skeleton Animation

---

# Liquid Glass

Aplicar apenas em

Header

Search Bar

Floating Player

Floating Notifications

Floating Bottom Navigation

Quick Actions

Floating Calendar

Floating Download Button

Nunca aplicar em

Cards

Lista de Cursos

Conteúdo

Texto

Progress Cards

---

# Tipografia

Hero

36px

---

Heading

28px

---

Subheading

22px

---

Body

17px

---

Caption

13px

---

# Cores

60%

White

30%

Primary Blue

10%

Premium Gold

---

# Responsividade

## Desktop

Sidebar fixa.

Cards maiores.

Grid 3 colunas.

---

## Tablet

Sidebar recolhida.

Grid 2 colunas.

---

## Mobile

Bottom Navigation.

Cards empilhados.

Carousel horizontal.

Botões maiores.

Safe Area.

---

# Performance

Lazy Loading

Infinite Scroll

Cache

Pré-carregar última aula

Pré-carregar thumbnails

Shimmer

Hero Animation em GPU

60 FPS

---

# Analytics

Tempo de estudo

Dias consecutivos

Cursos iniciados

Cursos concluídos

CTR dos cursos recomendados

Retenção

Tempo por aula

Downloads

Eventos acessados

Taxa de conclusão

---

# Acessibilidade

WCAG AA

TalkBack

VoiceOver

Screen Reader

Keyboard Navigation

Touch Target

44x44px

Focus Visible

Modo Alto Contraste

Escala de Fonte

---

# Psicologia de Conversão

## Efeito Zeigarnik

O curso iniciado sempre deve aparecer no topo.

O cérebro tende a querer concluir tarefas iniciadas.

---

## Goal Gradient Effect

Mostrar claramente quanto falta.

Exemplo

"Você está a apenas 3 aulas do certificado."

---

## Prova Social

Mostrar

★★★★★

+12.000 alunos concluíram.

---

## Gamificação

Conquistas

Badges

Certificados

Dias consecutivos

Progresso

Sequência de estudos

---

## Personalização

A IA poderá recomendar:

Novos cursos.

Eventos.

Consultorias.

Lives.

Artigos.

Materiais.

Com base no comportamento do aluno.

---

# Segurança

Autenticação

Supabase Auth

JWT

Refresh Token

HTTPS

OWASP Top 10

Role Guard

Session Refresh

Device Tracking

Proteção contra acesso a cursos não adquiridos

Validação de assinatura ativa

---

# Critérios de Aceitação

- O Dashboard deve carregar em menos de **2 segundos**.
- O componente **Continue Learning** deve ser sempre o primeiro conteúdo exibido.
- O progresso do aluno deve ser atualizado em tempo real após a conclusão de uma aula.
- Todos os cards devem seguir integralmente o **Lawrence Design System**.
- O efeito **Liquid Glass** deve ser aplicado apenas em elementos flutuantes (Header, Search, FABs e Bottom Navigation).
- O Dashboard deve funcionar totalmente responsivo para Web e Android.
- Deve suportar cache offline para exibição das últimas informações sincronizadas.
- Todas as listas devem utilizar **Skeleton Loading** durante o carregamento.
- As recomendações de cursos devem ser personalizadas com base no histórico do aluno.
- A experiência deve transmitir sofisticação, clareza e foco no aprendizado, reforçando a identidade premium da Lawrence Academy.