# Data Dictionary

This dictionary documents the validated SQL Server schema. Classification values:
`public`, `internal`, `confidential`, `personal_data`, `financial_data`,
`security_sensitive`.

Most lookup tables use the standard pattern: code primary key, Dutch/French/
English/Turkish label columns when present, `is_active`, and `sort_order`.
Domain-specific operational tables are documented below at column level.

## core.Tenant

Purpose: tenant identity and default settings.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| tenant_id | UNIQUEIDENTIFIER | No | NEWSEQUENTIALID() | PK | Referenced by tenant-aware roots | Tenant surrogate id | internal |
| tenant_code | NVARCHAR(80) | No | none | UQ | UQ_Tenant_tenant_code | Stable tenant code | internal |
| legal_name | NVARCHAR(200) | No | none |  | Legal display | Registered tenant name | confidential |
| display_name | NVARCHAR(200) | No | none |  | UI display | Broker/tenant label | internal |
| vat_number | NVARCHAR(30) | Yes | none |  | Business identifier | VAT number | confidential |
| country_code | CHAR(2) | No | 'BE' |  | ISO country | Tenant country | internal |
| default_language | CHAR(2) | No | 'nl' |  | FK-like language code | Default UI language | internal |
| is_active | BIT | No | 1 |  | Active flag | Tenant availability | internal |
| created_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  | Audit timestamp | Creation time | internal |
| updated_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  | Audit timestamp | Last update time | internal |

## core.AppUser

Purpose: tenant-scoped application users.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| user_id | UNIQUEIDENTIFIER | No | NEWSEQUENTIALID() | PK |  | User id | internal |
| tenant_id | UNIQUEIDENTIFIER | No | none | FK | FK_AppUser_Tenant, UQ tenant/email | Owning tenant | internal |
| email | NVARCHAR(320) | No | none | UQ | Unique per tenant | Login/contact email | personal_data |
| display_name | NVARCHAR(160) | No | none |  |  | UI name | personal_data |
| person_id | UNIQUEIDENTIFIER | Yes | none | FK | FK_AppUser_Person | Linked person | personal_data |
| auth_provider | NVARCHAR(40) | No | 'local' |  |  | Identity provider | security_sensitive |
| external_subject_id | NVARCHAR(200) | Yes | none |  |  | External identity id | security_sensitive |
| is_active | BIT | No | 1 |  |  | Login enabled | security_sensitive |
| last_login_at_utc | DATETIME2(0) | Yes | none |  |  | Last login time | security_sensitive |
| created_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Creation time | internal |
| updated_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Last update time | internal |

## person.Person

Purpose: tenant-aware root for natural and legal persons.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| person_id | UNIQUEIDENTIFIER | No | NEWSEQUENTIALID() | PK |  | Person id | personal_data |
| tenant_id | UNIQUEIDENTIFIER | No | none | FK | FK_Person_Tenant | Owning tenant | internal |
| person_kind | NVARCHAR(10) | No | none | CK | NATURAL or LEGAL | Subtype discriminator | personal_data |
| dossier | NVARCHAR(50) | Yes | none | UQ filtered | UQ_Person_tenant_dossier | Broker dossier number | confidential |
| language_code | CHAR(2) | Yes | none | FK | FK_Person_Language | Preferred language | personal_data |
| nationality | NVARCHAR(80) | Yes | none |  |  | Nationality | personal_data |
| subagent_person_id | UNIQUEIDENTIFIER | Yes | none | FK | Self FK | Subagent person | confidential |
| manager_person_id | UNIQUEIDENTIFIER | Yes | none | FK | Self FK | Manager person | confidential |
| portfolio_person_id | UNIQUEIDENTIFIER | Yes | none | FK | Self FK | Portfolio owner | confidential |
| created_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Creation time | internal |
| updated_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Last update time | internal |
| created_by_user_id | UNIQUEIDENTIFIER | Yes | none | FK | FK_Person_AppUser_CreatedBy | Creator user | security_sensitive |
| updated_by_user_id | UNIQUEIDENTIFIER | Yes | none | FK | FK_Person_AppUser_UpdatedBy | Last updater | security_sensitive |
| is_deleted | BIT | No | 0 |  | Soft delete | Deleted marker | internal |

