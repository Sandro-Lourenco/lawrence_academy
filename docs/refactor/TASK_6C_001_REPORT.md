# TASK 6C-001 TECHNICAL REPORT (REVISÃO 2)

## Resumo Executivo
Após revisão arquitetural, a Fase 6C foi revertida para o status **EM PROGRESSO**. O escopo original precisou ser dividido formalmente em dois subcontextos independentes: **Phase 6C-A (Certificates)** e **Phase 6C-B (Secure Offline Download)**.

A aprovação prévia foi anulada porque os requisitos rigorosos de segurança e integridade (criptografia, RLS privado, replay protection) não haviam sido mapeados no detalhamento original nem na implementação base, além de estarem acoplados indevidamente no mesmo lote de conclusão.

## Alterações de Governança
- O [PHASE_6C_IMPLEMENTATION_PLAN.md](file:///c:/Users/sandr/.gemini/antigravity/brain/1ce79786-c08a-47f9-acbe-d1174d33d3b5/PHASE_6C_IMPLEMENTATION_PLAN.md) foi reescrito.
- O [IMPLEMENTATION_BACKLOG.md](file:///c:/Users/sandr/Documents/site%20ariane/docs/refactor/IMPLEMENTATION_BACKLOG.md) foi ajustado para exibir as tarefas 6C-A-001 e 6C-B-001 separadamente e com status `PENDING`.
- O [PROJECT_STATUS.md](file:///c:/Users/sandr/Documents/site%20ariane/docs/refactor/PROJECT_STATUS.md) foi revertido para amarelo (Em Progresso).

## Próximos Passos Obrigatórios
Antes de solicitar nova validação, os seguintes requisitos técnicos deverão ser adicionados ao código e banco de dados:

### Para 6C-A (Certificates)
1. **Banco:** A policy RLS `USING(true)` para certificados públicos **DEVE SER REMOVIDA**. O banco não terá leitura pública direta. O Backend fará a intermediação (possivelmente utilizando um repositorio privilegiado ou view restrita).
2. **Integridade:** Geração de `document_hash` (SHA256) sobre um payload canônico imutável de `metadata` em cada emissão.
3. **Elegibilidade Real:** Delegação completa das verificações acadêmicas para o `CertificateEligibilityService`, sem usar progresso bruto.

### Para 6C-B (DRM Token)
1. **Anti-Replay:** Inclusão de um nonce (registro do `jti`) na emissão do token e amarração não apenas ao `user_id` e `lesson_id`, mas também ao contexto do dispositivo (device fingerprint ou identificador análogo).
2. **Testes de Integração:** O player Flutter deverá demonstrar que consegue consumir este token ativamente sem vazar o JWT no console.

## Status Atual
`APPROVED WITH REQUIRED ADJUSTMENTS`. A equipe retomará o fluxo na camada de banco de dados e APIs para cobrir os gaps identificados.
