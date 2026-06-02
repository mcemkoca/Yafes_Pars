SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF OBJECT_ID(N'policy.Contract', N'U') IS NULL
    THROW 50501, 'Missing table: policy.Contract', 1;

IF OBJECT_ID(N'policy.ContractVersion', N'U') IS NULL
    THROW 50502, 'Missing table: policy.ContractVersion', 1;

IF OBJECT_ID(N'policy.ContractParty', N'U') IS NULL
    THROW 50503, 'Missing table: policy.ContractParty', 1;

IF OBJECT_ID(N'policy.ContractObject', N'U') IS NULL
    THROW 50504, 'Missing table: policy.ContractObject', 1;

IF OBJECT_ID(N'policy.ContractVersionObject', N'U') IS NULL
    THROW 50505, 'Missing table: policy.ContractVersionObject', 1;

IF OBJECT_ID(N'policy.ContractTakeover', N'U') IS NULL
    THROW 50506, 'Missing table: policy.ContractTakeover', 1;

IF COL_LENGTH(N'policy.Contract', N'tenant_id') IS NULL
    THROW 50507, 'Missing column: policy.Contract.tenant_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = N'UQ_Contract_tenant_number'
      AND parent_object_id = OBJECT_ID(N'policy.Contract')
)
    THROW 50508, 'Missing unique constraint: UQ_Contract_tenant_number', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = N'UQ_ContractVersion_contract_version_no'
      AND parent_object_id = OBJECT_ID(N'policy.ContractVersion')
)
    THROW 50509, 'Missing unique constraint: UQ_ContractVersion_contract_version_no', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Contract_Tenant'
      AND parent_object_id = OBJECT_ID(N'policy.Contract')
)
    THROW 50510, 'Missing FK: FK_Contract_Tenant', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_ContractVersion_Contract'
      AND parent_object_id = OBJECT_ID(N'policy.ContractVersion')
)
    THROW 50511, 'Missing FK: FK_ContractVersion_Contract', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_ContractParty_Person'
      AND parent_object_id = OBJECT_ID(N'policy.ContractParty')
)
    THROW 50512, 'Missing FK: FK_ContractParty_Person', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_ContractObject_InsurableObject'
      AND parent_object_id = OBJECT_ID(N'policy.ContractObject')
)
    THROW 50513, 'Missing FK: FK_ContractObject_InsurableObject', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = N'UQ_ContractType_code_domain'
      AND parent_object_id = OBJECT_ID(N'policy.ContractType')
)
    THROW 50514, 'Missing unique constraint: UQ_ContractType_code_domain', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Contract_status_dates'
      AND object_id = OBJECT_ID(N'policy.Contract')
)
    THROW 50515, 'Missing index: IX_Contract_status_dates', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_ContractVersion_contract_effective'
      AND object_id = OBJECT_ID(N'policy.ContractVersion')
)
    THROW 50516, 'Missing index: IX_ContractVersion_contract_effective', 1;

PRINT 'Policy domain validation passed.';
GO
