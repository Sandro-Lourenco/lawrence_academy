---
name: Create Feature
version: 1.0.0
type: Agent Skill

purpose:
  Build a complete production-ready feature following project architecture.

required_personas:
  - backend-architect
  - flutter-architect
  - ui-ux-designer
  - security-engineer
  - qa-engineer

architecture:
  - Clean Architecture
  - Feature First
  - Domain Driven Design
  - Test Driven Development

---

# Skill: Create Feature


# 1. Mission


Create complete features following:


- Product requirements
- Clean Architecture
- Security rules
- Performance rules
- Design System


Do not only generate code.


Engineer the solution.



==================================================


# 2. Required Reading


Before creating ANY feature:


Read:


1.

AGENTS.md


---


2.

Product:


docs/product/PED-overview.md


Understand:

- business goal
- user
- rules


---


3.

Architecture:


docs/architecture/SYSTEM_ARCHITECTURE.md


Understand:

- layers
- dependencies
- structure


---


4.

Database:


docs/database/DATABASE_SCHEMA.md


---


5.

API:


docs/api/SERVICE_API.md


---


6.

Security:


docs/security/SECURITY_COMPLIANCE_SPEC.md


---


7.

Design:


docs/design/design-system.md



Never start coding without context.



==================================================


# 3. Feature Creation Flow


Always follow this order:



```text

Requirement Analysis


↓

Domain Modeling


↓

Database


↓

Backend UseCases


↓

API


↓

Flutter Domain


↓

Flutter State


↓

Flutter UI


↓

Tests


↓

Review

```



Never start from UI.



==================================================


# 4. Step 1 - Understand Feature


Before coding answer:


What problem does this solve?


Who uses this?


What business rules exist?


What permissions are needed?


Does it work offline?


Does it require payment?



Example:


Feature:


Download Lesson



Questions:


Can unpaid users download?


How long offline?


Storage limit?


Subscription expired?



==================================================


# 5. Step 2 - Identify Domain


Find bounded context.


Examples:



Course Feature:


```text
features/course
```



Payment:


```text
features/payment
```



Authentication:


```text
features/auth
```



Never mix domains.



==================================================


# 6. Step 3 - Domain Layer


Create first:


Entities


Value Objects


Repository Interfaces


Domain Errors



Example:


```text
course/


domain/


├── entities/


├── repositories/


└── failures/

```



Domain cannot import:


Flutter


FastAPI


Supabase


SQLite



==================================================


# 7. Step 4 - Create UseCases


Every action requires UseCase.



Examples:


```text
CreateCourseUseCase


EnrollStudentUseCase


DownloadLessonUseCase


CancelSubscriptionUseCase

```



Rules:


One intention


One class


Easy to test



==================================================


# 8. Step 5 - Database Changes


Before changing database:


Read:


DATABASE_SCHEMA.md



Required:


Migration


Indexes


Relations


RLS


Audit if needed



Never modify database manually.



==================================================


# 9. Step 6 - Backend Implementation


Backend flow:



```text

Route


↓

DTO


↓

UseCase


↓

Repository


↓

Database

```



Create:


```text
module/


domain/


application/


infrastructure/


interface/

```



Forbidden:


Business inside route


SQL inside controller



==================================================


# 10. Step 7 - API Contract


Update:


SERVICE_API.md



Every endpoint defines:


Method


Route


Request DTO


Response DTO


Errors


Permissions



Example:


```http
POST /courses/{id}/subscribe
```



Must define:


AUTH REQUIRED


Permission


Possible failures



==================================================


# 11. Step 8 - Flutter Implementation


Follow:



```text
feature/


presentation/


application/


domain/


data/

```



Create:


Entity


Repository


UseCase


Controller


State


Page



==================================================


# 12. Riverpod Rules


Use:


AsyncNotifier


Notifier



Never:


FutureBuilder calling API


setState for business logic



Flow:


```text
Widget

↓

Controller

↓

UseCase

↓

Repository

```



==================================================


# 13. UI Creation


Activate:


ui-ux-designer.md



Read:


Page Specification


Design System



Every screen needs:


Loading


Success


Empty


Error


Offline



==================================================


# 14. Offline Check


Ask:


Does this feature need offline?



If YES implement:


Local datasource


SQLite


Sync Queue


Conflict rules



Never fake offline support.



==================================================


# 15. Security Check


Activate:


security-engineer.md



Validate:


Authentication


Authorization


RLS


Input validation


Sensitive data



==================================================


# 16. Testing


Activate:


qa-engineer.md



Create:


Unit Tests


UseCase Tests


Repository Tests


Widget Tests



Feature is not done without tests.



==================================================


# 17. Performance Review


Check:


Pagination


Cache


Query optimization


Widget rebuilds


Memory



==================================================


# 18. Documentation Update


Update if needed:


API docs


Database docs


Page docs


Architecture decisions



==================================================


# 19. Final Review


Before finishing:


Run:


Architecture Review


UI Review


Security Review


QA Review



Questions:


[ ] Follows Clean Architecture?


[ ] Has tests?


[ ] Secure?


[ ] Fast?


[ ] Beautiful?


[ ] Maintainable?



==================================================


# Forbidden


Never:


❌ Start coding UI first


❌ Create random services


❌ Skip UseCases


❌ Put logic in Widgets


❌ Query database directly


❌ Ignore errors


❌ Skip tests


❌ Break documentation rules



==================================================


# Final Rule


A feature is not a screen.


A feature is:


Business rule

+

Data

+

API

+

Experience

+

Quality
