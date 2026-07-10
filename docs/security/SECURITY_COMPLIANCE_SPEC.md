---
version: 2.0.0
name: Security-Compliance-Spec
type: Security Architecture & Compliance Specification

status: Production Ready

platforms:
  - Flutter Web
  - Flutter Android

backend:
  framework: FastAPI
  language: Python

database:
  provider: Supabase
  engine: PostgreSQL

security_frameworks:
  - OWASP Top 10
  - Zero Trust Architecture
  - LGPD
  - GDPR
  - PCI-DSS SAQ-A

principles:
  - Never Trust Client
  - Least Privilege
  - Defense In Depth
  - Secure By Default
---

# Lawrence Academy
# Security & Compliance Specification


# 1. Objetivo

Este documento define todas as regras de segurança da plataforma.

Protege:

- usuários
- professores
- pagamentos
- cursos
- vídeos premium
- dados pessoais
- infraestrutura
- inteligência artificial


Segurança não é camada extra.

É requisito arquitetural.


---

# 2. Security Philosophy


A arquitetura segue:


Zero Trust


Regra principal:


```text
Nunca confiar no Frontend
```


Flutter Web e Android são considerados clientes não confiáveis.


Toda decisão crítica acontece em:


```text
FastAPI

+

Supabase RLS

+

Business Rules
```


---

# 3. Security Layers


A segurança é dividida em camadas:


```text

Client Security


        ↓


API Security


        ↓


Application Security


        ↓


Database Security


        ↓


Infrastructure Security

```


Nenhuma camada depende sozinha de outra.


---

# 4. Threat Model


Principais riscos:


## Account Takeover


Usuário perde acesso da conta.


Mitigação:


- MFA
- Refresh Token seguro
- Rate Limit


---


## Data Leak


Exposição de dados pessoais.


Mitigação:


- RLS
- criptografia
- controle de acesso


---


## Course Piracy


Roubo de vídeos.


Mitigação:


- HLS
- Signed URL
- Watermark


---


## Privilege Escalation


Aluno tentando virar admin.


Mitigação:


- RBAC
- Audit
- Server Validation


---

# 5. Authentication


Pergunta:


```text
Quem é o usuário?
```


Tecnologia:


Supabase Auth


---


# Login


Fluxo:


```text
Email/Senha


↓

Supabase Auth


↓

JWT


↓

Session

```


---

# Password Security


Obrigatório:


Hash seguro


Política senha


Proteção brute force


---

# Session Security


Access Token:


curta duração


Refresh Token:


rotacionável


---

# MFA


Obrigatório para:


ADMIN


SUPER_ADMIN


Ações críticas


---

# 6. Authorization


Pergunta:


```text
O que o usuário pode fazer?
```


Nunca usar somente:


```text
if user.role == admin
```


---

Usar:


```text

User

↓

Roles

↓

Permissions

```


---

# Permissions Examples


```text
CREATE_COURSE


DELETE_USER


VIEW_REPORT


MANAGE_PAYMENT

```


---

# Role Rules


Student:


Menor privilégio.


---

Teacher:


Somente seus próprios recursos.


---

Admin:


Limitado por permissões.


---

Super Admin:


Controle avançado.


---

# 7. Route Protection


Todas rotas passam:


```text

Request

↓

JWT Validation

↓

Permission Check

↓

UseCase

↓

Repository

↓

RLS

```


---

# 8. API Security


Framework:


FastAPI


---

Obrigatório:


Pydantic DTO Validation


Rate Limiting


CORS Restrito


Request Size Limit


Error Sanitization


---

# Input Validation


Nunca confiar:


JSON


Query Params


Headers


Uploads


---

# API Errors


Nunca retornar:


```text
SQL Error


Stack Trace


Internal Path

```


---

Retornar:


```json
{
"error":"ACCESS_DENIED"
}
```


---

# 9. CORS Policy


Permitido:


```text
app.lawrence.com


admin.lawrence.com

```


---

Proibido:


```text
Access-Control-Allow-Origin: *
```


---

# 10. Database Security


Banco:


Supabase PostgreSQL


---

Obrigatório:


Row Level Security


Todas tabelas sensíveis.


---

Default:


```text
DENY ALL
```


---

Permitir somente por policy.


---

# RLS Example


Aluno acessa somente dados próprios.


Professor somente seus cursos.


Admin conforme permissão.


---

# 11. Data Protection


Dados em trânsito:


HTTPS


