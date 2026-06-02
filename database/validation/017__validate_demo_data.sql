SET NOCOUNT ON;
GO

USE [YafesPars];
GO

DECLARE @TenantId UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000000001';

IF NOT EXISTS (SELECT 1 FROM core.Tenant WHERE tenant_id = @TenantId)
    THROW 51701, 'Missing demo tenant.', 1;

IF (SELECT COUNT(*) FROM core.AppUser WHERE tenant_id = @TenantId) < 3
    THROW 51702, 'Missing demo users.', 1;

IF (
    SELECT COUNT(*)
    FROM core.UserRole ur
    INNER JOIN core.AppUser au
        ON au.user_id = ur.user_id
    WHERE au.tenant_id = @TenantId
) < 3
    THROW 51712, 'Missing demo user roles.', 1;

IF (
    SELECT COUNT(*)
    FROM person.Person
    WHERE tenant_id = @TenantId
      AND person_kind = N'NATURAL'
) < 5
    THROW 51703, 'Missing demo natural persons.', 1;

IF (
    SELECT COUNT(*)
    FROM person.Person
    WHERE tenant_id = @TenantId
      AND person_kind = N'LEGAL'
) < 2
    THROW 51704, 'Missing demo legal persons.', 1;

IF (SELECT COUNT(*) FROM institution.Institution WHERE tenant_id = @TenantId) < 3
    THROW 51705, 'Missing demo institutions.', 1;

IF (SELECT COUNT(*) FROM risk.InsurableObject WHERE tenant_id = @TenantId AND object_type_code = N'VEHICLE') < 3
    THROW 51706, 'Missing demo vehicles.', 1;

IF (SELECT COUNT(*) FROM risk.InsurableObject WHERE tenant_id = @TenantId AND object_type_code = N'REAL_ESTATE') < 2
    THROW 51707, 'Missing demo real estate risks.', 1;

IF (SELECT COUNT(*) FROM policy.Contract WHERE tenant_id = @TenantId) < 4
    THROW 51708, 'Missing demo contracts.', 1;

IF (SELECT COUNT(*) FROM claim.Claim WHERE tenant_id = @TenantId) < 2
    THROW 51709, 'Missing demo claims.', 1;

IF (SELECT COUNT(*) FROM tasking.Task WHERE tenant_id = @TenantId) < 5
    THROW 51710, 'Missing demo tasks.', 1;

IF (SELECT COUNT(*) FROM document.Document WHERE tenant_id = @TenantId) < 5
    THROW 51711, 'Missing demo documents.', 1;

PRINT 'Demo data validation passed.';
GO