## person.NaturalPerson

Purpose: natural person subtype.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| person_id | UNIQUEIDENTIFIER | No | none | PK/FK | FK_NaturalPerson_Person | Root person | personal_data |
| first_name | NVARCHAR(100) | Yes | none |  |  | First name | personal_data |
| last_name | NVARCHAR(100) | Yes | none |  | IX_NaturalPerson_name | Last name | personal_data |
| birth_date | DATE | Yes | none |  | Lifespan check | Birth date | personal_data |
| birth_place | NVARCHAR(120) | Yes | none |  |  | Birth place | personal_data |
| death_date | DATE | Yes | none |  | death >= birth | Death date | personal_data |
| gender | NVARCHAR(20) | Yes | none |  |  | Gender | personal_data |
| marital_status | NVARCHAR(50) | Yes | none |  |  | Marital status | personal_data |
| national_number | NVARCHAR(30) | Yes | none |  | Sensitive identifier | National id | personal_data |
| passport_number | NVARCHAR(30) | Yes | none |  | Sensitive identifier | Passport id | personal_data |
| id_card_number | NVARCHAR(30) | Yes | none |  | Sensitive identifier | ID card number | personal_data |
| id_card_valid_from | DATE | Yes | none |  | Date range check | ID validity start | personal_data |
| id_card_valid_to | DATE | Yes | none |  | Date range check | ID validity end | personal_data |
| title_code | NVARCHAR(10) | Yes | none | FK | FK_NaturalPerson_Title | Person title | personal_data |
| created_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Creation time | internal |
| updated_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Last update time | internal |
| created_by_user_id | UNIQUEIDENTIFIER | Yes | none | FK |  | Creator user | security_sensitive |
| updated_by_user_id | UNIQUEIDENTIFIER | Yes | none | FK |  | Last updater | security_sensitive |
| is_deleted | BIT | No | 0 |  | Soft delete | Deleted marker | internal |

## person.LegalPerson

Purpose: legal entity subtype modeled as a person.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| person_id | UNIQUEIDENTIFIER | No | none | PK/FK | FK_LegalPerson_Person | Root person | confidential |
| incorporation_date | DATE | Yes | none |  | closing >= incorporation | Incorporation date | confidential |
| closing_date | DATE | Yes | none |  | closing >= incorporation | Closing date | confidential |
| legal_form | NVARCHAR(120) | Yes | none |  |  | Legal form | confidential |
| created_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Creation time | internal |
| updated_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Last update time | internal |
| created_by_user_id | UNIQUEIDENTIFIER | Yes | none | FK |  | Creator user | security_sensitive |
| updated_by_user_id | UNIQUEIDENTIFIER | Yes | none | FK |  | Last updater | security_sensitive |
| is_deleted | BIT | No | 0 |  | Soft delete | Deleted marker | internal |

## institution.Institution

Purpose: insurers, brokers, banks, leasing firms, and partners.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| institution_id | UNIQUEIDENTIFIER | No | NEWSEQUENTIALID() | PK |  | Institution id | internal |
| tenant_id | UNIQUEIDENTIFIER | No | none | FK/UQ | UQ_Institution_tenant_code | Owning tenant | internal |
| institution_code | NVARCHAR(80) | No | none | UQ | Unique per tenant | Institution code | internal |
| name | NVARCHAR(200) | No | none |  | IX_Institution_name | Common name | confidential |
| legal_name | NVARCHAR(200) | Yes | none |  |  | Legal name | confidential |
| vat_number | NVARCHAR(30) | Yes | none |  |  | VAT number | confidential |
| country_code | CHAR(2) | No | 'BE' |  |  | Country | internal |
| is_active | BIT | No | 1 |  |  | Active flag | internal |
| created_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Creation time | internal |
| updated_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Last update time | internal |
| created_by_user_id | UNIQUEIDENTIFIER | Yes | none | FK |  | Creator user | security_sensitive |
| updated_by_user_id | UNIQUEIDENTIFIER | Yes | none | FK |  | Last updater | security_sensitive |
| is_deleted | BIT | No | 0 |  | Soft delete | Deleted marker | internal |

