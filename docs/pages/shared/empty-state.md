---
id: SHARED-002
name: Empty State System
path: /shared/empty-state
type: Shared Component
platforms:
  - Web
  - Android

usage:
  - Public Pages
  - Student Dashboard
  - Teacher Dashboard
  - Admin Dashboard

framework:
  frontend: Flutter
  state_management: Riverpod
  animations:
    - Flutter Animate
    - Lottie

design-system: Lawrence Design System

style:
  minimal: true
  liquid_glass: true
  apple_inspired: true
  human_feedback: true
---

# Empty State System

## Objetivo

O **Empty State System** define como a Lawrence Academy apresenta telas sem conteúdo.

Um Empty State nunca deve parecer um erro.

Ele deve transformar ausência de dados em:

- Orientação
- Próxima ação
- Aprendizado
- Motivação

Inspirado em:

- Apple iOS
- Notion
- Linear
- Airbnb
- Stripe Dashboard
- Duolingo

---

# Filosofia

Nunca mostrar:

```text
Nenhum dado encontrado.
```

Sem contexto.

---

Sempre responder:

```text
O que aconteceu?

Por que aconteceu?

O que posso fazer agora?
```

---

# Estrutura Base

Todo Empty State segue:

```text
Illustration / Icon

↓

Título

↓

Descrição curta

↓

Ação principal

↓

Ação secundária opcional
```

---

# Layout

## Desktop

```text
--------------------------------

            Icon


       Título


       Descrição


        CTA

--------------------------------
```

---

# Mobile

```text
Safe Area


Icon

Título

Texto

Botão


```

---

# Espaçamento

Centro da área disponível.

Nunca ocupar tela inteira se existir navegação.

---

# EmptyState Component

Flutter:

```dart
EmptyState(
 icon,
 title,
 description,
 primaryAction,
 secondaryAction,
)
```

---

# Design

## Container

Background:

```text
Transparent
```

---

## Icon

Tamanho:

Desktop:

96px

Mobile:

72px

---

Estilo:

Minimal Line

SF Symbols Inspired

---

# Typography

Título:

```text
Heading M

28px

Weight 600
```

---

Descrição:

```text
Body

17px

#6E6E73
```

---

CTA:

Pill Button

44px+

---

# Liquid Glass

Usar somente quando Empty aparecer como:

Modal

Overlay

Floating Panel

---

Config:

```text
Blur:

20px


Opacity:

72%


Radius:

28px
```

---

Nunca usar Glass:

- Texto
- Ícone principal
- Página inteira

---

# Tipos de Empty States

A plataforma possui:

```text
No Content

No Search Results

No Internet

No Permission

No Subscription

No Activity

First Experience

Error Recovery
```

---

# 1. No Content

Quando uma lista está vazia.

Exemplo:

Cursos:

```text
Você ainda não começou nenhum curso.

Explore novas habilidades e continue sua jornada.

[Explorar cursos]
```

---

# 2. Search Empty

Quando busca não retorna.

Nunca:

```text
0 resultados
```

---

Usar:

```text
Não encontramos cursos para "modelagem 3D".

Tente ajustar os filtros ou pesquisar outro termo.

[Limpar filtros]
```

---

# 3. First Experience

Primeira utilização.

Exemplo Professor:

```text
Crie seu primeiro curso.

Compartilhe seu conhecimento com milhares de alunos.

[Criar curso]
```

---

# 4. No Internet

Offline.

Mostrar:

```text
Você está sem conexão.

Continuaremos mostrando conteúdos salvos.

[Tentar novamente]
```

---

# 5. No Permission

Quando usuário não possui acesso.

Exemplo:

```text
Este recurso não está disponível.

Verifique suas permissões ou fale com o suporte.
```

---

# 6. No Subscription

Quando aluno tenta acessar curso sem assinatura.

Como cada curso possui assinatura própria:

Mostrar:

```text
Você ainda não possui acesso a este curso.

Assine este curso para continuar aprendendo.

[Assinar Curso]
```

---

# 7. No Activities

Aluno.

```text
Nenhuma atividade disponível.

Novas atividades aparecerão aqui.
```

---

# 8. No Certificates

```text
Seus certificados aparecerão aqui.

Finalize seus cursos para conquistar novos certificados.
```

---

# 9. Teacher Empty States

## Sem cursos

```text
Seu primeiro curso começa aqui.

Crie conteúdos, publique aulas e alcance alunos.

[Criar curso]
```

---

## Sem alunos

```text
Nenhum aluno inscrito ainda.

Quando alguém comprar seu curso aparecerá aqui.
```

---

## Sem correções

```text
Tudo em dia.

Nenhuma atividade aguardando correção.
```

---

# 10. Admin Empty States

## Sem usuários

```text
Nenhum usuário encontrado.

Ajuste os filtros ou faça uma nova busca.
```

---

## Sem relatórios

```text
Você ainda não criou relatórios.

Gere análises completas da plataforma.

[Criar relatório]
```

---

# Estados por Domínio

## Courses

empty_courses

empty_lessons

empty_modules

empty_reviews

---

## Users

empty_students

empty_teachers

empty_search

---

## Payments

empty_transactions

empty_invoices

empty_subscriptions

---

## Notifications

empty_notifications

---

# Assets

Usar:

SVG

Lottie leve

Vector

---

Não usar:

Imagens pesadas

Personagens infantis

Animações exageradas

---

# Motion

Entrada:

Fade

+

Slide Up

---

Tempo:

```text
250ms
```

---

Ícone:

Micro Animation

---

CTA:

Spring Press

---

# Providers

```dart
emptyStateProvider

emptyContentProvider

searchStateProvider
```

---

# Componentes

```text
EmptyState

EmptySearch

EmptyCourses

EmptyStudents

EmptyPayments

EmptyOffline

EmptyPermission

EmptySubscription

EmptyErrorRecovery
```

---

# API Handling

Resposta vazia:

```json
{
 "data": []
}
```

não é erro.

---

Converter para:

```text
EmptyState
```

---

# Diferença

Loading:

```text
Ainda buscando dados.
```

---

Empty:

```text
Busca terminou e não existe conteúdo.
```

---

Error:

```text
Algo falhou.
```

---

# Responsividade

## Desktop

Centralizado no container.

---

## Tablet

Ícone reduzido.

---

## Mobile

Vertical.

Safe Area.

CTA próximo ao polegar.

---

# Performance

SVG Cache

Lazy Load Animation

Sem rebuild

60 FPS

---

# Acessibilidade

Obrigatório:

WCAG AA

VoiceOver

TalkBack

Dynamic Text

---

Labels:

```text
Nenhum conteúdo disponível
```

---

Botões claros.

---

# Psicologia de Produto

## Redução de frustração

Nunca culpar o usuário.

---

## Direcionamento

Sempre oferecer próximo passo.

---

## Clareza

Usuário entende imediatamente a situação.

---

## Motivação

Estados vazios são oportunidades de engajamento.

---

# Critérios de Aceitação

- Nenhuma tela deve exibir listas vazias sem tratamento.
- Todo Empty State possui título, descrição e ação quando aplicável.
- Deve diferenciar vazio, erro e carregamento.
- Deve respeitar Lawrence Design System.
- Liquid Glass somente em modais ou elementos flutuantes.
- Deve funcionar no Flutter Web e Android.
- Deve manter acessibilidade WCAG AA.
- Deve possuir componentes reutilizáveis.
- Experiência inspirada no Apple iOS, Linear e Notion.