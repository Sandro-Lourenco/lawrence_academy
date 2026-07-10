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

/courses/{id}/modules


Criar módulo.


---


## PATCH

/modules/{id}


Editar.


---


## DELETE

/modules/{id}



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

/subscriptions


Lista assinaturas.


---


## GET

/subscriptions/{id}


---


## PATCH

/subscriptions/{id}/cancel


Cancela somente aquele curso.



Estados:


ACTIVE

CANCELLED

EXPIRED

PAYMENT_FAILED



================================================


# 10. Payment Context


## POST

/payments/checkout


Request:


course_id


Response:


checkout_url



---


## GET

/payments/history



---


## GET

/invoices



---


## POST

/webhook/payment



Eventos:


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



Sincroniza:


progress

notes

favorites



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

