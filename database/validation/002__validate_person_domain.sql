SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF OBJECT_ID(N'person.Person', N'U') IS NULL
    THROW 50201, 'Missing table: person.Person', 1;

IF OBJECT_ID(N'person.NaturalPerson', N'U') IS NULL
    THROW 50202, 'Missing table: person.NaturalPerson', 1;

IF OBJECT_ID(N'person.LegalPerson', N'U') IS NULL
    THROW 50203, 'Missing table: person.LegalPerson', 1;

IF OBJECT_ID(N'person.Address', N'U') IS NULL
    THROW 50204, 'Missing table: person.Address', 1;

IF OBJECT_ID(N'person.Phone', N'U') IS NULL
    THROW 50205, 'Missing table: person.Phone', 1;

IF OBJECT_ID(N'person.Email', N'U') IS NULL
    THROW 50206, 'Missing table: person.Email', 1;

IF OBJECT_ID(N'person.PersonRelation', N'U') IS NULL
    THROW 50207, 'Missing table: person.PersonRelation', 1;

IF OBJECT_ID(N'ref.Language', N'U') IS NULL
    THROW 50208, 'Missing table: ref.Language', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Person_Tenant'
      AND parent_object_id = OBJECT_ID(N'person.Person')
)
    THROW 50209, 'Missing FK: FK_Person_Tenant', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_NaturalPerson_Person'
      AND parent_object_id = OBJECT_ID(N'person.NaturalPerson')
)
    THROW 50210, 'Missing FK: FK_NaturalPerson_Person', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_LegalPerson_Person'
      AND parent_object_id = OBJECT_ID(N'person.LegalPerson')
)
    THROW 50211, 'Missing FK: FK_LegalPerson_Person', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_Email_Person'
      AND parent_object_id = OBJECT_ID(N'person.Email')
)
    THROW 50212, 'Missing FK: FK_Email_Person', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_AppUser_Person'
      AND parent_object_id = OBJECT_ID(N'core.AppUser')
)
    THROW 50213, 'Missing FK: FK_AppUser_Person', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'UQ_Person_tenant_dossier'
      AND object_id = OBJECT_ID(N'person.Person')
)
    THROW 50214, 'Missing index: UQ_Person_tenant_dossier', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_NaturalPerson_name'
      AND object_id = OBJECT_ID(N'person.NaturalPerson')
)
    THROW 50215, 'Missing index: IX_NaturalPerson_name', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Email_email'
      AND object_id = OBJECT_ID(N'person.Email')
)
    THROW 50216, 'Missing index: IX_Email_email', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Phone_number'
      AND object_id = OBJECT_ID(N'person.Phone')
)
    THROW 50217, 'Missing index: IX_Phone_number', 1;

IF COL_LENGTH(N'person.Person', N'tenant_id') IS NULL
    THROW 50218, 'Missing column: person.Person.tenant_id', 1;

IF COL_LENGTH(N'person.Person', N'is_deleted') IS NULL
    THROW 50219, 'Missing column: person.Person.is_deleted', 1;

IF EXISTS (
    SELECT 1
    FROM person.Person p
    WHERE p.person_kind = N'NATURAL'
      AND p.is_deleted = 0
      AND NOT EXISTS (
            SELECT 1
            FROM person.NaturalPerson np
            WHERE np.person_id = p.person_id
              AND np.is_deleted = 0
      )
)
    THROW 50220, 'Natural person without NaturalPerson row.', 1;

IF EXISTS (
    SELECT 1
    FROM person.Person p
    WHERE p.person_kind = N'LEGAL'
      AND p.is_deleted = 0
      AND NOT EXISTS (
            SELECT 1
            FROM person.LegalPerson lp
            WHERE lp.person_id = p.person_id
              AND lp.is_deleted = 0
      )
)
    THROW 50221, 'Legal person without LegalPerson row.', 1;

IF EXISTS (
    SELECT 1
    FROM person.NaturalPerson np
    INNER JOIN person.LegalPerson lp
        ON lp.person_id = np.person_id
    WHERE np.is_deleted = 0
      AND lp.is_deleted = 0
)
    THROW 50222, 'Person cannot be both natural and legal.', 1;

IF EXISTS (
    SELECT p.tenant_id, e.email
    FROM person.Email e
    INNER JOIN person.Person p
        ON p.person_id = e.person_id
    WHERE e.is_deleted = 0
      AND e.is_primary = 1
    GROUP BY p.tenant_id, e.email
    HAVING COUNT(1) > 1
)
    THROW 50223, 'Duplicate primary email per tenant.', 1;

PRINT 'Person domain validation passed.';
GO
