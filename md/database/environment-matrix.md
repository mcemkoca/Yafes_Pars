# Environment Matrix

This matrix keeps DEV, TEST, and PROD behavior explicit for operators.

| Area | DEV | TEST | PROD |
| --- | --- | --- | --- |
| Database name | `YafesPars_DEV` | `YafesPars_TEST` | `YafesPars` |
| SQL Server edition | Developer | Standard/Enterprise or approved test edition | Standard/Enterprise |
| Data | Demo or synthetic | Sanitized or approved test data | Live business data |
| Demo seed `018` | Allowed | Optional | Not allowed |
| Rollback scripts | Allowed after review | Restricted | Separate approval only |
| Rebuild from migrations | Allowed | Allowed with approval | Not allowed as normal rollback |
| Backup before migration | Required | Required | Required |
| Static quality gate | Required | Required | Required |
| SQL validation | Required | Required | Required |
| SSMS dashboard | Required | Required | Required |
| Secrets in repo | Never | Never | Never |
| Public SQL access | No | No | No |
| RDP | Restricted | Restricted | Restricted/JIT |
| Change approval | Lightweight | Release approval | Formal approval |

## Naming Rules

- DEV database names must contain `DEV`.
- TEST database names must contain `TEST` or be clearly tagged as non-production.
- PROD database names must not include `DEV`, `TEST`, `LOCAL`, or `SANDBOX`.
- Tools should refuse production-like names unless explicitly designed for PROD
  runbook execution.

## Operator Rule

When the environment is unclear, stop. Confirm the SQL Server name, database
name, backup target, and approval record before running any script that changes
data or schema.
