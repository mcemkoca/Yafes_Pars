[CmdletBinding()]
param(
    [switch]$PatchProgram,
    [switch]$ApplyMigration,
    [switch]$Force,
    [string]$DatabaseName = $env:YAFES_SQL_DATABASE,
    [string]$SqlServer = $env:YAFES_SQL_SERVER,
    [string]$SqlUser = $env:YAFES_SQL_USER,
    [string]$SqlPassword = $env:YAFES_SQL_PASSWORD
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-RepoRoot {
    $current = (Get-Location).Path
    while ($true) {
        if ((Test-Path (Join-Path $current 'README.md')) -and
            (Test-Path (Join-Path $current 'database')) -and
            (Test-Path (Join-Path $current 'backend'))) {
            return $current
        }

        $parent = Split-Path -Parent $current
        if ([string]::IsNullOrWhiteSpace($parent) -or $parent -eq $current) {
            throw 'Yafes_Pars repo root bulunamadı. Scripti repo klasörü içinde çalıştır.'
        }

        $current = $parent
    }
}

function Write-ProjectFile {
    param(
        [Parameter(Mandatory=$true)][string]$RelativePath,
        [Parameter(Mandatory=$true)][string]$Content
    )

    $fullPath = Join-Path $repoRoot $RelativePath
    $parent = Split-Path -Parent $fullPath
    New-Item -ItemType Directory -Force -Path $parent | Out-Null

    if ((Test-Path $fullPath) -and -not $Force) {
        Write-Host "SKIP  $RelativePath already exists. Use -Force to overwrite." -ForegroundColor Yellow
        return
    }

    Set-Content -Path $fullPath -Value $Content -Encoding UTF8
    Write-Host "WRITE $RelativePath" -ForegroundColor Green
}

$repoRoot = Resolve-RepoRoot
Write-Host "Yafes Pars repo root: $repoRoot" -ForegroundColor Cyan

# =============================================================================
# 021 Migration — Yafes Assurance Engine
# =============================================================================
$migration021 = @'
-- =============================================================================
-- Migration 021 — Yafes Assurance Engine
-- Adds: assurance schema
--       SQL review requests, risk findings, approval workflow, rollback plans
--       sensitive column discovery, masking policies, compliance controls/scans
--       permission drift findings, assurance reports
--       dashboard and scanner stored procedures
-- =============================================================================
:setvar YAFES_SQL_DATABASE "YafesPars"
USE [$(YAFES_SQL_DATABASE)];
GO

PRINT 'Running migration: 021__create_assurance_domain.sql';
GO

IF SCHEMA_ID(N'assurance') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA assurance');
    PRINT 'Schema assurance created.';
END
GO

-- ─── SQL review request ──────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'assurance') AND name = N'SqlReviewRequest')
BEGIN
    CREATE TABLE assurance.SqlReviewRequest (
        sql_review_request_id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
            CONSTRAINT PK_SqlReviewRequest PRIMARY KEY,
        tenant_id              UNIQUEIDENTIFIER NOT NULL,
        environment_code       NVARCHAR(24) NOT NULL
            CONSTRAINT CK_SqlReviewRequest_Environment CHECK (environment_code IN (N'DEV', N'TEST', N'UAT', N'PROD')),
        target_database        SYSNAME NOT NULL,
        script_name            NVARCHAR(260) NULL,
        submitted_sql          NVARCHAR(MAX) NOT NULL,
        rollback_sql           NVARCHAR(MAX) NULL,
        risk_score             INT NOT NULL DEFAULT 0
            CONSTRAINT CK_SqlReviewRequest_RiskScore CHECK (risk_score BETWEEN 0 AND 100),
        risk_level             NVARCHAR(16) NOT NULL DEFAULT N'LOW'
            CONSTRAINT CK_SqlReviewRequest_RiskLevel CHECK (risk_level IN (N'LOW', N'MEDIUM', N'HIGH', N'CRITICAL')),
        status_code            NVARCHAR(32) NOT NULL DEFAULT N'DRAFT'
            CONSTRAINT CK_SqlReviewRequest_Status CHECK (status_code IN (
                N'DRAFT', N'PENDING_APPROVAL', N'APPROVED', N'REJECTED',
                N'BLOCKED', N'EXECUTED', N'CANCELLED'
            )),
        submitted_by_user_id   UNIQUEIDENTIFIER NULL,
        approved_by_user_id    UNIQUEIDENTIFIER NULL,
        requested_execution_at_utc DATETIME2(2) NULL,
        created_at_utc         DATETIME2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
        approved_at_utc        DATETIME2(2) NULL,
        executed_at_utc        DATETIME2(2) NULL,
        correlation_id         UNIQUEIDENTIFIER NULL
    );

    CREATE INDEX IX_SqlReviewRequest_Tenant_Status
        ON assurance.SqlReviewRequest (tenant_id, status_code, created_at_utc DESC);

    CREATE INDEX IX_SqlReviewRequest_Risk
        ON assurance.SqlReviewRequest (tenant_id, risk_level, risk_score DESC);

    PRINT 'assurance.SqlReviewRequest created.';
END
GO

-- ─── SQL risk finding ────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'assurance') AND name = N'SqlRiskFinding')
BEGIN
    CREATE TABLE assurance.SqlRiskFinding (
        sql_risk_finding_id    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
            CONSTRAINT PK_SqlRiskFinding PRIMARY KEY,
        sql_review_request_id  UNIQUEIDENTIFIER NOT NULL,
        tenant_id              UNIQUEIDENTIFIER NOT NULL,
        rule_code              NVARCHAR(80) NOT NULL,
        severity_code          NVARCHAR(16) NOT NULL
            CONSTRAINT CK_SqlRiskFinding_Severity CHECK (severity_code IN (N'LOW', N'MEDIUM', N'HIGH', N'CRITICAL')),
        category_code          NVARCHAR(80) NOT NULL,
        finding_message        NVARCHAR(800) NOT NULL,
        evidence               NVARCHAR(1200) NULL,
        line_number            INT NULL,
        created_at_utc         DATETIME2(2) NOT NULL DEFAULT SYSUTCDATETIME()
    );

    CREATE INDEX IX_SqlRiskFinding_Request
        ON assurance.SqlRiskFinding (sql_review_request_id, severity_code);

    CREATE INDEX IX_SqlRiskFinding_Tenant
        ON assurance.SqlRiskFinding (tenant_id, severity_code, created_at_utc DESC);

    PRINT 'assurance.SqlRiskFinding created.';
END
GO

-- ─── Approval workflow ───────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'assurance') AND name = N'ApprovalWorkflow')
BEGIN
    CREATE TABLE assurance.ApprovalWorkflow (
        approval_workflow_id   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
            CONSTRAINT PK_ApprovalWorkflow PRIMARY KEY,
        sql_review_request_id  UNIQUEIDENTIFIER NOT NULL,
        tenant_id              UNIQUEIDENTIFIER NOT NULL,
        approval_stage         INT NOT NULL DEFAULT 1,
        approver_role_code     NVARCHAR(80) NOT NULL DEFAULT N'admin',
        decision_code          NVARCHAR(24) NOT NULL DEFAULT N'PENDING'
            CONSTRAINT CK_ApprovalWorkflow_Decision CHECK (decision_code IN (N'PENDING', N'APPROVED', N'REJECTED', N'ESCALATED')),
        decision_comment       NVARCHAR(1000) NULL,
        decided_by_user_id     UNIQUEIDENTIFIER NULL,
        decided_at_utc         DATETIME2(2) NULL,
        created_at_utc         DATETIME2(2) NOT NULL DEFAULT SYSUTCDATETIME()
    );

    CREATE INDEX IX_ApprovalWorkflow_Request
        ON assurance.ApprovalWorkflow (sql_review_request_id, decision_code);

    PRINT 'assurance.ApprovalWorkflow created.';
END
GO

-- ─── Rollback plan ───────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'assurance') AND name = N'RollbackPlan')
BEGIN
    CREATE TABLE assurance.RollbackPlan (
        rollback_plan_id       UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
            CONSTRAINT PK_RollbackPlan PRIMARY KEY,
        sql_review_request_id  UNIQUEIDENTIFIER NOT NULL,
        tenant_id              UNIQUEIDENTIFIER NOT NULL,
        rollback_sql           NVARCHAR(MAX) NOT NULL,
        validation_status_code NVARCHAR(24) NOT NULL DEFAULT N'NOT_VALIDATED'
            CONSTRAINT CK_RollbackPlan_Status CHECK (validation_status_code IN (N'NOT_VALIDATED', N'VALID', N'INVALID', N'NOT_REQUIRED')),
        validation_message     NVARCHAR(1200) NULL,
        created_at_utc         DATETIME2(2) NOT NULL DEFAULT SYSUTCDATETIME()
    );

    CREATE INDEX IX_RollbackPlan_Request
        ON assurance.RollbackPlan (sql_review_request_id);

    PRINT 'assurance.RollbackPlan created.';
