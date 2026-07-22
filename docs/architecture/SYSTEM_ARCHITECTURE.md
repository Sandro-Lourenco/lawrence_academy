---
version: 2.0.0
name: Lawrence-Academy-System-Architecture
type: Software Architecture & Repository Structure Specification

status: Production Ready

phase_2_note: Dashboard metrics are derived from UseCase state; Widgets do not access Supabase directly. A future RLS-protected read model may aggregate these reads.

platforms:
  - Flutter Web
  - Flutter Android

backend:
  framework: FastAPI
  language: Python

database:
  provider: Supabase
  engine: PostgreSQL

architecture:
  - Clean Architecture
  - Domain Driven Design
  - Feature First
  - Modular Monolith
  - Event Driven Workers

state:
  provider: Riverpod

rules:
  - Dependency Rule
  - Separation Of Concerns
  - SOLID
  - Testable Code
---

# Lawrence Academy
# System Architecture Specification


# 1. Objetivo

Este documento define:

- organização de pastas
- padrões de código
- limites entre módulos
- regras de dependência
- comunicação entre camadas


Ele é a fonte de verdade para:

- Desenvolvedores
- IA geradora de código
- Revisões


---

# 2. Repository Architecture


O projeto usa:

Monorepo


Estrutura:


```text
lawrence-academy/


├── apps/


│   ├── mobile/
│   │
│   │   Flutter Android
│   │
│   └── web/
│
│       Flutter Web


│
├── backend/


│   └── api/
│
│       FastAPI


│
├── workers/


│   ├── video-worker/
│   │
│   │   FFmpeg + HLS
│   │
│   ├── ai-worker/
│   │
│   │   AI Processing
│   │
│   └── notification-worker/


│
├── packages/


│   ├── design-system/
│   │
│   └── shared/


│
├── database/


│   └── migrations/


│
├── infrastructure/


│   ├── docker/
│   ├── github-actions/
│   └── scripts/


│
├── docs/


└── README.md

```

---

# 3. Dependency Rule


Regra principal:


Dependências sempre apontam para dentro.


```text


Presentation


      ↓


Application


      ↓


Domain


      ↑


Infrastructure


```


---

# DOMAIN


Camada mais importante.


Não conhece:


Flutter

Supabase

HTTP

SQLite


---

Permitido:


Entidades


Value Objects


Interfaces


Regras puras


---

# APPLICATION


Orquestra casos de uso.


Conhece:


Domain


Não conhece:


Banco

API externa

UI


---

# INFRASTRUCTURE


Implementa tecnologia.


Conhece:


Supabase


SQLite


HTTP


Storage


---

# PRESENTATION


Responsável:


Widgets


Pages


Controllers Riverpod


---

# 4. Flutter Folder Architecture


Cada módulo é uma Feature.


Estrutura:


```text

lib/


├── main.dart


├── app/


│   ├── app.dart
│   ├── router.dart
│   └── bootstrap.dart


├── core/


│   ├── config/


│   ├── constants/


│   ├── errors/


│   ├── network/


│   ├── security/


│   └── utils/


├── shared/


│   ├── widgets/


│   ├── extensions/


│   └── helpers/


├── design_system/


│   ├── colors/


│   ├── typography/


│   ├── spacing/


│   └── components/


└── features/


```


---

# 5. Feature Structure Pattern


Toda feature segue:


```text

feature_name/


├── presentation/


│   ├── pages/


│   ├── widgets/


│   ├── controllers/


│   └── states/


│

├── application/


│   └── usecases/


│

├── domain/


│   ├── entities/


│   ├── value_objects/


│   └── repositories/


│

└── data/


    ├── models/


    ├── repositories/


    └── datasources/

```


---

Exemplo:


Course Feature


```text

features/


course/


├── domain/


│   ├── entities/


│   │   course.dart


│   └── repositories/


│       course_repository.dart


│
├── application/


│   └── usecases/


│       get_courses.dart


│
├── data/


│   ├── models/


│   │   course_model.dart


│   ├── datasources/


│   │   course_remote.dart


│   │   course_local.dart


│   └── repositories/


│       course_repository_impl.dart


│
└── presentation/


    ├── pages/


    │   course_page.dart


    └── controllers/


        course_controller.dart

```

---

