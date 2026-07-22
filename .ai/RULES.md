---
name: project-rules
version: 2.0.0
status: active
---

# Regras globais para agentes

1. Trabalhe dentro do escopo autorizado e preserve alterações existentes do usuário.
2. Leia as fontes canônicas relevantes antes de editar; relatórios históricos não substituem especificações.
3. Não invente endpoints, tabelas, contratos, resultados de teste ou estado de produção.
4. Mantenha regras de negócio fora de widgets e rotas; dependências apontam para o domínio.
5. Frontend não é autoridade de autenticação, autorização, preço, pagamento ou ownership.
6. Toda tabela em schema exposto DEVE ter RLS e privilégios mínimos. `service_role`/secret key nunca vai para cliente.
7. Mudanças de schema usam o workflow Supabase existente, migrations versionadas e testes de policy; nunca alterar produção manualmente.
8. Interfaces cobrem responsividade, acessibilidade e estados relevantes. Nem toda página precisa de offline; documente quando não se aplica.
9. Valide entradas no limite e preserve dados em formato original quando necessário. Escape/encode no contexto de saída; regex isolada não sanitiza HTML.
10. Ações com efeito externo, destrutivas ou financeiro exigem idempotência, auditoria e aprovação proporcional ao risco.
11. Adicione testes que protejam o comportamento alterado e execute o conjunto proporcional ao risco.
12. Reviews reportam achados com severidade, evidência, impacto e correção; não são selos decorativos.
13. Atualize documentação e contratos no mesmo conjunto de mudanças.
14. Nunca exponha segredos, PII, tokens, stack traces ou dados de pagamento em prompts, logs ou exemplos.
15. Em caso de conflito ou incerteza material, registre a suposição ou escale; não silencie.

