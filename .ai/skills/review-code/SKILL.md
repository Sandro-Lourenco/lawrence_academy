---
name: review-code
description: "Revisa código Flutter, FastAPI, Supabase e PostgreSQL com foco em arquitetura, segurança, qualidade, performance e testes.
category: quality
risk: safe
source: self
source_type: self
date_added: "2026-07-10"
version: 1.0.0
tags:
  - code-review
  - flutter
  - fastapi
  - python
  - supabase
  - postgresql
  - security
  - performance
  - testing
tools:
  - antigravity
  - gemini

required_personas:
  - flutter-architect
  - backend-architect
  - security-engineer
  - qa-engineer

optional_personas:
  - ui-ux-designer
---

# Review Code

## 1. Objetivo

Revisar código novo ou alterado antes de considerá-lo pronto.

A revisão deve avaliar:

- aderência aos requisitos;
- arquitetura;
- separação de responsabilidades;
- regras de negócio;
- segurança;
- privacidade;
- performance;
- acessibilidade;
- testes;
- legibilidade;
- manutenção;
- documentação;
- risco de regressão.

Esta skill não deve apenas procurar erros de sintaxe.

Ela deve responder:

```text

O código resolve o problema correto?

Está no módulo correto?

Respeita a arquitetura?

É seguro?

É testável?

É performático?

Está pronto para produção?
```

---

## 2. Quando usar

Use esta skill:

* após criar uma feature;
* após criar uma página;
* após criar ou alterar uma API;
* antes de abrir pull request;
* antes de merge;
* após refatoração;
* após correção de bug;
* antes de release;
* quando houver dúvida sobre qualidade;
* quando código gerado por IA precisar ser validado;
* quando houver mudança em segurança, pagamentos, mídia ou permissões.

Usar obrigatoriamente após:

```text
@create-feature

@create-page

@create-api

@create-premium-flutter-screen

@optimize-performance
```

---

## 3. Leitura obrigatória

Antes da revisão, ler apenas os documentos relevantes, nesta ordem:

```text
1. AGENTS.md

2. GEMINI.md

3. docs/product/PED-overview.md

4. docs/architecture/SYSTEM_ARCHITECTURE.md

5. documentação do domínio alterado

6. docs/api/SERVICE_API.md, se houver API

7. docs/database/DATABASE_SCHEMA.md

8. docs/security/SECURITY_COMPLIANCE_SPEC.md

9. docs/performance/PERFORMANCE_OPTIMIZATION_SPEC.md

10. docs/design/design-system.md

11. Page Spec/
```

A revisão precisa comparar o código com a especificação correta.

Não avaliar apenas por preferência pessoal.

---

## 4. Escopo da revisão

Antes de começar, identificar:

```yaml
review:
  type: feature | page | api | database | bugfix | refactor | release
  files_changed: []
  bounded_context: subscriptions
  risk_level: low | medium | high | critical
  affects:
    - frontend
    - backend
    - database
    - security
    - payments
    - offline
  expected_behavior: ""
```

Classificar o risco como:

### Low

* texto;
* documentação;
* componente visual simples;
* refatoração sem mudança de comportamento.

### Medium

* estado Flutter;
* nova página;
* endpoint de leitura;
* cache;
* alteração de fluxo não crítico.

### High

* autenticação;
* autorização;
* RLS;
* upload;
* assinatura;
* pagamento;
* offline;
* sincronização;
* exclusão.

### Critical

* service role;
* dados financeiros;
* permissões administrativas;
* migração destrutiva;
* webhook;
* segredo;
* proteção de vídeo;
* produção;
* incidente de segurança.

Quanto maior o risco, mais profunda deve ser a revisão.

---

## 5. Processo obrigatório

Toda revisão segue:

