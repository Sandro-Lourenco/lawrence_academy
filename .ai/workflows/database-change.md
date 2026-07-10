---
name: database-change
description: "Workflow seguro para alterações em banco de dados seguindo arquitetura, segurança, migrations, testes e documentação."
type: workflow
version: 1.0.0
status: production

required_personas:
  - backend-architect
  - security-engineer
  - qa-engineer

optional_personas:
  - performance-engineer

required_skills:
  - create-api
  - optimize-performance
  - review-code

affected_docs:
  - docs/database/DATABASE_SCHEMA.md
  - docs/api/SERVICE_API.md
  - docs/security/SECURITY_COMPLIANCE_SPEC.md
  - docs/architecture/SYSTEM_ARCHITECTURE.md
---

# Workflow: Database Change


# 1. Objetivo

Controlar qualquer mudança estrutural no banco de dados.

Inclui:

- criar tabelas;
- alterar tabelas;
- remover campos;
- criar índices;
- alterar relacionamentos;
- criar policies;
- criar funções;
- criar triggers;
- alterar permissões;
- otimizar queries.

Nunca alterar banco diretamente sem este fluxo.


---

# 2. Regra principal


Banco representa regras do negócio.

Toda mudança deve começar entendendo:

```text
Produto

↓

Domínio

↓

Modelo

↓

Migration

↓

Segurança

↓

Teste
```

Nunca começar criando SQL.


---

# 3. Antes de alterar


Ler obrigatoriamente:


```text
AGENTS.md

GEMINI.md


docs/product/PED-overview.md


docs/database/DATABASE_SCHEMA.md


docs/architecture/SYSTEM_ARCHITECTURE.md


docs/security/SECURITY_COMPLIANCE_SPEC.md


docs/api/SERVICE_API.md
```


---

# 4. Identificar motivo


Antes de criar migration:

Responder:


```yaml
database_change:

 reason:

 affected_feature:

 bounded_context:

 tables:

 operation:
   create:
   update:
   delete:

 risk:
   low | medium | high | critical
```


Exemplo:


```yaml
database_change:

 reason:
   adicionar certificados

 bounded_context:
   learning

 tables:
   - certificates

 operation:
   create: true

 risk:
   medium
```

---

# 5. Classificação de risco


## LOW


Exemplos:


```text
Criar índice

Adicionar coluna nullable

Adicionar tabela isolada
```


---


## MEDIUM


```text
Nova relação

Nova FK

Nova constraint

Novo enum
```


---


## HIGH


```text
Alterar coluna existente

Adicionar NOT NULL

Alterar relacionamento

Adicionar regra financeira

Dados pessoais
```


---


## CRITICAL


```text
Excluir tabela

Excluir coluna

Alterar pagamento

Alterar permissão

Alterar autenticação

Migration destrutiva
```


Mudanças críticas exigem:

```text
Backup

Plano rollback

Review obrigatório
```

---

# 6. Modelagem


Antes da tabela definir:


```text
Entidade existe no domínio?

É Value Object?

É relacionamento?

É evento?

É log?

É configuração?
```


Não criar tabela porque "precisa salvar algo".


---

# 7. Convenções de tabela


Usar:


```text
snake_case

plural

nomes claros
```


Exemplos:


Correto:

```sql
users

course_lessons

student_certificates
```


Errado:

```sql
User

tblAluno

data
```

---

# 8. Campos obrigatórios


Toda entidade principal:


```sql
id UUID PRIMARY KEY

created_at TIMESTAMP

updated_at TIMESTAMP
```


Quando necessário:


```sql
deleted_at

created_by

updated_by
```


---

# 9. UUID


Obrigatório:


```sql
UUID
```


Evitar:


```sql
INTEGER AUTO_INCREMENT
```


Motivos:


- segurança;
- sincronização offline;
- sistemas distribuídos;
- mobile.


---

# 10. Relacionamentos


Toda FK deve definir:


```text
ON DELETE

ON UPDATE

INDEX
```


Exemplo:


```sql
course_id UUID REFERENCES courses(id)
```


Criar:


```sql
CREATE INDEX idx_lessons_course
ON lessons(course_id);
```

---

# 11. Delete Strategy


Nunca escolher sem pensar.


Opções:


## CASCADE


Somente quando filho não existe sozinho.


Ex:


```text
Curso

↓

Aulas
```


---


## SET NULL


Quando histórico importa.


---


## RESTRICT


Quando exclusão pode quebrar negócio.


Ex:


```text
Pagamentos

Assinaturas

Certificados
```

---

# 12. Soft Delete


Usar em:


```text
Usuários

Cursos

Pagamentos

Certificados

Conteúdo criado
```


Campo:


```sql
deleted_at
```


Nunca apagar histórico financeiro.


---

# 13. Constraints


