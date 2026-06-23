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

IF EXISTS (
    SELECT 1
    FROM claim.Claim
    WHERE incident_date IS NOT NULL
      AND reported_date < incident_date
)
    THROW 50713, 'Claim reported_date cannot be before incident_date.', 1;

IF EXISTS (
    SELECT 1
    FROM claim.Claim
    WHERE (claim_status_code = N'CLOSED' AND closed_date IS NULL)
       OR (claim_status_code <> N'CLOSED' AND closed_date IS NOT NULL)
)
    THROW 50714, 'Claim closed status/date state is inconsistent.', 1;

IF EXISTS (
    SELECT 1
    FROM claim.Claim
    WHERE paid_amount > 0
      AND payment_method_code IS NULL
)
    THROW 50715, 'Paid claim must have payment method.', 1;

IF EXISTS (
    SELECT 1
    FROM claim.Claim
    WHERE ISNULL(paid_amount, 0) < 0
       OR ISNULL(reserved_amount, 0) < 0
)
    THROW 50716, 'Claim paid/reserved amount cannot be negative.', 1;

IF EXISTS (
    SELECT 1
    FROM claim.Claim c
    WHERE c.is_deleted = 0
      AND NOT EXISTS (
            SELECT 1
            FROM policy.Contract pc
            WHERE pc.contract_id = c.contract_id
              AND pc.tenant_id = c.tenant_id
      )
)
    THROW 50717, 'Claim contract tenant linkage is invalid.', 1;

PRINT 'Claim domain validation passed.';
GO
