---
version: 2.0.0
name: Database-Schema
type: Database Architecture Specification

database:
  provider: Supabase
  engine: PostgreSQL 15+

architecture:
  - Domain Driven Design
  - Clean Architecture
  - Modular Monolith

security:
  - Row Level Security
  - RBAC
  - Audit Logs
  - JWT

principles:
  - Default Deny
  - Zero Trust
  - UUID Everywhere
  - Soft Delete
---

# Lawrence Academy Database Schema

# Objetivo

Este documento define toda a arquitetura de dados da plataforma.

Responsável por:

- Usuários
- Permissões
- Cursos
- Aprendizado
- Pagamentos
- Assinaturas
- Certificados
- IA
- Offline
- Auditoria


O banco segue:

PostgreSQL

+

Supabase

+

DDD Bounded Contexts

---

# Database Rules

## IDs

Todas tabelas usam:

```sql
UUID PRIMARY KEY DEFAULT gen_random_uuid()
```

Nunca usar:

```sql
SERIAL
INTEGER ID
```

---

# Timestamp Pattern

Todas tabelas principais possuem:

```sql
created_at TIMESTAMPTZ DEFAULT NOW(),

updated_at TIMESTAMPTZ DEFAULT NOW()
```

---

# Soft Delete

Entidades importantes usam:

```sql
deleted_at TIMESTAMPTZ
```

Nunca apagar:

- usuários
- pagamentos
- auditoria

---

# ENUMS

## User Status

```sql
CREATE TYPE user_status AS ENUM (

'active',

'blocked',

'deleted'

);
```

---

## Roles

```sql
CREATE TYPE system_role AS ENUM (

'student',

'teacher',

'admin',

'super_admin'

);
```

---

## Course Status

```sql
CREATE TYPE course_status AS ENUM(

'draft',

'review',

'published',

'archived'

);
```

---

## Subscription Status

```sql
CREATE TYPE subscription_status AS ENUM(

'active',

'cancelled',

'expired',

'payment_failed'

);
```

---

## Payment Status


```sql
CREATE TYPE payment_status AS ENUM(

'pending',

'paid',

'failed',

'refunded'

);
```

---

## Lesson Media Status

```sql
CREATE TYPE media_status AS ENUM(

'uploading',

'processing',

'ready',

'failed'

);
```

---

# ======================================
# AUTH CONTEXT
# ======================================


Gerenciado pelo:

Supabase Auth

Tabela:

auth.users


Nunca alterar diretamente.


---

# PROFILES


Extensão pública do usuário.


```sql
CREATE TABLE profiles (

id UUID PRIMARY KEY
REFERENCES auth.users(id),


full_name VARCHAR(200),

email VARCHAR(255)
UNIQUE NOT NULL,


avatar_url TEXT,


bio TEXT,


status user_status
DEFAULT 'active',


created_at TIMESTAMPTZ DEFAULT NOW(),

updated_at TIMESTAMPTZ DEFAULT NOW(),

deleted_at TIMESTAMPTZ

);
```

---

# USER SETTINGS


Preferências do usuário.


```sql
CREATE TABLE user_settings(

id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

user_id UUID REFERENCES profiles(id),


theme VARCHAR(50),

language VARCHAR(20),

notifications BOOLEAN DEFAULT TRUE,


created_at TIMESTAMPTZ DEFAULT NOW()

);
```

---

# ======================================
# RBAC CONTEXT
# ======================================


Sistema profissional de permissões.


Não usar somente:

role ENUM


Usar:


User

↓

Roles

↓

Permissions


---

# ROLES


```sql
CREATE TABLE roles(

id UUID PRIMARY KEY DEFAULT gen_random_uuid(),


name VARCHAR(100) UNIQUE NOT NULL,

description TEXT,


created_at TIMESTAMPTZ DEFAULT NOW()

);
```

Exemplo:


student

teacher

admin


---

# PERMISSIONS


```sql
CREATE TABLE permissions(

id UUID PRIMARY KEY DEFAULT gen_random_uuid(),


key VARCHAR(100) UNIQUE NOT NULL,


description TEXT

);
```

