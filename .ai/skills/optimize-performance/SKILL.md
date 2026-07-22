---
name: optimize-performance
description: Diagnosticar e corrigir regressões mensuráveis de performance em Flutter, FastAPI, PostgreSQL/Supabase ou workers.
version: 2.0.0
---

# Optimize Performance

1. Definir budget, workload, ambiente, dataset e métrica.
2. Medir baseline com profile/trace/query plan; não otimizar por intuição.
3. Isolar gargalo e formular hipótese.
4. Aplicar a menor correção sem degradar segurança ou consistência.
5. Repetir a mesma medição, comparar distribuição e verificar regressões.
6. Registrar resultado, trade-offs e condições do teste.

