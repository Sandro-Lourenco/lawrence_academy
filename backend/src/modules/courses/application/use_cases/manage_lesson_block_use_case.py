import uuid
from typing import List

from src.core.errors.errors import AuthorizationError, NotFoundError, ValidationError
from src.modules.courses.domain.entities import LessonBlock
from src.modules.courses.domain.repositories import CourseRepository
from src.modules.courses.application.idempotency import deterministic_resource_id, request_fingerprint


class ManageLessonBlockUseCase:
    def __init__(self, repository: CourseRepository):
        self.repository = repository

    async def _authorize(self, course_id: str, lesson_id: str, user_id: str, role: str):
        lesson = await self.repository.get_lesson_by_id(course_id, lesson_id)
        if not lesson:
            raise NotFoundError("Aula não encontrada neste curso.")
        owner = await self.repository.get_instructor_id(course_id)
        if role != "super_admin" and owner != user_id:
            raise AuthorizationError("Apenas o instrutor pode editar o conteúdo desta aula.")
        return lesson

    async def create(
        self,
        *,
        course_id: str,
        lesson_id: str,
        data: dict,
        user_id: str,
        role: str,
        idempotency_key: str | None = None,
    ):
        await self._authorize(course_id, lesson_id, user_id, role)
        self._validate_storage_path(course_id, lesson_id, data.get("content", {}))
        block = LessonBlock(
            id=(
                deterministic_resource_id(f"block:{course_id}:{lesson_id}", idempotency_key)
                if idempotency_key else str(uuid.uuid4())
            ),
            lesson_id=lesson_id,
            course_id=course_id,
            block_type=data["block_type"],
            content=data.get("content", {}),
            order_index=data.get("order_index", 0),
            status=data.get("status", "draft"),
        )
        if not idempotency_key:
            return await self.repository.create_lesson_block(block)
        return await self.repository.create_lesson_block(
            block,
            idempotency_key=idempotency_key,
            request_hash=request_fingerprint(data) if idempotency_key else None,
            actor_id=user_id,
        )

    async def list(self, *, course_id: str, lesson_id: str, user_id: str, role: str):
        await self._authorize(course_id, lesson_id, user_id, role)
        return await self.repository.list_lesson_blocks(course_id, lesson_id)

    async def update(
        self, *, course_id: str, lesson_id: str, block_id: str, data: dict, user_id: str, role: str
    ):
        await self._authorize(course_id, lesson_id, user_id, role)
        block = await self.repository.get_lesson_block(course_id, lesson_id, block_id)
        if not block:
            raise NotFoundError("Bloco não encontrado nesta aula.")
        if "content" in data:
            self._validate_storage_path(course_id, lesson_id, data["content"])
        allowed = {"block_type", "content", "order_index", "status"}
        return await self.repository.update_lesson_block(
            block_id, {key: value for key, value in data.items() if key in allowed}
        )

    async def duplicate(
        self, *, course_id: str, lesson_id: str, block_id: str, user_id: str, role: str,
        idempotency_key: str | None = None,
    ):
        await self._authorize(course_id, lesson_id, user_id, role)
        source = await self.repository.get_lesson_block(course_id, lesson_id, block_id)
        if not source:
            raise NotFoundError("Bloco não encontrado nesta aula.")
        return await self.create(
            course_id=course_id,
            lesson_id=lesson_id,
            user_id=user_id,
            role=role,
            idempotency_key=idempotency_key,
            data={
                "block_type": source.block_type,
                "content": source.content,
                "order_index": source.order_index + 1,
                "status": "draft",
            },
        )

    async def delete(
        self, *, course_id: str, lesson_id: str, block_id: str, user_id: str, role: str
    ):
        await self._authorize(course_id, lesson_id, user_id, role)
        block = await self.repository.get_lesson_block(course_id, lesson_id, block_id)
        if not block:
            raise NotFoundError("Bloco não encontrado nesta aula.")
        return await self.repository.delete_lesson_block(block_id)

    async def reorder(
        self,
        *,
        course_id: str,
        lesson_id: str,
        block_ids: List[str],
        expected_revision: int,
        user_id: str,
        role: str,
    ) -> dict[str, int]:
        await self._authorize(course_id, lesson_id, user_id, role)
        if not block_ids or len(block_ids) != len(set(block_ids)):
            raise ValidationError("Informe cada bloco ativo exatamente uma vez.")
        revision = await self.repository.reorder_lesson_blocks(
            course_id, lesson_id, user_id, block_ids, expected_revision
        )
        return {"authoring_revision": revision}

    @staticmethod
    def _validate_storage_path(course_id: str, lesson_id: str, content: dict) -> None:
        path = content.get("storage_path")
        if path and not path.startswith(f"courses/{course_id}/lessons/{lesson_id}/"):
            raise ValidationError("O arquivo não pertence a esta aula.")