END
GO

-- ─── Sensitive column finding ────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'assurance') AND name = N'SensitiveColumnFinding')
BEGIN
    CREATE TABLE assurance.SensitiveColumnFinding (
        sensitive_column_finding_id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
            CONSTRAINT PK_SensitiveColumnFinding PRIMARY KEY,
        tenant_id              UNIQUEIDENTIFIER NOT NULL,
        schema_name            SYSNAME NOT NULL,
        table_name             SYSNAME NOT NULL,
        column_name            SYSNAME NOT NULL,
        detected_pattern       NVARCHAR(120) NOT NULL,
        data_category_code     NVARCHAR(80) NOT NULL,
        confidence_score       DECIMAL(5,2) NOT NULL DEFAULT 80.00,
        masking_recommended    BIT NOT NULL DEFAULT 1,
        is_acknowledged        BIT NOT NULL DEFAULT 0,
        created_at_utc         DATETIME2(2) NOT NULL DEFAULT SYSUTCDATETIME()
    );

    CREATE UNIQUE INDEX UX_SensitiveColumnFinding_Column
        ON assurance.SensitiveColumnFinding (tenant_id, schema_name, table_name, column_name, detected_pattern);

    PRINT 'assurance.SensitiveColumnFinding created.';
END
GO

-- ─── Masking policy ──────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'assurance') AND name = N'MaskingPolicy')
BEGIN
    CREATE TABLE assurance.MaskingPolicy (
        masking_policy_id      UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
            CONSTRAINT PK_MaskingPolicy PRIMARY KEY,
        tenant_id              UNIQUEIDENTIFIER NOT NULL,
        schema_name            SYSNAME NOT NULL,
        table_name             SYSNAME NOT NULL,
        column_name            SYSNAME NOT NULL,
        masking_strategy_code  NVARCHAR(80) NOT NULL
            CONSTRAINT CK_MaskingPolicy_Strategy CHECK (masking_strategy_code IN (
                N'EMAIL_PARTIAL', N'PHONE_PARTIAL', N'IBAN_PARTIAL', N'HASH',
                N'NULLIFY', N'REDACT', N'CUSTOM'
            )),
        is_active              BIT NOT NULL DEFAULT 1,
        created_by_user_id     UNIQUEIDENTIFIER NULL,
        created_at_utc         DATETIME2(2) NOT NULL DEFAULT SYSUTCDATETIME()
    );

    CREATE UNIQUE INDEX UX_MaskingPolicy_Column
        ON assurance.MaskingPolicy (tenant_id, schema_name, table_name, column_name)
        WHERE is_active = 1;

    PRINT 'assurance.MaskingPolicy created.';
END
GO

-- ─── Compliance controls ─────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'assurance') AND name = N'ComplianceControl')
BEGIN
    CREATE TABLE assurance.ComplianceControl (
        compliance_control_id  UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
            CONSTRAINT PK_ComplianceControl PRIMARY KEY,
        framework_code         NVARCHAR(40) NOT NULL,
        control_code           NVARCHAR(80) NOT NULL,
        control_title          NVARCHAR(260) NOT NULL,
        control_description    NVARCHAR(1200) NULL,
        severity_code          NVARCHAR(16) NOT NULL
            CONSTRAINT CK_ComplianceControl_Severity CHECK (severity_code IN (N'LOW', N'MEDIUM', N'HIGH', N'CRITICAL')),
        is_active              BIT NOT NULL DEFAULT 1,
        created_at_utc         DATETIME2(2) NOT NULL DEFAULT SYSUTCDATETIME()
    );

    CREATE UNIQUE INDEX UX_ComplianceControl_Code
        ON assurance.ComplianceControl (framework_code, control_code);

    PRINT 'assurance.ComplianceControl created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'assurance') AND name = N'ComplianceScanRun')
BEGIN
    CREATE TABLE assurance.ComplianceScanRun (
        compliance_scan_run_id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
            CONSTRAINT PK_ComplianceScanRun PRIMARY KEY,
        tenant_id              UNIQUEIDENTIFIER NOT NULL,
        scan_scope_code        NVARCHAR(80) NOT NULL DEFAULT N'SQL_SERVER',
        status_code            NVARCHAR(24) NOT NULL DEFAULT N'RUNNING'
            CONSTRAINT CK_ComplianceScanRun_Status CHECK (status_code IN (N'RUNNING', N'COMPLETED', N'FAILED')),
        started_at_utc         DATETIME2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
        completed_at_utc       DATETIME2(2) NULL,
        summary_json           NVARCHAR(MAX) NULL
    );

    CREATE INDEX IX_ComplianceScanRun_Tenant
        ON assurance.ComplianceScanRun (tenant_id, started_at_utc DESC);

    PRINT 'assurance.ComplianceScanRun created.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'assurance') AND name = N'ComplianceFinding')
BEGIN
    CREATE TABLE assurance.ComplianceFinding (
        compliance_finding_id  UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
            CONSTRAINT PK_ComplianceFinding PRIMARY KEY,
        compliance_scan_run_id UNIQUEIDENTIFIER NOT NULL,
        tenant_id              UNIQUEIDENTIFIER NOT NULL,
        framework_code         NVARCHAR(40) NOT NULL,
        control_code           NVARCHAR(80) NOT NULL,
        finding_status_code    NVARCHAR(24) NOT NULL
            CONSTRAINT CK_ComplianceFinding_Status CHECK (finding_status_code IN (N'PASS', N'WARN', N'FAIL', N'INFO')),
        severity_code          NVARCHAR(16) NOT NULL
            CONSTRAINT CK_ComplianceFinding_Severity CHECK (severity_code IN (N'LOW', N'MEDIUM', N'HIGH', N'CRITICAL')),
        finding_title          NVARCHAR(260) NOT NULL,
        finding_detail         NVARCHAR(1600) NULL,
        evidence_sql           NVARCHAR(MAX) NULL,
        remediation_hint       NVARCHAR(1600) NULL,
        created_at_utc         DATETIME2(2) NOT NULL DEFAULT SYSUTCDATETIME()
    );

    CREATE INDEX IX_ComplianceFinding_Run
        ON assurance.ComplianceFinding (compliance_scan_run_id, finding_status_code, severity_code);

    PRINT 'assurance.ComplianceFinding created.';
END
GO

-- ─── Permission drift ────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'assurance') AND name = N'PermissionDriftFinding')
BEGIN
    CREATE TABLE assurance.PermissionDriftFinding (
        permission_drift_finding_id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
            CONSTRAINT PK_PermissionDriftFinding PRIMARY KEY,
        tenant_id              UNIQUEIDENTIFIER NOT NULL,
        finding_type_code      NVARCHAR(80) NOT NULL,
        severity_code          NVARCHAR(16) NOT NULL
            CONSTRAINT CK_PermissionDriftFinding_Severity CHECK (severity_code IN (N'LOW', N'MEDIUM', N'HIGH', N'CRITICAL')),
        principal_name         NVARCHAR(260) NULL,
        role_code              NVARCHAR(120) NULL,
        finding_detail         NVARCHAR(1600) NOT NULL,
        remediation_hint       NVARCHAR(1600) NULL,
        is_resolved            BIT NOT NULL DEFAULT 0,
        created_at_utc         DATETIME2(2) NOT NULL DEFAULT SYSUTCDATETIME(),
        resolved_at_utc        DATETIME2(2) NULL
    );

    CREATE INDEX IX_PermissionDriftFinding_Tenant
        ON assurance.PermissionDriftFinding (tenant_id, is_resolved, severity_code, created_at_utc DESC);

    PRINT 'assurance.PermissionDriftFinding created.';
END
GO

-- ─── Assurance report ────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE schema_id = SCHEMA_ID(N'assurance') AND name = N'AssuranceReport')
BEGIN
    CREATE TABLE assurance.AssuranceReport (
        assurance_report_id    UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID()
            CONSTRAINT PK_AssuranceReport PRIMARY KEY,
        tenant_id              UNIQUEIDENTIFIER NOT NULL,
        report_type_code       NVARCHAR(80) NOT NULL,
        report_title           NVARCHAR(260) NOT NULL,
        report_json            NVARCHAR(MAX) NULL,
        report_html            NVARCHAR(MAX) NULL,
        generated_by_user_id   UNIQUEIDENTIFIER NULL,
        generated_at_utc       DATETIME2(2) NOT NULL DEFAULT SYSUTCDATETIME()
    );

    CREATE INDEX IX_AssuranceReport_Tenant
        ON assurance.AssuranceReport (tenant_id, generated_at_utc DESC);

    PRINT 'assurance.AssuranceReport created.';
