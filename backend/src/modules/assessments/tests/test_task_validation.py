import pytest

from src.core.errors.errors import ValidationError
from src.modules.assessments.domain.task_validation import validate_task_definition


def test_multiple_choice_requires_correct_option_from_server_owned_options() -> None:
    validate_task_definition(
        task_type="multiple_choice",
        options={"A": "Viés", "B": "Acabamento"},
        correct_option="B",
    )

    with pytest.raises(ValidationError, match="corresponder"):
        validate_task_definition(
            task_type="multiple_choice",
            options={"A": "Viés", "B": "Acabamento"},
            correct_option="C",
        )


@pytest.mark.parametrize("correct_option", ["true", "false"])
def test_true_false_accepts_canonical_server_answers(correct_option: str) -> None:
    validate_task_definition(
        task_type="true_false",
        options={"true": "Verdadeiro", "false": "Falso"},
        correct_option=correct_option,
    )


def test_essay_cannot_publish_an_automatic_answer() -> None:
    with pytest.raises(ValidationError, match="não possuem resposta automática"):
        validate_task_definition(
            task_type="essay",
            options=None,
            correct_option="A",
        )
