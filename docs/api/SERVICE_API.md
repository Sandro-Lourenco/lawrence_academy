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

### Idempotência obrigatória da autoria (v1)

Os seguintes `POST` exigem o header `Idempotency-Key` (8–255 caracteres):

- criação de curso, módulo, aula e bloco;
- duplicação de bloco;
- publicação de curso.

Repetir a mesma chave, ator, escopo e payload retorna o recurso/versão original
sem duplicar conteúdo. Reutilizar a chave com outro payload retorna
`409 Conflict`; omitir o header retorna `422 Unprocessable Entity`.



Request:

```json
{
  "title": "Modelagem feminina",
  "slug": "modelagem-feminina",
  "summary": "Aprenda modelagem do básico ao primeiro vestido.",
  "description": "Descrição completa do curso.",
  "course_type": "complete",
  "subtitle": "Da tomada de medidas à construção de bases",
  "category": "modelagem",
  "level": "iniciante",
  "language": "pt-BR",
  "estimated_duration_minutes": 720,
  "requirements": [],
  "prerequisite_course_ids": ["11111111-1111-4111-8111-111111111111"],
  "learning_objectives": [],
  "target_audience": [],
  "required_materials": [],
  "competencies": [],
  "expected_outcomes": [],
  "monthly_price": 0,
  "status": "draft"
}
```

### Contrato de planejamento do curso

O payload de criação e o `PATCH /teacher/courses/{id}` aceitam:

- `course_type`: `complete | quick | workshop`;
- `subtitle`: texto de até 160 caracteres;
- `language`: `pt-BR | en | es`;
- `estimated_duration_minutes`: inteiro positivo opcional;
- `learning_objectives`: lista de até 20 itens;
- `target_audience`: lista de até 20 itens;
- `prerequisite_course_ids`: até 20 UUIDs de cursos publicados do mesmo professor;
- `required_materials`: lista de até 20 itens;
- `competencies`: lista de até 20 itens;
- `expected_outcomes`: lista de até 20 itens.

Cada item pedagógico possui de 2 a 240 caracteres. `requirements` representa
conhecimentos prévios em texto. Quando a exigência for concluir outro curso,
o cliente envia `prerequisite_course_ids` e a resposta retorna
`prerequisite_courses` como objetos (`id`, `title`, `slug`, `summary`,
`category`, `status` e imagens). O backend rejeita autorreferência, cursos não
publicados, cursos de outro professor e ciclos de dependência.

### Contrato de oferta e configurações

Criação e atualização aceitam:

- `monthly_price`: zero para curso gratuito ou valor mensal positivo;
- `promotional_monthly_price`: opcional e menor que `monthly_price`;
- `promotion_starts_at` e `promotion_ends_at`: obrigatórios em conjunto;
- `certificate_enabled`, `reviews_enabled` e `comments_enabled`;
- `visibility`: `public | unlisted | private`;
- `availability`: `immediate | scheduled`;
- `scheduled_publish_at`: obrigatório quando a disponibilidade for agendada.

`is_featured` é retornado para leitura, mas não pertence ao DTO de atualização
do professor. O backend e as constraints do banco são autoridades financeiras.



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
| POST | `/api/v1/teacher/courses/{course_id}/modules/{module_id}/lessons` | Cria uma aula independente no módulo. Aceita metadados e, opcionalmente, `video_url` HTTPS oficial de YouTube/Vimeo. Aula por link exige `estimated_duration_minutes`. |
| PATCH | `/api/v1/teacher/courses/{course_id}` | Autosave do curso com CAS atômico. Aceita `trailer_video_url` oficial de YouTube/Vimeo ou `remove_external_trailer=true`. `expected_authoring_revision` é obrigatório; revisão obsoleta retorna `409 Conflict`. |
| PATCH | `/api/v1/teacher/courses/{course_id}/lessons/{lesson_id}` | Atualiza somente a aula selecionada. Aceita metadados, `video_url` para substituir por YouTube/Vimeo e `remove_external_video=true` ao trocar o link por upload. |
| PUT | `/api/v1/teacher/courses/{course_id}/lessons/{lesson_id}/blocks/reorder` | Reordena atomicamente todos os blocos ativos. Body: `block_ids` na ordem final e `expected_revision`; retorna `authoring_revision`. Responde conflito quando a revisão ficou obsoleta ou o conjunto está incompleto/duplicado. |
| DELETE | `/api/v1/teacher/courses/{course_id}/lessons/{lesson_id}` | Arquiva logicamente somente a aula selecionada, preservando módulo e demais aulas. |

### Upload de Arquivos de Vídeo (Teacher)

Geração de URLs pré-assinadas para envio direto de aulas para o Storage (bucket `raw-videos`), isentando o backend de tráfego de mídia pesado e respeitando BOLA e RBAC (apenas instrutores donos ou admins).

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| POST   | `/api/v1/teacher/courses/{c_id}/lessons/{l_id}/upload` | Retorna `signed_url`, `path` e `expires_in` para upload do vídeo `mp4`/`mov` (max 2GB). O caminho gerado internamente evita colisão de nomes e previne Path Traversal. |

