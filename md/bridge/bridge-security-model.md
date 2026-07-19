# Bridge Security Model

## Principles

1. **DEV-only guard** — the bridge script throws if `DB_NAME()` does not contain
   `DEV`. Running against TEST or PROD requires a separate approved script.

2. **PREVIEW_FIRST** — every action runs in preview mode (`EXECUTE_ACTION = 0`)
   by default. The operator must review the preview grids and set
   `EXECUTE_ACTION = 1` explicitly to perform the write.

3. **Tenant isolation** — every action resolves `@TenantId` from `TENANT_CODE`
   and all reads and writes are scoped to that tenant. Cross-tenant operations
   are structurally impossible through the bridge.

4. **Operator identity** — `CREATED_BY_USER_EMAIL` resolves to an active
   `core.AppUser` for the tenant. Writes that require `created_by_user_id` use
   this resolved value. NULL is tolerated only where the SP explicitly allows it.

5. **No raw DML** — bridge actions call stored procedures only. Direct INSERT,
   UPDATE, or DELETE against operational tables is not permitted in bridge
   scripts.

6. **Audit trail** — all write SPs record the operator's user_id and UTC
   timestamp in the respective audit columns or audit log tables.

7. **Validation grids before write** — every action emits at least one
   validation SELECT (step 03) that operators must review before executing.

## Threat Model

| Threat | Mitigation |
|--------|-----------|
| Wrong tenant targeted | TENANT_CODE resolved at runtime; THROW if NULL |
| Accidental PROD execution | DB_NAME() DEV guard |
| Blind data entry | PREVIEW_FIRST default; preview grid step 02 |
| Invalid lookup values | Step 03 validation grid emits OK/MISSING per field |
| Duplicate entity creation | SPs enforce unique constraints; bridge echoes DUPLICATE status |
| Missing operator identity | CREATED_BY_USER_EMAIL lookup shown in step 01 preview |
