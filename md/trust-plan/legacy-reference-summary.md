# Legacy Reference Summary

This folder is now a sanitized reference area. The old web-first app plans,
VM deployment notes, package readmes, and duplicated task plans were removed
from the active documentation tree.

## Useful Lessons Kept

| Lesson | Current product decision |
| --- | --- |
| The insurance model needs clear person, institution, risk/object, policy, and claim domains. | Current migrations keep those domains and place them in SQL Server schemas. |
| Operators need guided flows, not raw table editing. | SSMS workbench scripts provide dashboards, bridge templates, guardrails, tutorials, and info tips. |
| The old package referenced 89 tables. | `md/database/table-reconciliation-89-vs-108.md` records why the current source has 108 tables. |
| Visual planning helps explain the model. | `13__visual_workflow_board.sql` turns the visual idea into SSMS-safe node, edge, and route grids. |

## Files Still Useful Here

- `research/insurance_schema_comparison.md`
- `research/below_70_comparison.md`

These are comparison notes only. They are not implementation source.

## Files Removed From Active Docs

- old React/web dashboard plans
- old VM/VHDX deployment notes
- duplicated zero-error/research/GitHub task plans
- old server/package readmes

The production source of truth is the SQL, SSMS, and documentation structure in
the root repository and `md/` folders.
