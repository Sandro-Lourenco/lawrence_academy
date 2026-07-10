---
id: SHARED-004
name: Offline System
path: /shared/offline
type: Shared Component + Architecture Pattern
platforms:
  - Android
  - Web (limited)

usage:
  - Student Dashboard
  - Teacher Dashboard
  - Admin Dashboard

framework:
  frontend: Flutter
  backend: Python
  state_management: Riverpod
  local_database: SQLite
  cache: Hive
  api: REST
  realtime: Supabase Realtime

design-system: Lawrence Design System

style:
  minimal: true
  liquid_glass: true
  apple_inspired: true
  offline_first: true
---

# Offline System

## Objetivo

O **Offline System** define o comportamento da Lawrence Academy quando o usuário perde conexão com a internet.

A plataforma deve continuar funcionando parcialmente, principalmente no aplicativo Android.

A ausência de internet não deve interromper completamente a experiência.

O usuário deve conseguir:

- Continuar estudando
- Assistir aulas baixadas
- Ler materiais salvos
- Criar alterações locais
- Sincronizar depois

Inspirado em:

- Netflix Downloads
- Spotify Offline
- Apple Photos Sync
- Google Docs Offline
- Notion Offline

---

# Filosofia

Nunca mostrar somente:

```text
Sem conexão.
```

---

Sempre oferecer continuidade:

```text
Você está offline.

Continuamos mostrando conteúdos disponíveis neste dispositivo.
```

---

# Estratégia

Modelo:

```text
Offline First

Local Data

Sync Queue

Conflict Resolver

Cloud Sync
```

---

# Arquitetura

```text
Flutter App


↓

Repository


↓

Local Database

(SQLite/Hive)


↓

Sync Engine


↓

API Python


↓

Supabase
```

---

# Camadas

## Remote Data Source

Responsável por:

- API
- Supabase
- Storage
- Realtime

---

## Local Data Source

Responsável por:

- Cache
- Dados offline
- Downloads
- Fila pendente

---

# Banco Local

Utilizar:

SQLite

Para:

Dados estruturados

---

Hive

Para:

Cache rápido

Configurações

Sessão

---

# Conteúdo Offline

## Disponível

Aluno:

- Cursos baixados
- Aulas baixadas
- Materiais PDF
- Progresso local
- Anotações
- Favoritos

---

Professor:

- Rascunhos
- Dados recentes
- Correções pendentes
- Materiais em fila

---

Admin:

Somente cache leitura.

---

# Downloads de Aulas

Disponível apenas Android.

Fluxo:

```text
Aluno

↓

Baixar Aula

↓

Salvar criptografado

↓

Assistir Offline

↓

Sincronizar progresso
```

---

# Segurança dos Vídeos

Nunca salvar:

MP4 aberto

---

Salvar:

HLS criptografado

Chunks protegidos

Token local

Sandbox App

---

Estrutura:

```text
lesson/

manifest

segments encrypted

metadata
```

---

# Offline Banner

Quando perder internet:

Mostrar:

```text
Modo Offline ativado
```

---

Posição:

Topo

---

Visual:

Liquid Glass

Blur 20px

Opacity 72%

---

# Connection Detection

Usar:

Flutter:

```yaml
connectivity_plus
```

---

Estados:

```text
online

offline

unstable

syncing
```

---

# Sync Engine

Responsável por sincronização.

Fluxo:

```text
Alteração Local

↓

Queue

↓

Internet volta

↓

Enviar

↓

Confirmar

↓

Limpar fila
```

---

# Sync Queue

Guardar:

action

payload

created_at

retry_count

status

---

Exemplo:

```json
{
 "action":"COMPLETE_LESSON",
 "lesson_id":"123",
 "status":"pending"
}
```

---

# Conflitos

Quando local e servidor mudaram:

Estratégia:

```text
Last Write Wins

+
Manual Resolve
```

---

# Exemplos

Aluno concluiu aula offline.

