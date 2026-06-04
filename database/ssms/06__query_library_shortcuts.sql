/*
    Yafes Pars SSMS Workbench - Query Library Shortcuts

    INFO TIP:
    This file is read-only. Change SEARCH_TEXT, TOP_ROWS, and TENANT_CODE at the
    top, then execute the section you need or run the whole file.

    Enable SQLCMD Mode before running.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"
:setvar SEARCH_TEXT ""
:setvar TOP_ROWS "100"

SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

IF DB_NAME() NOT LIKE N'%DEV%'
    THROW 52299, 'Current database name must contain DEV.', 1;

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @TenantId UNIQUEIDENTIFIER;
DECLARE @SearchText NVARCHAR(160) = NULLIF(N'$(SEARCH_TEXT)', N'');
DECLARE @TopRows INT = TRY_CONVERT(INT, N'$(TOP_ROWS)');

IF @TopRows IS NULL OR @TopRows < 1 OR @TopRows > 1000
    SET @TopRows = 100;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52200, 'Tenant code was not found.', 1;

PRINT 'INFO TIP: Search sections use SEARCH_TEXT when set; blank SEARCH_TEXT returns recent/top rows.';

PRINT '01 - Search customers';
EXEC person.SP_SearchPerson
    @tenant_id = @TenantId,
    @search_text = @SearchText;

PRINT '02 - Search institutions';
EXEC institution.SP_SearchInstitution
    @tenant_id = @TenantId,
    @search_text = @SearchText;

PRINT '03 - Search vehicles';
EXEC risk.SP_SearchVehicle
    @tenant_id = @TenantId,
    @search_text = @SearchText;

PRINT '04 - Recent policies';
SELECT TOP (@TopRows)
    contract_id,
    contract_number,
    contract_status_code,
    contract_domain_code,
    contract_type_code,
    start_date,
    end_date,
    company_name,
    latest_version_no,
    party_count,
    object_count,
    N'INFO TIP: Use contract_id in policy edit or claim creation templates.' AS info_tip
FROM policy.VW_PolicyDashboard
WHERE tenant_id = @TenantId
ORDER BY start_date DESC, contract_number DESC;

PRINT '05 - Claims needing attention';
SELECT TOP (@TopRows)
    claim_id,
    claim_number,
    contract_number,
    coverage_code,
    claim_status_code,
    incident_date,
    reported_date,
    paid_amount,
    reserved_amount,
    N'INFO TIP: Use claim_id in claim close/edit guardrail templates.' AS info_tip
FROM claim.VW_ClaimDashboard
WHERE tenant_id = @TenantId
  AND claim_status_code NOT IN (N'CLOSED', N'CANCELLED')
ORDER BY reported_date DESC, claim_number DESC;

PRINT '06 - Open tasks by due date';
SELECT TOP (@TopRows)
    task_id,
    title,
    related_entity_type,
    related_entity_id,
    assigned_to_name,
    task_priority_code,
    task_status_code,
    due_at_utc,
    N'INFO TIP: Confirm related_entity_type before editing a task.' AS info_tip
FROM tasking.VW_OpenTaskDashboard
WHERE tenant_id = @TenantId
ORDER BY due_at_utc, task_priority_code, created_at_utc DESC;

PRINT '07 - Lookup helper';
SELECT
    lookup_area,
    lookup_code,
    label,
    info_tip
FROM (
    SELECT N'policy.ContractStatus' AS lookup_area, contract_status_code AS lookup_code, label_nl AS label, N'Use for policy status templates.' AS info_tip
    FROM policy.ContractStatus
    WHERE is_active = 1
    UNION ALL
    SELECT N'policy.ContractDomain', contract_domain_code, label_nl, N'Use for policy domain selection.'
    FROM policy.ContractDomain
    WHERE is_active = 1
    UNION ALL
    SELECT N'tasking.TaskPriority', task_priority_code, label_nl, N'Use for task priority selection.'
    FROM tasking.TaskPriority
    WHERE is_active = 1
    UNION ALL
    SELECT N'tasking.TaskStatus', task_status_code, label_nl, N'Use for task status selection.'
    FROM tasking.TaskStatus
    WHERE is_active = 1
    UNION ALL
    SELECT N'claim.ClaimStatus', claim_status_code, label_nl, N'Use for claim workflow status.'
    FROM claim.ClaimStatus
    WHERE is_active = 1
) AS lookup_data
ORDER BY lookup_area, lookup_code;
GO
