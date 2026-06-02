# Database Setup With SSMS

Use SQL Server Management Studio to execute migration files in filename order.

## Initial Process

1. Open the target SQL Server instance in SSMS.
2. Run `database/migrations/000__create_database.sql`.
3. Switch to the created database if the script does not do so automatically.
4. Run each remaining migration in order.
5. Run validation scripts from `database/validation/`.

Do not run destructive rollback scripts against production databases without a
separate operational approval.

## Current Validation

After running `000__create_database.sql`, `001__create_schemas.sql`, and
`002__create_core_infrastructure.sql`, run:

- `database/validation/001__validate_core_infrastructure.sql`
