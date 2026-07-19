# TEST Restore Drill Plan

**Environment:** TEST
**Status:** PENDING ENVIRONMENT EXECUTION
**Frequency:** Quarterly (or before major migrations)
**Owner:** Deuterium12{MCK}

## Objective

Verify that the TEST database backup can be restored to a clean SQL Server
instance and passes structural integrity validation within the agreed RTO.

## Target RTO

≤ 60 minutes from backup selection to validation pass.

## Prerequisites

| Requirement | Status |
|-------------|--------|
| Access to TEST SQL Server backup files | PENDING |
| Access to a clean restore-target SQL Server instance | PENDING |
| `database/tools/restore-drill-validation.sql` available | READY |
| DBA or authorized operator available | PENDING |

## Drill Steps

### 1. Select Backup

- Identify the most recent full backup of `YafesPars` from the TEST instance.
- Record: backup file name, backup timestamp, file size.

### 2. Restore

```sql
RESTORE DATABASE [YafesPars_RestoreDrill]
FROM DISK = N'<backup_path>'
WITH MOVE 'YafesPars' TO N'<data_file_path>',
     MOVE 'YafesPars_log' TO N'<log_file_path>',
     REPLACE, STATS = 10;
```

### 3. Validate

Run `database/tools/restore-drill-validation.sql` against `YafesPars_RestoreDrill`.

Record:
- Migration count (expected ≥ 48)
- Table count (expected ≥ 140)
- Orphan FK count (expected = 0)

### 4. Record Evidence

Fill in `md/reports/test-restore-drill-report.md`.

### 5. Clean Up

Drop the `YafesPars_RestoreDrill` database after evidence is recorded.

## Pass Criteria

- [ ] Restore completed without errors
- [ ] Migration count ≥ 48, all SUCCESS
- [ ] Table count ≥ 140
- [ ] No orphan FK violations
- [ ] Completion within RTO (60 min)