END
GO

-- ─── Seed controls ───────────────────────────────────────────────────────────
MERGE assurance.ComplianceControl AS target
USING (VALUES
    (N'GDPR', N'GDPR-ART32-AUDIT', N'Auditability of processing', N'Processing activities must be traceable through audit trail.', N'HIGH'),
    (N'GDPR', N'GDPR-ART32-ACCESS', N'Least privilege access', N'Access to personal data must be restricted to authorized users.', N'HIGH'),
    (N'GDPR', N'GDPR-ART32-ENCRYPTION', N'Encryption at rest', N'Database encryption should be enabled where available.', N'HIGH'),
    (N'CIS',  N'CIS-MSSQL-AUDIT', N'SQL Server audit controls', N'Audit capability should be enabled and monitored.', N'HIGH'),
    (N'CIS',  N'CIS-MSSQL-SA', N'Default privileged account hardening', N'Default high-privilege accounts should not be left exposed.', N'CRITICAL'),
    (N'ISO27001', N'ISO-A.8.2', N'Privileged access rights', N'Privileged access must be controlled and reviewed.', N'HIGH'),
    (N'ISO27001', N'ISO-A.8.12', N'Data leakage prevention', N'Sensitive columns should be identified and protected.', N'HIGH')
) AS source(framework_code, control_code, control_title, control_description, severity_code)
ON target.framework_code = source.framework_code AND target.control_code = source.control_code
WHEN NOT MATCHED THEN
    INSERT (framework_code, control_code, control_title, control_description, severity_code)
    VALUES (source.framework_code, source.control_code, source.control_title, source.control_description, source.severity_code);
GO

-- ─── SP: Create SQL review request + lightweight static risk analysis ────────
CREATE OR ALTER PROCEDURE assurance.SP_CreateSqlReviewRequest
    @tenant_id              UNIQUEIDENTIFIER,
    @environment_code       NVARCHAR(24),
    @target_database        SYSNAME,
    @script_name            NVARCHAR(260) = NULL,
    @submitted_sql          NVARCHAR(MAX),
    @rollback_sql           NVARCHAR(MAX) = NULL,
    @submitted_by_user_id   UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @tenant_id IS NULL
        THROW 52100, 'tenant_id is required.', 1;

    IF @submitted_sql IS NULL OR LEN(TRIM(@submitted_sql)) = 0
        THROW 52101, 'submitted_sql is required.', 1;

    SET @environment_code = UPPER(ISNULL(NULLIF(TRIM(@environment_code), N''), N'DEV'));
    SET @target_database = ISNULL(NULLIF(TRIM(@target_database), N''), DB_NAME());

    DECLARE @sql_upper NVARCHAR(MAX) = UPPER(@submitted_sql);
    DECLARE @risk_score INT = 0;
    DECLARE @risk_level NVARCHAR(16) = N'LOW';
    DECLARE @status_code NVARCHAR(32) = N'DRAFT';
    DECLARE @request_id UNIQUEIDENTIFIER = NEWID();

    DECLARE @Findings TABLE (
        rule_code NVARCHAR(80),
        severity_code NVARCHAR(16),
        category_code NVARCHAR(80),
        finding_message NVARCHAR(800),
        evidence NVARCHAR(1200)
    );

    IF @sql_upper LIKE N'%DROP TABLE%' OR @sql_upper LIKE N'%DROP DATABASE%' OR @sql_upper LIKE N'%DROP SCHEMA%'
    BEGIN
        INSERT INTO @Findings VALUES
        (N'SQL_DESTRUCTIVE_DROP', N'CRITICAL', N'DESTRUCTIVE_OPERATION', N'DROP operation detected. Production execution must be blocked or formally approved.', N'DROP keyword present.');
        SET @risk_score += 40;
    END

    IF @sql_upper LIKE N'%TRUNCATE TABLE%'
    BEGIN
        INSERT INTO @Findings VALUES
        (N'SQL_DESTRUCTIVE_TRUNCATE', N'CRITICAL', N'DESTRUCTIVE_OPERATION', N'TRUNCATE TABLE detected. This is irreversible without backup/restore.', N'TRUNCATE TABLE keyword present.');
        SET @risk_score += 35;
    END

    IF (@sql_upper LIKE N'%DELETE FROM%' AND @sql_upper NOT LIKE N'% WHERE %')
    BEGIN
        INSERT INTO @Findings VALUES
        (N'SQL_DELETE_WITHOUT_WHERE', N'CRITICAL', N'DATA_LOSS', N'DELETE without WHERE detected.', N'DELETE FROM without WHERE.');
        SET @risk_score += 35;
    END

    IF (@sql_upper LIKE N'%UPDATE %' AND @sql_upper NOT LIKE N'% WHERE %')
    BEGIN
        INSERT INTO @Findings VALUES
        (N'SQL_UPDATE_WITHOUT_WHERE', N'HIGH', N'DATA_CORRUPTION', N'UPDATE without WHERE detected.', N'UPDATE without WHERE.');
        SET @risk_score += 25;
    END

    IF @sql_upper LIKE N'%ALTER TABLE%' OR @sql_upper LIKE N'%ALTER PROCEDURE%' OR @sql_upper LIKE N'%CREATE OR ALTER%'
    BEGIN
        INSERT INTO @Findings VALUES
        (N'SQL_SCHEMA_CHANGE', N'MEDIUM', N'SCHEMA_CHANGE', N'Schema or programmable object change detected.', N'ALTER/CREATE OR ALTER keyword present.');
        SET @risk_score += 15;
    END

    IF @sql_upper LIKE N'%DISABLE TRIGGER%' OR @sql_upper LIKE N'%DISABLE%TRIGGER%'
    BEGIN
        INSERT INTO @Findings VALUES
        (N'SQL_DISABLE_TRIGGER', N'HIGH', N'AUDIT_BYPASS', N'Trigger disablement detected. Audit integrity can be affected.', N'DISABLE TRIGGER keyword present.');
        SET @risk_score += 30;
    END

    IF @environment_code = N'PROD'
    BEGIN
        SET @risk_score += 20;

        IF @rollback_sql IS NULL OR LEN(TRIM(@rollback_sql)) = 0
        BEGIN
            INSERT INTO @Findings VALUES
            (N'PROD_ROLLBACK_REQUIRED', N'HIGH', N'CHANGE_GOVERNANCE', N'Production change requires a rollback plan.', N'rollback_sql is empty.');
            SET @risk_score += 25;
        END
    END

    IF @risk_score > 100 SET @risk_score = 100;

    SET @risk_level =
        CASE
            WHEN @risk_score >= 80 THEN N'CRITICAL'
            WHEN @risk_score >= 50 THEN N'HIGH'
            WHEN @risk_score >= 20 THEN N'MEDIUM'
            ELSE N'LOW'
        END;

    SET @status_code =
        CASE
            WHEN @risk_level = N'CRITICAL' THEN N'BLOCKED'
            WHEN @environment_code = N'PROD' OR @risk_level IN (N'HIGH', N'MEDIUM') THEN N'PENDING_APPROVAL'
            ELSE N'DRAFT'
        END;

    BEGIN TRANSACTION;

    INSERT INTO assurance.SqlReviewRequest (
        sql_review_request_id, tenant_id, environment_code, target_database,
        script_name, submitted_sql, rollback_sql, risk_score, risk_level,
        status_code, submitted_by_user_id, correlation_id
    )
    VALUES (
        @request_id, @tenant_id, @environment_code, @target_database,
        @script_name, @submitted_sql, @rollback_sql, @risk_score, @risk_level,
        @status_code, @submitted_by_user_id, NEWID()
    );

    INSERT INTO assurance.SqlRiskFinding (
        sql_review_request_id, tenant_id, rule_code, severity_code,
        category_code, finding_message, evidence
    )
    SELECT @request_id, @tenant_id, rule_code, severity_code, category_code, finding_message, evidence
    FROM @Findings;

    IF @rollback_sql IS NOT NULL AND LEN(TRIM(@rollback_sql)) > 0
    BEGIN
        INSERT INTO assurance.RollbackPlan (
            sql_review_request_id, tenant_id, rollback_sql,
            validation_status_code, validation_message
        )
        VALUES (
            @request_id, @tenant_id, @rollback_sql,
            N'NOT_VALIDATED', N'Rollback SQL captured. Manual validation required before execution.'
        );
    END

    IF @status_code = N'PENDING_APPROVAL'
    BEGIN
        INSERT INTO assurance.ApprovalWorkflow (
            sql_review_request_id, tenant_id, approval_stage, approver_role_code, decision_code
        )
        VALUES (@request_id, @tenant_id, 1, N'admin', N'PENDING');
    END

    COMMIT TRANSACTION;

    SELECT
        sql_review_request_id,
        tenant_id,
        environment_code,
        target_database,
        script_name,
        risk_score,
        risk_level,
        status_code,
        created_at_utc
    FROM assurance.SqlReviewRequest
    WHERE sql_review_request_id = @request_id;
