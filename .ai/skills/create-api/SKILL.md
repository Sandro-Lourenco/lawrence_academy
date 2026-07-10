---
name: create-api
description: "Cria ou altera endpoints FastAPI seguros, testáveis, documentados e alinhados à arquitetura da Lawrence Academy.
category: backend
risk: critical
source: self
source_type: self
date_added: "2026-07-10"
version: 1.0.0
tags:
  - fastapi
  - python
  - api
  - supabase
  - postgresql
  - security
  - testing
tools:
  - antigravity
  - gemini
---

# Create API

## Objetivo

Criar ou modificar endpoints FastAPI completos, seguindo:

- Clean Architecture;
- Domain-Driven Design;
- Modular Monolith;
- contratos REST;
- autenticação e autorização;
- Supabase PostgreSQL;
- Row Level Security;
- auditoria;
- observabilidade;
- testes automatizados.

## Quando usar

Ative esta skill quando a tarefa envolver:

- criação de endpoint;
- alteração de rota;
- DTO de request ou response;
- webhook;
- paginação;
- autenticação;
- autorização;
- integração com Supabase;
- implementação de UseCase;
- testes de API.

Para funcionalidades completas que também exijam Flutter e banco, use primeiro:

```text
@create-feature
```

## Leitura obrigatória

Antes de implementar:

1. `AGENTS.md`
2. `GEMINI.md`
3. `docs/product/PED-overview.md`
4. `docs/architecture/SYSTEM_ARCHITECTURE.md`
5. `docs/api/SERVICE_API.md`
6. `docs/database/DATABASE_SCHEMA.md`
7. `docs/security/SECURITY_COMPLIANCE_SPEC.md`
8. `docs/performance/PERFORMANCE_OPTIMIZATION_SPEC.md`

## Fluxo obrigatório

```text
Entender requisito
        ↓
Identificar bounded context
        ↓
Confirmar contrato da API
        ↓
Modelar domínio
        ↓
Criar ou alterar UseCase
        ↓
Criar Repository Interface
        ↓
Criar Repository Implementation
        ↓
Criar DTOs Pydantic
        ↓
Criar rota FastAPI
        ↓
Adicionar autenticação e autorização
        ↓
Validar RLS e auditoria
        ↓
Criar testes
        ↓
Atualizar documentação
```

## Regra de arquitetura

```text
Route
  ↓
Request DTO
  ↓
UseCase
  ↓
Repository Interface
  ↓
Repository Implementation
  ↓
Supabase/PostgreSQL
```

A rota nunca pode conter:

* SQL;
* chamada direta ao Supabase;
* regra de negócio;
* cálculo financeiro;
* processamento de vídeo;
* lógica de autorização espalhada;
* tratamento genérico de exceção.

## Estrutura esperada

```text
backend/api/src/modules/<context>/

├── domain/
│   ├── entities.py
│   ├── value_objects.py
│   ├── exceptions.py
│   └── repositories.py
│
├── application/
│   └── use_cases/
│
├── infrastructure/
│   ├── repositories/
│   ├── gateways/
│   └── mappers/
│
├── interface/
│   └── api/
│       ├── routes.py
│       ├── schemas.py
│       └── dependencies.py
│
└── tests/
    ├── unit/
    ├── integration/
    └── api/
```

## Contrato obrigatório do endpoint

Antes de criar código, definir:

```yaml
endpoint:
  id: API-CONTEXT-001
  method: POST
  path: /api/v1/resource
  context: bounded_context
  authentication: required
  roles:
    - student
  permissions:
    - resource.create
  ownership_validation: true
  idempotent: false
  audit: false
  rate_limit: 30/minute
```

Definir também:

* request;
* response;
* status HTTP;
* erros;
* permissões;
* ownership;
* eventos;
* transação;
* RLS;
* auditoria;
* idempotência.

## Segurança obrigatória

Toda rota protegida deve validar:

```text
JWT
+
Role
+
Permission
+
Ownership
+
RLS
```

O frontend nunca é autoridade.

Nunca usar `service_role` sem necessidade explícita, escopo mínimo e auditoria.

## Respostas

Sucesso:

```json
{
  "status": "success",
  "data": {},
  "meta": {
    "version": "v1"
  }
}
```

Erro:

```json
{
  "status": "error",
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "O recurso solicitado não foi encontrado."
  },
  "meta": {
    "request_id": "req_123"
  }
}
```

Nunca retornar:

* stack trace;
* erro SQL;
* caminho interno;
* token;
* credencial;
* resposta bruta do gateway.

## Testes obrigatórios

Criar testes para:

```text
Success

Invalid payload

Missing authentication

Invalid authentication

Missing permission

Invalid ownership

Resource not found

Business conflict

RLS denial

Rate limit

Sanitized internal error
```

Operações críticas também devem testar:

* idempotência;
* transação;
* rollback;
* webhook duplicado;
* auditoria.

## Checklist final

```text
[ ] O bounded context está correto?
[ ] A rota está fina?
[ ] Existe UseCase?
[ ] Existe Repository Interface?
[ ] DTOs estão validados?
[ ] JWT está validado?
[ ] Permission está validada?
[ ] Ownership está validado?
[ ] RLS está correta?
[ ] Existe transação quando necessária?
[ ] Existe idempotência quando necessária?
[ ] Existe auditoria quando necessária?
[ ] Erros estão sanitizados?
[ ] Logs não expõem dados sensíveis?
[ ] Testes foram criados?
[ ] OpenAPI foi atualizada?
[ ] SERVICE_API.md foi atualizado?
```

## Proibições

Nunca:

* colocar regra de negócio na rota;
* acessar banco diretamente no controller;
* expor models do banco;
* ignorar RLS;
* processar tarefas pesadas na requisição;
* criar pagamento sem idempotência;
* armazenar dados de cartão;
* expor MP4 público;
* alterar contrato sem atualizar documentação;
* concluir sem testes.

## Regra final

```text
A rota recebe.

O UseCase executa.

O domínio protege.

A infraestrutura integra.

O banco aplica a barreira final.

Os testes comprovam.
```

```

A versão extensa que escrevi anteriormente pode continuar como conteúdo principal desse `SKILL.md`; esta organização em pasta permite adicionar templates, exemplos e checklists sem transformar um único arquivo em algo difícil de manter.
```
