# Relatório de Migração de Cursos e Aulas (Courses & Lessons)

Este relatório registra a migração e padronização do bounded context de Courses e Lessons para a arquitetura limpa modular oficial da Lawrence Academy.

---

## 1. Estrutura Antiga vs. Nova

### Antiga
- Entidade: `src/core/entities/course.py` (Acoplada com Pydantic, contendo Course, Module e Lesson).
- Serviço: `src/modules/courses/services/course_service.py` (Métodos assíncronos acoplados a chamadas diretas ao banco Supabase).
- Repositório: `src/modules/courses/repositories/course_repository.py` (Estático, acoplado).
- Rotas Concorrentes/Duplicadas: `/api/courses` e `/courses`.

### Nova
- Entidades de Domínio Puro: `src/modules/courses/domain/entities.py` (Dataclasses python puros para Course, Module e Lesson).
- Repositório Interface (Protocol): `src/modules/courses/domain/repositories.py`.
- Repositório Concreto Supabase: `src/modules/courses/infrastructure/repositories/supabase_course_repository.py`.
- UseCases:
  - `ListCoursesUseCase`
  - `GetCourseUseCase`
  - `GetCourseBySlugUseCase`
  - `CreateCourseUseCase`
  - `UpdateCourseUseCase`
  - `DeleteCourseUseCase`
  - `GetLessonUseCase`
  - `GetLessonStreamUseCase` (Executa controle de acesso seguro).
- Rotas Consolidadas: `/api/v1/courses` em `src/modules/courses/interface/api/routes.py`.
- Rotas Legacy (Redirecionadas):
  - `/api/courses`
  - `/courses`

---

## 2. Arquivos Modificados/Criados

- **[NEW]** [`src/modules/courses/domain/entities.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/courses/domain/entities.py)
- **[NEW]** [`src/modules/courses/domain/repositories.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/courses/domain/repositories.py)
- **[NEW]** [`src/modules/courses/infrastructure/repositories/supabase_course_repository.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/courses/infrastructure/repositories/supabase_course_repository.py)
- **[NEW]** [`src/modules/courses/application/use_cases/get_lesson_stream_use_case.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/courses/application/use_cases/get_lesson_stream_use_case.py)
- **[NEW]** [`src/modules/courses/interface/api/routes.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/courses/interface/api/routes.py)
- **[MODIFY]** [`src/modules/courses/interfaces/routes.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/courses/interfaces/routes.py) (Legacy)
- **[MODIFY]** [`src/modules/courses/api/router.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/courses/api/router.py) (Legacy)
- **[DELETE]** `src/core/entities/course.py`
- **[DELETE]** `src/modules/courses/services/course_service.py`

---

## 3. Segurança e Regras Preservadas

- **Controle de Acesso ao Vídeo HLS:** Alunos são validados contra as regras de pagamento ativo e período de carência (grace period) da assinatura do curso solicitado antes de gerar a URL temporária assinada pelo Supabase Storage.
- **Validação de Papéis (RBAC) e Ownership:** Apenas professores do próprio curso e administradores podem criar, editar e excluir logicamente cursos.

---

## 4. Testes e Validação
1. 100% de cobertura nos testes unitários e de integração existentes.
2. 16 testes passando com sucesso.