END;
GO

-- ─── SP: Dashboard ───────────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE assurance.SP_GetAssuranceDashboard
    @tenant_id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT N'open_reviews' AS metric_code, COUNT_BIG(*) AS metric_value
    FROM assurance.SqlReviewRequest
    WHERE tenant_id = @tenant_id AND status_code IN (N'DRAFT', N'PENDING_APPROVAL', N'BLOCKED')
    UNION ALL
    SELECT N'critical_findings', COUNT_BIG(*)
    FROM assurance.SqlRiskFinding
    WHERE tenant_id = @tenant_id AND severity_code = N'CRITICAL'
    UNION ALL
    SELECT N'sensitive_columns', COUNT_BIG(*)
    FROM assurance.SensitiveColumnFinding
    WHERE tenant_id = @tenant_id AND is_acknowledged = 0
    UNION ALL
    SELECT N'open_permission_drift', COUNT_BIG(*)
    FROM assurance.PermissionDriftFinding
    WHERE tenant_id = @tenant_id AND is_resolved = 0
    UNION ALL
    SELECT N'failed_compliance_controls', COUNT_BIG(*)
    FROM assurance.ComplianceFinding
    WHERE tenant_id = @tenant_id AND finding_status_code = N'FAIL';
END;
GO

CREATE OR ALTER PROCEDURE assurance.SP_GetSqlReviewRequests
    @tenant_id UNIQUEIDENTIFIER,
    @limit INT = 100
AS
BEGIN
    SET NOCOUNT ON;

    SET @limit = CASE WHEN @limit IS NULL OR @limit < 1 THEN 100 WHEN @limit > 1000 THEN 1000 ELSE @limit END;

    SELECT TOP (@limit)
        sql_review_request_id,
        environment_code,
        target_database,
        script_name,
        risk_score,
        risk_level,
        status_code,
        submitted_by_user_id,
        created_at_utc,
        approved_at_utc,
        executed_at_utc
    FROM assurance.SqlReviewRequest
    WHERE tenant_id = @tenant_id
    ORDER BY created_at_utc DESC;
END;
GO

CREATE OR ALTER PROCEDURE assurance.SP_GetSqlRiskFindings
    @tenant_id UNIQUEIDENTIFIER,
    @sql_review_request_id UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (500)
        sql_risk_finding_id,
        sql_review_request_id,
        rule_code,
        severity_code,
        category_code,
        finding_message,
        evidence,
        line_number,
        created_at_utc
    FROM assurance.SqlRiskFinding
    WHERE tenant_id = @tenant_id
      AND (@sql_review_request_id IS NULL OR sql_review_request_id = @sql_review_request_id)
    ORDER BY created_at_utc DESC, severity_code DESC;
END;
GO

-- ─── SP: Sensitive column metadata scan ──────────────────────────────────────
CREATE OR ALTER PROCEDURE assurance.SP_RunSensitiveColumnScan
    @tenant_id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Detected TABLE (
        schema_name SYSNAME,
        table_name SYSNAME,
        column_name SYSNAME,
        detected_pattern NVARCHAR(120),
        data_category_code NVARCHAR(80),
        confidence_score DECIMAL(5,2)
    );

    INSERT INTO @Detected
    SELECT
        s.name,
        t.name,
        c.name,
        CASE
            WHEN LOWER(c.name) LIKE N'%email%' THEN N'email'
            WHEN LOWER(c.name) LIKE N'%phone%' OR LOWER(c.name) LIKE N'%gsm%' OR LOWER(c.name) LIKE N'%mobile%' THEN N'phone'
            WHEN LOWER(c.name) LIKE N'%iban%' THEN N'iban'
            WHEN LOWER(c.name) LIKE N'%national%' OR LOWER(c.name) LIKE N'%ssn%' OR LOWER(c.name) LIKE N'%rijksreg%' THEN N'national_identifier'
            WHEN LOWER(c.name) LIKE N'%birth%' OR LOWER(c.name) LIKE N'%dob%' THEN N'birth_date'
            WHEN LOWER(c.name) LIKE N'%plate%' THEN N'vehicle_plate'
            WHEN LOWER(c.name) LIKE N'%address%' OR LOWER(c.name) LIKE N'%postcode%' THEN N'address'
            ELSE N'possible_personal_data'
        END,
        CASE
            WHEN LOWER(c.name) LIKE N'%email%' THEN N'CONTACT'
            WHEN LOWER(c.name) LIKE N'%phone%' OR LOWER(c.name) LIKE N'%gsm%' OR LOWER(c.name) LIKE N'%mobile%' THEN N'CONTACT'
            WHEN LOWER(c.name) LIKE N'%iban%' THEN N'FINANCIAL'
            WHEN LOWER(c.name) LIKE N'%national%' OR LOWER(c.name) LIKE N'%ssn%' OR LOWER(c.name) LIKE N'%rijksreg%' THEN N'IDENTITY'
            WHEN LOWER(c.name) LIKE N'%birth%' OR LOWER(c.name) LIKE N'%dob%' THEN N'IDENTITY'
            WHEN LOWER(c.name) LIKE N'%plate%' THEN N'VEHICLE'
            WHEN LOWER(c.name) LIKE N'%address%' OR LOWER(c.name) LIKE N'%postcode%' THEN N'ADDRESS'
            ELSE N'PERSONAL'
        END,
        CASE
            WHEN LOWER(c.name) LIKE N'%email%' OR LOWER(c.name) LIKE N'%iban%' THEN 95.00
            WHEN LOWER(c.name) LIKE N'%national%' OR LOWER(c.name) LIKE N'%ssn%' THEN 95.00
            ELSE 80.00
        END
    FROM sys.columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name NOT IN (N'sys', N'INFORMATION_SCHEMA', N'assurance')
      AND (
            LOWER(c.name) LIKE N'%email%'
         OR LOWER(c.name) LIKE N'%phone%'
         OR LOWER(c.name) LIKE N'%gsm%'
         OR LOWER(c.name) LIKE N'%mobile%'
         OR LOWER(c.name) LIKE N'%iban%'
         OR LOWER(c.name) LIKE N'%national%'
         OR LOWER(c.name) LIKE N'%ssn%'
         OR LOWER(c.name) LIKE N'%rijksreg%'
         OR LOWER(c.name) LIKE N'%birth%'
         OR LOWER(c.name) LIKE N'%dob%'
         OR LOWER(c.name) LIKE N'%plate%'
         OR LOWER(c.name) LIKE N'%address%'
         OR LOWER(c.name) LIKE N'%postcode%'
      );

    INSERT INTO assurance.SensitiveColumnFinding (
        tenant_id, schema_name, table_name, column_name, detected_pattern,
        data_category_code, confidence_score, masking_recommended
    )
    SELECT
        @tenant_id, d.schema_name, d.table_name, d.column_name,
        d.detected_pattern, d.data_category_code, d.confidence_score, 1
    FROM @Detected d
    WHERE NOT EXISTS (
        SELECT 1
        FROM assurance.SensitiveColumnFinding f
        WHERE f.tenant_id = @tenant_id
          AND f.schema_name = d.schema_name
          AND f.table_name = d.table_name
          AND f.column_name = d.column_name
          AND f.detected_pattern = d.detected_pattern
    );

    SELECT TOP (500)
        sensitive_column_finding_id,
        schema_name,
        table_name,
        column_name,
        detected_pattern,
        data_category_code,
        confidence_score,
        masking_recommended,
        is_acknowledged,
        created_at_utc
    FROM assurance.SensitiveColumnFinding
    WHERE tenant_id = @tenant_id
    ORDER BY confidence_score DESC, schema_name, table_name, column_name;
END;
GO

