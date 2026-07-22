---
name: database-change
type: workflow
version: 2.0.0
status: active
---

# Workflow: mudança de banco/Supabase

1. Confirmar se o projeto usa schema declarativo ou migrations imperativas e consultar a documentação atual do Supabase.
2. Definir motivo, owner, tabelas, volume, compatibilidade, risco e estratégia expand/migrate/contract.
3. Modelar constraints, FKs, `ON DELETE`, índices e timestamps conforme o ciclo de vida real; UUID não elimina a necessidade de threat modeling.
4. Para schemas expostos, habilitar RLS, restringir grants e criar policies por operação com ownership/tenant. UPDATE exige SELECT e `WITH CHECK` quando aplicável.
5. Criar migration pelo workflow do repositório. Destruição, backfill grande e locks exigem plano, backup e aprovação.
6. Testar migration em banco limpo e atualizado, policies adversariais, rollback/forward-fix e queries relevantes com `EXPLAIN (ANALYZE, BUFFERS)` quando seguro.
7. Executar Security, Architecture, QA e Performance Reviews conforme risco.
8. Atualizar schema, contratos e runbook. Nunca alterar produção manualmente.

