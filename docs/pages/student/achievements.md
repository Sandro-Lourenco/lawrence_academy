---
id: PAGE-STUDENT-018
name: Achievements
route: /dashboard/achievements
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
real-time: Supabase Realtime

gamification:
  enabled: true
  levels: true
  achievements: true
  badges: true
  milestones: true
  streaks: true
---

# Achievements

## Implementação canônica da fase de Conquistas

A implementação atual preserva a rota autenticada e os estados da experiência,
mas não ativa gamificação avançada sem backend. O PED classifica essa capacidade
como fora do MVP e `SERVICE_API.md` não confirma endpoints de conquistas, nível,
XP, sequência ou ranking.

Por isso, o loader é injetável e retorna estado vazio até existir um use case
respaldado por API e RLS. A tela não apresenta medalhas, pontos, percentuais ou
ranking fictícios. Quando dados autorizados forem fornecidos, exibe nível e uma
grade responsiva de conquistas, sempre comunicando bloqueio e liberação por
ícone e texto.

Compartilhamento, realtime, streaks, milestones, ranking e animações de
celebração permanecem recomendações futuras, não critérios implementados.

## Objetivo

A página **Achievements** concentra todas as conquistas do aluno durante sua jornada de aprendizagem.

Ela transforma o progresso em uma experiência motivadora através de medalhas, badges, níveis, marcos, desafios e estatísticas pessoais.

A gamificação deve incentivar a continuidade dos estudos sem parecer infantil ou excessivamente competitiva.

Toda a experiência deve transmitir elegância, conquista e progresso, seguindo o estilo minimalista da Apple.

Inspirada em:

- Apple Fitness Awards
- Duolingo Achievements
- PlayStation Trophies
- Xbox Achievements
- GitHub Contribution
- Coursera Milestones

---

# Objetivos

- Visualizar conquistas.
- Acompanhar progresso.
- Desbloquear badges.
- Evoluir de nível.
- Visualizar sequência de estudos.
- Acompanhar estatísticas.
- Compartilhar conquistas.

---

# Fluxo

```
Aluno

↓

Achievements

↓

Visualiza conquistas

↓

Continua estudando

↓

Desbloqueia nova conquista

↓

Animação Premium

↓

Compartilhar (Opcional)
```

---

# Layout Desktop

```
------------------------------------------------------------

Glass Header

------------------------------------------------------------

Sidebar

|

Achievement Hero

|

Resumo Geral

|

Badges

|

Milestones

|

Estatísticas

|

Linha do Tempo

------------------------------------------------------------
```

---

# Layout Mobile

```
Glass Header

↓

Hero

↓

Resumo

↓

Badges

↓

Conquistas

↓

Timeline

↓

Bottom Navigation
```

---

# Estrutura

```
Glass Header

↓

Achievement Hero

↓

Student Level

↓

Learning Statistics

↓

Achievements Grid

↓

Badges Collection

↓

Learning Streak

↓

Milestones

↓

Timeline

↓

Share Achievement
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

# Achievement Hero

Área de destaque.

Mostrar

Foto

Nome

Nível

Título

Progresso Geral

---

Exemplo

```
Sandro

Nível 18

Especialista em Modelagem

82% da próxima evolução
```

---

# Student Level

Card Premium.

Mostrar

Nível atual

XP total

XP necessário

Barra de progresso

---

Exemplo

```
Nível 18

12.480 XP

Próximo nível

15.000 XP
```

---

# Learning Statistics

Mostrar

Cursos concluídos

Horas estudadas

Aulas assistidas

Atividades concluídas

Certificados

Dias consecutivos

Downloads

Lives assistidas

---

# Achievements Grid

Grid responsivo.

Cada conquista possui

Ícone

Nome

Descrição

Categoria

Data

Status

XP

---

Categorias

Aprendizagem

Persistência

Comunidade

Professor

Eventos

Desafios

Cursos

Certificados

---

# Achievement Card

Mostrar

Badge

Título

Descrição

XP

Status

Botão

Detalhes

---

Exemplo

```
Primeiro Curso

Conclua seu primeiro curso.

+500 XP
```

---

# Badges Collection

Galeria.

Exibir

Badges desbloqueadas

Badges bloqueadas

Raridade

---

Tipos

Bronze

Prata

Ouro

Platina

Diamante

---

# Learning Streak

Mostrar

Dias consecutivos estudando

Calendário

Maior sequência

---

Exemplo

```
🔥

