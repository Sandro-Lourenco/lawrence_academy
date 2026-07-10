````markdown
---
id: PAGE-PUBLIC-006
name: Contact
route: /contact
layout: PublicLayout
platforms:
  - Web
  - Android
roles:
  - Guest
  - Student
authentication: false
responsive: true
status: Production
design-system: Lawrence Design System
seo: true
---

# Contact Page

## Objetivo

A página de Contato é o principal canal de comunicação entre visitantes, alunos e a equipe da Lawrence Academy.

Ela deve oferecer uma experiência simples, elegante e acolhedora, permitindo que qualquer usuário encontre rapidamente o canal de atendimento ideal sem gerar atrito.

A interface deve transmitir profissionalismo, confiança e proximidade, mantendo o minimalismo característico do Lawrence Design System.

---

# Objetivos de Negócio

- Facilitar o contato com a equipe.
- Reduzir abandono por falta de suporte.
- Melhorar a experiência do aluno.
- Direcionar corretamente cada tipo de solicitação.
- Diminuir chamados incorretos.
- Aumentar confiança na marca.

---

# Objetivos do Usuário

O visitante deve conseguir:

- Entrar em contato rapidamente.
- Encontrar o canal correto.
- Enviar mensagens.
- Solicitar suporte.
- Tirar dúvidas comerciais.
- Solicitar parceria.
- Reportar problemas.
- Acompanhar redes sociais.

---

# Layout

Desktop

12 Columns

1440px

Tablet

8 Columns

Mobile

4 Columns

---

# Estrutura

```
Header

↓

Hero

↓

Contact Options

↓

Contact Form

↓

Business Information

↓

Support Categories

↓

Social Media

↓

FAQ Shortcut

↓

Map (Opcional)

↓

Final CTA

↓

Footer
```

---

# Header

Tipo

Sticky

Transparent

Liquid Glass

---

# Hero

## Objetivo

Transmitir proximidade e acolhimento.

---

## Conteúdo

Título

Entre em contato

Subtítulo

Nossa equipe está pronta para ajudar você.

Imagem editorial discreta relacionada à educação, atendimento ou moda.

---

# Contact Options

Grid responsivo.

Desktop

4 Cards

Tablet

2x2

Mobile

1 coluna

---

## Card 01

### Suporte ao Aluno

Ícone

MessageCircle

Descrição

Problemas com cursos, certificados, atividades ou acesso.

Botão

Abrir Atendimento

---

## Card 02

### Comercial

Ícone

ShoppingBag

Descrição

Dúvidas sobre planos, pagamentos e assinatura.

Botão

Falar com Comercial

---

## Card 03

### Parcerias

Ícone

Handshake

Descrição

Professores, empresas e instituições.

Botão

Enviar Proposta

---

## Card 04

### Problemas Técnicos

Ícone

Bug

Descrição

Falhas na plataforma.

Botão

Reportar Problema

---

# Contact Form

## Objetivo

Permitir envio direto de mensagens.

---

## Campos

Nome

Obrigatório

---

Email

Obrigatório

---

Telefone

Opcional

---

Categoria

Dropdown

Valores

Suporte

Pagamento

Cursos

Professor

Parceria

Problema Técnico

Outro

---

Assunto

Obrigatório

---

Mensagem

Textarea

Mínimo

30 caracteres

Máximo

3000 caracteres

---

Anexo

Opcional

Tipos

PDF

PNG

JPG

ZIP

DOCX

---

Checkbox

Aceito a Política de Privacidade

---

Botão

Enviar Mensagem

---

# Business Information

## Informações

Nome da empresa

Lawrence Academy

---

Email

contato@lawrenceacademy.com

---

Suporte

suporte@lawrenceacademy.com

---

Comercial

comercial@lawrenceacademy.com

---

Telefone

(XX) XXXX-XXXX

---

Horário

Segunda a Sexta

08:00 às 18:00

---

Fuso

GMT-3

---

# Support Categories

Cards

Conta

Pagamentos

Cursos

