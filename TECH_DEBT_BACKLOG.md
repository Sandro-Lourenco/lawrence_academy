# Technical Debt Backlog

## Completed

- [x] **Pytest Failures - Phase 4 & Certificates Legados**
  - **Context:** Durante a revalida√ß√£o da Phase 6D, 5 testes do pytest de √°reas n√£o relacionadas ao Offline Download (Assessments, Certificates, Validation) falharam no ambiente atual.
    - `test_submit_task_bola_protection` (Learning/Assessments) - Corrigido.
    - `test_grade_submission_blocked_for_student` (Phase 4 Validation) - Corrigido.
    - `test_no_financial_mock_in_production_settings` (Phase 4 Validation) - Corrigido.
    - `test_generate_certificate_idempotency` (Certificates) - Corrigido.
    - `test_verify_certificate` (Certificates) - Corrigido.
  - **Resolution:** Corrigidos os stubs de reposit√≥rios nos testes de certificados, adaptadas rotas legadas e implementados validadores de mock financeiro para passar nos requisitos BOLA e de ambiente de testes. (Conclu√≠do na Sprint STAB-001)

- [x] **Flutter Analyze & Build Errors - Interfaces de Usu√°rio Legadas**
  - **Context:** `flutter analyze` e `flutter build` acusavam centenas de erros de tipagem (`Undefined name 'LawrenceTheme'` e `LiquidTheme`).
  - **Resolution:** Reimplementado o Design System (`LawrenceTheme` e aliases de cores) de forma compat√≠vel no arquivo `theme.dart`, al√©m de suprimidos warnings de deprecia√ß√£o espec√≠ficos no `analysis_options.yaml`. (Conclu√≠do na Sprint STAB-001)

- [x] RC1 Homologation completed and approved.

## Pending (STAB-001A)

- [ ] **Funcionalidades de Perfil Falsas (NotificaÁıes e Privacidade)**
  - **Context:** Os botıes de NotificaÁıes e Privacidade e Termos na tela de perfil do aluno foram mapeados para um dialog informativo (Em Desenvolvimento) pois ainda n„o existe backend/fluxo real definido.
  - **Resolution:** Aguardando especificaÁ„o e desenvolvimento de regras de negÛcio de GDPR e Push Notifications.

- [ ] **Cat·logo de Cursos Vazio (Falta de Seed Data)**
  - **Context:** A rota /api/v1/courses est· integrada perfeitamente no Flutter via CourseRepository. Contudo, ao validar no dispositivo, nenhum curso aparece. Isso n„o È um defeito de app, e sim o banco de dados que n„o possui nenhum curso publicado para o cat·logo.
  - **Resolution:** Inserir dados de teste (Seed Data) no Supabase ou via painel de admin para validaÁ„o visual total.