42 dias consecutivos

Maior sequência

87 dias
```

---

# Milestones

Linha de progresso.

Mostrar

Primeira aula

Primeiro curso

100 aulas

500 horas

Primeiro certificado

10 cursos

50 atividades

1000 XP

---

# Timeline

Linha cronológica.

Cada item

Conquista

Data

Curso

XP

---

Exemplo

```
Conquista desbloqueada

Especialista em Costura

+800 XP

15 Julho
```

---

# Share Achievement

Permitir

Compartilhar Badge

Gerar imagem

Compartilhar Certificado

Copiar Link

---

# XP System

Toda ação gera experiência.

Exemplo

Primeira Aula

+20 XP

Conclusão de Aula

+50 XP

Conclusão de Curso

+500 XP

Certificado

+250 XP

Sequência diária

+15 XP

Primeira Live

+100 XP

---

# APIs

GET /achievements

GET /achievements/{id}

GET /badges

GET /milestones

GET /streak

GET /student-level

GET /student-xp

GET /statistics

POST /achievements/share

---

# Providers

achievementProvider

badgeProvider

milestoneProvider

streakProvider

studentLevelProvider

statisticsProvider

timelineProvider

---

# Componentes

GlassHeader

AchievementHero

LevelCard

XPProgressBar

StatisticsCard

AchievementCard

BadgeCard

MilestoneTimeline

LearningStreakCard

TimelineCard

ShareCard

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style.

---

## Sem conquistas

Mostrar

```
Continue estudando para desbloquear suas primeiras conquistas.
```

Botão

Explorar Cursos

---

## Nova conquista

Executar animação premium.

Confetti discreto.

Badge dourada.

Som opcional.

---

## Offline

Mostrar dados locais.

---

## Erro

Toast.

Botão

Tentar novamente.

---

# Motion

Fade

Scale

Hero Animation

Spring

Progress Animation

Blur

Shared Transition

Skeleton

Confetti (somente novas conquistas)

---

# Liquid Glass

Aplicar apenas em

Glass Header

Floating Achievement Notification

Bottom Navigation

Dialogs

Floating Share Button

Nunca aplicar em

Cards principais

Grid

Timeline

Texto

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

Bronze

#CD7F32

Silver

#C0C0C0

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

Grid de conquistas.

Timeline lateral.

Galeria de badges.

---

## Tablet

Grid adaptativo.

---

## Mobile

Cards empilhados.

Bottom Navigation.

Safe Area.

Badges em carrossel horizontal.

---

# Performance

Lazy Loading

Realtime

Cache

Optimistic Update

Background Refresh

Skeleton Loading

60 FPS

---

# Analytics

XP total

Conquistas desbloqueadas

Badges obtidas

Sequência de estudos

Cursos concluídos

Tempo médio de estudo

Taxa de conclusão

---

# Segurança

Supabase Auth

JWT

HTTPS

Row Level Security

Ownership Guard

Criptografia

Logs de Auditoria

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Touch Target

44x44px

Focus Visible

Escala dinâmica

Alto contraste

---

# Psicologia de Produto

## Motivação Intrínseca

As conquistas devem incentivar o aprendizado, nunca substituir o valor do conhecimento.

---

## Progressão Contínua

Sempre mostrar o próximo objetivo.

Exemplo

```
Faltam apenas 3 aulas para desbloquear a próxima medalha.
```

---

## Recompensa Elegante

Evitar animações exageradas.

Celebrar conquistas com discrição, utilizando microinterações inspiradas na Apple.

---

## Valor Pessoal

As conquistas representam a evolução do aluno e podem ser compartilhadas, reforçando seu progresso e dedicação.

---

# Critérios de Aceitação

- O sistema deve registrar automaticamente conquistas, badges, níveis, marcos e estatísticas do aluno.
- Toda conquista deve estar vinculada ao progresso real do usuário na plataforma.
- O aluno deve visualizar seu XP, nível atual, progresso para o próximo nível e histórico completo de conquistas.
- Deve ser possível compartilhar badges e conquistas em formato de imagem ou link.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito **Liquid Glass** deve ser utilizado exclusivamente em elementos flutuantes.
- A gamificação deve ser elegante, discreta e voltada para aumentar o engajamento sem comprometer a experiência premium da plataforma.