-- ─── SP: Compliance scan ─────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE assurance.SP_RunComplianceScan
    @tenant_id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @scan_run_id UNIQUEIDENTIFIER = NEWID();
    DECLARE @audit_trigger_count INT = 0;
    DECLARE @audit_schema_exists BIT = CASE WHEN SCHEMA_ID(N'audit') IS NULL THEN 0 ELSE 1 END;
    DECLARE @encryption_state INT = NULL;

    SELECT @audit_trigger_count = COUNT(*)
    FROM sys.triggers tr
    WHERE tr.name LIKE N'TR[_]%[_]Audit'
      AND tr.is_disabled = 0;

    BEGIN TRY
        SELECT @encryption_state = dek.encryption_state
        FROM sys.dm_database_encryption_keys dek
        WHERE dek.database_id = DB_ID();
    END TRY
    BEGIN CATCH
        SET @encryption_state = NULL;
    END CATCH;

    INSERT INTO assurance.ComplianceScanRun (
        compliance_scan_run_id, tenant_id, scan_scope_code, status_code, started_at_utc
    )
    VALUES (@scan_run_id, @tenant_id, N'YAFES_SQL_SERVER', N'RUNNING', SYSUTCDATETIME());

    INSERT INTO assurance.ComplianceFinding (
        compliance_scan_run_id, tenant_id, framework_code, control_code,
        finding_status_code, severity_code, finding_title, finding_detail,
        evidence_sql, remediation_hint
    )
    VALUES
    (
        @scan_run_id, @tenant_id, N'GDPR', N'GDPR-ART32-AUDIT',
        CASE WHEN @audit_schema_exists = 1 AND @audit_trigger_count > 0 THEN N'PASS' ELSE N'FAIL' END,
        N'HIGH',
        N'Audit trail availability',
        CONCAT(N'audit schema exists: ', @audit_schema_exists, N'; enabled audit triggers: ', @audit_trigger_count),
        N'SELECT * FROM sys.triggers WHERE name LIKE ''TR[_]%[_]Audit'';',
        N'Ensure audit schema exists and critical tables have enabled audit triggers.'
    ),
    (
        @scan_run_id, @tenant_id, N'GDPR', N'GDPR-ART32-ENCRYPTION',
        CASE WHEN @encryption_state = 3 THEN N'PASS' WHEN @encryption_state IS NULL THEN N'WARN' ELSE N'FAIL' END,
        N'HIGH',
        N'Database encryption state',
        CONCAT(N'TDE encryption_state: ', COALESCE(CONVERT(NVARCHAR(20), @encryption_state), N'not available')),
        N'SELECT * FROM sys.dm_database_encryption_keys WHERE database_id = DB_ID();',
        N'Enable TDE or document Azure SQL encryption posture.'
    ),
    (
        @scan_run_id, @tenant_id, N'ISO27001', N'ISO-A.8.12',
        CASE WHEN EXISTS (SELECT 1 FROM assurance.SensitiveColumnFinding WHERE tenant_id = @tenant_id) THEN N'WARN' ELSE N'INFO' END,
        N'HIGH',
        N'Sensitive column inventory',
        N'Sensitive metadata discovery should be reviewed and linked to masking policy.',
        N'EXEC assurance.SP_RunSensitiveColumnScan @tenant_id = @tenant_id;',
        N'Run sensitive column scan and create masking policies for high-confidence findings.'
    );

    UPDATE assurance.ComplianceScanRun
    SET status_code = N'COMPLETED',
        completed_at_utc = SYSUTCDATETIME(),
        summary_json = (
            SELECT
                COUNT(*) AS totalFindings,
                SUM(CASE WHEN finding_status_code = N'FAIL' THEN 1 ELSE 0 END) AS failed,
                SUM(CASE WHEN finding_status_code = N'WARN' THEN 1 ELSE 0 END) AS warnings
            FROM assurance.ComplianceFinding
            WHERE compliance_scan_run_id = @scan_run_id
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
    WHERE compliance_scan_run_id = @scan_run_id;

    SELECT
        compliance_scan_run_id,
        tenant_id,
        scan_scope_code,
        status_code,
        started_at_utc,
        completed_at_utc,
        summary_json
    FROM assurance.ComplianceScanRun
    WHERE compliance_scan_run_id = @scan_run_id;
END;
GO

CREATE OR ALTER PROCEDURE assurance.SP_GetComplianceFindings
    @tenant_id UNIQUEIDENTIFIER,
    @limit INT = 200
AS
BEGIN
    SET NOCOUNT ON;

    SET @limit = CASE WHEN @limit IS NULL OR @limit < 1 THEN 200 WHEN @limit > 1000 THEN 1000 ELSE @limit END;

    SELECT TOP (@limit)
        cf.compliance_finding_id,
        cf.compliance_scan_run_id,
        cf.framework_code,
        cf.control_code,
        cf.finding_status_code,
        cf.severity_code,
        cf.finding_title,
        cf.finding_detail,
        cf.remediation_hint,
        cf.created_at_utc
    FROM assurance.ComplianceFinding cf
    WHERE cf.tenant_id = @tenant_id
    ORDER BY cf.created_at_utc DESC,
             CASE cf.finding_status_code WHEN N'FAIL' THEN 1 WHEN N'WARN' THEN 2 WHEN N'INFO' THEN 3 ELSE 4 END;
END;
GO

-- ─── SP: Permission drift scan ───────────────────────────────────────────────
CREATE OR ALTER PROCEDURE assurance.SP_RunPermissionDriftScan
    @tenant_id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    -- Users without roles
    IF OBJECT_ID(N'core.AppUser') IS NOT NULL AND OBJECT_ID(N'core.UserRole') IS NOT NULL
    BEGIN
        INSERT INTO assurance.PermissionDriftFinding (
            tenant_id, finding_type_code, severity_code, principal_name, role_code,
            finding_detail, remediation_hint
        )
        SELECT
            @tenant_id,
            N'USER_WITHOUT_ROLE',
            N'MEDIUM',
            u.email,
            NULL,
            N'Active user has no assigned role.',
            N'Assign the least-privilege role or deactivate the user.'
        FROM core.AppUser u
        WHERE u.tenant_id = @tenant_id
          AND ISNULL(u.is_active, 1) = 1
          AND NOT EXISTS (SELECT 1 FROM core.UserRole ur WHERE ur.user_id = u.user_id)
          AND NOT EXISTS (
              SELECT 1
              FROM assurance.PermissionDriftFinding f
              WHERE f.tenant_id = @tenant_id
                AND f.finding_type_code = N'USER_WITHOUT_ROLE'
                AND ISNULL(f.principal_name, N'') = ISNULL(u.email, N'')
                AND f.is_resolved = 0
          );
    END

    -- Task assignment outside tenant, mirrors existing SSMS audit query.
    IF OBJECT_ID(N'tasking.Task') IS NOT NULL AND OBJECT_ID(N'core.AppUser') IS NOT NULL
    BEGIN
        INSERT INTO assurance.PermissionDriftFinding (
            tenant_id, finding_type_code, severity_code, principal_name, role_code,
            finding_detail, remediation_hint
        )
        SELECT
            @tenant_id,
            N'TASK_ASSIGNEE_OUTSIDE_TENANT',
            N'HIGH',
            u.email,
            NULL,
            CONCAT(N'Task ', CONVERT(NVARCHAR(50), t.task_id), N' is assigned to user from a different tenant.'),
            N'Reassign task to a user within the same tenant.'
        FROM tasking.Task t
        INNER JOIN core.AppUser u ON u.user_id = t.assigned_to_user_id
        WHERE t.tenant_id = @tenant_id
          AND t.assigned_to_user_id IS NOT NULL
          AND t.tenant_id <> u.tenant_id
          AND NOT EXISTS (
              SELECT 1
              FROM assurance.PermissionDriftFinding f
              WHERE f.tenant_id = @tenant_id
                AND f.finding_type_code = N'TASK_ASSIGNEE_OUTSIDE_TENANT'
                AND f.finding_detail LIKE CONCAT(N'%Task ', CONVERT(NVARCHAR(50), t.task_id), N'%')
                AND f.is_resolved = 0
          );
    END

    SELECT TOP (500)
        permission_drift_finding_id,
        finding_type_code,
        severity_code,
        principal_name,
        role_code,
        finding_detail,
        remediation_hint,
        is_resolved,
        created_at_utc
    FROM assurance.PermissionDriftFinding
    WHERE tenant_id = @tenant_id
    ORDER BY is_resolved ASC, created_at_utc DESC;
END;
GO

CREATE OR ALTER PROCEDURE assurance.SP_GetPermissionDriftFindings
    @tenant_id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (500)
        permission_drift_finding_id,
        finding_type_code,
        severity_code,
        principal_name,
        role_code,
        finding_detail,
        remediation_hint,
        is_resolved,
        created_at_utc,
        resolved_at_utc
    FROM assurance.PermissionDriftFinding
    WHERE tenant_id = @tenant_id
    ORDER BY is_resolved ASC, created_at_utc DESC;
END;
GO

PRINT 'Migration 021 completed.';
GO
'@

# =============================================================================
# SSMS Workbench scripts
# =============================================================================
$ssms20 = @'
/*
    Yafes Pars SSMS Workbench - Assurance Dashboard

    Enable SQLCMD Mode before running.
    Read-heavy dashboard; scan procedures insert assurance findings.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"

SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantCode NVARCHAR(80) = N'$(TENANT_CODE)';
DECLARE @TenantId UNIQUEIDENTIFIER;

SELECT @TenantId = tenant_id
FROM core.Tenant
WHERE tenant_code = @TenantCode;

IF @TenantId IS NULL
    THROW 52200, 'Tenant code was not found.', 1;

PRINT '01 - Assurance KPI dashboard';
EXEC assurance.SP_GetAssuranceDashboard @tenant_id = @TenantId;

PRINT '02 - Latest SQL review requests';
EXEC assurance.SP_GetSqlReviewRequests @tenant_id = @TenantId, @limit = 50;

PRINT '03 - Latest risk findings';
EXEC assurance.SP_GetSqlRiskFindings @tenant_id = @TenantId, @sql_review_request_id = NULL;

PRINT '04 - Latest compliance findings';
EXEC assurance.SP_GetComplianceFindings @tenant_id = @TenantId, @limit = 100;

PRINT '05 - Open permission drift findings';
EXEC assurance.SP_GetPermissionDriftFindings @tenant_id = @TenantId;
GO
'@

$ssms21 = @'
/*
    Yafes Pars SSMS Workbench - SQL Risk Review Board

    Creates a sample review request if SAMPLE_SQL is changed.
    Enable SQLCMD Mode before running.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"

SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantId UNIQUEIDENTIFIER;
SELECT @TenantId = tenant_id FROM core.Tenant WHERE tenant_code = N'$(TENANT_CODE)';
IF @TenantId IS NULL THROW 52210, 'Tenant code was not found.', 1;

DECLARE @SampleSql NVARCHAR(MAX) = N'
UPDATE policy.Contract
SET status_code = ''CANCELLED'';
';

DECLARE @RollbackSql NVARCHAR(MAX) = N'
-- Provide precise rollback SQL before production execution.
';

PRINT '01 - Create SQL review request';
EXEC assurance.SP_CreateSqlReviewRequest
    @tenant_id = @TenantId,
    @environment_code = N'PROD',
    @target_database = N'$(YAFES_SQL_DATABASE)',
    @script_name = N'ssms-sample-risk-review.sql',
    @submitted_sql = @SampleSql,
    @rollback_sql = @RollbackSql,
    @submitted_by_user_id = NULL;

PRINT '02 - Review board';
EXEC assurance.SP_GetSqlReviewRequests @tenant_id = @TenantId, @limit = 100;

PRINT '03 - Findings';
EXEC assurance.SP_GetSqlRiskFindings @tenant_id = @TenantId, @sql_review_request_id = NULL;
GO
'@

$ssms22 = @'
/*
    Yafes Pars SSMS Workbench - Compliance Control Matrix

    Runs sensitive column and compliance scans.
    Enable SQLCMD Mode before running.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"

SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantId UNIQUEIDENTIFIER;
SELECT @TenantId = tenant_id FROM core.Tenant WHERE tenant_code = N'$(TENANT_CODE)';
IF @TenantId IS NULL THROW 52220, 'Tenant code was not found.', 1;

PRINT '01 - Sensitive column scan';
EXEC assurance.SP_RunSensitiveColumnScan @tenant_id = @TenantId;

PRINT '02 - Compliance scan';
EXEC assurance.SP_RunComplianceScan @tenant_id = @TenantId;

PRINT '03 - Compliance findings';
EXEC assurance.SP_GetComplianceFindings @tenant_id = @TenantId, @limit = 200;
GO
'@

$ssms23 = @'
/*
    Yafes Pars SSMS Workbench - Permission Drift Report

    Detects authorization inconsistencies.
    Enable SQLCMD Mode before running.
*/
:ON ERROR EXIT
:setvar YAFES_SQL_DATABASE "YafesPars_Dev"
:setvar TENANT_CODE "DEV-BE-BROKER"

SET NOCOUNT ON;
GO

USE [$(YAFES_SQL_DATABASE)];
GO

DECLARE @TenantId UNIQUEIDENTIFIER;
SELECT @TenantId = tenant_id FROM core.Tenant WHERE tenant_code = N'$(TENANT_CODE)';
IF @TenantId IS NULL THROW 52230, 'Tenant code was not found.', 1;

PRINT '01 - Run permission drift scan';
EXEC assurance.SP_RunPermissionDriftScan @tenant_id = @TenantId;

PRINT '02 - Open permission drift findings';
EXEC assurance.SP_GetPermissionDriftFindings @tenant_id = @TenantId;
GO
'@

# =============================================================================
# Rule files
# =============================================================================
$sqlRiskRules = @'
[
  {
    "ruleCode": "SQL_DESTRUCTIVE_DROP",
    "severity": "CRITICAL",
    "category": "DESTRUCTIVE_OPERATION",
    "patterns": ["DROP TABLE", "DROP DATABASE", "DROP SCHEMA"],
    "productionAction": "BLOCK",
    "message": "DROP operation detected. Production execution requires explicit security approval."
  },
  {
    "ruleCode": "SQL_DESTRUCTIVE_TRUNCATE",
    "severity": "CRITICAL",
    "category": "DATA_LOSS",
    "patterns": ["TRUNCATE TABLE"],
    "productionAction": "BLOCK",
    "message": "TRUNCATE TABLE detected. This is irreversible without backup/restore."
  },
  {
    "ruleCode": "SQL_DELETE_WITHOUT_WHERE",
    "severity": "CRITICAL",
    "category": "DATA_LOSS",
    "patterns": ["DELETE FROM"],
    "requires": ["WHERE"],
    "productionAction": "BLOCK",
    "message": "DELETE without WHERE detected."
  },
  {
    "ruleCode": "SQL_UPDATE_WITHOUT_WHERE",
    "severity": "HIGH",
    "category": "DATA_CORRUPTION",
    "patterns": ["UPDATE"],
    "requires": ["WHERE"],
    "productionAction": "APPROVAL_REQUIRED",
    "message": "UPDATE without WHERE detected."
  },
  {
    "ruleCode": "PROD_ROLLBACK_REQUIRED",
    "severity": "HIGH",
    "category": "CHANGE_GOVERNANCE",
    "environment": "PROD",
    "requires": ["rollbackSql"],
    "productionAction": "APPROVAL_REQUIRED",
    "message": "Production changes require a rollback plan."
  }
]
'@

$sensitiveColumnPatterns = @'
[
  { "pattern": "email", "category": "CONTACT", "confidence": 95, "defaultMasking": "EMAIL_PARTIAL" },
  { "pattern": "phone", "category": "CONTACT", "confidence": 85, "defaultMasking": "PHONE_PARTIAL" },
  { "pattern": "mobile", "category": "CONTACT", "confidence": 85, "defaultMasking": "PHONE_PARTIAL" },
  { "pattern": "iban", "category": "FINANCIAL", "confidence": 95, "defaultMasking": "IBAN_PARTIAL" },
  { "pattern": "national", "category": "IDENTITY", "confidence": 95, "defaultMasking": "HASH" },
  { "pattern": "ssn", "category": "IDENTITY", "confidence": 95, "defaultMasking": "HASH" },
  { "pattern": "birth", "category": "IDENTITY", "confidence": 80, "defaultMasking": "REDACT" },
  { "pattern": "address", "category": "ADDRESS", "confidence": 80, "defaultMasking": "REDACT" },
  { "pattern": "plate", "category": "VEHICLE", "confidence": 80, "defaultMasking": "REDACT" }
]
'@

$complianceControls = @'
[
  {
    "framework": "GDPR",
    "controlCode": "GDPR-ART32-AUDIT",
    "title": "Auditability of processing",
    "severity": "HIGH",
    "description": "Personal-data processing activities must be traceable through audit logs."
  },
  {
    "framework": "GDPR",
    "controlCode": "GDPR-ART32-ENCRYPTION",
    "title": "Encryption at rest",
    "severity": "HIGH",
    "description": "Database encryption should be enabled or explicitly documented."
  },
  {
    "framework": "CIS",
    "controlCode": "CIS-MSSQL-AUDIT",
    "title": "SQL Server audit controls",
    "severity": "HIGH",
    "description": "Audit controls should be active and monitored."
  },
  {
    "framework": "ISO27001",
    "controlCode": "ISO-A.8.2",
    "title": "Privileged access rights",
    "severity": "HIGH",
    "description": "Privileged access must be granted, reviewed and revoked under control."
  }
]
'@

# =============================================================================
# API endpoint scaffold
# =============================================================================
$assuranceEndpoints = @'
using System.Security.Claims;
using YafesPars.Application.Abstractions;
using YafesPars.Api.Security;

namespace YafesPars.Api.Endpoints;

public static class AssuranceEndpoints
{
    public static IEndpointRouteBuilder MapAssuranceEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/assurance")
            .WithTags("Assurance")
            .RequireAuthorization(AuthRoles.AuditorPolicy)
            .RequireRateLimiting("tenant");

        api.MapGet("/dashboard", GetDashboardAsync);
        api.MapGet("/sql-reviews", GetSqlReviewsAsync);
        api.MapGet("/sql-risk-findings", GetSqlRiskFindingsAsync);
        api.MapGet("/compliance-findings", GetComplianceFindingsAsync);
        api.MapGet("/permission-drift", GetPermissionDriftAsync);

        api.MapPost("/sql-review", CreateSqlReviewAsync)
            .RequireAuthorization(AuthRoles.AdminPolicy)
            .RequireRateLimiting("write");

        api.MapPost("/sensitive-column-scan", RunSensitiveColumnScanAsync)
            .RequireAuthorization(AuthRoles.AdminPolicy)
            .RequireRateLimiting("write");

        api.MapPost("/compliance-scan", RunComplianceScanAsync)
            .RequireAuthorization(AuthRoles.AdminPolicy)
            .RequireRateLimiting("write");

        api.MapPost("/permission-drift-scan", RunPermissionDriftScanAsync)
            .RequireAuthorization(AuthRoles.AdminPolicy)
            .RequireRateLimiting("write");

        return app;
    }

    private static async Task<IResult> GetDashboardAsync(
        ClaimsPrincipal user,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<AssuranceMetricRow>(
            "assurance.SP_GetAssuranceDashboard",
            new { tenant_id = tenantId },
            cancellationToken);

        return Results.Ok(rows);
    }

    private static async Task<IResult> GetSqlReviewsAsync(
        ClaimsPrincipal user,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<SqlReviewRequestRow>(
            "assurance.SP_GetSqlReviewRequests",
            new
            {
                tenant_id = tenantId,
                limit = Math.Clamp(take.GetValueOrDefault(100), 1, 1000)
            },
            cancellationToken);

        return Results.Ok(rows);
    }

    private static async Task<IResult> CreateSqlReviewAsync(
        ClaimsPrincipal user,
        SqlReviewCreateRequest request,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);
        var submittedBy = TryGetUserId(user);

        if (string.IsNullOrWhiteSpace(request.SubmittedSql))
            return Results.BadRequest(new { error = "submittedSql is required." });

        var rows = await repository.QueryAsync<SqlReviewCreatedRow>(
            "assurance.SP_CreateSqlReviewRequest",
            new
            {
                tenant_id = tenantId,
                environment_code = string.IsNullOrWhiteSpace(request.EnvironmentCode) ? "DEV" : request.EnvironmentCode.Trim().ToUpperInvariant(),
                target_database = string.IsNullOrWhiteSpace(request.TargetDatabase) ? "YafesPars" : request.TargetDatabase.Trim(),
                script_name = request.ScriptName,
                submitted_sql = request.SubmittedSql,
                rollback_sql = request.RollbackSql,
                submitted_by_user_id = submittedBy
            },
            cancellationToken);

        return Results.Ok(rows.FirstOrDefault());
    }

    private static async Task<IResult> GetSqlRiskFindingsAsync(
        ClaimsPrincipal user,
        Guid? sqlReviewRequestId,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<SqlRiskFindingRow>(
            "assurance.SP_GetSqlRiskFindings",
            new { tenant_id = tenantId, sql_review_request_id = sqlReviewRequestId },
            cancellationToken);

        return Results.Ok(rows);
    }

    private static async Task<IResult> RunSensitiveColumnScanAsync(
        ClaimsPrincipal user,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<SensitiveColumnFindingRow>(
            "assurance.SP_RunSensitiveColumnScan",
            new { tenant_id = tenantId },
            cancellationToken);

        return Results.Ok(new
        {
            generatedAtUtc = DateTime.UtcNow,
            findingCount = rows.Count,
            findings = rows
        });
    }

    private static async Task<IResult> RunComplianceScanAsync(
        ClaimsPrincipal user,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<ComplianceScanRunRow>(
            "assurance.SP_RunComplianceScan",
            new { tenant_id = tenantId },
            cancellationToken);

        return Results.Ok(rows.FirstOrDefault());
    }

    private static async Task<IResult> GetComplianceFindingsAsync(
        ClaimsPrincipal user,
        int? take,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<ComplianceFindingRow>(
            "assurance.SP_GetComplianceFindings",
            new
            {
                tenant_id = tenantId,
                limit = Math.Clamp(take.GetValueOrDefault(200), 1, 1000)
            },
            cancellationToken);

        return Results.Ok(rows);
    }

    private static async Task<IResult> RunPermissionDriftScanAsync(
        ClaimsPrincipal user,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<PermissionDriftFindingRow>(
            "assurance.SP_RunPermissionDriftScan",
            new { tenant_id = tenantId },
            cancellationToken);

        return Results.Ok(new
        {
            generatedAtUtc = DateTime.UtcNow,
            findingCount = rows.Count,
            findings = rows
        });
    }

    private static async Task<IResult> GetPermissionDriftAsync(
        ClaimsPrincipal user,
        IReadRepository repository,
        CancellationToken cancellationToken)
    {
        var tenantId = TenantClaims.GetRequiredTenantId(user);

        var rows = await repository.QueryAsync<PermissionDriftFindingRow>(
            "assurance.SP_GetPermissionDriftFindings",
            new { tenant_id = tenantId },
            cancellationToken);

        return Results.Ok(rows);
    }

    private static Guid? TryGetUserId(ClaimsPrincipal user)
    {
        var value = user.FindFirstValue("sub")
            ?? user.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? user.FindFirstValue("user_id");

        return Guid.TryParse(value, out var id) ? id : null;
    }

    public sealed record SqlReviewCreateRequest(
        string EnvironmentCode,
        string TargetDatabase,
        string? ScriptName,
        string SubmittedSql,
        string? RollbackSql);

    private sealed record AssuranceMetricRow(string MetricCode, long MetricValue);

    private sealed record SqlReviewCreatedRow(
        Guid SqlReviewRequestId,
        Guid TenantId,
        string EnvironmentCode,
        string TargetDatabase,
        string? ScriptName,
        int RiskScore,
        string RiskLevel,
        string StatusCode,
        DateTime CreatedAtUtc);

    private sealed record SqlReviewRequestRow(
        Guid SqlReviewRequestId,
        string EnvironmentCode,
        string TargetDatabase,
        string? ScriptName,
        int RiskScore,
        string RiskLevel,
        string StatusCode,
        Guid? SubmittedByUserId,
        DateTime CreatedAtUtc,
        DateTime? ApprovedAtUtc,
        DateTime? ExecutedAtUtc);

    private sealed record SqlRiskFindingRow(
        Guid SqlRiskFindingId,
        Guid SqlReviewRequestId,
        string RuleCode,
        string SeverityCode,
        string CategoryCode,
        string FindingMessage,
        string? Evidence,
        int? LineNumber,
        DateTime CreatedAtUtc);

    private sealed record SensitiveColumnFindingRow(
        Guid SensitiveColumnFindingId,
        string SchemaName,
        string TableName,
        string ColumnName,
        string DetectedPattern,
        string DataCategoryCode,
        decimal ConfidenceScore,
        bool MaskingRecommended,
        bool IsAcknowledged,
        DateTime CreatedAtUtc);

    private sealed record ComplianceScanRunRow(
        Guid ComplianceScanRunId,
        Guid TenantId,
        string ScanScopeCode,
        string StatusCode,
        DateTime StartedAtUtc,
        DateTime? CompletedAtUtc,
        string? SummaryJson);

    private sealed record ComplianceFindingRow(
        Guid ComplianceFindingId,
        Guid ComplianceScanRunId,
        string FrameworkCode,
        string ControlCode,
        string FindingStatusCode,
        string SeverityCode,
        string FindingTitle,
        string? FindingDetail,
        string? RemediationHint,
        DateTime CreatedAtUtc);

    private sealed record PermissionDriftFindingRow(
        Guid PermissionDriftFindingId,
        string FindingTypeCode,
        string SeverityCode,
        string? PrincipalName,
        string? RoleCode,
        string FindingDetail,
        string? RemediationHint,
        bool IsResolved,
        DateTime CreatedAtUtc,
        DateTime? ResolvedAtUtc);
}
'@

