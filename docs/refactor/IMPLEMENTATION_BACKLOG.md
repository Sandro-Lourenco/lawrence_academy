# IMPLEMENTATION_BACKLOG.md

## Project Recovery B2.25

- **Done:** PATCH progress semantics, server percentage calculation, duration
  rejection, permission migration, SQL/RLS tests, snapshot, and safe legacy lots.
- **Done:** canonical subscription cancellation and checkout status APIs, Flutter
  v1 migration, contract tests, OpenAPI and release build gates.
- **External blocker:** verify Stripe Dashboard and signed sandbox delivery.
- **Runtime blockers:** physical Android validation, approved per-course Stripe
  price source, and the partial flows inventoried in `RUNTIME_FUNCTIONAL_REPORT.md`.

# Lawrence Academy - Backlog Oficial de Execução

Este é o documento oficial de execução do projeto. Todas as próximas implementações deverão partir **exclusivamente** deste backlog.

---

## Sprint 1: Estabilização Financeira (Fase 5C)
**Objetivo:** Eliminar débitos técnicos críticos do backend e estabilizar o fluxo financeiro (Stripe Webhooks) e controle rigoroso de assinaturas via RLS.

### Fase 5C - Lote 1: Tech Debt & Idempotência

#### Task 5C-001
- **Título:** Eliminar erros do mypy e padronizar HTTP Exceptions
- **Descrição:** Corrigir 116 erros de mypy no backend e refatorar status HTTP 500 do API Gateway para 502/503 quando forem erros externos.
- **Objetivo:** Aumentar confiabilidade do backend e evitar falhas de deploy.
- **Motivação:** Código frágil gera bugs silenciosos em produção.
- **Prioridade:** Média
- **Status:** Done
- **Complexidade:** M
- **Dependências:** Nenhuma
- **Arquivos previstos:** `backend/src/core/exceptions.py`, `backend/src/modules/` (anotações de tipo).
- **Documentação obrigatória:** `TECH_DEBT_BACKLOG.md`, `SERVICE_API.md`
- **Workflow obrigatório:** `refactor-code` / `architecture-review`
- **Skills obrigatórias:** `review-code`, `optimize-performance`
- **Personas obrigatórias:** `backend-architect`, `qa-engineer`
- **Reviews obrigatórios:** `architecture-review`
- **Critérios de aceite:** `mypy .` roda com 0 erros. Status 502 é mapeado globalmente no handler do FastAPI.
- **Critérios de conclusão:** PR aprovado, pipelines verdes.
- **Riscos:** Quebra de contratos por alteração de tipos.
- **Estimativa:** 1 dia.

#### Task 5C-002
- **Título:** Migrar Stripe Webhooks para API v1 e implementar Idempotência
- **Descrição:** Mover e documentar endpoint do webhook para `POST /api/v1/payments/webhook`. A rota legada `/webhooks/stripe` deve receber um plano de depreciação controlado (não ser removida sem atualizar o Stripe Dashboard). Implementar idempotência no processamento para evitar duplicação de assinaturas ativadas/canceladas.
- **Objetivo:** Blindar o sistema financeiro contra eventos duplicados do Stripe e organizar a arquitetura de rotas v1.
- **Motivação:** Garantir que o SaaS opere sem inconsistências financeiras.
- **Prioridade:** Crítica
- **Status:** Done
- **Complexidade:** L
- **Dependências:** Task 5C-001
- **Arquivos previstos:** `backend/src/modules/payments/application/process_webhook.py`, `backend/src/modules/payments/interface/api/routes.py`
- **Documentação obrigatória:** `docs/api/SERVICE_API.md`, `docs/security/SECURITY_COMPLIANCE_SPEC.md`
- **Workflow obrigatório:** `new-feature`
- **Skills obrigatórias:** `create-api`, `review-code`
- **Personas obrigatórias:** `backend-architect`, `security-engineer`
- **Reviews obrigatórios:** `architecture-review`, `security-review`
- **Critérios de aceite:** Webhook aceita requests do Stripe e bloqueia reprocessamento do mesmo `event_id`.
- **Critérios de conclusão:** Testes mockados cobrindo fluxo sucesso/falha do Webhook.
- **Riscos:** Perder eventos financeiros por bloqueio indevido.
- **Estimativa:** 2 dias.

### Fase 5C - Lote 2: RBAC & Segregação no Frontend