Sempre preferir banco protegendo regra.


Exemplo:


```sql
price >= 0

email UNIQUE

progress BETWEEN 0 AND 100
```


Não deixar somente no frontend.


---

# 14. Dinheiro


Nunca usar:


```sql
FLOAT
DOUBLE
```


Usar:


```sql
NUMERIC(10,2)
```


---

# 15. Datas


Usar:


```sql
TIMESTAMPTZ
```


Salvar UTC.


Frontend converte timezone.


---

# 16. Enums


Cuidado com enum.


Antes perguntar:


```text
Vai mudar frequentemente?
```


Se sim:


usar tabela.


Exemplo:


```text
categories
```

não enum fixo.


---

# 17. Índices


Criar para:


```text
FK

Filtros frequentes

Busca

Ordenação
```


Exemplo:


```sql
CREATE INDEX idx_orders_user
ON orders(user_id);
```


Não criar índice sem uso.


---

# 18. Performance


Antes de otimizar:


usar:


```sql
EXPLAIN ANALYZE
```


Verificar:


```text
Seq Scan

Index Scan

Tempo

Rows

Locks
```


---

# 19. Paginação


Toda lista grande exige suporte:


Preferir:


```text
Cursor Pagination
```


Evitar:


```sql
OFFSET 100000
```


---

# 20. Segurança Supabase


Todas tabelas sensíveis:


```sql
ENABLE ROW LEVEL SECURITY;
```


Obrigatório definir:


```text
SELECT

INSERT

UPDATE

DELETE
```


---

# 21. RLS Checklist


Verificar:


```text
[ ] Quem pode ler?

[ ] Quem pode criar?

[ ] Quem pode editar?

[ ] Quem pode apagar?

[ ] Admin pode?

[ ] Dono pode?

[ ] Professor pode?

[ ] Aluno pode?
```


Nunca:


```sql
USING(true)
```


sem justificativa.


---

# 22. Dados sensíveis


Proteger:


```text
Email

Telefone

Pagamento

Documento

Logs

Arquivos privados
```


Nunca salvar:


```text
Senha pura

Token

Secret

Cartão
```


---

# 23. Auditoria


Obrigatório para:


```text
Pagamento

Admin

Permissões

Assinaturas

Usuários
```


Registrar:


```text
Quem

Quando

O que mudou

IP se necessário
```

---

# 24. Migrations


Toda alteração:


```text
Migration versionada
```


Nunca alterar produção manualmente.


Migration deve ter:


```text
UP

DOWN quando suportado

Descrição clara
```


---

# 25. Dados existentes


Antes de alterar coluna:


Pensar:


```text
Quantas linhas existem?

Tem NULL?

Precisa backfill?

Vai travar tabela?

Precisa rodar em etapas?
```

---

# 26. Mudança segura


Para adicionar NOT NULL:


Errado:


```sql
ADD COLUMN name TEXT NOT NULL
```


Certo:


```text
1 adicionar nullable

2 preencher dados

3 validar

4 aplicar NOT NULL
```

---

# 27. Testes


Criar:


```text
Migration test

Repository test

UseCase test

Permission test

RLS test
```


---

# 28. Atualizar documentação


Após alterar:


Atualizar:


```text
docs/database/DATABASE_SCHEMA.md

docs/api/SERVICE_API.md

docs/architecture/SYSTEM_ARCHITECTURE.md
```


Se impactar tela:


Atualizar:


```text
docs/pages/
```

---

# 29. Revisão obrigatória


Depois executar:


```text
@review-code
```


Validar:


```text
Migration

Relacionamentos

Segurança

Performance

Testes
```

---

# 30. Checklist final


```text
MODELAGEM

[ ] Domínio correto?

[ ] Nome correto?

[ ] Relacionamentos?


BANCO

[ ] UUID?

[ ] Constraints?

[ ] Índices?

[ ] Datas?


SEGURANÇA

[ ] RLS?

[ ] Policies?

[ ] Permissões?


DADOS

[ ] Sem perda?

[ ] Rollback?

[ ] Backup?


QUALIDADE

[ ] Testes?

[ ] Documentação?

[ ] Review?
```

---

# Proibido


Nunca:

```text
❌ Criar tabela sem domínio

❌ Migration direto em produção

❌ Remover coluna sem plano

❌ Usar FLOAT para dinheiro

❌ Salvar senha

❌ Ignorar RLS

❌ Criar FK sem índice

❌ SELECT público sem policy

❌ Apagar histórico financeiro

❌ Alterar banco sem atualizar docs
```

---

# Regra final


Banco não é apenas armazenamento.

Banco protege:

```text
Dados

Negócio

Histórico

Segurança

Confiança
```

Toda alteração deve ser:

```text
Planejada

Versionada

Testada

Segura

Reversível
```
