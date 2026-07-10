# Relatório de Migração de Avaliações (Assessments)

Este relatório registra a migração e padronização do bounded context de Avaliações (Assessments) para a arquitetura limpa modular oficial da Lawrence Academy.

---

## 1. Estrutura Antiga vs. Nova

### Antiga
- Entidade: `src/core/entities/task_submission.py` (Acoplada com Pydantic).
- Repositório: `src/modules/assessments/repositories/task_repository.py` (Métodos estáticos e database client global).
- UseCases: `src/modules/assessments/application/submit_task.py` e `src/modules/assessments/application/grade_submission.py` (Métodos estáticos).
- Rotas Legadas: `/api/task_submissions` e `/api/teacher/submissions/{id}/review`.

### Nova
- Entidade: `src/modules/assessments/domain/entities.py` (Domínio puro, dataclass python).
- Repositório Interface (Protocol): `src/modules/assessments/domain/repositories.py`.
- Repositório Concreto Supabase: `src/modules/assessments/infrastructure/repositories/supabase_assessment_repository.py`.
- UseCases:
  - `SubmitTaskUseCase` em `src/modules/assessments/application/use_cases/submit_task_use_case.py`.
  - `GradeSubmissionUseCase` em `src/modules/assessments/application/use_cases/grade_submission_use_case.py`.
- Rotas Consolidadas: `/api/v1/assessments/submissions` em `src/modules/assessments/interface/api/routes.py`.
- Rotas Legacy (Redirecionadas para compatibilidade): `/api/task_submissions` e `/api/teacher/submissions/{id}/review`.

---

## 2. Arquivos Modificados/Criados

- **[NEW]** [`src/modules/assessments/domain/entities.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/assessments/domain/entities.py)
- **[NEW]** [`src/modules/assessments/domain/repositories.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/assessments/domain/repositories.py)
- **[NEW]** [`src/modules/assessments/infrastructure/repositories/supabase_assessment_repository.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/assessments/infrastructure/repositories/supabase_assessment_repository.py)
- **[NEW]** [`src/modules/assessments/application/use_cases/submit_task_use_case.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/assessments/application/use_cases/submit_task_use_case.py)
- **[NEW]** [`src/modules/assessments/application/use_cases/grade_submission_use_case.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/assessments/application/use_cases/grade_submission_use_case.py)
- **[NEW]** [`src/modules/assessments/interface/api/routes.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/assessments/interface/api/routes.py)
- **[MODIFY]** [`src/modules/assessments/interfaces/routes.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/assessments/interfaces/routes.py) (Legacy)
- **[DELETE]** `src/core/entities/task_submission.py`
- **[DELETE]** `src/modules/assessments/repositories/task_repository.py`

---

## 3. Segurança e Regras Preservadas

- **Validação de Papéis (RBAC):** Correções e feedback de tarefas discursivas são estritamente restritos a papéis `teacher` ou `admin`.
- **Prevenção contra Broken Access Control (BOLA):** O `user_id` é injetado diretamente a partir do `CurrentUser` autenticado extraído do token JWT, impedindo qualquer injeção maliciosa de outro usuário na submissão de exercícios.

---

## 4. Testes e Validação
1. Executado `python -m pytest -q` para validação do suite.
2. 100% de sucesso (16 testes válidos passando).
