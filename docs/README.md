---
id: DOC-INDEX-001
title: Documentação da Lawrence Academy
status: active
owner: engineering
last_reviewed: 2026-07-21
review_cycle_days: 90
---

# Documentação da Lawrence Academy

Este é o ponto de entrada canônico para pessoas e agentes de IA. Documentos em `archive/`, `audits/` e `refactor/` registram histórico e não definem o estado atual do produto.

## Fontes de verdade

| Ordem | Tema | Documento canônico |
| --- | --- | --- |
| 1 | Produto e regras de negócio | `product/PED-overview.md` |
| 2 | Arquitetura | `architecture/SYSTEM_ARCHITECTURE.md` |
| 3 | Design | `design/DESIGN_SYSTEM.md` |
| 4 | Navegação e páginas | `navigation/PAGES_OVERVIEW.md` e `pages/` |
| 5 | Estado e offline | `architecture/STATE_AND_OFFLINE_SPEC.md` |
| 6 | API | `api/SERVICE_API.md` e `contracts/` |
| 7 | Dados | `database/DATABASE_SCHEMA.md` e migrations |
| 8 | Segurança | `security/SECURITY_COMPLIANCE_SPEC.md` |
| 9 | Performance | `performance/PERFORMANCE_OPTIMIZATION_SPEC.md` |
| 10 | Operação | `devops/DEVOPS_INFRA.md` |

Em conflito, a especificação canônica vence relatórios e planos antigos. O código e as migrations são evidência do estado implementado; divergências devem ser registradas e resolvidas, nunca ocultadas.

## Tipos de documento

- `product/`, `architecture/`, `design/`, `navigation/`, `api/`, `contracts/`, `database/`, `security/`, `performance/` e `devops/`: referência vigente.
- `pages/`: especificações de comportamento por página.
- `development/`: guias operacionais para tarefas concretas.
- `audits/`: evidências datadas e imutáveis de verificação.
- `refactor/`: planos e relatórios de mudança; não são fonte de verdade permanente.
- `archive/`: material substituído, proibido como base para novas decisões.

## Manutenção

Siga [`standards/DOCUMENTATION_STANDARD.md`](standards/DOCUMENTATION_STANDARD.md). Toda mudança funcional deve atualizar no mesmo pull request a especificação afetada, os contratos e os testes. Decisões arquiteturais irreversíveis ou de alto impacto devem receber um ADR.
