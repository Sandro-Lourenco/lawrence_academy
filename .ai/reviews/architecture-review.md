---
name: architecture-review
description: "Revisão arquitetural validando Clean Architecture, DDD, SOLID, separação de responsabilidades, escalabilidade e manutenção."
type: review
version: 1.0.0
status: production

review_owner:
  - software-architect

required_personas:
  - backend-architect
  - flutter-architect
  - security-engineer
  - qa-engineer

required_documents:
  - AGENTS.md
  - GEMINI.md
  - docs/product/PED-overview.md
  - docs/architecture/SYSTEM_ARCHITECTURE.md
  - docs/database/DATABASE_SCHEMA.md
  - docs/api/SERVICE_API.md
  - docs/security/SECURITY_COMPLIANCE_SPEC.md

related_workflows:
  - new-feature
  - database-change
  - release

related_skills:
  - create-feature
  - create-api
  - create-page
  - review-code
---

# Architecture Review


# 1. Objetivo

Garantir que qualquer implementação siga uma arquitetura profissional, sustentável e escalável.

A revisão deve responder:

```text
Esse código consegue crescer?

As responsabilidades estão separadas?

As regras de negócio estão protegidas?

Existe acoplamento desnecessário?

Um novo desenvolvedor entenderia?
```

Código funcionando não significa arquitetura correta.

---

# 2. Filosofia

A arquitetura deve seguir:

```text
Business First

Domain Driven

Low Coupling

High Cohesion

Testable

Maintainable

Scalable
```

Prioridade:

```text
Regra de negócio

↓

Casos de uso

↓

Infraestrutura

↓

Framework
```

Framework nunca deve controlar o domínio.

---

# 3. Quando executar

Obrigatório após:

```text
Nova feature

Grande refatoração

Novo módulo

Nova API

Novo fluxo crítico

Mudança estrutural
```

Antes de:

```text
Merge

Release

Produção
```

---

# 4. Identificação da revisão

Criar:

```yaml
architecture_review:

 feature:

 module:

 bounded_context:

 affected_layers:

 risk:
   low | medium | high | critical
```

Exemplo:

```yaml
feature:
  Subscription

bounded_context:
  Billing

layers:
 - domain
 - application
 - infrastructure

risk:
 high
```

---

# 5. Estrutura do projeto


Validar organização:


Frontend:

```text
lib/

├── core/

├── design_system/

├── shared/

└── features/

    └── feature_name/

        ├── domain/

        ├── application/

        ├── infrastructure/

        └── presentation/
```


Backend:

```text
src/

├── core/

├── modules/

│   └── module/

│       ├── domain/

│       ├── application/

│       ├── infrastructure/

│       └── interfaces/
```

---

# 6. Separação de camadas


Fluxo permitido:

```text
Presentation

↓

Application

↓

Domain

↑

Infrastructure
```


Proibido:

```text
Controller → Database

Widget → API

UseCase → HTTP

Domain → Framework
```

---

# 7. Domain Review


Validar:

```text
[ ] Entidades representam negócio?

[ ] Nomes fazem sentido?

[ ] Existem invariantes?

[ ] Existem Value Objects?

[ ] Domínio não depende de biblioteca externa?

[ ] Regras importantes não estão espalhadas?
```


Bloquear:


```text
Entidade anêmica demais

Regra somente no frontend

Regra dentro do Controller
```

---

# 8. Use Cases


Cada caso de uso deve:

```text
Ter uma intenção clara

Representar ação real

Ser testável

Ser pequeno
```


Exemplos bons:

```text
CreateCourse

SubscribeStudent

GenerateCertificate
```


Ruins:

```text
CourseService

UserHelper

Manager
```

---

# 9. SOLID Review


## Single Responsibility


Perguntar:

```text
Essa classe tem apenas um motivo para mudar?
```


Bloquear:

```text
Classe Deus

Arquivo gigante
```

---

## Open Closed


Validar:

```text
Novos comportamentos entram sem quebrar antigos
```

---

## Dependency Inversion


Correto:

```text
UseCase

↓

Repository Interface

↓

Repository Implementation
```


Errado:


```text
UseCase

↓

Prisma/Supabase/Dio direto
```

---