Certificados

Downloads

Aplicativo

Consultorias

Eventos Ao Vivo

---

# Social Media

Instagram

YouTube

Facebook

TikTok

Pinterest

LinkedIn

---

Cada card possui

Ícone

Nome

Descrição

Botão

Abrir

---

# FAQ Shortcut

Card especial.

Título

Ainda possui dúvidas?

Descrição

Consulte nossa Central de Ajuda.

Botão

Ir para FAQ

---

# Map (Opcional)

Caso exista endereço físico.

Google Maps.

Apple Maps.

---

# Final CTA

Título

Estamos prontos para ajudar você.

Botão

Enviar Mensagem

---

# Footer

Institucional

---

# Componentes Utilizados

GlobalHeader

GlassNavigation

HeroSection

ContactCard

InputField

Dropdown

Textarea

UploadField

PrimaryButton

SecondaryButton

SocialCard

FAQCard

Footer

---

# APIs

GET /api/contact

GET /api/contact/categories

POST /api/contact

POST /api/contact/upload

GET /api/social-links

---

# Validação

Nome obrigatório

Email válido

Categoria obrigatória

Assunto obrigatório

Mensagem obrigatória

Aceite da Política obrigatório

Upload limitado

20MB

---

# Fluxo

Visitante

↓

Seleciona categoria

↓

Preenche formulário

↓

Validação

↓

Envio

↓

Mensagem enviada

↓

Email automático

↓

Equipe recebe ticket

---

# Estados

Loading

Skeleton

Offline

Erro

Sucesso

Validação

Upload em andamento

Upload concluído

---

# Mensagem de Sucesso

Título

Mensagem enviada com sucesso.

Descrição

Nossa equipe responderá o mais breve possível.

Botão

Voltar para Home

---

# Segurança

HTTPS obrigatório

Rate Limiting

Google reCAPTCHA

Sanitização de inputs

Proteção contra Spam

Proteção XSS

Proteção CSRF

OWASP Top 10

Validação Backend

---

# SEO

Meta Title

Meta Description

Canonical URL

Open Graph

Twitter Card

Schema.org ContactPage

---

# Motion

Fade In

Card Hover

Smooth Scroll

Button Press

Form Validation Animation

Success Animation

---

# Liquid Glass

Aplicar apenas em

Header

Floating Contact Button

Floating Help Widget

Bottom Sheet (Mobile)

Quick Contact FAB

Nunca aplicar em

Formulário

Cards principais

Conteúdo

Mapa

---

# Responsividade

## Desktop

Cards em Grid

Formulário em duas colunas

Informações laterais

---

## Tablet

Grid reduzido

Formulário centralizado

---

## Mobile

Cards empilhados

Formulário em coluna única

FAB de contato

Bottom Navigation

---

# Analytics

Mensagens enviadas

Categoria mais utilizada

Tempo de preenchimento

Taxa de abandono

Cliques nos contatos

Cliques nas redes sociais

Origem do usuário

---

# Acessibilidade

WCAG AA

Keyboard Navigation

Screen Reader

TalkBack

Labels semânticas

Mensagens de erro acessíveis

Touch Target mínimo 44x44px

Alto contraste

---

# Performance

Lazy Loading

Compressão de imagens

Cache

Validação assíncrona

Upload otimizado

Carregamento progressivo

---

# Critérios de Aceitação

- O formulário deve validar todos os campos antes do envio.
- O usuário deve receber confirmação imediata após o envio.
- O upload deve aceitar apenas formatos permitidos e limitar o tamanho a 20MB.
- O formulário deve ser protegido contra spam e ataques comuns seguindo o OWASP Top 10.
- O layout deve seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve ser utilizado apenas em elementos flutuantes.
- A página deve ser totalmente responsiva para Web e Android.
- Todos os estados (Loading, Offline, Erro e Sucesso) devem estar implementados.
- A experiência deve transmitir confiança, simplicidade e atendimento premium, mantendo a identidade visual da Lawrence Academy.
````
