-- =============================================================================
-- Migration 025: risk.sp_CreateVehicle — geldige default lookup-codes
--   Defaults @vehicle_type_code='PASSENGER' en @plate_type_code='STANDARD'
--   bestaan niet in risk.VehicleType / risk.LicensePlateType (seed: CAR/VAN/
--   MOTORCYCLE en NORMAL/TEMPORARY) → FK-conflict bij register_vehicle zonder
--   expliciete codes. Defaults gecorrigeerd naar CAR / NORMAL. Valuta → EUR.
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'025__fix_vehicle_defaults')
        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'025__fix_vehicle_defaults', N'SUCCESS');
COMMIT TRANSACTION;
GO

CREATE OR ALTER PROCEDURE risk.sp_CreateVehicle
    @tenant_id             UNIQUEIDENTIFIER,
    @plate_number          NVARCHAR(20),
    @brand                 NVARCHAR(100)    = N'',
    @model                 NVARCHAR(100)    = N'',
    @model_year            INT              = NULL,
    @chassis_number        NVARCHAR(40)     = N'',
    @engine_number         NVARCHAR(40)     = NULL,
    @market_value          DECIMAL(18,2)    = NULL,
    @currency_code         NCHAR(3)         = N'EUR',
    @fuel_type_code        NVARCHAR(40)     = NULL,
    @vehicle_type_code     NVARCHAR(60)     = N'CAR',
    @usage_type_code       NVARCHAR(40)     = N'PRIVATE',
    @plate_type_code       NVARCHAR(40)     = N'NORMAL',
    @created_by_user_id    UNIQUEIDENTIFIER = NULL,
    @insurable_object_id   UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @tenant_id IS NULL
        THROW 51720, 'tenant_id is required.', 1;
    IF @plate_number IS NULL OR LEN(TRIM(@plate_number)) = 0
        THROW 51721, 'plate_number is required.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC risk.sp_CreateRiskObject
            @tenant_id           = @tenant_id,
            @object_type_code    = N'VEHICLE',
            @description         = @plate_number,
            @created_by_user_id  = @created_by_user_id,
            @insurable_object_id = @insurable_object_id OUTPUT;

        INSERT INTO risk.InsurableVehicle
            (insurable_object_id, vehicle_type_code, usage_type_code, plate_type_code,
             brand, model, chassis_number, build_year, first_commissioning_date,
             registration_date, license_plate, fuel_type_code)
        VALUES
            (@insurable_object_id, @vehicle_type_code, @usage_type_code, @plate_type_code,
             ISNULL(@brand, N''), ISNULL(@model, N''), ISNULL(@chassis_number, N''),
             ISNULL(@model_year, YEAR(SYSUTCDATETIME())),
             CAST(SYSUTCDATETIME() AS DATE), CAST(SYSUTCDATETIME() AS DATE),
             @plate_number, @fuel_type_code);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

PRINT 'Migration 025 voltooid: sp_CreateVehicle defaults gecorrigeerd (CAR/NORMAL/EUR).';
GO
