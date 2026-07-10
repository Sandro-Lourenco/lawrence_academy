# Mapa de Migração de Rotas do Backend (Fase 4)

Este documento mapeia todas as rotas legadas e as rotas oficiais de destino sob a versão de API `/api/v1` da Lawrence Academy.

---

## 1. Mapeamento das Rotas

### 1.1. Perfis e Alunos (Profiles & Students)
| Rota Legada | Rota Oficial (`/api/v1`) | Verbos | Ação de Migração |
|---|---|---|---|
| `/api/profiles/me` | `/api/v1/profiles/me` | `GET` | Mover para o módulo `profiles`, validar `student_id` e permissões, retornar DTO formatado. |
| `/students/me` | `/api/v1/profiles/me` | `GET` | Rota depreciada. Unificar sob `/api/v1/profiles/me`. |
| `/api/profiles/me` | `/api/v1/profiles/me` | `PUT` | Mover para o módulo `profiles` utilizando o `UpdateMyProfileUseCase`. |
| `/students/me` | `/api/v1/profiles/me` | `PUT` | Rota depreciada. Unificar sob `/api/v1/profiles/me`. |

### 1.2. Cursos e Aulas (Courses & Lessons)
| Rota Legada | Rota Oficial (`/api/v1`) | Verbos | Ação de Migração |
|---|---|---|---|
| `/api/courses` | `/api/v1/courses` | `GET` | Listar cursos ativos e publicados. Consumido via `ListPublishedCoursesUseCase`. |
| `/courses` | `/api/v1/courses` | `GET` | Rota depreciada. Unificar sob `/api/v1/courses`. |
| `/api/courses/slug/{slug}` | `/api/v1/courses/slug/{slug}` | `GET` | Retornar detalhes de curso pelo slug. Consumido via `GetCourseBySlugUseCase`. |
| `/api/courses/{course_id}` | `/api/v1/courses/{course_id}` | `GET`, `PUT`, `DELETE` | CRUD e soft-delete de cursos. Restrito por roles (professores/admins). |
| `/courses/{id}/lessons/{lesson_id}` | `/api/v1/courses/{course_id}/lessons/{lesson_id}` | `GET` | Retornar detalhes de uma lição. Consumido via `GetLessonUseCase`. |
| `/courses/{id}/lessons/{lesson_id}/stream` | `/api/v1/courses/{course_id}/lessons/{lesson_id}/stream` | `GET` | Obter link temporário HLS assinado. Valida assinatura e grace period. |

### 1.3. Assinaturas e Pagamentos (Subscriptions & Payments)
| Rota Legada | Rota Oficial (`/api/v1`) | Verbos | Ação de Migração |
|---|---|---|---|
| `/api/checkout/session` | `/api/v1/payments/checkout` | `POST` | Criar sessão segura de checkout Stripe. Valida existência de assinatura ativa. |
| `/webhooks/stripe` | `/api/v1/payments/webhook` | `POST` | Processar eventos Stripe com controle de idempotência (tabela `payment_events`). |

### 1.4. Avaliações (Assessments)
| Rota Legada | Rota Oficial (`/api/v1`) | Verbos | Ação de Migração |
|---|---|---|---|
| `/api/task_submissions` | `/api/v1/assessments/submissions` | `POST` | Criar submissão de tarefa (discursiva ou múltipla escolha com auto-correção). |
| `/api/teacher/submissions/{id}/review` | `/api/v1/assessments/submissions/{id}/review` | `PUT` | Atribuição de nota e feedback pelo instrutor ou administrador. |

---

## 2. Redirecionamento e Transição
Para garantir compatibilidade com versões existentes do Flutter que possam estar rodando sem atualização imediata das rotas:
1. Durante a migração, manteremos as rotas legadas ativas em `backend/src/main.py` mas marcadas como `@deprecated`.
2. As rotas legadas farão chamadas diretas aos mesmos UseCases da nova arquitetura.
3. Após a publicação e homologação total da Fase 5 (Flutter) consumindo `/api/v1`, removeremos definitivamente os routers legados.
