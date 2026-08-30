# Lawrence Academy — auditoria de prontidão da V1

Data: 2026-08-20

Veredito: **CÓDIGO PRONTO PARA RELEASE CANDIDATE; PRODUÇÃO AGUARDA GATES EXTERNOS**

## Implementado nesta rodada

- conclusão fail-closed: curso publicado, certificado habilitado, aulas e blocos
  obrigatórios concluídos e todas as atividades aprovadas;
- emissão/reconciliação idempotente por aluno e curso;
- coleção real de cursos concluídos e certificados do aluno;
- certificado com nome, curso, data, carga horária, aulas e código persistidos;
- PDF privado, protegido por JWT e ownership, sem cache, com QR Code público;
- download, compartilhamento, cópia do link e verificação pública responsiva;
- estado de revogação impedindo download e compartilhamento;
- correções de arquitetura, acessibilidade e responsividade nos fluxos públicos;
- cadeia Android atualizada para Gradle 8.14, AGP 8.12.1 e Kotlin 2.2.20.

## Evidências verdes

- backend: `293 passed`; lint Ruff aprovado;
- Flutter: `213 passed`; `flutter analyze --no-pub` sem issues;
- banco/RLS/RBAC: `178` testes SQL aprovados;
- aulas por link externo do YouTube/Vimeo disponíveis na área do professor, com validação do provedor e acesso do aluno protegido pelo endpoint de reprodução;
- migrations locais e remotas alinhadas até `20260811163000`;
- build web release aprovado;
- PDF renderizado e inspecionado visualmente em A4 paisagem;
- build Android release chegou à compilação Flutter/Java com a cadeia atualizada,
  mas o Windows bloqueou a limpeza de um cache nativo gerado em
  `build/app/intermediates/cxx/.../configure_stderr.txt`; o APK deve ser
  recompilado após liberar esse arquivo ou reiniciar a máquina.

O reset destrutivo do banco local não foi executado para preservar os dados já
existentes. A validação segura confirmou o histórico de migrations e toda a
suíte SQL no schema local atual.

## Gates externos antes de abrir produção

1. executar em staging a jornada login → Stripe test → acesso → player →
   atividade aprovada → certificado → PDF/QR/verificação;
2. confirmar Stripe Dashboard, assinatura e reentrega de webhooks com as
   credenciais reais de staging;
3. validar HLS real, renovação do token e sincronização offline;
4. executar smoke, acessibilidade e desempenho em Android físico;
5. comprovar health/readiness, observabilidade, backup/restore e rollback no
   ambiente de staging;
6. configurar segredos e URLs HTTPS definitivas, sem valores de desenvolvimento.

Esses gates dependem de infraestrutura, credenciais ou dispositivo real e não
devem ser substituídos por mocks. A publicação para usuários finais ocorre
somente após seus registros de aprovação.