# 10. Dependency Direction


Regra:

```text
Camadas internas nunca conhecem externas.
```


Domain não conhece:

```text
Flutter

FastAPI

Database

HTTP

Firebase

Supabase
```

---

# 11. Backend Review


Validar:

```text
Controllers pequenos

DTO separado

Validação entrada

UseCases isolados

Repositories abstraídos

Erros tratados
```


Controller deve:

```text
Receber

Validar

Chamar UseCase

Responder
```


Nunca:

```text
Processar regra de negócio
```

---

# 12. API Architecture


Validar:

```text
REST correto

Versionamento

DTO

Paginação

Erros padronizados

Autorização
```


Exemplo:

Correto:

```http
GET /courses/{id}/lessons
```


Evitar:

```http
GET /getLessons
```

---

# 13. Flutter Architecture


Validar:

```text
Widget

↓

Controller / Notifier

↓

UseCase

↓

Repository
```


Widget não pode:

```text
Chamar API

Salvar banco

Calcular regra

Controlar pagamento
```

---

# 14. State Management


Riverpod:


Validar:

```text
Providers organizados

Estado imutável

AsyncValue usado corretamente

Dispose correto

Poucos rebuilds
```


Bloquear:

```text
Estado global desnecessário

Provider gigante
```

---

# 15. Models e DTOs


Separar:


```text
Entity

DTO

ViewModel
```


Não usar:


```text
Objeto do banco na UI
```

---

# 16. Banco de Dados


Validar:


```text
Modelagem segue domínio

Relacionamentos corretos

Índices

Constraints

Migrations
```


Banco não deve corrigir arquitetura ruim.

---

# 17. Segurança arquitetural


Validar:

```text
Autorização centralizada

Permissões consistentes

Dados isolados

Segredos protegidos
```


Nunca:

```text
Verificar admin somente na UI
```

---

# 18. Testabilidade


Arquitetura boa permite:


```text
Mock Repository

Testar UseCase

Testar domínio isolado
```


Se precisa subir app inteiro:

problema arquitetural.

---

# 19. Acoplamento


Identificar:


Ruim:

```text
Módulo A conhece detalhes do módulo B
```


Melhor:

```text
Eventos

Interfaces

Contratos
```

---

# 20. Complexidade


Avaliar:


```text
Arquivo > 500 linhas

Função > 50 linhas

Classe com muitas responsabilidades
```


Não é regra absoluta.

É alerta.

---

# 21. Nomenclatura


Nomes devem explicar negócio.


Bom:

```text
SubscriptionExpired

CalculateProgress

ApproveCourse
```


Ruim:

```text
Helper

Utils

Manager

Processor
```

---

# 22. Performance estrutural


Validar:


```text
Paginação

Cache

Lazy Loading

Queries eficientes

Processamento assíncrono
```

---

# 23. Documentação


Toda decisão importante:


Registrar:

```text
Architecture Decision Record
```


Formato:


```text
Problema

Decisão

Motivo

Consequência
```

---

# 24. Resultado esperado


Sempre responder:


```markdown
# Architecture Review Result


## Status

APPROVED

NEEDS_CHANGES

BLOCKED


## Pontos fortes


## Problemas


### Critical


### Major


### Minor


## Recomendações


## Riscos futuros
```

---

# 25. Bloqueadores


Nunca aprovar:


```text
❌ Regra no Controller

❌ Regra no Widget

❌ Banco direto na UI

❌ Domínio dependente de framework

❌ Sem testes possíveis

❌ Acoplamento alto

❌ Duplicação estrutural

❌ Segurança espalhada

❌ Código impossível de evoluir
```

---

# Checklist final


```text
DOMAIN

[ ] Entidades corretas

[ ] Regras protegidas


APPLICATION

[ ] UseCases claros


INFRA

[ ] Isolada


FRONTEND

[ ] UI sem regra


BACKEND

[ ] API limpa


QUALITY

[ ] Testável

[ ] Escalável

[ ] Manutenível
```

---

# Regra final


Arquitetura boa permite trocar:

```text
Banco

Framework

Interface

Biblioteca
```


sem perder:

```text
Regra de negócio
```

O domínio é o coração.

Todo o resto é detalhe.