---
version: 2.0.0

phase_2_routes:
  - /login
  - /register
  - /forgot-password
name: Pages-Overview
type: Application Navigation & Page Architecture Specification

platforms:
  - Flutter Web
  - Flutter Android

frontend:
  framework: Flutter
  navigation: GoRouter
  state_management: Riverpod

architecture:
  - Clean Architecture
  - Feature First
  - Domain Driven Design

auth:
  provider: Supabase Auth

design:
  system: Lawrence Design System

purpose:
  - Route Mapping
  - Navigation Flow
  - Page Ownership
  - Permission Control
  - State Definition
---

## Navegação canônica da área do aluno

| Destino | Rota canônica | Adaptação |
| --- | --- | --- |
| Início | `/dashboard/home` | Bottom bar, rail ou sidebar |
| Cursos | `/dashboard/courses` | Bottom bar, rail ou sidebar |
| Projetos | `/dashboard/projects` | Bottom bar, rail ou sidebar |
| Detalhe do projeto | `/dashboard/projects/:projectId` | Subrota autenticada de Projetos |
| Conquistas | `/dashboard/achievements` | Bottom bar, rail ou sidebar |
| Perfil | `/dashboard/profile` | Bottom bar, rail ou sidebar |

Configurações é uma subrota de Perfil (`/dashboard/settings`). Atividades,
certificados, downloads, pagamentos e assinaturas permanecem subrotas
contextuais e não disputam espaço na navegação principal.

Breakpoints canônicos: mobile abaixo de 700 px, tablet entre 700 e 1099 px e
desktop a partir de 1100 px. Detalhes e player devem preservar contexto ao
voltar e podem reduzir a navegação global quando houver uma ação imersiva.

# Lawrence Academy
# Pages Overview Specification


# 1. Objetivo


Este documento define a arquitetura global de telas da aplicação.


Ele responde:


Quais páginas existem?


Como elas se conectam?


Quem pode acessar?


Qual layout utilizam?


Quais regras protegem cada rota?



---


# Importante


Este arquivo NÃO define detalhes visuais.


Detalhes das páginas ficam em:


pages/


Exemplo:


student/dashboard.md


teacher/create-course.md


admin/users.md


---


# Hierarquia da documentação


```text

PED

↓

PAGES_OVERVIEW

↓

PAGE SPEC

↓

COMPONENTS

↓

CODE

```


---

# 2. Application Structure


A aplicação possui 4 áreas principais:


```text

Public


Auth


Student


Teacher


Admin

```


---


# 3. Layout Architecture



## Public Layout


Usado para visitantes.


Rotas:


```text
/

/courses

/courses/:slug

/pricing

/about

/blog

/contact

```


Componentes:


Header


Footer


Search


CTA


---


## Auth Layout


Fluxos de autenticação.


Rotas:


```text

/auth/splash

/auth/onboarding

/auth/login

/auth/register

/auth/forgot-password

/auth/reset-password

/auth/verify-email

```


---


## Student Layout


Área do aluno.


Protegido:


AuthGuard


RoleGuard


---


Rotas:


```text

/student/*

```


Componentes:


Sidebar Desktop


Bottom Navigation Mobile


Header


Search


Notifications


---


## Teacher Layout


Área do professor.


Protegido:


TeacherGuard


---


Rotas:


```text

/teacher/*

```


---


## Admin Layout


Área administrativa.


Protegido:


AdminGuard


MFA obrigatório


---


Rotas:


```text

/admin/*

```


---

# 4. Route Guards



Toda navegação passa por:


```text

Router

↓

Auth Guard

↓

Role Guard

↓

Permission Guard

↓

Page

```


---


# Auth Guard


Bloqueia usuários sem sessão.


Usa:


Supabase Auth


---


Exemplo:


```text

/student/dashboard


Sem login:


redirect


/auth/login

```


---


# Role Guard


Controla:


STUDENT


TEACHER


ADMIN


SUPER_ADMIN


---


# Subscription Guard


Regra:


1 curso = 1 assinatura


---


Usado:


Lesson


Downloads


Materials


Certificate


---


Exemplo:


Aluno acessa:


```text

/course/123/lesson/1

```


Verifica:


Subscription ACTIVE


---


# Permission Guard


Usado Admin.


Exemplo:


DELETE_USER


VIEW_REPORT


MANAGE_PAYMENT


---

# 5. Public Routes


# PAGE-PUBLIC-001


Name:


Landing Page


Route:


/


Spec:


pages/public/home.md


API:


GET /courses/featured


---


# PAGE-PUBLIC-002


Name:


Course Catalog


Route:


/courses


Spec:


pages/public/courses.md


API:


GET /courses


---


# PAGE-PUBLIC-003


Name:


Course Detail


Route:


/courses/:slug


Spec:


course-detail.md


API:


GET /courses/{id}


---


# PAGE-PUBLIC-004


Pricing


Route:


/pricing


---


# PAGE-PUBLIC-005


Blog


