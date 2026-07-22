# Authentication Flow Audit

## Atualização da Fase 2 — 2026-07-17

- `/register` abre diretamente o cadastro.
- `/forgot-password` chama `resetPasswordForEmail` via UseCase e Repository.
- Flutter recebe somente chave pública/anon; nunca `service_role`.
- Callback final com `updateUser` ainda está pendente.
- Sessões restauradas acompanham `onAuthStateChange`; o refresh pode ocorrer após o bootstrap no Supabase Flutter v2.

## 1. Overview & Objectives
This audit verifies the user's authentication journey, from the public Landing Page to the Student Dashboard. We examine fields, validations, loading/error states, session persistence, routing guards, and UX/accessibility criteria.

## 2. Authentication Journey Analysis
1. **Landing Page Entry:** The header in `PublicLayout` features visible "Entrar" and "Matricular" buttons.
2. **Login Screen:** Accesses `/login`. Form features e-mail, password, and optional full name fields. Fields have validation messages below them.
3. **Password Recovery:** Currently **missing** from `LoginPage`. There is no "Forgot Password" or recovery trigger button.
4. **Loading States:** The button uses the custom Riverpod `loginFormControllerProvider` showing progress indicators and preventing multiple submissions.
5. **Redirections:** GoRouter guards verify status and redirect to `/dashboard/home` for logged-in users, or `/login` for unauthenticated attempts.
6. **Session Persistence:** Managed automatically by `SupabaseAuthRepository` listening to `onAuthStateChange`. Session is restored on bootstrap.
7. **Logout:** Implemented via `signOut` in `AuthNotifier` and `LogoutUseCase`.

## 3. Critical Gaps & Required Fixes
- **Link "Forgot Password":** Must be added below the password input in `LoginPage`.
- **Password Reset Route:** GoRouter has no `/auth/reset-password` or `/auth/forgot-password` routes registered.
- **Show/Hide Password:** The password field needs a toggle icon to show/hide the password.

## 4. Remediation Plan
- Update `LoginPage` to support:
  1. Password visibility toggle (Show/Hide).
  2. "Esqueci minha senha" text button that opens a dialog or changes the mode to "Forgot Password" mode.
  3. Integrated recovery logic via Supabase Auth `resetPasswordForEmail`.
