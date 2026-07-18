-- =============================================================================
-- Validation 032: Claim Settlement workflow
-- =============================================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE [YafesPars];
GO

PRINT 'Validating: 032__validate_claim_settlement.sql';
GO

-- Tables
IF OBJECT_ID(N'claim.ClaimSettlement', N'U') IS NULL
    THROW 53201, 'claim.ClaimSettlement table missing.', 1;

IF OBJECT_ID(N'claim.ClaimReserveLog', N'U') IS NULL
    THROW 53202, 'claim.ClaimReserveLog table missing.', 1;

-- Stored procedures
IF OBJECT_ID(N'claim.SP_CreateSettlement', N'P') IS NULL
    THROW 53203, 'claim.SP_CreateSettlement SP missing.', 1;

IF OBJECT_ID(N'claim.SP_ApproveSettlement', N'P') IS NULL
    THROW 53204, 'claim.SP_ApproveSettlement SP missing.', 1;

IF OBJECT_ID(N'claim.SP_UpdateClaimReserve', N'P') IS NULL
    THROW 53205, 'claim.SP_UpdateClaimReserve SP missing.', 1;

IF OBJECT_ID(N'claim.SP_GetClaimSettlementSummary', N'P') IS NULL
    THROW 53206, 'claim.SP_GetClaimSettlementSummary SP missing.', 1;

IF OBJECT_ID(N'claim.SP_GetReserveLog', N'P') IS NULL
    THROW 53207, 'claim.SP_GetReserveLog SP missing.', 1;

-- Constraints
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_ClaimSettlement_status'
      AND parent_object_id = OBJECT_ID(N'claim.ClaimSettlement')
)
    THROW 53208, 'CK_ClaimSettlement_status constraint missing.', 1;

-- Indexes
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_ClaimSettlement_claim'
      AND object_id = OBJECT_ID(N'claim.ClaimSettlement')
)
    THROW 53209, 'IX_ClaimSettlement_claim index missing.', 1;

PRINT 'Validation 032 passed: claim settlement tables, SPs, constraints, indexes OK.';
GO