Exemplo:


CREATE_COURSE


DELETE_USER


VIEW_REPORT


---

# ROLE PERMISSIONS


```sql
CREATE TABLE role_permissions(

role_id UUID REFERENCES roles(id) ON DELETE CASCADE,

permission_id UUID REFERENCES permissions(id) ON DELETE CASCADE,


PRIMARY KEY(role_id,permission_id)

);
```

---

# USER ROLES


```sql
CREATE TABLE user_roles(

user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,

role_id UUID REFERENCES roles(id) ON DELETE CASCADE,


PRIMARY KEY(user_id,role_id)

);
```

---

# ======================================
# TEACHER CONTEXT
# ======================================

## Course Planning — Fase 1 do Studio de Autoria

`public.courses` mantém o planejamento no agregado do curso:

```text
course_type                  complete | quick | workshop
subtitle                     varchar(160)
language                     pt-BR | en | es
estimated_duration_minutes   integer positivo, opcional
learning_objectives          text[]
target_audience              text[]
required_materials           text[]
competencies                 text[]
expected_outcomes            text[]
```

`requirements` permanece como a lista de pré-requisitos. As novas colunas usam
defaults retrocompatíveis e continuam protegidas pelas policies de ownership e
RLS da tabela `courses`. A duração estimada não substitui a duração real obtida
do pipeline de mídia.


Dados específicos de professores.


```sql
CREATE TABLE teachers(

id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

user_id UUID UNIQUE REFERENCES profiles(id),


headline VARCHAR(255),

description TEXT,


verified BOOLEAN DEFAULT FALSE,


rating DECIMAL(3,2),


created_at TIMESTAMPTZ DEFAULT NOW()

);
```

---

# ======================================
# STUDENT CONTEXT
# ======================================


```sql
CREATE TABLE students(

id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

user_id UUID UNIQUE REFERENCES profiles(id),


learning_goal TEXT,


created_at TIMESTAMPTZ DEFAULT NOW()

);
```

---

# USER CREATED TRIGGER


Quando cria usuário no Supabase Auth:

gera profile automático.


```sql
CREATE FUNCTION create_profile()

RETURNS TRIGGER AS $$

BEGIN


INSERT INTO profiles(

id,

email,

full_name

)

VALUES(

NEW.id,

NEW.email,

NEW.raw_user_meta_data->>'name'

);


RETURN NEW;


END;


$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE TRIGGER user_created

AFTER INSERT ON auth.users

FOR EACH ROW

EXECUTE FUNCTION create_profile();

```

---

# INDEXES


```sql
CREATE INDEX idx_profiles_email

ON profiles(email);



CREATE INDEX idx_user_roles

ON user_roles(user_id);

```

---

# RLS


Ativar:


```sql
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

ALTER TABLE roles ENABLE ROW LEVEL SECURITY;

ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
```

---

# RBAC Policies

Roles and Permissions são de leitura pública:

```sql
CREATE POLICY "Public read for roles" ON roles FOR SELECT USING (true);
CREATE POLICY "Public read for permissions" ON permissions FOR SELECT USING (true);
```

Admin gerencia todo o RBAC:

```sql
CREATE POLICY "Admin manage roles" ON roles FOR ALL USING (public.is_admin(auth.uid()));
CREATE POLICY "Admin manage permissions" ON permissions FOR ALL USING (public.is_admin(auth.uid()));
CREATE POLICY "Admin manage role_permissions" ON role_permissions FOR ALL USING (public.is_admin(auth.uid()));
CREATE POLICY "Admin manage user_roles" ON user_roles FOR ALL USING (public.is_admin(auth.uid()));
```

Usuário lê próprios user_roles:

```sql
CREATE POLICY "User read own roles" ON user_roles FOR SELECT USING (auth.uid() = user_id OR public.is_admin(auth.uid()));
```

---

# Profile Policy


Usuário vê próprio perfil:


```sql
CREATE POLICY profile_owner

ON profiles

FOR SELECT

USING(

auth.uid() = id

);
```

---

# Admin Policy


Admin acessa usuários:


```sql
CREATE POLICY admin_profiles

ON profiles

FOR ALL

USING(

public.is_admin(auth.uid())

);
```

---

# ======================================
# VIDEO UPLOAD PIPELINE CONTEXT
# ======================================

## Video Job Status
```sql
CREATE TYPE video_job_status AS ENUM (
    'upload_pending',
    'uploaded',
    'processing_pending',
    'processing',
    'validating',
    'transcoding',
    'generating_hls',
    'generating_thumbnail',
    'completed',
    'failed',
    'dead_letter'
);
```

## Video Processing Jobs
```sql
CREATE TABLE video_processing_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
    course_id UUID NOT NULL,
    initiated_by UUID REFERENCES profiles(id),
    idempotency_key TEXT UNIQUE NOT NULL,
    raw_video_path TEXT NOT NULL,
    status video_job_status DEFAULT 'upload_pending',
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    last_error TEXT,
    next_retry_at TIMESTAMPTZ,
    expected_size_bytes BIGINT,
    real_size_bytes BIGINT,
    video_metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

# ======================================
# OFFLINE SYNC & TELEMETRY CONTEXT
# ======================================

`public.lesson_progress` e a unica tabela de estado consolidado. Usa
`student_id`, `course_id`, `lesson_id`, `watched_seconds`,
`progress_percentage`, `completed`, `completed_at`, `last_synced_at`,
`created_at` e `updated_at`, com chave unica `(student_id, lesson_id)`.

O merge oficial e `public.merge_lesson_progress_event`, executado somente pelo
backend. Ele registra o evento idempotente em `event_store` e aplica `MAX` para
tempo/percentual e OR irreversivel para conclusao na mesma transacao. A funcao
e `SECURITY INVOKER` e nao e executavel por clientes.

`event_store` e append-only e guarda evento, idempotencia, dispositivo,
correlacao, instante do cliente e payload canonico. O identificador externo e
`TEXT` para preservar IDs deterministas ja persistidos nas filas offline. Nao ha
grant para `anon` ou `authenticated`; somente o backend `service_role` registra
eventos pelo RPC `SECURITY INVOKER`.

O trigger `check_progress_course_integrity` consulta a duracao oficial, rejeita
tempo negativo, superior a duracao, curso divergente e conclusao prematura. O
percentual persistido e sempre `ROUND(watched_seconds * 100 / duration_seconds,
2)`. `lesson_progress` concede `SELECT` e `INSERT` ao usuario autenticado sob
RLS de ownership; updates canonicos passam exclusivamente pelo backend.

# SUBSCRIPTIONS AND PAYMENTS CONTEXT

Em `public.courses`, `monthly_price = 0` representa curso gratuito. Um curso
gratuito publicado aparece no catálogo e libera streaming autenticado sem criar
linha em `subscriptions`. Valores maiores que zero seguem o modelo de assinatura
mensal individual por curso.

`public.subscriptions` e a fonte local de verdade para acesso por curso. A
chave primaria e UUID; `student_id` e `course_id` sao chaves estrangeiras e os
identificadores externos ficam em `provider_customer_id` e
`provider_subscription_id`.

O cancelamento ao fim do periodo preserva `status = 'active'` enquanto o acesso
pago continua valido e grava `cancel_at_period_end = true`, `canceled_at` e
`updated_at`. A chamada ao gateway ocorre antes da persistencia local. O
webhook continua responsavel por aplicar o estado terminal `canceled`.

Clientes autenticados possuem somente leitura das proprias assinaturas sob
RLS. Escritas financeiras sao executadas pelo backend com `service_role`, com
ownership validado no caso de uso. `payment_events` permanece server-only e
possui unicidade por `(provider, provider_event_id)` para idempotencia.

# Próximos Contextos

Parte 3:

- Invoices


Parte 4:

- Learning
- Activities
- Certificates

Parte 5:

- AI
- Notifications
- Audit Logs
