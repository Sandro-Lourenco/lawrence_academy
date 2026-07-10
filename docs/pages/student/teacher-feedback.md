---
id: PAGE-STUDENT-007
name: Teacher Feedback
route: /dashboard/activities/:activityId/feedback
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
  ownership-required: true
---

# Teacher Feedback

## Objetivo

A página **Teacher Feedback** representa o encerramento do ciclo de aprendizagem.

Mais do que mostrar uma nota, ela deve entregar uma experiência de aprendizado personalizada, permitindo que o aluno compreenda seus erros, reconheça seus acertos e saiba exatamente como evoluir.

A filosofia desta página é inspirada no conceito de **Feedback Construtivo**, onde cada correção é uma oportunidade de crescimento.

Inspirado em:

- Apple Education
- Coursera
- MasterClass
- Canvas LMS
- Notion
- GitHub Code Review

---

# Objetivos

- Exibir a avaliação completa do professor.
- Mostrar nota final.
- Exibir comentários detalhados.
- Mostrar critérios utilizados.
- Evidenciar pontos fortes.
- Evidenciar oportunidades de melhoria.
- Permitir responder comentários quando habilitado.
- Incentivar o aluno a continuar estudando.

---

# Fluxo

```
Atividade

↓

Envio

↓

Professor Corrige

↓

Feedback Disponível

↓

Aluno Visualiza

↓

Lê Comentários

↓

Compara Respostas

↓

Aprende

↓

Próxima Aula
```

---

# Layout Desktop

```
---------------------------------------------------------------

Glass Header

---------------------------------------------------------------

Sidebar

|

|

Grade Summary

↓

Teacher Feedback

↓

Rubric

↓

Student Answer

↓

Teacher Notes

↓

Learning Suggestions

↓

Next Lesson

---------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Nota

↓

Resumo

↓

Comentários

↓

Rubrica

↓

Resposta

↓

Próxima Aula

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

Feedback Hero

↓

Grade Summary

↓

Teacher Feedback

↓

Rubric

↓

Student Submission

↓

Teacher Attachments

↓

Suggested Improvements

↓

Continue Learning

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

# Feedback Hero

Exibir

Título da atividade

Curso

Professor

Data da correção

Tipo

Prazo

Tempo de correção

---

# Grade Summary

Grande destaque.

Centro da página.

Mostrar

Nota

Conceito

Status

---

Exemplo

```
9.7

Excelente

✔ Aprovado
```

---

Também exibir

Pontuação

97 / 100

---

# Progress Circle

Animação circular.

Azul.

---

Caso nota máxima

Pequena animação dourada.

---

# Teacher Feedback

Área principal.

Mostrar

Comentário geral.

Comentário detalhado.

Parágrafos.

Markdown.

---

Exemplo

```
Seu acabamento ficou excelente.

A interpretação do molde foi correta.

Apenas observe a margem de costura nas próximas peças.
```

---

# Destaques

Separar em dois blocos.

## Pontos Fortes

✔ Organização

✔ Técnica

✔ Acabamento

✔ Criatividade

---

## Oportunidades de Melhoria

•

Precisão

•

Velocidade

•

Acabamento interno

•

Posicionamento

---

# Rubric

Tabela.

Critério

↓

Peso

↓

Nota

↓

Comentário

---

Exemplo

| Critério | Peso | Nota |
|----------|------|------|
| Técnica | 40% | 39 |
| Criatividade | 30% | 29 |
| Organização | 20% | 20 |
| Acabamento | 10% | 9 |

---

# Student Submission

Mostrar exatamente o que o aluno enviou.

Quiz

↓

Alternativas marcadas.

---

Discursiva

↓

Texto enviado.

---

Projeto

↓

Arquivos enviados.

---

Upload

↓

Lista completa.

---

# Teacher Annotations

Caso exista.

Mostrar marcações.

Comentários.

Imagem anotada.

PDF anotado.

---

# Teacher Attachments

Arquivos anexados pelo professor.

Tipos

PDF

Imagem

Vídeo

Checklist

Modelo

Referência

---

Botão

Visualizar

↓

Baixar

---

# Suggested Improvements

Seção dedicada ao aprendizado.

Mostrar

Materiais recomendados.

Próximas aulas.

Cursos relacionados.

Artigos.

Vídeos.

---

Exemplo

```
Recomendamos revisar:

