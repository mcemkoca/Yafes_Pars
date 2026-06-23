SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InsurableLoan_Periodicity'
      AND parent_object_id = OBJECT_ID(N'risk.InsurableLoan')
)
    THROW 51101, 'Missing FK: FK_InsurableLoan_Periodicity', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InsurableLoan_DurationType'
      AND parent_object_id = OBJECT_ID(N'risk.InsurableLoan')
)
    THROW 51102, 'Missing FK: FK_InsurableLoan_DurationType', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_InsurableObject_AppUser_CreatedBy'
      AND parent_object_id = OBJECT_ID(N'risk.InsurableObject')
)
    THROW 51103, 'Missing FK: FK_InsurableObject_AppUser_CreatedBy', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_ContractVersion_AppUser_CreatedBy'
      AND parent_object_id = OBJECT_ID(N'policy.ContractVersion')
)
    THROW 51104, 'Missing FK: FK_ContractVersion_AppUser_CreatedBy', 1;

IF EXISTS (
    SELECT required.table_name
    FROM (VALUES
        (N'person.Person'),
        (N'institution.Institution'),
        (N'risk.InsurableObject'),
        (N'policy.Contract'),
        (N'claim.Claim'),
        (N'document.Document'),
        (N'tasking.Task')
    ) AS required (table_name)
    WHERE COL_LENGTH(required.table_name, N'tenant_id') IS NULL
)
    THROW 51105, 'Business root table missing tenant_id.', 1;

IF EXISTS (
    SELECT 1
    FROM policy.ContractObject co
    INNER JOIN policy.Contract c
        ON c.contract_id = co.contract_id
    INNER JOIN risk.InsurableObject io
        ON io.insurable_object_id = co.insurable_object_id
    WHERE c.tenant_id <> io.tenant_id
)
    THROW 51106, 'Contract object tenant mismatch.', 1;

IF EXISTS (
    SELECT 1
    FROM claim.Claim cl
    INNER JOIN policy.Contract c
        ON c.contract_id = cl.contract_id
    WHERE cl.tenant_id <> c.tenant_id
)
    THROW 51107, 'Claim contract tenant mismatch.', 1;

PRINT 'Cross-domain constraint validation passed.';
GO
