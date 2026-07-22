---
id: PAGE-SPEC-INDEX
title: Especificações de página
status: active
owner: product
last_reviewed: 2026-07-21
review_cycle_days: 90
---

# Especificações de página

Cada arquivo descreve comportamento observável de uma rota ou componente de estado compartilhado. O código pode estar diferente; nesse caso, registre a divergência e decida qual lado deve mudar.

## Template mínimo

```yaml
---
id: PAGE-<AREA>-<NNN>
title: <nome>
status: draft | active | deprecated
owner: product
route: /path
actors: [student]
auth: required | optional | public
last_reviewed: YYYY-MM-DD
---
```

1. Objetivo do usuário
2. Escopo e fora de escopo
3. Pré-condições e permissões
4. Fluxo principal e fluxos alternativos
5. Estados aplicáveis: loading, success, empty, error e offline
6. Conteúdo e ações
7. Responsividade
8. Acessibilidade WCAG 2.2 AA
9. Contratos/API e modelo de estado
10. Eventos analíticos, sem PII
11. Critérios de aceite verificáveis

Use apenas um H1. Não transforme inspirações visuais em requisitos. Estados que não se aplicam devem ser marcados como `N/A` com justificativa.