## risk.InsurableObject

Purpose: tenant-aware root for all insurable risks.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| insurable_object_id | UNIQUEIDENTIFIER | No | NEWSEQUENTIALID() | PK |  | Risk id | internal |
| tenant_id | UNIQUEIDENTIFIER | No | none | FK | FK_InsurableObject_Tenant | Owning tenant | internal |
| object_type_code | NVARCHAR(40) | No | none | FK | FK_InsurableObject_InsurableObjectType | Risk subtype | internal |
| description | NVARCHAR(255) | No | none |  |  | Risk label | confidential |
| status_code | NVARCHAR(30) | No | none |  | Validated values | Risk status | internal |
| start_date | DATE | No | none |  | Date range check | Risk start | internal |
| end_date | DATE | Yes | none |  | end >= start | Risk end | internal |
| created_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Creation time | internal |
| updated_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Last update time | internal |
| created_by_user_id | UNIQUEIDENTIFIER | Yes | none | FK |  | Creator user | security_sensitive |
| updated_by_user_id | UNIQUEIDENTIFIER | Yes | none | FK |  | Last updater | security_sensitive |
| is_deleted | BIT | No | 0 |  | Soft delete | Deleted marker | internal |

## risk.InsurableVehicle

Purpose: vehicle-specific risk attributes.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| insurable_object_id | UNIQUEIDENTIFIER | No | none | PK/FK | FK_InsurableVehicle_InsurableObject | Root risk | internal |
| vehicle_type_code | NVARCHAR(60) | No | none | FK |  | Vehicle type | internal |
| usage_type_code | NVARCHAR(40) | No | none | FK |  | Vehicle usage | internal |
| plate_type_code | NVARCHAR(40) | No | none | FK |  | Plate type | internal |
| brand | NVARCHAR(100) | No | none |  |  | Brand | confidential |
| model | NVARCHAR(100) | No | none |  |  | Model | confidential |
| chassis_number | NVARCHAR(40) | No | none |  | IX_InsurableVehicle_chassis | VIN/chassis | confidential |
| build_year | INT | No | none | CK | >= 1886, sane range validation | Build year | internal |
| first_commissioning_date | DATE | No | none |  | <= registration validation | First use date | internal |
| registration_date | DATE | No | none |  | >= commissioning validation | Registration date | internal |
| license_plate | NVARCHAR(20) | No | none |  | IX_InsurableVehicle_plate | Plate number | confidential |
| fuel_type_code | NVARCHAR(40) | Yes | none | FK |  | Fuel type | internal |
| drive_type_code | NVARCHAR(20) | Yes | none | FK |  | Drive type | internal |
| finance_institution_id | UNIQUEIDENTIFIER | Yes | none | FK | Required when financed | Finance institution | financial_data |
| is_financed | BIT | No | 0 | CK | Financing consistency | Is financed | financial_data |
| insured_value_ex_vat | DECIMAL(18,2) | Yes | none |  |  | Value excl VAT | financial_data |
| insured_value_inc_vat | DECIMAL(18,2) | Yes | none |  |  | Value incl VAT | financial_data |
| catalog_value_ex_vat | DECIMAL(18,2) | Yes | none |  |  | Catalog value excl VAT | financial_data |
| catalog_value_inc_vat | DECIMAL(18,2) | Yes | none |  |  | Catalog value incl VAT | financial_data |
| vat_exemption_pct | DECIMAL(5,2) | Yes | none | CK | Percent semantics | VAT exemption | financial_data |
| accessories_value | DECIMAL(18,2) | Yes | none |  |  | Accessories value | financial_data |
| pvg_number | NVARCHAR(40) | Yes | none |  |  | PVG number | confidential |
| eu_pvg_number | NVARCHAR(40) | Yes | none |  |  | EU PVG number | confidential |
| adr_code | NVARCHAR(40) | Yes | none |  |  | ADR code | internal |
| engine_cc | INT | Yes | none |  |  | Engine displacement | internal |
| power_kw | INT | Yes | none |  |  | Power kW | internal |
| power_hp | INT | Yes | none |  |  | Power HP | internal |
| plate_cancellation_date | DATE | Yes | none |  |  | Plate cancellation | internal |

