# Admin Portal Overview

## Objetivo

## Segurança Global

- Admin Guard
- Super Admin Guard
- MFA obrigatório
- RBAC
- Audit Log

## Rotas

/admin/dashboard
/admin/users
/admin/teachers
/admin/students
/admin/categories
/admin/payments
/admin/subscriptions
/admin/reports
/admin/audit
/admin/roles
/admin/settings

## Regras Globais

- toda ação crítica gera audit log
- ações financeiras exigem 2FA
- alterações de roles exigem confirmação
- acesso admin nunca pode ser impersonado sem log

## Documentos Relacionados

- dashboard.md
- users.md
- payments.md
- roles.md