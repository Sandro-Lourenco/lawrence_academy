---
id: SHARED-006
name: Bottom Sheet System
path: /shared/bottom-sheet
type: Shared Component
platforms:
  - Web
  - Android
design-system: Lawrence Design System
style:
  minimal: true
  liquid_glass: true
  apple_inspired: true
---

# Bottom Sheet System

## Objetivo

O **Bottom Sheet System** define o padrão de painéis inferiores usados na Lawrence Academy.

Bottom Sheets são usados principalmente no **Android**, para ações rápidas, filtros, menus, seleção de opções e fluxos curtos.

A experiência deve ser inspirada no iOS, Android moderno e Apple VisionOS, com sensação de profundidade, leveza e foco.

---

# Quando Usar

Usar Bottom Sheet para:

- Filtros
- Menus de ação
- Seleção de categoria
- Seleção de curso
- Seleção de pagamento
- Confirmações simples
- Compartilhamento
- Configurações rápidas
- Detalhes rápidos
- Chat de live no mobile
- Materiais da aula
- Opções do player

---

# Quando Não Usar

Não usar Bottom Sheet para:

- Formulários longos
- Criação completa de curso
- Correção complexa
- Edição administrativa crítica
- Fluxos com muitas etapas
- Dados financeiros sensíveis extensos

Nesses casos, usar **Full Screen Dialog**.

---

# Estrutura Visual

```text
Overlay

↓

Liquid Glass Sheet

↓

Drag Handle

↓

Header

↓

Content

↓

Actions
```

---

# Liquid Glass

Aplicar no container do Bottom Sheet.

Configuração:

```text
Blur: 20px
Opacity: 72%
Background: rgba(255, 255, 255, 0.72)
Border: 1px solid rgba(255, 255, 255, 0.28)
Radius Top: 28px
```

---

# Overlay

Fundo atrás do Bottom Sheet:

```text
Dim: 20%
Blur: 8px
```

Nunca usar fundo preto pesado.

---

# Alturas

## Small

```text
30% da tela
```

Uso:

- Menu rápido
- Compartilhar
- Ações simples

---

## Medium

```text
60% da tela
```

Uso:

- Filtros
- Configurações
- Listas curtas

---

## Large

```text
90% da tela
```

Uso:

- Detalhes
- Seleções longas
- Chat
- Materiais

---

# Drag Handle

Sempre exibir no topo.

Tamanho:

```text
36px x 4px
```

Cor:

```text
#D2D2D7
```

Radius:

```text
999px
```

---

# Header

Pode conter:

- Título
- Descrição curta
- Botão fechar
- Ação secundária

Exemplo:

```text
Filtros

Escolha como deseja encontrar seus cursos.
```

---

# Content

Conteúdo deve ser simples.

Elementos permitidos:

- Lista
- Chips
- Switches
- Radio buttons
- Checkboxes
- Cards compactos
- Search input
- Slider
- Date picker

---

# Actions

Quando existir ação final:

```text
Cancelar

Aplicar
```

Botão principal sempre à direita ou fixo inferior.

---

# Tipos de Bottom Sheet

```text
Action Bottom Sheet
Filter Bottom Sheet
Selection Bottom Sheet
Payment Bottom Sheet
Share Bottom Sheet
Player Options Bottom Sheet
Live Chat Bottom Sheet
Confirmation Bottom Sheet
```

---

# Action Bottom Sheet

Usado para menus rápidos.

Exemplo:

```text
Editar

Duplicar

Compartilhar

Excluir
```

Ação destrutiva sempre em vermelho.

---

# Filter Bottom Sheet

Usado em:

- Catálogo
- Meus cursos
- Atividades
- Pagamentos
- Relatórios

Deve conter:

- Filtros
- Ordenação
- Botão limpar
- Botão aplicar

---

# Selection Bottom Sheet

Usado para escolher:

- Categoria
- Professor
- Curso
- Idioma
- Qualidade do vídeo
- Velocidade do vídeo

---

# Payment Bottom Sheet

Usado para compra de curso no mobile.

Deve mostrar claramente:

```text
Curso
Valor mensal
Método de pagamento
Renovação
```

Exemplo:

```text
Alta Costura Premium

R$89,90/mês

Renova todo dia 15
```

---

# Subscription Bottom Sheet

Como cada curso possui assinatura própria:

