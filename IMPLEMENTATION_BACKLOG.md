# Implementation Backlog

## Project Recovery B2.25
**Status:** NEEDS_CHANGES

- [x] Harden lesson progress contract and use PATCH semantics.
- [x] Canonicalize database permissions and pass all SQL/RLS tests.
- [x] Preserve binary legacy snapshot and remove authorized Flutter lots.
- [x] Implement and approve the backend contract for subscription cancellation.
- [x] Implement and approve the backend contract for checkout status.
- [x] Migrate Flutter consumers to both canonical v1 routes.
- [x] Pass backend, Flutter, OpenAPI, SQL/RLS, APK, App Bundle and Web gates.
- [ ] Validate the canonical Stripe webhook in Dashboard/sandbox.
- [ ] Execute the mandatory flow on a physical Android device.
- [ ] Replace `price_placeholder` with an approved per-course Stripe price source.
- [ ] Complete the partial runtime flows listed in `RUNTIME_FUNCTIONAL_REPORT.md`.

## STAB-001: Project Stabilization
**Status:** COMPLETED

- [x] Correção Global Flutter Analyze (Reduzir 351 erros a 0).
- [x] Correções dos testes legados no backend (Pytest: `test_certificates.py`, `test_phase4_validation.py`, `test_main_api.py`).
- [x] Aprovação limpa em `flutter build apk --debug` e `flutter build web`.
- [x] Geração de Relatórios de Estabilização, QA e Arquitetura.

## Phase 6D: Offline Progress & Telemetry Sync
**Status:** APPROVED_TO_START

- [ ] (A fazer em nova sprint) Garantir a integração e cobertura 100% dos novos endpoints Sync e repositórios locais que ainda precisam se conectar no fluxo sem quebras.
- [ ] Implementação de lógica complementar e validação QA final da Phase 6D pós-estabilização.

- [x] RC1 Homologation completed and approved.
\n- [x] GO-LIVE v1.0.0 concluído.\n
