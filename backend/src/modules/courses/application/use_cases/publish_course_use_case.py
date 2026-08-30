from src.core.errors.errors import AuthorizationError, ConflictError, NotFoundError
from src.modules.courses.domain.repositories import CourseRepository
from src.modules.courses.application.idempotency import request_fingerprint


class CoursePublicationUseCase:
    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def _authorize(self, course_id: str, user_id: str, role: str) -> None:
        owner = await self.repository.get_instructor_id(course_id)
        if not owner:
            raise NotFoundError("Curso não encontrado.")
        if role != "super_admin" and owner != user_id:
            raise AuthorizationError("Apenas o instrutor pode revisar e publicar este curso.")

    async def checklist(self, *, course_id: str, user_id: str, role: str) -> dict:
        await self._authorize(course_id, user_id, role)
        snapshot = await self.repository.get_publication_snapshot(course_id)
        course = snapshot.get("course")
        if not course:
            raise NotFoundError("Curso não encontrado.")
        issues: list[dict] = []
        structure: list[dict] = []

        def add(code: str, label: str, severity: str, target: str) -> None:
            issues.append({"code": code, "label": label, "severity": severity, "target": target})

        if len((course.get("title") or "").strip()) < 3:
            add("title", "Informe o título do curso.", "blocking", "basic")
        if len((course.get("summary") or "").strip()) < 10:
            add("summary", "Complete a descrição curta.", "blocking", "basic")
        if not course.get("category"):
            add("classification", "Informe a categoria.", "blocking", "basic")
        if course.get("cover_status") != "ready":
            add("cover", "Envie uma imagem de capa válida.", "blocking", "media")
        if course.get("monthly_price") is None:
            add("price", "Confirme o preço do curso.", "blocking", "offer")
        unavailable_prerequisites = [
            relation.get("prerequisite_course") or {}
            for relation in course.get("course_prerequisites", []) or []
            if (relation.get("prerequisite_course") or {}).get("status") != "published"
        ]
        if unavailable_prerequisites:
            add(
                "prerequisite_courses",
                "Todos os cursos pré-requisitos precisam estar publicados.",
                "blocking",
                "basic",
            )
        if course.get("availability") == "scheduled":
            add(
                "scheduling",
                "Agendamento ainda não possui executor backend.",
                "blocking",
                "offer",
            )

        modules = [m for m in course.get("modules", []) if m.get("deleted_at") is None]
        if not modules:
            add(
                "modules",
                "Adicione o conteúdo do curso.",
                "blocking",
                "curriculum",
            )
        lesson_count = 0
        for module in modules:
            lessons = [
                lesson for lesson in module.get("lessons", []) if lesson.get("deleted_at") is None
            ]
            module_structure = {
                "id": module["id"],
                "title": module.get("title") or "Módulo sem título",
                "lessons": [],
            }
            structure.append(module_structure)
            if not lessons:
                add(
                    f"module:{module['id']}",
                    f"O módulo “{module.get('title') or 'Sem título'}” não possui aulas.",
                    "recommended",
                    f"module:{module['id']}",
                )
            for lesson in lessons:
                lesson_count += 1
                blocks = [
                    block
                    for block in lesson.get("lesson_blocks", [])
                    if block.get("deleted_at") is None
                ]
                module_structure["lessons"].append(
                    {
                        "id": lesson["id"],
                        "title": lesson.get("title") or "Aula sem título",
                        "blocks": [
                            {
                                "id": block["id"],
                                "type": block.get("block_type"),
                                "block_type": block.get("block_type"),
                                "order_index": block.get("order_index", 0),
                                "content": block.get("content") or {},
                            }
                            for block in blocks
                        ],
                    }
                )
                has_external_video = lesson.get("video_source_type") in {
                    "youtube",
                    "vimeo",
                } and bool(lesson.get("external_video_id"))
                if (
                    lesson.get("is_required") is True
                    and not lesson.get("hls_storage_path")
                    and not has_external_video
                ):
                    add(
                        f"required-video:{lesson['id']}",
                        (
                            f"A aula obrigatória “{lesson.get('title') or 'Sem título'}” "
                            "ainda não possui vídeo processado ou link externo válido."
                        ),
                        "blocking",
                        f"lesson:{lesson['id']}",
                    )
                if not blocks and not lesson.get("hls_storage_path") and not has_external_video:
                    add(
                        f"lesson:{lesson['id']}",
                        f"A aula “{lesson.get('title') or 'Sem título'}” não possui vídeo nem conteúdo.",
                        "blocking",
                        f"lesson:{lesson['id']}",
                    )
                for block in blocks:
                    content = block.get("content") or {}
                    if block.get("block_type") in {"image", "gallery"} and not content.get(
                        "alt_text"
                    ):
                        add(
                            f"alt:{block['id']}",
                            "Imagem sem texto alternativo.",
                            "blocking",
                            f"block:{block['id']}",
                        )
                    if block.get("block_type") == "activity":
                        activity_type = content.get("activity_type") or "single_choice"
                        if not content.get("question"):
                            add(
                                f"activity:{block['id']}",
                                "Atividade sem enunciado.",
                                "blocking",
                                f"block:{block['id']}",
                            )
                        if not str(content.get("task_id") or "").strip():
                            add(
                                f"activity-task:{block['id']}",
                                "Atividade ainda não foi confirmada no servidor.",
                                "blocking",
                                f"block:{block['id']}",
                            )
                        items = content.get("items") or []
                        correct_index = content.get("correct_index")
                        if activity_type == "single_choice" and len(items) < 2:
                            add(
                                f"activity-options:{block['id']}",
                                "Atividade precisa ter ao menos duas alternativas.",
                                "blocking",
                                f"block:{block['id']}",
                            )
                        if activity_type == "single_choice" and (
                            not isinstance(correct_index, int)
                            or not (0 <= correct_index < len(items))
                        ):
                            add(
                                f"activity-answer:{block['id']}",
                                "Selecione uma alternativa correta para a atividade.",
                                "blocking",
                                f"block:{block['id']}",
                            )
                        if activity_type == "true_false" and correct_index not in {0, 1}:
                            add(
                                f"activity-answer:{block['id']}",
                                "Selecione verdadeiro ou falso como resposta correta.",
                                "blocking",
                                f"block:{block['id']}",
                            )
                        if activity_type not in {"single_choice", "true_false", "essay"}:
                            add(
                                f"activity-type:{block['id']}",
                                "Tipo de atividade não suportado no lançamento.",
                                "blocking",
                                f"block:{block['id']}",
                            )
                    if block.get("block_type") == "learn_more" and not any(
                        (
                            str(content.get("text") or "").strip(),
                            str(content.get("url") or "").strip(),
                            str(content.get("storage_path") or "").strip(),
                        )
                    ):
                        add(
                            f"learn-more:{block['id']}",
                            "Saber mais precisa de texto, link ou material enviado.",
                            "blocking",
                            f"block:{block['id']}",
                        )
        if lesson_count == 0 and modules:
            add("lessons", "Crie ao menos uma aula.", "blocking", "curriculum")
        if snapshot.get("pending_jobs"):
            add(
                "uploads",
                "Aguarde o processamento dos vídeos em andamento.",
                "blocking",
                "media",
            )
        if snapshot.get("failed_jobs"):
            add(
                "failed_uploads",
                "Um ou mais vídeos de aula falharam. Reenvie antes de publicar.",
                "blocking",
                "media",
            )
        has_external_trailer = course.get("trailer_source_type") in {
            "youtube",
            "vimeo",
        } and bool(course.get("trailer_external_video_id"))
        if not course.get("trailer_hls_path") and not has_external_trailer:
            add(
                "trailer",
                "Adicionar um trailer pode melhorar a apresentação.",
                "recommended",
                "media",
            )
        if not course.get("description"):
            add(
                "description",
                "Adicione uma descrição completa.",
                "recommended",
                "basic",
            )

        blocking = sum(item["severity"] == "blocking" for item in issues)
        return {
            "ready": blocking == 0,
            "blocking_count": blocking,
            "issues": issues,
            "module_count": len(modules),
            "lesson_count": lesson_count,
            "pending_uploads": len(snapshot.get("pending_jobs", [])),
            "failed_uploads": len(snapshot.get("failed_jobs", [])),
            "structure": structure,
        }

    async def publish(
        self,
        *,
        course_id: str,
        user_id: str,
        role: str,
        idempotency_key: str | None = None,
        expected_updated_at: str | None = None,
        change_summary: str | None = None,
    ):
        checklist = await self.checklist(course_id=course_id, user_id=user_id, role=role)
        if not checklist["ready"]:
            raise ConflictError("O curso possui pendências bloqueadoras antes da publicação.")
        if not any((idempotency_key, expected_updated_at, change_summary)):
            return await self.repository.publish_course(course_id, user_id)
        return await self.repository.publish_course(
            course_id,
            user_id,
            change_summary,
            idempotency_key,
            request_fingerprint(
                {
                    "course_id": course_id,
                    "expected_updated_at": expected_updated_at,
                    "change_summary": change_summary,
                }
            ),
            expected_updated_at,
        )
