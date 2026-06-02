# Naming Conventions

## Schemas

Use lowercase domain schema names such as `person`, `policy`, and `claim`.

## Tables

Use PascalCase singular table names:

- `person.Person`
- `risk.InsurableObject`
- `policy.Contract`
- `policy.ContractVersion`

## Columns

Use snake_case column names:

- `tenant_id`
- `created_at_utc`
- `contract_number`

## Database Objects

- Primary keys: `PK_<Table>`
- Foreign keys: `FK_<FromTable>_<ToTable>_<Purpose>`
- Unique constraints: `UQ_<Table>_<ColumnOrBusinessKey>`
- Check constraints: `CK_<Table>_<Rule>`
- Indexes: `IX_<Table>_<ColumnList>`
- Defaults: `DF_<Table>_<Column>`
- Triggers: `TR_<Table>_<Action>`
- Views: `VW_<Domain>_<Name>`
- Stored procedures: `SP_<Domain>_<Action>`
