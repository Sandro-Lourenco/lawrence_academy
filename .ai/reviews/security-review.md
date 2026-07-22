---
name: security-review
type: review
version: 2.0.0
---

# Security Review

## Verificar

Trust boundaries; JWT/sessão; RBAC/ABAC e ownership; BOLA; RLS e grants; service keys; validação/encoding; uploads; SSRF; webhooks e idempotência; pagamentos; secrets; logs/PII; dependências; prompt injection e tool permissions quando houver IA.

## Saída

Para cada achado, registrar ativo, ameaça, evidência, impacto, probabilidade, severidade, correção e teste. Resultado: `APPROVED`, `APPROVED_WITH_RISK` ou `CHANGES_REQUIRED`. Somente owner humano aceita risco alto/crítico.

