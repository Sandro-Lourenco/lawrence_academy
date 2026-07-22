# Plano de ação — trabalho remanescente

Data: 21/07/2026

## Diagnóstico executivo

As nove telas principais da experiência do aluno estão padronizadas e a suíte
Flutter está estável (`flutter analyze` sem ocorrências e 104 testes aprovados
na consolidação). Isso não significa que a jornada esteja pronta para produção:
algumas telas ainda exibem estados vazios reais porque não existe contrato de
backend, e outros fluxos possuem ações incompletas ou validação apenas
automatizada.

O estado oficial deve permanecer `PRODUCTION_BLOCKED` até que os gates abaixo
sejam concluídos. Relatórios antigos que declaram módulos completos ou go-live
não substituem evidência de execução em dispositivo, Stripe sandbox, Supabase
local e ambiente de homologação.

## Pendências confirmadas

### P0 — bloqueadores de produção

1. Validar em Android físico: autenticação, catálogo, checkout, curso adquirido,
   player HLS, progresso, retomada, offline e logout.
2. Substituir `price_placeholder` por uma fonte aprovada de preço Stripe por
   curso e validar checkout/webhook no Stripe sandbox.
3. Criar fixtures de homologação com usuário, curso, módulos, aulas, assinatura,
   progresso e certificado para permitir teste real ponta a ponta.
4. Executar novamente os gates atuais de backend, Flutter, OpenAPI, migrations,
   SQL/RLS e builds; os números existentes pertencem a momentos diferentes do
   worktree.
5. Fechar o inventário de rotas legadas e remover aliases somente após janela de
   logs sem consumidores.

### P1 — jornada principal do aluno

1. Projetos: modelar banco, RLS, Storage, API e repositórios Flutter para lista,
   detalhe, criação, etapas, materiais, fotos, anotações e compartilhamento.
2. Conquistas: definir regras de produto e implementar leitura de pontos, nível,
   sequência e badges. O provider atual retorna lista vazia por padrão.
3. Perfil e preferências: implementar edição, avatar, notificações, privacidade e
   alteração/recuperação de senha. Hoje o perfil possui apenas leitura real.
4. Aula: concluir materiais, exercícios, comentários e anotações com estados
   offline e sincronização.
5. Player: validar legendas, qualidade, velocidade, tela cheia, acessibilidade e
   retomada em dispositivo físico.
6. Certificados: implementar download e compartilhamento; os botões ainda não
   executam essas ações.

### P1 — integridade operacional e segurança

1. Conectar o scheduler Flutter ao endpoint canônico de sincronização e trocar o
   estado fixo da tela de downloads por estado real.
2. Remover URLs e resultados simulados do fluxo runtime de sync e workers; mocks
   devem existir apenas nos testes.
3. Validar todas as novas tabelas expostas com RLS, políticas de ownership,
   índices e testes contra BOLA/IDOR.
4. Validar upload seguro com URL assinada, tipos/tamanhos permitidos, isolamento
   por usuário e revogação de acesso.
5. Integrar observabilidade de produção: Sentry, logs estruturados, métricas de
   sync, player, checkout e webhook, sem tokens ou dados sensíveis.

### P2 — módulos complementares

1. Lives: substituir eventos estáticos e implementar entrada na sala/player.
2. Favoritos: substituir derivação mock por persistência real.
3. Calendário: concluir grade responsiva e dados reais.
4. Professor: validar CRUD de cursos, módulos e aulas, upload HLS e gestão de
   alunos de ponta a ponta.
5. Admin, cache/paginação e otimizações avançadas devem entrar depois dos fluxos
   P0/P1, salvo requisito operacional comprovado.

## Plano de execução proposto

### Fase 01 — baseline confiável e homologação local

- Congelar o escopo do próximo release e catalogar alterações do worktree.
- Corrigir documentos conflitantes e escolher um único status oficial.
- Criar fixtures reproduzíveis no Supabase local/homologação.
- Executar e registrar Flutter, backend, OpenAPI, SQL/RLS, migrations e builds.
- Critério de saída: todos os gates verdes no mesmo commit e ambiente.

### Fase 02 — compra real e acesso ao curso

- Aprovar a fonte de `stripe_price_id` por curso.
- Integrar catálogo/detalhe/checkout sem placeholder.
- Validar webhook canônico, idempotência, polling, cancelamento e expiração.
- Testar compra no Stripe sandbox e liberação do curso no Android físico.
- Critério de saída: curso pago libera somente o comprador e o webhook repetido
  não duplica assinatura ou cobrança.

### Fase 03 — aprendizagem ponta a ponta

- Validar upload e processamento HLS com URLs temporárias.
- Completar player, progresso, retomada, materiais e exercícios.
- Conectar anotações e comentários aos contratos aprovados.
- Testar bloqueio de conteúdo sem assinatura e perda/retorno de rede.
- Critério de saída: o aluno conclui uma aula, reinicia o app e retoma do estado
  correto sem acesso indevido ao vídeo.

### Fase 04 — projetos do aluno

- Aprovar regras de privacidade e compartilhamento.
- Criar migrations, RLS, Storage policies, API, casos de uso e UI integrada.
- Cobrir criação, edição, etapas, anexos, fotos, notas, conclusão e exclusão.
- Critério de saída: projeto completo persiste, sincroniza e só é visível segundo
  a política aprovada.

### Fase 05 — perfil, preferências e conquistas

- Implementar edição de perfil/avatar e recuperação de senha.
- Implementar preferências, notificações e privacidade.
- Aprovar regras de gamificação antes de criar schema ou métricas.
- Integrar conquistas com eventos reais de curso e projeto.
- Critério de saída: nenhuma métrica é inventada e toda mutação respeita usuário,
  papel e RLS.

### Fase 06 — offline, certificados e ações auxiliares

- Conectar fila local e `/api/v1/offline` com resolução de conflitos definida.
- Implementar cancelamento real de download e metadados do curso.
- Remover respostas mock de runtime.
- Implementar download/compartilhamento seguro de certificados.
- Critério de saída: cenários online → offline → online preservam progresso sem
  duplicação e arquivos protegidos não ficam públicos.

### Fase 07 — validação de release

- Executar E2E dos fluxos críticos em Android físico e Flutter Web.
- Medir WCAG/TalkBack/teclado, FPS, tempo de API, memória e falhas de rede.
- Executar testes de segurança, carga, recuperação e rollback.
- Validar Sentry, logs, alertas, backups e runbooks.
- Critério de saída: nenhuma pendência P0/P1, evidência anexada ao mesmo release
  candidate e aprovação formal de Produto, Segurança e QA.

## Ordem recomendada

Começar pela Fase 01. A Fase 02 é o maior risco de negócio; a Fase 03 é o núcleo
do produto. Projetos e gamificação devem vir depois dos contratos críticos de
compra e aprendizagem, evitando ampliar uma interface bonita sobre integrações
que ainda não foram comprovadas.

