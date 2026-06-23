# Restore Drill Evidence - DEV - 2026-06-04

## Summary

| Field | Value |
| --- | --- |
| Environment restored from | Local ephemeral SQL Server DEV container |
| Run ID | `20260604093451` |
| Restore target | `YafesPars_RESTORE_DEV` |
| Source database | `YafesPars_DEV` |
| SQL Server version | 16.0.4260.1 RTM, Developer Edition |
| Backup file size | 20,013,056 bytes |
| Evidence generated UTC | 2026-06-04T07:35:22Z |
| Tenant code | `DEV-BE-BROKER` |
| Tenant display name | Yafes Broker Operations |
| Result | PASS |

## Restore Steps

| Step | Result |
| --- | --- |
| Apply migrations `000..018` to source DEV database | PASS |
| Run validations `001..017` on source DEV database | PASS |
| Create copy-only backup | PASS |
| Run `RESTORE VERIFYONLY` | PASS |
| Restore backup to `YafesPars_RESTORE_DEV` | PASS |
| Run validations `001..017` on restored database | PASS |
| Open SSMS dashboard script against restored database | PASS |
| Run admin role matrix against restored database | PASS |

## Restored Database Signals

| Signal | Value |
| --- | --- |
| Domain table count | 108 |
| Active role count | 4 |
| Active permission count | 18 |
| Active DEV sample user count | 3 |
| Schema migration success rows | 17 |

## Decision

The DEV restore drill is accepted for repository readiness. TEST/PROD restore
drill evidence must still be collected on the approved infrastructure using
`md/database/restore-drill-evidence-template.md`.
