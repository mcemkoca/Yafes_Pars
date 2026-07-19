# TEST Restore Drill Evidence Report

**Environment:** TEST  
**Status:** PENDING ENVIRONMENT EXECUTION  
**Owner:** Deuterium12{MCK}  
**Plan:** `md/restore/test-restore-drill-plan.md`  
**Template version:** 2026-07-19

---

## Drill Summary

| Field | Value |
|---|---|
| Environment | TEST |
| Source backup instance | |
| Restore target instance | |
| Backup file selected | |
| Backup timestamp | |
| Backup file size | |
| Drill start UTC | |
| Drill end UTC | |
| Elapsed time (minutes) | |
| Target RTO | 60 minutes |
| RTO met? | |
| Executor | |

---

## Step 1 — Backup Selection

| Field | Value |
|---|---|
| Most recent full backup found | |
| Backup file path | |
| Backup taken at UTC | |
| Verified with RESTORE VERIFYONLY | |

---

## Step 2 — Restore

```sql
-- Command used:
RESTORE DATABASE [YafesPars_RestoreDrill]
FROM DISK = N'<backup_path>'
WITH MOVE 'YafesPars' TO N'<data_file_path>',
     MOVE 'YafesPars_log' TO N'<log_file_path>',
     REPLACE, STATS = 10;
```

| Field | Value |
|---|---|
| RESTORE command result | |
| Errors encountered | |
| Duration (seconds) | |

---

## Step 3 — Validation (`database/tools/restore-drill-validation.sql`)

Run against `YafesPars_RestoreDrill` database.

| Check | Expected | Actual | Status |
|---|---|---|---|
| Migration count | ≥ 48 | | |
| All migrations SUCCESS | Yes | | |
| Table count | ≥ 140 | | |
| Orphan FK violations | 0 | | |
| Schema version | 1 | | |

---

## Step 4 — SSMS Operator Smoke Test (optional)

| Script | Status |
|---|---|
| `05__operator_dashboard_home.sql` | |
| `14__admin_role_permission_matrix.sql` | |

---

## Step 5 — Cleanup

| Action | Done |
|---|---|
| `YafesPars_RestoreDrill` database dropped | |
| Backup file access confirmed revoked | |
| No live copy of TEST data retained | |

---

## Pass Criteria

- [ ] Restore completed without errors within 60 minutes
- [ ] Migration count ≥ 48, all SUCCESS
- [ ] Table count ≥ 140
- [ ] No orphan FK violations
- [ ] Restore target dropped after evidence recorded

---

## Sign-Off

| Field | Value |
|---|---|
| Drill result | PASS / FAIL |
| Issues found | |
| Corrective actions | |
| Executor sign-off | |
| Approver sign-off | |
| Date | |
