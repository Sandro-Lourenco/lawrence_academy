---
id: SHARED-003
name: Error Handling System
path: /shared/error
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
  backend: Python
  state_management: Riverpod
  api: REST
  database: Supabase

design-system: Lawrence Design System

style:
  minimal: true
  liquid_glass: true
  apple_inspired: true
  human_message: true
---

# Error System

## Objetivo

O **Error System** define como todos os erros da Lawrence Academy devem ser tratados, exibidos e recuperados.

Um erro nunca deve parecer uma falha técnica.

Ele deve:

- Explicar o problema.
- Preservar confiança.
- Orientar próxima ação.
- Recuperar automaticamente quando possível.

Inspirado em:

- Apple iOS
- Stripe
- Linear
- Notion
- Airbnb

---

# Filosofia

Nunca mostrar:

```text
Exception Error

500 Internal Server Error

Stack Trace

Undefined
```

Para o usuário.

---

Sempre transformar em:

```text
Algo não carregou corretamente.

Vamos tentar novamente.

[Tentar novamente]
```

---

# Tipos de Erro

A plataforma possui:

```text
Network Error

Server Error

Validation Error

Authentication Error

Permission Error

Payment Error

Upload Error

Video Error

Unknown Error
```

---

# Error Component

Flutter:

```dart
ErrorState(
 title,
 description,
 action,
 errorCode,
)
```

---

# Estrutura Visual

```text
Icon

↓

Título amigável

↓

Descrição

↓

Ação

↓

Código suporte opcional
```

---

# Layout Desktop

```text
-------------------------

        !

 Algo aconteceu


 Explicação


 [Tentar novamente]

-------------------------
```

---

# Mobile

```text
Safe Area

Icon

Mensagem

Botão

```

---

# Tipografia

Título:

```text
Heading M

28px

600 weight
```

---

Descrição:

```text
Body

17px

#6E6E73
```

---

# Liquid Glass

Permitido:

- Error Dialog
- Critical Alert
- Floating Retry

---

Configuração:

```text
Blur 20px

Opacity 72%

Radius 28px
```

---

Não aplicar em:

- Texto
- Código erro
- Logs

---

# Categorias

---

# 1. Network Error

Quando:

Sem internet

Timeout

Servidor inacessível

---

Mensagem:

```text
Não conseguimos conectar.

Verifique sua conexão e tente novamente.
```

CTA:

```text
Tentar novamente
```

---

Ações:

Retry automático

Cache offline

Fila local

---

# 2. Server Error

HTTP:

500

502

503

---

Mensagem:

```text
Estamos com dificuldade para carregar isso.

Tente novamente em alguns instantes.
```

---

Nunca mostrar:

```text
Database Exception
```

---

# 3. Validation Error

Quando:

Campos incorretos.

---

Exemplo:

```text
Este email parece inválido.
```

---

Input:

Borda vermelha

Mensagem abaixo

Foco automático

---

# 4. Authentication Error

Supabase Auth.

Casos:

Token expirado

Login inválido

Sessão encerrada

---

Mensagem:

```text
Sua sessão expirou.

Entre novamente para continuar.
```

CTA:

Login

---

# 5. Permission Error

RBAC / RLS.

Quando:

Usuário sem permissão.

---

Mensagem:

```text
Você não possui acesso a esta área.
```

---

Nunca:

Mostrar dados parciais.

---

# 6. Payment Error

Falha pagamento.

---

Mensagem:

```text
Não conseguimos concluir o pagamento.

Verifique seus dados ou tente outro método.
```

---

Estados:

Cartão recusado

Gateway offline

Pagamento pendente

---

# 7. Subscription Error

Como cada curso possui assinatura própria:

Exemplo:

```text
Sua assinatura deste curso não está ativa.
```

CTA:

```text
Gerenciar assinatura
```

---

# 8. Upload Error

Vídeos

Materiais

Imagem

---

Mostrar:

Motivo:

Arquivo grande

Formato inválido

Conexão perdida

---

Ações:

Tentar novamente

Continuar upload

Cancelar

---

