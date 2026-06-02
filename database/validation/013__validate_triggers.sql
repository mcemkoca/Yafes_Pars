SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF OBJECT_ID(N'person.TR_Person_Audit', N'TR') IS NULL
    THROW 51301, 'Missing trigger: person.TR_Person_Audit', 1;

IF OBJECT_ID(N'institution.TR_Institution_Audit', N'TR') IS NULL
    THROW 51302, 'Missing trigger: institution.TR_Institution_Audit', 1;

IF OBJECT_ID(N'risk.TR_InsurableObject_Audit', N'TR') IS NULL
    THROW 51303, 'Missing trigger: risk.TR_InsurableObject_Audit', 1;

IF OBJECT_ID(N'policy.TR_Contract_Audit', N'TR') IS NULL
    THROW 51304, 'Missing trigger: policy.TR_Contract_Audit', 1;

IF OBJECT_ID(N'policy.TR_ContractVersion_Audit', N'TR') IS NULL
    THROW 51305, 'Missing trigger: policy.TR_ContractVersion_Audit', 1;

IF OBJECT_ID(N'claim.TR_Claim_Audit', N'TR') IS NULL
    THROW 51306, 'Missing trigger: claim.TR_Claim_Audit', 1;

PRINT 'Trigger validation passed.';
GO