```text
Entender requisito
        ↓
Inspecionar diff
        ↓
Identificar módulos afetados
        ↓
Verificar arquitetura
        ↓
Verificar regras de negócio
        ↓
Verificar segurança
        ↓
Verificar performance
        ↓
Verificar testes
        ↓
Executar validações
        ↓
Classificar achados
        ↓
Emitir decisão
```

Não fazer mudanças grandes silenciosamente durante a revisão.

Primeiro registrar os achados.

Depois corrigir, quando a tarefa também autorizar correção.

---

## 6. Regra de evidência

Toda conclusão deve ser sustentada por:

* arquivo;
* trecho;
* comportamento;
* teste;
* comando executado;
* requisito;
* regra documentada.

Evitar comentários vagos como:

```text
Isso não está bom.

Pode melhorar.

Código estranho.
```

Preferir:

```text
CRITICAL — `subscription_routes.py:84`

A rota usa `service_role` para cancelar assinatura sem validar
ownership do aluno. Isso contorna a RLS definida para subscriptions.

Correção:
validar `student_id == current_user.id` no UseCase e usar o
repositório com contexto autenticado.
```

---

## 7. Classificação dos achados

Usar estes níveis:

### BLOCKER

Impede merge ou release.

Exemplos:

* vazamento de segredo;
* perda de dados;
* pagamento duplicado;
* ausência de autorização;
* migração destrutiva insegura;
* código não compila;
* testes críticos quebrados.

### CRITICAL

Risco grave de segurança, negócio ou confiabilidade.

Exemplos:

* RLS incorreta;
* endpoint administrativo sem permission;
* corrida em assinatura;
* arquivo MP4 público;
* webhook sem validação;
* transação incompleta.

### MAJOR

Problema importante que deve ser corrigido antes do merge.

Exemplos:

* regra no Widget;
* rota com regra de negócio;
* ausência de testes;
* estados de erro não tratados;
* N+1;
* acessibilidade quebrada;
* contrato divergente.

### MINOR

Melhoria relevante, mas não bloqueante.

Exemplos:

* nome pouco claro;
* duplicação pequena;
* documentação incompleta;
* widget poderia ser extraído.

### NIT

Sugestão cosmética.

Exemplos:

* comentário;
* formatação;
* ordem de import;
* pequena melhoria de nome.

Não transformar preferência pessoal em `MAJOR`.

---

## 8. Revisão de requisitos

Confirmar:

```text
[ ] O código implementa o requisito solicitado?

[ ] A regra de negócio corresponde ao PED?

[ ] O comportamento corresponde à Page Spec ou SERVICE_API?

[ ] Os critérios de aceitação foram atendidos?

[ ] Foi criado algo fora do escopo?

[ ] Alguma regra existente foi quebrada?
```

A revisão deve detectar implementação tecnicamente correta do problema errado.

---

## 9. Revisão de arquitetura geral

Verificar:

```text
[ ] O bounded context está correto?

[ ] As dependências apontam para dentro?

[ ] Domain permanece independente?

[ ] Application orquestra o fluxo?

[ ] Infrastructure contém detalhes tecnológicos?

[ ] Presentation apenas apresenta estado?

[ ] Não há dependência circular?

[ ] Não há pasta genérica criada sem necessidade?

[ ] Não há duplicação entre módulos?
```

Fluxo esperado:

```text
Presentation
    ↓
Application
    ↓
Domain
    ↑
Infrastructure
```

Bloquear:

```text
Widget → Supabase

Route → SQL

UseCase → Flutter

Domain → FastAPI

Domain → SDK externo
```

---

## 10. Revisão Flutter

Ativar `flutter-architect`.

Verificar:

### Estrutura

```text
[ ] Feature First?

[ ] Page pequena e composicional?

[ ] Widgets locais bem separados?

[ ] Controller separado?

[ ] State explícito?

[ ] UseCase usado?

[ ] Repository abstraído?
```

### Riverpod

