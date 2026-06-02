# Quick Start

## Goal

Start SSMS work with minimum risk and a known DEV context.

## Steps

1. Open SQL Server Management Studio.
2. Connect to the DEV SQL Server instance.
3. Open `database/ssms/00__open_first_safety_check.sql`.
4. Enable `Query > SQLCMD Mode`.
5. Set `YAFES_SQL_DATABASE` to the DEV database name.
6. Execute the script.
7. Confirm the Results Grid shows the expected server, machine, and database.
8. Open `database/ssms/05__operator_dashboard_home.sql`.

## Info Tips

- Stop if the database name does not contain `DEV`.
- Stop if the server or machine name looks like production.
- Keep the dashboard open as the first SSMS tab.
- Use query library results to copy IDs into bridge templates.

## Daily Startup

Run these scripts in order:

1. `05__operator_dashboard_home.sql`
2. `10__daily_operator_checklist.sql`
3. `02__operations_dashboard.sql`

Resolve any `ACTION` rows before data entry.
