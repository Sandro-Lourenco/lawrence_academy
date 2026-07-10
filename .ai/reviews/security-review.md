---
name: security-review
description: "Revisão de segurança validando autenticação, autorização, dados, APIs, banco, infraestrutura e riscos antes de produção."
type: review
version: 1.0.0
status: production

review_owner:
  - security-engineer

required_personas:
  - security-engineer
  - backend-architect

optional_personas:
  - flutter-architect
  - qa-engineer
  - devops-engineer

required_documents:
  - AGENTS.md
  - GEMINI.md
  - docs/security/SECURITY_COMPLIANCE_SPEC.md
  - docs/architecture/SYSTEM_ARCHITECTURE.md
  - docs/api/SERVICE_API.md
  - docs/database/DATABASE_SCHEMA.md

related_workflows:
  - new-feature
  - database-change
  - release

related_reviews:
  - architecture-review
  - code-review
---

# Security Review


# 1. Objetivo

Garantir que nenhuma funcionalidade seja entregue com riscos de:

- vazamento de dados;
- acesso indevido;
- exposição de credenciais;
- falhas de autenticação;
- abuso de API;
- perda de dados;
- fraude;
- quebra de privacidade.

Segurança não é etapa final.

Ela faz parte da arquitetura.

---

# 2. Princípio principal

Aplicar:

```text
Secure By Design

Zero Trust

Least Privilege

Defense In Depth

Privacy First
```

Nunca confiar:

```text
Frontend

Cliente Mobile

Payload recebido

Usuário autenticado

Dados externos
```

---

# 3. Quando executar

Obrigatório em:

```text
Nova API

Nova tabela

Nova permissão

Login

Pagamento

Upload

Admin

Dados pessoais

Integração externa

Antes de release
```

---

# 4. Classificação de risco

Antes da revisão:

```yaml
security_review:

 feature:

 module:

 data_type:

 authentication:
   required: true

 risk:
   low | medium | high | critical
```

---

# 5. Autenticação


Validar:

```text
[ ] Login seguro

[ ] Token seguro

[ ] Refresh token

[ ] Expiração

[ ] Logout

[ ] Sessão inválida

[ ] MFA quando necessário
```

Bloquear:

```text
Token infinito

Senha armazenada

Sessão sem expiração
```

---

# 6. Senhas


Obrigatório:

```text
Hash forte

Salt

Proteção brute force
```

Nunca armazenar:

```text
senha pura

senha reversível
```

Permitido:

```text
bcrypt

argon2
```

---

# 7. JWT / Tokens


Validar:

```text
Tempo de vida

Assinatura

Claims

Revogação

Refresh seguro
```

Nunca colocar:

```text
Senha

Dados bancários

Dados sensíveis
```

dentro do token.

---

# 8. Autorização


Toda ação deve verificar:

```text
Quem é?

Pode fazer?

Sobre qual recurso?
```

Validar:

```text
Role

Permission

Ownership
```

Exemplo:

```text
Aluno A não acessa dados do Aluno B
```

---

# 9. Frontend Security


Flutter nunca deve conter:

```text
Regra real de permissão

Chave privada

Service Key

Secret

Controle financeiro
```

Frontend pode:

```text
Esconder botão
```

Backend deve:

```text
Bloquear ação
```

---

# 10. API Security


Todo endpoint validar:

```text
[ ] Auth

[ ] Permission

[ ] Input

[ ] Rate Limit

[ ] Erros seguros

[ ] Logs
```


Bloquear:

```http
GET /users/all
```

sem permissão.

---

# 11. Input Validation


Validar:

```text
Body

Query

Params

Headers

Files
```


Nunca confiar:

```text
O frontend já valida
```

---

# 12. Injection Protection


Verificar:

```text
SQL Injection

Command Injection

Template Injection
```

Obrigatório:

```text
ORM seguro

Prepared Statements

Sanitização
```

---

# 13. Erros


Nunca retornar:

```text
Stacktrace

SQL

Caminho interno

Secrets
```

Errado:

```json
{
 "error":"Database password invalid"
}
```


Certo:

```json
{
 "message":"Não foi possível concluir operação"
}
```

---

# 14. Dados sensíveis


Classificar:

## Público

```text
Nome curso

Descrição pública
```

## Privado

