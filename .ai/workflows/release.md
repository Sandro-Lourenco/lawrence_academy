---
name: release
description: "Workflow completo para preparar, validar e publicar uma versão em produção com segurança."
type: workflow
version: 1.0.0
status: production

required_personas:
  - backend-architect
  - flutter-architect
  - security-engineer
  - qa-engineer

optional_personas:
  - ui-ux-designer
  - devops-engineer

required_skills:
  - review-code
  - optimize-performance

related_workflows:
  - new-feature
  - create-screen
  - database-change

documents:
  - AGENTS.md
  - GEMINI.md
  - docs/product/PED-overview.md
  - docs/architecture/SYSTEM_ARCHITECTURE.md
  - docs/security/SECURITY_COMPLIANCE_SPEC.md
  - docs/performance/PERFORMANCE_OPTIMIZATION_SPEC.md
  - docs/devops/DEVOPS_INFRA.md
---

# Workflow: Release


# 1. Objetivo

Preparar uma versão para:

- staging;
- homologação;
- produção.

Garantir que nenhuma alteração seja publicada sem validar:

- requisitos;
- arquitetura;
- segurança;
- banco;
- frontend;
- backend;
- performance;
- testes;
- documentação;
- rollback.


Release não é apenas deploy.

Release é controle de risco.


---

# 2. Quando usar


Executar antes de:

```text
Publicar nova versão

Merge na branch principal

Deploy produção

Criar build mobile

Criar versão web

Liberar feature
```


---

# 3. Fluxo obrigatório


```text
Congelar alterações

        ↓

Revisar código

        ↓

Executar testes

        ↓

Validar segurança

        ↓

Validar banco

        ↓

Gerar build

        ↓

Validar ambiente

        ↓

Deploy

        ↓

Monitorar

        ↓

Encerrar release
```


---

# 4. Identificação da release


Antes de iniciar definir:


```yaml
release:

 version:

 date:

 environment:
   staging | production

 type:
   major | minor | patch

 features:

 migrations:

 risks:

 rollback_plan:
```


Exemplo:


```yaml
release:

 version: 1.4.0

 type: minor

 features:
   - certificates
   - offline videos

 migrations:
   - create_certificates

 risk:
   medium
```


---

# 5. Validar branch


Antes:

```text
[ ] Branch correta

[ ] Código atualizado

[ ] Sem alterações locais

[ ] Pull request criado

[ ] Review feito
```


Executar:


```bash
git status

git pull

git log
```


---

# 6. Code Review


Executar:

```text
@review-code
```


Validar:


```text
Arquitetura

Clean Architecture

SOLID

DDD

Separação de camadas

Regras de negócio
```


Bloquear:

```text
Controller gordo

Regra no Widget

SQL espalhado

Código duplicado

Gambiarras temporárias
```


---

# 7. Testes Backend


Executar:


```bash
pytest
```


Validar:


```text
Unit Tests

Integration Tests

API Tests

Security Tests
```


Obrigatório:


```text
100% passando
```


---

# 8. Testes Flutter


Executar:


```bash
flutter test

flutter analyze
```


Validar:


```text
Widgets

Providers

Navigation

Golden Tests

Responsividade
```


---

# 9. Qualidade código


Executar quando configurado:


Python:


```bash
ruff check .

mypy .
```


Flutter:


```bash
dart analyze

dart format .
```


---

# 10. Banco de Dados


Executar workflow:


```text
@database-change
```


Verificar:


```text
[ ] Todas migrations aplicadas

[ ] Rollback definido

[ ] Backup criado

[ ] Índices revisados

[ ] Constraints corretas

[ ] Performance validada
```


Nunca fazer migration manual em produção.


---

# 11. Segurança


Executar:

```text
@security-engineer
```


Validar:


## Autenticação


```text
[ ] JWT

[ ] Refresh Token

[ ] Sessão
```


## Autorização


```text
[ ] Roles

[ ] Permissions

[ ] Ownership

[ ] RLS
```


## Secrets


Verificar:


```text
.env

API Keys

Tokens

Service Keys
```


Nunca permitir:


```text
Secret no Git
```


---

# 12. Dependências


Verificar:


