-- =============================================================================
-- Migration 021 â€” Yafes Assurance Engine
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

-- â”€â”€â”€ SQL review request â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

-- â”€â”€â”€ SQL risk finding â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

-- â”€â”€â”€ Approval workflow â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

-- â”€â”€â”€ Rollback plan â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

-- â”€â”€â”€ Sensitive column finding â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

-- â”€â”€â”€ Masking policy â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

-- â”€â”€â”€ Compliance controls â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

-- â”€â”€â”€ Permission drift â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

-- â”€â”€â”€ Assurance report â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

-- â”€â”€â”€ Seed controls â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

-- â”€â”€â”€ SP: Create SQL review request + lightweight static risk analysis â”€â”€â”€â”€â”€â”€â”€â”€
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

-- â”€â”€â”€ SP: Dashboard â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

-- â”€â”€â”€ SP: Sensitive column metadata scan â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

-- â”€â”€â”€ SP: Compliance scan â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

-- â”€â”€â”€ SP: Permission drift scan â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
