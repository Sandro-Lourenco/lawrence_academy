---
version: 2.0.0
name: DevOps-Infrastructure
type: DevOps & Cloud Engineering Specification

status: Production Ready

platform:
  frontend:
    - Flutter Web
    - Flutter Android

backend:
  framework: FastAPI
  language: Python

database:
  provider: Supabase
  engine: PostgreSQL

storage:
  provider: Supabase Storage

architecture:
  - Cloud Native
  - Container Based
  - Event Driven Workers
  - Zero Trust Security

devops:
  - Docker
  - GitHub Actions
  - CI/CD
  - Observability
  - Automated Backup
---

# Lawrence Academy
# DevOps & Infrastructure Specification


# 1. Objetivo

Este documento define toda infraestrutura necessária para executar a Lawrence Academy em produção.

Responsável por:

- Ambientes
- Deploy
- Containers
- Workers
- CI/CD
- Segurança
- Monitoramento
- Backup
- Escalabilidade


A infraestrutura deve permitir:

- deploy seguro
- crescimento gradual
- baixo custo inicial
- fácil manutenção


---


# 2. Cloud Architecture Overview


Arquitetura geral:


```text
                USERS


                  ↓


          Flutter Applications


       ┌──────────┴──────────┐

       ↓                     ↓


 Flutter Web           Flutter Android



                  ↓


             HTTPS API


                  ↓


          FastAPI Backend


                  ↓


 ┌───────────┬───────────┬────────────┐


Supabase   Workers      Queue


Postgres   Video        Redis

Auth       AI


Storage



```


---


# 3. Environments


A plataforma possui três ambientes.


---


# Development


Uso:

Programadores.


Características:


- logs completos
- debug ativo
- dados falsos
- banco isolado


Branch:


develop


---


# Staging


Uso:

Validação antes da produção.


Igual produção.


Possui:


- testes finais
- homologação
- dados simulados


Branch:


staging


---


# Production


Usuários reais.


Obrigatório:


- HTTPS
- backups
- monitoramento
- secrets protegidos
- logs estruturados


Branch:


main


---


# 4. Repository Structure


Monorepo recomendado:


```text
lawrence-academy/


 apps/


   mobile/

      Flutter Android


   web/

      Flutter Web



 backend/


   api/

      FastAPI



 workers/


   video-worker/


   ai-worker/


 infrastructure/


   docker/


   github-actions/


 supabase/


   migrations/


 docs/

```


---

# 5. Container Strategy


Todo serviço backend roda em Docker.


Containers:


```text
api


video-worker


ai-worker


redis


monitoring

```


---


# 6. Docker Compose Local


Ambiente completo:


```yaml
version: "3.9"


services:


 api:

  build:

   ./backend/api


  ports:

   - "8000:8000"



 redis:


  image:

   redis:7



 video-worker:


  build:

   ./workers/video-worker



 ai-worker:


  build:

   ./workers/ai-worker


```


Executar:


```bash
docker compose up
```


---

# 7. FastAPI Container


Dockerfile padrão:


```dockerfile

FROM python:3.11-slim


WORKDIR /app


ENV PYTHONDONTWRITEBYTECODE=1

ENV PYTHONUNBUFFERED=1


RUN apt update


COPY requirements.txt .


RUN pip install -r requirements.txt


COPY . .


RUN useradd worker


USER worker


CMD [

"uvicorn",

"main:app",

"--host",

"0.0.0.0"

]

```


---


# 8. Worker Architecture


Processos demorados nunca rodam na API.


Errado:


```text
Request

↓

Processar vídeo

↓

Resposta

```


Correto:


```text
Request


↓

Event


↓

Queue


↓

Worker


↓

Storage


↓

Notification

```


---

# 9. Queue System


Tecnologia:


Redis


Processadores:


Celery


ou


RQ


---


Responsável:


- vídeos
- IA
- emails
- notificações


---


# 10. Video Worker


Responsável:


Converter vídeos.


Pipeline:


```text
Upload


↓

Queue Job


↓

Download temporário


↓

FFmpeg


↓

HLS


↓

Encryption


↓

Supabase Storage


↓

Ready Event

```


