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
- Added `md/database/table-reconciliation-89-vs-108.md`; the legacy 89-table
  source is now recorded as comparison input, and the active 108-table migration
  model remains the source of truth.
- Sanitized `md/trust-plan/` by removing old web-first app, VM/VHDX, package,
  and duplicated planning notes while keeping only comparison research and a
  short legacy reference summary.
- Added access-review and restore-drill evidence templates, then linked them
  from readiness, backup, and security docs.
- Recorded DEV validation evidence in `md/reports/dev-validation-evidence-2026-06-04.md`.
- Recorded DEV access-review evidence in
  `md/reports/access-review-evidence-dev-2026-06-04.md`.
- Ran a DEV restore drill through SQL Server backup, `RESTORE VERIFYONLY`,
  restore to `YafesPars_RESTORE_DEV`, restored validations, dashboard check,
  and admin matrix check; evidence is in
  `md/reports/restore-drill-evidence-dev-2026-06-04.md`.
- Hardened stored procedure bridges with tenant ownership checks for policy
  parties, policy objects, claim handlers, creator users, and claim close
  updater users.
- Extended `07__data_entry_bridge_templates.sql` with `ADD_POLICY_OBJECT` and
  `CLOSE_CLAIM`, plus correct claim-handler email to `person_id` resolution.
- Updated `08__data_editing_guardrails.sql` so blank/default IDs show
  `NO_TARGET` preview rows instead of failing during safe rollback mode.
- Added `database/ssms/15__monitoring_and_job_readiness.sql` for DEV health,
  backlog, backup visibility, SQL Agent observed jobs, and DBA handoff grids.
- Added monitoring tutorial coverage in
  `md/ssms/tutorials/09_monitoring_and_jobs.md`.
- Verified migrations, validations, `07`, `08`, and `15` against SQL Server
  2022 in an ephemeral container.

### Remaining Risks And Gaps

| Priority | Area | Finding | Best Fix |
| --- | --- | --- | --- |
| P0 | Token hygiene | A token was shared during coordination. It should be treated as exposed. | Rotate/revoke the token and use GitHub secrets or local credential manager only. |
| P1 | Workbench preview depth | The workbench controls are now wired and synchronized from the manifest, but execution is still non-persistent and uses prepared DEV preview data. | Keep real data work inside SSMS DEV; add backend-backed preview behavior only after the SSMS contract is stable. |
| P1 | Operator permissions | DEV access-review evidence exists, but final SQL logins/roles still need TEST/PROD environment evidence. | Run approved TEST/PROD access review and record sign-off. |
| P1 | Backup and restore | DEV restore drill evidence exists, but TEST/PROD restore drill evidence is still environment-dependent. | Run restore drill on approved TEST/PROD infrastructure and record sign-off. |
| P2 | Guided bridge coverage | Core create/close/link bridges now cover natural person, policy, version, party, object, claim create, and claim close; department-specific edge cases remain. | Add bridge coverage by department priority. |
| P2 | Finance model | Claim has paid/reserved fields, but no full ledger/commission model. | Design migration `019+` only after business owner confirms accounting flow. |
| P2 | Import/export | Bulk onboarding needs staging, validation issue, and export job tables. | Design `019+` staging tables and SSMS validation grids. |
| P3 | Monitoring | SSMS monitoring and job-readiness result sets exist, but approved SQL Agent jobs and TEST/PROD schedules are still environment-dependent. | Create approved jobs after DEV/TEST owners and schedules are confirmed. |

## Clean Structure Rule

- Keep source code, SQL scripts, and workflows in their functional folders.
- Keep human-readable operational docs under `md/`.
- Keep GitHub-required files in conventional locations.
- Do not commit local packages, backups, VM images, `.env` files, or secrets.
- Treat `md/trust-plan/` as legacy reference notes, not production truth.

## Next Update Queue

1. Rotate any exposed coordination token and confirm no active token is stored in
   Git.
2. Add TEST/PROD execution evidence after the target environments are refreshed.
3. Add TEST/PROD role/permission evidence for operator, admin, auditor, and deployer.
4. Add TEST/PROD restore drill evidence to the production readiness checklist.
5. Design migration `019+` candidates only after owner approval:
   finance/commission, import/export staging, entity notes, product templates.
6. Add more bridge templates for department-specific high-frequency actions.
7. Turn monitoring result sets into approved SQL Agent jobs once DEV/TEST
   owners and schedules are confirmed.

## Working Agreement

Every update should end with:

- focused diff,
- local validation,
- commit,
- push,
- short report.
