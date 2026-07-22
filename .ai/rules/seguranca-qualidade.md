---
name: security-and-quality
trigger: always_on
version: 2.0.0
---

# Segurança e qualidade

- Use a linguagem do domínio definida no PED e no schema; não proíba termos tecnicamente corretos como `user` quando eles representarem `auth.users` ou um conceito diferente de `profile`.
- Autorização exige defesa em profundidade: JWT validado, permissão no backend e RLS nas tabelas expostas. `TO authenticated` sem predicado de ownership não basta.
- Nunca use `user_metadata` para autorização. Claims de `app_metadata` podem ficar desatualizadas até o refresh do token; operações sensíveis devem considerar isso.
- Funções `SECURITY DEFINER` exigem justificativa, schema não exposto, `search_path` seguro, grants mínimos e teste adversarial.
- Soft delete é uma decisão de ciclo de vida, não regra universal. Dados financeiros/auditoria exigem retenção; dados pessoais podem exigir eliminação ou anonimização conforme LGPD.
- Proteções no cliente, marcas d'água e ofuscação são dissuasórias e nunca substituem autorização, URLs assinadas e controles do servidor. Não deslogue usuários com base em manipulação de DOM.
- Minimize PII antes de enviar conteúdo a provedores de IA usando detecção testada, revisão de falsos negativos, contrato de tratamento, retenção e base legal; regex isolada não oferece garantia.
- Todo achado deve incluir evidência reproduzível. Toda correção deve incluir teste de regressão proporcional ao risco.

