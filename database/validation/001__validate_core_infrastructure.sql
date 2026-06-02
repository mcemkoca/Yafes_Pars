SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF SCHEMA_ID(N'core') IS NULL
    THROW 50101, 'Missing schema: core', 1;

IF SCHEMA_ID(N'ref') IS NULL
    THROW 50102, 'Missing schema: ref', 1;

IF SCHEMA_ID(N'person') IS NULL
    THROW 50103, 'Missing schema: person', 1;

IF SCHEMA_ID(N'institution') IS NULL
    THROW 50104, 'Missing schema: institution', 1;

IF SCHEMA_ID(N'risk') IS NULL
    THROW 50105, 'Missing schema: risk', 1;

IF SCHEMA_ID(N'policy') IS NULL
    THROW 50106, 'Missing schema: policy', 1;

IF SCHEMA_ID(N'coverage') IS NULL
    THROW 50107, 'Missing schema: coverage', 1;

IF SCHEMA_ID(N'claim') IS NULL
    THROW 50108, 'Missing schema: claim', 1;

IF SCHEMA_ID(N'document') IS NULL
    THROW 50109, 'Missing schema: document', 1;

IF SCHEMA_ID(N'tasking') IS NULL
    THROW 50110, 'Missing schema: tasking', 1;

IF SCHEMA_ID(N'audit') IS NULL
    THROW 50111, 'Missing schema: audit', 1;

IF OBJECT_ID(N'core.SchemaMigration', N'U') IS NULL
    THROW 50112, 'Missing table: core.SchemaMigration', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = N'PK_SchemaMigration'
      AND parent_object_id = OBJECT_ID(N'core.SchemaMigration')
)
    THROW 50113, 'Missing primary key: PK_SchemaMigration', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_SchemaMigration_execution_status'
      AND parent_object_id = OBJECT_ID(N'core.SchemaMigration')
)
    THROW 50114, 'Missing check constraint: CK_SchemaMigration_execution_status', 1;

PRINT 'Core schema and migration tracking validation passed.';
GO
