# Relatório de Auditoria: Uso de Service Role no Backend

**Status:** Concluído  
**Data:** 10 de Julho de 2026  
**Auditor:** Principal Software Architect / Security Engineer  

---

## 1. Contexto e Objetivo
O Supabase fornece duas chaves de API principais para interação com o banco de dados via PostgREST/Client:
1. **Anon Key:** Usada no lado do cliente. Respeita as políticas de Row Level Security (RLS).
2. **Service Role Key (`service_role`):** Chave administrativa superprivilegiada que ignora todas as restrições de RLS.

O objetivo desta auditoria é catalogar onde a `service_role` é inicializada e consumida no backend FastAPI e propor correções para mitigar riscos de segurança, garantindo que o acesso a dados privados respeite o modelo de privilégios.

---

## 2. Inicialização e Mapeamento da Service Key
A Service Key é carregada das variáveis de ambiente e injetada no cliente administrativo do Supabase:

- **Arquivo de Configuração:** [config.py](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/shared/config.py#L15)
  `supabase_service_key: str = Field(default_factory=lambda: os.getenv("SUPABASE_SERVICE_KEY"))`
- **Inicialização do Cliente:** [client.py](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/infra/supabase/client.py#L5-L8)
  `supabase_admin` é instanciado com `supabase_service_key`.
- **Exportação Global:** [database.py](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/shared/database.py#L5)
  Define `db = supabase_admin` e exporta para todos os módulos e repositórios.

---

## 3. Análise de Risco e Vulnerabilidades Encontradas

Como a variável global `database.db` do backend aponta para `supabase_admin`, **todas as operações de banco executadas por UseCases e Repositórios ignoram completamente o RLS**. Isso significa que a validação de permissões deve ocorrer de forma estrita na camada do backend FastAPI.

### Vulnerabilidade Crítica Identificada e Corrigida:
No endpoint de stream de vídeo de aulas (`/api/courses/{id}/lessons/{lesson_id}/stream`), a autorização do estudante era feita da seguinte forma:
```python
sub_res = database.db.table("subscriptions").select("*").eq("user_id", current_user["id"]).execute()
```
**Impacto:** Qualquer estudante com uma assinatura ativa para **QUALQUER** curso conseguia obter a URL assinada para assistir aulas de **TODOS** os outros cursos do catálogo, quebrando a regra de negócio de "1 curso = 1 assinatura por aluno" e configurando uma falha grave de Broken Object Level Authorization (BOLA/IDOR).

### Ação de Mitigação:
Refatoramos o endpoint em [router.py](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/courses/api/router.py#L63-L82) para restringir a busca de assinaturas ativas filtrando explicitamente pelo `course_id` correspondente:
```python
sub_res = database.db.table("subscriptions")\
    .select("*")\
    .eq("student_id", current_user["id"])\
    .eq("course_id", id)\
    .execute()
```
Além disso, adicionamos validação para o status `past_due` com verificação de tolerância de 5 dias baseada em `current_period_end`.

---

## 4. Recomendações e Diretrizes de Segurança

1. **Uso Exclusivo:** A chave `service_role` (via `database.db`) deve ser usada **apenas** para:
   - Processamento de webhooks de pagamento (Stripe).
   - Operações em lote executadas por Workers em segundo plano (como processamento de vídeo).
   - Criação/atualização de recursos onde o controle de acesso é estritamente gerenciado pelas dependências do FastAPI (ex: `require_role(["teacher", "admin"])`).
2. **Camada de Autenticação:** Qualquer rota do backend FastAPI destinada a estudantes comuns que leia ou modifique registros deve:
   - Validar se o ID do recurso solicitado pertence ao usuário autenticado (`current_user["id"]`).
   - Ou usar a instância `supabase_anon` com o token JWT do usuário passado no header da requisição, delegando a segurança ao RLS do banco de dados quando aplicável.
