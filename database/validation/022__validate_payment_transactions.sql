SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables
    WHERE schema_id = SCHEMA_ID(N'finance') AND name = N'PaymentTransaction'
)
    THROW 52020, 'finance.PaymentTransaction ontbreekt.', 1;

IF NOT EXISTS (
    SELECT 1 FROM sys.procedures
    WHERE schema_id = SCHEMA_ID(N'finance') AND name = N'SP_CreatePaymentTransaction'
)
    THROW 52021, 'finance.SP_CreatePaymentTransaction ontbreekt.', 1;

IF NOT EXISTS (
    SELECT 1 FROM sys.procedures
    WHERE schema_id = SCHEMA_ID(N'finance') AND name = N'SP_UpdatePaymentStatus'
)
    THROW 52022, 'finance.SP_UpdatePaymentStatus ontbreekt.', 1;

PRINT 'Validatie 022: PaymentTransaction + SPs OK.';
GO
