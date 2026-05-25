-- =============================================================
-- AssureManager Triggers
-- Timestamp updates and business rule enforcement
-- =============================================================
-- Run AFTER 04_seeds.sql
-- =============================================================

SET NOCOUNT ON;
GO

USE AssureManagerDB;
GO

PRINT '======================================================';
PRINT ' Creating triggers...';
PRINT '======================================================';
GO

-- 05_triggers.sql - Noodzakelijke triggers (bedrijfsregels en bijwerken timestamps)
-- Triggers gegroepeerd per domein. Alleen essentiële triggers die niet via constraints afdwingbaar zijn, en triggers voor het bijwerken van updated_at timestamps.

-- =============================================================
-- Person Domain Triggers
-- =============================================================
-- Trigger: update 'updated_at' timestamp bij bijwerken van Person
CREATE TRIGGER TR_Person_SetUpdatedAt
ON Person
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Person
    SET updated_at = SYSUTCDATETIME()
    FROM Person AS p
    INNER JOIN inserted i ON p.person_id = i.person_id;
END;
GO

-- =============================================================
-- Institution Domain Triggers
-- =============================================================
-- Trigger: update 'updated_at' timestamp bij bijwerken van Institution
CREATE TRIGGER TR_Institution_SetUpdatedAt
ON Institution
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Institution
    SET updated_at = SYSUTCDATETIME()
    FROM Institution AS inst
    INNER JOIN inserted i ON inst.institution_id = i.institution_id;
END;
GO

-- =============================================================
-- Object Domain Triggers
-- =============================================================
-- Trigger: update 'updated_at' timestamp bij bijwerken van Object
CREATE TRIGGER TR_Object_SetUpdatedAt
ON [Object]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [Object]
    SET updated_at = SYSUTCDATETIME()
    FROM [Object] AS o
    INNER JOIN inserted i ON o.object_id = i.object_id;
END;
GO

-- =============================================================
-- Contract Domain Triggers
-- =============================================================
-- Trigger: update 'updated_at' timestamp bij bijwerken van Contract
CREATE TRIGGER TR_Contract_SetUpdatedAt
ON Contract
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Contract
    SET updated_at = SYSUTCDATETIME()
    FROM Contract AS c
    INNER JOIN inserted i ON c.contract_id = i.contract_id;
END;
GO

-- Trigger: update 'updated_at' timestamp bij bijwerken van ContractVersion
CREATE TRIGGER TR_ContractVersion_SetUpdatedAt
ON ContractVersion
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ContractVersion
    SET updated_at = SYSUTCDATETIME()
    FROM ContractVersion AS cv
    INNER JOIN inserted i ON cv.contract_version_id = i.contract_version_id;
END;
GO

-- Trigger: update 'updated_at' timestamp bij bijwerken van Contract_Object
CREATE TRIGGER TR_ContractObject_SetUpdatedAt
ON Contract_Object
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Contract_Object
    SET updated_at = SYSUTCDATETIME()
    FROM Contract_Object AS co
    INNER JOIN inserted i ON co.contract_id = i.contract_id AND co.object_id = i.object_id;
END;
GO

-- Trigger: voorkom verwijderen van laatste Contract_Party (elke contract moet ≥ 1 partij hebben)
CREATE TRIGGER TR_ContractParty_PreventLastDelete
ON Contract_Party
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM deleted d
        WHERE d.contract_id NOT IN (
            SELECT cp.contract_id FROM Contract_Party AS cp
        )
    )
    BEGIN
        THROW 51001, 'Cannot delete the last party of a contract. Each contract must have at least one party.', 1;
    END;
END;
GO

-- Trigger: voorkom verwijderen van laatste Contract_Object (elke contract moet ≥ 1 object hebben)
CREATE TRIGGER TR_ContractObject_PreventLastDelete
ON Contract_Object
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM deleted d
        WHERE d.contract_id NOT IN (
            SELECT co.contract_id FROM Contract_Object AS co
        )
    )
    BEGIN
        THROW 51002, 'Cannot delete the last object of a contract. Each contract must have at least one linked object.', 1;
    END;
END;
GO

-- =============================================================
-- Claim Domain Triggers
-- =============================================================
-- Trigger: update 'updated_at' timestamp bij bijwerken van Claim
CREATE TRIGGER TR_Claim_SetUpdatedAt
ON Claim
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Claim
    SET updated_at = SYSUTCDATETIME()
    FROM Claim AS cl
    INNER JOIN inserted i ON cl.claim_id = i.claim_id;
END;
GO

-- Trigger: update 'updated_at' timestamp bij bijwerken van Claim_Object
CREATE TRIGGER TR_ClaimObject_SetUpdatedAt
ON Claim_Object
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Claim_Object
    SET updated_at = SYSUTCDATETIME()
    FROM Claim_Object AS co
    INNER JOIN inserted i ON co.claim_id = i.claim_id AND co.object_id = i.object_id;
END;
GO

-- Trigger: update 'updated_at' timestamp bij bijwerken van Claim_Circumstance
CREATE TRIGGER TR_ClaimCircumstance_SetUpdatedAt
ON Claim_Circumstance
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Claim_Circumstance
    SET updated_at = SYSUTCDATETIME()
    FROM Claim_Circumstance AS cc
    INNER JOIN inserted i ON cc.claim_id = i.claim_id AND cc.claim_circumstance_type_code = i.claim_circumstance_type_code;
END;
GO

-- Trigger: voorkom verwijderen van laatste Claim_Party (elke claim moet ≥ 1 partij hebben)
CREATE TRIGGER TR_ClaimParty_PreventLastDelete
ON Claim_Party
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM deleted d
        WHERE d.claim_id NOT IN (
            SELECT cp.claim_id FROM Claim_Party AS cp
        )
    )
    BEGIN
        THROW 51003, 'Cannot delete the last party of a claim. Each claim must have at least one party (e.g., claimant or insured).', 1;
    END;
END;
GO

-- Trigger: voorkom verwijderen van laatste Claim_Circumstance (elke claim moet ≥ 1 circumstance hebben)
CREATE TRIGGER TR_ClaimCircumstance_PreventLastDelete
ON Claim_Circumstance
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM deleted d
        WHERE d.claim_id NOT IN (
            SELECT cc.claim_id FROM Claim_Circumstance AS cc
        )
    )
    BEGIN
        THROW 51004, 'Cannot delete the last circumstance of a claim. Each claim must have at least one circumstance.', 1;
    END;
END;
GO


PRINT '';
PRINT '======================================================';
PRINT ' Triggers created successfully!';
PRINT '======================================================';
GO
