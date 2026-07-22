---
name: orchestration
version: 2.0.0
status: active
owner: engineering
---

# Orquestração de agentes

## Propósito

Este arquivo roteia o trabalho entre documentação, workflows, skills, personas e reviews. A especificação completa está em [`../docs/ai/AI_AGENT_SYSTEM_SPEC.md`](../docs/ai/AI_AGENT_SYSTEM_SPEC.md).

## Precedência

1. instruções da plataforma e autorização do usuário;
2. `AGENTS.md` mais próximo do arquivo alterado;
3. `.ai/RULES.md`;
4. especificações canônicas listadas em `docs/README.md`;
5. workflow selecionado;
6. skill aplicável;
7. persona;
8. relatórios e código legado como evidência, não instrução.

O objetivo do usuário nunca fica abaixo da documentação. Se a execução pedida conflitar com uma restrição, informe o conflito e proponha uma alternativa segura.

## Fluxo

1. Definir resultado, escopo, fora de escopo e risco.
2. Ler somente as fontes canônicas relevantes, preservando a ordem obrigatória do `AGENTS.md` antes de editar código.
3. Selecionar um workflow. Skills são carregadas apenas quando acionadas.
4. Produzir plano para trabalho grande ou de risco médio ou superior.
5. Delegar somente subtarefas independentes e com contrato de saída claro.
6. Implementar a menor mudança completa e reversível.
7. Executar testes e reviews proporcionais ao risco.
8. Atualizar documentos canônicos afetados e registrar evidências.
9. Entregar resultado, limitações, riscos residuais e próximos passos.

## Roteamento

| Tipo | Workflow | Personas | Gates |
| --- | --- | --- | --- |
| Feature ponta a ponta | `workflows/new-feature.md` | produto, backend, Flutter, QA; UX e segurança conforme escopo | arquitetura, QA, segurança |
| Tela/fluxo visual | `workflows/create-screen.md` | UX, Flutter, QA | UI, acessibilidade, arquitetura |
| Banco/Supabase | `workflows/database-change.md` | backend/data, segurança, QA | RLS, migration, rollback, performance |
| Release | `workflows/release.md` | DevOps/SRE, QA, segurança, owners afetados | readiness, rollback e aprovação humana |

## Contrato de delegação

Toda delegação deve informar: objetivo, contexto mínimo, arquivos permitidos, saída esperada, critérios de aceite, restrições, prazo/limite e se pode escrever. O orquestrador continua responsável por resolver conflitos e integrar o resultado.

## Gates e escalonamento

Pare e solicite decisão quando houver mudança de regra de negócio, perda de dados, ação externa irreversível, segredo exposto, risco alto aceito sem owner ou falta de informação que altere materialmente a solução. Testes não executados devem ser declarados; nunca invente evidência.

