# BACKEND_LEGACY_REMOVAL_PLAN.md

**Versão:** 1.0.0  
**Data:** 2026-07-10  
**Branch:** `refactor/monorepo-cleanup`  
**Status:** APROVADO — rotas legacy mantidas temporariamente para compatibilidade

---

## Objetivo

Documentar o plano de remoção controlada das rotas e arquivos legacy do backend,
garantindo que nenhum consumidor ativo seja quebrado durante a transição.

---

## Critérios para Remoção de uma Rota Legacy

Uma rota legacy pode ser removida **somente quando**:

1. A rota v1 correspondente está **100% funcional e testada**
2. O cliente Flutter **não possui chamadas ativas** para a rota legacy
3. O Flutter foi atualizado para usar a rota v1
4. Os testes E2E passam com as novas rotas
5. Um PR de remoção foi revisado e aprovado

---

## Mapa de Rotas Legacy → v1

### Profiles

| Rota Legacy | Rota v1 | Consumidor | Status |
|---|---|---|---|
| `GET /api/profiles/me` | `GET /api/v1/profiles/me` | Flutter: `ProfileRepository` | ⏳ Aguardando Flutter |
| `GET /students/me` | `GET /api/v1/profiles/me` | Flutter: `StudentRepository` | ⏳ Aguardando Flutter |
| `PUT /api/profiles/me` | `PUT /api/v1/profiles/me/update` | Flutter: `ProfileRepository` | ⏳ Aguardando Flutter |

### Courses

| Rota Legacy | Rota v1 | Consumidor | Status |
|---|---|---|---|
| `GET /courses` | `GET /api/v1/courses/` | Flutter: `CourseRepository` | ⏳ Aguardando Flutter |
| `GET /api/courses` | `GET /api/v1/courses/` | Flutter: `CourseRepository` | ⏳ Aguardando Flutter |
| `GET /api/courses/{id}` | `GET /api/v1/courses/{id}` | Flutter: `CourseRepository` | ⏳ Aguardando Flutter |
| `GET /api/courses/slug/{slug}` | `GET /api/v1/courses/slug/{slug}` | Flutter | ⏳ Aguardando Flutter |
| `GET /api/courses/{id}/lessons/{lid}` | `GET /api/v1/courses/{id}/lessons/{lid}` | Flutter | ⏳ Aguardando Flutter |
| `GET /api/courses/{id}/lessons/{lid}/stream` | `GET /api/v1/courses/{id}/lessons/{lid}/stream` | Flutter: VideoPlayer | ⏳ Aguardando Flutter |

### Assessments

| Rota Legacy | Rota v1 | Consumidor | Status |
|---|---|---|---|
| `POST /api/task_submissions` | `POST /api/v1/assessments/submissions` | Flutter: `AssessmentRepository` | ⏳ Aguardando Flutter |
| `PUT /api/teacher/submissions/{id}/review` | `PUT /api/v1/assessments/submissions/{id}/review` | Flutter: Teacher dashboard | ⏳ Aguardando Flutter |

### Payments

| Rota Legacy | Rota v1 | Consumidor | Status |
|---|---|---|---|
| `POST /api/checkout/session` | `POST /api/v1/payments/checkout` | Flutter: `PaymentRepository` | ⏳ Aguardando Flutter |
| `POST /webhooks/stripe` | `POST /api/v1/payments/webhook` | Stripe Dashboard config | ⚠️ Requer atualização manual no Stripe Dashboard |

---

## Arquivos Legacy Ainda Presentes

Os seguintes arquivos existem para manter a compatibilidade retroativa e
**devem ser removidos** após confirmação de que nenhum consumidor os usa:

### Routers Legacy (re-direcionam para UseCases v1)
- `src/modules/profiles/interfaces/routes.py`
- `src/modules/courses/interfaces/routes.py`
- `src/modules/courses/api/router.py`
- `src/modules/assessments/interfaces/routes.py`
- `src/modules/payments/interfaces/routes.py`
- `src/modules/students/api/router.py`

### Services Legacy (ainda usados por routers legacy)
- `src/modules/students/services/student_service.py`
- `src/modules/profiles/repositories/profile_repository.py`

### Arquivo para deprecar após Fase 5
- `src/modules/subscriptions/application/use_cases/create_checkout_use_case.py`
  _(substituído por `ValidateCheckoutEligibilityUseCase` no contexto Payments)_

---

## Cronograma de Remoção

| Fase | Ação | Pré-requisito |
|---|---|---|
| **Fase 5** | Atualizar Flutter para usar rotas `/api/v1/*` | Refatoração Flutter completa |
| **Fase 5** | Remover routers legacy após confirmação | Testes E2E passando |
| **Fase 5** | Atualizar Stripe Dashboard: webhook URL | Acesso ao Stripe Dashboard |
| **Pós Fase 5** | Remover `student_service.py` e `profile_repository.py` legacy | Flutter migrado |
| **Pós Fase 5** | Remover `create_checkout_use_case.py` (subscriptions context) | Validado em produção |

---

## Regra: Nenhuma Rota Legacy Será Removida Sem

1. Confirmação via `grep` de que o Flutter não usa a rota
2. Teste automatizado verificando que o Flutter usa a rota v1
3. PR revisado por pelo menos 1 engenheiro
4. Deploy em staging validado
