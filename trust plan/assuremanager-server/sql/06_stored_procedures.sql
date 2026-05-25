-- =============================================================
-- AssureManager Stored Procedures
-- Belgian Insurance Management System
-- =============================================================
-- Run AFTER 05_triggers.sql
-- Contains: 18 production-grade stored procedures
-- =============================================================

SET NOCOUNT ON;
GO

USE AssureManagerDB;
GO

PRINT '======================================================';
PRINT ' Creating stored procedures...';
PRINT '======================================================';
GO

-- =============================================================
-- 1. sp_Person_GetAll - List persons with pagination, search, type, city
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Person_GetAll
    @PageNumber     INT = 1,
    @PageSize       INT = 25,
    @Search         NVARCHAR(100) = NULL,
    @PersonKind     NVARCHAR(10) = NULL,       -- 'NATURAL', 'LEGAL', or NULL for both
    @City           NVARCHAR(120) = NULL,
    @SortColumn     NVARCHAR(50) = 'created_at',
    @SortDirection  NVARCHAR(4) = 'DESC'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    -- Main query with CTE for counting
    WITH FilteredPersons AS (
        SELECT
            p.person_id,
            p.person_kind,
            p.dossier,
            p.language_code,
            p.nationality,
            p.created_at,
            p.updated_at,
            -- Natural person fields
            np.first_name,
            np.last_name,
            np.birth_date,
            np.gender,
            np.national_number,
            -- Legal person fields
            lp.legal_form,
            lp.incorporation_date,
            -- Computed display name
            CASE
                WHEN p.person_kind = 'NATURAL' THEN CONCAT(np.first_name, ' ', np.last_name)
                ELSE lp.legal_form
            END AS display_name,
            -- Primary address info for filtering
            a.city AS address_city,
            a.postal_code
        FROM Person p
        LEFT JOIN NaturalPerson np ON p.person_id = np.person_id
        LEFT JOIN LegalPerson lp ON p.person_id = lp.person_id
        LEFT JOIN Address a ON p.person_id = a.person_id AND a.is_primary = 1
        WHERE (@Search IS NULL
               OR np.first_name LIKE '%' + @Search + '%'
               OR np.last_name LIKE '%' + @Search + '%'
               OR np.national_number LIKE '%' + @Search + '%'
               OR p.dossier LIKE '%' + @Search + '%'
               OR lp.legal_form LIKE '%' + @Search + '%')
          AND (@PersonKind IS NULL OR p.person_kind = @PersonKind)
          AND (@City IS NULL OR a.city LIKE '%' + @City + '%')
    )
    SELECT
        fp.*,
        (SELECT COUNT(*) FROM FilteredPersons) AS total_count
    FROM FilteredPersons fp
    ORDER BY
        CASE WHEN @SortColumn = 'display_name' AND @SortDirection = 'ASC' THEN fp.display_name END ASC,
        CASE WHEN @SortColumn = 'display_name' AND @SortDirection = 'DESC' THEN fp.display_name END DESC,
        CASE WHEN @SortColumn = 'created_at' AND @SortDirection = 'ASC' THEN fp.created_at END ASC,
        CASE WHEN @SortColumn = 'created_at' AND @SortDirection = 'DESC' THEN fp.created_at END DESC,
        CASE WHEN @SortColumn = 'dossier' AND @SortDirection = 'ASC' THEN fp.dossier END ASC,
        CASE WHEN @SortColumn = 'dossier' AND @SortDirection = 'DESC' THEN fp.dossier END DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- =============================================================
-- 2. sp_Person_GetById - Full person detail with addresses, phones, emails
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Person_GetById
    @PersonId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    -- Main person data
    SELECT
        p.person_id,
        p.person_kind,
        p.dossier,
        p.language_code,
        l.language_label_nl,
        p.nationality,
        p.created_at,
        p.updated_at,
        -- Natural person
        np.first_name,
        np.last_name,
        np.birth_date,
        np.birth_place,
        np.death_date,
        np.gender,
        np.marital_status,
        np.national_number,
        np.passport_number,
        np.id_card_number,
        np.id_card_valid_from,
        np.id_card_valid_to,
        t.title_label_nl,
        -- Legal person
        lp.incorporation_date,
        lp.closing_date,
        lp.legal_form,
        -- Subagent/manager/portfolio references
        p.subagent_person_id,
        p.manager_person_id,
        p.portfolio_person_id
    FROM Person p
    LEFT JOIN Language l ON p.language_code = l.language_code
    LEFT JOIN NaturalPerson np ON p.person_id = np.person_id
    LEFT JOIN Title t ON np.title_code = t.title_code
    LEFT JOIN LegalPerson lp ON p.person_id = lp.person_id
    WHERE p.person_id = @PersonId;

    -- Addresses
    SELECT
        a.address_id,
        a.address_role_code,
        r.label_nl AS address_role_label,
        a.street,
        a.house_number,
        a.box,
        a.postal_code,
        a.city,
        a.country,
        a.country_code,
        a.remark,
        a.is_primary,
        a.created_at
    FROM Address a
    JOIN PersonAddressRole r ON a.address_role_code = r.address_role_code
    WHERE a.person_id = @PersonId
    ORDER BY a.is_primary DESC, a.created_at;

    -- Phone numbers
    SELECT
        ph.phone_id,
        ph.phone_number,
        ph.phone_type_code,
        pt.phone_type_label_nl,
        ph.is_primary,
        ph.comment,
        ph.created_at
    FROM Phone ph
    JOIN PhoneType pt ON ph.phone_type_code = pt.phone_type_code
    WHERE ph.person_id = @PersonId
    ORDER BY ph.is_primary DESC;

    -- Emails
    SELECT
        e.email_id,
        e.email,
        e.comment
    FROM Email e
    WHERE e.person_id = @PersonId;

    -- Bank accounts
    SELECT
        ba.bank_account_id,
        ba.iban,
        ba.bic,
        ba.bank,
        ba.remark
    FROM BankAccount ba
    WHERE ba.person_id = @PersonId;

    -- Social media
    SELECT
        sm.social_id,
        sm.social_type_code,
        st.social_type_label_nl,
        sm.url,
        sm.description
    FROM SocialMedia sm
    JOIN SocialType st ON sm.social_type_code = st.social_type_code
    WHERE sm.person_id = @PersonId;

    -- Economic activities
    SELECT
        ea.economic_activity_id,
        ea.profession,
        ps.professional_status_label_nl,
        ea.kbo_number,
        ea.vat_number,
        ea.paritair_comite_code
    FROM EconomicActivity ea
    LEFT JOIN ProfessionalStatus ps ON ea.professional_status_code = ps.professional_status_code
    WHERE ea.person_id = @PersonId;

    -- Person types
    SELECT pt.person_type_code, pt.person_type_label_nl
    FROM Person_PersonType ppt
    JOIN PersonType pt ON ppt.person_type_code = pt.person_type_code
    WHERE ppt.person_id = @PersonId;

    -- Relations
    SELECT
        pr.person_relation_id,
        pr.relation_type_code,
        pr.start_date,
        pr.end_date,
        prp.person_role,
        prp2.person_id AS related_person_id,
        COALESCE(np2.first_name + ' ' + np2.last_name, lp2.legal_form) AS related_person_name
    FROM PersonRelation pr
    JOIN PersonRelation_Person prp ON pr.person_relation_id = prp.person_relation_id
    JOIN PersonRelation_Person prp2 ON pr.person_relation_id = prp2.person_relation_id AND prp2.person_role <> prp.person_role
    LEFT JOIN NaturalPerson np2 ON prp2.person_id = np2.person_id
    LEFT JOIN LegalPerson lp2 ON prp2.person_id = lp2.person_id
    WHERE prp.person_id = @PersonId;
