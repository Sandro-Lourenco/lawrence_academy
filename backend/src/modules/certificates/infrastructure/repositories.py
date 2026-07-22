from supabase import Client
from typing import Optional, cast
from src.modules.certificates.domain.entities import Certificate


class SupabaseCertificateRepository:
    def __init__(self, client: Client):
        self.client = client
        self.table = "certificates"

    async def get_by_id(self, certificate_id: str) -> Optional[Certificate]:
        response = (
            self.client.table(self.table).select("*").eq("id", certificate_id).execute()
        )
        if response.data:
            return Certificate(**cast(dict, response.data[0]))
        return None

    async def get_by_validation_code(self, code: str) -> Optional[Certificate]:
        response = (
            self.client.table(self.table)
            .select("*")
            .eq("validation_code", code)
            .execute()
        )
        if response.data:
            return Certificate(**cast(dict, response.data[0]))
        return None

    async def get_by_student_and_course(
        self, student_id: str, course_id: str
    ) -> Optional[Certificate]:
        response = (
            self.client.table(self.table)
            .select("*")
            .eq("student_id", student_id)
            .eq("course_id", course_id)
            .execute()
        )
        if response.data:
            return Certificate(**cast(dict, response.data[0]))
        return None

    async def list_by_student(self, student_id: str) -> list[Certificate]:
        response = (
            self.client.table(self.table)
            .select("*")
            .eq("student_id", student_id)
            .execute()
        )
        return [Certificate(**cast(dict, item)) for item in response.data]

    async def create(
        self,
        student_id: str,
        course_id: str,
        validation_code: str,
        signature: str,
        signature_algorithm: str,
        signature_version: int,
        metadata: dict,
    ) -> Certificate:
        data = {
            "student_id": student_id,
            "course_id": course_id,
            "validation_code": validation_code,
            "signature": signature,
            "signature_algorithm": signature_algorithm,
            "signature_version": signature_version,
            "metadata": metadata,
        }
        response = self.client.table(self.table).insert(cast(dict, data)).execute()
        return Certificate(**cast(dict, response.data[0]))
