---
name: new-feature
description: "Workflow completo para criar uma nova funcionalidade seguindo produto, arquitetura, backend, frontend, testes e revisão.
type: workflow
version: 1.0.0
status: production

required_personas:
  - backend-architect
  - flutter-architect
  - ui-ux-designer
  - qa-engineer
  - security-engineer

required_skills:
  - create-feature
  - create-api
  - create-page
  - optimize-performance
  - review-code
---

# Workflow: New Feature


# 1. Objetivo

Este workflow define a sequência obrigatória para criar uma nova funcionalidade completa.

Uma feature nunca deve começar pelo código.

A ordem correta é:

```text
Produto

↓

Arquitetura

↓

Banco

↓

Backend

↓

API

↓

Frontend

↓

Testes

↓

Performance

↓

Review
```

---

# 2. Quando usar

Usar quando solicitado:

```text
Criar módulo

Criar funcionalidade

Adicionar recurso

Implementar fluxo completo

Criar CRUD

Adicionar regra de negócio
```

Exemplos:

```text
Criar sistema de certificados

Criar assinatura de curso

Criar comentários nas aulas

Criar módulo financeiro

Criar notificações
```

---

# 3. Documentos obrigatórios

Antes de iniciar:

Ler:

```text
AGENTS.md

GEMINI.md

docs/product/PED-overview.md

docs/architecture/SYSTEM_ARCHITECTURE.md

docs/database/DATABASE_SCHEMA.md

docs/api/SERVICE_API.md

docs/security/SECURITY_COMPLIANCE_SPEC.md

docs/navigation/PAGES_OVERVIEW.md

docs/design/UI_UX_FRONTEND_SPEC.md

docs/design/DESIGN_SYSTEM.md

docs/pages/
```

Nunca implementar sem consultar documentação.

---

# 4. Fase 1 — Entender requisito

Antes de criar arquivos:

Responder:

```text
Qual problema resolve?

Quem usa?

Qual persona?

Qual regra de negócio?

Qual fluxo?

Qual permissão?

Tem pagamento?

Tem dados sensíveis?

Tem offline?

Tem IA?
```

Gerar:

```yaml
feature:
  name:

  user:

  objective:

  business_rules:

  permissions:

  risks:
```

---

# 5. Fase 2 — Definir domínio


Identificar:

```text
Bounded Context

Entidades

Value Objects

Agregados

Eventos

Casos de uso
```

Exemplo:

Feature:

```text
Certificados
```


Domínio:

```text
certificate
```

Estrutura:

```text
features/

└── certificate/

    ├── domain

    ├── application

    ├── infrastructure

    └── presentation
```

---

# 6. Fase 3 — Banco de Dados


Antes de criar tabela:

Verificar:

```text
DATABASE_SCHEMA.md
```


Definir:

```text
Tabelas

Relacionamentos

Constraints

Índices

RLS

Auditoria
```


Obrigatório:

```text
UUID

created_at

updated_at
```


Dados sensíveis:

exigem:

```text
Security Review
```

---

# 7. Fase 4 — Backend


Executar skill:

```text
@create-api
```


Criar:


```text
Domain

UseCases

DTOs

Repositories

Routes

Tests
```


Fluxo obrigatório:

```text
Controller

↓

UseCase

↓

Repository

↓

Database
```


Proibido:


```text
Controller → Banco
```

---

# 8. Fase 5 — API


Definir:

```text
Endpoint

Request

Response

Errors

Permissions
```


Atualizar:

```text
docs/api/SERVICE_API.md
```


Exemplo:


```http
POST /api/certificates
```


Contrato:


```json
{
"id":"uuid",
"status":"generated"
}
```

---

# 9. Fase 6 — Frontend Flutter


Executar:

```text
@create-page
```


Antes:


Consultar:

```text
docs/pages/
```


Criar:


```text
Page

Widgets

Controller

State

Provider
```


Fluxo:


```text
Widget

↓

Riverpod

↓

UseCase

↓

Repository
```

---

# 10. Fase 7 — UI/UX


Executar:

```text
@create-premium-flutter-screen
```


Validar:


```text
Design System

Componentes

Responsividade

Acessibilidade

Motion

Estados
```


Estados obrigatórios:


```text
Loading

Success

Empty

Error

Offline
```

---

# 11. Fase 8 — Segurança


Executar:

```text
@security-engineer
```


Validar:


```text
Auth

Permission

Ownership

Input

Upload

Payments

Secrets
```


Bloquear:


```text
Dados sem autorização

Service key exposta

Endpoint público indevido
```

---

# 12. Fase 9 — Testes


Executar:

```text
@qa-engineer
```


Criar:


Backend:

```text
Unit Tests

Integration Tests

API Tests
```


Flutter:


```text
Widget Tests

Golden Tests

Flow Tests
```


Testar:


```text
Happy Path

Error

Permission

Offline

Edge Cases
```

---

# 13. Fase 10 — Performance


Executar:

```text
@optimize-performance
```


Validar:


Flutter:


```text
Rebuilds

FPS

Images

Memory
```


Backend:


```text
Queries

Cache

Indexes

Payload
```

---

# 14. Fase 11 — Revisão final


Executar:


```text
@review-code
```


Critérios:


```text
Arquitetura OK

Testes OK

Segurança OK

Performance OK

Documentação OK
```


Resultado:


```text
APPROVE

ou

REQUEST_CHANGES

ou

BLOCK
```

---

# 15. Checklist final


Antes de finalizar:


```text
PRODUTO

[ ] Resolve requisito?

[ ] Está no PED?


BANCO

[ ] Migration?

[ ] Índices?

[ ] Segurança?


BACKEND

[ ] UseCase?

[ ] Testes?


API

[ ] Contrato atualizado?


FRONTEND

[ ] Page Spec seguida?

[ ] Design System?


UX

[ ] Estados completos?

[ ] Acessível?


QUALIDADE

[ ] Testes passando?

[ ] Review aprovado?
```

---

# 16. Nunca fazer


Proibido:


```text
❌ Começar criando tela

❌ Criar endpoint sem regra

❌ Criar tabela sem domínio

❌ Ignorar documentação

❌ Duplicar componente

❌ Misturar camadas

❌ Ignorar segurança

❌ Ignorar testes

❌ Finalizar sem review
```

---

# Regra final


Uma feature nasce no produto.

Cresce no domínio.

É entregue pela tecnologia.


Fluxo obrigatório:

```text
Think

↓

Design

↓

Build

↓

Test

↓

Review

↓

Ship
```
````

Com isso sua pasta começa a ficar no estilo **Claude Code / agentes profissionais**:

```text
.ai/

├── personas/
│   ├── ui-ux-designer.md
│   ├── flutter-architect.md
│   ├── backend-architect.md
│   ├── security-engineer.md
│   └── qa-engineer.md

├── skills/
│   ├── create-feature/
│   ├── create-page/
│   ├── create-api/
│   ├── optimize-performance/
│   └── review-code/

└── workflows/
    └── new-feature.md ⭐
```

Agora o agente tem **quem ele é (personas)** + **o que sabe fazer (skills)** + **a ordem correta de execução (workflows)**. Esse é o ponto onde começa a ficar próximo de um fluxo de engenharia real.