END;
GO

-- =============================================================
-- 3. sp_Person_Create - Insert Natural or Legal person
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Person_Create
    @PersonKind     NVARCHAR(10),
    @Dossier        NVARCHAR(50) = NULL,
    @LanguageCode   CHAR(2) = 'NL',
    @Nationality    NVARCHAR(80) = NULL,
    @SubagentId     UNIQUEIDENTIFIER = NULL,
    @ManagerId      UNIQUEIDENTIFIER = NULL,
    @PortfolioId    UNIQUEIDENTIFIER = NULL,
    -- Natural person fields
    @FirstName      NVARCHAR(100) = NULL,
    @LastName       NVARCHAR(100) = NULL,
    @BirthDate      DATE = NULL,
    @BirthPlace     NVARCHAR(120) = NULL,
    @Gender         NVARCHAR(20) = NULL,
    @MaritalStatus  NVARCHAR(50) = NULL,
    @NationalNumber NVARCHAR(30) = NULL,
    @TitleCode      NVARCHAR(10) = NULL,
    -- Legal person fields
    @IncorporationDate DATE = NULL,
    @LegalForm      NVARCHAR(120) = NULL,
    -- Output
    @NewPersonId    UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate required parameters
        IF @PersonKind IS NULL OR @PersonKind NOT IN ('NATURAL', 'LEGAL')
            THROW 52002, 'PersonKind must be NATURAL or LEGAL.', 1;

        BEGIN TRANSACTION;

        -- Generate new person ID
        SET @NewPersonId = NEWSEQUENTIALID();

        -- Insert base Person record
        INSERT INTO Person (person_id, person_kind, dossier, language_code, nationality,
                           subagent_person_id, manager_person_id, portfolio_person_id)
        VALUES (@NewPersonId, @PersonKind, @Dossier, @LanguageCode, @Nationality,
                @SubagentId, @ManagerId, @PortfolioId);

        -- Insert subtype-specific record
        IF @PersonKind = 'NATURAL'
        BEGIN
            INSERT INTO NaturalPerson (person_id, first_name, last_name, birth_date, birth_place,
                                       gender, marital_status, national_number, title_code)
            VALUES (@NewPersonId, @FirstName, @LastName, @BirthDate, @BirthPlace,
                    @Gender, @MaritalStatus, @NationalNumber, @TitleCode);
        END
        ELSE IF @PersonKind = 'LEGAL'
        BEGIN
            INSERT INTO LegalPerson (person_id, incorporation_date, legal_form)
            VALUES (@NewPersonId, @IncorporationDate, @LegalForm);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- =============================================================
-- 4. sp_Person_Update - Update person data
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Person_Update
    @PersonId       UNIQUEIDENTIFIER,
    @Dossier        NVARCHAR(50) = NULL,
    @LanguageCode   CHAR(2) = NULL,
    @Nationality    NVARCHAR(80) = NULL,
    -- Natural person fields
    @FirstName      NVARCHAR(100) = NULL,
    @LastName       NVARCHAR(100) = NULL,
    @BirthDate      DATE = NULL,
    @BirthPlace     NVARCHAR(120) = NULL,
    @Gender         NVARCHAR(20) = NULL,
    @MaritalStatus  NVARCHAR(50) = NULL,
    @NationalNumber NVARCHAR(30) = NULL,
    @TitleCode      NVARCHAR(10) = NULL,
    -- Legal person fields
    @IncorporationDate DATE = NULL,
    @ClosingDate    DATE = NULL,
    @LegalForm      NVARCHAR(120) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @PersonKind NVARCHAR(10);
        SELECT @PersonKind = person_kind FROM Person WHERE person_id = @PersonId;

        IF @PersonKind IS NULL
            THROW 52001, 'Person not found.', 1;

        -- Update base Person
        UPDATE Person
        SET dossier = COALESCE(@Dossier, dossier),
            language_code = COALESCE(@LanguageCode, language_code),
            nationality = COALESCE(@Nationality, nationality),
            updated_at = SYSUTCDATETIME()
        WHERE person_id = @PersonId;

        -- Update subtype
        IF @PersonKind = 'NATURAL'
        BEGIN
            UPDATE NaturalPerson
            SET first_name = COALESCE(@FirstName, first_name),
                last_name = COALESCE(@LastName, last_name),
                birth_date = COALESCE(@BirthDate, birth_date),
                birth_place = COALESCE(@BirthPlace, birth_place),
                gender = COALESCE(@Gender, gender),
                marital_status = COALESCE(@MaritalStatus, marital_status),
                national_number = COALESCE(@NationalNumber, national_number),
                title_code = COALESCE(@TitleCode, title_code)
            WHERE person_id = @PersonId;
        END
        ELSE IF @PersonKind = 'LEGAL'
        BEGIN
            UPDATE LegalPerson
            SET incorporation_date = COALESCE(@IncorporationDate, incorporation_date),
                closing_date = COALESCE(@ClosingDate, closing_date),
                legal_form = COALESCE(@LegalForm, legal_form)
            WHERE person_id = @PersonId;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- =============================================================
