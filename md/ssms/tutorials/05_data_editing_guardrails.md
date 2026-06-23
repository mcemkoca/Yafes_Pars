# Data Editing Guardrails

## Purpose

Update existing records with preview and rollback-by-default behavior.

## Main Script

Use:

```text
database/ssms/08__data_editing_guardrails.sql
```

## Supported Actions

- `UPDATE_TASK_STATUS`
- `CLOSE_CLAIM`
- `SOFT_DELETE_DOCUMENT`

## Safe Edit Flow

1. Use `06__query_library_shortcuts.sql` to find the exact ID.
2. Set `ACTION_NAME`.
3. Set `COMMIT_CHANGES = 0`.
4. Fill the ID and target values.
5. Execute and inspect before/after result sets.
6. Confirm the expected row count is exactly one.
7. Set `COMMIT_CHANGES = 1`.
8. Execute again only when the preview is correct.

## Info Tips

- If more than one row is affected, the script throws an error.
- If the preview is unexpected, leave `COMMIT_CHANGES = 0`.
- Use audit queries after significant edit sessions.