```text
[ ] AsyncNotifier ou Notifier usado corretamente?

[ ] Providers possuem escopo adequado?

[ ] Não há rebuild global desnecessário?

[ ] `select` é usado quando útil?

[ ] Não existe regra de negócio em provider de apresentação?

[ ] Providers não criam dependências ocultas?
```

### UI

```text
[ ] Loading?

[ ] Empty?

[ ] Error?

[ ] Offline, quando aplicável?

[ ] Unauthorized, quando aplicável?

[ ] Responsivo em mobile, tablet e desktop?

[ ] Usa Design System?

[ ] Não possui valores visuais aleatórios?
```

### Navegação

```text
[ ] Usa GoRouter?

[ ] Rotas centralizadas?

[ ] Guards corretos?

[ ] Não duplica autorização na UI?

[ ] Deep link válido?
```

### Recursos

Verificar descarte de:

```text
AnimationController

TextEditingController

FocusNode

StreamSubscription

Timer

VideoController
```

Bloquear vazamentos de recursos.

---

## 11. Revisão UI/UX

Ativar `ui-ux-designer` quando houver alteração visual.

Verificar:

```text
[ ] A ação principal está clara?

[ ] A hierarquia visual faz sentido?

[ ] A tela parece específica do produto?

[ ] O conteúdo prioritário aparece primeiro?

[ ] Há excesso de cards?

[ ] Há excesso de ações concorrentes?

[ ] A interface funciona com texto grande?

[ ] Os estados são humanos e recuperáveis?

[ ] O Liquid Glass foi usado apenas onde permitido?

[ ] A tela evita estética genérica de IA?
```

Não aceitar tela bonita que prejudique uso.

---

## 12. Revisão de acessibilidade

Verificar:

```text
[ ] Semantics em ações importantes?

[ ] Labels em campos?

[ ] Touch targets adequados?

[ ] Contraste suficiente?

[ ] Não depende apenas de cor?

[ ] Ordem de foco correta?

[ ] Navegação por teclado no Web?

[ ] Text scaling sem overflow?

[ ] Reduce Motion respeitado?

[ ] Ícones importantes acompanhados por texto ou label?
```

Para usuários com baixa visão:

* evitar texto pequeno;
* evitar transparência excessiva;
* evitar cinza claro em informação importante;
* manter foco visível;
* não reduzir fonte para corrigir layout.

---

## 13. Revisão Backend

Ativar `backend-architect`.

Verificar:

### Estrutura

```text
[ ] Módulo correto?

[ ] Route fina?

[ ] DTO Pydantic?

[ ] UseCase explícito?

[ ] Repository Interface?

[ ] Repository Implementation?

[ ] Mapper separado quando necessário?
```

### Domínio

```text
[ ] Invariantes estão no domínio?

[ ] Value Objects validam conceitos?

[ ] Erros de domínio são específicos?

[ ] Entidades não dependem de FastAPI/Pydantic/Supabase?
```

### API

```text
[ ] Método HTTP correto?

[ ] Status HTTP correto?

[ ] Envelope padronizado?

[ ] Erros padronizados?

[ ] OpenAPI atualizada?

[ ] Paginação em listas?

[ ] Idempotência em ações críticas?

[ ] Tarefas pesadas foram para worker?
```

Bloquear:

```text
Fat controller

SQL em rota

Supabase em toda camada

Resposta bruta de gateway

try/except Exception repetido
```

---

## 14. Revisão de banco

Verificar:

```text
[ ] A mudança possui migration?

[ ] UUID usado?

[ ] created_at e updated_at?

[ ] FK correta?

[ ] ON DELETE correto?

[ ] Constraints de domínio?

[ ] Índices para FKs e filtros?

[ ] Unique constraint quando necessária?

[ ] RLS habilitada?

[ ] Policies completas?

[ ] Soft delete quando necessário?

[ ] Auditoria preservada?
```

Verificar riscos:

* exclusão em cascata indevida;
* coluna `NOT NULL` sem migração segura;
* enum difícil de evoluir;
* índice redundante;
* constraint ausente;
* duplicação de dados sem estratégia;
* migration irreversível.