-- 5. sp_Person_Delete - Soft delete (archive)
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Person_Delete
    @PersonId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate parameter
        IF @PersonId IS NULL
            THROW 52005, 'PersonId is required.', 1;

        -- Verify person exists
        IF NOT EXISTS (SELECT 1 FROM Person WHERE person_id = @PersonId)
            THROW 52006, 'Person not found.', 1;

        BEGIN TRANSACTION;

        -- Archive the person dossier instead of hard delete
        -- Soft delete: prefix dossier with ARCHIVED_ and set closing date for legal persons
        UPDATE Person
        SET dossier = 'ARCHIVED_' + COALESCE(dossier, CONVERT(NVARCHAR(36), person_id)),
            updated_at = SYSUTCDATETIME()
        WHERE person_id = @PersonId;

        -- Set closing date for legal persons
        UPDATE LegalPerson
        SET closing_date = COALESCE(closing_date, CAST(GETDATE() AS DATE))
        WHERE person_id = @PersonId;

        COMMIT TRANSACTION;

        -- Note: Hard delete would require cascade handling via triggers
        -- The archive approach preserves referential integrity
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- =============================================================
-- 6. sp_Institution_GetAll - List with filters
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Institution_GetAll
    @PageNumber     INT = 1,
    @PageSize       INT = 25,
    @Search         NVARCHAR(100) = NULL,
    @InstitutionRole NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    WITH FilteredInstitutions AS (
        SELECT
            i.institution_id,
            i.institution_code,
            i.name,
            i.created_at,
            i.updated_at,
            -- Primary address
            ia.street,
            ia.house_number,
            ia.postal_code,
            ia.city,
            ia.country_code
        FROM Institution i
        LEFT JOIN InstitutionAddress ia ON i.institution_id = ia.institution_id AND ia.is_primary = 1
        WHERE (@Search IS NULL
               OR i.name LIKE '%' + @Search + '%'
               OR i.institution_code LIKE '%' + @Search + '%'
               OR ia.city LIKE '%' + @Search + '%')
    )
    SELECT
        fi.*,
        (SELECT COUNT(*) FROM FilteredInstitutions) AS total_count
    FROM FilteredInstitutions fi
    ORDER BY fi.name
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- =============================================================
-- 7. sp_Institution_GetById - Full institution detail
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Institution_GetById
    @InstitutionId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    -- Main institution data
    SELECT
        i.institution_id,
        i.institution_code,
        i.name,
        i.created_at,
        i.updated_at
    FROM Institution i
    WHERE i.institution_id = @InstitutionId;

    -- Addresses
    SELECT
        ia.institution_address_id,
        ia.address_role_code,
        iar.label_nl AS address_role_label,
        ia.street,
        ia.house_number,
        ia.box,
        ia.postal_code,
        ia.city,
        ia.country,
        ia.country_code,
        ia.remark,
        ia.is_primary,
        ia.created_at
    FROM InstitutionAddress ia
    JOIN InstitutionAddressRole iar ON ia.address_role_code = iar.address_role_code
    WHERE ia.institution_id = @InstitutionId
    ORDER BY ia.is_primary DESC;

    -- Identifiers
    SELECT
        ii.id_type_code,
        iit.label_nl AS id_type_label,
        ii.id_value,
        ii.valid_from,
        ii.valid_to
    FROM InstitutionIdentifier ii
    JOIN InstitutionIdentifierType iit ON ii.id_type_code = iit.id_type_code
    WHERE ii.institution_id = @InstitutionId;
END;
GO

-- =============================================================
-- 8. sp_Object_GetAll - List by category with filters
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Object_GetAll
    @PageNumber     INT = 1,
    @PageSize       INT = 25,
    @CategoryCode   NVARCHAR(40) = NULL,    -- 'VEHICLE','REAL_ESTATE','PERSON','THING','ACTIVITY','LOAN'
    @Search         NVARCHAR(100) = NULL,
    @Status         NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    WITH FilteredObjects AS (
        SELECT
            o.object_id,
            o.object_type_id,
            ot.code AS object_type_code,
            ot.label AS object_type_label,
            o.description,
            o.status,
            o.start_date,
            o.end_date,
            o.created_at,
            o.updated_at,
            -- Category-specific info
            CASE
                WHEN ot.code = 'VEHICLE' THEN CONCAT(ov.brand, ' ', ov.model, ' (', ov.license_plate, ')')
                WHEN ot.code = 'REAL_ESTATE' THEN CONCAT(ore.street, ' ', ore.number, ', ', ore.postal_code, ' ', ore.city)
                WHEN ot.code = 'LOAN' THEN CONCAT('Lening EUR ', FORMAT(ol.principal_amount, 'N2'))
                WHEN ot.code = 'PERSON' THEN op.description
                WHEN ot.code = 'THING' THEN CONCAT(otg.brand, ' ', otg.model)
                WHEN ot.code = 'ACTIVITY' THEN oa.description
                ELSE o.description
            END AS category_detail
        FROM [Object] o
        JOIN ObjectType ot ON o.object_type_id = ot.object_type_id
        LEFT JOIN ObjectVehicle ov ON o.object_id = ov.object_id
        LEFT JOIN ObjectRealEstate ore ON o.object_id = ore.object_id
        LEFT JOIN ObjectLoan ol ON o.object_id = ol.object_id
        LEFT JOIN ObjectPerson op ON o.object_id = op.object_id
        LEFT JOIN ObjectThing otg ON o.object_id = otg.object_id
        LEFT JOIN ObjectActivity oa ON o.object_id = oa.object_id
        WHERE (@CategoryCode IS NULL OR ot.code = @CategoryCode)
          AND (@Status IS NULL OR o.status = @Status)
          AND (@Search IS NULL
               OR o.description LIKE '%' + @Search + '%'
               OR ov.brand LIKE '%' + @Search + '%'
               OR ov.model LIKE '%' + @Search + '%'
               OR ov.license_plate LIKE '%' + @Search + '%'
               OR ore.city LIKE '%' + @Search + '%')
    )
    SELECT
        fo.*,
        (SELECT COUNT(*) FROM FilteredObjects) AS total_count
    FROM FilteredObjects fo
    ORDER BY fo.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- =============================================================