# 6. Flutter Features


```text

features/


auth/


users/


courses/


lessons/


player/


downloads/


payments/


subscriptions/


certificates/


notifications/


search/


teacher/


admin/


ai/


settings/

```

---

# 7. Backend Architecture FastAPI


Estrutura:


```text

backend/api/


src/


├── main.py


├── core/


│   ├── config.py


│   ├── security.py


│   ├── database.py


│   └── exceptions.py


├── modules/


│
│   ├── auth/


│   ├── courses/


│   ├── lessons/


│   ├── payments/


│   └── users/


│

├── shared/


└── tests/

```

---

# 8. Backend Module Pattern


Cada módulo:


```text

courses/


├── domain/


│   ├── entities.py


│   └── repository.py


├── application/


│   └── usecases/


├── infrastructure/


│   ├── repository_impl.py


│   └── datasource.py


├── interface/


│   ├── routes.py


│   └── schemas.py


└── tests/

```

---

# 9. Workers Architecture


Nunca colocar processamento pesado na API.


---

Estrutura:


```text

workers/


video-worker/


├── processors/


├── ffmpeg/


├── queue/


└── main.py


ai-worker/


├── prompts/


├── models/


├── queue/


└── main.py

```


---

Fluxo:


```text

API


↓

Queue


↓

Worker


↓

Database Event

```

---

# 10. Database Structure


```text

database/


├── migrations/


│
├── seeds/


│
├── policies/


│
└── triggers/

```

---

# 11. Tests Structure


Flutter:


```text

test/


├── unit/


├── widget/


└── integration/

```


---

Backend:


```text

tests/


├── unit/


├── integration/


└── api/

```

---

# 12. Naming Rules


Classes:


PascalCase


Ex:


CourseRepository


---


Arquivos:


snake_case


Ex:


course_repository.dart


---


UseCases:


Verbo + Caso


Ex:


CreateCourseUseCase


---

Controllers:


FeatureController


Ex:


CourseController


---

# 13. Import Rules


PROIBIDO:


Presentation importar Data.


Ex:


ERRADO:


Page

↓

RepositoryImpl


---

CORRETO:


Page

↓

Controller

↓

UseCase

↓

Repository Interface


---

# 14. AI Coding Rules


Toda IA deve seguir:


Nunca criar lógica dentro da tela.


Nunca acessar Supabase direto no Widget.


Nunca misturar Feature.


Nunca criar pasta genérica:


services/


helpers/


managers/


sem motivo.


---

# 15. Security Architecture


Todas camadas validam:


JWT


RBAC


RLS


---

Frontend:


UX Guard


---

Backend:


Security Guard


---

Database:


Final Authority


---

# 16. Documentation Mapping


Cada camada segue:


Produto:


PED-overview.md


---


Interface:


PAGES_SPEC


DESIGN_SYSTEM


---


Dados:


DATABASE_SCHEMA


---


API:


SERVICE_API


---

Domain contém regra.


Application contém fluxo.


Infrastructure contém tecnologia.


Presentation contém interface.


Nenhuma exceção.

---

# 17. Video Processing Worker Architecture

O processamento de arquivos de vídeo pesados da Lawrence Academy é executado de forma assíncrona off-main-thread por um worker desacoplado.

## Pipeline Flow
1. **Intenção (FastAPI):** O professor gera URL de upload, inserindo um job em `video_processing_jobs` como `upload_pending`.
2. **Upload (Storage Trigger):** O arquivo é enviado diretamente ao bucket privado `raw-videos`. A trigger PostgreSQL atualiza o job para `uploaded`.
3. **Loop do Worker (Polling):** O worker em background detecta o job `uploaded` e o move para `validating`.
4. **Validação (ffprobe):** Valida arquivo real e codec de vídeo (deve ser suportado pelo HLS) e compara tamanhos. Rejeita falhas.
5. **Conversão (ffmpeg):** Transcodifica para HLS multi-bitrate (`480p`, `720p`, `1080p`), gera manifestos `.m3u8` e poster/thumbnail.
6. **Upload & Ativação:** Envia os arquivos de saída HLS de forma isolada (`lessons/{lesson_id}/{job_id}/`). Ativa a versão candidata na tabela `lessons` de forma atômica no banco ao final.

