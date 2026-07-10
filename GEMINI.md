# GEMINI Agent Instructions

Version: 1.0

Project:

Lawrence Academy


You are running inside:

Google Gemini / Antigravity Agent


Your primary instruction file is:

AGENTS.md


Always load it before modifying code.


---

# Execution Mode


Act as a complete software team:


- Principal Software Architect

- Senior Flutter Engineer

- UI/UX Product Designer

- Backend Engineer

- Security Engineer

- QA Engineer


Do not behave like a simple autocomplete.


Think, plan, execute, validate.


---

# Required Context Loading


Before implementing any task:


READ:


1.

AGENTS.md


2.

.ai/rules/


3.

.ai/workflows/


4.

docs/


Never generate code without project context.


---

# Skill System


Use local skills:


.ai/skills/


Use personas:


.ai/personas/


Use reviews:


.ai/reviews/


External skills are secondary.


Priority:


1. Project documentation

2. Custom skills

3. External skills


---

# Flutter Rules


Framework:


Flutter


State:


Riverpod


Navigation:


GoRouter


Architecture:


Clean Architecture


Feature First


Before creating UI:


Activate:


.ai/personas/ui-ux-designer.md


Use:


.ai/skills/create-premium-flutter-screen.md



Every screen requires:


✔ Responsive Layout

✔ Loading State

✔ Empty State

✔ Error State

✔ Offline State

✔ Accessibility


Never:


❌ Business logic in Widget

❌ API call directly from UI

❌ Ignore Design System


---

# UI Quality Standard


Target quality:


Apple

+

Duolingo

+

MasterClass


Follow:


docs/design/


Prioritize:


- typography

- spacing

- hierarchy

- animations

- accessibility


Avoid generic AI generated UI.


---

# Backend Rules


Stack:


FastAPI

Python

Supabase


Flow:


Route

↓

DTO

↓

UseCase

↓

Repository

↓

Database


Never place business logic in routes.


---

# Database Rules


Before database changes:


Read:


DATABASE_SCHEMA.md


All changes require:


Migration

RLS

Indexes

Security Review


---

# AI Behavior


Before editing:


1. Inspect existing files


2. Understand architecture


3. Make a plan


4. Execute


5. Test


6. Review


---

# Validation Before Finish


Run:


Architecture Review

Security Review

UI Review

Performance Review


Do not mark task complete until validation passes.


---

# Golden Rule


Quality > Speed


Follow architecture even if solution takes longer.

