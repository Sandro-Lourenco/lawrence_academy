---
name: architecture-ddd
trigger: always_on
version: 2.0.0
---

# Arquitetura e DDD

## Princípios

- Bounded contexts são definidos pelo modelo e pela linguagem do negócio, não por pastas arbitrárias.
- A arquitetura atual é um monólito modular; cada módulo protege seus limites e integra por contratos explícitos.
- Domain não depende de Flutter, FastAPI, Supabase, HTTP ou serialização.
- Application coordena use cases e transações. Adapters convertem protocolos. Infrastructure implementa portas.
- Use entidades quando identidade e ciclo de vida importarem; value objects para conceitos imutáveis definidos por valor; domain services somente quando o comportamento não pertencer naturalmente a uma entidade/value object.
- Workers de mídia e IA são componentes de aplicação/infraestrutura que executam capacidades do domínio, não “domain services” automaticamente.
- Agregados protegem invariantes transacionais. Não force carregamento de grafos inteiros ou passagem artificial pela raiz quando consistência eventual e contratos explícitos forem apropriados.

## Mudanças arquiteturais

Decisões de alto impacto exigem ADR com contexto, opções, decisão, consequências e plano de migração. O review valida dependências reais e testes, não apenas nomes de pastas.

