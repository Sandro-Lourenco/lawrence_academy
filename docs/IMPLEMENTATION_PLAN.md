# Implementation Plan - Auth Flow Completion & Accessibility Fixes

## 1. Goal Description
The objective of this plan is to close the gaps discovered in our audits, mainly:
- Complete the authentication flow in `LoginPage` (adding "Esqueci minha senha" / password recovery flow, show/hide password toggle).
- Improve accessibility (semantics, touch targets, screen reader friendliness).
- Correct secret hygiene issues (already completed).

## 2. Proposed Changes

### Frontend (Flutter)

#### [MODIFY] [login_page.dart](file:///c:/Users/sandr/Documents/site%20ariane/lawrence/lib/features/auth/presentation/pages/login_page.dart)
- Implement show/hide password visibility toggle using an `IconButton` as a suffix icon.
- Add an "Esqueci minha senha" link button below the password field.
- Integrate forgot password state mode (switching the UI inputs to ask only for Email and show a recovery button).
- Ensure high contrast and appropriate touch targets (>= 44px).
- Add semantic labels or tooltips to input field prefixes.

## 3. Verification Plan
- Run automated backend tests to ensure everything remains operational.
- Manually run/validate the login flow and recovery behavior.
