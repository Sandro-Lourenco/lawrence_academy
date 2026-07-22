# TASK 6C-A-001 TECHNICAL REPORT - Certificates (Implementation)

## Status
**Completed**

## Resumo da Implementação
A infraestrutura para emissão e verificação pública de certificados foi concluída com as restrições arquiteturais exigidas:
- O módulo de Certificados opera agora como um subcontexto isolado (6C-A).

### Segurança e Governança de Banco de Dados
1. **Remoção do Acesso RLS Público:** A policy genérica `USING(true)` para certificados foi removida. A tabela agora é estritamente privada.
2. **Integração de Assinatura (HMAC):** Foram adicionados os campos `signature`, `signature_algorithm` (HMAC-SHA256) e `signature_version` (1). O payload do certificado é convertido num formato JSON canônico (chaves ordenadas, sem espaçamento) e assinado com o `CERTIFICATE_SECRET_KEY`.
3. **Imutabilidade e Idempotência:** A restrição `UNIQUE(student_id, course_id)` no banco previne concorrência.
4. **Política de Revogação:** A infraestrutura de schema suporta soft-delete lógico/revogação explícita com os campos `revoked_at` e `revocation_reason`.

### Backend
1. **Geração (GenerateCertificateUseCase):** O sistema assina os metadados gerados (usando HMAC) e acopla ao DB de forma determinística.
2. **Verificação (VerifyCertificateUseCase):** A leitura para verificação é intermediada pelo backend, que usa o index `idx_certificates_validation_code` e oculta todo dado sensível (`student_id`, etc), projetando uma `PublicCertificateDTO`.
3. **Rate Limiting:** A rota `/{code}/verify` foi bloqueada para abusos e enumerações com um limite de `5/minute` via dependência `slowapi`.

### Frontend
- Os models Dart em `Certificate` foram espelhados para incluir os campos `signature`, `signatureAlgorithm`, `signatureVersion`, e tratamento de datas de revogação. O uso do `.withOpacity` também foi corrigido em passes de linter anteriores.

## Testes Realizados
Os testes de integração em `backend/tests/test_certificates.py` cobriram os cenários requeridos:
- Verificação de Idempotência (não criação se certificado já existe).
- Assinatura da emissão em testes `new_cert`.
- Validação no `VerifyCertificateUseCase` validando a proteção da estrutura (ausência do `student_id`).
- Bloqueio de certificado revogado (`is_valid = False` se houver data de revogação).

## Próximos Passos
Esta conclusão libera a inicialização formal da esteira **Phase 6C-B (Secure Offline Download)**.
