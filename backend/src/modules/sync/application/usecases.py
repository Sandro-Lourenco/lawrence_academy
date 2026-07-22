import logging
import uuid
from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP

from src.modules.sync.domain.entities import LessonProgress
from src.modules.sync.domain.repositories import (
    LessonProgressRepository,
    SyncEventRepository,
)
from src.modules.sync.domain.validators import AntiFraudProgressValidator

from .dtos import (
    DownloadTokenRequest,
    DownloadTokenResponse,
    ProgressPayload,
    ProgressWriteRequest,
    SyncBatchRequest,
    SyncBatchResponse,
    SyncEventResponseDTO,
)

logger = logging.getLogger(__name__)


class ProgressValidationError(ValueError):
    pass


def _canonical_progress_percentage(
    *, watched_seconds: int, duration_seconds: int
) -> Decimal:
    return (
        Decimal(watched_seconds) * Decimal(100) / Decimal(duration_seconds)
    ).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


class TelemetryAggregationService:
    def __init__(self, event_repository: SyncEventRepository):
        self.event_repository = event_repository

    async def process_event(self, user_id: str, event: dict) -> bool:
        payload = event.get("payload", {})
        return self.event_repository.append_event(
            event_type=event["action"],
            event_id=event["id"],
            idempotency_key=event["idempotency_key"],
            correlation_id=payload.get("correlation_id", str(uuid.uuid4())),
            device_id=payload.get("device_id", "unknown"),
            user_id=user_id,
            payload=payload,
            occurred_at=datetime.fromtimestamp(
                event["created_at"], tz=timezone.utc
            ).isoformat(),
            origin="offline_sync",
            lesson_id=payload.get("lesson_id"),
            course_id=payload.get("course_id"),
        )


class ProcessLessonProgressEventUseCase:
    def __init__(self, repository: LessonProgressRepository):
        self.repository = repository
        self.validator = AntiFraudProgressValidator()

    async def execute(self, student_id: str, event: dict) -> LessonProgress:
        payload = ProgressPayload.model_validate(event.get("payload", {}))
        payload_dict = payload.model_dump(mode="json")
        if not self.validator.validate_progress(
            payload_dict, event.get("created_at", 0)
        ):
            raise ProgressValidationError("Invalid lesson progress event")

        completed = payload.completed or event["action"] == "LESSON_COMPLETED"
        percentage = self._validate_and_calculate(payload, completed=completed)
        payload_dict["progress_percentage"] = str(percentage)
        return self.repository.merge_event(
            student_id=student_id,
            course_id=payload.course_id,
            lesson_id=payload.lesson_id,
            watched_seconds=payload.watched_seconds,
            progress_percentage=percentage,
            completed=completed,
            completed_at=payload.completed_at,
            event_id=event["id"],
            idempotency_key=event["idempotency_key"],
            correlation_id=payload.correlation_id,
            device_id=payload.device_id,
            occurred_at=datetime.fromtimestamp(event["created_at"], tz=timezone.utc),
            payload=payload_dict,
        )

    def _validate_and_calculate(
        self, payload: ProgressPayload, *, completed: bool
    ) -> Decimal:
        context = self.repository.get_lesson_context(payload.lesson_id)
        if context is None:
            raise ProgressValidationError("Lesson not found")
        if context.course_id != payload.course_id:
            raise ProgressValidationError("Lesson does not belong to course")
        if context.duration_seconds <= 0:
            raise ProgressValidationError("Lesson duration is unavailable")
        if payload.watched_seconds > context.duration_seconds:
            raise ProgressValidationError("watched_seconds exceeds lesson duration")
        if completed and payload.watched_seconds < context.duration_seconds:
            raise ProgressValidationError("Completed lesson requires full duration")

        percentage = _canonical_progress_percentage(
            watched_seconds=payload.watched_seconds,
            duration_seconds=context.duration_seconds,
        )
        if (
            payload.progress_percentage is not None
            and abs(payload.progress_percentage - percentage) > Decimal("0.01")
        ):
            raise ProgressValidationError(
                "progress_percentage is inconsistent with watched_seconds"
            )
        return percentage


class ListLessonProgressUseCase:
    def __init__(self, repository: LessonProgressRepository):
        self.repository = repository

    def execute(self, student_id: str) -> list[LessonProgress]:
        return self.repository.list_for_student(student_id)


