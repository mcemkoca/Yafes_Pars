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

PRINT 'Coverage domain validation passed.';
GO
