---
version: 2.0.0
name: Service-API
type: Backend Contract Specification

backend:
  framework: FastAPI
  language: Python

database:
  provider: Supabase
  engine: PostgreSQL

auth:
  provider: Supabase Auth

architecture:
 - Clean Architecture
 - DDD
 - REST

security:
 - JWT
 - RBAC
 - RLS
 - OWASP
---

# Lawrence Academy API Specification


# 1. API Standards


Base URL:


/api/v1


Todos endpoints retornam:


{
 success,
 data,
 error,
 meta
}


---


# 2. Authentication Context


## POST
/auth/register
Descrição:
Criação de usuário.

Permission:
PUBLIC

Request:
{
 name,
 email,
 password
}


Response:
{
 user_id,
 access_token,
 refresh_token
}


Errors:
AUTH_EMAIL_EXISTS
AUTH_INVALID_PASSWORD

---


## POST
/auth/login


Request:
{
 email,
 password
}


Response:

{
 token,
 user,
 role
}


---


## POST
/auth/logout
Permission:

AUTHENTICATED

---


## POST
/auth/refresh

Renovar JWT.


---


## POST
/auth/password/forgot


Enviar recuperação.


---


## POST
/auth/password/reset


Alterar senha.


---


## POST
/auth/email/verify


Verificar email.



================================================


# 3. User Context


## GET
/users/me


Retorna usuário logado.


---


## PATCH
/users/me


Atualiza perfil.


---


## DELETE
/users/me


Desativa conta.



================================================


# 4. Admin User Management


## GET
/admin/users


Permission:

ADMIN


Query:


?page=

?search=

?role=

?status=


Response:


[
 {
  id,
  name,
  email,
  role,
  status
 }
]


---


## PATCH

/admin/users/{id}/role


Alterar permissão.



---


## PATCH

/admin/users/{id}/block


Bloquear usuário.



================================================


# 5. Course Context


## GET

/courses


PUBLIC


Filtros:


category

price

teacher

level

rating

page


---


## GET

/courses/{id}


Retorna:


Course

Modules

Lessons Preview

Teacher

Reviews


---


## POST

/teacher/courses


Role:


TEACHER


Cria curso.



Request:


{
 title,
 description,
 price_month,
 category
}



---


## PATCH

/teacher/courses/{id}



---


## DELETE

/teacher/courses/{id}



================================================


# 6. Module Context


## POST
/teacher/courses/{course_id}/modules
- Auth: Teacher/Admin
- Body: `title` (str), `order_index` (int, opt)
- Func: Cria um novo módulo.

## PATCH
/teacher/courses/{course_id}/modules/{module_id}
- Auth: Teacher/Admin
- Body: `title` (str, opt), `order_index` (int, opt)
- Func: Atualiza os dados de um módulo.

## DELETE
/teacher/courses/{course_id}/modules/{module_id}
- Auth: Teacher/Admin
- Func: Arquiva logicamente um módulo.

### Gerenciamento individual de aulas (Teacher)

Todas as operações validam JWT, role e ownership do curso no backend.

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| POST | `/api/v1/teacher/courses/{course_id}/modules/{module_id}/lessons` | Cria uma aula independente no módulo. Aceita `title`, `description` e `order_index`. |
| PATCH | `/api/v1/teacher/courses/{course_id}/lessons/{lesson_id}` | Atualiza somente a aula selecionada. Aceita `title`, `description`, `order_index` e `status` (`draft`, `published`, `hidden`). |
| DELETE | `/api/v1/teacher/courses/{course_id}/lessons/{lesson_id}` | Arquiva logicamente somente a aula selecionada, preservando módulo e demais aulas. |

### Upload de Arquivos de Vídeo (Teacher)

