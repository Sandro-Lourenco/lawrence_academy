from src.modules.courses.interface.api.teacher_routes import BlockContentSchema


def test_activity_correct_index_is_preserved_by_api_contract():
    payload = BlockContentSchema(
        question="Qual alternativa está correta?",
        activity_type="single_choice",
        items=["Primeira", "Segunda", "Terceira"],
        correct_index=1,
    )

    assert payload.model_dump(exclude_none=True)["correct_index"] == 1


def test_activity_correct_index_rejects_value_outside_items():
    try:
        BlockContentSchema(
            question="Qual alternativa está correta?",
            activity_type="single_choice",
            items=["Primeira", "Segunda"],
            correct_index=2,
        )
    except ValueError:
        return

    raise AssertionError("correct_index fora do contrato deveria ser rejeitado")