# 9. Video Error

Player HLS.

Estados:

Buffer falhou

Token expirou

Arquivo indisponível

---

Mensagem:

```text
Não conseguimos reproduzir esta aula.

Tente novamente.
```

---

Ações:

Atualizar token

Reconectar

Trocar qualidade

---

# 10. Unknown Error

Fallback global.

---

Mensagem:

```text
Algo inesperado aconteceu.

Estamos trabalhando para resolver.
```

---

# Error Severity

## Low

Toast.

Exemplo:

Falha ao atualizar.

---

## Medium

Inline Error.

Exemplo:

Formulário.

---

## High

Página inteira.

---

## Critical

Modal bloqueante.

---

# Toast Errors

Usar para erros leves.

Exemplo:

```text
Não foi possível salvar.
```

Tempo:

4s

---

# Inline Errors

Inputs.

Exemplo:

```text
Senha precisa ter 8 caracteres.
```

---

# Full Page Error

Quando tela não consegue carregar.

---

Mostrar:

Erro

Descrição

Retry

---

# Retry System

Estratégia:

```text
Erro

↓

Retry 1

↓

Retry 2

↓

Retry 3

↓

Mostrar ação manual
```

---

Tempo:

```text
1s

3s

5s
```

---

# Offline Recovery

Fluxo:

```text
Perde conexão

↓

Mostra cache

↓

Sincroniza depois
```

---

# Error Logging

Registrar:

Frontend

Backend

API

Banco

---

Dados:

Erro

Usuário

Rota

Timestamp

Device

Stack interno

---

Nunca salvar:

Senha

Token

Dados sensíveis

---

# APIs Response Pattern

Formato padrão:

```json
{
 "success": false,
 "error": {
   "code": "PAYMENT_FAILED",
   "message": "Pagamento recusado"
 }
}
```

---

# Error Codes

Padrão:

```text
AUTH_001

PAYMENT_001

COURSE_001

UPLOAD_001

SERVER_001
```

---

# Providers

```dart
errorProvider

networkErrorProvider

apiErrorProvider

validationProvider

globalErrorProvider
```

---

# Components

```text
ErrorState

ErrorPage

ErrorDialog

ErrorToast

InlineError

NetworkError

PaymentError

PermissionError

RetryButton
```

---

# Backend Python

Padronizar:

```python
raise AppException(
 code,
 message
)
```

---

# API Middleware

Responsável por:

Capturar erros

Converter resposta

Gerar logs

Ocultar detalhes internos

---

# Supabase Errors

Converter:

```text
JWT expired
```

Para:

```text
Sessão expirada.
```

---

# Motion

Entrada:

Fade

Slide

---

Duração:

200ms

---

Botões:

Spring Feedback

---

# Responsividade

## Desktop

Inline quando possível.

---

## Mobile

Bottom Sheet

Toast

Full Screen somente crítico.

---

# Performance

Evitar:

Loops infinitos

Rebuild excessivo

Retry agressivo

---

Usar:

Cache

Debounce

Circuit Breaker

---

# Segurança

Nunca mostrar:

SQL Error

Stack Trace

Tokens

Paths internos

Credenciais

---

# Acessibilidade

WCAG AA

Screen Reader

TalkBack

VoiceOver

---

Mensagens devem ser:

Claras

Humanas

Curtas

---

# Psicologia de Produto

## Confiança

Erro deve parecer algo recuperável.

---

## Controle

Sempre oferecer próximo passo.

---

## Transparência

Explicar sem linguagem técnica.

---

## Continuidade

Sempre tentar preservar progresso.

---

# Critérios de Aceitação

- Nenhum erro técnico aparece para usuário final.
- Todos os erros possuem mensagem amigável.
- Deve existir retry automático.
- Uploads devem poder continuar após falha.
- Erros críticos precisam gerar logs.
- Deve integrar com Supabase e backend Python.
- Deve respeitar RBAC e segurança.
- Liquid Glass somente em dialogs/overlays.
- Deve funcionar em Flutter Web e Android.
- Experiência inspirada em Apple, Stripe e Linear.