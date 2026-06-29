SET NOCOUNT ON;
GO

USE [YafesPars];
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.views
    WHERE schema_id = SCHEMA_ID(N'reporting') AND name = N'VW_PortfolioSummary'
)
    THROW 51980, 'reporting.VW_PortfolioSummary view ontbreekt.', 1;

PRINT 'Validatie 019: portefeuille-overzicht OK.';
GO
