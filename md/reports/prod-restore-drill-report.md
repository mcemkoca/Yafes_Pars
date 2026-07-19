# PROD Restore Drill Evidence Report

**Environment:** PROD  
**Status:** PENDING — BLOCKED BY PROD ACCESS  
**Owner:** Deuterium12{MCK}  
**Plan:** `md/restore/prod-restore-drill-plan.md`  
**Template version:** 2026-07-19

> **RESTRICTIONS:**
> - Do NOT restore PROD backup to the PROD instance itself.
> - Do NOT allow the restore-target to be network-accessible after the drill.
> - Do NOT retain a live copy of PROD data beyond the drill window.
> - TWO named signatories required.

---

## Drill Summary

| Field | Value |
|---|---|
| Environment | PROD |
| Source backup instance | |
| Restore target instance (isolated) | |
| Backup file selected | |
| Backup timestamp | |
| Backup file size | |
| Drill start UTC | |
| Drill end UTC | |
| Elapsed time (minutes) | |
| Target RTO | 120 minutes |
| RTO met? | |
| First executor | |
| Second executor | |
| Change management ticket | |

---

## Step 1 — Backup Selection

| Field | Value |
|---|---|
| Most recent PROD full backup | |
| Backup file path (read-only access) | |
| Backup taken at UTC | |
| RESTORE VERIFYONLY result | |
| Data age (hours since backup) | |

---

## Step 2 — Restore to Isolated Instance

```sql
RESTORE DATABASE [YafesPars_ProdRestoreDrill]
FROM DISK = N'<backup_path>'
WITH MOVE 'YafesPars' TO N'<isolated_data_path>',
     MOVE 'YafesPars_log' TO N'<isolated_log_path>',
     REPLACE, STATS = 10;
```

| Field | Value |
|---|---|
| Target instance confirmed isolated from network | |
| RESTORE result | |
| Errors encountered | |
| Duration (seconds) | |

---

## Step 3 — Validation (`database/tools/restore-drill-validation.sql`)

Run against `YafesPars_ProdRestoreDrill` on isolated instance.

| Check | Expected | Actual | Status |
|---|---|---|---|
| Migration count | ≥ 48 | | |
| All migrations SUCCESS | Yes | | |
| Table count | ≥ 140 | | |
| Orphan FK violations | 0 | | |

---

## Step 4 — Cleanup

| Action | Done |
|---|---|
| `YafesPars_ProdRestoreDrill` database dropped | |
| Snapshot discarded / isolated instance decommissioned | |
| Backup file access confirmed revoked | |
| No live copy of PROD data retained | |
| Drill logged in change-management system | |

---

## Pass Criteria

- [ ] Restore completed without errors within 120 minutes (RTO)
- [ ] Migration count ≥ 48, all SUCCESS
- [ ] Table count ≥ 140
- [ ] No orphan FK violations
- [ ] Two signatories recorded below
- [ ] Restore target dropped or snapshot discarded after evidence recorded

---

## Sign-Off (TWO SIGNATORIES REQUIRED)

| Field | Value |
|---|---|
| Drill result | PASS / FAIL |
| Issues found | |
| Corrective actions | |
| First signatory name | |
| First signatory sign-off | |
| Second signatory name | |
| Second signatory sign-off | |
| Date | |