-- 9. sp_Object_GetById - Full detail per category
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Object_GetById
    @ObjectId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    -- Base object data
    SELECT
        o.object_id,
        ot.code AS object_type_code,
        ot.label AS object_type_label,
        o.description,
        o.status,
        o.start_date,
        o.end_date,
        o.created_at,
        o.updated_at
    FROM [Object] o
    JOIN ObjectType ot ON o.object_type_id = ot.object_type_id
    WHERE o.object_id = @ObjectId;

    -- Category-specific data based on type
    DECLARE @TypeCode NVARCHAR(40);
    SELECT @TypeCode = ot.code
    FROM [Object] o
    JOIN ObjectType ot ON o.object_type_id = ot.object_type_id
    WHERE o.object_id = @ObjectId;

    IF @TypeCode = 'VEHICLE'
    BEGIN
        SELECT
            ov.*,
            vt.label_nl AS vehicle_type_label,
            ut.label_nl AS usage_type_label,
            lpt.label_nl AS plate_type_label,
            ft.label_nl AS fuel_type_label,
            dt.label_nl AS drive_type_label
        FROM ObjectVehicle ov
        LEFT JOIN VehicleType vt ON ov.vehicle_type_code = vt.vehicle_type_code
        LEFT JOIN UsageType ut ON ov.usage_type_code = ut.usage_type_code
        LEFT JOIN LicensePlateType lpt ON ov.plate_type_code = lpt.plate_type_code
        LEFT JOIN FuelType ft ON ov.fuel_type_code = ft.fuel_type_code
        LEFT JOIN DriveType dt ON ov.drive_type_code = dt.drive_type_code
        WHERE ov.object_id = @ObjectId;
    END
    ELSE IF @TypeCode = 'REAL_ESTATE'
    BEGIN
        SELECT
            ore.*,
            ret.label_nl AS realestate_type_label,
            utre.label_nl AS use_type_label,
            ir.label_nl AS insured_role_label,
            rt.label_nl AS residence_type_label,
            at.label_nl AS adjacency_type_label,
            olv.label_nl AS occupancy_level_label,
            ct.label_nl AS construction_type_label,
            rt2.label_nl AS roof_type_label
        FROM ObjectRealEstate ore
        LEFT JOIN RealEstateType ret ON ore.realestate_type_code = ret.realestate_type_code
        LEFT JOIN UseTypeRealEstate utre ON ore.use_type_code = utre.use_type_code
        LEFT JOIN InsuredRole ir ON ore.insured_role_code = ir.insured_role_code
        LEFT JOIN ResidenceType rt ON ore.residence_type_code = rt.residence_type_code
        LEFT JOIN AdjacencyType at ON ore.adjacency_type_code = at.adjacency_type_code
        LEFT JOIN OccupancyLevel olv ON ore.occupancy_level_code = olv.occupancy_level_code
        LEFT JOIN ConstructionType ct ON ore.construction_type_code = ct.construction_type_code
        LEFT JOIN RoofType rt2 ON ore.roof_type_code = rt2.roof_type_code
        WHERE ore.object_id = @ObjectId;

        -- Burglary protections
        SELECT
            bp.burglary_protection_type_code,
            bpt.label_nl
        FROM ObjectRealEstate_BurglaryProtection bp
        JOIN BurglaryProtectionType bpt ON bp.burglary_protection_type_code = bpt.burglary_protection_type_code
        WHERE bp.object_id = @ObjectId;
    END
    ELSE IF @TypeCode = 'LOAN'
    BEGIN
        SELECT
            ol.*,
            p.periodicity_label_nl,
            dt.label_nl AS duration_type_label
        FROM ObjectLoan ol
        LEFT JOIN Periodicity p ON ol.interest_periodicity_code = p.periodicity_code
        LEFT JOIN DurationType dt ON ol.duration_type_code = dt.duration_type_code
        WHERE ol.object_id = @ObjectId;
    END
    ELSE IF @TypeCode = 'PERSON'
    BEGIN
        SELECT
            op.*,
            ops.label_nl AS subtype_label,
            wrc.label_nl AS worker_risk_class_label,
            erc.label_nl AS employee_risk_class_label,
            ac.label_nl AS age_category_label
        FROM ObjectPerson op
        LEFT JOIN ObjectPersonSubtype ops ON op.subtype_code = ops.subtype_code
        LEFT JOIN WorkerRiskClass wrc ON op.worker_risk_class_code = wrc.worker_risk_class_code
        LEFT JOIN EmployeeRiskClass erc ON op.employee_risk_class_code = erc.employee_risk_class_code
        LEFT JOIN AgeCategory ac ON op.age_category_code = ac.age_category_code
        WHERE op.object_id = @ObjectId;
    END
    ELSE IF @TypeCode = 'THING'
    BEGIN
        SELECT
            ot.*,
            ots.label_nl AS subtype_label,
            trc.label_nl AS risk_category_label,
            tmt.label_nl AS material_type_label
        FROM ObjectThing ot
        LEFT JOIN ObjectThingSubtype ots ON ot.subtype_code = ots.subtype_code
        LEFT JOIN ThingRiskCategory trc ON ot.risk_category_code = trc.risk_category_code
        LEFT JOIN ThingMaterialType tmt ON ot.material_type_code = tmt.material_type_code
        WHERE ot.object_id = @ObjectId;
    END
    ELSE IF @TypeCode = 'ACTIVITY'
    BEGIN
        SELECT
            oa.*,
            oas.label_nl AS activity_type_label,
            ac.label_nl AS age_category_label,
            arl.label_nl AS risk_level_label
        FROM ObjectActivity oa
        LEFT JOIN ObjectActivitySubtype oas ON oa.activity_type_code = oas.activity_type_code
        LEFT JOIN AgeCategory ac ON oa.age_category_code = ac.age_category_code
        LEFT JOIN ActivityRiskLevel arl ON oa.risk_level_code = arl.risk_level_code
        WHERE oa.object_id = @ObjectId;
    END
END;
GO

