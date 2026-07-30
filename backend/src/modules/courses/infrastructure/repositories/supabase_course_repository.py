import hashlib
import typing
from decimal import Decimal
from typing import List, Optional
from supabase import Client
from postgrest.exceptions import APIError
from src.modules.courses.domain.entities import Course, Module, Lesson, LessonBlock
from src.modules.courses.domain.repositories import CourseRepository
from src.core.concurrency import run_sync_io
from src.core.storage.public_url import to_public_supabase_url
from src.core.errors.errors import AuthorizationError, ConflictError, NotFoundError


def _response_data(response: object) -> typing.Any:
    """Cross the PostgREST JSON boundary without weakening domain typing.

    The SDK declares every response as recursive JSON even when a query's
    selected shape is known. Runtime validation and mapping remain unchanged;
    only this external boundary is explicitly dynamic.
    """
    return typing.cast(typing.Any, response).data


class SupabaseCourseRepository(CourseRepository):
    """ImplementaÃƒÂ§ÃƒÂ£o Supabase concreta para repositÃƒÂ³rio de Cursos e Aulas."""

    def __init__(self, client: Client):
        self.client = client

    def _register_authoring_request(
        self,
        *,
        actor_id: str,
        operation_scope: str,
        idempotency_key: str | None,
        request_hash: str | None,
        resource_id: str,
    ) -> None:
        if not idempotency_key:
            return
        opaque_key = hashlib.sha256(idempotency_key.encode("utf-8")).hexdigest()
        try:
            self.client.rpc(
                "register_course_authoring_request",
                {
                    "p_actor_id": actor_id,
                    "p_operation_scope": operation_scope,
                    "p_idempotency_key": opaque_key,
                    "p_request_hash": request_hash,
                    "p_resource_id": resource_id,
                },
            ).execute()
        except APIError as error:
            if error.code == "P0001":
                raise ConflictError(
                    "Idempotency-Key jÃƒÂ¡ foi usada com outro conteÃƒÂºdo."
                ) from error
            raise

    def _map_lesson_block(self, data: dict) -> LessonBlock:
        return LessonBlock(
            id=data["id"],
            lesson_id=data["lesson_id"],
            course_id=data["course_id"],
            block_type=data["block_type"],
            content=data.get("content") or {},
            order_index=int(data.get("order_index") or 0),
            status=data.get("status") or "draft",
            created_at=data.get("created_at"),
            updated_at=data.get("updated_at"),
        )

    def _map_lesson(self, data: dict) -> Lesson:
        blocks = [
            self._map_lesson_block(b)
            for b in data.get("lesson_blocks", []) or []
            if b.get("deleted_at") is None
        ]
        return Lesson(
            id=data["id"],
            module_id=data["module_id"],
            course_id=data["course_id"],
            title=data["title"],
            hls_storage_path=data.get("hls_storage_path"),
            video_job_status=data.get("video_job_status"),
            description=data.get("description"),
            order_index=int(data.get("order_index") or 0),
            duration_seconds=int(data.get("duration_seconds") or 0),
            estimated_duration_minutes=data.get("estimated_duration_minutes"),
            is_required=bool(data.get("is_required", True)),
            material_pdf_url=data.get("material_pdf_url"),
            status=data.get("status") or "draft",
            created_at=data.get("created_at"),
            updated_at=data.get("updated_at"),
            blocks=sorted(blocks, key=lambda x: x.order_index),
        )

    def _map_module(self, data: dict) -> Module:
        lessons = [
            self._map_lesson(lesson_data)
            for lesson_data in data.get("lessons", []) or []
            if lesson_data.get("deleted_at") is None
        ]
        return Module(
            id=data["id"],
            course_id=data["course_id"],
            title=data["title"],
            order_index=int(data.get("order_index") or 0),
            status=data.get("status") or "draft",
            created_at=data.get("created_at"),
            lessons=sorted(lessons, key=lambda x: x.order_index),
        )

    def _map_course(self, data: dict) -> Course:
        modules = [self._map_module(m) for m in data.get("modules", []) or []]
        return Course(
            id=data["id"],
            instructor_id=data["instructor_id"],
            title=data["title"],
            slug=data["slug"],
            summary=data.get("summary") or "",
            course_type=data.get("course_type") or "complete",
            subtitle=data.get("subtitle") or "",
            language=data.get("language") or "pt-BR",
            estimated_duration_minutes=data.get("estimated_duration_minutes"),
            category=data.get("category") or "costura",
            level=data.get("level") or "iniciante",
            description=data.get("description"),
            requirements=data.get("requirements") or [],
            learning_objectives=data.get("learning_objectives") or [],
            target_audience=data.get("target_audience") or [],
            required_materials=data.get("required_materials") or [],
            competencies=data.get("competencies") or [],
            expected_outcomes=data.get("expected_outcomes") or [],
            thumbnail_url=data.get("thumbnail_url"),
            trailer_hls_path=data.get("trailer_hls_path"),
            cover_image_path=data.get("cover_image_path"),
            cover_alt_text=data.get("cover_alt_text"),
            cover_focal_x=float(
                typing.cast(float, data.get("cover_focal_x"))
                if data.get("cover_focal_x") is not None
                else 0.5
            ),
            cover_focal_y=float(
                typing.cast(float, data.get("cover_focal_y"))
                if data.get("cover_focal_y") is not None
                else 0.5
            ),
            cover_status=data.get("cover_status") or "empty",
            trailer_status=data.get("trailer_status") or "empty",
            monthly_price=Decimal(
                str(data.get("monthly_price") if data.get("monthly_price") is not None else "0.00")
            ),
            promotional_monthly_price=(
                Decimal(str(data["promotional_monthly_price"]))
                if data.get("promotional_monthly_price") is not None
                else None
            ),
            promotion_starts_at=data.get("promotion_starts_at"),
            promotion_ends_at=data.get("promotion_ends_at"),
            certificate_enabled=(
                bool(data.get("certificate_enabled"))
                if data.get("certificate_enabled") is not None
                else True
            ),
            reviews_enabled=(
                bool(data.get("reviews_enabled"))
                if data.get("reviews_enabled") is not None
                else True
            ),
            comments_enabled=(
                bool(data.get("comments_enabled"))
                if data.get("comments_enabled") is not None
                else True
            ),
            visibility=data.get("visibility") or "public",
            availability=data.get("availability") or "immediate",
            scheduled_publish_at=data.get("scheduled_publish_at"),
            is_featured=bool(data.get("is_featured", False)),
            status=data.get("status") or "draft",
            authoring_revision=int(data.get("authoring_revision") or 0),
            created_at=data.get("created_at"),
            updated_at=data.get("updated_at"),
            deleted_at=data.get("deleted_at"),
            modules=sorted(modules, key=lambda x: x.order_index),
        )

    async def get_by_id(self, course_id: str) -> Optional[Course]:
        query = (
            self.client.table("courses")
            .select("*, modules(*, lessons(*, lesson_blocks(*)))")
            .eq("id", course_id)
            .is_("deleted_at", "null")
            .maybe_single()
        )
        res = await run_sync_io(query.execute)
        if res is None or not _response_data(res):
            return None
        course_data = typing.cast(dict[str, typing.Any], _response_data(res))
        lesson_ids = [
            lesson["id"]
            for module in course_data.get("modules", [])
            for lesson in module.get("lessons", [])
            if lesson.get("id")
        ]
        if lesson_ids:
            jobs_query = (
                self.client.table("video_processing_jobs")
                .select("lesson_id,status,created_at")
                .in_("lesson_id", lesson_ids)
                .order("created_at", desc=True)
            )
            jobs_response = await run_sync_io(jobs_query.execute)
            latest_status_by_lesson: dict[str, str] = {}
            for job in _response_data(jobs_response) or []:
                lesson_id = job.get("lesson_id")
                if lesson_id and lesson_id not in latest_status_by_lesson:
                    latest_status_by_lesson[lesson_id] = job["status"]
            for module in course_data.get("modules", []):
                for lesson in module.get("lessons", []):
                    lesson["video_job_status"] = latest_status_by_lesson.get(lesson.get("id"))
        return self._map_course(course_data)

    async def get_by_slug(self, slug: str) -> Optional[Course]:
        query = (
            self.client.table("courses")
            .select("*, modules(*, lessons(*, lesson_blocks(*)))")
            .eq("slug", slug)
            .is_("deleted_at", "null")
            .maybe_single()
        )
        res = await run_sync_io(query.execute)
        if res is None or not _response_data(res):
            return None
        return self._map_course(typing.cast(dict[str, typing.Any], _response_data(res)))

    async def get_instructor_id(self, course_id: str) -> Optional[str]:
        res = (
            self.client.table("courses")
            .select("instructor_id")
            .eq("id", course_id)
            .maybe_single()
            .execute()
        )
        if res is None or not _response_data(res):
            return None
        return typing.cast(dict[str, typing.Any], _response_data(res)).get("instructor_id")

    async def list_all(self) -> List[Course]:
        query = (
            self.client.table("courses")
            .select("*, modules(*, lessons(*, lesson_blocks(*)))")
            .is_("deleted_at", "null")
        )
        res = await run_sync_io(query.execute)
        return [
            self._map_course(typing.cast(dict[str, typing.Any], row))
            for row in (_response_data(res) or [])
        ]

    async def list_published_versions(self, *, limit: int = 50) -> List[Course]:
        safe_limit = max(1, min(limit, 50))
        courses_query = (
            self.client.table("courses")
            .select("id")
            .eq("status", "published")
            .is_("deleted_at", "null")
            .order("created_at", desc=True)
            .range(0, safe_limit - 1)
        )
        res = await run_sync_io(courses_query.execute)
        if not _response_data(res):
            return []

        course_ids = [row["id"] for row in _response_data(res)]

        # Busca snapshots das versÃƒÂµes publicadas atuais
        versions_query = (
            self.client.table("course_versions")
            .select("snapshot")
            .eq("is_current", True)
            .in_("course_id", course_ids)
            .order("version_number")
        )
        res_versions = await run_sync_io(versions_query.execute)

        if res_versions and _response_data(res_versions):
            courses = []
            for row in _response_data(res_versions):
                snapshot = row.get("snapshot")
                if snapshot:
                    courses.append(self._map_course(snapshot))
            if not courses:
                # Se nÃƒÂ£o houver snapshots criados ainda, busca os dados live
                live_query = (
                    self.client.table("courses")
                    .select("*, modules(*, lessons(*, lesson_blocks(*)))")
                    .in_("id", course_ids)
                )
                res_live = await run_sync_io(live_query.execute)
                courses = [self._map_course(row) for row in (_response_data(res_live) or [])]
            return courses
        else:
            live_query = (
                self.client.table("courses")
                .select("*, modules(*, lessons(*, lesson_blocks(*)))")
                .in_("id", course_ids)
            )
            res_live = await run_sync_io(live_query.execute)
            return [self._map_course(row) for row in (_response_data(res_live) or [])]

    async def get_published_by_id(self, course_id: str) -> Optional[Course]:
        query = (
            self.client.table("course_versions")
            .select("snapshot")
            .eq("course_id", course_id)
            .eq("is_current", True)
            .maybe_single()
        )
        res = await run_sync_io(query.execute)
        if not res or not _response_data(res) or not _response_data(res).get("snapshot"):
            return None
        return self._map_course(_response_data(res)["snapshot"])

    async def get_published_by_slug(self, slug: str) -> Optional[Course]:
        query = (
            self.client.table("courses")
            .select("id")
            .eq("slug", slug)
            .eq("status", "published")
            .is_("deleted_at", "null")
            .maybe_single()
        )
        res_course = await run_sync_io(query.execute)
        if not res_course or not _response_data(res_course):
            return None
        course_id = _response_data(res_course)["id"]
        return await self.get_published_by_id(course_id)

    async def get_published_lesson(self, course_id: str, lesson_id: str) -> Optional[Lesson]:
        course = await self.get_published_by_id(course_id)
        if not course:
            return None
        for module in course.modules:
            for lesson in module.lessons:
                if lesson.id == lesson_id:
                    return lesson
        return None

    async def get_published_lesson_stream_path(
        self, course_id: str, lesson_id: str
    ) -> Optional[str]:
        lesson = await self.get_published_lesson(course_id, lesson_id)
        if lesson:
            return lesson.hls_storage_path
        return None

    async def list_by_instructor(self, instructor_id: str) -> List[Course]:
        res = (
            self.client.table("courses")
            .select("*, modules(*, lessons(*, lesson_blocks(*)))")
            .eq("instructor_id", instructor_id)
            .is_("deleted_at", "null")
            .execute()
        )
        return [
            self._map_course(typing.cast(dict[str, typing.Any], row))
            for row in (_response_data(res) or [])
        ]

    async def create(
        self,
        course: Course,
        *,
        idempotency_key: str | None = None,
        request_hash: str | None = None,
    ) -> Course:
        self._register_authoring_request(
            actor_id=course.instructor_id,
            operation_scope="course:create",
            idempotency_key=idempotency_key,
            request_hash=request_hash,
            resource_id=course.id,
        )
        course_data = {
            "id": course.id,
            "instructor_id": course.instructor_id,
            "title": course.title,
            "slug": course.slug,
            "summary": course.summary,
            "course_type": course.course_type,
            "subtitle": course.subtitle,
            "language": course.language,
            "estimated_duration_minutes": course.estimated_duration_minutes,
            "category": course.category,
            "level": course.level,
            "description": course.description,
            "requirements": course.requirements,
            "learning_objectives": course.learning_objectives,
            "target_audience": course.target_audience,
            "required_materials": course.required_materials,
            "competencies": course.competencies,
            "expected_outcomes": course.expected_outcomes,
            "thumbnail_url": course.thumbnail_url,
            "trailer_hls_path": course.trailer_hls_path,
            "monthly_price": float(course.monthly_price),
            "promotional_monthly_price": (
                float(course.promotional_monthly_price)
                if course.promotional_monthly_price is not None
                else None
            ),
            "promotion_starts_at": course.promotion_starts_at,
            "promotion_ends_at": course.promotion_ends_at,
            "certificate_enabled": course.certificate_enabled,
            "reviews_enabled": course.reviews_enabled,
            "comments_enabled": course.comments_enabled,
            "visibility": course.visibility,
            "availability": course.availability,
            "scheduled_publish_at": course.scheduled_publish_at,
            "status": course.status,
        }
        try:
            res = (
                self.client.table("courses").insert(typing.cast(typing.Any, course_data)).execute()
            )
        except APIError as error:
            if error.code == "23505":
                if idempotency_key:
                    replay = (
                        self.client.table("courses")
                        .select("*, modules(*, lessons(*, lesson_blocks(*)))")
                        .eq("id", course.id)
                        .eq("instructor_id", course.instructor_id)
                        .maybe_single()
                        .execute()
                    )
                    if replay and _response_data(replay):
                        return self._map_course(_response_data(replay))
                raise ConflictError(
                    "JÃƒÆ’Ã‚Â¡ existe um curso com este slug. Escolha outro identificador."
                ) from error
            raise
        if not _response_data(res):
            raise NotFoundError("Erro ao criar curso.")
        return self._map_course(typing.cast(dict[str, typing.Any], _response_data(res)[0]))

    async def update(
        self, course_id: str, course: Course, expected_authoring_revision: int
    ) -> Course:
        course_data = {
            "instructor_id": course.instructor_id,
            "title": course.title,
            "slug": course.slug,
            "summary": course.summary,
            "course_type": course.course_type,
            "subtitle": course.subtitle,
            "language": course.language,
            "estimated_duration_minutes": course.estimated_duration_minutes,
            "category": course.category,
            "level": course.level,
            "description": course.description,
            "requirements": course.requirements,
            "learning_objectives": course.learning_objectives,
            "target_audience": course.target_audience,
            "required_materials": course.required_materials,
            "competencies": course.competencies,
            "expected_outcomes": course.expected_outcomes,
            "thumbnail_url": course.thumbnail_url,
            "trailer_hls_path": course.trailer_hls_path,
            "monthly_price": float(course.monthly_price),
            "promotional_monthly_price": (
                float(course.promotional_monthly_price)
                if course.promotional_monthly_price is not None
                else None
            ),
            "promotion_starts_at": course.promotion_starts_at,
            "promotion_ends_at": course.promotion_ends_at,
            "certificate_enabled": course.certificate_enabled,
            "reviews_enabled": course.reviews_enabled,
            "comments_enabled": course.comments_enabled,
            "visibility": course.visibility,
            "availability": course.availability,
            "scheduled_publish_at": course.scheduled_publish_at,
            "status": course.status,
            "authoring_revision": expected_authoring_revision + 1,
        }
        res = (
            self.client.table("courses")
            .update(typing.cast(typing.Any, course_data))
            .eq("id", course_id)
            .eq("instructor_id", course.instructor_id)
            .eq("authoring_revision", expected_authoring_revision)
            .execute()
        )
        if not _response_data(res):
            raise ConflictError("O curso foi alterado em outra sessão. Recarregue antes de salvar.")
        return self._map_course(typing.cast(dict[str, typing.Any], _response_data(res)[0]))

    async def delete(self, course_id: str) -> bool:
        from datetime import datetime, timezone

        res = (
            self.client.table("courses")
            .update({"deleted_at": datetime.now(timezone.utc).isoformat()})
            .eq("id", course_id)
            .execute()
        )
        return len(_response_data(res)) > 0

    async def get_lesson_by_id(self, course_id: str, lesson_id: str) -> Optional[Lesson]:
        res = (
            self.client.table("lessons")
            .select("*")
            .eq("id", lesson_id)
            .eq("course_id", course_id)
            .is_("deleted_at", "null")
            .maybe_single()
            .execute()
        )
        if res is None or not _response_data(res):
            return None
        return self._map_lesson(typing.cast(dict[str, typing.Any], _response_data(res)))

    async def create_lesson(
        self,
        lesson: Lesson,
        *,
        idempotency_key: str | None = None,
        request_hash: str | None = None,
        actor_id: str | None = None,
    ) -> Lesson:
        if actor_id:
            self._register_authoring_request(
                actor_id=actor_id,
                operation_scope=f"lesson:create:{lesson.course_id}:{lesson.module_id}",
                idempotency_key=idempotency_key,
                request_hash=request_hash,
                resource_id=lesson.id,
            )
        data = {
            "id": lesson.id,
            "module_id": lesson.module_id,
            "course_id": lesson.course_id,
            "title": lesson.title,
            "description": lesson.description,
            "order_index": lesson.order_index,
            "duration_seconds": lesson.duration_seconds,
            "status": lesson.status,
        }
        try:
            res = self.client.table("lessons").insert(data).execute()
        except APIError as error:
            if error.code == "23505" and idempotency_key and actor_id:
                replay = (
                    self.client.table("lessons")
                    .select("*")
                    .eq("id", lesson.id)
                    .eq("course_id", lesson.course_id)
                    .maybe_single()
                    .execute()
                )
                if replay and _response_data(replay):
                    return self._map_lesson(_response_data(replay))
            raise
        if not _response_data(res):
            raise NotFoundError("NÃƒÆ’Ã‚Â£o foi possÃƒÆ’Ã‚Â­vel criar a aula.")
        return self._map_lesson(typing.cast(dict[str, typing.Any], _response_data(res)[0]))

    async def update_lesson(self, lesson_id: str, lesson_data: dict) -> Lesson:
        res = (
            self.client.table("lessons")
            .update(lesson_data)
            .eq("id", lesson_id)
            .is_("deleted_at", "null")
            .execute()
        )
        if not _response_data(res):
            raise NotFoundError("Aula nÃƒÂ£o encontrada para atualizaÃƒÂ§ÃƒÂ£o.")
        return self._map_lesson(typing.cast(dict[str, typing.Any], _response_data(res)[0]))

    async def delete_lesson(self, lesson_id: str) -> bool:
        from datetime import datetime, timezone

        res = (
            self.client.table("lessons")
            .update(
                {
                    "deleted_at": datetime.now(timezone.utc).isoformat(),
                    "status": "archived",
                }
            )
            .eq("id", lesson_id)
            .is_("deleted_at", "null")
            .execute()
        )
        return len(_response_data(res) or []) > 0

    async def get_lesson_stream_path(self, course_id: str, lesson_id: str) -> Optional[str]:
        res = (
            self.client.table("lessons")
            .select("hls_storage_path")
            .eq("id", lesson_id)
            .eq("course_id", course_id)
            .maybe_single()
            .execute()
        )
        if res is None or not _response_data(res):
            return None
        return typing.cast(dict[str, typing.Any], _response_data(res)).get("hls_storage_path")

    async def get_module_by_id_and_course_id(
        self, module_id: str, course_id: str
    ) -> Optional[Module]:
        res = (
            self.client.table("modules")
            .select("*, lessons(*)")
            .eq("id", module_id)
            .eq("course_id", course_id)
            .is_("deleted_at", "null")
            .maybe_single()
            .execute()
        )
        if res is None or not _response_data(res):
            return None
        return self._map_module(typing.cast(dict[str, typing.Any], _response_data(res)))

    async def create_module(
        self,
        module: Module,
        *,
        idempotency_key: str | None = None,
        request_hash: str | None = None,
        actor_id: str | None = None,
    ) -> Module:
        if actor_id:
            self._register_authoring_request(
                actor_id=actor_id,
                operation_scope=f"module:create:{module.course_id}",
                idempotency_key=idempotency_key,
                request_hash=request_hash,
                resource_id=module.id,
            )
        module_data: typing.Any = {
            "id": module.id,
            "course_id": module.course_id,
            "title": module.title,
            "order_index": module.order_index,
        }
        try:
            res = self.client.table("modules").insert(module_data).execute()
        except APIError as error:
            if error.code == "23505" and idempotency_key and actor_id:
                replay = (
                    self.client.table("modules")
                    .select("*, lessons(*)")
                    .eq("id", module.id)
                    .eq("course_id", module.course_id)
                    .maybe_single()
                    .execute()
                )
                if replay and _response_data(replay):
                    return self._map_module(_response_data(replay))
            raise
        if not _response_data(res):
            raise NotFoundError("Erro ao criar mÃƒÂ³dulo.")
        return self._map_module(typing.cast(dict[str, typing.Any], _response_data(res)[0]))

    async def update_module(self, module_id: str, module_data: dict) -> Module:
        res = (
            self.client.table("modules")
            .update(module_data)
            .eq("id", module_id)
            .select("*, lessons(*)")
            .execute()
        )
        if not _response_data(res):
            raise NotFoundError("MÃƒÂ³dulo nÃƒÂ£o encontrado para atualizaÃƒÂ§ÃƒÂ£o.")
        return self._map_module(typing.cast(dict[str, typing.Any], _response_data(res)[0]))

    async def delete_module(self, module_id: str) -> bool:
        from datetime import datetime, timezone

        res = (
            self.client.table("modules")
            .update({"deleted_at": datetime.now(timezone.utc).isoformat()})
            .eq("id", module_id)
            .execute()
        )
        return len(_response_data(res)) > 0

    async def has_active_subscription(self, student_id: str, course_id: str) -> bool:
        from datetime import datetime, timezone

        query = (
            self.client.table("subscriptions")
            .select("status, current_period_end")
            .eq("student_id", student_id)
            .eq("course_id", course_id)
        )
        res = await run_sync_io(query.execute)

        if not _response_data(res):
            return False

        for sub in typing.cast(list[dict[str, typing.Any]], _response_data(res)):
            status = sub.get("status")
            if status == "active":
                return True

            current_period_end_str = sub.get("current_period_end")
            if current_period_end_str:
                current_period_end = datetime.fromisoformat(
                    current_period_end_str.replace("Z", "+00:00")
                )
                if current_period_end > datetime.now(timezone.utc):
                    return True

        return False

    async def generate_signed_url(self, storage_path: str) -> str:
        try:
            bucket = self.client.storage.from_("lessons-hls")
            res = await run_sync_io(bucket.create_signed_url, storage_path, 3600)
            signed_url = res.get("signedURL") or res.get("signedUrl")
            if not signed_url:
                from src.core.errors.errors import ExternalServiceError

                raise ExternalServiceError(
                    "Falha ao gerar URL de assinatura (vazia).",
                    provider="supabase-storage",
                    request_id=storage_path,
                )
            return to_public_supabase_url(str(signed_url))
        except Exception as exc:
            from src.core.errors.errors import ExternalServiceError

            raise ExternalServiceError(
                "Falha ao comunicar com Supabase Storage.",
                provider="supabase-storage",
                request_id=storage_path,
            ) from exc

    async def download_hls_asset(self, storage_path: str) -> bytes:
        try:
            bucket = self.client.storage.from_("lessons-hls")
            content = await run_sync_io(bucket.download, storage_path)
            return bytes(content)
        except Exception as exc:
            from src.core.errors.errors import ExternalServiceError

            raise ExternalServiceError(
                "Falha ao carregar mídia protegida.",
                provider="supabase-storage",
                request_id=storage_path,
            ) from exc

    async def get_publication_snapshot(self, course_id: str) -> dict:
        res = (
            self.client.table("courses")
            .select("*, modules(*, lessons(*, lesson_blocks(*)))")
            .eq("id", course_id)
            .is_("deleted_at", "null")
            .maybe_single()
            .execute()
        )
        if not res or not _response_data(res):
            return {}

        course_data = _response_data(res)
        lesson_ids = []
        for module_data in course_data.get("modules") or []:
            for lesson_data in module_data.get("lessons") or []:
                if lesson_data.get("id"):
                    lesson_ids.append(lesson_data["id"])

        pending_jobs = []
        failed_jobs = []
        if lesson_ids:
            res_jobs = (
                self.client.table("video_processing_jobs")
                .select("id, status, lesson_id")
                .in_("lesson_id", lesson_ids)
                .execute()
            )
            if res_jobs and _response_data(res_jobs):
                current_job_by_lesson = {
                    lesson_data.get("id"): lesson_data.get("pending_upload_job_id")
                    for module_data in course_data.get("modules") or []
                    for lesson_data in module_data.get("lessons") or []
                    if lesson_data.get("pending_upload_job_id")
                }
                current_jobs = [
                    job
                    for job in _response_data(res_jobs)
                    if current_job_by_lesson.get(job.get("lesson_id")) == job.get("id")
                ]
                pending_jobs = [
                    job
                    for job in current_jobs
                    if job.get("status") not in {"completed", "failed", "dead_letter"}
                ]
                failed_jobs = [
                    job
                    for job in current_jobs
                    if job.get("status") in {"failed", "dead_letter"}
                ]

        return {
            "course": course_data,
            "pending_jobs": pending_jobs,
            "failed_jobs": failed_jobs,
        }

    async def publish_course(
        self,
        course_id: str,
        actor_id: str,
        change_summary: str | None = None,
        idempotency_key: str | None = None,
        request_hash: str | None = None,
        expected_updated_at: str | None = None,
    ) -> Course:
        idempotency_key = (
            hashlib.sha256(idempotency_key.encode("utf-8")).hexdigest() if idempotency_key else None
        )
        try:
            self.client.rpc(
                "publish_course_idempotent",
                {
                    "p_course_id": course_id,
                    "p_actor_id": actor_id,
                    "p_idempotency_key": idempotency_key,
                    "p_request_hash": request_hash,
                    "p_expected_updated_at": expected_updated_at,
                    "p_change_summary": change_summary or "PublicaÃƒÂ§ÃƒÂ£o de versÃƒÂ£o",
                },
            ).execute()
        except APIError as error:
            if error.code in {"P0001", "40001"}:
                raise ConflictError(str(error)) from error
            if error.code == "42501":
                raise AuthorizationError("Acesso negado para publicar este curso.") from error
            raise

        updated = await self.get_by_id(course_id)
        if not updated:
            raise NotFoundError("Curso nÃƒÂ£o encontrado pÃƒÂ³s-publicaÃƒÂ§ÃƒÂ£o.")
        return updated

    async def transition_course_status(
        self, course_id: str, actor_id: str, target_status: str, reason: str | None
    ) -> str:
        res = self.client.rpc(
            "transition_course_status",
            {
                "p_course_id": course_id,
                "p_actor_id": actor_id,
                "p_target_status": target_status,
                "p_reason": reason,
            },
        ).execute()
        return str(_response_data(res))

    async def list_course_versions(self, course_id: str) -> list[dict]:
        res = (
            self.client.table("course_versions")
            .select("id, version_number, is_current, change_summary, created_at")
            .eq("course_id", course_id)
            .order("version_number", desc=True)
            .execute()
        )
        return _response_data(res) or []

    async def get_course_version(self, course_id: str, version_id: str) -> Optional[dict]:
        res = (
            self.client.table("course_versions")
            .select("*")
            .eq("course_id", course_id)
            .eq("id", version_id)
            .maybe_single()
            .execute()
        )
        return _response_data(res) if res else None

    async def restore_course_version(
        self,
        course_id: str,
        version_id: str,
        actor_id: str,
        expected_updated_at: str,
        reason: str | None,
    ) -> Course:
        try:
            rpc = self.client.rpc(
                "restore_course_version_to_authoring",
                {
                    "p_course_id": course_id,
                    "p_version_id": version_id,
                    "p_actor_id": actor_id,
                    "p_expected_updated_at": expected_updated_at,
                    "p_reason": reason,
                },
            )
            rpc.execute()
        except APIError as error:
            if error.code in {"P0001", "40001"}:
                raise ConflictError(str(error)) from error
            if error.code == "42501":
                raise AuthorizationError("Acesso negado para restaurar este curso.") from error
            raise

        updated = await self.get_by_id(course_id)
        if not updated:
            raise NotFoundError("Curso nÃƒÂ£o encontrado pÃƒÂ³s-restauraÃƒÂ§ÃƒÂ£o.")
        return updated

    async def create_lesson_block(
        self,
        block: LessonBlock,
        *,
        idempotency_key: str | None = None,
        request_hash: str | None = None,
        actor_id: str | None = None,
    ) -> LessonBlock:
        if actor_id:
            self._register_authoring_request(
                actor_id=actor_id,
                operation_scope=f"block:create:{block.course_id}:{block.lesson_id}",
                idempotency_key=idempotency_key,
                request_hash=request_hash,
                resource_id=block.id,
            )
        data = {
            "id": block.id,
            "lesson_id": block.lesson_id,
            "course_id": block.course_id,
            "block_type": block.block_type,
            "content": block.content,
            "order_index": block.order_index,
        }
        try:
            res = self.client.table("lesson_blocks").insert(typing.cast(typing.Any, data)).execute()
        except APIError as error:
            if error.code == "23505" and idempotency_key and actor_id:
                replay = (
                    self.client.table("lesson_blocks")
                    .select("*")
                    .eq("id", block.id)
                    .eq("course_id", block.course_id)
                    .maybe_single()
                    .execute()
                )
                if replay and _response_data(replay):
                    return self._map_lesson_block(_response_data(replay))
            raise
        if not _response_data(res):
            raise NotFoundError("NÃƒÂ£o foi possÃƒÂ­vel criar o bloco.")
        return self._map_lesson_block(_response_data(res)[0])

    async def update_lesson_block(self, block_id: str, data: dict) -> LessonBlock:
        res = (
            self.client.table("lesson_blocks")
            .update(data)
            .eq("id", block_id)
            .is_("deleted_at", "null")
            .execute()
        )
        if not _response_data(res):
            raise NotFoundError("Bloco nÃƒÂ£o encontrado para atualizaÃƒÂ§ÃƒÂ£o.")
        return self._map_lesson_block(_response_data(res)[0])

    async def get_lesson_block(
        self, course_id: str, lesson_id: str, block_id: str
    ) -> Optional[LessonBlock]:
        res = (
            self.client.table("lesson_blocks")
            .select("*")
            .eq("id", block_id)
            .eq("lesson_id", lesson_id)
            .eq("course_id", course_id)
            .is_("deleted_at", "null")
            .maybe_single()
            .execute()
        )
        if not res or not _response_data(res):
            return None
        return self._map_lesson_block(_response_data(res))

    async def delete_lesson_block(self, block_id: str) -> bool:
        from datetime import datetime, timezone

        res = (
            self.client.table("lesson_blocks")
            .update({"deleted_at": datetime.now(timezone.utc).isoformat()})
            .eq("id", block_id)
            .is_("deleted_at", "null")
            .execute()
        )
        return len(_response_data(res) or []) > 0

    async def list_lesson_blocks(self, course_id: str, lesson_id: str) -> List[LessonBlock]:
        res = (
            self.client.table("lesson_blocks")
            .select("*")
            .eq("lesson_id", lesson_id)
            .eq("course_id", course_id)
            .is_("deleted_at", "null")
            .order("order_index")
            .execute()
        )
        return [self._map_lesson_block(row) for row in (_response_data(res) or [])]

    async def reorder_lesson_blocks(
        self,
        course_id: str,
        lesson_id: str,
        actor_id: str,
        block_ids: list[str],
        expected_revision: int,
    ) -> int:
        try:
            response = self.client.rpc(
                "reorder_lesson_blocks_atomic",
                {
                    "p_course_id": course_id,
                    "p_lesson_id": lesson_id,
                    "p_actor_id": actor_id,
                    "p_block_ids": block_ids,
                    "p_expected_revision": expected_revision,
                },
            ).execute()
        except APIError as error:
            if error.code in {"P0001", "40001"}:
                raise ConflictError(str(error)) from error
            if error.code == "42501":
                raise AuthorizationError("Acesso negado para reordenar esta aula.") from error
            if error.code == "P0002":
                raise NotFoundError("Curso ou aula nÃ£o encontrado.") from error
            raise
        return int(_response_data(response))
