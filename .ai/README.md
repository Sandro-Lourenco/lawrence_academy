---
name: ai-system-index
version: 2.0.0
status: active
---

# Sistema local de IA

Use `ORCHESTRATION.md` como roteador e `RULES.md` como política global.

- `agents/`: contratos de agentes executores e orquestradores;
- `personas/`: perspectivas profissionais para decisões;
- `skills/`: procedimentos reutilizáveis com gatilho e saída definidos;
- `workflows/`: sequências ponta a ponta;
- `reviews/`: gates independentes de validação;
- `rules/`: políticas especializadas sempre aplicáveis ou acionadas por escopo.

Uma persona não é “executada”. Um workflow pode exigir uma persona, acionar skills e terminar em reviews. Arquivos antigos ou com nomes incorretos devem conter somente um aviso de compatibilidade apontando para o arquivo canônico.
