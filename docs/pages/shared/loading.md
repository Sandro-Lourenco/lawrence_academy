---
id: SHARED-001
name: Loading System
path: /shared/loading
type: Shared Component
platforms:
  - Web
  - Android
usage:
  - Public Pages
  - Student Dashboard
  - Teacher Dashboard
  - Admin Dashboard

framework:
  frontend: Flutter
  state_management: Riverpod
  animations: Flutter Animations

design-system: Lawrence Design System
style:
  minimal: true
  liquid_glass: true
  apple_inspired: true
  skeleton_first: true
---

# Loading System

## Objetivo

O **Loading System** define todos os padrões de carregamento utilizados dentro da Lawrence Academy.

Nenhuma página deve utilizar carregamentos genéricos.

O objetivo é criar uma experiência premium onde o usuário percebe:

- Velocidade
- Fluidez
- Continuidade
- Confiança

Inspirado em:

- Apple iOS
- Apple VisionOS
- Linear
- Notion
- YouTube
- Netflix

---

# Princípios

Nunca mostrar:

```text
Tela branca vazia

Loading infinito

Spinner sem contexto
```

Sempre utilizar:

```text
Skeleton

↓

Progressivo

↓

Conteúdo real
```

---

# Estratégia Principal

## Skeleton First

Fluxo:

```text
Request

↓

Render Skeleton

↓

Carrega Dados

↓

Fade Transition

↓

Render Conteúdo
```

---

# Tipos de Loading

A plataforma possui:

```text
Skeleton Loading

Page Loading

Button Loading

Upload Loading

Video Loading

Processing Loading

Pull Refresh

Infinite Scroll
```

---

# 1. Page Loading

Usado em:

- Dashboard
- Cursos
- Perfil
- Analytics
- Admin

---

Visual:

```
Glass Header

██████████

████ ████

████████████

██████
```

---

Características:

- Mantém layout final
- Evita mudança brusca
- Carrega em blocos

---

# Skeleton Component

## SkeletonCard

Propriedades:

```dart
SkeletonCard(
 height,
 width,
 radius
)
```

---

# Estilo

Background:

```text
#E8E8ED
```

Highlight:

```text
#F5F5F7
```

Radius:

```text
16px - 24px
```

---

# Animação Shimmer

Duração:

```text
1200ms
```

Loop:

true

Motion:

Soft Linear

---

# 2. Button Loading

Antes:

```text
Publicar Curso
```

Depois:

```text
○ Publicando...
```

---

Regras:

- Mantém tamanho botão
- Desativa clique
- Bloqueia múltiplos envios

---

# Estados

```text
idle

loading

success

error
```

---

# 3. Upload Loading

Usado:

- Upload vídeo
- Upload material
- Foto perfil

---

Visual:

```text
Arquivo.mp4

████████ 75%

3 minutos restantes
```

---

Mostrar:

- Porcentagem
- Velocidade
- Tempo restante
- Status

---

Estados:

```text
Preparando

Enviando

Processando

Convertendo

Finalizando

Completo
```

---

# 4. Video Loading

Player:

Nunca exibir tela preta.

Fluxo:

```text
Thumbnail

↓

Blur Placeholder

↓

Buffer

↓

Play
```

---

Estados:

Buffer

Qualidade mudando

Reconectando

Erro

---

# 5. Processing Loading

Para processos demorados:

Exemplo:

Conversão HLS

Relatórios

Exportação

---

Mostrar etapas:

```text
Preparando arquivo

✓ Upload

→ Convertendo vídeo

○ Gerando thumbnail
```

---

# 6. Pull Refresh

Mobile.

Comportamento:

Puxar tela.

Feedback háptico.

Refresh.

---

Animação:

Spring

---

# 7. Infinite Scroll

Utilizado:

- Cursos
- Usuários
- Pagamentos
- Logs

---

Fluxo:

```text
Lista

↓

Último item

↓

Skeleton Items

↓

Novos dados
```

---

# Liquid Glass Loading

Permitido em:

- Loading Overlay
- Modal Loading
- Processing Floating Card

---

Exemplo:

```text
Blur 20px

Opacity 72%

Border White 20%
```

---

Não usar Glass em:

Skeleton

Cards principais

Texto

---

# Global Loading Overlay

Usado somente ações críticas.

Exemplo:

Pagamento.

---

Visual:

```text
-------------------

Liquid Glass Card


Processando pagamento...


-------------------
```

---

# Empty Loading Prevention

Se API > 300ms:

mostrar Skeleton.

Se < 300ms:

troca direta.

---

# Error State

Quando falha:

Mostrar:

Mensagem humana.

Nunca:

```text
Error 500
```

---

Exemplo:

```text
Não conseguimos carregar seus cursos.

Tentar novamente
```

---

# Offline Loading

Detectar conexão.

Mostrar:

```text
Você está offline.

Mostrando dados salvos.
```

---

# Providers

```dart
loadingProvider

networkStateProvider

uploadProgressProvider

processingProvider

refreshProvider
```

---

# Components

```text
SkeletonCard

SkeletonList

SkeletonGrid

LoadingButton

ProgressCircle

UploadProgress

ProcessingCard

GlassLoadingOverlay

RefreshIndicator

InfiniteLoader
```

---

# Flutter Packages

Recomendados:

```yaml
shimmer:

flutter_animate:

lottie:

riverpod:

connectivity_plus:
```

---

# Motion Guidelines

## Entrada

Fade

```text
200ms
```

---

## Saída

Fade Out

```text
150ms
```

---

## Skeleton

```text
1200ms loop
```

---

## Progress

Spring Animation

---

# Performance

Obrigatório:

60 FPS

GPU friendly

Sem rebuild desnecessário

---

Usar:

Riverpod Select

Const Widgets

Cache

Lazy Render

---

# Responsividade

## Desktop

Skeleton segue grid real.

---

## Tablet

Adapta colunas.

---

## Mobile

Skeleton vertical.

Safe Area.

---

# Acessibilidade

Suporte:

TalkBack

VoiceOver

Reduce Motion

Screen Reader

---

Labels:

```text
Carregando conteúdo
```

---

# Segurança UX

Não mostrar:

- Dados antigos como novos
- Progresso falso
- Loading infinito

---

# Psicologia de Produto

## Percepção de velocidade

Skeleton faz o usuário sentir que a tela já carregou.

---

## Confiança

Mostrar etapas evita ansiedade.

---

## Continuidade

Nunca trocar drasticamente o layout.

---

## Controle

Processos longos precisam informar progresso.

---

# Critérios de Aceitação

- Nenhuma página deve abrir vazia.
- Todas as páginas usam Skeleton antes dos dados.
- Loading deve respeitar Lawrence Design System.
- Liquid Glass usado somente em overlays/flutuantes.
- Uploads mostram progresso real.
- Processos longos mostram etapas.
- Deve funcionar offline quando possível.
- Deve manter animações em 60 FPS.
- Compatível com Flutter Web e Android.