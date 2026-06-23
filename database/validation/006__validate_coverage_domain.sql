SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF OBJECT_ID(N'coverage.Coverage', N'U') IS NULL
    THROW 50601, 'Missing table: coverage.Coverage', 1;

IF OBJECT_ID(N'coverage.CoverageDomain', N'U') IS NULL
    THROW 50602, 'Missing table: coverage.CoverageDomain', 1;

IF OBJECT_ID(N'coverage.CoveragePackage', N'U') IS NULL
    THROW 50603, 'Missing table: coverage.CoveragePackage', 1;

IF OBJECT_ID(N'coverage.CoveragePackageItem', N'U') IS NULL
    THROW 50604, 'Missing table: coverage.CoveragePackageItem', 1;

IF OBJECT_ID(N'dbo.lookup_coverage', N'U') IS NOT NULL
    THROW 50605, 'Forbidden legacy table exists: dbo.lookup_coverage', 1;

IF OBJECT_ID(N'dbo.coverage_domain', N'U') IS NOT NULL
    THROW 50606, 'Forbidden legacy table exists: dbo.coverage_domain', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_CoverageDomain_Coverage'
      AND parent_object_id = OBJECT_ID(N'coverage.CoverageDomain')
)
    THROW 50607, 'Missing FK: FK_CoverageDomain_Coverage', 1;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_CoverageDomain_ContractDomain'
      AND parent_object_id = OBJECT_ID(N'coverage.CoverageDomain')
)
    THROW 50608, 'Missing FK: FK_CoverageDomain_ContractDomain', 1;

IF NOT EXISTS (
    SELECT 1
    FROM coverage.Coverage
    WHERE coverage_code = N'AUTO_LIABILITY'
)
    THROW 50609, 'Missing seed coverage: AUTO_LIABILITY', 1;

IF NOT EXISTS (
    SELECT 1
    FROM coverage.Coverage
    WHERE coverage_code = N'BA_AUTO'
)
    THROW 50610, 'Missing seed coverage: BA_AUTO', 1;

IF NOT EXISTS (
    SELECT 1
    FROM coverage.CoveragePackage
    WHERE package_code = N'AUTO_BASIC'
)
    THROW 50611, 'Missing coverage package: AUTO_BASIC', 1;

IF EXISTS (
    SELECT 1
    FROM coverage.CoveragePackage cp
    WHERE cp.is_active = 1
      AND NOT EXISTS (
            SELECT 1
            FROM coverage.CoveragePackageItem cpi
            WHERE cpi.coverage_package_id = cp.coverage_package_id
      )
)
    THROW 50612, 'Active coverage package without items.', 1;

IF EXISTS (
    SELECT 1
    FROM coverage.Coverage c
    WHERE c.is_active = 1
      AND NOT EXISTS (
            SELECT 1
            FROM coverage.CoverageDomain cd
            WHERE cd.coverage_code = c.coverage_code
      )
)
    THROW 50613, 'Active coverage without coverage domain mapping.', 1;

IF EXISTS (
    SELECT 1
    FROM coverage.CoveragePackage cp
    INNER JOIN coverage.CoveragePackageItem cpi
        ON cpi.coverage_package_id = cp.coverage_package_id
    WHERE NOT EXISTS (
        SELECT 1
        FROM coverage.CoverageDomain cd
        WHERE cd.coverage_code = cpi.coverage_code
          AND cd.contract_domain_code = cp.contract_domain_code
    )
)
    THROW 50614, 'Coverage package item is not valid for the package domain.', 1;

PRINT 'Coverage domain validation passed.';
GO