Mudanças destrutivas exigem:

```text
Plano de migração

Backup

Rollback

Validação em staging
```

---

## 15. Revisão de segurança

Ativar `security-engineer`.

Verificar:

### Autenticação

```text
[ ] JWT validado?

[ ] Expiração validada?

[ ] Sessão válida?

[ ] MFA exigido em área crítica?
```

### Autorização

```text
[ ] Permission validada?

[ ] Ownership validado?

[ ] RLS reforça autorização?

[ ] Frontend não é autoridade?
```

### Entrada

```text
[ ] Body validado?

[ ] Query validada?

[ ] Upload validado?

[ ] Tamanho limitado?

[ ] MIME validado?

[ ] SQL parametrizado?
```

### Dados

```text
[ ] Segredos protegidos?

[ ] PII minimizada?

[ ] Logs sanitizados?

[ ] Dados financeiros tokenizados?

[ ] Service role usada com escopo mínimo?
```

### Mídia

```text
[ ] Sem MP4 público?

[ ] URL assinada?

[ ] Assinatura do curso validada?

[ ] Download offline protegido?

[ ] Licença offline respeitada?
```

### IA

```text
[ ] Contexto limitado?

[ ] Sem PII desnecessária?

[ ] Proteção contra prompt injection?

[ ] Saída validada?
```

---

## 16. Revisão de pagamentos e assinatura

Mudanças financeiras exigem revisão profunda.

Confirmar:

```text
[ ] 1 curso = 1 assinatura?

[ ] Cancelamento afeta apenas o curso correto?

[ ] Acesso permanece até o fim do período pago?

[ ] Operação é idempotente?

[ ] Webhook valida assinatura?

[ ] Eventos duplicados são tolerados?

[ ] Estado local e gateway podem ser reconciliados?

[ ] Valores usam Decimal?

[ ] Transação evita estado parcial?

[ ] Audit log existe?
```

Nunca aceitar:

* pagamento sem idempotência;
* valor vindo do frontend como autoridade;
* webhook não autenticado;
* atualização financeira sem auditoria;
* uso de `float` para dinheiro.

---

## 17. Revisão de offline e sincronização

Verificar:

```text
[ ] Ação offline não perde dados?

[ ] Sync Queue possui retry?

[ ] Operações possuem ID único?

[ ] Conflito multi-device foi tratado?

[ ] Maior progresso vence quando definido?

[ ] Server timestamp é usado para auditoria?

[ ] Licença offline expira?

[ ] Assinatura é validada antes do download?

[ ] Arquivo descriptografado não é persistido?

[ ] Falha de sync é observável?
```

Bloquear qualquer offline que contorne segurança.

---

## 18. Revisão de performance

Ativar `optimize-performance` quando necessário.

### Flutter

```text
[ ] Listas usam builder ou Sliver?

[ ] Imagens possuem dimensões de cache?

[ ] Não há rebuild global?

[ ] Blur está isolado?

[ ] Animações são leves?

[ ] Widgets usam const?

[ ] Não há objeto grande mantido sem necessidade?
```

### API

```text
[ ] Sem SELECT *?

[ ] Payload limitado?

[ ] Paginação?

[ ] Query eficiente?

[ ] Processo pesado assíncrono?

[ ] Cache possui invalidação?
```

### Banco

```text
[ ] Índices adequados?

[ ] Sem N+1?

[ ] Sem table scan indevido?

[ ] EXPLAIN ANALYZE quando necessário?

[ ] Sem lock longo?
```

Performance deve ser medida quando houver suspeita real.

---

## 19. Revisão de erros e resiliência

Verificar:

```text
[ ] Exceções de domínio específicas?

[ ] Erros técnicos não chegam ao usuário?

[ ] Retry possui limite?

[ ] Exponential backoff?

[ ] Timeout configurado?

[ ] Circuit breaker quando necessário?

[ ] Estado parcial evitado?

[ ] Requisição duplicada tolerada?

[ ] Falha externa mapeada corretamente?
```