## risk.InsurableRealEstate

Purpose: real estate-specific risk attributes.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| insurable_object_id | UNIQUEIDENTIFIER | No | none | PK/FK | Root risk | Real estate id | internal |
| realestate_type_code | NVARCHAR(80) | No | none | FK |  | Property type | internal |
| description | NVARCHAR(255) | Yes | none |  |  | Property description | confidential |
| use_type_code | NVARCHAR(80) | No | none | FK |  | Use type | internal |
| insured_role_code | NVARCHAR(80) | No | none | FK |  | Owner/tenant role | internal |
| residence_type_code | NVARCHAR(80) | Yes | none | FK |  | Residence type | internal |
| destination_type_code | NVARCHAR(80) | Yes | none | FK |  | Destination | internal |
| street | NVARCHAR(200) | No | none |  | Address | Street | personal_data |
| number | NVARCHAR(30) | No | none |  | Address | House number | personal_data |
| box | NVARCHAR(30) | Yes | none |  | Address | Box | personal_data |
| postal_code | NVARCHAR(20) | No | none |  | Address | Postal code | personal_data |
| city | NVARCHAR(120) | No | none |  | Address | City | personal_data |
| country_code | CHAR(2) | No | 'BE' |  | Address | Country | internal |
| adjacency_type_code | NVARCHAR(80) | Yes | none | FK |  | Adjacency | internal |
| occupancy_level_code | NVARCHAR(80) | Yes | none | FK |  | Occupancy | internal |
| construction_type_code | NVARCHAR(80) | Yes | none | FK |  | Construction | internal |
| roof_type_code | NVARCHAR(80) | Yes | none | FK |  | Roof | internal |
| build_year | INT | Yes | none | CK | >= 1000 | Build year | internal |
| flammable_materials_pct | DECIMAL(5,2) | Yes | none | CK | 0-100 | Flammable percentage | internal |
| capital_building | DECIMAL(18,2) | Yes | none |  |  | Building capital | financial_data |
| capital_roof | DECIMAL(18,2) | Yes | none |  |  | Roof capital | financial_data |

## policy.Contract

Purpose: tenant-aware policy or contract root.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| contract_id | UNIQUEIDENTIFIER | No | NEWSEQUENTIALID() | PK |  | Contract id | internal |
| tenant_id | UNIQUEIDENTIFIER | No | none | FK/UQ | Unique with contract_number | Owning tenant | internal |
| contract_number | NVARCHAR(40) | No | none | UQ | UQ_Contract_tenant_number | Policy number | confidential |
| contract_domain_code | NVARCHAR(40) | No | none | FK | Domain/type composite | Domain | internal |
| contract_type_code | NVARCHAR(80) | No | none | FK | Domain/type composite | Contract type | internal |
| contract_status_code | NVARCHAR(40) | No | none | FK |  | Status | internal |
| company_id | UNIQUEIDENTIFIER | Yes | none | FK | Institution | Insurer | confidential |
| handling_company_id | UNIQUEIDENTIFIER | Yes | none | FK | Institution | Handling company | confidential |
| start_date | DATE | No | none | CK | start <= end | Start date | internal |
| end_date | DATE | Yes | none | CK | start <= end | End date | internal |
| created_by_user_id | UNIQUEIDENTIFIER | Yes | none | FK |  | Creator | security_sensitive |
| updated_by_user_id | UNIQUEIDENTIFIER | Yes | none | FK |  | Updater | security_sensitive |
| is_deleted | BIT | No | 0 |  | Soft delete | Deleted marker | internal |

## policy.ContractVersion