Geração de URLs pré-assinadas para envio direto de aulas para o Storage (bucket `raw-videos`), isentando o backend de tráfego de mídia pesado e respeitando BOLA e RBAC (apenas instrutores donos ou admins).

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| POST   | `/api/v1/teacher/courses/{c_id}/lessons/{l_id}/upload` | Retorna `signed_url`, `path` e `expires_in` para upload do vídeo `mp4`/`mov` (max 2GB). O caminho gerado internamente evita colisão de nomes e previne Path Traversal. |

================================================


# 7. Lesson Context


## POST

/modules/{id}/lessons


Criar aula.


---


## POST

/lessons/{id}/upload


Upload vídeo.


Fluxo:


Upload

↓

Process HLS

↓

Publish


---


## GET

/lessons/{id}/stream


Proteção:


JWT

Subscription

RLS



Response:


{
 hls_url,
 expires_at
}


Nunca retornar:


.mp4


---


## POST

/lessons/{id}/progress



================================================


# 8. Enrollment Context


## POST

/courses/{id}/enroll


Criar matrícula.


---


## GET

/student/courses


Meus cursos.



================================================


# 9. Subscription Context


Regra:


1 curso = 1 assinatura


---


## GET

/api/v1/subscriptions/me


Lista assinaturas do usuário autenticado.
Retorna flags computadas: `has_access`, `grace_period_ends_at`.


---


## GET

/subscriptions/eligibility/{course_id}


Retorna a elegibilidade de compra/acesso para um curso específico.
Cursos publicados com `monthly_price = 0` retornam `has_access = true`,
`can_purchase = false` e `reason_code = FREE_COURSE`.
Response:
{
  can_purchase,
  has_access,
  reason_code,
  message,
  subscription_status,
  course_id
}


---


## GET

/subscriptions/{id}


---


## PATCH

/api/v1/subscriptions/{subscription_id}/cancel


Agenda o cancelamento somente daquele curso para o fim do periodo pago.
Valida JWT e ownership, rejeita cancelamento duplicado com HTTP 409 e retorna
o estado atualizado com `cancel_at_period_end`, `canceled_at` e `has_access`.



Estados:


ACTIVE

CANCELLED

EXPIRED

PAYMENT_FAILED



================================================


# 10. Payment Context


## POST

/api/v1/payments/checkout


Request:

```json
{
  "course_id": "uuid",
  "success_url": "lawrence://payment/pending?session_id={CHECKOUT_SESSION_ID}",
  "cancel_url": "lawrence://payment/cancel"
}
```

O cliente nunca define o valor nem um `price_id`. O backend carrega o curso
publicado, rejeita cursos gratuitos e cria o preço recorrente no Stripe a partir
de `courses.monthly_price`. `Idempotency-Key` pode ser enviado no header.


Response:


checkout_url

---

## GET

/api/v1/payments/checkout/status/{checkout_id}

Consulta uma sessao pertencente ao usuario autenticado e retorna:

```json
{
  "status": "pending | processing | paid | expired | failed | cancelled",
  "payment_status": "paid | unpaid | no_payment_required",
  "subscription_status": "active | trialing | incomplete | null",
  "created_at": "2026-07-13T13:00:00Z",
  "updated_at": "2026-07-13T13:00:05Z",
  "checkout_url": "https://checkout.stripe.com/..."
}
```

`updated_at` representa o instante em que o estado foi observado no gateway.
Checkout inexistente retorna HTTP 404 e ownership invalido retorna HTTP 403.



---


## GET

/payments/history



---


## GET

/invoices



---


## POST

/api/v1/payments/webhook

Endpoint oficial de recebimento de eventos do Stripe.
Garante idempotência atômica e processamento seguro.

## POST (DEPRECATED)

/webhooks/stripe

Rota legada mantida por compatibilidade temporária.
Atualizar no Stripe Dashboard para a rota v1.

Eventos suportados:

PAYMENT_SUCCESS
PAYMENT_FAILED
REFUND



================================================


# 11. Activities Context


## POST

/teacher/activities


Criar atividade.


Tipos:


MULTIPLE_CHOICE

BOOLEAN

