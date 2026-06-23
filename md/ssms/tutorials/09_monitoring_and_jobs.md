# Monitoring And Jobs

Use this workflow when an operator, admin, or DBA wants a quick SSMS view of
database readiness, backlog pressure, backup visibility, and SQL Agent handoff
items.

## Open The Script

1. Open `database/ssms/15__monitoring_and_job_readiness.sql` in SSMS.
2. Enable `Query > SQLCMD Mode`.
3. Confirm `YAFES_SQL_DATABASE` contains `DEV`.
4. Confirm `TENANT_CODE` is the expected tenant.
5. Run the script.

## Read The Result Sets

1. Start with `01 - Monitoring context`.
2. Check `02 - Database readiness signals` for migration count, recovery model,
   updateability, and Query Store state.
3. Review `03 - Tenant operations monitoring` for open tasks, overdue tasks,
   open claims, renewal candidates, and recent audit volume.
4. Use `04 - SQL Agent job blueprint` as the DBA handoff list.
5. Check `05 - SQL Agent observed Yafes jobs` to see whether approved jobs
   already exist.
6. Review `07 - Backup recency signal` before release or restore planning.

## Operator Rule

This script is read-only. It does not create SQL Agent jobs and does not change
data. If a signal shows `ACTION` or `REVIEW`, open the linked SSMS script or
send the result set to the named owner.