#### Task 5C-003
- **Título:** Sincronização Fina RLS e Supabase Auth Roles
- **Descrição:** Atualizar policies de RLS para checar estritamente a tabela `user_roles`.
- **Objetivo:** Proteger a camada de banco de dados contra leituras/alterações indevidas.
- **Motivação:** Segurança em primeiro lugar (Zero Trust).
- **Prioridade:** Alta
- **Status:** Done
- **Complexidade:** M
- **Dependências:** Task 5C-002
- **Arquivos previstos:** `database/policies/*`, `DATABASE_SCHEMA.md`
- **Documentação obrigatória:** `DATABASE_SCHEMA.md`, `SECURITY_COMPLIANCE_SPEC.md`
- **Workflow obrigatório:** `database-change`
- **Skills obrigatórias:** `review-code`
- **Personas obrigatórias:** `backend-architect`, `security-engineer`
- **Reviews obrigatórios:** `security-review`
- **Critérios de aceite:** Consultas anônimas ou de alunos não conseguem ler módulos não adquiridos.
- **Critérios de conclusão:** Políticas aplicadas no Supabase de testes e validadas.
- **Riscos:** Bloquear acesso acidental a usuários válidos.
- **Estimativa:** 2 dias.

#### Task 5C-004
- **Título:** Desacoplamento de Regras Financeiras no Flutter
- **Descrição:** Remover do Flutter verificações estritas de negócio (elegibilidade de compra) e depender unicamente da resposta do Backend (`ValidateCheckoutEligibilityUseCase`).
- **Objetivo:** Deixar o backend como autoridade exclusiva.
- **Motivação:** Prevenir bypass no client.
- **Prioridade:** Média
- **Status:** Done
- **Complexidade:** M
- **Dependências:** Task 5C-003
- **Arquivos previstos:** `lawrence/lib/features/subscriptions/presentation/*`, `lawrence/lib/features/courses/presentation/*`
- **Documentação obrigatória:** `docs/architecture/FRONTEND_ARCHITECTURE.md`, `docs/contracts/`
- **Workflow obrigatório:** `create-screen` (Refatoração de fluxo visual)
- **Skills obrigatórias:** `review-code`, `create-premium-flutter-screen`
- **Personas obrigatórias:** `flutter-architect`, `ui-ux-designer`
- **Reviews obrigatórios:** `architecture-review`, `ui-review`
- **Critérios de aceite:** Frontend só habilita botões de checkout após consulta à API.
- **Critérios de conclusão:** UI atualizada e testes locais passando.
- **Riscos:** Atraso de UX caso API demore a responder.
- **Estimativa:** 1 dia.

---

## Sprint 2: Portal do Professor & Video HLS (Fase 5D)
**Objetivo:** Permitir upload de vídeos assíncronos e gestão de alunos pelos professores.

### Fase 5D - Lote 1: Teacher CRUD

#### Task 5D-001
- **Título:** CRUD de Cursos e Módulos para Professores (Backend)
- **Descrição:** Rotas `/teacher/courses` e validação RBAC (`teacher`).
- **Objetivo:** Permitir ao professor criar e editar conteúdo.
- **Motivação:** A plataforma precisa de conteúdo gerenciado.
- **Prioridade:** Alta
- **Status:** Done
- **Complexidade:** L
- **Dependências:** Task 5C-004
- **Arquivos previstos:** `backend/src/modules/courses/interface/api/routes.py`, `UseCases`.
- **Documentação obrigatória:** `SERVICE_API.md`, `docs/pages/teacher/`
- **Workflow obrigatório:** `new-feature`
- **Skills obrigatórias:** `create-api`
- **Personas obrigatórias:** `backend-architect`, `qa-engineer`
- **Reviews obrigatórios:** `architecture-review`
- **Critérios de aceite:** Professores podem criar cursos vinculados ao seu ID. Alunos não podem.
- **Critérios de conclusão:** Rotas documentadas e testadas unitariamente.
- **Riscos:** Exposição de rotas.
- **Estimativa:** 3 dias.

#### Task 5D-002
- **Título:** Teacher Studio UI (Flutter)
- **Descrição:** Construção do painel visual (Web/Desktop preferred) para criação de cursos, integração com API `/teacher/courses`.
- **Objetivo:** Fornecer interface visual de autoria.
- **Motivação:** Necessidade de negócio.
- **Prioridade:** Alta
- **Status:** Done
- **Complexidade:** XL
- **Dependências:** Task 5D-001
- **Arquivos previstos:** `lawrence/lib/features/teacher/*`
- **Documentação obrigatória:** `docs/pages/teacher/*`, `COMPONENTS.md`, `ANIMATIONS.md`
- **Workflow obrigatório:** `create-screen`
- **Skills obrigatórias:** `create-page`, `create-premium-flutter-screen`
- **Personas obrigatórias:** `flutter-architect`, `ui-ux-designer`
- **Reviews obrigatórios:** `ui-review`, `architecture-review`
- **Critérios de aceite:** Telas 100% responsivas, integradas com a API.
- **Critérios de conclusão:** Widget tests básicos passados, UI testada.
- **Riscos:** Complexidade alta de gerenciamento de formulários grandes em Flutter.
- **Estimativa:** 5 dias.

