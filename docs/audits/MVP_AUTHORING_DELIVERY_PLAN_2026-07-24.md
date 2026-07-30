---
id: AUDIT-MVP-AUTHORING-2026-07-24
title: Plano de estabilização do MVP de autoria
status: active
owner: engineering
reviewed_at: 2026-07-24
---

# Objetivo

Entregar primeiro o fluxo mínimo confiável:

`professor -> curso -> módulo -> aula -> conteúdo -> vídeo -> publicação`

O lançamento não deve permitir duplicação por clique repetido, retry de rede ou
concorrência, nem expor rascunhos no catálogo publicado.

# Decisão de escopo

Até este fluxo passar pelos gates abaixo, novas funcionalidades fora do MVP
ficam fora do caminho crítico. Relatórios históricos não definem readiness.

# Diagnóstico atual

## P0 — resolvidos localmente

1. POSTs críticos possuem idempotência transacional e resposta replayável.
2. Publicação usa uma única RPC com lock, ownership, revisão, checklist e snapshot.
3. Restauração está alinhada à RPC definida pela migration.
4. Leitura publicada falha fechada e usa somente a versão imutável corrente.
5. Campos de oferta aceitos pela API são persistidos.

## P1 — devem entrar na estabilização

1. [concluído] Reordenação de blocos usa RPC transacional com CAS.
2. [concluído] Autosave é serializado, tem debounce e CAS servidor/cliente.
3. [concluído] Polling antigo não sobrescreve edição mais nova.
4. A rota documentada de criação e a rota Flutter são diferentes.
5. A documentação mistura um wizard vigente de cinco fases com aceite legado
   de oito etapas.
6. O cliente `service_role` usado pelo backend ignora RLS; cada mutação precisa
   de autorização explícita e testes BOLA, ou deve migrar para RPC atômica com
   autorização no banco.

# Atividades por especialista

## Data/Supabase + Backend

- Criar idempotência versionada para todas as mutações de criação, com escopo
  por agregado e resposta replayável.
- Tornar publicação uma RPC única: lock do curso, ownership, checklist,
  `expected_updated_at`, chave de intenção/hash e snapshot.
- Criar reorder em lote transacional.
- Adicionar testes pgTAP de retry, concorrência, grants, RLS e ownership.
- Remover fallbacks permissivos e manter leitura pública fail-closed.

Aceite: duas requisições simultâneas com a mesma intenção produzem uma linha e
a mesma resposta; publicação repetida do mesmo estado produz uma versão.

## Flutter

- Manter uma chave de intenção estável até sucesso ou cancelamento.
- Bloquear reentrada no controller, não apenas desabilitar visualmente botões.
- [concluído no cliente em 2026-07-24] Implementar autosave serializado com
  debounce e revisão otimista: alterações de planejamento e oferta usam
  debounce de 800 ms, mantêm somente o payload mais recente e nunca executam
  dois PATCHes simultâneos. Uma revisão monotônica local impede que uma
  resposta anterior limpe o indicador de alterações mais novas. Falhas
  recuperáveis preservam o payload pendente para retry. O cliente envia
  `expected_authoring_revision`, incorpora a nova `authoring_revision` da
  resposta e, em conflito 409, bloqueia retry automático, preserva o rascunho e
  exige atualização/reconciliação explícita antes de salvar novamente.
- [concluído em 2026-07-24] Impedir polling antigo de sobrescrever revisões
  recentes: a resposta só é aplicada quando o curso observado ainda é a mesma
  revisão local e a rota continua no mesmo curso.
- [concluído em 2026-07-24] Exibir erro recuperável e estado offline no Studio:
  falhas de rede e timeout são apresentadas com título, mensagem e ícone
  orientados à recuperação, preservando o conteúdo autorável já carregado.

Aceite: testes de provider provam um único POST sob chamadas simultâneas e
preservação do rascunho após falha recuperável.

## QA/Security

- Criar E2E do fluxo completo de professor.
- Executar cenários de double-click, timeout seguido de retry, duas abas,
  publicação concorrente, BOLA e falha parcial de upload.
- Validar que estudantes só leem a versão imutável atual.
- Exigir evidência de migration limpa e atualizada antes do go-live.

Aceite: nenhuma duplicação, nenhum rascunho exposto e nenhuma mutação cross-owner
nos cenários adversariais.

## DevOps/SRE

- Tornar backend tests, Flutter analyze/test, migrations e pgTAP gates do CI.
- Fixar versões, preservar lockfiles e validar os breaking changes do Supabase.
- Preparar staging, rollback, observabilidade e alertas de erro/duplicação.

# Gates de lançamento

O resultado atual é **NO-GO** até todos os itens abaixo estarem comprovados:

- idempotência transacional de autoria e publicação;
- migrations aplicáveis do zero e sobre o schema anterior;
- testes backend, Flutter, pgTAP e E2E verdes;
- autorização adversarial e RLS validadas;
- fluxo completo testado em staging;
- rollback e monitoramento disponíveis;
- aprovação humana antes de produção.

# Correções iniciadas nesta auditoria

- RPC de restauração alinhada ao nome definido pela migration.
- leitura de versão publicada alterada para falhar fechada;
- campos de oferta aceitos pela API passam a ser mapeados e persistidos;
- guardas locais contra reentrada adicionadas ao salvamento de rascunho e às
  ações de criar/duplicar blocos.

Essas guardas Flutter reduzem cliques duplicados, mas não substituem a
idempotência no servidor, que continua sendo o gate principal.
