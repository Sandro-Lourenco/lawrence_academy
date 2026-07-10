---
id: PAGE-TEACHER-013
name: Teacher Profile
route: /teacher/profile
layout: TeacherDashboardLayout
platforms:
  - Web
  - Android
roles:
  - Teacher
authentication: true
responsive: true
status: Production
design-system: Lawrence Design System
navigation: Sidebar + Top Navigation
state-management: Riverpod
architecture: Clean Architecture + DDD
real-time: Supabase Realtime

profile:
  public_profile: true
  instructor_branding: true
  social_links: true
  achievements: true
  statistics: true
  verification: true
---

# Profile

## Objetivo

A página **Teacher Profile** permite que o professor gerencie sua identidade profissional dentro da Lawrence Academy.

O perfil do professor não é apenas uma página de configurações, ele representa sua autoridade, marca pessoal e credibilidade dentro da plataforma.

Essas informações serão utilizadas nas páginas públicas dos cursos, catálogo, certificados, lives e páginas de apresentação.

A experiência deve ser elegante, premium e minimalista, semelhante a um perfil profissional Apple, MasterClass ou LinkedIn.

Inspirado em:

- Apple ID
- MasterClass Instructor Profile
- LinkedIn Creator
- Notion Profile
- Behance

---

# Objetivos

- Editar perfil profissional.
- Construir autoridade.
- Mostrar experiência.
- Gerenciar foto.
- Configurar redes sociais.
- Mostrar conquistas.
- Gerenciar dados pessoais.
- Visualizar perfil público.

---

# Fluxo

```text
Professor

↓

Profile

↓

Editar informações

↓

Preview

↓

Salvar

↓

Perfil público atualizado
```

---

# Layout Desktop

```text
--------------------------------------------------

Glass Header

--------------------------------------------------

Sidebar

|

Profile Preview

|

Profile Information

|

Statistics

--------------------------------------------------
```

---

# Layout Mobile

```text
Glass Header

↓

Foto Perfil

↓

Informações

↓

Estatísticas

↓

Configurações

↓

Bottom Navigation
```

---

# Estrutura

```text
Glass Header

↓

Profile Hero

↓

Public Preview

↓

Personal Information

↓

Professional Information

↓

Biography

↓

Social Links

↓

Achievements

↓

Statistics

↓

Account Settings
```

---

# Glass Header

Sticky

72px

Liquid Glass

Blur 20px

Opacity 72%

---

# Profile Hero

Área principal.

Mostrar:

Foto

Nome

Especialidade

Selo de verificação

Avaliação

Número de alunos

Cursos publicados

---

Exemplo:

```text
Ariane Oliveira

Especialista em Alta Costura

⭐ 4.9

12.400 alunos

8 cursos
```

---

# Profile Image

Upload:

Imagem JPG

PNG

WEBP

---

Recursos:

Cortar

Reposicionar

Remover fundo (Future AI)

Preview

---

Formato:

Circle Avatar

Border Radius 100%

---

# Public Preview

Visualização exatamente como os alunos verão.

Mostrar:

- Foto
- Nome
- Bio
- Cursos
- Avaliações
- Estatísticas
- Redes sociais

---

# Personal Information

Campos:

Nome completo

Nome público

Email

Telefone

Localização

Idioma

---

# Professional Information

Campos:

Título profissional

Área de atuação

Especialidades

Anos de experiência

Formações

Certificações

Empresa/Marca

---

Exemplo:

```text
Especialista em modelagem feminina

15 anos de experiência

Alta Costura
Modelagem
Moda Festa
```

---

# Biography

Editor avançado.

Suporta:

Markdown

Parágrafos

Links

Formatação

---

Sugestão:

```text
Conte sua trajetória, experiência e como você ajuda seus alunos.
```

---

# Expertise Tags

Tags:

Modelagem

Costura

Moda

Design

Alfaiataria

Negócios

Estilo

---

# Social Links

Adicionar:

Instagram

YouTube

TikTok

LinkedIn

Website

Portfólio

---

# Achievements

Mostrar conquistas.

Exemplo:

```text
🏆 10.000 alunos impactados

⭐ Professor 5 estrelas

🎓 1000 certificados emitidos
```

