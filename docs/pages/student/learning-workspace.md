---
id: PAGE-STUDENT-LEARNING-WORKSPACE
name: Learning Workspace
route: /dashboard/courses/:courseId/lessons/:lessonId
layout: LearningFocusLayout
platforms:
  - Web
  - Android
roles:
  - Student
authentication: true
responsive: true
status: implemented
---

# Objetivo

## Sequência pedagógica e navegação visível (2026-08)

- Assistir, Atividade e Saber mais formam uma sequência única e ordenada; não
  são abas paralelas. O avanço percorre aula → atividade → saber mais → próxima
  aula, omitindo etapas que não existirem.
- O cabeçalho branco permanece visível e apresenta o nome do curso centralizado.
  O título da aula fica abaixo do player. Anterior, Transcrição e o próximo
  passo contextual formam uma barra inferior centralizada da etapa.
- O currículo usa marcadores quadrados conectados por trilho azul. Aula,
  atividade e Saber mais possuem ícones próprios, texto e estado semântico; cor
  nunca é a única forma de comunicar o item atual.
- No mobile, as ações permanecem numa barra inferior adaptativa. Conteúdos
  longos rolam dentro da superfície correspondente.
- Controles do player usam uma única superfície Liquid Glass delimitada, com
  `RepaintBoundary`, blur de 20 px, contraste AA e alvos mínimos de 44 px.
  Velocidade e volume são exibidos por possuírem suporte real; legenda e
  qualidade permanecem ocultas até existirem trilhas/renditions selecionáveis.

## Retomada e tela cheia (2026-07)

- A última aula e o modo `watch`, `activities` ou `learn-more` são persistidos
  por aluno e curso e restaurados pelo parâmetro `view` da rota.
- Desktop e mobile mantêm o seletor Assistir/Atividades/Saber mais visível.
- Uma única instância do player é movida entre a página e o overlay de tela
  cheia; dois `VideoPlayer` nunca compartilham o mesmo controller.
- Web usa a Fullscreen API e permite sair com Escape. Android restaura
  orientação e barras do sistema ao sair ou desmontar a rota.

Oferecer um ambiente de aprendizagem focado, com orientação espacial constante
e separação clara entre assistir, praticar e aprofundar.

# Superfícies

## Assistir

- Player HLS protegido em 16:9.
- Título, descrição e ação de próxima aula.
- Persistência de progresso a cada 15 segundos, ao pausar e ao sair.

## Atividades

- Prática vinculada à aula em superfície opaca.
- Acesso explícito à central de atividades.
- Submissões reais devem usar o contrato idempotente do backend; estados
  simulados não podem ser apresentados como persistência real.

## Saber mais

- Resumos, referências, imagens e materiais complementares.
- Largura editorial limitada e links HTTPS validados.
- Conteúdo vazio mantém orientação e explica o próximo estado.

# Layout

- Desktop: conteúdo flexível e currículo persistente de 390 px à direita.
- Tablet e mobile: modos em seletor horizontal; conteúdo em coluna única.
- A rota da aula não exibe a navegação global do dashboard.

# Design e movimento

- Linguagem “Caderno de Ateliê”: ink, marfim, papel e dourado Lawrence.
- Botões com altura mínima de 48 px e um CTA primário por região.
- Hover entre 120 e 180 ms; mudança de superfície em até 280 ms.
- `disableAnimations` remove transições não essenciais.
- Liquid Glass reservado a controles flutuantes; leitura e formulários são opacos.

# Psicologia e acessibilidade

- Segmentação reduz carga cognitiva.
- Currículo persistente favorece reconhecimento em vez de memória.
- Progresso representa estado real, sem urgência ou escassez artificial.
- Contraste WCAG AA, foco visível e estados que não dependem apenas de cor.
- O aluno deve compreender em até cinco segundos onde está, o que pode fazer e
  qual é a próxima ação.
