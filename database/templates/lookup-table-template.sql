SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID('ref.<LookupTable>', 'U') IS NULL
BEGIN
    CREATE TABLE ref.<LookupTable> (
        lookup_code NVARCHAR(80) NOT NULL,
        label_nl NVARCHAR(160) NOT NULL,
        label_fr NVARCHAR(160) NULL,
        label_en NVARCHAR(160) NULL,
        label_tr NVARCHAR(160) NULL,
        is_active BIT NOT NULL CONSTRAINT DF_LookupTable_is_active DEFAULT 1,
        sort_order INT NULL,
        CONSTRAINT PK_LookupTable PRIMARY KEY (lookup_code)
    );
END;
GO