---

# Statistics

Dados públicos.

Mostrar:

Cursos publicados

Total de alunos

Avaliação média

Horas ensinadas

Lives realizadas

Certificados emitidos

---

# Reviews Preview

Mostrar últimas avaliações.

Cada avaliação:

Aluno

Nota

Comentário

Curso

Data

---

# Account Settings

Configurações rápidas:

Senha

Email

Notificações

Privacidade

Segurança

Sessões ativas

---

# Verification

Sistema de verificação.

Campos:

Documento

Formação

Experiência

Certificados

---

Estados:

Não verificado

Em análise

Verificado

---

# APIs

GET /teacher/profile

PATCH /teacher/profile

POST /teacher/profile/avatar

DELETE /teacher/profile/avatar

GET /teacher/profile/statistics

GET /teacher/profile/reviews

POST /teacher/profile/social

GET /teacher/profile/public-preview

---

# Providers

teacherProfileProvider

profileEditProvider

avatarProvider

statisticsProvider

reviewsProvider

socialLinksProvider

verificationProvider

---

# Componentes

GlassHeader

ProfileHero

AvatarUploader

ProfilePreview

PersonalInfoForm

ProfessionalInfoForm

BiographyEditor

SocialLinksCard

AchievementCard

StatisticCard

VerificationCard

SkeletonLoader

Toast

---

# Estados

## Loading

Skeleton Apple Style

---

## Salvando

Mostrar:

```text
Salvando alterações...
```

---

## Salvo

Toast:

```text
Perfil atualizado.
```

---

## Perfil incompleto

Mostrar progresso:

```text
Seu perfil está 75% completo.
```

---

## Erro

Toast

Tentar novamente

---

# Motion

Fade

Slide

Scale

Spring

Avatar Animation

Shared Transition

Blur

Skeleton

---

# Liquid Glass

Aplicar apenas em:

- Glass Header
- Profile Floating Actions
- Preview Modal
- Image Crop Dialog
- Bottom Actions

Nunca aplicar em:

- Formulários
- Texto
- Biografia
- Estatísticas

---

# Tipografia

Hero

36px

Heading

28px

Subheading

22px

Body

17px

Caption

13px

Micro

11px

---

# Cores

60%

White

#FFFFFF

30%

Primary Blue

#0A84FF

10%

Premium Gold

#D4AF37

Success

#30D158

Warning

#FF9F0A

Danger

#FF453A

Text

#1D1D1F

---

# Responsividade

## Desktop

Preview lateral.

Editor principal.

Cards estatísticos.

---

## Tablet

Preview recolhível.

---

## Mobile

Perfil em cards verticais.

Bottom Navigation.

Safe Area.

---

# Performance

Lazy Loading

Image Optimization

Cache

Realtime Update

Optimistic Update

Skeleton Loading

60 FPS

---

# Segurança

Supabase Auth

JWT

HTTPS

Row Level Security

Teacher Guard

Ownership Guard

Image Validation

Logs de Auditoria

Criptografia

---

# Acessibilidade

WCAG AA

Keyboard Navigation

TalkBack

VoiceOver

Touch Target

44x44px

Focus Visible

Texto alternativo nas imagens

Alto contraste

---

# Psicologia de Produto

## Autoridade

O perfil deve aumentar a confiança do aluno no professor.

---

## Humanização

Mostrar história e experiência cria conexão.

---

## Reconhecimento

Conquistas e avaliações aumentam motivação do professor.

---

## Simplicidade

Editar o perfil deve parecer tão simples quanto atualizar um perfil Apple.

---

# Critérios de Aceitação

- O professor deve conseguir editar todas as informações públicas.
- O perfil deve alimentar automaticamente páginas de cursos e certificados.
- Deve existir preview antes da publicação.
- Deve permitir foto, biografia, especialidades e redes sociais.
- Deve apresentar estatísticas e conquistas do professor.
- Deve possuir sistema de verificação.
- A interface deve seguir integralmente o Lawrence Design System.
- O efeito Liquid Glass deve ser usado somente em elementos flutuantes.
- A experiência deve ser elegante, humana e inspirada em Apple, MasterClass e LinkedIn.