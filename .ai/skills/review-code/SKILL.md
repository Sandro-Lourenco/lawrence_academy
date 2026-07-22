---
name: review-code
description: Revisar mudanças de código com foco em defeitos acionáveis, risco, regressão, segurança e testes.
version: 2.0.0
---

# Review Code

## Procedimento

1. Ler requisito, diff e fontes canônicas relevantes.
2. Entender fluxo de dados, limites de confiança, concorrência, falhas e consumidores.
3. Priorizar defeitos que mudam comportamento; evitar preferências sem impacto.
4. Para cada achado, informar severidade, local exato, cenário reproduzível, impacto e correção.
5. Verificar testes existentes e gaps; executar checks seguros quando possível.

## Severidade

- P0: perda de dados, comprometimento ou indisponibilidade generalizada;
- P1: quebra relevante sem alternativa segura;
- P2: defeito limitado ou risco de manutenção concreto;
- P3: melhoria não bloqueante.

Se não houver achados, diga isso e registre gaps de validação. Não reescreva código durante uma solicitação somente de review.

