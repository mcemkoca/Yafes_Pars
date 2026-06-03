# Mustafa Plan

This is the living plan for Yafes Pars. It keeps the roadmap, SSMS expert
assessment, clean-up decisions, and next update queue in one place.

## Current Baseline

- Product direction: SSMS-first SQL Server operations platform.
- Primary user surface: SQL Server Management Studio, Query Editor, Results Grid,
  Messages, SQLCMD Mode, and guarded scripts.
- Database scope: 108 tables across 11 domain schemas.
- Protected migration line: `000` through `018`; new schema changes start at
  `019+`.
- Documentation structure: operational markdown now lives under `md/`.
- Root `README.md`: customer-facing, bilingual English/Turkish entry point.

## SSMS Expert Assessment

### Strong Points

- Domain split is healthier than the imported legacy package: `risk` replaces
  unsafe generic object naming, and policy/claim/document/tasking are separated.
- Operator scripts use SQLCMD variables, DEV checks, info tips, and read-only or
  rollback-first patterns.
- CI already protects migration order, SQL Server syntax, destructive SQL
  patterns, SSMS conventions, and required documentation.
- The SSMS workbench preview now shows the real domain count, a working logic
  map, table catalog, and planning cards.

### Fixed In This Update

- Moved project markdown into a clean `md/` documentation hub.
- Added `md/mustafaplan.md` as the single planning file.
- Removed tracked legacy package `.zip` files, tracked `.env` files, and the
  remaining non-production `trust plan` source/assets folder.
- Expanded `.gitignore` for secrets, database backups, VM images, package
  archives, and local build/runtime noise.
- Removed or quarantined unsafe example credentials and wildcard CORS patterns
  from tracked production paths.
- Added a quality-gate artifact policy so tracked `.env`, package, backup,
  database, or VM artifacts fail CI.
- Added `database/ssms/13__visual_workflow_board.sql` as the SSMS-safe version
  of the visual/mind-map idea: domain cards, subheading cards, node/edge rows,
  template routes, and readiness gaps.
- Updated the visual workbench so it mirrors the new SSMS board flow instead of
  behaving like a separate web-first application.
- Started the productization phase for the SSMS workbench preview: toolbar buttons, menu
  commands, result tabs, Object Explorer nodes, copy/export commands, parse,
  execute, cancel, and state feedback are now wired instead of decorative.
- Synced the workbench preview with a generated infrastructure manifest:
  database name, tenant context, migration/validation counts, SSMS shortcuts,
  schema groups, table counts, and backend route inventory now come from the
  repository source instead of hand-maintained UI constants.
- Unblocked backend and SQL Server validation in CI; the DEV migration flow now
  runs with SQLCMD quoted identifiers and surfaces useful failure logs.
- Verified the protected `000` through `018` migration line and `001` through
  `017` validation line against a real SQL Server 2022 DEV container.
- Added `database/ssms/14__admin_role_permission_matrix.sql` as the user-friendly
  RBAC/admin matrix: expected roles, permissions, tenant user assignments,
  least-privilege checks, and handoff rows.

### Remaining Risks And Gaps

| Priority | Area | Finding | Best Fix |
| --- | --- | --- | --- |
| P0 | Token hygiene | A token was shared during coordination. It should be treated as exposed. | Rotate/revoke the token and use GitHub secrets or local credential manager only. |
| P1 | Legacy reference notes | `md/trust-plan/` still contains old comparison notes from the imported package. | Keep useful schema/UX lessons, then delete notes that no longer help the SSMS-first product. |
| P1 | Table reconciliation | The current migration source defines 108 tables, while the older visual/package reference mentioned 89 tables. | Compare table names before removing, merging, or adding any table. |
| P1 | Workbench preview depth | The workbench controls are now wired and synchronized from the manifest, but execution is still non-persistent and uses prepared DEV preview data. | Keep real data work inside SSMS DEV; add backend-backed preview behavior only after the SSMS contract is stable. |
| P1 | Operator permissions | The SSMS RBAC matrix exists, but final SQL logins/roles still need TEST/PROD environment evidence. | Run `14__admin_role_permission_matrix.sql` in TEST/PROD-like environments and record access-review evidence. |
| P1 | Backup and restore | Strategy exists, but no restore drill evidence is committed. | Run restore drill and record result in readiness checklist. |
| P2 | Guided bridge coverage | Core bridge templates exist, but not every daily create/edit path has a stored procedure bridge. | Add bridge coverage by department priority. |
| P2 | Finance model | Claim has paid/reserved fields, but no full ledger/commission model. | Design migration `019+` only after business owner confirms accounting flow. |
| P2 | Import/export | Bulk onboarding needs staging, validation issue, and export job tables. | Design `019+` staging tables and SSMS validation grids. |
| P3 | Monitoring | SQL Agent job and operational monitoring docs are planned, not proven. | Add job-monitor result sets after DEV/TEST environment is available. |

## Clean Structure Rule

- Keep source code, SQL scripts, and workflows in their functional folders.
- Keep human-readable operational docs under `md/`.
- Keep GitHub-required files in conventional locations.
- Do not commit local packages, backups, VM images, `.env` files, or secrets.
- Treat `md/trust-plan/` as legacy reference notes, not production truth.

## Next Update Queue

1. Rotate any exposed coordination token and confirm no active token is stored in
   Git.
2. Record repeatable DEV/TEST execution evidence after each environment refresh.
3. Compare the old 89-table package/reference against the current 108-table
   migration source and record keep/merge/remove decisions.
4. Review `md/trust-plan/` notes and keep only the parts that still help the
   SSMS-first product.
5. Add TEST/PROD role/permission evidence for operator, admin, auditor, and deployer.
6. Add restore drill evidence to the production readiness checklist.
7. Design migration `019+` candidates only after owner approval:
   finance/commission, import/export staging, entity notes, product templates.
8. Add more bridge templates for high-frequency operator actions.
9. Add SQL Agent/monitoring result sets once the DEV/TEST SQL Server instance is
   stable.

## Working Agreement

Every update should end with:

- focused diff,
- local validation,
- commit,
- push,
- short report.
