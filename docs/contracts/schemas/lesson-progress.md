# Contrato de Schema: LessonProgress

**Versão:** 1.0.0  
**Data:** 10 de Julho de 2026  
**Status:** Oficial  

---

## 1. Descrição
Este contrato define a estrutura do objeto que representa o progresso de visualização de uma aula por parte de um estudante.

---

## 2. Estrutura do Objeto (JSON)

```json
{
  "id": "8f7d8b9a-1234-4bc1-9a8b-123456789abc",
  "student_id": "bb0306b3-8da2-448a-99c2-27d802fa058f",
  "course_id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "lesson_id": "cccccccc-cccc-cccc-cccc-cccccccccccc",
  "watched_seconds": 120,
  "progress_percentage": 42.50,
  "completed": false,
  "completed_at": null,
  "last_synced_at": "2026-07-10T13:10:00Z",
  "created_at": "2026-07-10T13:00:00Z",
  "updated_at": "2026-07-10T13:10:00Z"
}
```

---

## 3. Definição de Campos

| Campo | Tipo | Obrigatório | Nullable | Descrição |
|---|---|---|---|---|
| `id` | UUID (String) | Sim | Não | ID único do registro de progresso (gerado automaticamente). |
| `student_id` | UUID (String) | Sim | Não | ID único do estudante associado (FK profiles). |
| `course_id` | UUID (String) | Sim | Não | ID único do curso associado (FK courses). Deve ser consistente com o `course_id` da lição. |
| `lesson_id` | UUID (String) | Sim | Não | ID único da aula associada (FK lessons). |
| `watched_seconds` | Integer | Sim | Não | Segundos assistidos acumulados da aula (padrão `0`). |
| `progress_percentage` | Decimal (5,2) | Sim | Não | Percentual de conclusão da aula (de `0.00` a `100.00`). |
| `completed` | Boolean | Sim | Não | Flag indicando se a aula foi dada como concluída (padrão `false`). |
| `completed_at` | DateTime (ISO 8601) | Não | Sim | Data e hora de conclusão (UTC). |
| `last_synced_at` | DateTime (ISO 8601) | Sim | Não | Última sincronização de progresso offline (UTC). |
| `created_at` | DateTime (ISO 8601) | Sim | Não | Data de criação do registro (UTC). |
| `updated_at` | DateTime (ISO 8601) | Sim | Não | Data da última atualização (UTC). |

---

## 4. Regras de Validação e Erros

1. **Integridade do Curso (`course_id`):** O trigger `trg_check_progress_course_integrity` impede a inserção ou atualização caso o `course_id` seja diferente do `course_id` da lição associada.
   - **Erro de Violação:** `ERROR: course_id in lesson_progress (...) does not match course_id of the lesson (...)`
2. **Propriedade (`student_id`):** Apenas o próprio estudante autenticado pode interagir com seu registro de progresso.
   - **Erro de Violação:** HTTP 403 Forbidden (via RLS).
