---
id: SHARED-005
name: Dialog System
path: /shared/dialogs
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
  navigation: GoRouter
  animation: Flutter Animate

design-system: Lawrence Design System

style:
  minimal: true
  liquid_glass: true
  apple_inspired: true
  adaptive: true
---

# Dialog System

## Objetivo

O **Dialog System** define todos os padrões de janelas, confirmações, modais e interações flutuantes da Lawrence Academy.

Dialogs são utilizados para:

- Confirmar decisões
- Exibir informações importantes
- Executar ações rápidas
- Evitar perda de dados
- Processos críticos

A experiência deve parecer:

**Apple iOS / macOS + VisionOS**

Simples, transparente e focada.

---

# Filosofia

Dialogs nunca devem interromper sem necessidade.

Utilizar somente quando:

- Existe decisão importante
- Existe risco de perda
- Precisa confirmar ação
- Processo precisa de foco

---

# Tipos de Dialog

Sistema possui:

```text
Confirmation Dialog

Alert Dialog

Form Dialog

Action Sheet

Bottom Sheet

Full Screen Dialog

Processing Dialog

Permission Dialog
```

---

# Estrutura Base

```text
Liquid Glass Container

↓

Icon (opcional)

↓

Título

↓

Descrição

↓

Conteúdo

↓

Actions
```

---

# Visual

## Liquid Glass

Configuração:

```text
Blur:

20px


Background:

rgba(255,255,255,0.72)


Border:

1px white 20%


Radius:

28px


Shadow:

Soft
```

---

# Background Overlay

Atrás do dialog:

```text
Blur 12px

Dim 20%
```

---

Nunca usar:

Fundo preto pesado.

---

# Tamanhos

## Desktop

```text
Small:

400px


Medium:

600px


Large:

900px
```

---

## Mobile

Preferir:

Bottom Sheet

ou

Full Screen Dialog

---

# 1. Confirmation Dialog

Usado para confirmar ações.

Exemplo:

Excluir curso.

---

Layout:

```text
Deseja excluir este curso?


Essa ação não poderá ser desfeita.


Cancelar

Excluir
```

---

Regras:

Botão destrutivo sempre separado.

Nunca executar sem confirmação.

---

Usado:

- Excluir usuário
- Cancelar assinatura
- Remover curso
- Reembolso
- Alterar permissões

---

# 2. Alert Dialog

Informação importante.

Exemplo:

```text
Sua assinatura termina em 3 dias.

Atualize o pagamento para continuar.
```

---

Possui:

Uma ação principal.

---

# 3. Form Dialog

Entrada rápida.

Exemplo:

Criar categoria.

---

Campos:

```text
Nome

Descrição

Salvar
```

---

Regras:

- Validar campos
- Preservar dados
- Loading no botão

---

# 4. Action Sheet

Mobile first.

Inspirado iOS.

Uso:

Mais opções.

---

Exemplo:

```text
Editar

Compartilhar

Duplicar

Excluir
```

---

Animação:

Slide Up

Spring

---

# 5. Bottom Sheet

Principal padrão mobile.

Usar:

- Filtros
- Seleções
- Configurações rápidas
- Menu

---

Alturas:

```text
Small 30%

Medium 60%

Full 95%
```

---

# 6. Full Screen Dialog

Usado quando existe fluxo.

Exemplo:

Criar curso.

Upload.

Pagamento.

---

Mobile:

Tela completa.

---

# 7. Processing Dialog

Para processos importantes.

Exemplo:

Pagamento.

---

Visual:

```text
Processando pagamento...


████████


Não feche esta tela.
```

---

Mostrar etapas reais.

---

# 8. Permission Dialog

Quando precisa explicar permissão.

Exemplo:

```text
Permitir notificações?


Receba avisos das suas aulas e lives.
```

---

# Dialog Actions

Sempre:

Primária direita.

Secundária esquerda.

---

Exemplo:

```text
Cancelar        Confirmar
```

---

# Botões

## Primary

Pill Button

Altura:

44px

---

## Secondary

Texto simples.

---

## Destructive

Usar apenas:

Excluir

Cancelar definitivo

Bloquear

---

# Estados

## Loading

```text
Salvando...
```

Bloquear múltiplos cliques.

---

## Success

Fechar automaticamente.

Mostrar Toast.

---

## Error

Manter aberto.

Mostrar erro inline.

---

# Motion

Entrada:

Scale

+
Fade

---

Config:

```text
Duration:

250ms


Curve:

Spring
```

---

Saída:

Fade

150ms

---

# Gesture

Mobile:

Swipe Down fecha:

Somente se não houver dados alterados.

---

Se existir alteração:

Mostrar:

```text
Descartar alterações?
```

---

# Unsaved Changes Dialog

Global.

Quando usuário tenta sair.

---

Mensagem:

```text
Você possui alterações não salvas.

Deseja sair mesmo assim?
```

---

# Payment Dialog

Segurança maior.

Usado:

Compra de curso.

---

Mostrar:

Curso

Valor mensal

Método

Confirmação

---

Exemplo:

```text
Alta Costura

R$89,90/mês


Confirmar assinatura
```

---

# Subscription Dialog

Como cada curso possui assinatura própria.

Cancelar:

Mostrar:

```text
Cancelar assinatura deste curso?


Você terá acesso até:

10/08/2026
```

---

# Admin Critical Dialog

Ações críticas:

Exigem:

Senha

2FA

Confirmação escrita

---

Exemplo:

```text
Digite EXCLUIR para continuar.
```

---

# APIs

Dialogs não chamam API diretamente.

Fluxo:

```text
Dialog

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
dialogProvider

confirmationProvider

bottomSheetProvider

modalStateProvider
```

---

# Components

```text
GlassDialog

ConfirmDialog

AlertDialog

ActionSheet

GlassBottomSheet

ProcessingDialog

PermissionDialog

DeleteDialog

UnsavedChangesDialog
```

---

# Flutter Structure

```text
shared/

dialogs/

    glass_dialog.dart

    confirm_dialog.dart

    bottom_sheet.dart

    action_sheet.dart

    processing_dialog.dart
```

---

# Responsividade

## Desktop

Central Modal.

---

## Tablet

Adaptive Dialog.

---

## Mobile Android

Bottom Sheet.

Full Screen quando necessário.

---

# Performance

Regras:

- Render sob demanda
- Não manter dialogs ocultos
- Evitar rebuild
- 60 FPS

---

# Segurança

Nunca mostrar:

Tokens

Dados internos

Stack Trace

SQL Errors

---

Confirmação obrigatória:

- Financeiro
- Usuários
- Permissões
- Exclusões

---

# Acessibilidade

WCAG AA

Obrigatório:

Focus Trap

Keyboard Navigation

ESC fecha

TalkBack

VoiceOver

---

Touch:

44x44px mínimo

---

# Psicologia de Produto

## Foco

Dialog remove distrações.

---

## Segurança

Confirma decisões irreversíveis.

---

## Clareza

Usuário entende exatamente o impacto.

---

## Elegância

Deve parecer uma camada natural do sistema.

---

# Critérios de Aceitação

- Todos dialogs usam componentes compartilhados.
- Liquid Glass aplicado somente em containers flutuantes.
- Mobile prioriza Bottom Sheets.
- Ações destrutivas exigem confirmação.
- Dados preenchidos não podem ser perdidos sem aviso.
- Dialogs nunca acessam API diretamente.
- Deve seguir Clean Architecture.
- Deve funcionar em Flutter Web e Android.
- Experiência inspirada em Apple iOS, macOS e VisionOS.