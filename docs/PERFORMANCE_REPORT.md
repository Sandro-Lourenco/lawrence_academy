# Relatório de Performance — Fase 2

## Implementado

- Resumo do dashboard deriva métricas do estado Riverpod sem I/O.
- `Wrap` adaptativo evita árvores separadas por plataforma.
- Cards novos não repetem blur.
- Catálogo mantém `GridView.builder` e skeleton estável.

## Riscos

- Catálogo ainda carrega lista completa e payload inclui módulos/aulas.
- Dashboard faz requisições separadas para perfil, cursos e progresso.
- FPS, rebuilds, memória e P95 ainda precisam de medição runtime.

Próximos passos: Flutter DevTools, P95 dos endpoints, `EXPLAIN ANALYZE`, DTO de card e paginação por cursor.