Servidor:

60%

Local:

80%

Resultado:

```text
80%
```

---

# Upload Offline

Quando professor perde conexão:

Upload pausa.

---

Estado:

```text
Upload pausado.

Será retomado automaticamente.
```

---

Quando volta:

Continuar chunk.

---

# Cache Rules

## Cursos

Cache:

30 dias

---

## Perfil

Cache:

7 dias

---

## Configurações

Persistente

---

## Analytics

Não cache crítico

---

# Dados Nunca Offline

Não armazenar:

- Senhas
- Tokens sensíveis
- Dados financeiros completos
- Logs administrativos

---

# Offline Components

```text
OfflineBanner

SyncIndicator

DownloadButton

DownloadManager

OfflineBadge

ConnectionStatus

SyncProgress

ConflictDialog
```

---

# Providers

```dart
connectionProvider

offlineProvider

syncProvider

downloadProvider

localStorageProvider
```

---

# Estados UI

## Online

Normal.

---

## Offline

Mostrar:

Badge discreto.

---

## Sincronizando

```text
Sincronizando alterações...
```

---

## Finalizado

```text
Tudo atualizado.
```

---

## Falha Sync

Mostrar:

```text
Algumas alterações não sincronizaram.
```

Botão:

Tentar novamente

---

# Downloads Page

Mostrar:

Cursos baixados

Espaço usado

Última atualização

---

Exemplo:

```text
Modelagem Premium

12 aulas

850MB

Disponível offline
```

---

# Storage Control

Usuário pode:

Ver espaço

Excluir downloads

Limpar cache

---

# APIs

POST /sync

GET /sync/status

POST /sync/resolve


GET /offline/content

POST /offline/progress

POST /offline/download-token

---

# Backend Python

Criar:

Sync Service

Conflict Resolver

Queue Processor

---

# Supabase

Usar:

Auth

Storage

Database

Realtime

---

Offline:

via cache local

---

# Motion

Quando muda conexão:

Fade

Slide Down

---

Sync:

Progress Animation

---

# Liquid Glass

Aplicar:

- Offline Banner
- Sync Floating Card
- Conflict Dialog

---

Nunca aplicar:

- Dados
- Listas
- Conteúdo

---

# Responsividade

## Android

Suporte completo.

Downloads.

SQLite.

---

## Web

Suporte limitado.

Cache navegador.

Sem download protegido.

---

# Performance

Obrigatório:

Sync em background

Batch requests

Compressão

Lazy Load

Cache inteligente

60 FPS

---

# Segurança

Obrigatório:

Criptografar cache sensível

Sandbox Android

JWT Refresh seguro

Controle expiração

Remover acesso após cancelamento

---

# Regra Assinatura

Como cada curso possui assinatura própria:

Se assinatura expirar:

```text
Bloquear conteúdo offline daquele curso.
```

---

Ao abrir offline:

Verificar última licença válida.

---

# Acessibilidade

WCAG AA

TalkBack

VoiceOver

Mensagens claras

Feedback visual

---

# Psicologia de Produto

## Continuidade

Perder internet não significa parar.

---

## Confiança

Usuário sabe o que está salvo.

---

## Controle

Usuário decide o que manter offline.

---

## Segurança

Conteúdo premium permanece protegido.

---

# Critérios de Aceitação

- Aplicativo Android deve funcionar parcialmente offline.
- Aluno deve assistir aulas baixadas sem internet.
- Vídeos precisam permanecer criptografados.
- Progresso offline deve sincronizar automaticamente.
- Uploads pausados devem continuar depois.
- Sistema deve possuir fila de sincronização.
- Deve detectar conflitos.
- Deve respeitar assinatura individual por curso.
- Deve usar SQLite/Hive localmente.
- Deve integrar com Supabase e backend Python.
- Deve seguir Lawrence Design System.
- Liquid Glass somente em elementos flutuantes.
- Experiência inspirada em Netflix, Spotify e Apple.