-- =============================================================
-- 10. sp_Contract_GetAll - List with status filters
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Contract_GetAll
    @PageNumber     INT = 1,
    @PageSize       INT = 25,
    @Search         NVARCHAR(100) = NULL,
    @StatusCode     NVARCHAR(40) = NULL,
    @DomainCode     NVARCHAR(40) = NULL,
    @SortColumn     NVARCHAR(50) = 'start_date',
    @SortDirection  NVARCHAR(4) = 'DESC'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    WITH FilteredContracts AS (
        SELECT
            c.contract_id,
            c.contract_number,
            c.contract_domain_code,
            cd.label_nl AS domain_label,
            c.contract_type_code,
            ct.contract_type_name,
            c.contract_status_code,
            cs.status_label,
            c.company_id,
            i.name AS company_name,
            c.start_date,
            c.end_date,
            c.created_at,
            c.updated_at,
            -- Primary party (policyholder)
            pp.person_id AS policyholder_id,
            COALESCE(np.first_name + ' ' + np.last_name, lp.legal_form) AS policyholder_name
        FROM Contract c
        JOIN ContractDomain cd ON c.contract_domain_code = cd.contract_domain_code
        JOIN ContractType ct ON c.contract_type_code = ct.contract_type_code
        JOIN ContractStatus cs ON c.contract_status_code = cs.contract_status_code
        LEFT JOIN Institution i ON c.company_id = i.institution_id
        LEFT JOIN Contract_Party cpp ON c.contract_id = cpp.contract_id AND cpp.contract_party_role_code = 'POLICYHOLDER'
        LEFT JOIN Person pp ON cpp.person_id = pp.person_id
        LEFT JOIN NaturalPerson np ON pp.person_id = np.person_id
        LEFT JOIN LegalPerson lp ON pp.person_id = lp.person_id
        WHERE (@StatusCode IS NULL OR c.contract_status_code = @StatusCode)
          AND (@DomainCode IS NULL OR c.contract_domain_code = @DomainCode)
          AND (@Search IS NULL
               OR c.contract_number LIKE '%' + @Search + '%'
               OR COALESCE(np.first_name + ' ' + np.last_name, lp.legal_form) LIKE '%' + @Search + '%'
               OR i.name LIKE '%' + @Search + '%')
    )
    SELECT
        fc.*,
        (SELECT COUNT(*) FROM FilteredContracts) AS total_count
    FROM FilteredContracts fc
    ORDER BY
        CASE WHEN @SortColumn = 'start_date' AND @SortDirection = 'ASC' THEN fc.start_date END ASC,
        CASE WHEN @SortColumn = 'start_date' AND @SortDirection = 'DESC' THEN fc.start_date END DESC,
        CASE WHEN @SortColumn = 'contract_number' AND @SortDirection = 'ASC' THEN fc.contract_number END ASC,
        CASE WHEN @SortColumn = 'contract_number' AND @SortDirection = 'DESC' THEN fc.contract_number END DESC,
        CASE WHEN @SortColumn = 'created_at' AND @SortDirection = 'ASC' THEN fc.created_at END ASC,
        CASE WHEN @SortColumn = 'created_at' AND @SortDirection = 'DESC' THEN fc.created_at END DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- =============================================================
-- 11. sp_Contract_GetById - Full with parties, objects, versions
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Contract_GetById
    @ContractId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    -- Main contract data
    SELECT
        c.contract_id,
        c.contract_number,
        c.contract_domain_code,
        cd.label_nl AS domain_label,
        c.contract_type_code,
        ct.contract_type_name,
        c.contract_status_code,
        cs.status_label,
        c.company_id,
        i.name AS company_name,
        c.handling_company_id,
        hi.name AS handling_company_name,
        c.start_date,
        c.end_date,
        c.created_at,
        c.updated_at
    FROM Contract c
    JOIN ContractDomain cd ON c.contract_domain_code = cd.contract_domain_code
    JOIN ContractType ct ON c.contract_type_code = ct.contract_type_code
    JOIN ContractStatus cs ON c.contract_status_code = cs.contract_status_code
    LEFT JOIN Institution i ON c.company_id = i.institution_id
    LEFT JOIN Institution hi ON c.handling_company_id = hi.institution_id
    WHERE c.contract_id = @ContractId;

    -- Contract versions
    SELECT
        cv.contract_version_id,
        cv.version_no,
        cv.effective_from,
        cv.effective_to,
        cvs.status_label AS version_status,
        cvs.status_code AS version_status_code,
        cv.duration_type_code,
        dt.label_nl AS duration_type_label,
        cv.periodicity_code,
        p.periodicity_label_nl,
        cv.collection_method_code,
        cm.collection_method_label_nl,
        cv.coinsurance_participation_pct,
        cv.company_endorsement_number,
        cv.initial_start_date,
        cv.created_at
    FROM ContractVersion cv
    JOIN ContractVersionStatus cvs ON cv.status_code = cvs.status_code
    LEFT JOIN DurationType dt ON cv.duration_type_code = dt.duration_type_code
    LEFT JOIN Periodicity p ON cv.periodicity_code = p.periodicity_code
    LEFT JOIN CollectionMethod cm ON cv.collection_method_code = cm.collection_method_code
    WHERE cv.contract_id = @ContractId
    ORDER BY cv.version_no DESC;

    -- Contract parties
    SELECT
        cp.person_id,
        cp.contract_party_role_code,
        cpr.role_label,
        cp.is_primary,
        cp.created_at,
        COALESCE(np.first_name + ' ' + np.last_name, lp.legal_form) AS person_name,
        p.person_kind
    FROM Contract_Party cp
    JOIN ContractPartyRole cpr ON cp.contract_party_role_code = cpr.contract_party_role_code
    JOIN Person p ON cp.person_id = p.person_id
    LEFT JOIN NaturalPerson np ON p.person_id = np.person_id
    LEFT JOIN LegalPerson lp ON p.person_id = lp.person_id
    WHERE cp.contract_id = @ContractId;

    -- Contract objects
    SELECT
        co.object_id,
        o.description,
        ot.code AS object_type_code,
        ot.label AS object_type_label,
        co.contract_object_status_code,
        cos.status_label AS object_status_label,
        co.is_primary,
        co.to_date,
        co.created_at
    FROM Contract_Object co
    JOIN [Object] o ON co.object_id = o.object_id
    JOIN ObjectType ot ON o.object_type_id = ot.object_type_id
    JOIN ContractObjectStatus cos ON co.contract_object_status_code = cos.contract_object_status_code
    WHERE co.contract_id = @ContractId;

    -- Takeover info (if any)
    SELECT
        ct.takeover_direction_code,
        td.label_nl AS direction_label,
        ct.takeover_source_type_code,
        tst.label_nl AS source_type_label,
        ct.other_institution_id,
        oi.name AS other_institution_name,
        ct.other_policy_number,
        ct.other_policy_start_date,
        ct.other_policy_end_date
    FROM ContractTakeover ct
    LEFT JOIN TakeoverDirection td ON ct.takeover_direction_code = td.takeover_direction_code
    LEFT JOIN TakeoverSourceType tst ON ct.takeover_source_type_code = tst.takeover_source_type_code
    LEFT JOIN Institution oi ON ct.other_institution_id = oi.institution_id
    WHERE ct.contract_version_id IN (
        SELECT contract_version_id FROM ContractVersion WHERE contract_id = @ContractId
    );
END;
GO