### Fase 5D - Lote 2: Upload Seguro de Vídeo (HLS)

#### Task 5D-003
- **Título:** Infra de Pre-signed URLs para Uploads
- **Descrição:** Endpoint `/lessons/{id}/upload` retorna URL assinada do Supabase Storage.
- **Objetivo:** Evitar passagem de grandes binários pela API FastAPI.
- **Motivação:** Escalabilidade de backend.
- **Prioridade:** Crítica
- **Status:** ✅ Done (2026-07-11)
- **Complexidade:** M
- **Dependências:** Task 5D-002
- **Arquivos previstos:** `backend/src/modules/lessons/*`
- **Documentação obrigatória:** `SERVICE_API.md`, `SECURITY_COMPLIANCE_SPEC.md`
- **Workflow obrigatório:** `new-feature`
- **Skills obrigatórias:** `create-api`
- **Personas obrigatórias:** `backend-architect`, `security-engineer`
- **Reviews obrigatórios:** `architecture-review`, `security-review`
- **Critérios de aceite:** URL gerada possui tempo de expiração rigoroso.
- **Critérios de conclusão:** Somente o dono do curso pode gerar URL de upload para suas aulas.
- **Riscos:** Vazamento de buckets de storage.
- **Estimativa:** 2 dias.
- **Relatório:** `docs/refactor/TASK_5D_003_REPORT.md`
- **Testes:** 27/27 PASSED, 69/69 suite completa PASSED


#### Task 5D-004
- **Título:** Video Worker Base (FFmpeg)
- **Descrição:** Configurar Worker assíncrono básico em Python para capturar evento do Storage e iniciar mock de compressão (preparação HLS).
- **Objetivo:** Processamento off-main-thread de vídeo.
- **Motivação:** Evitar travamentos do backend.
- **Prioridade:** Alta
- **Status:** ✅ Done (2026-07-11)
- **Complexidade:** L
- **Dependências:** Task 5D-003
- **Arquivos previstos:** `workers/video-worker/*`
- **Documentação obrigatória:** `SYSTEM_ARCHITECTURE.md`
- **Workflow obrigatório:** `new-feature`
- **Skills obrigatórias:** `review-code`
- **Personas obrigatórias:** `backend-architect`, `qa-engineer`
- **Reviews obrigatórios:** `architecture-review`
- **Critérios de aceite:** Worker escuta fila/evento e atualiza tabela `media_status`.
- **Critérios de conclusão:** Fluxo de ponta a ponta logado e validado.
- **Riscos:** Custo de CPU em nuvem.
- **Estimativa:** 4 dias.
- **Relatório:** `docs/refactor/TASK_5D_004_REPORT.md`
- **Testes:** 6/6 testes de worker PASSED, suite total backend PASSED


---
## Restante do Backlog (Próximas Sprints)

*(O detalhamento minucioso seguirá nas Sprints 3 e 4, conforme planejamento executivo, englobando Fase 5E, Fase 6 e Fase 7. Serão documentadas tasks no mesmo formato quando a Sprint 2 estiver em reta final).*

---

## Grafo de Dependências Críticas

```text
[Sprint 1: Base & Financeira]
Task 5C-001 (Mypy & Exceções)
 ↓
Task 5C-002 (Webhooks Stripe & Idempotência)
 ↓
Task 5C-003 (RLS Refino)
 ↓
Task 5C-004 (Flutter Desacoplado)

[Sprint 2: Portal e Upload]
Task 5C-004
 ↓
Task 5D-001 (API Teacher CRUD)
 ↓
Task 5D-002 (Flutter Teacher UI)
 ↓
Task 5D-003 (Pre-signed URL API)
 ↓
Task 5D-004 (Video Worker FFmpeg)

[Sprint 3: Interatividade - Planejada]
Task 5D-004
 ↓
Task 6A-001 (Assessments e Tasks Reais)
```

*(Sem dependências circulares. Toda task subsequente aguarda o fechamento e QA da anterior).*

