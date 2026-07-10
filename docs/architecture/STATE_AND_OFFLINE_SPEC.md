---
version: 2.0.0
name: State-And-Offline-Spec
type: State Management & Offline First Architecture Specification

status: Production Ready

platforms:
  - Flutter Web
  - Flutter Android

frontend:
  framework: Flutter
  language: Dart
  state_management: Riverpod 3.x

local_storage:
  cache:
    - Hive

  database:
    - SQLite

  secure_storage:
    - Android Keystore
    - Flutter Secure Storage

architecture:
  - Clean Architecture
  - Feature First
  - Offline First
  - Event Driven Sync

security:
  - Encrypted Local Storage
  - Secure Sandbox
  - HLS Protection
  - DRM Ready Architecture
---

# Lawrence Academy
# State Management & Offline Specification


# 1. Objetivo


Este documento define como a aplicação gerencia:


- estado global
- cache
- persistência local
- modo offline
- sincronização
- download seguro de aulas
- proteção de conteúdo


A aplicação deve funcionar mesmo com internet instável.


Principal foco:


Flutter Android


+


Produtores com conexão limitada


---


# 2. State Architecture Principles


A arquitetura segue:


Unidirectional Data Flow


Nenhuma tela acessa banco ou API diretamente.


Fluxo obrigatório:


```text

Widget

↓

Riverpod Controller

↓

UseCase

↓

Repository Interface

↓

Local / Remote Datasource

↓

SQLite / Supabase

```


---

# Camadas


Presentation:


Flutter UI


Controllers


States


---


Domain:


Entities


UseCases


Repositories


---


Data:


DTO


Models


Local Datasource


Remote Datasource


---

# 3. Riverpod Architecture


Riverpod é responsável por:


- estado de tela
- cache em memória
- injeção de dependência
- controle assíncrono


---

# Provider Rules


Usar:


```text

Notifier


AsyncNotifier


FutureProvider


StreamProvider

```


Evitar:


StatefulWidget segurando regra


Singleton global


Variáveis estáticas


---

# 4. Core Providers


## Auth Provider


Responsável:


- sessão
- usuário atual
- refresh token
- logout


Tipo:


```dart
AsyncNotifier<AuthState>
```


---


# Subscription Provider


Responsável:


Verificar acesso aos cursos.


Estado:


```text
ACTIVE

EXPIRED

CANCELED

PAYMENT_FAILED
```


Usado:


Course Guard


Lesson Guard


Download Guard


---

# Course Provider


Responsável:


- catálogo
- filtros
- busca
- cache


Estratégia:


Stale While Revalidate


Fluxo:


```text

Carrega Cache

↓

Mostra UI

↓

Atualiza API

↓

Atualiza Cache

```


---

# Lesson Player Provider


Controla:


- tempo assistido
- progresso
- conclusão
- favoritos
- notas


Heartbeat:


A cada:


10 segundos


salva progresso.


---

# Offline Queue Provider


Controla:


- downloads
- uploads pendentes
- sincronização


---

# 5. Global State Pattern


Toda tela utiliza:


```text

INITIAL


LOADING


SUCCESS


EMPTY


ERROR


OFFLINE

```


---

Exemplo:


```dart

sealed class PageState<T>{}


Loading()


Success(data)


Failure(error)

```


---

# 6. Cache Architecture


Camadas:


```text

Riverpod Memory


↓

Hive Cache


↓

SQLite Database


↓

FastAPI


↓

Supabase

```


---

# Memory Cache


Responsável:


Estado temporário.


Ex:


- filtros
- tela atual
- player


---

# Hive


Usado para:


- preferências
- tema
- configurações
- cache simples


Não usar:


dados relacionais.


---

# SQLite


Banco offline principal.


Guarda:


- cursos baixados
- aulas
- progresso
- atividades
- fila sync


---

# 7. Offline First Strategy


Regra:


Usuário nunca perde ação.


---

Quando offline:


```text

User Action


↓

Save Local


↓

Update UI


↓

Sync Later

```


---

Quando online:


```text

Sync Queue


↓

Backend


↓

Resolve Conflict


↓

Clear Queue

```


---

# 8. SQLite Local Schema


## Sync Queue


```sql

CREATE TABLE sync_queue(

id TEXT PRIMARY KEY,


action TEXT NOT NULL,


payload TEXT NOT NULL,


status TEXT,


retry_count INTEGER DEFAULT 0,


next_retry_at INTEGER,


created_at INTEGER

);

```


