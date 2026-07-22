# Flutter Legacy Migration Map

**Date:** 2026-07-12  
**Phase:** B2 only  
**Status:** `AUTHORIZED_LOTS_COMPLETED`

## Snapshot status

The legacy scope currently has local changes: **29 tracked files**, with a
worktree diff summary of **387 insertions and 1,154 deletions**. Three legacy
files are already deleted locally. Because these changes predate this removal
lot, no file is approved for deletion yet.

A removal snapshot must contain the complete binary-capable patch plus the
untracked-file manifest immediately before deletion. This document is the
inventory snapshot only; it is deliberately not a substitute for that patch.

## Migration map

| Arquivo legado | Implementacao canonica | Imports ativos | Alteracoes locais | Pode remover? | Status |
|---|---|---:|---|---|---|
| `lib/presentation/auth/controllers/auth_controller.dart` | `features/auth/presentation/controllers/auth_controller.dart` | Legacy pages/router only | No tracked diff shown | No | `ISOLATE_THEN_SNAPSHOT` |
| `lib/presentation/auth/views/login_page.dart` | `features/auth/presentation/pages/login_page.dart` | `core/router.dart` | Yes | No | `LOCAL_CHANGES` |
| `lib/presentation/catalog/views/catalog_page.dart` | `features/courses/presentation/pages/catalog_page.dart` | `core/router.dart` | Yes | No | `LOCAL_CHANGES` |
| `lib/presentation/catalog/views/course_detail_page.dart` | `features/courses/presentation/pages/course_detail_page.dart` | `core/router.dart` | Yes | No | `LOCAL_CHANGES` |
| `lib/presentation/dashboard/controllers/dashboard_controller.dart` | `features/dashboard/presentation/controllers/dashboard_controller.dart` | Legacy dashboard only | Yes | No | `LOCAL_CHANGES` |
| `lib/presentation/dashboard/views/dashboard_page.dart` | `features/dashboard/presentation/pages/student_dashboard_page.dart` | `core/router.dart` | Yes | No | `LOCAL_CHANGES` |
| `lib/presentation/dashboard/views/shell_layout.dart` | `app/router/app_router.dart` shell | `core/router.dart` | Yes | No | `LOCAL_CHANGES` |
| `lib/presentation/dashboard/views/lives_page.dart` | `features/lives/presentation/pages/lives_page.dart` | None found | Deleted locally | No | `PRESERVE_DELETION_SNAPSHOT` |
| `lib/presentation/dashboard/views/profile_page.dart` | `features/profile/presentation/pages/student_profile_page.dart` | None found | Deleted locally | No | `PRESERVE_DELETION_SNAPSHOT` |
| `lib/presentation/dashboard/widgets/agenda_item_tile.dart` | Canonical dashboard composition | Legacy dashboard only | Yes | No | `LOCAL_CHANGES` |
| `lib/presentation/dashboard/widgets/course_progress_card.dart` | `features/dashboard/presentation/widgets/my_courses_section.dart` | Legacy dashboard only | Yes | No | `LOCAL_CHANGES` |
| `lib/presentation/dashboard/widgets/dashboard_hero_card.dart` | `features/dashboard/presentation/widgets/dashboard_header.dart` | Legacy dashboard only | Yes | No | `LOCAL_CHANGES` |
| `lib/presentation/dashboard/widgets/referral_gold_card.dart` | `features/referral/presentation/pages/referral_page.dart` | Legacy dashboard only | Yes | No | `LOCAL_CHANGES` |
| `lib/presentation/form_controller.dart` | Feature-specific controllers/validators | `test/unit_test.dart`, legacy login | Yes | No | `ACTIVE_TEST_IMPORT` |
| `lib/presentation/player_controller.dart` | `features/player` plus lesson/progress controllers | Legacy player pages | Yes | No | `LEGACY_API_CONSUMER` |
| `lib/presentation/player/views/course_player_page.dart` | `features/player/presentation/pages/secure_player_page.dart` | `core/router.dart` | Yes | No | `LOCAL_CHANGES` |
| `lib/ui/admin/admin_analytics_page.dart` | No canonical admin replacement confirmed | None found | Yes | No | `CANONICAL_TARGET_REQUIRED` |
| `lib/ui/catalog/catalog_page.dart` | `features/courses/presentation/pages/catalog_page.dart` | None found | Yes | No | `LOCAL_CHANGES` |
| `lib/ui/dashboard/student_dashboard.dart` | `features/dashboard/presentation/pages/student_dashboard_page.dart` | None found | Yes | No | `LOCAL_CHANGES` |
| `lib/ui/player/course_player_page.dart` | `features/player/presentation/pages/secure_player_page.dart` | None found | Yes | No | `LOCAL_CHANGES` |
| `lib/ui/public/course_detail_page.dart` | `features/courses/presentation/pages/course_detail_page.dart` | None found | Yes | No | `LOCAL_CHANGES` |
| `lib/ui/public/home_page.dart` | No canonical public home confirmed | None found | Yes | No | `CANONICAL_TARGET_REQUIRED` |
| `lib/ui/shell/dashboard_layout.dart` | `app/router/app_router.dart` shell | None found | Yes | No | `LOCAL_CHANGES` |
| `lib/ui/shell/public_layout.dart` | No canonical public shell confirmed | None found | No tracked diff shown | No | `CANONICAL_TARGET_REQUIRED` |
| `lib/ui/tasks/task_execution_page.dart` | `features/tasks/presentation/pages/task_execution_page.dart` if completed | None found | Yes | No | `VERIFY_CANONICAL_TARGET` |
| `lib/ui/teacher/course_creation_wizard.dart` | `features/teacher_studio/presentation/pages/course_wizard_page.dart` | None found | Deleted locally | No | `PRESERVE_DELETION_SNAPSHOT` |
| `lib/ui/theme.dart` | `design_system/tokens/liquid_theme.dart` | Compatibility imports may remain | Yes; export shim | No | `COMPATIBILITY_SHIM` |
| `lib/data/datasources/supabase_client.dart` | Supabase/network providers in `app/providers` and `core/network` | Legacy repositories only | No tracked diff shown | No | `ISOLATED_LEGACY` |
| `lib/data/models/course_dto.dart` | `features/courses/domain/entities/course.dart` plus feature models | Legacy data/player/router | No tracked diff shown | No | `ISOLATED_LEGACY` |
| `lib/data/models/profile_dto.dart` | Profile feature entity/model | `lib/data/repositories.dart` only | No tracked diff shown | No | `ISOLATED_LEGACY` |
| `lib/data/repositories.dart` | Feature repository contracts and app providers | Legacy catalog only | Yes | No | `LOCAL_CHANGES` |
| `lib/data/repositories/auth_repository.dart` | Auth domain contract and app provider | Legacy auth controller | Yes | No | `LOCAL_CHANGES` |
| `lib/data/repositories/course_repository.dart` | Courses/lessons domain contracts and app providers | Legacy presentation/router | Yes | No | `LOCAL_CHANGES` |
| `lib/core/router.dart` | `lib/app/router/app_router.dart` | No consumer found | Yes | No | `SNAPSHOT_AND_REMOVE_LAST` |

## Safe-removal procedure

1. Capture `git diff --binary` for the exact legacy scope and preserve the
   untracked-file manifest outside the deletion commit.
2. Confirm zero imports from the canonical app, tests, and tooling.
3. Migrate `test/unit_test.dart` away from `presentation/form_controller.dart`.
4. Resolve the missing canonical targets for public and admin surfaces.
5. Run `flutter analyze` and the complete Flutter test suite before deletion.
6. Delete in bounded groups; run the same gates after every group.

## B2.24 result

- `lib/presentation`: removed after the final test import migrated.
- `lib/data`: removed after zero external imports were confirmed.
- `lib/core/router.dart`: removed; `app/router/app_router.dart` is canonical.
- Removable `lib/ui` pages with confirmed replacements: removed.
- Admin analytics, public home, and public layout: retained because no canonical
  replacement was approved.
- Every removal lot passed Flutter analyze, 38 Flutter tests, 107 backend tests,
  Ruff, and Mypy.