Route:


/blog


---


# PAGE-PUBLIC-006


FAQ


Route:


/faq


---


# PAGE-PUBLIC-007


Contact


Route:


/contact


---

# 6. Authentication Routes


# AUTH-001


Splash


Route:


/auth/splash


---


# AUTH-002


Onboarding


Route:


/auth/onboarding


---


# AUTH-003


Login


Route:


/auth/login


API:


POST /auth/login


---


# AUTH-004


Register


Route:


/auth/register


API:


POST /auth/register


---


# AUTH-005


Forgot Password


Route:


/auth/forgot-password


---


# AUTH-006


Verify Email


Route:


/auth/verify-email


---

# 7. Student Routes


Base:


```text

/student

```


---


# STUDENT-001


Dashboard


Route:


/student/dashboard


Spec:


student/dashboard.md


API:


GET /student/dashboard


---


# STUDENT-002


My Courses


Route:


/student/courses


API:


GET /student/courses


---


# STUDENT-003


Course Player


Route:


/student/course/:id/player


Guard:


SubscriptionGuard


---


# STUDENT-004


Lesson


Route:


/student/lesson/:id


Guard:


SubscriptionGuard


---


# STUDENT-005


Activities


Route:


/student/activities


---


# STUDENT-006


Certificates


Route:


/student/certificates


---


# STUDENT-007


Downloads


Route:


/student/downloads


Android:


Offline Enabled


---


# STUDENT-008


Favorites


Route:


/student/favorites


---


# STUDENT-009


Payments


Route:


/student/payments


---


# STUDENT-010


Subscriptions


Route:


/student/subscriptions


---


# STUDENT-011


Invoices


Route:


/student/invoices


---


# STUDENT-012


Profile


Route:


/student/profile


---


# STUDENT-013


Settings


Route:


/student/settings


---

# 8. Teacher Routes


Base:


```text

/teacher

```


---


# TEACHER-001


Dashboard


Route:


/teacher/dashboard


---


# TEACHER-002


Courses


Route:


/teacher/courses


---


# TEACHER-003


Create Course


Route:


/teacher/course/create


---


# TEACHER-004


Edit Course


Route:


/teacher/course/:id/edit


---


# TEACHER-005


Modules


Route:


/teacher/course/:id/modules


---


# TEACHER-006


Lessons


Route:


/teacher/lessons


---


# TEACHER-007


Upload Video


Route:


/teacher/upload/video


Pipeline:


Video Worker


HLS


---


# TEACHER-008


Assignments


Route:


/teacher/assignments


---


# TEACHER-009


Correction


Route:


/teacher/corrections


---


# TEACHER-010


Analytics


Route:


/teacher/analytics


---


# TEACHER-011


Students


Route:


/teacher/students


---

# 9. Admin Routes


Base:


```text

/admin

```


Proteção:


AdminGuard


MFA


Audit


---


# ADMIN-001


Dashboard


/admin/dashboard


---


# ADMIN-002


Users


/admin/users


---


# ADMIN-003


Teachers


/admin/teachers


---


# ADMIN-004


Students


/admin/students


---


# ADMIN-005


Payments


/admin/payments


---


# ADMIN-006


Subscriptions


/admin/subscriptions


---


# ADMIN-007


Categories


/admin/categories


---


# ADMIN-008


Reports


/admin/reports


---


# ADMIN-009


Audit


/admin/audit


---


# ADMIN-010


Roles


/admin/roles


---


# ADMIN-011


Settings


/admin/settings


---

# 10. Shared Pages


Todos módulos usam:


Loading


Empty State


Error


Offline


Search


Dialogs


Bottom Sheets


Notifications


---

# 11. Required Page States


Toda página obrigatoriamente possui:


```text

INITIAL


LOADING


SUCCESS


EMPTY


ERROR


OFFLINE


UNAUTHORIZED

```


---

# 12. Flutter Architecture Mapping



Cada página gera:


```text

feature/


 presentation/


   pages/


   widgets/


   controllers/


 domain/


   entities/


   usecases/


 data/


   models/


   repositories/

```


---

# 13. Provider Rules


Cada página possui:


Controller


State


Repository


Exemplo:


```text

dashboardProvider


dashboardController


dashboardRepository

```


---

# 14. Navigation Rules


Mobile:


Bottom Navigation


Desktop:


Sidebar


Tablet:


Adaptive Navigation


---

# 15. Deep Links


Suporte:


```text

lawrence://course/{id}


lawrence://lesson/{id}


lawrence://certificate/{id}

```


---

# 16. Offline Routing


Android:


Permitir:


Downloads


Lessons baixadas


Materiais


---


Bloquear:


Pagamento


Admin


Upload


---

# 17. Security Rules


Nunca confiar no Frontend.


Toda rota valida:


JWT


RBAC


RLS


Subscription


---

# 18. Final Rule


PED define produto.


Pages Overview define navegação.


Page Specs definem telas.


Design System define visual.


Service API define dados.

