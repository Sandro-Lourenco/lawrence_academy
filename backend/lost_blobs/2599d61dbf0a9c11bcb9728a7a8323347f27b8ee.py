# Project Status

## Project Recovery
**Status:** RECOVERY_IN_PROGRESS / PRODUCTION_BLOCKED

The Phase A audit on 2026-07-12 supersedes prior production approvals for the
current worktree. Phase B is authorized and B0 incident containment is complete,
including credential rotation confirmation and local Git history cleanup.
B1 quality-gate automation is implemented but still awaits a clean GitHub run and
database reset evidence. Production remains prohibited until B1-B6 pass.

Source of truth: `docs/refactor/PROJECT_RECOVERY_PHASE_A.md`.

## Project Recovery B2.24
**Status:** B2_NEEDS_CHANGES / B3_BLOCKED / PRODUCTION_BLOCKED

Lesson progress now uses PATCH semantics, server-calculated percentage, duration
validation, idempotent monotonic merge, and reviewed RLS/grants. Authorized
Flutter legacy lots were removed with a binary snapshot and full per-lot gates.
Remaining blockers are external Stripe Dashboard validation and two active
subscription workflows without an implemented backend contract.

## STAB-001: Project Stabilization
**Status:** PRODUCTION

A sprint de estabilização STAB-001 foi concluída com absoluto sucesso.
- O aplicativo Flutter compila (`web` e `apk`) sem erros.
- A análise estática do Flutter retorna `0 issues` (sem warnings soltos e sem vazamento de UI themes).
- Os testes do Python Backend foram corrigidos (5 testes legados falhos). Agora há 100% de sucesso (82 testes passaram).

## Phase 6D: Offline Progress & Telemetry Sync
**Status:** BLOCKED / APPROVED_TO_START

A implementação anterior estava bloqueada pela necessidade de uma base estável, agora que as fundações de QA e compilação estão sólidas, podemos reiniciar oficialmente a implementação detalhada da Phase 6D (como features limpas).
