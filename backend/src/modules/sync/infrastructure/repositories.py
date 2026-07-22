import time
from src.shared import database
import logging

logger = logging.getLogger(__name__)


class DownloadTokenRepository:
    def __init__(self):
        self.db = (
            database.db
        )  # Assumption: global Supabase client instance in shared module

    def register_token(
        self, jti: str, user_id: str, lesson_id: str, expires_at: int
    ) -> bool:
        """
        Registra um novo token emitido.
        Status inicial: ACTIVE
        """
        try:
            now = int(time.time())
            data = {
                "jti": jti,
                "user_id": user_id,
                "lesson_id": lesson_id,
                "issued_at": now,
                "expires_at": expires_at,
                "status": "ACTIVE",
            }
            # Using upsert just in case, but it should be a unique JTI
            self.db.table("download_tokens").insert(data).execute()
            return True
        except Exception as e:
            logger.error(f"Error registering download token {jti}: {e}")
            return False

    def mark_as_used(self, jti: str) -> bool:
        """
        Marca o JTI como USED de forma transacional. Lança exceção se não estiver ACTIVE.
        Isso é crítico para prevenir Replay de geração de licença/url.
        """
        try:
            # First, check if it's ACTIVE
            response = (
                self.db.table("download_tokens")
                .select("status")
                .eq("jti", jti)
                .execute()
            )
            if not response.data or response.data[0].get("status") != "ACTIVE":
                logger.warning(f"Attempted to use invalid or non-ACTIVE token: {jti}")
                return False

            # Update to USED
            update_res = (
                self.db.table("download_tokens")
                .update({"status": "USED"})
                .eq("jti", jti)
                .eq("status", "ACTIVE")
                .execute()
            )
            if not update_res.data:
                return False

            return True
        except Exception as e:
            logger.error(f"Error marking token {jti} as used: {e}")
            return False
