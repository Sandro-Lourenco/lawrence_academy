---
name: release
type: workflow
version: 2.0.0
status: active
---

# Workflow: release

1. Identificar versão, ambiente, artefatos, features, migrations, flags, owners e risco.
2. Congelar o artefato e validar provenance, dependências, secrets e configuração.
3. Executar lint, typecheck, testes e builds aplicáveis; registrar comandos e resultados.
4. Validar compatibilidade de migrations, backup/restore, rollout e rollback.
5. Executar Architecture, Security, QA, Performance e Release Reviews aplicáveis.
6. Obter aprovação humana para staging/produção conforme política.
7. Fazer rollout gradual quando possível; executar smoke tests e observar SLOs/alertas.
8. Encerrar somente após a janela de observação ou executar rollback.
9. Atualizar changelog, runbooks e registro da release com evidências.