---

## Sprint 3: Interatividade e Avaliações (Fase 6A)

### Fase 6A - Lote 1: Tarefas (Assessments) Reais

#### Task 6A-001
- **Título:** Migração de Tarefas Simuladas para Fluxo Real Backend/Frontend
- **Descrição:** Implementação do fluxo de tarefas (Tasks) para os alunos com rotas de API protegidas (`GET /api/v1/tasks/lesson/{lesson_id}` e `POST /api/v1/tasks/{task_id}/submissions`), correção automática de objetivas, uso de chaves de idempotência, e scaffold completo no Flutter usando Feature First e Riverpod state management.
- **Objetivo:** Eliminar dados mockados das tarefas dos alunos e garantir a autoridade do backend.
- **Motivação:** Fase 6A Master Plan. 
- **Prioridade:** Alta
- **Status:** ✅ Done (2026-07-11)
- **Complexidade:** XL
- **Dependências:** Fase 5 concluída.
- **Arquivos previstos:** `backend/src/modules/assessments/*`, `lawrence/lib/features/tasks/*`
- **Documentação obrigatória:** `docs/refactor/MASTER_IMPLEMENTATION_PLAN.md`
- **Workflow obrigatório:** `new-feature`
- **Skills obrigatórias:** `create-api`, `create-page`
- **Personas obrigatórias:** `backend-architect`, `flutter-architect`
- **Reviews obrigatórios:** `architecture-review`
- **Critérios de aceite:** Backend gerencia estado, nota e tentativas. Frontend renderiza dinamicamente e suporta idempotência e preservação local.
- **Critérios de conclusão:** Códigos e scaffolds implementados, repo Supabase e rotas FastAPI configuradas. Testes mapeados.
- **Riscos:** Perda de estados ao rotacionar tela, sincronização offline complexa (adiada para 6B).
- **Estimativa:** 4 dias.
- **Relatório:** `docs/refactor/TASK_6A_001_REPORT.md`

#### Task 6A-002
- **Título:** Saneamento de Mocks e Dependências (Auditoria 6A)
- **Descrição:** Remover mocks provisórios no backend (SubmitTaskUseCase, routes de pagamentos) e frontend (dashboard_controller). Corrigir quebra de import nos testes do `video_worker` (module 'main'). Atualizar `.withOpacity` para `.withValues` em toda a lib do Flutter.
- **Objetivo:** Limpar a base de código (tech debts críticos gerados ou identificados na sprint) antes de avançar para Offline Sync.
- **Motivação:** Resultado do Audit Report.
- **Prioridade:** Alta
- **Status:** ✅ Done (2026-07-11)
- **Complexidade:** M
- **Dependências:** Task 6A-001.
- **Arquivos previstos:** `backend/src/*`, `backend/tests/*`, `lawrence/lib/*`.
- **Documentação obrigatória:** `docs/audits/ARCHITECTURE_AUDIT_REPORT.md`
- **Workflow obrigatório:** `refactor-code`
- **Skills obrigatórias:** `review-code`
- **Personas obrigatórias:** `backend-architect`, `flutter-architect`
- **Reviews obrigatórios:** `architecture-review`
- **Critérios de aceite:** Testes do video_worker passando 100%. Flutter Analyze sem 248 warnings de Opacity. Mocks retirados de código produtivo.
- **Critérios de conclusão:** Todos os checks locais no backend e no flutter verdejando.
- **Riscos:** Nenhum significativo.
- **Estimativa:** 1 dia.
## Sprint 4: Infraestrutura Offline & Sync (Fase 6B)

### Fase 6B - Lote 1: Banco e Sincronização Flutter e Backend

#### Task 6B-001
- **Título:** Setup Offline Flutter (SQLite, Hive e Sync Engine Base)
- **Descrição:** Implementar a arquitetura completa V2 do SQLite baseada no pacote sqflite, suportando `sync_queue`, `offline_courses` e `offline_lessons`. Adicionar Hive para cache rápido de sessão/tema. Criar Provider de Status de Fila e mecanismo de WorkManager/Background Fetch para o Android.
- **Objetivo:** Estabelecer a infraestrutura local necessária para modo Offline First, seguindo os eventos de domínio definidos na documentação.
- **Motivação:** Fase 6B Master Plan.
- **Prioridade:** Crítica
- **Status:** ✅ Done (2026-07-11)
- **Complexidade:** XL
- **Dependências:** Fase 6A concluída.
- **Arquivos previstos:** `lawrence/lib/core/offline/*`, `lawrence/pubspec.yaml`, `lawrence/lib/features/sync/*`
- **Documentação obrigatória:** `STATE_AND_OFFLINE_SPEC.md`
- **Workflow obrigatório:** `new-feature`
- **Skills obrigatórias:** `create-page`, `review-code`
- **Personas obrigatórias:** `flutter-architect`
- **Reviews obrigatórios:** `architecture-review`
- **Critérios de aceite:** Flutter pode gravar e enfileirar eventos de domínio no SQLite de forma offline e exibir notificações ou logs no Riverpod.
- **Critérios de conclusão:** Tabelas construídas, injeção de dependência garantida com repositórios locais funcionando.
- **Estimativa:** 4 dias.