Purpose: versioned policy lifecycle details.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| contract_version_id | UNIQUEIDENTIFIER | No | NEWSEQUENTIALID() | PK/UQ | Unique with contract_id | Version id | internal |
| contract_id | UNIQUEIDENTIFIER | No | none | FK/UQ | FK_ContractVersion_Contract | Parent contract | internal |
| version_no | INT | No | none | UQ/CK | > 0, unique per contract | Version number | internal |
| effective_from | DATE | No | none | CK | Date range | Effective from | internal |
| effective_to | DATE | Yes | none | CK | >= effective_from | Effective to | internal |
| contract_version_status_code | NVARCHAR(40) | No | none | FK | Duplicate active validated | Version status | internal |
| duration_type_code | NVARCHAR(20) | No | none | FK |  | Duration type | internal |
| periodicity_code | NVARCHAR(40) | No | none | FK |  | Periodicity | financial_data |
| collection_method_code | NVARCHAR(20) | No | none | FK |  | Collection method | financial_data |
| initial_start_date | DATE | Yes | none |  |  | Original start | internal |
| parent_contract_id | UNIQUEIDENTIFIER | Yes | none | FK |  | Parent contract | internal |
| coinsurance_participation_pct | DECIMAL(5,2) | Yes | none | CK | 0-100 | Coinsurance share | financial_data |
| manager_person_id | UNIQUEIDENTIFIER | Yes | none | FK |  | Manager person | personal_data |
| is_deleted | BIT | No | 0 |  | Soft delete | Deleted marker | internal |

## policy.ContractParty

Purpose: maps people to contracts.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| contract_id | UNIQUEIDENTIFIER | No | none | PK/FK |  | Contract | internal |
| person_id | UNIQUEIDENTIFIER | No | none | PK/FK |  | Party person | personal_data |
| contract_party_role_code | NVARCHAR(40) | No | none | PK/FK |  | Role | internal |
| is_primary | BIT | No | 0 |  |  | Primary party flag | internal |
| created_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Link creation time | internal |

## policy.ContractObject

Purpose: maps contracts to insurable risks.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| contract_id | UNIQUEIDENTIFIER | No | none | PK/FK |  | Contract | internal |
| insurable_object_id | UNIQUEIDENTIFIER | No | none | PK/FK | Tenant match validated | Risk object | confidential |
| contract_object_status_code | NVARCHAR(20) | No | none | FK |  | Link status | internal |
| is_primary | BIT | No | 0 |  |  | Primary object flag | internal |
| to_date | DATE | Yes | none |  |  | End date for link | internal |
| created_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Link creation time | internal |

## coverage.Coverage

Purpose: coverage catalog.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| coverage_code | NVARCHAR(80) | No | none | PK |  | Coverage code | public |
| label_nl | NVARCHAR(160) | No | none |  |  | Dutch label | public |
| label_fr | NVARCHAR(160) | Yes | none |  |  | French label | public |
| label_en | NVARCHAR(160) | Yes | none |  |  | English label | public |
| label_tr | NVARCHAR(160) | Yes | none |  |  | Turkish label | public |
| description | NVARCHAR(500) | Yes | none |  |  | Coverage description | internal |
| is_active | BIT | No | 1 |  |  | Active flag | internal |
| sort_order | INT | Yes | none |  |  | Display order | internal |

## coverage.CoverageDomain

Purpose: maps coverages to contract domains.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| coverage_code | NVARCHAR(80) | No | none | PK/FK | FK_CoverageDomain_Coverage | Coverage | public |
| contract_domain_code | NVARCHAR(40) | No | none | PK/FK | FK_CoverageDomain_ContractDomain | Domain | public |
| is_default | BIT | No | 0 |  |  | Default for domain | internal |
| sort_order | INT | Yes | none |  |  | Display order | internal |

## coverage.CoveragePackage

Purpose: reusable coverage bundles by domain.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| coverage_package_id | UNIQUEIDENTIFIER | No | NEWSEQUENTIALID() | PK |  | Package id | internal |
| package_code | NVARCHAR(80) | No | none | UQ | UQ_CoveragePackage_package_code | Package code | public |
| contract_domain_code | NVARCHAR(40) | No | none | FK |  | Domain | public |
| package_name | NVARCHAR(160) | No | none |  |  | Package name | public |
| description | NVARCHAR(500) | Yes | none |  |  | Package description | internal |
| is_active | BIT | No | 1 |  |  | Active flag | internal |
| created_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Creation time | internal |
| updated_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Last update time | internal |