Não aceitar retry infinito.

---

## 20. Revisão de observabilidade

Verificar:

```text
[ ] Request ID?

[ ] Trace ID quando aplicável?

[ ] Logs estruturados?

[ ] Latência registrada?

[ ] Erros monitorados?

[ ] Worker possui métricas?

[ ] Fila possui alerta?

[ ] Eventos críticos auditados?
```

Não registrar:

```text
Senha

JWT

Refresh token

Service role key

CVV

Número de cartão

Conteúdo privado completo
```

---

## 21. Revisão de testes

Ativar `qa-engineer`.

Verificar:

```text
[ ] Testes unitários?

[ ] Testes de UseCase?

[ ] Testes de Repository?

[ ] Testes de API?

[ ] Widget tests?

[ ] Golden tests quando necessário?

[ ] Integration tests para fluxo crítico?

[ ] Edge cases?

[ ] Falhas de autenticação?

[ ] Falhas de autorização?

[ ] RLS testada?

[ ] Offline testado?

[ ] Regressão coberta?
```

Não aceitar testes que apenas repetem a implementação.

Os testes devem provar comportamento.

---

## 22. Comandos de validação

Executar os comandos aplicáveis ao projeto.

### Flutter

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Quando houver testes de integração:

```bash
flutter test integration_test
```

### Python

```bash
ruff check .
ruff format --check .
mypy src
pytest -q
```

Usar apenas comandos configurados no repositório.

Não inventar ferramentas que o projeto não utiliza.

### Supabase

Quando disponível:

```bash
supabase db lint
supabase test db
```

### Docker

```bash
docker compose config
docker compose build
```

Registrar comandos não executados e o motivo.

---

## 23. Revisão de diff

Priorizar o diff, mas também inspecionar contexto suficiente.

Verificar:

* arquivos alterados;
* arquivos novos;
* arquivos removidos;
* migrations;
* dependências;
* configurações;
* `.env.example`;
* workflows;
* documentação;
* testes.

Não revisar apenas o arquivo principal.

Uma mudança pequena pode afetar arquitetura global.

---

## 24. Dependências novas

Para cada dependência adicionada, verificar:

```text
[ ] É realmente necessária?

[ ] Existe alternativa já instalada?

[ ] É mantida?

[ ] Possui licença adequada?

[ ] Aumenta bundle?

[ ] Introduz vulnerabilidade?

[ ] Foi fixada em versão compatível?

[ ] É usada em apenas um ponto simples?
```

Evitar dependência para função trivial.

---

## 25. Revisão de documentação

Confirmar atualização de:

```text
SERVICE_API.md

DATABASE_SCHEMA.md

PAGES_OVERVIEW.md

Page Spec

README

.env.example

Migration notes

ADR
```

quando aplicável.

Código e documentação não podem divergir.

---

## 26. Formato de saída da revisão

Usar este formato:

```markdown
# Code Review

## Decisão

APPROVE | REQUEST_CHANGES | BLOCK

## Escopo

- Contexto:
- Risco:
- Arquivos revisados:
- Testes executados:

## Achados

### BLOCKER

1. `arquivo:linha` — Título
   - Problema:
   - Impacto:
   - Evidência:
   - Correção recomendada:

### CRITICAL

...

### MAJOR

...

### MINOR

...

### NIT

...

## Pontos positivos

- ...

## Validações

- `flutter analyze`: passou
- `pytest`: falhou — 2 testes
- Não executado: motivo

## Conclusão

Resumo objetivo da decisão.
```

Ordenar achados por severidade.

Não esconder problemas importantes dentro de texto longo.

---

## 27. Regras de decisão

### APPROVE

Apenas quando:

