# Query And Search

## Purpose

Find records safely before using create/edit templates.

## Main Script

Use:

```text
database/ssms/06__query_library_shortcuts.sql
```

## Common Workflow

1. Set `TENANT_CODE`.
2. Set `SEARCH_TEXT` if you are looking for a specific person, institution, or vehicle.
3. Execute the script.
4. Copy IDs from Results Grid into data entry or editing bridge scripts.

## Search Sections

- Customers: `person.SP_SearchPerson`
- Institutions: `institution.SP_SearchInstitution`
- Vehicles: `risk.SP_SearchVehicle`
- Recent policies: `policy.VW_PolicyDashboard`
- Open claims: `claim.VW_ClaimDashboard`
- Open tasks: `tasking.VW_OpenTaskDashboard`
- Lookup helper: status, domain, priority, and workflow values

## Info Tips

- Never type GUIDs manually when you can copy from the Results Grid.
- Use `TOP_ROWS` to limit large result sets.
- Search first, edit second.
