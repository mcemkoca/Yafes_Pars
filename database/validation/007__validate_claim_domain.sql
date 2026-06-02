SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF OBJECT_ID(N'claim.Claim', N'U') IS NULL
    THROW 50701, 'Missing table: claim.Claim', 1;

IF OBJECT_ID(N'claim.ClaimParty', N'U') IS NULL
    THROW 50702, 'Missing table: claim.ClaimParty', 1;

IF OBJECT_ID(N'claim.ClaimObject', N'U') IS NULL
    THROW 50703, 'Missing table: claim.ClaimObject', 1;

IF OBJECT_ID(N'claim.ClaimCircumstance', N'U') IS NULL
    THROW 50704, 'Missing table: claim.ClaimCircumstance', 1;

IF OBJECT_ID(N'claim.ClaimStatus', N'U') IS NULL
    THROW 50705, 'Missing table: claim.ClaimStatus', 1;

IF COL_LENGTH(N'claim.Claim', N'tenant_id') IS NULL
    THROW 50706, 'Missing column: claim.Claim.tenant_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = N'UQ_Claim_tenant_number'
      AND parent_object_id = OBJECT_ID(N'claim.Claim')
)
    THROW 50707, 'Missing unique constraint: UQ_Claim_tenant_number', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Claim_Contract'
      AND parent_object_id = OBJECT_ID(N'claim.Claim')
)
    THROW 50708, 'Missing FK: FK_Claim_Contract', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_ClaimObject_InsurableObject'
      AND parent_object_id = OBJECT_ID(N'claim.ClaimObject')
)
    THROW 50709, 'Missing FK: FK_ClaimObject_InsurableObject', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_Claim_payment_method'
      AND parent_object_id = OBJECT_ID(N'claim.Claim')
)
    THROW 50710, 'Missing check constraint: CK_Claim_payment_method', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Claim_contract'
      AND object_id = OBJECT_ID(N'claim.Claim')
)
    THROW 50711, 'Missing index: IX_Claim_contract', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Claim_status_reported'
      AND object_id = OBJECT_ID(N'claim.Claim')
)
    THROW 50712, 'Missing index: IX_Claim_status_reported', 1;

PRINT 'Claim domain validation passed.';
GO