* nenhum `BLOCKER`;
* nenhum `CRITICAL`;
* nenhum `MAJOR` pendente;
* testes relevantes passaram;
* documentação está consistente;
* riscos restantes estão declarados.

### REQUEST_CHANGES

Quando:

* existe `MAJOR`;
* testes relevantes faltam;
* arquitetura precisa ajuste;
* estados incompletos;
* documentação divergente;
* acessibilidade não atendida.

### BLOCK

Quando:

* existe `BLOCKER`;
* existe vulnerabilidade grave;
* há risco de perda de dados;
* pagamento pode duplicar;
* migration é insegura;
* código não compila;
* contrato crítico foi quebrado.

Não aprovar com base em “parece funcionar”.

---

## 28. Correção durante a revisão

Quando autorizado a corrigir:

```text
1. Registrar achado

2. Criar ou ajustar teste

3. Corrigir causa raiz

4. Executar validações

5. Revisar novamente

6. Documentar alteração
```

Não fazer refatoração não relacionada.

Não aumentar o escopo sem necessidade.

---

## 29. Anti-padrões obrigatoriamente bloqueados

```text
❌ Widget chamando Supabase

❌ Regra de negócio em rota

❌ SQL concatenado

❌ Endpoint protegido sem permission

❌ Tabela sensível sem RLS

❌ Service role no cliente

❌ Pagamento sem idempotência

❌ Webhook sem validação

❌ MP4 público

❌ Segredo no Git

❌ SELECT *

❌ Lista grande em Column

❌ UI sem estados de erro

❌ Código crítico sem testes

❌ Exceção técnica exposta

❌ Migration destrutiva sem plano

❌ Uso de float para dinheiro

❌ Audit log editável
```

---

## 30. Checklist final

```text
REQUISITOS

[ ] Implementa o comportamento correto?
[ ] Atende critérios de aceitação?
[ ] Não saiu do escopo?

ARQUITETURA

[ ] Bounded context correto?
[ ] Dependências corretas?
[ ] Camadas respeitadas?
[ ] Sem duplicação inadequada?

FLUTTER

[ ] Riverpod correto?
[ ] Sem regra no Widget?
[ ] Responsivo?
[ ] Estados completos?
[ ] Design System?
[ ] Acessível?

BACKEND

[ ] Route fina?
[ ] UseCase?
[ ] DTO?
[ ] Repository?
[ ] Erros padronizados?
[ ] OpenAPI?

DATABASE

[ ] Migration?
[ ] Constraints?
[ ] Índices?
[ ] RLS?
[ ] Policies?

SEGURANÇA

[ ] Auth?
[ ] Permission?
[ ] Ownership?
[ ] Secrets?
[ ] Logs?
[ ] Audit?

PERFORMANCE

[ ] Paginação?
[ ] Payload?
[ ] Queries?
[ ] Cache?
[ ] Workers?
[ ] Rebuilds?

QUALIDADE

[ ] Testes?
[ ] Edge cases?
[ ] Lint?
[ ] Build?
[ ] Documentação?
```

---

## 31. Exemplo

Solicitação:

```text
Revise a implementação de cancelamento de assinatura.
```

Revisão esperada:

```text
1. Confirmar regra 1 curso = 1 assinatura.

2. Verificar se apenas a assinatura do curso é cancelada.

3. Verificar acesso até o fim do período pago.

4. Validar ownership.

5. Validar idempotência.

6. Validar webhook.

7. Verificar transação e rollback.

8. Confirmar audit log.

9. Executar testes.

10. Emitir APPROVE, REQUEST_CHANGES ou BLOCK.
```

---

## Regra final

Revisão de código não é cerimônia.

É a última barreira antes de uma decisão ruim chegar ao usuário.

```text
Leia o requisito.

Inspecione a evidência.

Encontre o risco.

Explique o impacto.

Exija a correção.

Valide novamente.
```

Aprovar significa assumir responsabilidade técnica pelo código.

```
```
