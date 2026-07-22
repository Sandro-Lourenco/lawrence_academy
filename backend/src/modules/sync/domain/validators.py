import time
import logging
from decimal import Decimal, InvalidOperation
from typing import Dict, Any

logger = logging.getLogger(__name__)


class AntiFraudProgressValidator:
    """
    Validates offline progress events to prevent fraud.
    Ensures timestamps make sense and progress doesn't exceed 100%.
    """

    def __init__(self):
        pass

    def validate_progress(
        self, event_payload: Dict[str, Any], event_timestamp: int
    ) -> bool:
        """
        Validates if the progress increment is mathematically possible.
        """
        progress_percentage = event_payload.get("progress_percentage")
        if progress_percentage is not None:
            try:
                numeric_progress = Decimal(str(progress_percentage))
            except (InvalidOperation, ValueError):
                logger.warning("Anti-fraud: progress_percentage is not numeric")
                return False

            if not (0 <= numeric_progress <= 100):
                logger.warning(
                    "Anti-fraud: Progress out of bounds: %s", progress_percentage
                )
                return False

        # 2. Check future timestamps
        current_time = int(time.time())
        if event_timestamp > current_time + 300:  # allow 5 mins drift
            logger.warning(f"Anti-fraud: Future timestamp detected: {event_timestamp}")
            return False

        # 3. Time elapsed vs progress (simplified for MVP, we'd need video duration)
        # If we had video duration, we would check if (current_progress - last_progress) / 100 * duration <= time_elapsed * 1.5

        return True


class ConflictResolver:
    """
    Implements LWW (Last Write Wins) and MAX(progress) strategies for merging.
    """

    @staticmethod
    def resolve_lesson_progress(
        remote_progress: int, local_progress: int, remote_status: str, local_status: str
    ) -> tuple[int, str]:
        """
        Resolves conflicts between local and remote lesson progress.
        Returns (resolved_progress, resolved_status)
        """
        resolved_progress = max(remote_progress, local_progress)

        # If local says completed, we trust it over IN_PROGRESS due to offline nature,
        # assuming it passed anti-fraud validation.
        if local_status == "COMPLETED" or remote_status == "COMPLETED":
            return (100, "COMPLETED")

        return (
            resolved_progress,
            local_status if local_progress > remote_progress else remote_status,
        )
