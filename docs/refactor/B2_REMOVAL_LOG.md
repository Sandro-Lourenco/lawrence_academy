# B2 Removal Log

**Phase:** B2.24  
**Snapshot:** `docs/refactor/FLUTTER_LEGACY_SNAPSHOT_REPORT.md`

| Lot | Scope | Removed | Validation | Status |
|---|---|---:|---|---|
| A | `lib/presentation` | 14 in lot; 3 prior deletions preserved | Flutter analyze, 38 Flutter tests, 107 pytest, Ruff, Mypy | `PASSED` |
| B | `lib/ui` | 7 in lot; 1 prior deletion preserved | Same gates; retained imports migrated to canonical theme | `PASSED` |
| C | `lib/data` | 6 | Same gates | `PASSED` |
| D | `lib/core/router.dart` | 1 | Same gates | `PASSED` |

Files without a canonical replacement remain explicitly outside removal scope.

Retained: `ui/admin/admin_analytics_page.dart`, `ui/public/home_page.dart`, and
`ui/shell/public_layout.dart`. They have no canonical feature replacement and
were updated only to import the canonical design token directly.