-- =============================================================
-- 12. sp_Claim_GetAll - List with urgency (>45 days open = urgent)
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Claim_GetAll
    @PageNumber     INT = 1,
    @PageSize       INT = 25,
    @Search         NVARCHAR(100) = NULL,
    @StatusCode     NVARCHAR(40) = NULL,
    @UrgentOnly     BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    WITH FilteredClaims AS (
        SELECT
            cl.claim_id,
            cl.claim_number,
            cl.contract_id,
            c.contract_number,
            cl.coverage_code,
            lc.label_nl AS coverage_label,
            cl.claim_status_code,
            cs.status_label,
            cl.incident_date,
            cl.reported_date,
            cl.closed_date,
            cl.paid_amount,
            cl.payment_method_code,
            cl.description,
            cl.created_at,
            cl.updated_at,
            -- Urgency calculation
            CASE
                WHEN cl.claim_status_code <> 'AFGEHANDELD'
                     AND DATEDIFF(DAY, COALESCE(cl.incident_date, cl.reported_date), GETDATE()) > 45
                THEN 1 ELSE 0
            END AS is_urgent,
            DATEDIFF(DAY, COALESCE(cl.incident_date, cl.reported_date), GETDATE()) AS days_open,
            -- Claimant name
            COALESCE(np.first_name + ' ' + np.last_name, lp.legal_form) AS claimant_name
        FROM Claim cl
        JOIN Contract c ON cl.contract_id = c.contract_id
        JOIN lookup_coverage lc ON cl.coverage_code = lc.coverage_code
        JOIN ClaimStatus cs ON cl.claim_status_code = cs.claim_status_code
        LEFT JOIN Claim_Party cp ON cl.claim_id = cp.claim_id AND cp.claim_party_role_code = 'CLAIMANT'
        LEFT JOIN Person p ON cp.person_id = p.person_id
        LEFT JOIN NaturalPerson np ON p.person_id = np.person_id
        LEFT JOIN LegalPerson lp ON p.person_id = lp.person_id
        WHERE (@StatusCode IS NULL OR cl.claim_status_code = @StatusCode)
          AND (@Search IS NULL
               OR cl.claim_number LIKE '%' + @Search + '%'
               OR c.contract_number LIKE '%' + @Search + '%'
               OR COALESCE(np.first_name + ' ' + np.last_name, lp.legal_form) LIKE '%' + @Search + '%')
    )
    SELECT
        fc.*,
        (SELECT COUNT(*) FROM FilteredClaims
         WHERE @UrgentOnly = 0 OR is_urgent = 1) AS total_count
    FROM FilteredClaims fc
    WHERE @UrgentOnly = 0 OR fc.is_urgent = 1
    ORDER BY fc.is_urgent DESC, fc.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- =============================================================
-- 13. sp_Claim_GetById - Full with timeline
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Claim_GetById
    @ClaimId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    -- Main claim data
    SELECT
        cl.claim_id,
        cl.claim_number,
        cl.contract_id,
        c.contract_number,
        cl.coverage_code,
        lc.label_nl AS coverage_label,
        cl.claim_status_code,
        cs.status_label,
        cl.claims_handler_id,
        COALESCE(hnp.first_name + ' ' + hnp.last_name, hlp.legal_form) AS handler_name,
        cl.incident_date,
        cl.reported_date,
        cl.closed_date,
        cl.description,
        cl.paid_amount,
        cl.payment_method_code,
        cpm.method_label AS payment_method_label,
        cl.created_at,
        cl.updated_at
    FROM Claim cl
    JOIN Contract c ON cl.contract_id = c.contract_id
    JOIN lookup_coverage lc ON cl.coverage_code = lc.coverage_code
    JOIN ClaimStatus cs ON cl.claim_status_code = cs.claim_status_code
    LEFT JOIN Person hp ON cl.claims_handler_id = hp.person_id
    LEFT JOIN NaturalPerson hnp ON hp.person_id = hnp.person_id
    LEFT JOIN LegalPerson hlp ON hp.person_id = hlp.person_id
    LEFT JOIN ClaimPaymentMethod cpm ON cl.payment_method_code = cpm.payment_method_code
    WHERE cl.claim_id = @ClaimId;

    -- Claim parties
    SELECT
        cp.person_id,
        cp.claim_party_role_code,
        cpr.role_label,
        cp.is_primary,
        COALESCE(np.first_name + ' ' + np.last_name, lp.legal_form) AS person_name
    FROM Claim_Party cp
    JOIN ClaimPartyRole cpr ON cp.claim_party_role_code = cpr.claim_party_role_code
    LEFT JOIN Person p ON cp.person_id = p.person_id
    LEFT JOIN NaturalPerson np ON p.person_id = np.person_id
    LEFT JOIN LegalPerson lp ON p.person_id = lp.person_id
    WHERE cp.claim_id = @ClaimId;

    -- Claim objects
    SELECT
        co.object_id,
        o.description,
        ot.label AS object_type_label,
        co.is_primary
    FROM Claim_Object co
    JOIN [Object] o ON co.object_id = o.object_id
    JOIN ObjectType ot ON o.object_type_id = ot.object_type_id
    WHERE co.claim_id = @ClaimId;

    -- Claim circumstances
    SELECT
        cc.claim_circumstance_type_code,
        cct.circumstance_label,
        cc.is_primary
    FROM Claim_Circumstance cc
    JOIN ClaimCircumstanceType cct ON cc.claim_circumstance_type_code = cct.circumstance_code
    WHERE cc.claim_id = @ClaimId;

    -- Timeline (status progression simulation)
    SELECT
        claim_status_code AS status_code,
        CASE claim_status_code
            WHEN 'INGEDIEND' THEN 'Claim ingediend'
            WHEN 'IN_BEHANDELING' THEN 'In behandeling genomen'
            WHEN 'AFGEHANDELD' THEN 'Claim afgehandeld'
            WHEN 'GEWEIGERD' THEN 'Claim geweigerd'
        END AS status_event,
        CASE claim_status_code
            WHEN 'INGEDIEND' THEN created_at
            WHEN 'IN_BEHANDELING' THEN DATEADD(DAY, 1, created_at)
            WHEN 'AFGEHANDELD' THEN closed_date
            WHEN 'GEWEIGERD' THEN DATEADD(DAY, 7, created_at)
        END AS event_date
    FROM Claim
    WHERE claim_id = @ClaimId;
END;
GO

