# Contrato de API: Stream de Aulas (Lessons)

**Versão:** 1.0.0  
**Data:** 10 de Julho de 2026  
**Status:** Oficial  

---

## 1. Descrição
Este endpoint retorna os dados de uma aula específica para reprodução no player de vídeo, incluindo o caminho de reprodução HLS (`hls_storage_path`) e anexos, desde que o estudante possua uma assinatura válida e ativa para o respectivo curso.

---

## 2. Detalhes Técnicos

- **Método:** `GET`
- **Path:** `/api/v1/courses/{course_id}/lessons/{lesson_id}`
- **Autenticação:** Requerida (Bearer JWT do Supabase Auth)

---

## 3. Respostas da API

### Sucesso (200 OK)
Retorna os detalhes da aula autorizada:
```json
{
  "id": "cccccccc-cccc-cccc-cccc-cccccccccccc",
  "course_id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "title": "Aprenda Modelagem Prática",
  "description": "Nesta aula vamos aprender as bases da modelagem.",
  "hls_storage_path": "lessons/cccccccc/master.m3u8",
  "material_pdf_url": "https://storage.lawrence.academy/materials/cccccccc.pdf",
  "duration_seconds": 1200,
  "status": "published"
}
```

### Não Assinado (403 Forbidden)
O usuário não possui assinatura ativa no curso ou a carência de 5 dias expirou:
```json
{
  "detail": "Acesso negado. Assinatura ativa não encontrada para este curso ou período de carência expirado."
}
```

### Não Encontrado (404 Not Found)
A aula não existe, pertence a outro curso, ou foi deletada (soft delete):
```json
{
  "detail": "Aula não encontrada ou indisponível."
}
```

---

## 4. Fluxo de Autorização e RLS
1. A API faz a validação da sessão do usuário pelo JWT.
2. A política RLS da tabela `lessons` (`student_select_lesson`) executa uma verificação no banco de dados:
   - Garante que a lição não está deletada (`deleted_at IS NULL`).
   - Garante que o status é `published`.
   - Verifica se há assinatura correspondente na tabela `subscriptions` com status `active`, `trialing`, ou `past_due` e data de expiração mais tolerância de 5 dias no futuro (`current_period_end + INTERVAL '5 days' > NOW()`).
3. Se a linha não for retornada na query SQL por violar o RLS, o backend FastAPI retorna `404 Not Found` (ou `403 Forbidden` após validação explícita de inscrição).
