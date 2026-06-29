-- =============================================================================
-- Migration 031: finance.SP_MarkOverdueInvoices
-- Zet PENDING facturen met vervaldatum in het verleden op OVERDUE.
-- Bedoeld voor dagelijkse SQL Agent job uitvoering. Tenant-agnostisch.
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'031__add_overdue_invoice_sp')
    BEGIN
        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'031__add_overdue_invoice_sp', N'SUCCESS');
    END

COMMIT TRANSACTION;
GO

CREATE OR ALTER PROCEDURE finance.SP_MarkOverdueInvoices
    @dry_run BIT = 1
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    DECLARE @affected INT = 0;

    IF @dry_run = 1
    BEGIN
        SELECT @affected = COUNT(*)
        FROM finance.Invoices
        WHERE StatusCode = N'PENDING'
          AND DueDate < CAST(SYSUTCDATETIME() AS DATE);

        SELECT
            @affected AS WouldMark,
            'DRY_RUN' AS Mode,
            CAST(SYSUTCDATETIME() AS DATE) AS RunDate;
        RETURN;
    END

    UPDATE finance.Invoices
    SET StatusCode = N'OVERDUE',
        UpdatedAt  = SYSUTCDATETIME()
    WHERE StatusCode = N'PENDING'
      AND DueDate < CAST(SYSUTCDATETIME() AS DATE);

    SET @affected = @@ROWCOUNT;

    SELECT
        @affected AS Marked,
        'EXECUTED' AS Mode,
        CAST(SYSUTCDATETIME() AS DATE) AS RunDate;
END TRY
BEGIN CATCH
    THROW;
END CATCH;
GO

PRINT 'Migration 031 complete: finance.SP_MarkOverdueInvoices.';
GO