# =============================================================================
# Docs
# =============================================================================
$docs = @'
# Yafes Assurance Engine

Yafes Assurance Engine, Yafes Pars SSMS-first mimarisine eklenen database governance ve change-assurance katmanıdır.

## Amaç

Bu modül SQL Server değişikliklerini sadece çalıştırılabilir script olarak değil, risk, onay, rollback, audit, compliance ve veri koruma boyutlarıyla ele alır.

## V1 kapsamı

| Alan | İçerik |
|---|---|
| SQL script risk analizi | DROP, TRUNCATE, DELETE/UPDATE without WHERE, schema change, trigger disablement |
| Production değişiklik onayı | Risk seviyesine göre pending approval veya blocked |
| Rollback planı | PROD değişikliklerinde rollback zorunluluğu |
| Audit trail | Review request, finding, approval ve scan kayıtları |
| Sensitive column detection | Metadata tabanlı email, phone, iban, national id, birth date, address, plate detection |
| Data masking policy | Column-level masking policy tablosu |
| GDPR/CIS/ISO kontrol matrisi | Seed compliance controls + scan findings |
| SQL Server config scanner | Audit trigger ve encryption-state kontrolleri |
| User/role/permission drift | Role atanmamış kullanıcı ve tenant dışı task assignment kontrolü |
| Assurance dashboard | SSMS ve API dashboard endpointleri |

