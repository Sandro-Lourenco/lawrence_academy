---
version: 2.0.0
name: Lawrence-Academy-PED
type: Product Engineering Document

status: Planning

owner:
  product: Product Team
  engineering: Engineering Team
  design: Design Team

platforms:
  web: Flutter Web
  mobile: Flutter Android

technology:
  frontend:
    framework: Flutter
    language: Dart
    state_management: Riverpod
    navigation: GoRouter

  backend:
    language: Python
    framework: FastAPI

  database:
    provider: Supabase
    engine: PostgreSQL

  auth:
    provider: Supabase Auth

  storage:
    provider: Supabase Storage

architecture:
  - Domain Driven Design
  - Clean Architecture
  - Modular Monolith

related_documents:
  - design-system.md
  - architecture.md
  - database.md
  - api.md
  - pages/*
  - shared/*
---

# Lawrence Academy

# Product Engineering Document (PED)


# 1. Executive Summary


## Product Overview

A Lawrence Academy é uma plataforma SaaS educacional premium focada no ensino profissional de:

- Corte
- Costura
- Modelagem
- Alta Costura
- Fashion Design
- Style Design


O produto conecta:

Alunos

+

Professores especialistas

+

Conteúdo estruturado

+

Tecnologia


para criar uma experiência profissional de aprendizado digital.


---

# Product Mission


Democratizar o acesso ao ensino profissional de moda através de uma plataforma moderna, organizada e escalável.


---

# Product Vision


Construir a principal plataforma digital especializada em educação profissional de moda.


A experiência deve unir:


- qualidade de ensino
- experiência premium
- tecnologia moderna
- acompanhamento real do aluno


---

# 2. Problem Statement


## Problemas atuais do mercado


Estudantes encontram:


- cursos espalhados
- falta de metodologia
- pouca prática
- ausência de acompanhamento
- dificuldade em validar conhecimento


---


Professores encontram:


- dificuldade para vender cursos
- dificuldade para gerenciar alunos
- falta de ferramentas profissionais


---

# 3. Solution


A Lawrence Academy resolve isso criando:


- plataforma centralizada
- cursos estruturados
- tarefas avaliativas
- certificados
- acompanhamento de progresso
- comunidade educacional
- monetização para professores


---

# 4. Target Audience


# Student


Perfil:


Iniciante ou profissional buscando evolução.


Objetivos:


- aprender uma profissão
- melhorar habilidades
- receber certificado
- entrar no mercado


Necessidades:


- aulas organizadas
- materiais
- acompanhamento
- feedback


---

# Teacher


Perfil:


Especialista em moda.


Objetivos:


- vender conhecimento
- criar autoridade
- gerar receita recorrente


Necessidades:


- publicar cursos
- gerenciar alunos
- analisar resultados


---

# Admin


Responsável:


- operação
- segurança
- financeiro
- qualidade


---

# 5. Business Model


## Monetization Model


A plataforma utiliza:


Course Based Subscription


---

Cada curso possui sua própria assinatura mensal.


Não existe assinatura única liberando tudo.


---

Exemplo:


Aluno Maria:


Curso Alta Costura

R$89,90/mês


+

Curso Modelagem

R$59,90/mês


=


R$149,80/mês


---

# Revenue Streams


- assinatura mensal por curso

- mentorias

- consultorias

- eventos premium

- certificados adicionais

- parcerias


---

# 6. MVP Scope


# MVP Version 1


Incluído:


## Conta

✔ Cadastro

✔ Login

✔ Perfil


---


## Cursos


✔ Catálogo

✔ Compra

✔ Aulas

✔ Módulos


---


## Ensino


✔ Player

✔ Progresso

✔ Atividades

✔ Certificado


---


## Professor


✔ Criar curso

✔ Upload aulas

✔ Gerenciar alunos


---


## Financeiro


✔ Assinatura mensal

✔ Pagamentos

✔ Cancelamento


---


# Fora do MVP


Versões futuras:


❌ IA recomendação

❌ Comunidade

❌ Marketplace aberto

❌ App iOS

❌ Gamificação avançada


---

# 7. User Journeys


# STUDENT-001

Comprar Curso


Fluxo:


Visitante

↓

Catálogo

↓

Página Curso

↓

Checkout

↓

Pagamento aprovado

↓

Curso liberado


---


# STUDENT-002

Completar Curso


Aluno

↓

Aulas

↓

Atividades

↓

Conclusão

↓

Certificado


---


# TEACHER-001

Criar Curso


Professor

↓

Criar curso

↓

Adicionar módulos

↓

Enviar vídeos

↓

Publicar


---

# 8. Product Requirements


# REQ-001 Authentication


Usuário deve conseguir criar conta e acessar a plataforma.


Prioridade:

MUST


Critério:


Dado um novo usuário

Quando finalizar cadastro

Então uma conta deve ser criada.


---

# REQ-002 Course Purchase


Aluno deve conseguir assinar cursos individualmente.


Prioridade:

MUST


---

# REQ-003 Video Learning


Aluno deve assistir aulas protegidas.


Obrigatório:


- HLS

- Controle de progresso

- Materiais


---

# REQ-004 Assessment


Sistema deve permitir:


- múltipla escolha

- verdadeiro/falso

- discursiva


---

# REQ-005 Certificate


Certificado liberado quando:


100% progresso

+

aprovação obrigatória


---

# 9. Business Rules


# BR-001


Um curso possui uma assinatura própria.


---

# BR-002


Aluno pode ter múltiplas assinaturas.


---

# BR-003


Cancelar uma assinatura remove somente aquele curso.


---

# BR-004


Aluno mantém acesso até fim do período pago.


---

# BR-005


Vídeos nunca podem ser expostos em MP4 público.


---

# BR-006


Professor acessa somente seus cursos.


---

# 10. Domain Contexts


Arquitetura:


DDD


---


# Auth Context


Responsável:


- login

- sessão

- permissões


---

# User Context


Responsável:


- aluno

- professor

- perfil


---

# Course Context


Responsável:


- cursos

- categorias

- módulos


---

# Lesson Context


Responsável:


- aulas

- materiais

- progresso


---

# Subscription Context


Responsável:


- assinatura

- renovação

- cancelamento


---

# Payment Context


Responsável:


- checkout

- transações

- reembolso


---

# Certificate Context


Responsável:


- emissão

- validação


---

# Notification Context


Responsável:


- push

- email

- alertas


---

# Download Context


Responsável:


Modo offline Android.


---

# 11. Roles And Permissions


## STUDENT


Pode:


- comprar curso

- assistir aulas

- enviar atividades

- baixar materiais


---

## TEACHER


Pode:


- criar cursos

- corrigir alunos

- acompanhar métricas


---

## ADMIN


Pode:


- gerenciar plataforma


---

## SUPER ADMIN


Pode:


- alterar configurações críticas


---

# 12. Technical Overview


# Frontend


Flutter


Architecture:


Clean Architecture


Camadas:


Presentation

Domain

Data


---

# Backend


Python FastAPI


Estrutura:


modules/


core/


infra/


shared/


---

# Database


Supabase PostgreSQL


Recursos:


- RLS

- Functions

- Triggers

- Realtime


---

# Mobile Offline


Android:


SQLite:


- progresso

- aulas baixadas

- fila sync


Hive:


- cache

- preferências


---

# 13. Integrations


## Supabase


Usado para:


Auth

Database

Storage

Realtime


---

## Payment Gateway


Suporte:


Stripe

Mercado Pago


---

## Notifications


Push Notifications


---

# 14. Non Functional Requirements


# NFR-001 Performance


Requisitos:


- Flutter 60 FPS

- API < 300ms

- Lazy Loading


---

# NFR-002 Security


Obrigatório:


JWT

HTTPS

RBAC

RLS

Audit Logs


---

# NFR-003 Availability


Meta:


99.5% uptime


---

# NFR-004 Accessibility


Obrigatório:


WCAG AA


TalkBack


VoiceOver


---

# 15. Analytics Metrics


Medir:


## Produto


Activation Rate

Completion Rate

Retention


---


## Negócio


MRR

ARR

Churn

LTV


---


## Ensino


Aulas concluídas

Certificados emitidos

Engajamento


---

# 16. Technical Risks


# RISK-001

Alto custo de vídeo.


Mitigação:


HLS

Compressão

CDN


---

# RISK-002

Pirateria de conteúdo.


Mitigação:


Criptografia

Tokens temporários


---

# RISK-003

Escalabilidade.


Mitigação:


Arquitetura modular.


---

# 17. Documentation Map


Este documento define:


O QUE construir.


---


Outros documentos:


architecture.md

define:

COMO construir


---


design-system.md

define:

COMO parecer


---


pages/

define:

COMO cada tela funciona


---


shared/

define:

COMPONENTES reutilizáveis


---

# Final Rule


Se existir conflito:


PED vence requisitos de produto.


Architecture vence implementação.


Design System vence interface visual.
