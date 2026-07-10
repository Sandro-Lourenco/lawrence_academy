---
name: optimize-performance
description: "Analisa e otimiza performance em Flutter, Backend, Banco de Dados e Infraestrutura.
category: optimization
risk: medium
source: self
version: 1.0.0

required_personas:
  - flutter-architect
  - backend-architect
  - qa-engineer

optional_personas:
  - security-engineer

stack:
  frontend:
    - Flutter
    - Riverpod
    - GoRouter

  backend:
    - FastAPI
    - Python
    - PostgreSQL
    - Supabase

focus:
  - Mobile Performance
  - API Latency
  - Database Optimization
  - Rendering
  - Memory Usage
  - Caching
---

# Skill: Optimize Performance


# 1. Objetivo


Garantir que o sistema seja:

- rápido;
- escalável;
- econômico;
- eficiente;
- estável;
- pronto para produção.


Performance não é aplicada depois.

Performance faz parte da arquitetura.


---

# 2. Leitura obrigatória


Antes de otimizar:


```text
1. AGENTS.md

2. docs/architecture/SYSTEM_ARCHITECTURE.md

3. docs/performance/PERFORMANCE_OPTIMIZATION_SPEC.md

4. docs/database/DATABASE_SCHEMA.md

5. docs/api/SERVICE_API.md

6. docs/design/design-system.md
```

Nunca otimizar sem entender:

- domínio;
- usuários;
- gargalo real;
- arquitetura.


---

# 3. Processo obrigatório


Sempre seguir:


```text
Medir

 ↓

Encontrar gargalo

 ↓

Criar hipótese

 ↓

Otimizar

 ↓

Comparar resultado

 ↓

Documentar
```


Nunca otimizar baseado apenas em opinião.


---

# 4. Performance Flutter


Toda tela deve buscar:


```text
60 FPS mínimo

120 FPS quando suportado

Baixo consumo de memória

Inicialização rápida
```


---

# 5. Flutter Rendering


Verificar:


```text
Widget rebuilds

Frame drops

Jank

Layout pesado

Imagens grandes

Animações caras
```


Usar:


```dart
const Widget()

RepaintBoundary

ListView.builder

SliverList

SliverGrid

Cached Images
```


Evitar:


```dart
Column(
 children: hugeList.map(...)
)
```


Para listas grandes:

usar:


```dart
ListView.builder()
```


---

# 6. Riverpod Performance


Evitar rebuild global.


Errado:


```dart
ref.watch(userProvider);
```


quando precisa apenas:


```dart
ref.watch(
 userProvider.select(
  (user)=> user.name
 )
);
```


Preferir:


```text
Provider pequeno

Estado imutável

AsyncNotifier

Cache controlado
```


---

# 7. Imagens


Toda imagem deve:


- usar cache;
- possuir tamanho correto;
- ter placeholder;
- carregar progressivamente.


Proibido:


```text
Imagem 4K em thumbnail

Carregar lista inteira

Sem cache
```


---

# 8. Vídeos


Vídeo deve usar:


```text
HLS

Adaptive Bitrate

Streaming

Cache controlado
```


Nunca:


```text
MP4 gigante público

Download completo antes de assistir
```


Fluxo:


```text
Player

 ↓

HLS Stream

 ↓

Cache

 ↓

Controle offline
```


---

# 9. Animações


Toda animação deve:


- ter propósito;
- ser leve;
- respeitar acessibilidade.


Usar:


```text
AnimatedContainer

AnimatedSwitcher

TweenAnimationBuilder

Hero
```


Evitar:


```text
Blur animado pesado

Animação infinita

Rebuild por frame
```


---

# 10. Liquid Glass Performance


Liquid Glass custa processamento.


Usar somente:


```text
Navigation

Dialogs

Player controls

Floating components
```


Obrigatório:


```dart
RepaintBoundary(
 child: GlassWidget()
)
```


Evitar:


```text
Glass em lista

Glass em cards repetidos

Tela inteira com blur
```


