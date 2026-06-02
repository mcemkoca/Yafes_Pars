SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF OBJECT_ID(N'audit.AuditLog', N'U') IS NULL
    THROW 51001, 'Missing table: audit.AuditLog', 1;

IF OBJECT_ID(N'audit.EntityChangeSet', N'U') IS NULL
    THROW 51002, 'Missing table: audit.EntityChangeSet', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_AuditLog_action_type'
      AND parent_object_id = OBJECT_ID(N'audit.AuditLog')
)
    THROW 51003, 'Missing check constraint: CK_AuditLog_action_type', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_AuditLog_entity'
      AND object_id = OBJECT_ID(N'audit.AuditLog')
)
    THROW 51004, 'Missing index: IX_AuditLog_entity', 1;

IF OBJECT_ID(N'person.TR_Person_Audit', N'TR') IS NULL
    THROW 51005, 'Missing trigger: person.TR_Person_Audit', 1;

IF OBJECT_ID(N'institution.TR_Institution_Audit', N'TR') IS NULL
    THROW 51006, 'Missing trigger: institution.TR_Institution_Audit', 1;

IF OBJECT_ID(N'risk.TR_InsurableObject_Audit', N'TR') IS NULL
    THROW 51007, 'Missing trigger: risk.TR_InsurableObject_Audit', 1;

IF OBJECT_ID(N'policy.TR_Contract_Audit', N'TR') IS NULL
    THROW 51008, 'Missing trigger: policy.TR_Contract_Audit', 1;

IF OBJECT_ID(N'policy.TR_ContractVersion_Audit', N'TR') IS NULL
    THROW 51009, 'Missing trigger: policy.TR_ContractVersion_Audit', 1;

IF OBJECT_ID(N'claim.TR_Claim_Audit', N'TR') IS NULL
    THROW 51010, 'Missing trigger: claim.TR_Claim_Audit', 1;

PRINT 'Audit domain validation passed.';
GO
