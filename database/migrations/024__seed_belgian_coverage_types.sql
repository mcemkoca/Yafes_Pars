-- =============================================================================
-- Migration 024: Belgische dekkingstypes in coverage.CoverageType
--   sp_AddCoverageItem valideert tegen coverage.CoverageType. Tot nu bevatte
--   die catalogus alleen Turkse codes → add_coverage_item met BA_AUTO/OMNIUM
--   faalde (51753). Deze migratie voegt de Belgische codes toe als actief.
-- =============================================================================
USE [YafesPars];
GO

BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM core.SchemaMigration WHERE migration_name = N'024__seed_belgian_coverage_types')
    BEGIN

        MERGE coverage.CoverageType AS target
        USING (VALUES
            (N'BA_AUTO',                N'Trafik Sorumluluk',       N'Motor third-party liability', 10),
            (N'OMNIUM',                 N'Kasko (Tam)',             N'Comprehensive motor',         20),
            (N'MINI_OMNIUM',            N'Kasko (Sınırlı)',         N'Limited comprehensive motor', 30),
            (N'LEGAL_PROTECTION_AUTO',  N'Araç Hukuki Koruma',      N'Auto legal protection',       40),
            (N'LEGAL_PROTECTION',       N'Hukuki Koruma',           N'Legal protection',            50),
            (N'LEGAL_ASSISTANCE',       N'Hukuki Yardım',           N'Legal assistance',            55),
            (N'FIRE_BUILDING',          N'Bina Yangın',             N'Fire building',               60),
            (N'FIRE_CONTENTS',          N'Eşya Yangın',             N'Fire contents',               70),
            (N'FAMILY_LIABILITY',       N'Aile Sorumluluk',         N'Family liability',            110),
            (N'LEGAL_PROTECTION_PRIVATE', N'Özel Hukuki Koruma',    N'Private legal protection',    120),
            (N'HOSPITALIZATION',        N'Hastane',                 N'Hospitalization',             130),
            (N'LIFE_COVER',             N'Hayat Teminatı',          N'Life cover',                  140)
        ) AS source (coverage_type_code, label_tr, label_en, sort_order)
        ON target.coverage_type_code = source.coverage_type_code
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (coverage_type_code, label_tr, label_en, is_active, sort_order)
            VALUES (source.coverage_type_code, source.label_tr, source.label_en, 1, source.sort_order)
        WHEN MATCHED THEN
            UPDATE SET is_active = 1, label_en = source.label_en;

        INSERT INTO core.SchemaMigration (migration_name, execution_status)
        VALUES (N'024__seed_belgian_coverage_types', N'SUCCESS');

    END

COMMIT TRANSACTION;
GO

PRINT 'Migration 024 voltooid: Belgische dekkingstypes toegevoegd aan coverage.CoverageType.';
GO
