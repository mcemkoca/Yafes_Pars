SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF OBJECT_ID(N'person.SP_CreateNaturalPerson', N'P') IS NULL
    THROW 51501, 'Missing procedure: person.SP_CreateNaturalPerson', 1;

IF OBJECT_ID(N'person.SP_SearchPerson', N'P') IS NULL
    THROW 51502, 'Missing procedure: person.SP_SearchPerson', 1;

IF OBJECT_ID(N'institution.SP_SearchInstitution', N'P') IS NULL
    THROW 51503, 'Missing procedure: institution.SP_SearchInstitution', 1;

IF OBJECT_ID(N'risk.SP_SearchVehicle', N'P') IS NULL
    THROW 51504, 'Missing procedure: risk.SP_SearchVehicle', 1;

IF OBJECT_ID(N'policy.SP_CreateContract', N'P') IS NULL
    THROW 51505, 'Missing procedure: policy.SP_CreateContract', 1;

IF OBJECT_ID(N'policy.SP_CreateContractVersion', N'P') IS NULL
    THROW 51506, 'Missing procedure: policy.SP_CreateContractVersion', 1;

IF OBJECT_ID(N'policy.SP_AddContractParty', N'P') IS NULL
    THROW 51507, 'Missing procedure: policy.SP_AddContractParty', 1;

IF OBJECT_ID(N'policy.SP_AddContractObject', N'P') IS NULL
    THROW 51508, 'Missing procedure: policy.SP_AddContractObject', 1;

IF OBJECT_ID(N'claim.SP_CreateClaim', N'P') IS NULL
    THROW 51509, 'Missing procedure: claim.SP_CreateClaim', 1;

IF OBJECT_ID(N'claim.SP_CloseClaim', N'P') IS NULL
    THROW 51510, 'Missing procedure: claim.SP_CloseClaim', 1;

IF OBJECT_ID(N'audit.SP_GetEntityAuditTrail', N'P') IS NULL
    THROW 51511, 'Missing procedure: audit.SP_GetEntityAuditTrail', 1;

IF OBJECT_ID(N'tasking.SP_CreateRenewalTasks', N'P') IS NULL
    THROW 51512, 'Missing procedure: tasking.SP_CreateRenewalTasks', 1;

IF OBJECT_DEFINITION(OBJECT_ID(N'policy.SP_AddContractParty')) NOT LIKE N'%Person not found for tenant%'
    THROW 51516, 'Missing tenant guard: policy.SP_AddContractParty person check', 1;

IF OBJECT_DEFINITION(OBJECT_ID(N'policy.SP_AddContractObject')) NOT LIKE N'%Insurable object not found for tenant%'
    THROW 51517, 'Missing tenant guard: policy.SP_AddContractObject object check', 1;

IF OBJECT_DEFINITION(OBJECT_ID(N'claim.SP_CreateClaim')) NOT LIKE N'%claims_handler_id does not belong to the tenant%'
    THROW 51518, 'Missing tenant guard: claim.SP_CreateClaim handler check', 1;

IF OBJECT_DEFINITION(OBJECT_ID(N'claim.SP_CloseClaim')) NOT LIKE N'%updated_by_user_id does not belong to the tenant%'
    THROW 51519, 'Missing tenant guard: claim.SP_CloseClaim updater check', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.parameters
    WHERE object_id = OBJECT_ID(N'tasking.SP_CreateRenewalTasks')
      AND name = N'@tenant_id'
)
    THROW 51513, 'Missing parameter: tasking.SP_CreateRenewalTasks.@tenant_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.parameters
    WHERE object_id = OBJECT_ID(N'tasking.SP_CreateRenewalTasks')
      AND name = N'@days_ahead'
)
    THROW 51514, 'Missing parameter: tasking.SP_CreateRenewalTasks.@days_ahead', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.parameters
    WHERE object_id = OBJECT_ID(N'tasking.SP_CreateRenewalTasks')
      AND name = N'@dry_run'
)
    THROW 51515, 'Missing parameter: tasking.SP_CreateRenewalTasks.@dry_run', 1;

PRINT 'Stored procedure validation passed.';
GO
