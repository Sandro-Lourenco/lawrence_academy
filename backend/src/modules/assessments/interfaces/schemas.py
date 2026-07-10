from pydantic import BaseModel, ConfigDict, Field

class TaskSubmissionSchema(BaseModel):
    """Payload de validação de input do aluno para envio de exercícios."""
    model_config = ConfigDict(frozen=True, extra="forbid")

    task_id: str = Field(..., description="UUID da tarefa sendo respondida")
    selected_option: str = Field(..., min_length=1, max_length=1, description="Opção de resposta selecionada (A-Z)")