```text
Email

Telefone

Histórico
```

## Restrito

```text
Pagamento

Tokens

Permissões
```

---

# 15. LGPD / Privacidade


Validar:

```text
[ ] Coleta necessária

[ ] Finalidade clara

[ ] Exclusão possível

[ ] Exportação possível

[ ] Consentimento quando necessário
```

Coletar somente o necessário.

---

# 16. Banco de Dados


Validar:

```text
Permissões

Relacionamentos

Constraints

Auditoria

Backup
```

Nunca:

```text
Banco aberto publicamente
```

---

# 17. Supabase RLS


Obrigatório:

```sql
ENABLE ROW LEVEL SECURITY;
```


Toda tabela deve definir:

```text
SELECT

INSERT

UPDATE

DELETE
```

Bloquear:

```sql
USING(true)
```

sem motivo.

---

# 18. Multi Tenant


Sempre validar:

```text
tenant_id

ownership

scope
```

Nunca:

```text
WHERE id = ?
```

quando precisa:

```text
WHERE id=? AND tenant_id=?
```

---

# 19. Upload Security


Validar:

```text
Tipo arquivo

Tamanho

Extensão

Scan

Permissão

Storage privado
```

Nunca confiar:

```text
arquivo.png
```

pode ser outro tipo.

---

# 20. Storage


Arquivos privados:

```text
URL assinada

Tempo limitado

Controle acesso
```


Evitar:

```text
bucket público
```

---

# 21. Pagamentos


Obrigatório:

```text
Webhook seguro

Assinatura validada

Logs

Auditoria
```

Nunca salvar:

```text
Cartão

CVV
```

---

# 22. Webhooks


Validar:

```text
Signature

Timestamp

Replay Attack

Origem
```

Nunca confiar apenas na URL.

---

# 23. Logs


Registrar:

```text
Login

Falhas

Admin

Pagamento

Permissões
```

Nunca logar:

```text
Senha

Token

Cartão

Secrets
```

---

# 24. Secrets


Nunca:

```text
.env no Git

API Key no app

Senha hardcoded
```

Usar:

```text
Environment Variables

Secret Manager
```

---

# 25. Dependências


Verificar:

```text
Vulnerabilidades

Pacotes abandonados

Licenças

Versões antigas
```

---

# 26. Admin Security


Admin exige:

```text
Permissão forte

Auditoria

Confirmação

Logs
```

Ações críticas:

```text
Excluir usuário

Alterar pagamento

Alterar role
```

---

# 27. IA Security


Se usar IA:

Validar:

```text
Prompt Injection

Dados enviados

Privacidade

Controle acesso

Logs
```

Não enviar:

```text
Dados sensíveis sem necessidade
```

---

# 28. Mobile Security


Validar:

```text
Secure Storage

Sessões

Cache

Dados offline
```

Não armazenar:

```text
Token em arquivo simples
```

---

# 29. Checklist OWASP


Verificar:

```text
Broken Access Control

Cryptographic Failures

Injection

Insecure Design

Security Misconfiguration

Vulnerable Components

Authentication Failures

Integrity Failures

Logging Failures
```

---

# 30. Resultado esperado


Responder:

```markdown
# Security Review Result


## Status

APPROVED

NEEDS_CHANGES

BLOCKED


## Critical Risks

-

## Medium Risks

-

## Low Risks

-


## Required Fixes

-


## Recommendations

-
```

---

# 31. Bloqueadores


Nunca aprovar:

```text
❌ Secret exposto

❌ Sem autorização backend

❌ Dados privados públicos

❌ Senha insegura

❌ SQL inseguro

❌ Upload sem validação

❌ Pagamento sem auditoria

❌ Admin sem controle

❌ Token sem proteção
```

---

# Checklist final


```text
AUTH

[ ] Seguro


PERMISSIONS

[ ] Validado


DATA

[ ] Protegido


API

[ ] Validada


DATABASE

[ ] Seguro


UPLOAD

[ ] Controlado


SECRETS

[ ] Protegidos


LOGS

[ ] Seguros
```

---

# Regra final

Segurança boa é invisível.

O usuário percebe:

```text
Confiança
```

O sistema garante:

```text
Proteção

Privacidade

Controle

Auditoria
```

Nunca dependa de confiança.

Sempre valide.