## Oluşan API endpointleri

```text
GET  /api/assurance/dashboard
GET  /api/assurance/sql-reviews
POST /api/assurance/sql-review
GET  /api/assurance/sql-risk-findings
POST /api/assurance/sensitive-column-scan
POST /api/assurance/compliance-scan
GET  /api/assurance/compliance-findings
POST /api/assurance/permission-drift-scan
GET  /api/assurance/permission-drift
```

## SSMS scriptleri

```text
database/ssms/20__assurance_dashboard.sql
database/ssms/21__sql_risk_review_board.sql
database/ssms/22__compliance_control_matrix.sql
database/ssms/23__permission_drift_report.sql
```

## Migration

```text
database/migrations/021__create_assurance_domain.sql
```

## Azure notu

Bu modül Yafes Pars API içinde native endpoint olarak çalışır. Ayrı CloudDM veya Bytebase container'ı gerektirmez. Azure App Service deploy sürecine normal API build/deploy ile dahil olur. SQL tarafında migration 021'in Azure SQL üzerinde çalıştırılması gerekir.

## Sonraki geliştirme adımları

1. Risk analyzer'ı T-SQL parser tabanlı hale getirmek.
2. Approval workflow'u gerçek kullanıcı/rol matrisiyle bağlamak.
3. HTML/PDF report renderer eklemek.
4. Azure SQL Defender / Microsoft Defender for SQL bulgularını içeri almak.
5. SQLFluff veya benzeri linter ile CI/CD entegrasyonu yapmak.
'@

