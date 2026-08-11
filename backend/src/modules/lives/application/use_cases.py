from src.core.errors.errors import AuthorizationError, NotFoundError
from src.modules.lives.domain.entities import LiveEvent
from src.modules.lives.domain.repositories import LiveEventRepository


class ListPublicLiveEventsUseCase:
    def __init__(self, repository: LiveEventRepository):
        self.repository = repository

    async def execute(self) -> list[LiveEvent]:
        return await self.repository.list_public()


class ListTeacherLiveEventsUseCase:
    def __init__(self, repository: LiveEventRepository):
        self.repository = repository

    async def execute(self, user_id: str, role: str) -> list[LiveEvent]:
        return await self.repository.list_for_teacher(user_id, role == "super_admin")


class CreateLiveEventUseCase:
    def __init__(self, repository: LiveEventRepository):
        self.repository = repository

    async def execute(self, instructor_id: str, data: dict) -> LiveEvent:
        return await self.repository.create(instructor_id, data)


class UpdateLiveEventUseCase:
    def __init__(self, repository: LiveEventRepository):
        self.repository = repository

    async def execute(self, event_id: str, data: dict, user_id: str, role: str) -> LiveEvent:
        event = await self.repository.get_by_id(event_id)
        if event is None:
            raise NotFoundError("Evento não encontrado.")
        if role != "super_admin" and event.instructor_id != user_id:
            raise AuthorizationError()
        return await self.repository.update(event_id, data)


class DeleteLiveEventUseCase:
    def __init__(self, repository: LiveEventRepository):
        self.repository = repository

    async def execute(self, event_id: str, user_id: str, role: str) -> None:
        event = await self.repository.get_by_id(event_id)
        if event is None:
            raise NotFoundError("Evento não encontrado.")
        if role != "super_admin" and event.instructor_id != user_id:
            raise AuthorizationError()
        await self.repository.delete(event_id)
