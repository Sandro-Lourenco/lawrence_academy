````markdown

id: PAGE-PUBLIC-005 name: FAQ route: /faq layout: PublicLayout platforms:

* Web

* Android roles:

* Guest

* Student authentication: false responsive: true status: Production design-system: Lawrence Design System seo: true

### FAQ Page

### Objetivo

A página de Perguntas Frequentes tem como objetivo responder as principais dúvidas dos visitantes e alunos antes que eles precisem entrar em contato com o suporte.

Ela deve reduzir objeções de compra, aumentar a confiança na plataforma e facilitar a tomada de decisão.

A experiência deve ser simples, rápida e extremamente clara, seguindo o estilo minimalista da Lawrence Academy.

### Objetivos de Negócio

* Reduzir tickets de suporte.

* Aumentar conversão de assinatura.

* Diminuir abandono no checkout.

* Melhorar retenção.

* Explicar regras da plataforma.

* Aumentar confiança do usuário.

### Objetivos do Usuário

O visitante deve conseguir:

* Entender como funciona a plataforma.

* Saber como comprar.

* Entender a assinatura.

* Saber como cancelar.

* Entender os certificados.

* Entender downloads e offline.

* Saber como funcionam as atividades.

* Encontrar respostas rapidamente.

### Layout

Desktop

12 Columns

1440px

Tablet

8 Columns

Mobile

4 Columns

### Estrutura

### Header

Tipo

Sticky

Liquid Glass

### Hero

### Conteúdo

Título

Perguntas Frequentes

Subtítulo

Encontre rapidamente respostas sobre cursos, assinaturas, certificados, pagamentos e muito mais.

Imagem editorial discreta.

### Search FAQ

Campo de busca central.

Placeholder

Digite sua dúvida...

Busca instantânea.

Autocomplete.

Sugestões.

### Categories

### Chips

Assinatura

Pagamentos

Cursos

Certificados

Downloads

Offline

Atividades

Professores

Conta

Suporte

### FAQ Accordion

Perguntas organizadas por categoria.

Apenas uma resposta aberta por vez.

Animação suave.

### Categoria: Assinatura

### Perguntas

Como funciona a assinatura?

Posso cancelar quando quiser?

Existe fidelidade?

O que acontece quando cancelo?

Posso mudar de plano?

### Categoria: Pagamentos

Quais formas de pagamento são aceitas?

Posso pagar no PIX?

Meu pagamento foi recusado.

Como atualizo meu cartão?

Recebo nota fiscal?

### Categoria: Cursos

Tenho acesso a todos os cursos?

Os cursos possuem certificado?

Os cursos são atualizados?

Posso assistir no celular?

Os cursos ficam disponíveis para sempre?

### Categoria: Certificados

Como recebo meu certificado?

O certificado possui validade?

Posso baixar em PDF?

Como validar o certificado?

### Categoria: Downloads

Posso baixar materiais?

Posso baixar vídeos?

Como funciona o modo offline?

Os downloads expiram?

### Categoria: Atividades

Como funcionam os exercícios?

As questões são corrigidas automaticamente?

O professor pode comentar minhas respostas?

Posso reenviar atividades?

### Categoria: Conta

Como altero meus dados?

Como troco minha senha?

Posso usar a mesma conta em vários dispositivos?

Como excluir minha conta?

### Categoria: Suporte

Como falar com o suporte?

Qual o horário de atendimento?

Quanto tempo demora a resposta?

### Still Need Help

Card de destaque.

Título

Não encontrou sua resposta?

Descrição

Nossa equipe está pronta para ajudar.

Botão

Falar com o Suporte

Botão secundário

Enviar E-mail

### Footer

Institucional

### Componentes Utilizados

GlobalHeader

GlassNavigation

SearchInput

CategoryChip

FAQAccordion

SupportCard

PrimaryButton

SecondaryButton

Footer

### APIs

GET /api/faq

GET /api/faq/categories

GET /api/faq/search

POST /api/support/ticket

### Busca

Pesquisa por:

Pergunta

Resposta

Categoria

Palavras-chave

Sugestões populares.

### Estados

Loading

Skeleton

Offline

Erro

Nenhum resultado

### Empty State

Mensagem

Nenhuma pergunta encontrada.

Botão

Limpar busca

### Navegação

FAQ

↓

Buscar dúvida

↓

Ler resposta

↓

Abrir suporte (se necessário)

### SEO

Meta Title

Meta Description

Canonical URL

Schema.org FAQPage

Open Graph

Twitter Card

Rich Snippets

### Motion

Accordion Animation

Fade

Smooth Scroll

Search Suggestions

Chip Selection

### Liquid Glass

Aplicar apenas em

Header

Search Bar

Floating Support Button

Bottom Sheet (Mobile)

Nunca aplicar em

Accordion

Conteúdo

Cards principais

Respostas

### Responsividade

### Desktop

Accordion centralizado.

Busca larga.

Categorias em linha.

### Tablet

Categorias em múltiplas linhas.

Accordion adaptado.

### Mobile

Busca fixa.

Categorias em scroll horizontal.

Accordion otimizado para toque.

Bottom Navigation.

### Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

Screen Reader

Alto Contraste

Touch Target mínimo 44x44px

Estrutura semântica correta

### Performance

Lazy Loading

Cache

Busca otimizada

Debounce

Skeleton Loading

Carregamento progressivo

### Analytics

Perguntas mais acessadas

Buscas sem resultado

Categoria mais utilizada

Cliques em suporte

Tempo na página

Taxa de resolução

### Critérios de Aceitação

* A busca deve responder em tempo real com debounce.

* O Accordion deve abrir e fechar sem recarregar a página.

* Apenas uma pergunta pode permanecer aberta por vez.

* O estado "Nenhum resultado" deve estar implementado.

* O botão de suporte deve estar sempre acessível.

* O layout deve seguir integralmente o Lawrence Design System.

* O efeito Liquid Glass deve ser utilizado apenas em elementos flutuantes.

* A página deve ser totalmente responsiva.

* O conteúdo deve ser facilmente escaneável e legível em dispositivos móveis.

* A experiência deve transmitir clareza, confiança e simplicidade.

```