## coverage.CoveragePackageItem

Purpose: coverage items in packages.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| coverage_package_id | UNIQUEIDENTIFIER | No | none | PK/FK |  | Package | internal |
| coverage_code | NVARCHAR(80) | No | none | PK/FK | Package/domain validated | Coverage | public |
| is_mandatory | BIT | No | 0 |  |  | Mandatory item | internal |
| sort_order | INT | Yes | none |  |  | Display order | internal |

## claim.Claim

Purpose: tenant-aware claim lifecycle root.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| claim_id | UNIQUEIDENTIFIER | No | NEWSEQUENTIALID() | PK |  | Claim id | internal |
| tenant_id | UNIQUEIDENTIFIER | No | none | FK/UQ | Tenant-contract match | Owning tenant | internal |
| claim_number | NVARCHAR(50) | No | none | UQ | Unique per tenant | Claim number | confidential |
| contract_id | UNIQUEIDENTIFIER | No | none | FK | Composite with tenant | Contract | confidential |
| coverage_code | NVARCHAR(80) | Yes | none | FK |  | Claimed coverage | internal |
| claim_status_code | NVARCHAR(40) | No | none | FK | Closed-state validated | Status | internal |
| claims_handler_id | UNIQUEIDENTIFIER | Yes | none | FK | Person | Handler | personal_data |
| incident_date | DATE | Yes | none | CK | reported >= incident | Incident date | confidential |
| reported_date | DATE | No | none | CK | reported >= incident | Report date | confidential |
| closed_date | DATE | Yes | none | CK | Required for CLOSED | Close date | confidential |
| description | NVARCHAR(500) | Yes | none |  |  | Claim description | confidential |
| paid_amount | DECIMAL(18,2) | Yes | none | CK | >= 0 | Paid amount | financial_data |
| reserved_amount | DECIMAL(18,2) | Yes | none | CK | >= 0 | Reserved amount | financial_data |
| payment_method_code | NVARCHAR(40) | Yes | none | FK | Required when paid > 0 | Payment method | financial_data |
| is_deleted | BIT | No | 0 |  | Soft delete | Deleted marker | internal |

## document.Document

Purpose: file metadata only; binary content lives outside SQL Server.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| document_id | UNIQUEIDENTIFIER | No | NEWSEQUENTIALID() | PK |  | Document id | internal |
| tenant_id | UNIQUEIDENTIFIER | No | none | FK |  | Owning tenant | internal |
| owner_entity_type | NVARCHAR(60) | No | none | CK | PERSON/INSTITUTION/POLICY/CLAIM/RISK_OBJECT | Owner type | internal |
| owner_entity_id | UNIQUEIDENTIFIER | No | none |  | Polymorphic owner | Owner id | confidential |
| document_type_code | NVARCHAR(80) | No | none | FK |  | Document type | internal |
| file_name | NVARCHAR(260) | No | none |  |  | File name | confidential |
| file_extension | NVARCHAR(20) | No | none |  |  | Extension | internal |
| mime_type | NVARCHAR(120) | No | none |  |  | MIME type | internal |
| file_size_bytes | BIGINT | No | none | CK | Positive in validation | File size | internal |
| storage_provider | NVARCHAR(40) | No | none |  |  | Storage backend | security_sensitive |
| storage_key | NVARCHAR(500) | No | none |  | Non-empty validation | Storage object key | security_sensitive |
| checksum_sha256 | NVARCHAR(128) | Yes | none |  |  | File checksum | security_sensitive |
| language_code | CHAR(2) | Yes | none | FK |  | Document language | internal |
| uploaded_by_user_id | UNIQUEIDENTIFIER | Yes | none | FK |  | Uploader | security_sensitive |
| uploaded_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Upload time | internal |
| is_deleted | BIT | No | 0 | CK | Deleted state | Deleted flag | internal |
| deleted_at_utc | DATETIME2(0) | Yes | none | CK | Required when deleted | Deleted timestamp | internal |

