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

PRINT 'Cross-domain constraint validation passed.';
GO