-- =============================================================
-- 14. sp_Dashboard_GetStats - All KPIs in one call
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Dashboard_GetStats
AS
BEGIN
    SET NOCOUNT ON;

    -- Person counts
    SELECT
        COUNT(*) AS total_persons,
        COUNT(CASE WHEN person_kind = 'NATURAL' THEN 1 END) AS natural_persons,
        COUNT(CASE WHEN person_kind = 'LEGAL' THEN 1 END) AS legal_persons,
        COUNT(CASE WHEN updated_at > DATEADD(DAY, -30, SYSUTCDATETIME()) THEN 1 END) AS new_this_month
    FROM Person;

    -- Contract counts
    SELECT
        COUNT(*) AS total_contracts,
        COUNT(CASE WHEN contract_status_code = 'LOPEND' THEN 1 END) AS active_contracts,
        COUNT(CASE WHEN contract_status_code = 'OPGEZEGD' THEN 1 END) AS terminated_contracts,
        COUNT(CASE WHEN end_date IS NOT NULL AND end_date <= DATEADD(DAY, 90, CAST(GETDATE() AS DATE)) 
                   AND end_date >= CAST(GETDATE() AS DATE) AND contract_status_code = 'LOPEND' 
              THEN 1 END) AS expiring_soon
    FROM Contract;

    -- Claim counts
    SELECT
        COUNT(*) AS total_claims,
        COUNT(CASE WHEN claim_status_code = 'INGEDIEND' THEN 1 END) AS submitted_claims,
        COUNT(CASE WHEN claim_status_code = 'IN_BEHANDELING' THEN 1 END) AS open_claims,
        COUNT(CASE WHEN claim_status_code = 'AFGEHANDELD' THEN 1 END) AS resolved_claims,
        COUNT(CASE WHEN claim_status_code <> 'AFGEHANDELD' 
                        AND DATEDIFF(DAY, COALESCE(incident_date, reported_date), GETDATE()) > 45 
                   THEN 1 END) AS urgent_claims,
        ISNULL(SUM(paid_amount), 0) AS total_paid
    FROM Claim;

    -- Object counts
    SELECT
        COUNT(*) AS total_objects,
        COUNT(CASE WHEN ot.code = 'VEHICLE' THEN 1 END) AS vehicle_count,
        COUNT(CASE WHEN ot.code = 'REAL_ESTATE' THEN 1 END) AS real_estate_count,
        COUNT(CASE WHEN ot.code = 'LOAN' THEN 1 END) AS loan_count
    FROM [Object] o
    JOIN ObjectType ot ON o.object_type_id = ot.object_type_id;

    -- Institution count
    SELECT COUNT(*) AS total_institutions FROM Institution;
END;
GO

-- =============================================================
-- 15. sp_Dashboard_GetCharts - Chart data (line, bar, donut)
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Dashboard_GetCharts
    @Months INT = 12
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate parameter
    IF @Months IS NULL OR @Months < 1 OR @Months > 120
        SET @Months = 12;

    -- Line chart: Contracts per month
    SELECT
        FORMAT(c.start_date, 'yyyy-MM') AS month_period,
        COUNT(*) AS contract_count,
        cd.label_nl AS domain_label
    FROM Contract c
    JOIN ContractDomain cd ON c.contract_domain_code = cd.contract_domain_code
    WHERE c.start_date >= DATEADD(MONTH, -@Months, CAST(GETDATE() AS DATE))
    GROUP BY FORMAT(c.start_date, 'yyyy-MM'), cd.label_nl
    ORDER BY month_period, domain_label;

    -- Bar chart: Claims per month by status
    SELECT
        FORMAT(cl.reported_date, 'yyyy-MM') AS month_period,
        cl.claim_status_code,
        cs.status_label,
        COUNT(*) AS claim_count
    FROM Claim cl
    JOIN ClaimStatus cs ON cl.claim_status_code = cs.claim_status_code
    WHERE cl.reported_date >= DATEADD(MONTH, -@Months, CAST(GETDATE() AS DATE))
    GROUP BY FORMAT(cl.reported_date, 'yyyy-MM'), cl.claim_status_code, cs.status_label
    ORDER BY month_period;

    -- Donut chart: Contracts by status
    SELECT
        c.contract_status_code,
        cs.status_label,
        COUNT(*) AS status_count,
        CAST(ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 1) AS DECIMAL(5,1)) AS percentage
    FROM Contract c
    JOIN ContractStatus cs ON c.contract_status_code = cs.contract_status_code
    GROUP BY c.contract_status_code, cs.status_label;

    -- Donut chart: Claims by coverage type (top 10)
    SELECT TOP 10
        cl.coverage_code,
        lc.label_nl AS coverage_label,
        COUNT(*) AS coverage_count
    FROM Claim cl
    JOIN lookup_coverage lc ON cl.coverage_code = lc.coverage_code
    GROUP BY cl.coverage_code, lc.label_nl
    ORDER BY coverage_count DESC;

    -- Line chart: Claims paid amount per month
    SELECT
        FORMAT(cl.reported_date, 'yyyy-MM') AS month_period,
        ISNULL(SUM(cl.paid_amount), 0) AS total_paid
    FROM Claim cl
    WHERE cl.reported_date >= DATEADD(MONTH, -@Months, CAST(GETDATE() AS DATE))
    GROUP BY FORMAT(cl.reported_date, 'yyyy-MM')
    ORDER BY month_period;
END;
GO

-- =============================================================
-- 16. sp_Rapporten_Commissions - Commission report data
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Rapporten_Commissions
    @StartDate  DATE = NULL,
    @EndDate    DATE = NULL,
    @CompanyId  UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @StartDate = COALESCE(@StartDate, DATEADD(MONTH, -12, CAST(GETDATE() AS DATE)));
        SET @EndDate = COALESCE(@EndDate, CAST(GETDATE() AS DATE));

        -- Commission summary by company (estimated at 10% of contract value)
    SELECT
        i.institution_id AS company_id,
        i.name AS company_name,
        COUNT(DISTINCT c.contract_id) AS contract_count,
        COUNT(DISTINCT cv.contract_version_id) AS version_count,
        COUNT(DISTINCT cl.claim_id) AS claim_count,
        ISNULL(SUM(cl.paid_amount), 0) AS total_claims_paid,
        -- Estimated premium: 5% of a fictitious insured value based on object counts
        COUNT(DISTINCT co.object_id) * 500 AS estimated_total_premium,
        -- Estimated commission at 10%
        COUNT(DISTINCT co.object_id) * 50 AS estimated_commission
    FROM Institution i
    LEFT JOIN Contract c ON i.institution_id = c.company_id
        AND c.start_date BETWEEN @StartDate AND @EndDate
    LEFT JOIN ContractVersion cv ON c.contract_id = cv.contract_id
    LEFT JOIN Contract_Object co ON c.contract_id = co.contract_id
    LEFT JOIN Claim cl ON c.contract_id = cl.contract_id
    WHERE (@CompanyId IS NULL OR i.institution_id = @CompanyId)
    GROUP BY i.institution_id, i.name
    HAVING COUNT(DISTINCT c.contract_id) > 0
    ORDER BY estimated_commission DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- =============================================================