class UpdateLessonProgressUseCase:
    def __init__(self, repository: LessonProgressRepository):
        self.repository = repository

    def execute(
        self, student_id: str, request: ProgressWriteRequest
    ) -> LessonProgress:
        percentage = ProcessLessonProgressEventUseCase(
            self.repository
        )._validate_and_calculate(request, completed=request.completed)
        payload = request.model_dump(
            mode="json",
            exclude={"event_id", "idempotency_key", "occurred_at"},
        )
        payload["progress_percentage"] = str(percentage)
        return self.repository.merge_event(
            student_id=student_id,
            course_id=request.course_id,
            lesson_id=request.lesson_id,
            watched_seconds=request.watched_seconds,
            progress_percentage=percentage,
            completed=request.completed,
            completed_at=request.completed_at,
            event_id=request.event_id,
            idempotency_key=request.idempotency_key,
            correlation_id=request.correlation_id,
            device_id=request.device_id,
            occurred_at=request.occurred_at,
            payload=payload,
        )


class ProcessSyncBatchUseCase:
    def __init__(
        self,
        progress_repository: LessonProgressRepository,
        event_repository: SyncEventRepository,
    ):
        self.progress_use_case = ProcessLessonProgressEventUseCase(
            progress_repository
        )
        self.telemetry_service = TelemetryAggregationService(event_repository)

    async def execute(
        self, student_id: str, request: SyncBatchRequest
    ) -> SyncBatchResponse:
        results: list[SyncEventResponseDTO] = []
        for event in request.events:
            event_dict = event.model_dump()
            try:
                if event.action in {
                    "UPDATE_LESSON_PROGRESS",
                    "LESSON_COMPLETED",
                }:
                    await self.progress_use_case.execute(student_id, event_dict)
                else:
                    await self.telemetry_service.process_event(
                        student_id, event_dict
                    )
                results.append(SyncEventResponseDTO(id=event.id, status="COMPLETED"))
            except Exception as error:
                logger.warning(
                    "Sync event rejected event_id=%s error=%s",
                    event.id,
                    type(error).__name__,
                )
                results.append(
                    SyncEventResponseDTO(
                        id=event.id,
                        status="FAILED",
                        error_message="Validation or persistence failed",
                    )
                )
        return SyncBatchResponse(results=results)


class GenerateDownloadTokenUseCase:
    async def execute(
        self, user_id: str, request: DownloadTokenRequest
    ) -> DownloadTokenResponse:
        from src.core.security.jwt_download_service import JwtDownloadService
        from src.modules.sync.infrastructure.repositories import DownloadTokenRepository
        from src.shared import database

        correlation_id = str(uuid.uuid4())
        jwt_service = JwtDownloadService()
        token_repository = DownloadTokenRepository()
        duration_seconds = 900
        download_id = str(uuid.uuid4())

        token_data = jwt_service.generate_download_token(
            user_id=user_id,
            course_id=request.course_id,
            lesson_id=request.lesson_id,
            installation_id=request.device_id,
            duration_seconds=duration_seconds,
        )
        token = token_data["token"]
        payload = token_data["payload"]
        token_repository.register_token(
            jti=payload["jti"],
            user_id=user_id,
            lesson_id=request.lesson_id,
            expires_at=payload["exp"],
        )

        signed_hls_url = (
            "https://mock.supabase.co/storage/v1/object/sign/lessons/"
            f"{request.course_id}/{request.lesson_id}/index.m3u8?token=mock"
        )
        try:
            result = database.db.storage.from_("lessons").create_signed_url(
                f"{request.course_id}/{request.lesson_id}/index.m3u8",
                duration_seconds,
            )
            if isinstance(result, dict) and "signedURL" in result:
                signed_hls_url = str(result["signedURL"])
            elif hasattr(result, "signed_url"):
                signed_hls_url = str(result.signed_url)
            else:
                signed_hls_url = str(result)
        except Exception as error:
            logger.error(
                "Signed URL generation failed correlation_id=%s error=%s",
                correlation_id,
                type(error).__name__,
            )

        return DownloadTokenResponse(
            download_token=token,
            signed_url=signed_hls_url,
            expires_at=payload["exp"],
            license_expires_at=payload["iat"] + (30 * 24 * 3600),
            download_id=download_id,
        )
