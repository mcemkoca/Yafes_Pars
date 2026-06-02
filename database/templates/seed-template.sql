SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    MERGE ref.<LookupTable> AS target
    USING (VALUES
        (N'<CODE>', N'<Label NL>', N'<Label FR>')
    ) AS source (lookup_code, label_nl, label_fr)
    ON target.lookup_code = source.lookup_code
    WHEN MATCHED THEN
        UPDATE SET
            label_nl = source.label_nl,
            label_fr = source.label_fr
    WHEN NOT MATCHED THEN
        INSERT (lookup_code, label_nl, label_fr)
        VALUES (source.lookup_code, source.label_nl, source.label_fr);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
