from src.modules.courses.interface.api.teacher_routes import BlockContentSchema


def test_activity_correct_index_is_preserved_by_api_contract():
    task_id = "b886fb7b-6d89-43b6-b612-6ead8a5dd71b"
    payload = BlockContentSchema(
        question="Qual alternativa está correta?",
        activity_type="single_choice",
        items=["Primeira", "Segunda", "Terceira"],
        correct_index=1,
        task_id=task_id,
    )

    content = payload.model_dump(exclude_none=True)
    assert content["correct_index"] == 1
    assert content["task_id"] == task_id


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


def test_activity_task_id_rejects_non_uuid_value():
    try:
        BlockContentSchema(
            question="Qual alternativa está correta?",
            activity_type="single_choice",
            items=["Primeira", "Segunda"],
            correct_index=0,
            task_id="task-local-sem-uuid",
        )
    except ValueError:
        return

    raise AssertionError("task_id inválido deveria ser rejeitado")
