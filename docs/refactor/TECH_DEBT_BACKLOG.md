# Tech Debt Backlog

## B2.25 Pending

- **TD-INFRA-004:** Validate `/api/v1/payments/webhook` in the Stripe Dashboard
  with one signed sandbox delivery before removing `/webhooks/stripe`.
- **TD-ARCH-003 (completed):** v1 contracts for subscription cancellation and
  checkout status are implemented, documented and consumed by Flutter.
- **TD-FLUTTER-004:** Replace `price_placeholder` with an approved per-course
  Stripe price source without trusting a client-supplied price.
- **TD-RUNTIME-001:** Complete password reset, live-room navigation, offline
  sync/cancellation, and certificate download/share before production approval.
- **TD-MOBILE-001:** Run the mandatory acceptance and FPS matrix on a physical
  Android device.
- **TD-ANDROID-001:** Track migration of `workmanager_android` to built-in Kotlin
  before a future Flutter release turns the current warning into a build failure.

Este documento registra as pendências tecnológicas e melhorias não bloqueantes identificadas durante as fases de refatoração do Lawrence Academy, agora segregadas por categoria, de acordo com o Plano Diretor.

## Backend
- **TD-BACKEND-001**: ~~Eliminar 116 erros do mypy em `/core` e `/modules`.~~ (Concluído - TASK-5C-001)
- **TD-BACKEND-002**: Remover `create_checkout_use_case` legado que ainda não segue a interface rígida.
- **TD-BACKEND-003**: Remover rotas legadas após a migração total do Flutter.
- **TD-BACKEND-004**: ~~Revisar o uso do status 500 para timeouts externos (deve ser 502/503).~~ (Concluído - TASK-5C-001)
- **TD-BACKEND-005**: Separar os testes de acesso e checkout no "grace period" (período de carência de pagamento).
- **TD-BACKEND-006**: Padronizar atualização do perfil (Profile) sem utilizar rota `/update` fora do padrão REST.
- **TD-BACKEND-007**: Limpar uso de Repositórios diretos em rotas (aplicar Clean Architecture estritamente nos UseCases).

## Flutter (Frontend)
- **TD-FLUTTER-001**: Remover acoplamento do Flutter com checagens de regras de negócio estritas (ex: lógica pesada de elegibilidade de compra na UI).
- **TD-FLUTTER-002**: Revisar lazy loading do catálogo (Catálogo enorme causará travamentos de UI sem paginação via Riverpod).
- **TD-FLUTTER-003**: Extrair componentes repetidos de botões e cards para a biblioteca de `design_system`.

## Infraestrutura & DevOps
- **TD-INFRA-001**: Criar CI/CD automatizado via GitHub Actions (Lint, Type Checking, Unit Tests).
- **TD-INFRA-002**: Migrar ou documentar precisamente o webhook do Stripe Dashboard apontando para `/api/v1/webhook`.
- **TD-INFRA-003**: Configurar e documentar corretamente o Worker de FFmpeg para upload de vídeos.

## Banco de Dados (Supabase)
- **TD-DB-001**: Versionar as migrations em SQL (ausência de controle de versão explícito das tabelas atuais).
- **TD-DB-002**: Criar constraints mais seguras (ex: status válidos, foreign keys restritas).

## Segurança
- **TD-SEC-001**: Implementar Rate Limiting no FastAPI para prevenir brute force em rotas públicas.
- **TD-SEC-002**: Revisão de todas as permissões (RLS) associadas às tabelas vinculadas a financeiro e vídeo.
- **TD-SEC-003**: Garantir que as chaves de API secretas (Supabase Service Role, Stripe Secret) nunca estejam expostas em nenhum `.env` do app Flutter.
- **TD-SEC-004**: Garantir proteção do Player de vídeo (HLS) com tickets jwt de curta duração.

## Testes
- **TD-TESTS-001**: Implementar mock tests rigorosos para integrações externas (Supabase Auth, Stripe) isolando os UseCases no Backend.
- **TD-TESTS-002**: Criar fluxos de `integration_test` no Flutter cobrindo do Login até o Player de Vídeo.
- **TD-TESTS-003**: Refatorar os testes de `video_worker` para corrigir conflito de nome de módulo `main` (`AttributeError: module 'main' has no attribute 'process_job'`).

## Arquitetura e Código Base (Pós-Auditoria)
- **TD-ARCH-001**: Remover mocks legados inseridos provisoriamente em `SubmitTaskUseCase` (backend), Rotas de Stripe e `dashboard_controller.dart` (Flutter).
- **TD-ARCH-002**: Atualizar codebase Dart substituindo `.withOpacity()` por `.withValues()` para resolver 200+ warnings do motor Impeller.
