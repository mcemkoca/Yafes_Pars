# Database Setup With SSMS

Use SQL Server Management Studio to execute migration files in filename order.
All scripts target Microsoft SQL Server T-SQL and use SSMS batch separators.

## Initial Process

1. Open the target SQL Server instance in SSMS.
2. Run the static quality gate from the repository.
3. Run the migration files in the order below.
4. Run the validation files in the order below.
5. Run optional demo data only in development or test environments.

Do not run destructive rollback scripts against production databases without a
separate operational approval.

For Azure Windows Server, SQL Server installation, backup/restore, and
production release procedures, use:

- `azure-windows-server-deployment.md`
- `sql-server-installation-checklist.md`
- `ssms-deployment-runbook.md`
- `backup-restore-strategy.md`
- `production-readiness-checklist.md`

## Migration Order

- `000__create_database.sql`
- `001__create_schemas.sql`
- `002__create_core_infrastructure.sql`
- `003__create_person_domain.sql`
- `004__create_institution_domain.sql`
- `005__create_object_domain.sql`
- `006__create_contract_domain.sql`
- `007__create_coverage_domain.sql`
- `008__create_claim_domain.sql`
- `009__create_document_domain.sql`
- `010__create_task_domain.sql`
- `011__create_audit_domain.sql`
- `012__add_constraints.sql`
- `013__add_indexes.sql`
- `014__add_triggers.sql`
- `015__add_views.sql`
- `016__add_stored_procedures.sql`
- `017__seed_lookup_data.sql`
- `018__seed_demo_data.sql` optional

## Validation Order

- `001__validate_core_infrastructure.sql`
- `002__validate_person_domain.sql`
- `003__validate_institution_domain.sql`
- `004__validate_risk_domain.sql`
- `005__validate_policy_domain.sql`
- `006__validate_coverage_domain.sql`
- `007__validate_claim_domain.sql`
- `008__validate_document_domain.sql`
- `009__validate_task_domain.sql`
- `010__validate_audit_domain.sql`
- `011__validate_constraints_exist.sql`
- `012__validate_indexes.sql`
- `013__validate_triggers.sql`
- `014__validate_views.sql`
- `015__validate_stored_procedures.sql`
- `016__validate_seed_data.sql`
- `017__validate_demo_data.sql` only after optional demo seed

## Rollback

Rollback scripts are guarded by confirmation variables and should not be used
against production databases. Prefer rebuilding disposable development databases
from migration order instead of object-level rollback.

## Renewal Task Procedure

After `016__add_stored_procedures.sql` is applied, preview renewal candidates in
SSMS before inserting tasks:

```sql
DECLARE @TenantId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000';

EXEC tasking.SP_CreateRenewalTasks
    @tenant_id = @TenantId,
    @days_ahead = 60,
    @assigned_to_user_id = NULL,
    @created_by_user_id = NULL,
    @dry_run = 1;
```

When the candidate set is correct, rerun with `@dry_run = 0`. The procedure is
tenant-aware and refuses assignee or creator users outside the tenant.