#### Task 6B-002
- **Título:** Módulo Backend de Sincronização (`/offline/sync`)
- **Descrição:** Criar o módulo `sync` no FastAPI expondo a rota transacional `POST /api/v1/offline/sync`. A rota deverá receber um array de eventos de domínio, processar as ações via UseCases aplicando "Modified Last-Write-Wins" (especialmente a regra do MAX para progressos).
- **Objetivo:** Backend absorver ações feitas em modo offline e reconciliá-las garantindo zero perda de progresso.
- **Motivação:** Fase 6B Master Plan.
- **Prioridade:** Crítica
- **Status:** ✅ Done (2026-07-11)
- **Complexidade:** L
- **Dependências:** Task 6B-001.
- **Arquivos previstos:** `backend/src/modules/sync/*`
- **Documentação obrigatória:** `SERVICE_API.md`, `STATE_AND_OFFLINE_SPEC.md`
- **Workflow obrigatório:** `new-feature`
- **Skills obrigatórias:** `create-api`
- **Personas obrigatórias:** `backend-architect`, `security-engineer`
- **Reviews obrigatórios:** `architecture-review`, `security-review`
- **Critérios de aceite:** Payload validado e eventos antigos rejeitados se houver versão mais nova já existente na base (idempotência confirmada).
- **Critérios de conclusão:** Testes de unidade em Python garantindo 100% de sucesso nas mesclagens de conflitos.
- **Estimativa:** 3 dias.

### Fase 6C - Lote 1: Certificates e DRM Token

#### Task 6C-A-001
- **Título:** Phase 6C-A - Certificates (Infraestrutura)
- **Descrição:** Implementação do schema de banco de dados para certificados (com document_hash, signature_version e metadata imutável), RLS blindado contra leitura pública indiscriminada, módulos de Backend para geração e validação pública. Integração do Flutter via Riverpod.
- **Objetivo:** Emitir certificados invioláveis, validados por hash, sem vazar dados sensíveis, utilizando idempotência suportada no BD `UNIQUE(student_id, course_id)`.
- **Prioridade:** Alta
- **Status:** Done
- **Complexidade:** M
- **Dependências:** Fase 6B concluída.
- **Documentação obrigatória:** `PHASE_6C_IMPLEMENTATION_PLAN.md`
- **Critérios de aceite:** Testes backend rodando. Idempotência provada na geração (constraint db). O endpoint de verificação pública não retorna `student_id` ou CPF.

#### Task 6C-B-001
- **Título:** Phase 6C-B - Secure Offline Download (DRM)
- **Descrição:** Rota `/offline/download-token` para aquisição de token de uso único (com nonce contra replay), amarrado a usuário e dispositivo. A URL gerada no backend e o JWT devem ser efetivamente consumidos pelo player no app.
- **Objetivo:** Permitir download seguro em HLS no Flutter para acesso offline sem risco de pirataria.
- **Prioridade:** Crítica
- **Status:** PENDING
- **Complexidade:** L
- **Dependências:** Fase 6B concluída.
- **Critérios de aceite:** O Token não pode sofrer replay e deve funcionar integrado no Player do app. Logs da aplicação não devem expor a Signed URL ou JWT completo.

---

### HOTFIX-001 — Estabilização de Execução (Android Físico)

#### Task HOTFIX-001
- **Título:** HOTFIX-001 — Runtime Stabilization (Android Device)
- **Descrição:** Estabilizar a execução em ambiente real de produção do Lawrence Academy no Android físico (BaseUrls, CORS, GoRouter Guards, NaNs, AspectRatio, e Rebuilds).
- **Prioridade:** Crítica
- **Status:** Done
- **Complexidade:** L
- **Dependências:** Nenhuma
- **Critérios de conclusão:** 100% dos testes Dart e Python aprovados, 0 erros no analyze, todos os relatórios gerados.