ESSAY



---


## POST

/student/activities/{id}/submit



---


## PATCH

/teacher/submissions/{id}/correct



================================================


# 12. Certificate Context


## GET

/certificates



---


## POST

/certificates/generate



---


## GET

/certificates/{code}/verify



================================================


# 13. Download Offline Context

## GET

`/api/v1/offline/progress`

Retorna o progresso consolidado do estudante autenticado. O `student_id` e
derivado do JWT e nunca e aceito do cliente.

## PATCH

`/api/v1/offline/progress/{lesson_id}`

Aplica merge parcial e monotonico de uma aula. `watched_seconds` e obrigatorio;
`progress_percentage` e opcional e, quando enviado, serve apenas para validar
consistencia. O servidor consulta `lessons.duration_seconds`, rejeita valores
fora de `0..duration_seconds` com HTTP 422 e persiste o percentual recalculado.
Conclusao nunca regride e exige a duracao completa.

## POST

`/api/v1/offline/sync`

Recebe ate 100 eventos offline. Eventos de progresso usam o mesmo payload
canonico e sao consolidados transacionalmente com auditoria multi-device.


ANDROID ONLY


## POST

/offline/download-token



Valida:


Subscription


Retorna:


HLS encrypted access



---


## POST

/offline/sync

Sincroniza telemetria e progresso offline garantindo Idempotência, Validação Antifraude e Merge LWW/MAX(progress).

Suporta os seguintes eventos de telemetria:
- UPDATE_LESSON_PROGRESS
- VIDEO_HEARTBEAT
- LESSON_COMPLETED
- PLAYER_STOPPED
- PLAYER_RESUMED
- PLAYER_PAUSED
- PLAYER_SEEK
- PLAYER_ERROR
- DOWNLOAD_COMPLETED

Payload inclui obrigatoriamente:
- correlation_id
- request_id
- device_id
- lesson_id
- event_id
- timestamp
- origin
- HMAC Signature (Header)



================================================


# 14. Notification Context



GET

/notifications



PATCH

/notifications/{id}/read



================================================


# 15. Favorites



POST

/favorites/course/{id}



DELETE

/favorites/course/{id}



================================================


# 16. Search


GET

/search


Query:


q

type

filters



================================================


# 17. Teacher Analytics


GET

/teacher/analytics



Retorna:


students

revenue

completion

engagement



================================================


# 18. Admin Reports


GET

/admin/reports



================================================


# 19. Audit Logs



GET

/admin/audit


Registra:


login

payments

roles

delete

update



================================================


# 20. Roles Permission



GET

/admin/roles



POST

/admin/roles



PATCH

/admin/roles/{id}



================================================


# 21. Realtime Events


Channels:


course-progress


notifications


live-events


payments



================================================


# 22. Error Codes


AUTH_001


PAYMENT_001


COURSE_001


VIDEO_001


PERMISSION_001



================================================


# Final Rules


Controllers nunca possuem regra de negócio.


Fluxo obrigatório:


Controller

↓

UseCase

↓

Repository

↓

Datasource


Toda rota protegida usa:


JWT

+

RBAC

+

Supabase RLS

---

# 12. Video Upload Context

## POST
`/teacher/courses/{course_id}/lessons/{lesson_id}/upload`

**Descrição:**
Gera uma URL assinada (Pre-signed URL) de expiração de 2 horas para upload direto de vídeo ao Supabase Storage.

**Payload:**
```json
{
  "filename": "aula_modelagem.mp4",
  "mime_type": "video/mp4",
  "size_bytes": 15482390,
  "idempotency_key": "upload-session-uniq-id-key"
}
```

**Resposta (200 OK):**
```json
{
  "job_id": "job-uuid-123",
  "raw_video_path": "uploads/course-uuid/job-uuid/lesson-uuid.mp4",
  "expires_in": 7200,
  "signed_url": "https://supabase-storage-url/raw-videos/..."
}
```
