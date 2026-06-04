# Data Entry Bridge

## Purpose

Create records through stored procedures instead of direct table edits.

## Main Script

Use:

```text
database/ssms/07__data_entry_bridge_templates.sql
```

## Supported Actions

- `CREATE_NATURAL_PERSON`
- `CREATE_POLICY`
- `CREATE_POLICY_VERSION`
- `ADD_POLICY_PARTY`
- `CREATE_VEHICLE_OBJECT`
- `ADD_POLICY_OBJECT`
- `CREATE_CLAIM`
- `CLOSE_CLAIM`

## Safe Create Flow

1. Set `ACTION_NAME`.
2. Keep `EXECUTE_ACTION = 0`.
3. Fill only the variables for the selected action.
4. Execute and inspect preview result sets.
5. Fix missing or invalid lookup values.
6. Set `EXECUTE_ACTION = 1`.
7. Execute again.
8. Copy the returned ID into the next template if needed.

## Info Tips

- Procedure-based creates enforce tenant and key rules better than ad hoc inserts.
- If a lookup validation says `MISSING`, do not execute.
- Do not run multiple create actions by editing the script body; use `ACTION_NAME`.
- For vehicle policies, create or search the vehicle first, then copy
  `created_insurable_object_id` into `ADD_POLICY_OBJECT`.