✔ Aula 12

✔ Aula 13

✔ Costura Francesa

✔ Técnicas de Alfaiataria
```

---

# Continue Learning

Grande CTA.

```
Continuar Curso

↓

Próxima Aula
```

---

Caso o módulo termine.

```
Ir para o próximo módulo.
```

---

# Reflection

Área opcional.

Aluno pode escrever.

"O que aprendi?"

Markdown.

Auto Save.

---

# APIs

GET /activities/{id}/feedback

GET /activities/{id}/rubric

GET /activities/{id}/submission

GET /activities/{id}/attachments

GET /activities/{id}/recommendations

POST /activities/{id}/reflection

---

# Providers

feedbackProvider

gradeProvider

rubricProvider

submissionProvider

recommendationsProvider

reflectionProvider

---

# Componentes

FeedbackHero

GradeCard

ProgressCircle

TeacherCommentCard

RubricTable

SubmissionViewer

AttachmentCard

RecommendationCard

ReflectionEditor

ContinueLearningCard

SkeletonLoader

---

# Estados

Loading

Skeleton Apple Style.

---

Sem feedback

Mensagem

```
Seu professor ainda não concluiu a correção.
```

---

Sem anexos

Ocultar seção.

---

Erro

Botão

Tentar novamente.

---

Offline

Mostrar cache.

---

# Motion

Fade

Slide

Scale

Hero Animation

Shared Transition

Spring

Blur

Progress Animation

---

# Liquid Glass

Aplicar apenas em

Glass Header

Floating Buttons

Bottom Navigation

Floating Progress Card

Modal

Nunca aplicar em

Texto

Rubrica

Comentários

Resposta

Tabela

Cards principais

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

Aprovado

#30D158

Revisão

#FF9F0A

Reprovado

#FF453A

---

# Responsividade

## Desktop

Sidebar fixa.

Conteúdo central.

Largura máxima

1200px.

---

## Tablet

Layout em duas colunas.

---

## Mobile

Uma coluna.

Cards empilhados.

Bottom Navigation.

Safe Area.

---

# Performance

Lazy Loading

Markdown Render

Image Cache

Skeleton

60 FPS

Pré-carregar recomendações

---

# Analytics

Nota média

Tempo até correção

Comentários lidos

Materiais acessados

Reflexões criadas

Aulas revisitadas

Taxa de melhoria

---

# Segurança

Supabase Auth

JWT

HTTPS

OWASP Top 10

Ownership Guard

Role Guard

Links temporários

Downloads protegidos

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

Alto contraste

---

# Psicologia de Aprendizagem

## Feedback Positivo

Sempre iniciar destacando os acertos.

Depois apresentar oportunidades de melhoria.

---

## Growth Mindset

Evitar linguagem punitiva.

Utilizar linguagem construtiva.

Exemplo

❌ Você errou.

✔ Você pode melhorar este ponto utilizando a técnica apresentada na Aula 8.

---

## Goal Gradient

Ao final mostrar

```
Você concluiu este desafio.

Faltam apenas 2 atividades para concluir o módulo.
```

---

## Reforço Positivo

Quando aprovado.

Mostrar pequena animação.

Check azul.

Brilho dourado discreto.

---

## Aprendizagem Contínua

Sempre recomendar

- Próxima aula.
- Material complementar.
- Exercícios relacionados.
- Curso avançado.

---

# Critérios de Aceitação

- O aluno deve visualizar a nota final de forma clara e destacada.
- O feedback do professor deve ser exibido em formato estruturado, utilizando Markdown.
- A rubrica de avaliação deve detalhar critérios, pesos e notas individuais.
- A página deve exibir exatamente a resposta enviada pelo aluno, preservando anexos e formatação.
- O sistema deve sugerir materiais complementares e a próxima etapa do aprendizado.
- O layout deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado exclusivamente em elementos flutuantes.
- A experiência deve transmitir sensação de crescimento, reconhecimento e continuidade do aprendizado, mantendo o padrão premium da Lawrence Academy.