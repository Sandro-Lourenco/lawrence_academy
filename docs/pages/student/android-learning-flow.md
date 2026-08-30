# Fluxo de aprendizagem Android

## Escopo

Experiência autenticada da aluna em telas abaixo de 700 dp. O fluxo preserva
as rotas canônicas `/dashboard/home`, `/dashboard/courses/:courseId` e
`/dashboard/activities/:activityId`.

## Home

- Barra de utilidades com menu, busca e notificações.
- Cursos em andamento em lista horizontal, com progresso e acesso ao detalhe.
- Atalho para formações/planos de estudo e atividades.
- Estados loading, empty, error e conteúdo em cache usam os componentes
  compartilhados.

## Curso adquirido

- Resumo, progresso e ação dominante para iniciar ou continuar.
- Ações secundárias de download offline, plano de estudo, pausa, conclusão,
  fórum e remoção, sempre com rótulo textual e alvo mínimo de 48 dp.
- Abas roláveis: Aulas, Pré-requisitos e Instrutores.
- O acesso continua protegido pela elegibilidade de assinatura antes da tela.

## Atividade

- Enunciado e alternativas são priorizados no mobile; metadados ficam em uma
  faixa compacta.
- Alternativas possuem letra, texto, estado selecionado e retorno semântico.
- A resposta permanece local em caso de falha e o envio mantém a chave de
  idempotência já definida pelo controller da tela.

## Direção visual e acessibilidade

- Fundo claro estável no app Android, com vinho, ameixa e marfim da Lawrence.
- Tipografia Cormorant Garamond + Inter e iconografia Material coerente com a
  referência funcional.
- Compatível com TalkBack, escala de texto, reduced motion e navegação por
  alvos de pelo menos 48 dp.
