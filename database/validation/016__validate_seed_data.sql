SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF NOT EXISTS (SELECT 1 FROM ref.Language WHERE language_code = 'nl')
    THROW 51601, 'Missing seed: Language nl', 1;

IF NOT EXISTS (SELECT 1 FROM policy.ContractStatus WHERE contract_status_code = N'ACTIVE')
    THROW 51602, 'Missing seed: ContractStatus ACTIVE', 1;

IF NOT EXISTS (SELECT 1 FROM policy.ContractVersionStatus WHERE contract_version_status_code = N'ACTIVE')
    THROW 51603, 'Missing seed: ContractVersionStatus ACTIVE', 1;

IF NOT EXISTS (SELECT 1 FROM claim.ClaimStatus WHERE claim_status_code = N'OPEN')
    THROW 51604, 'Missing seed: ClaimStatus OPEN', 1;

IF NOT EXISTS (SELECT 1 FROM tasking.TaskStatus WHERE task_status_code = N'OPEN')
    THROW 51605, 'Missing seed: TaskStatus OPEN', 1;

IF NOT EXISTS (SELECT 1 FROM tasking.TaskPriority WHERE task_priority_code = N'NORMAL')
    THROW 51606, 'Missing seed: TaskPriority NORMAL', 1;

IF NOT EXISTS (SELECT 1 FROM document.DocumentType WHERE document_type_code = N'ID_CARD')
    THROW 51607, 'Missing seed: DocumentType ID_CARD', 1;

IF NOT EXISTS (SELECT 1 FROM core.Permission WHERE permission_code = N'admin.user.manage')
    THROW 51608, 'Missing seed: Permission admin.user.manage', 1;

IF NOT EXISTS (SELECT 1 FROM core.Role WHERE tenant_id IS NULL AND role_code = N'SYSTEM_ADMIN')
    THROW 51609, 'Missing seed: Role SYSTEM_ADMIN', 1;

IF NOT EXISTS (SELECT 1 FROM risk.InsurableObjectType WHERE object_type_code = N'VEHICLE')
    THROW 51610, 'Missing seed: InsurableObjectType VEHICLE', 1;

PRINT 'Seed validation passed.';
GO
