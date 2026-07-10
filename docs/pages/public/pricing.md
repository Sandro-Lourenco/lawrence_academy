---
id: PAGE-PUBLIC-004
name: Pricing
route: /pricing
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

# Pricing Page

## Objetivo

A página de planos é responsável por converter visitantes em assinantes da Lawrence Academy.

Ela deve transmitir confiança, transparência e alto valor percebido, explicando claramente tudo o que está incluído na assinatura.

A experiência deve lembrar a Apple Store: simples, limpa, elegante e sem excesso de informações.

O usuário nunca deve sentir que está sendo pressionado a comprar.

A página deve responder praticamente todas as dúvidas antes do checkout.

---

# Objetivos de Negócio

- Converter visitantes em assinantes.
- Explicar claramente os benefícios.
- Demonstrar o valor da assinatura.
- Reduzir abandono no checkout.
- Aumentar retenção.
- Destacar vantagens da recorrência.
- Facilitar upgrade de planos.

---

# Objetivos do Usuário

O visitante deve conseguir:

- Entender os planos.
- Comparar benefícios.
- Conhecer formas de pagamento.
- Ver políticas de cancelamento.
- Tirar dúvidas.
- Assinar rapidamente.

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

Pricing Cards

↓

Comparison Table

↓

Included Benefits

↓

Payment Methods

↓

Student Testimonials

↓

FAQ

↓

Guarantee

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

Apresentar de forma clara a proposta da assinatura.

---

## Conteúdo

Título

Aprenda Moda, Costura e Modelagem sem limites.

Subtítulo

Tenha acesso a todos os cursos da plataforma com uma assinatura mensal.

CTA

Assinar Agora

CTA secundário

Explorar Cursos

Imagem editorial premium.

---

# Pricing Cards

## Desktop

2 Cards

Plano Mensal

Plano Anual

---

## Mobile

Cards empilhados.

---

## Card

Título

Preço

Economia

Descrição

Lista de benefícios

Botão Assinar

---

## Plano Mensal

Valor

Mensalidade

Renovação automática

Cancelamento a qualquer momento

---

## Plano Anual

Valor anual

Economia percentual

Badge

Mais Popular

Destaque visual discreto.

---

# Benefícios Inclusos

Acesso ilimitado a todos os cursos

Novos cursos automaticamente

Certificados

Download de materiais

Consultorias

Eventos ao vivo

Comunidade exclusiva

Suporte

Aplicativo Android

Acompanhamento do progresso

Avaliações corrigidas pelo professor

Comentários do professor

Atualizações constantes

---

# Comparison Table

## Colunas

Recurso

Plano Mensal

Plano Anual

---

## Comparações

Cursos ilimitados

Certificados

Downloads

Lives

Consultorias

Comunidade

Suporte

Atualizações

Acesso Mobile

Histórico

Favoritos

Progresso sincronizado

Modo Offline

---

# Payment Methods

Aceitar

Cartão de Crédito

PIX

Google Pay

Apple Pay (futuro)

---

## Segurança

Pagamento criptografado

SSL

PCI DSS

Tokenização

Nunca armazenar dados sensíveis localmente.

---

# Student Testimonials

Carousel

Foto

Nome

Curso

Comentário

Avaliação

---

# Guarantee

Título

Cancele quando quiser.

Descrição

Não existe fidelidade.

Você pode cancelar sua assinatura a qualquer momento mantendo acesso até o final do período contratado.

---

# FAQ

Accordion

Perguntas frequentes

Posso cancelar?

Como funciona?

Tenho certificado?

Posso baixar materiais?

Posso assistir offline?

Como funciona o pagamento?

Existe contrato?

---

# Final CTA

Título

Comece sua jornada hoje.

Botão

Assinar Agora

---

# Footer

Institucional

---

# Componentes Utilizados

GlobalHeader

HeroBanner

PricingCard

ComparisonTable

BenefitList

PaymentMethodCard

ReviewCarousel

Accordion

CTASection

Footer

---

# APIs

GET /api/plans

GET /api/pricing

GET /api/payment-methods

GET /api/faq

POST /api/subscriptions

POST /api/checkout

---

# Fluxos

Visitante

↓

Visualiza planos

↓

Escolhe plano

↓

Checkout

↓

Pagamento

↓

Cadastro (caso necessário)

↓

Assinatura criada

↓

Dashboard

---

# Estados

Loading

Skeleton

Offline

Erro

Plano indisponível

Promoção ativa

Cupom aplicado

---

# Regras de Negócio

O usuário pode navegar pela página sem autenticação.

A assinatura só é criada após confirmação do pagamento.

Os dados de pagamento são solicitados apenas no checkout.

Um usuário pode possuir apenas uma assinatura ativa.

Ao renovar a assinatura, o acesso continua automaticamente.

Ao cancelar, mantém acesso até o fim do ciclo vigente.

---

# Segurança

HTTPS obrigatório

JWT

Rate Limiting

Validação de pagamentos no backend

Webhooks para confirmação

Proteção contra fraude

OWASP Top 10

---

# SEO

Meta Title

Meta Description

Canonical URL

Schema.org Product

Schema.org Offer

Open Graph

Twitter Card

---

# Motion

Fade In

Hero Reveal

Scroll Animation

Card Hover

Scale Animation

Accordion Animation

Smooth Scroll

---

# Liquid Glass

Aplicar apenas em

Header

Floating CTA

Checkout Floating Bar

Bottom Sheet (Mobile)

Quick Actions

Nunca aplicar em

Pricing Cards

Tabela Comparativa

Conteúdo

Benefícios

FAQ

---

# Responsividade

## Desktop

Cards lado a lado.

Tabela comparativa completa.

CTA fixa durante scroll.

---

## Tablet

Cards centralizados.

Tabela adaptada.

---

## Mobile

Cards empilhados.

Tabela transformada em Accordion.

Botão de assinatura fixo na parte inferior.

Bottom Navigation.

---

# Analytics

Visualizações

Plano selecionado

Clique em Assinar

Tempo na página

Cupom aplicado

Conversão

Abandono

Scroll Depth

CTR

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

Screen Reader

Alto Contraste

Touch Target mínimo 44x44px

---

# Performance

Lazy Loading

Compressão de imagens

Cache

Skeleton Loading

Prefetch do Checkout

Carregamento progressivo

---

# Critérios de Aceitação

- A página deve carregar em menos de 2 segundos.
- Os planos devem ser apresentados de forma clara e comparável.
- O checkout deve iniciar com um único clique.
- O botão "Assinar Agora" deve permanecer acessível durante toda a navegação (Sticky CTA no desktop e Bottom CTA no mobile).
- O destaque visual deve ser utilizado apenas para o plano recomendado, sem exageros.
- Todos os estados (Loading, Offline, Erro e Promoções) devem estar implementados.
- O design deve seguir integralmente o Lawrence Design System, utilizando a proporção de cores 60% branco, 30% azul e 10% dourado.
- O efeito Liquid Glass deve ser aplicado exclusivamente em elementos flutuantes.
- A experiência deve transmitir confiança, simplicidade e sofisticação, reforçando a proposta premium da Lawrence Academy.
````