## tasking.Task

Purpose: operational tasks and reminders.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| task_id | UNIQUEIDENTIFIER | No | NEWSEQUENTIALID() | PK |  | Task id | internal |
| tenant_id | UNIQUEIDENTIFIER | No | none | FK |  | Owning tenant | internal |
| title | NVARCHAR(200) | No | none |  |  | Task title | confidential |
| description | NVARCHAR(MAX) | Yes | none |  |  | Task details | confidential |
| related_entity_type | NVARCHAR(60) | Yes | none | CK | Polymorphic type | Related type | internal |
| related_entity_id | UNIQUEIDENTIFIER | Yes | none | CK | Required with type | Related id | confidential |
| assigned_to_user_id | UNIQUEIDENTIFIER | Yes | none | FK | Tenant match validated | Assignee | security_sensitive |
| created_by_user_id | UNIQUEIDENTIFIER | Yes | none | FK | Tenant match validated | Creator | security_sensitive |
| task_priority_code | NVARCHAR(20) | No | 'NORMAL' | FK |  | Priority | internal |
| task_status_code | NVARCHAR(30) | No | 'OPEN' | FK | Completion state validated | Status | internal |
| due_at_utc | DATETIME2(0) | Yes | none |  |  | Due time | internal |
| completed_at_utc | DATETIME2(0) | Yes | none | CK | Required for DONE | Completion time | internal |
| is_deleted | BIT | No | 0 |  | Soft delete | Deleted marker | internal |

## audit.AuditLog

Purpose: audit events for core business tables.

| Column | Type | Null | Default | Key | Notes | Meaning | Classification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| audit_log_id | BIGINT | No | IDENTITY | PK |  | Audit id | internal |
| tenant_id | UNIQUEIDENTIFIER | Yes | none |  | Nullable for system scope | Tenant | internal |
| schema_name | SYSNAME | No | none |  | IX_AuditLog_entity | Source schema | internal |
| table_name | SYSNAME | No | none |  | IX_AuditLog_entity | Source table | internal |
| primary_key_value | NVARCHAR(200) | No | none |  | IX_AuditLog_entity | Row key | confidential |
| action_type | NVARCHAR(20) | No | none | CK | INSERT/UPDATE/DELETE | Action | internal |
| changed_at_utc | DATETIME2(0) | No | SYSUTCDATETIME() |  |  | Change time | internal |
| changed_by_user_id | UNIQUEIDENTIFIER | Yes | none |  |  | User id | security_sensitive |
| changed_by_name | NVARCHAR(200) | Yes | SUSER_SNAME() |  |  | User display | security_sensitive |
| old_values_json | NVARCHAR(MAX) | Yes | none |  | JSON summary | Previous values | confidential |
| new_values_json | NVARCHAR(MAX) | Yes | none |  | JSON summary | New values | confidential |
| source_system | NVARCHAR(80) | Yes | none |  |  | Source system | internal |
| correlation_id | UNIQUEIDENTIFIER | Yes | none |  |  | Request correlation | security_sensitive |

## Stored Procedures

- `tasking.SP_CreateRenewalTasks` creates tenant-aware renewal follow-up tasks
  for active policies ending within `@days_ahead`. Use `@dry_run = 1` in SSMS
  to preview candidates before inserting tasks.

Example:

```sql
DECLARE @TenantId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000';

EXEC tasking.SP_CreateRenewalTasks
    @tenant_id = @TenantId,
    @days_ahead = 60,
    @assigned_to_user_id = NULL,
    @created_by_user_id = NULL,
    @dry_run = 1;
```

## Reporting Views

- `person.VW_CustomerSummary`
- `institution.VW_InstitutionSummary`
- `risk.VW_InsurableObjectSummary`
- `policy.VW_ActivePolicy`
- `policy.VW_PolicyDashboard`
- `claim.VW_ClaimDashboard`
- `tasking.VW_OpenTaskDashboard`
