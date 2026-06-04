# Remaining Work Cockpit

Use this screen after the delivery gap register. It turns open blockers into
actionable owner evidence, 019+ decision, bridge ranking, and DBA handoff rows.

## Open

1. Open `database/ssms/17__remaining_work_cockpit.sql`.
2. Enable `Query > SQLCMD Mode`.
3. Confirm `YAFES_SQL_DATABASE` contains `DEV`.
4. Confirm `TENANT_CODE` is the tenant you are reviewing.
5. Execute the script.

## Read The Grids

1. `02 - Workstream closure board` shows every remaining workstream, owner,
   evidence needed, and stop condition.
2. `03 - Environment evidence handoff` lists TEST/PROD migration, access, and
   restore evidence artifacts.
3. `04 - Owner decision intake for 019+ candidates` prepares finance, import,
   product, and note decisions without creating tables.
4. `05 - Next bridge workflow ranking queue` helps rank the next non-task
   procedure-backed action.
5. `06 - SQL Agent promotion board` prepares DBA job approval without creating
   SQL Agent jobs.
6. `07 - Closure gates before release` summarizes the release gates.

## Operator Rule

Do not implement migration `019+`, SQL Agent jobs, or new bridge procedures from
this screen alone. Use the cockpit to collect owner decisions first, then add a
forward-only migration or stored procedure in a separate reviewed change.
