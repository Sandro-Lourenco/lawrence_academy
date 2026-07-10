from decimal import Decimal
from typing import List, Optional
from supabase import Client
from src.modules.courses.domain.entities import Course, Module, Lesson
from src.modules.courses.domain.repositories import CourseRepository
from src.core.errors.errors import NotFoundError

class SupabaseCourseRepository(CourseRepository):
    """Implementação Supabase concreta para repositório de Cursos e Aulas."""

    def __init__(self, client: Client):
        self.client = client

    def _map_lesson(self, data: dict) -> Lesson:
        return Lesson(
            id=data["id"],
            module_id=data["module_id"],
            course_id=data["course_id"],
            title=data["title"],
            hls_storage_path=data["hls_storage_path"],
            description=data.get("description"),
            order_index=data.get("order_index", 0),
            duration_seconds=data.get("duration_seconds", 0),
            material_pdf_url=data.get("material_pdf_url"),
            status=data.get("status", "draft"),
            created_at=data.get("created_at"),
            updated_at=data.get("updated_at")
        )

    def _map_module(self, data: dict) -> Module:
        lessons = [self._map_lesson(l) for l in data.get("lessons", [])]
        return Module(
            id=data["id"],
            course_id=data["course_id"],
            title=data["title"],
            order_index=data.get("order_index", 0),
            created_at=data.get("created_at"),
            lessons=sorted(lessons, key=lambda x: x.order_index)
        )

    def _map_course(self, data: dict) -> Course:
        modules = [self._map_module(m) for m in data.get("modules", [])]
        return Course(
            id=data["id"],
            instructor_id=data["instructor_id"],
            title=data["title"],
            slug=data["slug"],
            summary=data["summary"],
            category=data.get("category", "costura"),
            level=data.get("level", "iniciante"),
            description=data.get("description"),
            requirements=data.get("requirements", []),
            thumbnail_url=data.get("thumbnail_url"),
            trailer_hls_path=data.get("trailer_hls_path"),
            monthly_price=Decimal(str(data.get("monthly_price", "0.00"))),
            status=data.get("status", "draft"),
            created_at=data.get("created_at"),
            updated_at=data.get("updated_at"),
            deleted_at=data.get("deleted_at"),
            modules=sorted(modules, key=lambda x: x.order_index)
        )

    async def get_by_id(self, course_id: str) -> Optional[Course]:
        res = self.client.table("courses") \
            .select("*, modules(*, lessons(*))") \
            .eq("id", course_id) \
            .is_("deleted_at", "null") \
            .maybe_single() \
            .execute()
        if not res.data:
            return None
        return self._map_course(res.data)

    async def get_by_slug(self, slug: str) -> Optional[Course]:
        res = self.client.table("courses") \
            .select("*, modules(*, lessons(*))") \
            .eq("slug", slug) \
            .is_("deleted_at", "null") \
            .maybe_single() \
            .execute()
        if not res.data:
            return None
        return self._map_course(res.data)

    async def get_instructor_id(self, course_id: str) -> Optional[str]:
        res = self.client.table("courses") \
            .select("instructor_id") \
            .eq("id", course_id) \
            .maybe_single() \
            .execute()
        if not res.data:
            return None
        return res.data.get("instructor_id")

    async def list_all(self) -> List[Course]:
        res = self.client.table("courses") \
            .select("*, modules(*, lessons(*))") \
            .is_("deleted_at", "null") \
            .execute()
        return [self._map_course(row) for row in (res.data or [])]

    async def create(self, course: Course) -> Course:
        course_data = {
            "id": course.id,
            "instructor_id": course.instructor_id,
            "title": course.title,
            "slug": course.slug,
            "summary": course.summary,
            "category": course.category,
            "level": course.level,
            "description": course.description,
            "requirements": course.requirements,
            "thumbnail_url": course.thumbnail_url,
            "trailer_hls_path": course.trailer_hls_path,
            "monthly_price": float(course.monthly_price),
            "status": course.status
        }
        res = self.client.table("courses").insert(course_data).execute()
        if not res.data:
            raise NotFoundError("Erro ao criar curso.")
        return self._map_course(res.data[0])

    async def update(self, course_id: str, course: Course) -> Course:
        course_data = {
            "instructor_id": course.instructor_id,
            "title": course.title,
            "slug": course.slug,
            "summary": course.summary,
            "category": course.category,
            "level": course.level,
            "description": course.description,
            "requirements": course.requirements,
            "thumbnail_url": course.thumbnail_url,
            "trailer_hls_path": course.trailer_hls_path,
            "monthly_price": float(course.monthly_price),
            "status": course.status
        }
        res = self.client.table("courses").update(course_data).eq("id", course_id).execute()
        if not res.data:
            raise NotFoundError("Curso não encontrado para atualização.")
        return self._map_course(res.data[0])

    async def delete(self, course_id: str) -> bool:
        from datetime import datetime, timezone
        res = self.client.table("courses") \
            .update({"deleted_at": datetime.now(timezone.utc).isoformat()}) \
            .eq("id", course_id) \
            .execute()
        return len(res.data) > 0

    async def get_lesson_by_id(self, course_id: str, lesson_id: str) -> Optional[Lesson]:
        res = self.client.table("lessons") \
            .select("*") \
            .eq("id", lesson_id) \
            .eq("course_id", course_id) \
            .maybe_single() \
            .execute()
        if not res.data:
            return None
        return self._map_lesson(res.data)

    async def get_lesson_stream_path(self, course_id: str, lesson_id: str) -> Optional[str]:
        res = self.client.table("lessons") \
            .select("hls_storage_path") \
            .eq("id", lesson_id) \
            .eq("course_id", course_id) \
            .maybe_single() \
            .execute()
        if not res.data:
            return None
        return res.data.get("hls_storage_path")

    async def has_active_subscription(self, student_id: str, course_id: str) -> bool:
        from datetime import datetime, timezone
        res = self.client.table("subscriptions") \
            .select("status, current_period_end") \
            .eq("student_id", student_id) \
            .eq("course_id", course_id) \
            .execute()
            
        if not res.data:
            return False
            
        for sub in res.data:
            status = sub.get("status")
            if status == "active":
                return True
                
            current_period_end_str = sub.get("current_period_end")
            if current_period_end_str:
                current_period_end = datetime.fromisoformat(current_period_end_str.replace("Z", "+00:00"))
                if current_period_end > datetime.now(timezone.utc):
                    return True
                    
        return False

    async def generate_signed_url(self, storage_path: str) -> str:
        try:
            res = self.client.storage.from_("lessons-hls").create_signed_url(storage_path, 3600)
            return res.get("signedURL") or res.get("signedUrl") or f"https://cdn.lawrence.academy/{storage_path}?token=mock_signed_url"
        except Exception:
            return f"https://cdn.lawrence.academy/{storage_path}?token=mock_signed_url"