---

Estados:


```text

PENDING


SYNCING


FAILED


COMPLETED

```


---

# Offline Courses


```sql

CREATE TABLE offline_courses(

id TEXT PRIMARY KEY,


course_id TEXT,


student_id TEXT,


downloaded_at INTEGER,


expires_at INTEGER

);

```


---

# Offline Lessons


```sql

CREATE TABLE offline_lessons(

id TEXT PRIMARY KEY,


lesson_id TEXT,


course_id TEXT,


progress INTEGER,


file_path TEXT

);

```


---

# 9. Sync Engine


Responsável:


Sincronizar:


- progresso
- tarefas
- favoritos
- notas


---

# Trigger


Executa quando:


Internet retorna


App abre


Intervalo programado


---

Android usa:


WorkManager


---

# Batch Sync


Enviar:


Máximo:


100 eventos


por lote.


---

# Retry Strategy


Usar:


Exponential Backoff


Exemplo:


```text

1 tentativa


5 segundos


30 segundos


5 minutos


1 hora

```


---

Após limite:


marca FAILED.


---

# 10. Conflict Resolution


Regra:


Nunca perder progresso.


---

# Lesson Progress


Maior progresso vence.


Ex:


Mobile:


80%


Web:


100%


Resultado:


100%


---

# Timestamp


Auditoria:


Server Timestamp vence.


---

# 11. Offline Subscription License


Acesso offline precisa validar assinatura.


---

Fluxo:


```text

Online


↓

Check Subscription


↓

Generate Offline License


↓

Allow Download

```


---

Tabela:


offline_license


Campos:


```text

student_id


course_id


expires_at


last_validation

```


---

Tempo recomendado:


7 dias


Após expirar:


exige conexão.


---

# 12. Secure Offline Video


Política:


Zero Public MP4


---

Nunca:


```text

Downloads/video.mp4

```


---


Usar:


Encrypted HLS Storage


---

# Pipeline


```text

Download HLS


↓

Encrypt Segments


↓

Store Sandbox


↓

Decrypt Memory


↓

Player

```


---

# Storage Location


Android:


```text

/data/data/app/files/

```


Privado.


---

# Encryption


Usar:


AES-256


Chave:


Android Keystore


---

# 13. Local Video Server


Objetivo:


Compatibilidade com player HLS.


---

Fluxo:


```text

Video Player


↓

localhost


↓

Decrypt Stream


↓

Encrypted Files

```


---

Regra:


Nunca salvar arquivo descriptografado.


---

# 14. Background Download


Android:


WorkManager


---

Regras:


Vídeos grandes:


WiFi preferencial


---


Baixa bateria:


pausar


---


Falha:


retomar download


---

# 15. Web Behavior


Flutter Web:


Sem download offline de vídeo.


Permitido:


- cache leve
- sessão
- preferências


---

Bloqueado:


- salvar aulas
- exportar mídia


---

# 16. Android Behavior


Permitido:


Download aulas


Modo avião


Sync posterior


Cache persistente


---

# 17. Repository Pattern


Exemplo:


Lesson Repository


```text

getLesson()


↓


Existe local?


SIM → SQLite


NÃO → API

```


---

# 18. Error Handling


Offline:


Mostrar:


offline-state.md


---


Sync Failed:


Manter fila


Não perder dados


---

# 19. Observability


Monitorar:


```text

cache_hit_rate


offline_users


sync_failed


download_failed


storage_used


sync_time

```


Enviar:


Sentry


Analytics


---

# 20. Testing Strategy


Testar:


Riverpod:


Provider Tests


---


SQLite:


Repository Tests


---


Sync:


Conflict Tests


---


Offline:


Airplane Mode Tests


---

# 21. Storage Limits


Controlar:


Tamanho usado


Cursos baixados


Limpeza automática


---


Usuário pode:


Excluir downloads.


---

# 22. Security Rules


Nunca:


expor MP4


salvar token puro


ignorar assinatura


permitir acesso expirado


---

Sempre:


validar assinatura


criptografar mídia


usar sandbox


usar RLS


---

# Final Rule


Estado pertence ao Riverpod.


Regra pertence ao UseCase.


Dados pertencem ao Repository.


Offline nunca quebra segurança.


Experiência deve continuar mesmo sem internet.
