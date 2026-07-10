---
id: PAGE-AUTH-002
name: Onboarding
route: /onboarding
layout: FullscreenLayout
platforms:
  - Android
authentication: false
responsive: true
status: Production
design-system: Lawrence Design System
navigation: Swipe + CTA
---

# Onboarding

## Objetivo

O Onboarding é a primeira experiência real do usuário com a Lawrence Academy.

Seu objetivo não é ensinar a usar o aplicativo.

Seu objetivo é vender o sonho.

Nos primeiros segundos o usuário deve entender:

- O que é a Lawrence Academy.
- Como ela pode transformar sua carreira.
- Quais benefícios terá.
- Como começar.

A experiência deve ser extremamente elegante, limpa e inspirada na Apple.

Cada tela possui apenas uma mensagem.

Muito espaço em branco.

Fotografias editoriais.

Motion Design suave.

Liquid Glass apenas nos controles flutuantes.

---

# Objetivos

- Aumentar conversão.
- Reduzir abandono.
- Explicar benefícios.
- Criar conexão emocional.
- Apresentar diferenciais.
- Incentivar cadastro.

---

# Fluxo

```
Splash

↓

Onboarding

↓

Cadastro

↓

Login

↓

Dashboard
```

---

# Quantidade de Telas

5

Cada tela ocupa 100% da tela.

Swipe horizontal.

Indicador inferior.

Botão Continuar.

Botão Pular.

---

# Estrutura

```
Background

↓

Imagem Hero

↓

Título

↓

Descrição

↓

Indicador

↓

Botão

```

---

# Screen 01

## Hero

Fotografia premium.

Pessoa costurando.

Luz natural.

Fundo claro.

---

## Título

Aprenda Costura de um jeito totalmente novo.

---

## Descrição

Cursos completos desenvolvidos por profissionais da moda para você estudar no seu ritmo.

---

## CTA

Continuar

---

# Screen 02

## Hero

Modelagem.

Croquis.

Mesa de trabalho.

Tecidos.

---

## Título

Da modelagem ao acabamento.

---

## Descrição

Aprenda técnicas utilizadas por profissionais da indústria da moda.

---

# Screen 03

## Hero

Aluno assistindo aulas.

Notebook.

Tablet.

Celular.

---

## Título

Estude onde quiser.

---

## Descrição

Continue seus estudos no computador ou no aplicativo Android.

Baixe materiais e acompanhe sua evolução.

---

# Screen 04

## Hero

Certificado.

Professor.

Aluno.

---

## Título

Receba certificados e feedback.

---

## Descrição

Realize atividades, envie projetos e receba comentários personalizados dos professores.

---

# Screen 05

## Hero

Comunidade.

Lives.

Consultorias.

---

## Título

Faça parte da Lawrence Academy.

---

## Descrição

Tenha acesso a novos cursos, eventos ao vivo, consultorias e uma comunidade apaixonada por moda.

---

## CTA Principal

Começar Agora

---

## CTA Secundário

Já tenho uma conta

---

# Layout

Safe Area

Padding

32px

---

# Background

Branco

#FFFFFF

---

# Imagem

65%

Tela

Imagem editorial

Alta resolução

Nunca utilizar ilustrações.

---

# Tipografia

Título

SF Pro Display

34px

Bold

---

Descrição

17px

Regular

---

Botão

17px

Semibold

---

# Navegação

Botão

Continuar

↓

Próxima tela

---

Última tela

↓

Cadastro

---

Botão

Já tenho uma conta

↓

Login

---

Botão

Pular

↓

Cadastro

---

# Indicador

Cinco pontos.

Ponto ativo

Azul

#0A84FF

Demais

Cinza claro.

Animação suave.

---

# Motion

Fade

Scale

Slide

Opacity

Shared Transition

Spring

Blur

Parallax muito leve

---

# Liquid Glass

Aplicar apenas em

Botão Flutuante

Indicador

Bottom Navigation

Nunca aplicar em

Texto

Imagem

Background

---

# Componentes

OnboardingPage

HeroImage

PrimaryButton

SecondaryButton

PageIndicator

GlassButton

OnboardingController

---

# Providers

onboardingProvider

preferencesProvider

themeProvider

---

# Persistência

Ao finalizar:

Salvar

```
onboarding_completed = true
```

Nunca exibir novamente.

Exceto após logout manual ou redefinição.

---

# APIs

Nenhuma obrigatória.

Opcional

GET /api/app/config

---

# Estados

Loading

Offline

Erro

---

# Performance

Pré-carregar imagens.

Lazy Loading.

Cache local.

Animações em 60fps.

---

# Analytics

Usuários que concluíram.

Usuários que pularam.

Tempo médio.

Tela com maior abandono.

Conversão para cadastro.

---

# Acessibilidade

WCAG AA

TalkBack

VoiceOver

Texto escalável

Touch Target

44x44px

Contraste AA

---

# Psicologia de Conversão

## Storytelling

Cada tela apresenta uma evolução natural:

Descobrir

↓

Aprender

↓

Praticar

↓

Receber reconhecimento

↓

Entrar para a comunidade

---

## Regra de Ouro

Uma ideia por tela.

Uma imagem por tela.

Um CTA por tela.

---

## Hierarquia Visual

1. Fotografia
2. Título
3. Descrição
4. CTA

---

# Segurança

Nenhum dado pessoal é solicitado no onboarding.

Nenhuma autenticação é realizada.

Nenhum token é criado.

---

# Critérios de Aceitação

- O onboarding deve possuir exatamente 5 telas.
- Cada tela deve conter apenas uma mensagem principal.
- As transições devem utilizar animações suaves inspiradas na Apple.
- O botão "Pular" deve permanecer disponível em todas as telas.
- O estado de conclusão deve ser salvo localmente para que o onboarding seja exibido apenas uma vez.
- O layout deve seguir integralmente o Lawrence Design System.
- A proporção de cores 60% branco, 30% azul e 10% dourado deve ser respeitada.
- O efeito Liquid Glass deve ser utilizado apenas em elementos flutuantes, como botões e indicadores.
- A experiência deve transmitir sofisticação, leveza e exclusividade, preparando o usuário para entrar na Lawrence Academy.