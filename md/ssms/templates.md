# SSMS Templates

These templates are copy-friendly starting points for operators and maintainers.
They are not migrations. Use them inside SSMS tabs after running the dashboard
and safety checks.

## Files

- `operator-query-header.sql`: standard header for new operator queries.
- `guided-search-template.sql`: safe read-only search pattern.
- `guarded-update-template.sql`: rollback-by-default update pattern.
- `report-grid-template.sql`: chart/export-ready report pattern.

## Rule

Every operator query should include:

- SQLCMD variable block
- DEV database target
- `DB_NAME() LIKE '%DEV%'` runtime guard
- tenant resolution
- `INFO TIP` comments or result columns
- preview before mutation
- rollback default for updates

Templates are real SSMS starting points, not demo-only snippets. Keep SQLCMD
Mode enabled before running or copying them into new operator scripts.