### Vídeo externo de aula

Como alternativa ao upload, o professor pode informar um link HTTPS oficial de
YouTube ou Vimeo no create/patch da aula. O backend valida host e formato,
persiste somente `video_source_type` e o identificador normalizado e nunca busca
a URL recebida. O catálogo público não recebe o identificador externo.

`GET /api/v1/courses/{course_id}/lessons/{lesson_id}/stream` continua exigindo
JWT, acesso ao curso e ownership/assinatura. A resposta é discriminada:

```json
{"sourceType":"hls","signedUrl":"/api/v1/.../master.m3u8?token=..."}
```

ou:

```json
{"sourceType":"external","provider":"youtube","url":"https://www.youtube.com/watch?v=..."}
```

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

Um certificado é emitido de forma idempotente por `(student_id, course_id)`
somente quando o curso publicado permite certificado, todas as aulas e blocos
obrigatórios foram concluídos e todas as atividades existentes foram aprovadas.
O backend persiste no `metadata` assinado: `student_name`, `course_name`,
`course_workload_hours`, `completed_lesson_count`, `completion_date` e
`issuer_name`. O Flutter nunca fabrica esses dados.


## GET

/certificates



---


## POST

/certificates/generate

## POST

/api/v1/certificates/reconcile

Reconcilia conclusões já sincronizadas e retorna a coleção do aluno. A operação
é autenticada e idempotente; uma aula isolada concluída não reduz os requisitos
de elegibilidade.



---


## GET

/certificates/{code}/verify

Verificação pública e sem autenticação. Retorna somente os metadados públicos
necessários para comprovar autenticidade, conclusão e eventual revogação.

## GET

`/api/v1/certificates/{certificate_id}/pdf`

Baixa o certificado privado em PDF. Exige JWT e ownership do aluno; certificados
revogados não podem ser baixados. A resposta usa `application/pdf`,
`Cache-Control: private, no-store` e contém QR Code apontando para a verificação
pública por código.



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
## Teacher course lifecycle

Authenticated roles: `teacher` (course owner) and `super_admin`.

- `POST /api/v1/teacher/courses/{course_id}/unpublish`
- `POST /api/v1/teacher/courses/{course_id}/archive`
- `POST /api/v1/teacher/courses/{course_id}/restore`

The optional body field `reason` accepts up to 500 characters. Valid
transitions are enforced by `transition_course_status`. Restoring an archived
course results in `unpublished`; publishing always uses the server checklist.
## Immutable course versions

- Public catalog, course details, lessons, blocks and HLS paths read only from
  the current immutable `course_versions` snapshot.
- Teacher authoring endpoints continue reading and updating the relational
  authoring source.
- `GET /api/v1/teacher/courses/{course_id}/versions` returns version metadata
  to the owner or `super_admin`; snapshot payloads are not returned by this
  endpoint.
- `GET /api/v1/teacher/courses/{course_id}/versions/{version_id}` returns the
  protected snapshot, comparison with current authoring, and the optimistic
  concurrency timestamp to the owner or `super_admin`.
- `POST /api/v1/teacher/courses/{course_id}/versions/{version_id}/restore`
  restores the snapshot into authoring. It requires
  `expected_authoring_updated_at`, accepts an optional `reason`, and returns
  `409 Conflict` when authoring changed after comparison.
- `POST /api/v1/teacher/courses/{course_id}/publish` creates the next numbered
  version only after the server publication checklist succeeds. It requires
  `Idempotency-Key`; clients should also send `expected_updated_at` and may send
  `change_summary`. A stale authoring revision or key reused with a different
  request returns `409 Conflict`; an exact replay returns the original version
  without another status-history event.

Restoring content never changes the current public snapshot. A later explicit
publication is required to make restored content visible to students.
# Extensão — cursos rápidos e alunos do professor (2026-08-21)

## Criação simplificada de curso

`POST /api/v1/teacher/courses` aceita como dados editoriais essenciais `title`, `description`, `category`, `requirements`, `required_materials` e `course_type`. `monthly_price` permanece obrigatório por fazer parte da oferta. O backend deriva `slug` e `summary` quando omitidos; campos editoriais legados continuam aceitos temporariamente para compatibilidade.

Para `course_type=quick`, o backend cria um contêiner interno de aulas. O cliente não deve apresentar esse contêiner como módulo nem permitir sua edição ou remoção.

## Alunos de um curso

`GET /api/v1/teacher/courses/{course_id}/students`

- Autorização: professor proprietário ou `super_admin`.
- Retorno: `id`, `full_name`, `email`, `access_status`, datas de acesso, avatar e resumo de progresso.
- Cursos gratuitos incluem alunos que já iniciaram alguma aula, mesmo sem assinatura de pagamento.
