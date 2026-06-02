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

IF OBJECT_ID(N'core.Tenant', N'U') IS NULL
    THROW 50113, 'Missing table: core.Tenant', 1;

IF OBJECT_ID(N'core.AppUser', N'U') IS NULL
    THROW 50114, 'Missing table: core.AppUser', 1;

IF OBJECT_ID(N'core.Role', N'U') IS NULL
    THROW 50115, 'Missing table: core.Role', 1;

IF OBJECT_ID(N'core.Permission', N'U') IS NULL
    THROW 50116, 'Missing table: core.Permission', 1;

IF OBJECT_ID(N'core.RolePermission', N'U') IS NULL
    THROW 50117, 'Missing table: core.RolePermission', 1;

IF OBJECT_ID(N'core.UserRole', N'U') IS NULL
    THROW 50118, 'Missing table: core.UserRole', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = N'PK_SchemaMigration'
      AND parent_object_id = OBJECT_ID(N'core.SchemaMigration')
)
    THROW 50119, 'Missing primary key: PK_SchemaMigration', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_SchemaMigration_execution_status'
      AND parent_object_id = OBJECT_ID(N'core.SchemaMigration')
)
    THROW 50120, 'Missing check constraint: CK_SchemaMigration_execution_status', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_AppUser_Tenant'
      AND parent_object_id = OBJECT_ID(N'core.AppUser')
)
    THROW 50121, 'Missing FK: FK_AppUser_Tenant', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Role_Tenant'
      AND parent_object_id = OBJECT_ID(N'core.Role')
)
    THROW 50122, 'Missing FK: FK_Role_Tenant', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_RolePermission_Role'
      AND parent_object_id = OBJECT_ID(N'core.RolePermission')
)
    THROW 50123, 'Missing FK: FK_RolePermission_Role', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_RolePermission_Permission'
      AND parent_object_id = OBJECT_ID(N'core.RolePermission')
)
    THROW 50124, 'Missing FK: FK_RolePermission_Permission', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_UserRole_AppUser'
      AND parent_object_id = OBJECT_ID(N'core.UserRole')
)
    THROW 50125, 'Missing FK: FK_UserRole_AppUser', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_UserRole_Role'
      AND parent_object_id = OBJECT_ID(N'core.UserRole')
)
    THROW 50126, 'Missing FK: FK_UserRole_Role', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_AppUser_tenant_id'
      AND object_id = OBJECT_ID(N'core.AppUser')
)
    THROW 50127, 'Missing index: IX_AppUser_tenant_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_RolePermission_permission_code'
      AND object_id = OBJECT_ID(N'core.RolePermission')
)
    THROW 50128, 'Missing index: IX_RolePermission_permission_code', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_AppUser_person_id'
      AND object_id = OBJECT_ID(N'core.AppUser')
)
    THROW 50129, 'Missing index: IX_AppUser_person_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Role_tenant_id'
      AND object_id = OBJECT_ID(N'core.Role')
)
    THROW 50130, 'Missing index: IX_Role_tenant_id', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_UserRole_role_id'
      AND object_id = OBJECT_ID(N'core.UserRole')
)
    THROW 50131, 'Missing index: IX_UserRole_role_id', 1;

PRINT 'Core infrastructure validation passed.';
GO
