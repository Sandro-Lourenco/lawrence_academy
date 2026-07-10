# Plano de Refatoração e Padronização do Backend (Fase 4)

Este documento define o plano detalhado para reorganizar e padronizar o backend FastAPI de acordo com os princípios de Clean Architecture, Domain-Driven Design (DDD) e Monolito Modular.

---

## 1. Auditoria e Estrutura Atual

### 1.1. Estrutura Backend Atual
O backend atualmente possui duas estruturas arquiteturais paralelas coexistindo no diretório `src/`:
- Uma estrutura baseada em **UseCases e Clean Architecture** (com diretórios `application/`, `interfaces/`, `repositories/` em alguns módulos).
- Uma estrutura baseada em **Service Pattern** e acoplamento direto de rotas/serviços que retornam dicionários brutos (ex: nos módulos `students` e `courses/api/router.py`).

### 1.2. Módulos Existentes
- `auth`: Autenticação e validação de tokens JWT (apenas dependências FastAPI e serviço interno).
- `profiles`: Cadastro e recuperação de dados de perfis (UseCases).
- `students`: Duplicidade funcional de perfis de estudantes (Service).
- `courses`: Catálogo de cursos, módulos, lições e streaming (dividido entre UseCases e ad-hoc Service).
- `assessments`: Submissão de tarefas e avaliação de notas (UseCases).
- `payments`: Criação de sessões de checkout e webhooks do Stripe (UseCases / ad-hoc).

### 1.3. Rotas Existentes
- `profiles_router`: `GET /api/profiles/me`, `PUT /api/profiles/me`
- `new_students_router`: `GET /students/me`, `PUT /students/me` (Duplicada!)
- `courses_router`: `GET /api/courses`, `GET /api/courses/slug/{slug}`, `GET /api/courses/{course_id}`, `POST /api/courses`, `PUT /api/courses/{course_id}`, `DELETE /api/courses/{course_id}`
- `new_courses_router`: `GET /courses`, `GET /courses/{id}/lessons/{lesson_id}`, `GET /courses/{id}/lessons/{lesson_id}/stream` (Duplicada!)
- `payments_router`: `POST /api/checkout/session`, `POST /webhooks/stripe`
- `assessments_router`: `POST /api/task_submissions`, `PUT /api/teacher/submissions/{submission_id}/review`

### 1.4. Rotas Duplicadas e Mapa de Consolidação
Mapeamos e unificaremos as rotas sob o prefixo global `/api/v1` em `BACKEND_ROUTE_MIGRATION_MAP.md`:

| Rota Antiga | Rota Nova (/api/v1) | Descrição | Status/Observações |
|---|---|---|---|
| `/api/profiles/me` & `/students/me` | `GET /api/v1/profiles/me` | Recupera perfil do usuário logado | Unificar em `profiles` |
| `/api/profiles/me` & `/students/me` | `PUT /api/v1/profiles/me` | Atualiza perfil do usuário logado | Unificar em `profiles` |
| `/api/courses` & `/courses` | `GET /api/v1/courses` | Listagem de cursos | Unificar em `courses` |
| `/api/courses/{course_id}` | `GET /api/v1/courses/{course_id}` | Detalhes de um curso | Unificar em `courses` |
| `/api/courses/slug/{slug}` | `GET /api/v1/courses/slug/{slug}` | Detalhes do curso por slug | Unificar em `courses` |
| `/courses/{id}/lessons/{lesson_id}` | `GET /api/v1/courses/{course_id}/lessons/{lesson_id}` | Detalhes da lição | Unificar em `courses` |
| `/courses/{id}/lessons/{lesson_id}/stream` | `GET /api/v1/courses/{course_id}/lessons/{lesson_id}/stream` | Stream assinado HLS | Unificar em `courses` |
| `/api/checkout/session` | `POST /api/v1/payments/checkout` | Criar sessão do Stripe | Unificar em `payments` |
| `/webhooks/stripe` | `POST /api/v1/payments/webhook` | Receber webhooks do Stripe | Unificar em `payments` |
| `/api/task_submissions` | `POST /api/v1/assessments/submissions` | Submeter resposta de tarefa | Unificar em `assessments` |
| `/api/teacher/submissions/{id}/review` | `PUT /api/v1/assessments/submissions/{id}/review` | Corrigir tarefa discursiva | Unificar em `assessments` |

### 1.5. Classes e Responsabilidades Atuais
- **Services Existentes:**
  - `CourseService` (ad-hoc): Métodos assíncronos que chamam o Supabase diretamente.
  - `StudentService` (ad-hoc): Métodos assíncronos para perfil de estudante.
- **UseCases Existentes:**
  - `ListCoursesUseCase`, `GetCourseUseCase`, `CreateCourseUseCase`, `UpdateCourseUseCase`, `DeleteCourseUseCase`.
  - `GetMyProfileUseCase`, `UpdateMyProfileUseCase`.
  - `SubmitTaskUseCase`, `GradeSubmissionUseCase`.
- **Repositories Existentes:**
  - Atualmente os repositórios em `courses/repositories` e `profiles/repositories` contêm chamadas diretas ao cliente administrativo `database.db`. Não existem interfaces formais (Protocols) em domain.

---

## 2. Estrutura de Destino e Regra de Dependências

Adotaremos a estrutura modular estrita baseada em Clean Architecture:

```
backend/src/
├── main.py (Ponto de entrada unificado)
│
├── core/ (Preocupações transversais de infra)
│   ├── config/ (Definições de settings e env)
│   ├── database/ (Inicialização dos clients Supabase)
│   ├── security/ (Validação e extração de JWT e Roles)
│   ├── errors/ (Exceções globais e exception handlers)
│   ├── observability/ (Logging estruturado e Request ID)
│   └── middleware/ (CORS e rate limiting)
│
└── modules/
    └── <context>/ (ex: courses, profiles, subscriptions, payments, assessments)
        ├── domain/ (100% puro, sem frameworks)
        │   ├── entities.py
        │   ├── value_objects.py
        │   ├── exceptions.py
        │   └── repositories.py (Protocols/Interfaces)
        │
        ├── application/ (Regras aplicacionais, UseCases)
        │   ├── use_cases/
        │   ├── dto/
        │   └── services/
        │
        ├── infrastructure/ (Implementações de persistência/APIs externas)
        │   ├── repositories/
        │   └── mappers/
        │
        └── interface/ (FastAPI Routers, Schemas, Dependencies)
            └── api/
                ├── routes.py
                ├── schemas.py
                └── dependencies.py
```

### 2.1. Desacoplamento de Core
As entidades de domínio que estavam alocadas incorretamente em `src/core/entities/` serão migradas para a camada `domain/` dos seus respectivos bounded contexts:
- `course.py` -> `modules/courses/domain/entities.py`
- `profile.py` -> `modules/profiles/domain/entities.py`
- `subscription.py` -> `modules/subscriptions/domain/entities.py`
- `task_submission.py` -> `modules/assessments/domain/entities.py`

### 2.2. Regra de Dependência
- A camada **Domain** é pura. Ela não pode importar FastAPI, Pydantic, Supabase, Stripe, etc.
- A camada **Application** define as intenções por meio de UseCases e DTOs, consumindo Repositórios por meio de interfaces (Protocols) do domínio. Ela não acessa Supabase client diretamente.
- A camada **Infrastructure** implementa as interfaces do repositório consumindo os clientes do Supabase (`get_admin_supabase_client()` ou `get_authenticated_supabase_client()`).
- A camada **Interface** (routers FastAPI) é fina, contendo apenas validação de schemas Pydantic de entrada/saída e chamada ao UseCase correspondente.

---

## 3. Ordem de Migração por Módulo

Migraremos sequencialmente para garantir que cada etapa seja pequena, testável e sem quebra de comportamento:

1. **Fase 4.1: Core e Configuração**
   - Padronizar exceções globais (`DomainException`, `NotFoundError`, etc.) em `core/errors/` com exception handlers.
   - Centralizar validações de segurança e parsing de JWT in `core/security/` injetando `CurrentUser` via dependência.
   - Configuração de CORS por ambiente em `core/middleware/`.
2. **Fase 4.2: Auth & Profiles**
   - Consolidar as rotas de `/students/me` e `/api/profiles/me` em `GET/PUT /api/v1/profiles/me`.
   - Criar `profiles/domain/repositories.py` (Protocol) e `SupabaseProfileRepository` na infraestrutura.
3. **Fase 4.3: Courses & Lessons**
   - Unificar `/courses` e `/api/courses` em `/api/v1/courses`.
   - Criar `lessons` como subcontexto/módulo ou associado ao módulo `courses`.
   - Implementar `GetLessonStreamUseCase` consumindo a assinatura e validando o grace period via repositórios do domínio.
4. **Fase 4.4: Assessments**
   - Unificar submissão de tarefas e correções em `/api/v1/assessments/submissions`.
5. **Fase 4.5: Subscriptions & Payments**
   - Separar definitivamente a tabela de assinaturas da lógica de checkout e webhooks.
   - Implementar proteção idempotente de webhooks através do `ProcessPaymentWebhookUseCase` registrando em `payment_events`.
   - Utilizar Unit of Work/Transações para criação e cancelamento de assinaturas.

---

## 4. Testes de Caracterização e Critérios de Aceitação

### 4.1. Testes de Caracterização (Antes de Alterar)
Para cada módulo, criaremos um teste em `backend/tests/` (ex: `test_courses_api_legacy.py`) cobrindo requests válidos e inválidos para garantir que o comportamento da API legada seja idêntico ao da nova arquitetura.

### 4.2. Critérios de Aceitação por Módulo
- 100% dos testes unitários e de API passando.
- Linter `ruff check .` e formatador `ruff format --check .` sem erros.
- Análise estática `mypy src` sem violações de tipo em arquivos alterados.
- Nenhuma chamada direta ao Supabase client dentro de UseCases.
- Service role usada exclusivamente nas operações autorizadas da Fase 3.
- Relatório de migração individual registrado na pasta `docs/refactor/backend/`.

---

## 5. Plano de Rollback por Módulo

Caso um módulo apresente instabilidade na migração:
1. **Rollback de Código:** O Git permite reverter commits atômicos do módulo mantendo a branch atual estável.
2. **Rollback de Rotas:** O arquivo `backend/src/main.py` pode temporariamente montar o router legado (ex: `app.include_router(legacy_courses_router)`) redirecionando o tráfego enquanto corrigimos o código.
3. **Rollback de Banco:** Caso ocorra alguma alteração DDL adicional, o script correspondente de rollback em `docs/archive/database/` será aplicado.
