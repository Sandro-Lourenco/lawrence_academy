---
id: PAGE-AUTH-004
name: Register
route: /register
layout: AuthLayout
platforms:
  - Web
  - Android
roles:
  - Guest
authentication: false
responsive: true
status: Production
design-system: Lawrence Design System
navigation: Replace
---

# Register

## Objetivo

A tela de Cadastro é responsável por transformar visitantes em alunos da Lawrence Academy.

Ela deve seguir o princípio **Zero Friction Onboarding**, reduzindo ao máximo o atrito durante o primeiro contato.

**IMPORTANTE**

O cadastro **NÃO** solicita informações de pagamento.

O usuário cria apenas sua conta.

As informações financeiras serão solicitadas **somente no Checkout**, quando ele decidir comprar um curso.

Essa estratégia reduz significativamente a taxa de abandono e aumenta a conversão.

A interface deve ser inspirada na Apple ID, Apple Store, Arc Browser e Notion, utilizando bastante espaço em branco, tipografia editorial e animações suaves.

---

# Objetivos

- Criar conta rapidamente.
- Reduzir abandono.
- Aumentar conversão.
- Garantir segurança.
- Coletar apenas informações essenciais.
- Preparar o usuário para a compra do primeiro curso.

---

# Fluxo

```
Splash

↓

Onboarding

↓

Cadastro

↓

Verificação de Email

↓

Login Automático

↓

Dashboard

↓

Primeira Compra

↓

Cadastro dos Dados de Pagamento
```

---

# Layout

## Desktop

Grid

12 Columns

Tela dividida

```
+------------------------------------------------------+

Imagem Editorial (55%)

Cadastro (45%)

+------------------------------------------------------+
```

---

## Mobile

Layout centralizado.

Safe Area.

Rolagem vertical.

Sem imagem de fundo.

---

# Estrutura

```
Background

↓

Glass Header

↓

Logo

↓

Título

↓

Descrição

↓

Cadastro

↓

Aceite dos Termos

↓

Botão Criar Conta

↓

Login Social

↓

Link Login

↓

Footer
```

---

# Background

Desktop

Fotografia editorial.

Costura.

Alta costura.

Ateliê.

Desfocada.

---

Mobile

Branco.

Minimalista.

---

# Header

Logo

Idioma

Tema

Botão Home

Liquid Glass

Blur 20px

Opacity 72%

---

# Logo

Centro superior.

SVG.

Responsivo.

---

# Título

Crie sua conta.

---

# Descrição

Comece gratuitamente e tenha acesso à melhor plataforma de ensino de Costura, Modelagem e Moda.

---

# Campos

## Nome Completo

Obrigatório

Placeholder

Seu nome completo

---

## Email

Obrigatório

Validação em tempo real.

---

## Senha

Obrigatório

Mostrar senha.

Indicador de força.

---

## Confirmar Senha

Obrigatório.

Validação instantânea.

---

# Não solicitar

CPF

Telefone

Endereço

Cartão

Pix

Dados bancários

Documento

Essas informações pertencem ao Checkout.

---

# Password Rules

Mínimo

8 caracteres

Obrigatório

1 letra maiúscula

1 minúscula

1 número

1 caractere especial

Indicador visual

Fraca

Média

Forte

Excelente

---

# Aceite dos Termos

Checkbox

Obrigatório

Texto

Ao criar sua conta você concorda com os Termos de Uso e Política de Privacidade.

---

# Primary CTA

Criar Conta

Botão Pill

52px

Azul

#0A84FF

---

# Social Login

Google

Apple

Microsoft

Opcional.

---

# Login

Texto

Já possui uma conta?

Botão

Entrar

↓

Login

---

# Validação

Nome obrigatório.

Email válido.

Email único.

Senha forte.

Senhas iguais.

Aceite dos termos.

---

# Fluxo de Cadastro

```
Preencher formulário

↓

Validar

↓

Supabase Auth

↓

Criar usuário

↓

Criar Perfil

↓

Enviar Email

↓

Login

↓

Dashboard
```

---

# Banco de Dados

Tabela

users

```
id

name

email

avatar

role

status

created_at

updated_at
```

---

Tabela

profiles

```
id

user_id

photo

bio

country

language

timezone

preferences
```

---

# Dados NÃO cadastrados

Pagamento

Assinatura

Cursos

Certificados

Pedidos

Endereço

Telefone

CPF

Esses dados serão preenchidos futuramente.

---

# APIs

POST /auth/register

POST /auth/email-verification

GET /auth/session

POST /profiles

---

# Providers

authProvider

profileProvider

settingsProvider

themeProvider

---

# Estados

Loading

Erro

Offline

Email já utilizado

Senha fraca

Conta criada

Verificando Email

---

# Email de Verificação

Enviar automaticamente.

Botão

Reenviar Email

Tempo

60 segundos

---

# Segurança

Supabase Auth

JWT

Refresh Token

Rate Limit

OWASP Top 10

HTTPS

CSRF

XSS

SQL Injection Protection

Password Hash

Email Verification

Device Tracking

---

# Motion

Fade

Slide

Scale

Opacity

Blur

Spring

---

# Liquid Glass

Aplicar apenas em

Header

Floating Card Desktop

Bottom Sheet

Modal

Nunca aplicar em

Inputs

Background

Texto

Botões

---

# Tipografia

Título

36px

Bold

SF Pro Display

---

Texto

17px

Regular

---

Inputs

17px

---

Botão

17px

Semibold

---

# Cores

60%

Branco

30%

Azul

10%

Dourado

---

# Responsividade

## Desktop

Imagem lateral.

Formulário central.

Largura máxima

520px

---

## Tablet

Imagem menor.

Mais espaço para formulário.

---

## Mobile

Imagem removida.

Conteúdo ocupa toda largura.

Botão sempre visível.

---

# Performance

Validação local.

Cache.

Pré-carregar Dashboard.

Animações em 60fps.

---

# Analytics

Conversão Cadastro

Tempo médio

Abandono por campo

Login Social

Origem

Funil

---

# Acessibilidade

WCAG AA

TalkBack

VoiceOver

Keyboard Navigation

Touch Target

44x44px

Labels

Focus Visible

---

# Psicologia de Conversão

## Zero Friction

Solicitar apenas:

- Nome
- Email
- Senha

Nada mais.

---

## Compromisso Progressivo

Primeiro criar conta.

Depois explorar cursos.

Somente quando decidir comprar:

- Dados pessoais complementares
- Endereço
- Informações fiscais (quando necessário)
- Dados de pagamento

---

## Segurança

Mostrar discretamente:

✔ Seus dados estão protegidos.

✔ Conexão criptografada.

✔ Você poderá cancelar quando desejar.

---

## Continuidade

Após criar a conta:

Verificar email.

↓

Login automático (quando permitido).

↓

Dashboard vazio.

↓

Sugestão de cursos.

---

# Critérios de Aceitação

- O cadastro deve levar menos de 60 segundos para ser concluído.
- Apenas Nome, Email e Senha devem ser obrigatórios.
- Nenhum dado de pagamento deve ser solicitado nesta etapa.
- A autenticação deve utilizar Supabase Auth.
- O perfil do usuário deve ser criado automaticamente após o registro.
- Deve existir validação em tempo real para todos os campos.
- O botão "Criar Conta" deve permanecer desabilitado até que o formulário seja válido.
- O layout deve seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve ser aplicado apenas em superfícies flutuantes.
- A experiência deve transmitir simplicidade, confiança, sofisticação e baixa fricção, incentivando o usuário a concluir rapidamente seu cadastro.