TLS


---

Dados sensíveis:


Criptografados


---

Nunca armazenar:


senha


cartão


token externo


---

# 12. Media Security


Conteúdo premium é ativo crítico.


---

# Zero MP4 Policy


Nunca:


```text
/video/aula.mp4
```


---

Sempre:


```text
HLS

+

Token

+

Validação assinatura

```


---

# Video Pipeline


```text

Upload


↓

Worker


↓

FFmpeg


↓

HLS


↓

Storage


↓

Signed URL

```


---

# Android Offline Security


Vídeos baixados:


Sandbox privado


Arquivos criptografados


---

Nunca:


Galeria


Download público


---

# Screen Protection


Android:


FLAG_SECURE


para reduzir captura de tela.


---

# Watermark


Adicionar:


user


timestamp


session


Objetivo:


Rastreabilidade.


---

# 13. Payment Security


Gateway:


Stripe


Mercado Pago


---

Regra:


Nunca armazenar cartão.


---

Fluxo:


```text

Frontend


↓

Gateway


↓

Token


↓

Backend

```


---

Salvar:


payment_id


subscription_id


status


---

Nunca salvar:


CVV


Número cartão


---

# 14. Subscription Security


Regra:


1 Curso = 1 Assinatura


---

Antes de liberar aula:


validar:


```text
User

+

Course

+

Subscription ACTIVE

```


---

# 15. AI Security


IA é contexto separado.


---

AI nunca acessa:


pagamentos


tokens


senhas


---

# Prompt Protection


Mitigar:


Prompt Injection


Data Leakage


Context Escape


---

# AI Pipeline


```text

Request


↓

Filter


↓

AI Worker


↓

Validation


↓

Response

```


---

# AI Logs


Nunca salvar:


dados pessoais completos.


---

# 16. Privacy Compliance


Seguir:


LGPD


GDPR


---

# Dados coletados


Nome:


certificado


---


Email:


login


---


Histórico:


aprendizado


---


Pagamento:


somente referência gateway


---

# Data Rights


Usuário pode:


exportar dados


alterar


excluir conta


---

# 17. Account Deletion


Fluxo:


```text

Request delete


↓

Cancelar assinaturas


↓

Remover Auth


↓

Anonimizar histórico

```


---

Não apagar:


pagamentos legais


auditoria


---

# 18. Secrets Management


Nunca:


```text
.env no git
```


---

Usar:


GitHub Secrets


Cloud Secrets


Environment Variables


---

Secrets:


SUPABASE_SERVICE_KEY


JWT_SECRET


PAYMENT_SECRET


AI_KEYS


---

# 19. Admin Security


Ações críticas exigem:


Senha


MFA


Confirmação


Audit Log


---

Exemplos:


Excluir usuário


Alterar permissão


Liberar curso manual


Reembolso


---

# 20. Audit Trail


Registrar:


Quem


Quando


O que mudou


IP


Antes/depois


---

Tabela:


audit_logs


---

Regra:


Append Only


Nunca editar.


---

# 21. Logging Security


Permitido:


```json
{
"user_id":"uuid",
"action":"login"
}
```


---

Proibido:


```json
{
"password":"123",
"token":"jwt"
}
```


---

# 22. Infrastructure Security


Containers:


não root


imagem mínima


atualizados


---

Deploy:


CI/CD


Security Scan


Dependency Check


---

# 23. Security Testing


Obrigatório:


SAST


Dependency Scan


Secret Scan


OWASP ZAP


API Tests


---

Antes de produção:


Pentest recomendado


---

# 24. Incident Response


Classificação:


## SEV-1


Vazamento dados


Sistema comprometido


Resposta imediata.


---


## SEV-2


Falha parcial segurança


Correção prioritária.


---


## SEV-3


Melhoria preventiva.


---

# 25. Monitoring


Monitorar:


tentativas login


erros permissão


alteração admin


uso suspeito


falhas pagamento


---

# 26. Security Checklist


Antes do deploy:


✔ RLS ativo


✔ HTTPS ativo


✔ Secrets protegidos


✔ Admin MFA


✔ Logs seguros


✔ Rate limit


✔ Backup ativo


✔ Dependências verificadas


---

# Final Security Rules


Frontend nunca decide autorização.


Banco nunca fica aberto.


Vídeo nunca é público.


Admin nunca age sem auditoria.


IA nunca acessa dados fora do contexto.


Segurança sempre vence conveniência.