---


Entrada:


MP4 temporário


---


Saída:


```text
.m3u8

+

.ts encrypted

```


Nunca armazenar:


MP4 público


---

# Docker Video Worker


Necessário:


```dockerfile
RUN apt update && apt install -y ffmpeg
```


---

# 11. AI Worker


Responsável:


- transcrição
- resumo
- notas inteligentes


Fluxo:


```text
Lesson Uploaded


↓

Extract Audio


↓

Speech To Text


↓

LLM Processing


↓

Save Result

```


---


Controlar:


tokens


custo


tempo


---


# 12. Supabase Infrastructure


Utilizado:


## Auth


Responsável:


- login
- JWT
- MFA


---


## PostgreSQL


Usa:


- RLS
- Triggers
- Functions
- Views


---


## Storage


Armazena:


- HLS
- imagens
- PDFs
- certificados


---

# 13. Database Migrations


Todas mudanças passam por migrations.


Estrutura:


```text
supabase/


 migrations/


 001_auth.sql


 002_courses.sql


 003_payments.sql


```


Nunca alterar banco manualmente.


---

# 14. Environment Variables


Separação obrigatória:


Frontend:


```env
SUPABASE_URL=

SUPABASE_ANON_KEY=

API_URL=
```


---


Backend:


```env
DATABASE_URL=

SUPABASE_SERVICE_ROLE_KEY=

JWT_SECRET=

REDIS_URL=
```


---


Payments:


```env
STRIPE_SECRET_KEY=

STRIPE_WEBHOOK_SECRET=
```


---


AI:


```env
OPENAI_API_KEY=

GEMINI_API_KEY=
```


---


Nunca salvar secrets no Git.


---

# 15. CI/CD Strategy


Ferramenta:


GitHub Actions


---

Fluxo:


```text
Commit


↓

Lint


↓

Tests


↓

Build


↓

Security Scan


↓

Deploy

```


---

# Backend Pipeline


Executa:


```text
ruff

pytest

docker build

deploy

```


---

# Flutter Pipeline


Executa:


```text
flutter analyze

flutter test

flutter build web

flutter build appbundle

```


---

# 16. Deployment


# Frontend Web


Opções:


Cloudflare Pages


Vercel


---


# Backend API


Opções:


Railway


Fly.io


AWS ECS


---


# Mobile


Google Play Console


---

# 17. Feature Flags


Tabela:


feature_flags


Exemplos:


```text
enable_ai


enable_download


enable_live


maintenance_mode

```


Permite liberar recursos sem novo deploy.


---

# 18. Monitoring


Obrigatório:


Sentry


Logs estruturados


Health Check


---


Monitorar:


- erros
- performance
- API latency
- workers
- fila


---

# Health Endpoint


```http
GET /health
```


Response:


```json
{
"status":"healthy"
}
```


---

# 19. Logging Standard


Formato:


JSON


Exemplo:


```json
{
"user":"uuid",

"action":"upload",

"time":"2026-01-01"
}
```


Nunca logar:


- senha
- tokens
- cartões


---

# 20. Security


Obrigatório:


HTTPS


JWT


RBAC


RLS


MFA Admin


Secret Manager


Dependency Scan


---

# Containers


Obrigatório:


Usuário não root


Imagem mínima


Sem secrets internos


---

# 21. Backup Strategy


## Database


Supabase Backup


Point In Time Recovery


---


## Storage


Backup:


- vídeos
- PDFs
- certificados


---


## Disaster Recovery


Definir:


RPO


RTO


---

# 22. Testing Strategy


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

Integration Tests

```


---

# 23. Performance Goals


API:


<300ms


---


Flutter:


60 FPS


---


Worker:


Processamento assíncrono


---

# 24. Scaling Strategy


Fase 1:


Monolito Modular


---


Fase 2:


Separar Workers


---


Fase 3:


Escalar serviços críticos


---

# 25. Final Rules


API nunca processa tarefas pesadas.


Workers sempre usam fila.


Banco sempre usa migrations.


Produção sempre usa CI/CD.


Secrets nunca entram no Git.


Toda mudança crítica gera auditoria.