-- 17. sp_Rapporten_Contracts - Contract analytics
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Rapporten_Contracts
    @StartDate  DATE = NULL,
    @EndDate    DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @StartDate = COALESCE(@StartDate, DATEADD(MONTH, -12, CAST(GETDATE() AS DATE)));
        SET @EndDate = COALESCE(@EndDate, CAST(GETDATE() AS DATE));

        -- Summary statistics
    SELECT
        COUNT(*) AS total_contracts,
        COUNT(CASE WHEN contract_status_code = 'LOPEND' THEN 1 END) AS active_contracts,
        COUNT(CASE WHEN contract_status_code = 'OPGEZEGD' THEN 1 END) AS terminated_contracts,
        COUNT(CASE WHEN start_date BETWEEN @StartDate AND @EndDate THEN 1 END) AS new_contracts,
        COUNT(CASE WHEN end_date BETWEEN @StartDate AND @EndDate THEN 1 END) AS expired_contracts
    FROM Contract;

    -- By domain
    SELECT
        c.contract_domain_code,
        cd.label_nl AS domain_label,
        COUNT(*) AS contract_count,
        COUNT(CASE WHEN c.contract_status_code = 'LOPEND' THEN 1 END) AS active_count
    FROM Contract c
    JOIN ContractDomain cd ON c.contract_domain_code = cd.contract_domain_code
    WHERE c.start_date BETWEEN @StartDate AND @EndDate
       OR c.end_date BETWEEN @StartDate AND @EndDate
       OR c.contract_status_code = 'LOPEND'
    GROUP BY c.contract_domain_code, cd.label_nl
    ORDER BY contract_count DESC;

    -- By type
    SELECT
        c.contract_type_code,
        ct.contract_type_name,
        COUNT(*) AS type_count
    FROM Contract c
    JOIN ContractType ct ON c.contract_type_code = ct.contract_type_code
    GROUP BY c.contract_type_code, ct.contract_type_name
    ORDER BY type_count DESC;

    -- Monthly trend
    SELECT
        FORMAT(c.start_date, 'yyyy-MM') AS month_period,
        COUNT(*) AS contracts_started
    FROM Contract c
    WHERE c.start_date >= DATEADD(MONTH, -24, CAST(GETDATE() AS DATE))
    GROUP BY FORMAT(c.start_date, 'yyyy-MM')
    ORDER BY month_period;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- =============================================================
-- 18. sp_Rapporten_Claims - Claims analytics with monthly breakdown
-- =============================================================
CREATE OR ALTER PROCEDURE sp_Rapporten_Claims
    @StartDate  DATE = NULL,
    @EndDate    DATE = NULL,
    @StatusCode NVARCHAR(40) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @StartDate = COALESCE(@StartDate, DATEADD(MONTH, -12, CAST(GETDATE() AS DATE)));
        SET @EndDate = COALESCE(@EndDate, CAST(GETDATE() AS DATE));

        -- Summary statistics
    SELECT
        COUNT(*) AS total_claims,
        COUNT(CASE WHEN claim_status_code = 'INGEDIEND' THEN 1 END) AS submitted_count,
        COUNT(CASE WHEN claim_status_code = 'IN_BEHANDELING' THEN 1 END) AS in_progress_count,
        COUNT(CASE WHEN claim_status_code = 'AFGEHANDELD' THEN 1 END) AS resolved_count,
        COUNT(CASE WHEN claim_status_code = 'GEWEIGERD' THEN 1 END) AS rejected_count,
        ISNULL(SUM(paid_amount), 0) AS total_paid,
        AVG(CASE WHEN claim_status_code = 'AFGEHANDELD' 
                 THEN DATEDIFF(DAY, reported_date, closed_date) END) AS avg_resolution_days
    FROM Claim
    WHERE reported_date BETWEEN @StartDate AND @EndDate
      AND (@StatusCode IS NULL OR claim_status_code = @StatusCode);

    -- Monthly breakdown
    SELECT
        FORMAT(reported_date, 'yyyy-MM') AS month_period,
        COUNT(*) AS claim_count,
        COUNT(CASE WHEN claim_status_code = 'AFGEHANDELD' THEN 1 END) AS resolved_count,
        COUNT(CASE WHEN claim_status_code = 'GEWEIGERD' THEN 1 END) AS rejected_count,
        ISNULL(SUM(paid_amount), 0) AS total_paid,
        AVG(CASE WHEN claim_status_code = 'AFGEHANDELD' 
                 THEN DATEDIFF(DAY, reported_date, closed_date) END) AS avg_resolution_days
    FROM Claim
    WHERE reported_date BETWEEN @StartDate AND @EndDate
      AND (@StatusCode IS NULL OR claim_status_code = @StatusCode)
    GROUP BY FORMAT(reported_date, 'yyyy-MM')
    ORDER BY month_period;

    -- By coverage type
    SELECT
        cl.coverage_code,
        lc.label_nl AS coverage_label,
        COUNT(*) AS coverage_count,
        ISNULL(SUM(cl.paid_amount), 0) AS total_paid
    FROM Claim cl
    JOIN lookup_coverage lc ON cl.coverage_code = lc.coverage_code
    WHERE cl.reported_date BETWEEN @StartDate AND @EndDate
      AND (@StatusCode IS NULL OR cl.claim_status_code = @StatusCode)
    GROUP BY cl.coverage_code, lc.label_nl
    ORDER BY coverage_count DESC;

    -- By claim status
    SELECT
        claim_status_code,
        cs.status_label,
        COUNT(*) AS status_count,
        ISNULL(SUM(paid_amount), 0) AS total_paid,
        AVG(CASE WHEN closed_date IS NOT NULL 
                 THEN DATEDIFF(DAY, reported_date, closed_date) END) AS avg_days_to_resolve
    FROM Claim c
    JOIN ClaimStatus cs ON c.claim_status_code = cs.claim_status_code
    WHERE c.reported_date BETWEEN @StartDate AND @EndDate
    GROUP BY claim_status_code, cs.status_label
    ORDER BY status_count DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '';
PRINT '======================================================';
PRINT ' All stored procedures created successfully!';
PRINT ' (18 procedures created)';
PRINT '======================================================';
GO