$runMigrationScript = @'
[CmdletBinding()]
param(
    [string]$SqlServer = $env:YAFES_SQL_SERVER,
    [string]$DatabaseName = $env:YAFES_SQL_DATABASE,
    [string]$SqlUser = $env:YAFES_SQL_USER,
    [string]$SqlPassword = $env:YAFES_SQL_PASSWORD
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path (Join-Path $PSScriptRoot '..') '..')).Path
$migrationPath = Join-Path $repoRoot 'database/migrations/021__create_assurance_domain.sql'

if (-not (Test-Path $migrationPath)) {
    throw "Migration not found: $migrationPath"
}

if ([string]::IsNullOrWhiteSpace($SqlServer)) {
    $SqlServer = 'localhost,1433'
}

if ([string]::IsNullOrWhiteSpace($DatabaseName)) {
    $DatabaseName = 'YafesPars'
}

if (-not (Get-Command sqlcmd -ErrorAction SilentlyContinue)) {
    throw 'sqlcmd bulunamadı. SQL Server tools kurulu olmalı.'
}

if ([string]::IsNullOrWhiteSpace($SqlUser)) {
    Write-Host "Running with Windows authentication: $SqlServer / $DatabaseName"
    sqlcmd -S $SqlServer -d $DatabaseName -E -b -v YAFES_SQL_DATABASE=$DatabaseName -i $migrationPath
}
else {
    if ([string]::IsNullOrWhiteSpace($SqlPassword)) {
        throw 'YAFES_SQL_PASSWORD veya -SqlPassword gerekli.'
    }

    Write-Host "Running with SQL authentication: $SqlServer / $DatabaseName / $SqlUser"
    sqlcmd -S $SqlServer -d $DatabaseName -U $SqlUser -P $SqlPassword -C -b -v YAFES_SQL_DATABASE=$DatabaseName -i $migrationPath
}

Write-Host 'Assurance migration completed.' -ForegroundColor Green
'@

$assuranceReadme = @'
# database/assurance

Bu klasör Yafes Assurance Engine için rule ve scanner konfigürasyonlarını tutar.

- `rules/sql-risk-rules.json`: SQL script risk analizi kuralları
- `rules/sensitive-column-patterns.json`: sensitive column detection patternleri
- `rules/compliance-controls.json`: GDPR/CIS/ISO control seed modeli

Runtime V1 SQL Server stored procedure tabanlıdır. Bu JSON dosyaları V2'de API içindeki rule engine tarafından okunacak hale getirilebilir.
'@

# =============================================================================
# Write files
# =============================================================================
Write-ProjectFile -RelativePath 'database/migrations/021__create_assurance_domain.sql' -Content $migration021
Write-ProjectFile -RelativePath 'database/ssms/20__assurance_dashboard.sql' -Content $ssms20
Write-ProjectFile -RelativePath 'database/ssms/21__sql_risk_review_board.sql' -Content $ssms21
Write-ProjectFile -RelativePath 'database/ssms/22__compliance_control_matrix.sql' -Content $ssms22
Write-ProjectFile -RelativePath 'database/ssms/23__permission_drift_report.sql' -Content $ssms23
Write-ProjectFile -RelativePath 'database/assurance/rules/sql-risk-rules.json' -Content $sqlRiskRules
Write-ProjectFile -RelativePath 'database/assurance/rules/sensitive-column-patterns.json' -Content $sensitiveColumnPatterns
Write-ProjectFile -RelativePath 'database/assurance/rules/compliance-controls.json' -Content $complianceControls
Write-ProjectFile -RelativePath 'database/assurance/README.md' -Content $assuranceReadme
Write-ProjectFile -RelativePath 'database/tools/run-assurance-migration.ps1' -Content $runMigrationScript
Write-ProjectFile -RelativePath 'backend/src/YafesPars.Api/Endpoints/AssuranceEndpoints.cs' -Content $assuranceEndpoints
Write-ProjectFile -RelativePath 'docs/yafes-assurance-engine.md' -Content $docs

# =============================================================================
# Optional Program.cs patch
# =============================================================================
if ($PatchProgram) {
    $programPath = Join-Path $repoRoot 'backend/src/YafesPars.Api/Program.cs'
    if (-not (Test-Path $programPath)) {
        throw "Program.cs bulunamadı: $programPath"
    }

    $program = Get-Content -Path $programPath -Raw

    if ($program -match 'MapAssuranceEndpoints\(\)') {
        Write-Host 'SKIP  Program.cs already contains app.MapAssuranceEndpoints();' -ForegroundColor Yellow
    }
    elseif ($program -match 'app\.MapAuditEndpoints\(\);') {
        $program = $program -replace 'app\.MapAuditEndpoints\(\);', "app.MapAuditEndpoints();`r`n    app.MapAssuranceEndpoints();"
        Set-Content -Path $programPath -Value $program -Encoding UTF8
        Write-Host 'PATCH backend/src/YafesPars.Api/Program.cs -> app.MapAssuranceEndpoints(); added.' -ForegroundColor Green
    }
    else {
        Write-Host 'WARN  Program.cs içinde app.MapAuditEndpoints(); bulunamadı. Şu satırı manuel ekle:' -ForegroundColor Yellow
        Write-Host '      app.MapAssuranceEndpoints();' -ForegroundColor Yellow
    }
}
else {
    Write-Host ''
    Write-Host 'Program.cs patch yapılmadı. Endpointi aktif etmek için şunu çalıştır:' -ForegroundColor Yellow
    Write-Host '  .\tools\install-yafes-assurance-engine.ps1 -PatchProgram' -ForegroundColor Yellow
    Write-Host 'veya Program.cs içine app.MapAuditEndpoints(); sonrasına şunu ekle:' -ForegroundColor Yellow
    Write-Host '  app.MapAssuranceEndpoints();' -ForegroundColor Yellow
}

# =============================================================================
# Optional migration apply
# =============================================================================
if ($ApplyMigration) {
    $runner = Join-Path $repoRoot 'database/tools/run-assurance-migration.ps1'

    & $runner `
        -SqlServer $SqlServer `
        -DatabaseName $(if ([string]::IsNullOrWhiteSpace($DatabaseName)) { 'YafesPars' } else { $DatabaseName }) `
        -SqlUser $SqlUser `
        -SqlPassword $SqlPassword
}

Write-Host ''
Write-Host 'Yafes Assurance Engine scaffold hazır.' -ForegroundColor Cyan
Write-Host 'Sonraki komutlar:' -ForegroundColor Cyan
Write-Host '  git status'
Write-Host '  dotnet build .\backend\src\YafesPars.Api\YafesPars.Api.csproj'
Write-Host '  .\database\tools\run-assurance-migration.ps1'
Write-Host ''
