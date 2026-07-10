from pydantic import BaseModel, ConfigDict, Field
from typing import Optional
from decimal import Decimal
from datetime import datetime

class TaskSubmission(BaseModel):
    """Entidade representando o envio de exercício por um aluno."""
    model_config = ConfigDict(frozen=True, extra="forbid")

    id: Optional[str] = Field(None, description="UUID único do envio de tarefa")
    task_id: str = Field(..., description="UUID da tarefa associada")
    user_id: str = Field(..., description="UUID do aluno (JWT extraído/BOLA-safe)")
    selected_option: Optional[str] = Field(None, min_length=1, max_length=10, description="Opção marcada (múltipla escolha)")
    text_answer: Optional[str] = Field(None, description="Texto escrito pelo aluno (questões discursivas)")
    score: Optional[Decimal] = Field(None, description="Nota de 0.00 a 10.00")
    status: str = Field("pending_auto", description="Status da submissão (pending_auto, pending_review, graded)")
    teacher_feedback: Optional[str] = Field(None, description="Feedback textual do instrutor")
    graded_by: Optional[str] = Field(None, description="UUID do instrutor que corrigiu")
    submitted_at: Optional[datetime] = None
    graded_at: Optional[datetime] = None
