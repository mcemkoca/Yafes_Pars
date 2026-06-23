# DEV Validation Evidence - 2026-06-04

## Summary

| Field | Value |
| --- | --- |
| Environment | Local ephemeral SQL Server DEV container |
| Source database | `YafesPars_DEV` |
| Evidence date | 2026-06-04 |
| Commit line | PR #1 feature branch |
| Tenant code | `DEV-BE-BROKER` |
| Tenant display name | Yafes Broker Operations |
| Result | PASS |

## Evidence

| Check | Result |
| --- | --- |
| Static quality gate | PASS |
| Migration scripts `000..018` | PASS, 19 scripts |
| Validation scripts `001..017` on source DEV database | PASS, 17 scripts |
| SSMS dashboard contract | PASS |
| Admin role matrix contract | PASS |
| SQL Server validation workflow | PASS in GitHub Actions |
| SSMS workbench validation workflow | PASS in GitHub Actions |

## Restored Database Signals

| Signal | Value |
| --- | --- |
| Domain table count | 108 |
| Active role count | 4 |
| Active permission count | 18 |
| Active DEV sample user count | 3 |

## Notes

- No secret, password, backup file, or execution log artifact was committed.
- The database source remains migrations `000..018`; future schema work starts
  at `019+`.
- The local browser preview remains non-persistent. Real data work stays in
  SSMS with SQLCMD Mode enabled against DEV/TEST/PROD change-controlled
  environments.
