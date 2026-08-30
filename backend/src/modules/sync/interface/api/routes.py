from fastapi import APIRouter, Depends, HTTPException, status

from src.core.concurrency import run_sync_io
from src.core.security.security import CurrentUser, get_current_user
from src.modules.courses.application.access_policy import ensure_student_course_access
from src.modules.courses.domain.repositories import CourseRepository
from src.modules.courses.interface.api.dependencies import get_course_repository
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
    course_repository: CourseRepository = Depends(get_course_repository),
):
    checked_courses: set[str] = set()
    for event in request.events:
        if event.action not in {"UPDATE_LESSON_PROGRESS", "LESSON_COMPLETED"}:
            continue
        course_id = event.payload.get("course_id")
        if isinstance(course_id, str) and course_id not in checked_courses:
            await ensure_student_course_access(
                course_repository,
                student_id=current_user.id,
                course_id=course_id,
            )
            checked_courses.add(course_id)
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
    course_repository: CourseRepository = Depends(get_course_repository),
):
    return await run_sync_io(
        ListLessonProgressUseCase(repository).execute,
        current_user.id,
    )


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
    await ensure_student_course_access(
        course_repository,
        student_id=current_user.id,
        course_id=request.course_id,
    )
    try:
        return await run_sync_io(
            UpdateLessonProgressUseCase(repository).execute,
            current_user.id,
            request,
        )
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
    course_repository: CourseRepository = Depends(get_course_repository),
):
    await ensure_student_course_access(
        course_repository,
        student_id=current_user.id,
        course_id=request.course_id,
    )
    lesson = await course_repository.get_published_lesson(
        request.course_id, request.lesson_id
    )
    if lesson is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Aula publicada não encontrada.",
        )
    return await GenerateDownloadTokenUseCase().execute(current_user.id, request)
