from fastapi import APIRouter, Depends, HTTPException, status

from src.core.security.security import CurrentUser, get_current_user
from src.modules.sync.application.dtos import (
    DownloadTokenRequest,
    DownloadTokenResponse,
    LessonProgressResponse,
    ProgressWriteRequest,
    SyncBatchRequest,
    SyncBatchResponse,
)
from src.modules.sync.application.usecases import (
    GenerateDownloadTokenUseCase,
    ListLessonProgressUseCase,
    ProcessSyncBatchUseCase,
    ProgressValidationError,
    UpdateLessonProgressUseCase,
)
from src.modules.sync.domain.repositories import (
    LessonProgressRepository,
    SyncEventRepository,
)
from src.modules.sync.interface.api.dependencies import (
    get_lesson_progress_repository,
    get_sync_event_repository,
)

router = APIRouter(prefix="/api/v1/offline", tags=["Offline Sync"])


@router.post("/sync", response_model=SyncBatchResponse, status_code=status.HTTP_200_OK)
async def sync_offline_batch(
    request: SyncBatchRequest,
    current_user: CurrentUser = Depends(get_current_user),
    progress_repository: LessonProgressRepository = Depends(
        get_lesson_progress_repository
    ),
    event_repository: SyncEventRepository = Depends(get_sync_event_repository),
):
    usecase = ProcessSyncBatchUseCase(progress_repository, event_repository)
    return await usecase.execute(current_user.id, request)


@router.get(
    "/progress",
    response_model=list[LessonProgressResponse],
    status_code=status.HTTP_200_OK,
)
async def list_lesson_progress(
    current_user: CurrentUser = Depends(get_current_user),
    repository: LessonProgressRepository = Depends(
        get_lesson_progress_repository
    ),
):
    return ListLessonProgressUseCase(repository).execute(current_user.id)


@router.patch(
    "/progress/{lesson_id}",
    response_model=LessonProgressResponse,
    status_code=status.HTTP_200_OK,
)
async def update_lesson_progress(
    lesson_id: str,
    request: ProgressWriteRequest,
    current_user: CurrentUser = Depends(get_current_user),
    repository: LessonProgressRepository = Depends(
        get_lesson_progress_repository
    ),
):
    if lesson_id != request.lesson_id:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail="lesson_id does not match request payload",
        )
    try:
        return UpdateLessonProgressUseCase(repository).execute(current_user.id, request)
    except ProgressValidationError as error:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=str(error),
        ) from error


@router.post(
    "/download-token",
    response_model=DownloadTokenResponse,
    status_code=status.HTTP_200_OK,
)
async def generate_download_token(
    request: DownloadTokenRequest,
    current_user: CurrentUser = Depends(get_current_user),
):
    return await GenerateDownloadTokenUseCase().execute(current_user.id, request)
