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


name VARCHAR(100),

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


key VARCHAR(100) UNIQUE,


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

role_id UUID REFERENCES roles(id),

permission_id UUID REFERENCES permissions(id),


PRIMARY KEY(role_id,permission_id)

);
```

---

# USER ROLES


```sql
CREATE TABLE user_roles(

user_id UUID REFERENCES profiles(id),

role_id UUID REFERENCES roles(id),


PRIMARY KEY(user_id,role_id)

);
```

---

# ======================================
# TEACHER CONTEXT
# ======================================


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

EXISTS(

SELECT 1

FROM user_roles ur

JOIN roles r

ON r.id = ur.role_id


WHERE ur.user_id = auth.uid()

AND r.name='admin'

)

);
```

---

# Próximos Contextos

Parte 2:

- Course
- Modules
- Lessons
- HLS Media
- Upload Pipeline

Parte 3:

- Subscription
- Payments
- Invoices

Parte 4:

- Learning
- Activities
- Certificates

Parte 5:

- AI
- Offline
- Notifications
- Audit Logs
