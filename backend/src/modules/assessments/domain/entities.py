from dataclasses import dataclass
from typing import Optional, Dict, Any
from decimal import Decimal
from datetime import datetime


@dataclass(frozen=True)
class Task:
    """Entidade de Domínio Puro para tarefas (exercícios)."""

    id: str
    lesson_id: str
    title: str
    task_type: str
    description: Optional[str] = None
    options: Optional[Dict[str, Any]] = None
    correct_option: Optional[str] = None
    max_attempts: int = 1
    passing_score: Optional[Decimal] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


@dataclass(frozen=True)
class TaskSubmission:
    """Entidade de Domínio Puro para submissões de tarefas (exercícios)."""

    task_id: str
    user_id: str
    id: Optional[str] = None
    selected_option: Optional[str] = None
    text_answer: Optional[str] = None
    score: Optional[Decimal] = None
    status: str = "pending_auto"
    teacher_feedback: Optional[str] = None
    graded_by: Optional[str] = None
    submitted_at: Optional[datetime] = None
    graded_at: Optional[datetime] = None