Cancelar assinatura deve mostrar:

```text
Cancelar assinatura deste curso?

Você continuará com acesso até 15/09/2026.
```

---

# Player Options Bottom Sheet

Usado no player mobile.

Opções:

- Qualidade
- Velocidade
- Legendas
- Baixar aula
- Reportar problema

---

# Live Chat Bottom Sheet

Usado em lives no mobile.

Altura:

```text
90%
```

Conteúdo:

- Chat
- Perguntas
- Reações
- Materiais

---

# Confirmation Bottom Sheet

Usado para confirmações simples.

Para ações críticas administrativas, usar Dialog com 2FA.

---

# Comportamento

## Abrir

Animação:

```text
Slide Up + Fade
```

Duração:

```text
280ms
```

Curva:

```text
Spring / easeOutCubic
```

---

## Fechar

Animação:

```text
Slide Down + Fade
```

Duração:

```text
180ms
```

---

# Gestos

Permitir:

- Swipe down para fechar
- Tap overlay para fechar

Bloquear fechamento quando:

- upload em andamento
- pagamento processando
- dados não salvos
- ação crítica

---

# Unsaved Changes

Se o usuário tentar fechar com alterações:

Mostrar confirmação:

```text
Descartar alterações?
```

---

# Estados

## Loading

Mostrar skeleton interno.

---

## Empty

Mostrar Empty State compacto.

---

## Error

Mostrar mensagem curta e botão tentar novamente.

---

## Processing

Bloquear fechamento.

Mostrar progresso real.

---

# APIs

Bottom Sheet não chama API diretamente.

Fluxo correto:

```text
BottomSheet

↓

Controller

↓

UseCase

↓

Repository

↓

API
```

---

# Providers

```dart
bottomSheetProvider
filterBottomSheetProvider
selectionBottomSheetProvider
actionSheetProvider
paymentSheetProvider
```

---

# Componentes

```text
GlassBottomSheet
BottomSheetHeader
BottomSheetHandle
ActionBottomSheet
FilterBottomSheet
SelectionBottomSheet
PaymentBottomSheet
PlayerOptionsSheet
LiveChatSheet
```

---

# Flutter Structure

```text
shared/
  bottom_sheet/
    glass_bottom_sheet.dart
    bottom_sheet_header.dart
    action_bottom_sheet.dart
    filter_bottom_sheet.dart
    selection_bottom_sheet.dart
    payment_bottom_sheet.dart
```

---

# Responsividade

## Android

Bottom Sheet é o padrão principal.

---

## Web Desktop

Preferir Popover, Modal ou Side Panel.

Usar Bottom Sheet apenas em viewport mobile.

---

## Tablet

Pode usar Side Sheet ou Bottom Sheet large.

---

# Performance

- Renderizar sob demanda.
- Evitar listas gigantes sem virtualização.
- Manter animações em 60 FPS.
- Usar cache em filtros recorrentes.
- Evitar rebuild global.

---

# Segurança

Nunca exibir:

- tokens
- dados internos
- stack trace
- URLs privadas
- chaves de pagamento

Ações financeiras devem sempre confirmar:

- curso
- valor
- recorrência
- método

---

# Acessibilidade

Obrigatório:

- Focus Trap
- Fechamento por ESC no Web
- TalkBack
- VoiceOver
- Touch Target mínimo 44px
- Labels semânticas
- Ordem correta de leitura

---

# Psicologia de Produto

## Foco

Bottom Sheet concentra a atenção sem tirar o usuário totalmente do contexto.

---

## Controle

O usuário entende que ainda está na mesma página.

---

## Rapidez

Ideal para ações rápidas e decisões simples.

---

## Segurança

Ações críticas devem explicar claramente o impacto.

---

# Critérios de Aceitação

- Bottom Sheets devem seguir o Lawrence Design System.
- Devem usar Liquid Glass apenas no container flutuante.
- No Android, Bottom Sheet é padrão para filtros, ações e seleções.
- No Web desktop, preferir modal, popover ou side panel.
- Nenhum Bottom Sheet acessa API diretamente.
- Processos críticos não podem ser fechados acidentalmente.
- Ações destrutivas devem exigir confirmação.
- Deve funcionar com Flutter Web e Android.
- Experiência inspirada em iOS, Android moderno e VisionOS.