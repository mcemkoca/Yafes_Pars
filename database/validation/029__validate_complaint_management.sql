-- =============================================================================
-- Validation 029: şikayet yönetimi tablolarını ve SP'lerini doğrula
-- =============================================================================
USE [YafesPars];
GO

-- 029-001: communication.Complaint tablosu
IF NOT EXISTS (SELECT 1 FROM sys.tables
               WHERE schema_id = SCHEMA_ID(N'communication') AND name = N'Complaint')
BEGIN
    RAISERROR (N'[029-001] communication.Complaint tablosu bulunamadi.', 16, 1);
    RETURN;
END;

-- 029-002: SP_RegisterComplaint
IF NOT EXISTS (SELECT 1 FROM sys.procedures p JOIN sys.schemas s ON s.schema_id = p.schema_id
               WHERE s.name = N'communication' AND p.name = N'SP_RegisterComplaint')
BEGIN
    RAISERROR (N'[029-002] communication.SP_RegisterComplaint bulunamadi.', 16, 1);
    RETURN;
END;

-- 029-003: SP_UpdateComplaintStatus
IF NOT EXISTS (SELECT 1 FROM sys.procedures p JOIN sys.schemas s ON s.schema_id = p.schema_id
               WHERE s.name = N'communication' AND p.name = N'SP_UpdateComplaintStatus')
BEGIN
    RAISERROR (N'[029-003] communication.SP_UpdateComplaintStatus bulunamadi.', 16, 1);
    RETURN;
END;

-- 029-004: SP_GetComplaintDashboard
IF NOT EXISTS (SELECT 1 FROM sys.procedures p JOIN sys.schemas s ON s.schema_id = p.schema_id
               WHERE s.name = N'communication' AND p.name = N'SP_GetComplaintDashboard')
BEGIN
    RAISERROR (N'[029-004] communication.SP_GetComplaintDashboard bulunamadi.', 16, 1);
    RETURN;
END;

-- 029-005: reporting.SP_FsmaComplaintReport
IF NOT EXISTS (SELECT 1 FROM sys.procedures p JOIN sys.schemas s ON s.schema_id = p.schema_id
               WHERE s.name = N'reporting' AND p.name = N'SP_FsmaComplaintReport')
BEGIN
    RAISERROR (N'[029-005] reporting.SP_FsmaComplaintReport bulunamadi.', 16, 1);
    RETURN;
END;

-- 029-006: status CHECK constraint
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_Complaint_Status')
BEGIN
    RAISERROR (N'[029-006] CK_Complaint_Status CHECK constraint bulunamadi.', 16, 1);
    RETURN;
END;

PRINT 'Validation 029 OK: sikayet yonetimi tablosu ve SP''leri dogrulandi.';
GO
