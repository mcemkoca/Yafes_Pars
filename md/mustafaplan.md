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
- The SSMS demo now shows the real domain count, a working logic map, table
  catalog, and planning cards.

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

### Remaining Risks And Gaps

| Priority | Area | Finding | Best Fix |
| --- | --- | --- | --- |
| P0 | Real SQL execution | Local checks passed, but a real DEV SQL Server/SSMS execution still needs evidence. | Run full migration and validation flow against `YafesPars_DEV`, then attach the execution log. |
| P0 | Token hygiene | A token was shared during coordination. It should be treated as exposed. | Rotate/revoke the token and use GitHub secrets or local credential manager only. |
| P1 | Legacy reference notes | `md/trust-plan/` still contains old comparison notes from the imported package. | Keep useful schema/UX lessons, then delete notes that no longer help the SSMS-first product. |
| P1 | Operator permissions | SSMS scripts are safe, but final SQL logins/roles need real environment testing. | Add TEST/PROD role matrix evidence and least-privilege execution proof. |
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

1. Run real DEV SQL Server validation and record evidence.
2. Rotate any exposed coordination token and confirm no active token is stored in
   Git.
3. Review `md/trust-plan/` notes and keep only the parts that still help the
   SSMS-first product.
4. Add role/permission test evidence for operator, admin, auditor, and deployer.
5. Add restore drill evidence to the production readiness checklist.
6. Design migration `019+` candidates only after owner approval:
   finance/commission, import/export staging, entity notes, product templates.
7. Add more bridge templates for high-frequency operator actions.
8. Add SQL Agent/monitoring result sets once the DEV/TEST SQL Server instance is
   stable.

## Working Agreement

Every update should end with:

- focused diff,
- local validation,
- commit,
- push,
- short report.
