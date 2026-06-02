SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF OBJECT_ID(N'person.VW_CustomerSummary', N'V') IS NULL
    THROW 51401, 'Missing view: person.VW_CustomerSummary', 1;

IF OBJECT_ID(N'institution.VW_InstitutionSummary', N'V') IS NULL
    THROW 51402, 'Missing view: institution.VW_InstitutionSummary', 1;

IF OBJECT_ID(N'risk.VW_InsurableObjectSummary', N'V') IS NULL
    THROW 51403, 'Missing view: risk.VW_InsurableObjectSummary', 1;

IF OBJECT_ID(N'policy.VW_ActivePolicy', N'V') IS NULL
    THROW 51404, 'Missing view: policy.VW_ActivePolicy', 1;

IF OBJECT_ID(N'policy.VW_PolicyDashboard', N'V') IS NULL
    THROW 51405, 'Missing view: policy.VW_PolicyDashboard', 1;

IF OBJECT_ID(N'claim.VW_ClaimDashboard', N'V') IS NULL
    THROW 51406, 'Missing view: claim.VW_ClaimDashboard', 1;

IF OBJECT_ID(N'tasking.VW_OpenTaskDashboard', N'V') IS NULL
    THROW 51407, 'Missing view: tasking.VW_OpenTaskDashboard', 1;

PRINT 'View validation passed.';
GO