---

# 11. Startup Performance


O app deve:


- abrir rápido;
- carregar progressivamente;
- evitar tela branca.


Inicialização:


```text
Splash

↓

Config essencial

↓

UI

↓

Dados secundários
```


Não carregar tudo no boot.


---

# 12. Offline Performance


Usar cache:


```text
Memory Cache

↓

Local Database

↓

Remote API
```


Sincronização:


```text
Background Sync

Delta Sync

Conflict Resolution
```


Evitar:


```text
Baixar tudo sempre
```


---

# 13. API Performance


Metas:


```text
P95 API:
<300ms

Endpoints críticos:
<150ms
```


Toda API deve:


- paginar;
- filtrar;
- limitar payload;
- usar cache quando possível.


Nunca:


```sql
SELECT *
```


---

# 14. FastAPI


Verificar:


```text
async correto

I/O não bloqueante

Connection Pool

Background Tasks
```


Errado:


```python
time.sleep()
```


Correto:


```python
await asyncio.sleep()
```


---

# 15. Banco PostgreSQL


Analisar:


```text
Queries lentas

Índices

Relacionamentos

N+1

Locks
```


Obrigatório:


```sql
EXPLAIN ANALYZE
```


antes de otimizações grandes.


---

# 16. Índices


Criar índices para:


```text
FK

Busca frequente

Filtros

Ordenação
```


Exemplo:


```sql
CREATE INDEX idx_courses_teacher
ON courses(teacher_id);
```


Não criar índice sem motivo.


---

# 17. Paginação


Obrigatório em:


```text
Cursos

Usuários

Logs

Pagamentos

Notificações
```


Preferir:


```text
Cursor Pagination
```


Evitar:


```text
OFFSET gigante
```


---

# 18. Cache Backend


Pode cachear:


```text
Categorias

Catálogo

Configurações

Dados públicos

Dashboard agregado
```


Não cachear sem estratégia:


```text
Permissões

Assinatura

Dados sensíveis
```


Todo cache precisa:


```text
Key

TTL

Invalidation
```


---

# 19. Workers


Processos pesados vão para workers.


Exemplos:


```text
Vídeo FFmpeg

IA

Relatórios

Certificados

Emails
```


API:


```text
Recebe

↓

Cria Job

↓

Worker executa
```


---

# 20. Memory Optimization


Monitorar:


```text
Memory leaks

Objetos grandes

Streams abertas

Controllers não descartados
```


Flutter:


```dart
dispose()
```


quando necessário.


---

# 21. Network Optimization


Reduzir:


```text
Requests

Payload

JSON gigante

Imagens grandes
```


Usar:


```text
Compression

Cache Headers

Pagination
```


---

# 22. Performance Testing


Criar testes para:


```text
Carga

Tempo resposta

Renderização

Memória

Stress
```


Antes de release:


Verificar:


```text
Flutter DevTools

API profiling

Database metrics
```


---

# 23. Checklist Flutter


Antes de aprovar:


```text
[ ] Const usado?

[ ] Lista otimizada?

[ ] Imagens otimizadas?

[ ] Rebuild controlado?

[ ] Providers otimizados?

[ ] Animações leves?

[ ] Sem memory leak?

[ ] Offline eficiente?
```


---

# 24. Checklist Backend


Antes de aprovar:


```text
[ ] Query otimizada?

[ ] Índices corretos?

[ ] Paginação?

[ ] Cache necessário?

[ ] Payload pequeno?

[ ] Worker usado?

[ ] Async correto?
```


---

# 25. Proibido


Nunca aceitar:


❌ Tela travando

❌ Lista renderizando tudo

❌ API lenta sem análise

❌ SELECT *

❌ Upload sem limite

❌ Vídeo bruto

❌ Query sem índice

❌ Cache sem invalidação

❌ Animação prejudicando UX


---

# Regra final


Primeiro:

Faça funcionar.


Depois:

Meça.


Depois:

Otimize.


Performance boa é invisível para o usuário.