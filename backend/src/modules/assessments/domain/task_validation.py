from typing import Any

from src.core.errors.errors import ValidationError


SUPPORTED_TASK_TYPES = {"multiple_choice", "true_false", "essay"}


def validate_task_definition(
    *,
    task_type: str,
    options: dict[str, Any] | None,
    correct_option: str | None,
) -> None:
    """Validate the server-owned answer definition before it is persisted."""
    if task_type not in SUPPORTED_TASK_TYPES:
        raise ValidationError("Tipo de atividade não suportado.")

    if task_type == "essay":
        if correct_option:
            raise ValidationError("Atividades dissertativas não possuem resposta automática.")
        return

    if task_type == "true_false":
        if correct_option not in {"true", "false"}:
            raise ValidationError("Defina verdadeiro ou falso como resposta correta.")
        return

    normalized_options = {
        str(key).strip(): str(value).strip()
        for key, value in (options or {}).items()
        if str(key).strip() and str(value).strip()
    }
    if len(normalized_options) < 2:
        raise ValidationError("Informe pelo menos duas alternativas.")
    if correct_option not in normalized_options:
        raise ValidationError("A resposta correta deve corresponder a uma alternativa.")
