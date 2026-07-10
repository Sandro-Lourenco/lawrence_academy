---
version: 2.0.0
name: Performance-Optimization-Spec
type: Performance Engineering Specification

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

storage:
  provider: Supabase Storage

architecture:
  - Clean Architecture
  - Domain Driven Design
  - Offline First
  - Event Driven Workers

performance_strategy:
  - Cache First
  - Lazy Loading
  - Async Processing
  - Database Optimization
  - Observability
---

# Lawrence Academy
# Performance Optimization Specification


# 1. Objetivo


Este documento define as regras de performance da plataforma.


A performance deve garantir:


- carregamento rápido
- baixo consumo de bateria
- baixo consumo de dados móveis
- experiência premium
- escalabilidade


Performance é requisito de produto.


Não é otimização futura.


---

# 2. Performance Principles


Toda implementação deve seguir:


```text
Carregar menos

Processar menos

Transferir menos

Renderizar menos

Medir sempre
```


---


# 3. Performance Targets


Metas oficiais:


## Flutter UI


Obrigatório:


```text
60 FPS
```


Quando disponível:


```text
120 FPS
```


---


## API Latency


P95:


```text
< 300ms
```


Endpoints críticos:


```text
<150ms
```


---


## App Startup


Cold Start:


```text
< 2 segundos
```


Warm Start:


```text
< 500ms
```


---


## Search


Resposta:


```text
< 200ms
```


---


## Video Start


Time To First Frame:


```text
< 500ms
```


---


# 4. Frontend Performance Architecture


Flutter usa:


```text
UI

↓

Riverpod

↓

Repository

↓

Cache

↓

API
```


---


Nunca:


```text
Tela

↓

API direta
```


---

# 5. Flutter Rendering Rules


## Widgets


Obrigatório:


usar:


```dart
const Widget
```


quando possível.


---


Evitar rebuild global.


Errado:


```text
Atualiza App inteiro
```


Certo:


```text
Atualiza componente afetado
```


---


# Riverpod Optimization


Usar:


```dart
ref.watch(provider.select())
```


Para observar somente campos necessários.


---

# 6. Liquid Glass Optimization


Componentes Liquid Glass:


- Navigation
- Player Controls
- Dialog
- Bottom Sheet


Obrigatório:


```dart
RepaintBoundary(
 child: GlassComponent()
)
```


---


Motivo:


Evita recalcular blur em cada frame.


---

Nunca usar Liquid Glass em:


- listas grandes
- cards repetidos
- textos


---

# 7. List Performance


Obrigatório:


Usar:


```dart
ListView.builder

SliverList

SliverGrid
```


---


Proibido:


```dart
Column(
 children: hugeList.map()
)
```


---

# 8. Image Optimization


Formato padrão:


```text
WebP
```


---


Obrigatório:


Resize no servidor.


Cache no cliente.


Lazy Loading.


---

Flutter:


```dart
CachedNetworkImage(
 memCacheWidth: 600
)
```


---

Nunca carregar:


Imagem 4K em card pequeno.


---

# 9. Flutter Web Optimization


Obrigatório:


Tree Shaking


Minification


Deferred Loading


Image Optimization


Font Optimization


---

# Web Performance Goals


LCP:


```text
< 2.5s
```


CLS:


```text
< 0.1
```


INP:


```text
< 200ms
```


---

# 10. Network Strategy


Regra:


Nunca buscar dados sem necessidade.


---

# Payload Optimization


Proibido:


```sql
SELECT *
```


---


Usar DTO específico:


CourseCardDTO:


```json
{
"id",
"title",
"thumbnail",
"price"
}
```


---

Não retornar:


```json
lessons[]

reviews[]

comments[]
```


quando não necessário.


---

# 11. Pagination Strategy


Todas listas grandes usam:


Cursor Pagination.


---


Exemplo:


```http
GET /courses?cursor=abc&limit=20
```


---


Não usar:


OFFSET infinito.


---

# 12. Cache Architecture


Camadas:


```text
Memory Cache

↓

Hive Cache

↓

SQLite

↓

API

↓

Database
```


---

# Strategy


Usar:


Stale While Revalidate


Fluxo:


```text
Mostrar cache

↓

Atualizar background

↓

Atualizar UI
```


---

# 13. Offline Performance


Android usa:


SQLite


Hive


---


SQLite:


Guardar:


- progresso
- aulas baixadas
- fila sync


---


Hive:


Guardar:


- preferências
- cache rápido


---

# Sync Engine


Processar em lote.


Batch:


```text
100 eventos
```


Retry:


Exponential Backoff


---

# 14. FastAPI Performance


API deve:


- ser stateless
- validar rápido
- paginar tudo
- nunca processar tarefas longas


---

Errado:


```text
Request

↓

Processa vídeo

↓

Retorna

```


---

Certo:


```text
Request

↓

Queue

↓

Worker

```


---

# 15. Database Performance


PostgreSQL deve usar:


Indexes


Views


Materialized Views


Query Analysis


---

# Index Strategy


Obrigatório indexar:


FK


Search


Created_at


Status


---

Exemplo:


```sql
CREATE INDEX idx_courses_status
ON courses(status);
```


---

# 16. Search Optimization


Usar:


PostgreSQL Full Text Search


GIN Index


pg_trgm


---

Exemplo:


```sql
CREATE EXTENSION pg_trgm;
```


---

# 17. Dashboard Optimization


Nunca:


20 joins no carregamento.


---


Usar:


Read Models


Views


Exemplo:


```sql
student_dashboard_view
```


---

# 18. Video Streaming Performance


Vídeo usa:


HLS


Adaptive Bitrate


---

Nunca:


MP4 público


---

Pipeline:


```text
Upload

↓

Worker

↓

FFmpeg

↓

HLS

↓

Storage CDN

```


---

# HLS Optimization


Criar:


480p

720p

1080p


Player escolhe automaticamente.


---

# 19. Worker Performance


Workers:


Video Worker


AI Worker


Notification Worker


---


Controlar:


tempo


memória


fila


falhas


---

# 20. AI Performance


Nunca chamar IA direto da tela.


Fluxo:


```text
User Event

↓

Queue

↓

AI Worker

↓

Cache Result

↓

Database

```


---

Controlar:


tokens


custo


tempo


---

# 21. Monitoring


Obrigatório medir:


## Backend


API latency


Errors


CPU


Memory


---


## Database


Slow queries


Locks


Connections


---


## Flutter


Frame drops


Crashes


Memory usage


---

Ferramentas:


Sentry


Supabase Logs


Flutter DevTools


---

# 22. Performance Testing


Backend:


k6


pytest benchmark


---


Database:


EXPLAIN ANALYZE


---


Flutter:


Performance Overlay


DevTools


---

# 23. Performance Budget


## Mobile


RAM:


```text
<300MB
```


---


## API Response


JSON:


```text
Preferir <100KB
```


---


## Images


Card:


```text
<200KB
```


---

# 24. Alerts


Gerar alerta quando:


API > 500ms


Erro > 1%


Worker parado


Fila crescendo


Crash aumentando


---

# 25. Final Rules


Nunca otimizar sem medir.


Nunca carregar dados invisíveis.


Nunca bloquear UI.


Nunca executar processo pesado na API.


Sempre usar cache.


Sempre paginar.


Sempre monitorar.


Performance é uma feature.