```text
[ ] Vulnerabilidades

[ ] Versões

[ ] Licenças

[ ] Pacotes abandonados
```


Executar:


Flutter:


```bash
flutter pub outdated
```


Python:


```bash
pip list --outdated
```


---

# 13. Variáveis ambiente


Comparar:


```text
.env.example

↓

staging

↓

production
```


Validar:


```text
DATABASE_URL

JWT_SECRET

SUPABASE_KEYS

STORAGE

PAYMENTS

EMAIL
```


---

# 14. Build Flutter


## Android


Executar:


```bash
flutter build apk --release
```


ou:


```bash
flutter build appbundle
```


Validar:


```text
Tamanho

Performance

Crash

Permissões
```


---


## Web


Executar:


```bash
flutter build web
```


Validar:


```text
SEO

Assets

Rotas

Cache

Responsividade
```


---

# 15. Build Backend


Validar:


```text
Docker

Imagem

Variáveis

Health Check
```


Executar:


```bash
docker compose build
```


Testar:


```bash
docker compose up
```


---

# 16. Performance


Executar:


```text
@optimize-performance
```


Verificar:


Frontend:


```text
FPS

Rebuilds

Memória

Imagens

Bundle
```


Backend:


```text
Latency

Queries

Cache

CPU

RAM
```


---

# 17. Observabilidade


Antes do deploy:


Confirmar:


```text
Logs

Metrics

Errors

Alerts

Tracing
```


Monitorar:


```text
API Errors

Crash Rate

Database

Payments

Workers
```


---

# 18. Backup


Antes produção:


Obrigatório:


```text
Database Backup

Storage Backup

Config Backup
```


Guardar:


```text
Data

Versão

Responsável
```


---

# 19. Deploy Staging


Primeiro:


```text
Production-like environment
```


Validar:


```text
Login

Cadastro

Pagamento

Vídeo

Admin

Permissões

Offline
```


---

# 20. Smoke Test


Após deploy:


Testar:


```text
[ ] App abre

[ ] Login funciona

[ ] API responde

[ ] Banco conecta

[ ] Upload funciona

[ ] Vídeo funciona

[ ] Pagamento funciona

[ ] Email funciona

[ ] Logs aparecem
```


---

# 21. Deploy Production


Antes confirmar:


```text
Todos testes passaram

Backup OK

Rollback pronto

Monitoramento ativo
```


Depois:


```text
Deploy

Monitorar

Validar
```


---

# 22. Rollback


Sempre ter:


```text
Versão anterior

Migration rollback

Backup

Plano execução
```


Se ocorrer:


```text
Erro crítico

Perda dados

Falha pagamento

Indisponibilidade
```


executar rollback.


---

# 23. Pós-release


Após publicar:


Monitorar:


```text
Primeiros 15 minutos

Primeira hora

Primeiro dia
```


Verificar:


```text
Crash

Erros

Performance

Feedback usuários
```


---

# 24. Atualizar documentação


Atualizar:


```text
CHANGELOG.md

README.md

API Docs

Database Docs

Page Specs
```


Registrar:


```text
Versão

Mudanças

Migrações

Breaking Changes
```


---

# 25. Checklist final


```text
CÓDIGO

[ ] Review aprovado

[ ] Sem débito crítico


TESTES

[ ] Backend passou

[ ] Flutter passou


SEGURANÇA

[ ] Secrets OK

[ ] Permissões OK


BANCO

[ ] Migration OK

[ ] Backup OK


BUILD

[ ] Android OK

[ ] Web OK

[ ] Backend OK


DEPLOY

[ ] Staging OK

[ ] Produção OK


MONITORAMENTO

[ ] Logs

[ ] Alertas
```


---

# 26. Bloqueadores de release


Nunca publicar com:


```text
❌ Teste crítico falhando

❌ Migration insegura

❌ Sem rollback

❌ Sem backup

❌ Secret exposto

❌ Erro de autenticação

❌ Pagamento instável

❌ Dados sem proteção

❌ Crash conhecido

❌ Build com erro

❌ Documentação crítica divergente
```


---

# Regra final


Release não termina quando o deploy acaba.


Release termina quando:


```text
Usuários usando

Sistema saudável

Dados seguros

Métricas normais
```


