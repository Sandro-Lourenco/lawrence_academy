from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime


class Certificate(BaseModel):
    id: str
    student_id: str
    course_id: str
    validation_code: str
    signature: str
    signature_algorithm: str
    signature_version: int
    revoked_at: Optional[datetime] = None
    revocation_reason: Optional[str] = None
    metadata: Dict[str, Any]
    issued_at: datetime
