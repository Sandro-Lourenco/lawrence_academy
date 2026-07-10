# Relatório de Migração de Profiles (Perfis)

Este relatório registra a migração e padronização do bounded context de Profiles para a arquitetura limpa modular oficial da Lawrence Academy.

---

## 1. Estrutura Antiga vs. Nova

### Antiga
- Entidade: `src/core/entities/profile.py` (Acoplada com Pydantic).
- Repositório: `src/modules/profiles/repositories/profile_repository.py` (Acoplado a métodos estáticos e database client global).
- UseCases: `src/modules/profiles/application/get_profile.py` e `src/modules/profiles/application/update_profile.py`.
- Rotas Concorrentes/Duplicadas: `/api/profiles/me` e `/students/me`.

### Nova
- Entidade: `src/modules/profiles/domain/entities.py` (Domínio puro, dataclass sem dependência externa).
- Repositório Interface (Protocol): `src/modules/profiles/domain/repositories.py`.
- Repositório Concreto Supabase: `src/modules/profiles/infrastructure/repositories/supabase_profile_repository.py`.
- UseCases:
  - `GetMyProfileUseCase` em `src/modules/profiles/application/use_cases/get_my_profile_use_case.py`.
  - `UpdateMyProfileUseCase` em `src/modules/profiles/application/use_cases/update_my_profile_use_case.py`.
- Rotas Consolidadas: `/api/v1/profiles/me` em `src/modules/profiles/interface/api/routes.py`.
- Rotas Legacy (Mantidas para compatibilidade):
  - `/api/profiles/me` delega para novos UseCases.
  - `/students/me` delega para novos UseCases.

---

## 2. Arquivos Modificados/Criados

- **[NEW]** [`src/modules/profiles/domain/entities.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/profiles/domain/entities.py)
- **[NEW]** [`src/modules/profiles/domain/repositories.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/profiles/domain/repositories.py)
- **[NEW]** [`src/modules/profiles/infrastructure/repositories/supabase_profile_repository.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/profiles/infrastructure/repositories/supabase_profile_repository.py)
- **[NEW]** [`src/modules/profiles/application/use_cases/get_my_profile_use_case.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/profiles/application/use_cases/get_my_profile_use_case.py)
- **[NEW]** [`src/modules/profiles/application/use_cases/update_my_profile_use_case.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/profiles/application/use_cases/update_my_profile_use_case.py)
- **[NEW]** [`src/modules/profiles/interface/api/routes.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/profiles/interface/api/routes.py)
- **[MODIFY]** [`src/modules/profiles/interfaces/routes.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/profiles/interfaces/routes.py) (Legada - redirecionada)
- **[MODIFY]** [`src/modules/students/api/router.py`](file:///c:/Users/sandr/Documents/site%20ariane/backend/src/modules/students/api/router.py) (Legada - redirecionada)

---

## 3. Segurança e Regras Preservadas

- **Proteção contra Broken Access Control (BOLA):** O ID do usuário consultado ou alterado é extraído diretamente do token JWT decodificado (`CurrentUser.id`), impossibilitando falsificação de ID no corpo ou nos parâmetros da requisição.
- **Validação de Papéis (RBAC):** Os exception handlers capturam violações de autorizações e retornam HTTP 403 padronizado.

---

## 4. Testes e Validação
1. Executado `python -m pytest -q` para garantir comportamento idêntico.
2. 100% de aprovação (16 testes válidos passando com sucesso).
