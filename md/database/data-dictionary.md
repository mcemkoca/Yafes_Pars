# Veri Sözlüğü

Bu sözlük, doğrulanmış SQL Server schema'sını belgelemektedir. Sınıflandırma değerleri:
`public`, `internal`, `confidential`, `personal_data`, `financial_data`,
`security_sensitive`.

Çoğu arama tablosu standart kalıbı kullanır: kod birincil anahtar, mevcut olduğunda
Hollandaca/Fransızca/İngilizce/Türkçe etiket sütunları, `is_active` ve `sort_order`.
Domain'e özgü operasyonel tablolar aşağıda sütun düzeyinde belgelenmiştir.

## core.Tenant

Amaç: tenant kimliği ve varsayılan ayarlar.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| tenant_id | UNIQUEIDENTIFIER | Hayır | NEWSEQUENTIALID() | PK | Tenant farkında kökler tarafından referans alınır | Tenant vekil id | internal |
| tenant_code | NVARCHAR(80) | Hayır | yok | UQ | UQ_Tenant_tenant_code | Kararlı tenant kodu | internal |
| legal_name | NVARCHAR(200) | Hayır | yok |  | Hukuki görüntü | Kayıtlı tenant adı | confidential |
| display_name | NVARCHAR(200) | Hayır | yok |  | UI görüntüsü | Broker/tenant etiketi | internal |
| vat_number | NVARCHAR(30) | Evet | yok |  | İş tanımlayıcı | KDV numarası | confidential |
| country_code | CHAR(2) | Hayır | 'BE' |  | ISO ülke | Tenant ülkesi | internal |
| default_language | CHAR(2) | Hayır | 'nl' |  | FK benzeri dil kodu | Varsayılan UI dili | internal |
| is_active | BIT | Hayır | 1 |  | Aktif bayrağı | Tenant kullanılabilirliği | internal |
| created_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  | Denetim zaman damgası | Oluşturma zamanı | internal |
| updated_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  | Denetim zaman damgası | Son güncelleme zamanı | internal |

## core.AppUser

Amaç: tenant kapsamlı uygulama kullanıcıları.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| user_id | UNIQUEIDENTIFIER | Hayır | NEWSEQUENTIALID() | PK |  | Kullanıcı id | internal |
| tenant_id | UNIQUEIDENTIFIER | Hayır | yok | FK | FK_AppUser_Tenant, UQ tenant/email | Sahip tenant | internal |
| email | NVARCHAR(320) | Hayır | yok | UQ | Tenant başına benzersiz | Giriş/iletişim e-postası | personal_data |
| display_name | NVARCHAR(160) | Hayır | yok |  |  | UI adı | personal_data |
| person_id | UNIQUEIDENTIFIER | Evet | yok | FK | FK_AppUser_Person | Bağlı kişi | personal_data |
| auth_provider | NVARCHAR(40) | Hayır | 'local' |  |  | Kimlik sağlayıcısı | security_sensitive |
| external_subject_id | NVARCHAR(200) | Evet | yok |  |  | Harici kimlik id | security_sensitive |
| is_active | BIT | Hayır | 1 |  |  | Giriş etkin | security_sensitive |
| last_login_at_utc | DATETIME2(0) | Evet | yok |  |  | Son giriş zamanı | security_sensitive |
| created_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Oluşturma zamanı | internal |
| updated_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Son güncelleme zamanı | internal |

## person.Person

Amaç: gerçek ve tüzel kişiler için tenant farkında kök.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| person_id | UNIQUEIDENTIFIER | Hayır | NEWSEQUENTIALID() | PK |  | Kişi id | personal_data |
| tenant_id | UNIQUEIDENTIFIER | Hayır | yok | FK | FK_Person_Tenant | Sahip tenant | internal |
| person_kind | NVARCHAR(10) | Hayır | yok | CK | NATURAL veya LEGAL | Alt tür ayrımcısı | personal_data |
| dossier | NVARCHAR(50) | Evet | yok | UQ filtreli | UQ_Person_tenant_dossier | Broker dosya numarası | confidential |
| language_code | CHAR(2) | Evet | yok | FK | FK_Person_Language | Tercih edilen dil | personal_data |
| nationality | NVARCHAR(80) | Evet | yok |  |  | Uyruk | personal_data |
| subagent_person_id | UNIQUEIDENTIFIER | Evet | yok | FK | Öz FK | Alt acente kişisi | confidential |
| manager_person_id | UNIQUEIDENTIFIER | Evet | yok | FK | Öz FK | Yönetici kişi | confidential |
| portfolio_person_id | UNIQUEIDENTIFIER | Evet | yok | FK | Öz FK | Portföy sahibi | confidential |
| created_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Oluşturma zamanı | internal |
| updated_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Son güncelleme zamanı | internal |
| created_by_user_id | UNIQUEIDENTIFIER | Evet | yok | FK | FK_Person_AppUser_CreatedBy | Oluşturan kullanıcı | security_sensitive |
| updated_by_user_id | UNIQUEIDENTIFIER | Evet | yok | FK | FK_Person_AppUser_UpdatedBy | Son güncelleyen | security_sensitive |
| is_deleted | BIT | Hayır | 0 |  | Geçici silme | Silinmiş işareti | internal |

## person.NaturalPerson

Amaç: gerçek kişi alt türü.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| person_id | UNIQUEIDENTIFIER | Hayır | yok | PK/FK | FK_NaturalPerson_Person | Kök kişi | personal_data |
| first_name | NVARCHAR(100) | Evet | yok |  |  | Ad | personal_data |
| last_name | NVARCHAR(100) | Evet | yok |  | IX_NaturalPerson_name | Soyadı | personal_data |
| birth_date | DATE | Evet | yok |  | Yaşam süresi kontrolü | Doğum tarihi | personal_data |
| birth_place | NVARCHAR(120) | Evet | yok |  |  | Doğum yeri | personal_data |
| death_date | DATE | Evet | yok |  | ölüm >= doğum | Ölüm tarihi | personal_data |
| gender | NVARCHAR(20) | Evet | yok |  |  | Cinsiyet | personal_data |
| marital_status | NVARCHAR(50) | Evet | yok |  |  | Medeni durum | personal_data |
| national_number | NVARCHAR(30) | Evet | yok |  | Hassas tanımlayıcı | Ulusal kimlik | personal_data |
| passport_number | NVARCHAR(30) | Evet | yok |  | Hassas tanımlayıcı | Pasaport id | personal_data |
| id_card_number | NVARCHAR(30) | Evet | yok |  | Hassas tanımlayıcı | Kimlik kart numarası | personal_data |
| id_card_valid_from | DATE | Evet | yok |  | Tarih aralığı kontrolü | Kimlik geçerlilik başlangıcı | personal_data |
| id_card_valid_to | DATE | Evet | yok |  | Tarih aralığı kontrolü | Kimlik geçerlilik sonu | personal_data |
| title_code | NVARCHAR(10) | Evet | yok | FK | FK_NaturalPerson_Title | Kişi unvanı | personal_data |
| created_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Oluşturma zamanı | internal |
| updated_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Son güncelleme zamanı | internal |
| created_by_user_id | UNIQUEIDENTIFIER | Evet | yok | FK |  | Oluşturan kullanıcı | security_sensitive |
| updated_by_user_id | UNIQUEIDENTIFIER | Evet | yok | FK |  | Son güncelleyen | security_sensitive |
| is_deleted | BIT | Hayır | 0 |  | Geçici silme | Silinmiş işareti | internal |

## person.LegalPerson

Amaç: kişi olarak modellenen tüzel varlık alt türü.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| person_id | UNIQUEIDENTIFIER | Hayır | yok | PK/FK | FK_LegalPerson_Person | Kök kişi | confidential |
| incorporation_date | DATE | Evet | yok |  | kapanış >= kuruluş | Kuruluş tarihi | confidential |
| closing_date | DATE | Evet | yok |  | kapanış >= kuruluş | Kapanış tarihi | confidential |
| legal_form | NVARCHAR(120) | Evet | yok |  |  | Hukuki form | confidential |
| created_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Oluşturma zamanı | internal |
| updated_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Son güncelleme zamanı | internal |
| created_by_user_id | UNIQUEIDENTIFIER | Evet | yok | FK |  | Oluşturan kullanıcı | security_sensitive |
| updated_by_user_id | UNIQUEIDENTIFIER | Evet | yok | FK |  | Son güncelleyen | security_sensitive |
| is_deleted | BIT | Hayır | 0 |  | Geçici silme | Silinmiş işareti | internal |

## institution.Institution

Amaç: sigortacılar, brokerlar, bankalar, kiralama firmaları ve ortaklar.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| institution_id | UNIQUEIDENTIFIER | Hayır | NEWSEQUENTIALID() | PK |  | Kuruluş id | internal |
| tenant_id | UNIQUEIDENTIFIER | Hayır | yok | FK/UQ | UQ_Institution_tenant_code | Sahip tenant | internal |
| institution_code | NVARCHAR(80) | Hayır | yok | UQ | Tenant başına benzersiz | Kuruluş kodu | internal |
| name | NVARCHAR(200) | Hayır | yok |  | IX_Institution_name | Yaygın ad | confidential |
| legal_name | NVARCHAR(200) | Evet | yok |  |  | Hukuki ad | confidential |
| vat_number | NVARCHAR(30) | Evet | yok |  |  | KDV numarası | confidential |
| country_code | CHAR(2) | Hayır | 'BE' |  |  | Ülke | internal |
| is_active | BIT | Hayır | 1 |  |  | Aktif bayrağı | internal |
| created_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Oluşturma zamanı | internal |
| updated_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Son güncelleme zamanı | internal |
| created_by_user_id | UNIQUEIDENTIFIER | Evet | yok | FK |  | Oluşturan kullanıcı | security_sensitive |
| updated_by_user_id | UNIQUEIDENTIFIER | Evet | yok | FK |  | Son güncelleyen | security_sensitive |
| is_deleted | BIT | Hayır | 0 |  | Geçici silme | Silinmiş işareti | internal |

## risk.InsurableObject

Amaç: tüm sigortalanabilir riskler için tenant farkında kök.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| insurable_object_id | UNIQUEIDENTIFIER | Hayır | NEWSEQUENTIALID() | PK |  | Risk id | internal |
| tenant_id | UNIQUEIDENTIFIER | Hayır | yok | FK | FK_InsurableObject_Tenant | Sahip tenant | internal |
| object_type_code | NVARCHAR(40) | Hayır | yok | FK | FK_InsurableObject_InsurableObjectType | Risk alt türü | internal |
| description | NVARCHAR(255) | Hayır | yok |  |  | Risk etiketi | confidential |
| status_code | NVARCHAR(30) | Hayır | yok |  | Doğrulanmış değerler | Risk durumu | internal |
| start_date | DATE | Hayır | yok |  | Tarih aralığı kontrolü | Risk başlangıcı | internal |
| end_date | DATE | Evet | yok |  | bitiş >= başlangıç | Risk bitişi | internal |
| created_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Oluşturma zamanı | internal |
| updated_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Son güncelleme zamanı | internal |
| created_by_user_id | UNIQUEIDENTIFIER | Evet | yok | FK |  | Oluşturan kullanıcı | security_sensitive |
| updated_by_user_id | UNIQUEIDENTIFIER | Evet | yok | FK |  | Son güncelleyen | security_sensitive |
| is_deleted | BIT | Hayır | 0 |  | Geçici silme | Silinmiş işareti | internal |

## risk.InsurableVehicle

Amaç: araç'a özgü risk nitelikleri.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| insurable_object_id | UNIQUEIDENTIFIER | Hayır | yok | PK/FK | FK_InsurableVehicle_InsurableObject | Kök risk | internal |
| vehicle_type_code | NVARCHAR(60) | Hayır | yok | FK |  | Araç türü | internal |
| usage_type_code | NVARCHAR(40) | Hayır | yok | FK |  | Araç kullanımı | internal |
| plate_type_code | NVARCHAR(40) | Hayır | yok | FK |  | Plaka türü | internal |
| brand | NVARCHAR(100) | Hayır | yok |  |  | Marka | confidential |
| model | NVARCHAR(100) | Hayır | yok |  |  | Model | confidential |
| chassis_number | NVARCHAR(40) | Hayır | yok |  | IX_InsurableVehicle_chassis | VIN/şase | confidential |
| build_year | INT | Hayır | yok | CK | >= 1886, makul aralık doğrulaması | Üretim yılı | internal |
| first_commissioning_date | DATE | Hayır | yok |  | <= kayıt doğrulaması | İlk kullanım tarihi | internal |
| registration_date | DATE | Hayır | yok |  | >= ilk komisyon doğrulaması | Tescil tarihi | internal |
| license_plate | NVARCHAR(20) | Hayır | yok |  | IX_InsurableVehicle_plate | Plaka numarası | confidential |
| fuel_type_code | NVARCHAR(40) | Evet | yok | FK |  | Yakıt türü | internal |
| drive_type_code | NVARCHAR(20) | Evet | yok | FK |  | Tahrik türü | internal |
| finance_institution_id | UNIQUEIDENTIFIER | Evet | yok | FK | Finansmanlıysa zorunlu | Finans kuruluşu | financial_data |
| is_financed | BIT | Hayır | 0 | CK | Finansman tutarlılığı | Finansmanlı mı | financial_data |
| insured_value_ex_vat | DECIMAL(18,2) | Evet | yok |  |  | KDV hariç değer | financial_data |
| insured_value_inc_vat | DECIMAL(18,2) | Evet | yok |  |  | KDV dahil değer | financial_data |
| catalog_value_ex_vat | DECIMAL(18,2) | Evet | yok |  |  | KDV hariç katalog değeri | financial_data |
| catalog_value_inc_vat | DECIMAL(18,2) | Evet | yok |  |  | KDV dahil katalog değeri | financial_data |
| vat_exemption_pct | DECIMAL(5,2) | Evet | yok | CK | Yüzde semantiği | KDV muafiyeti | financial_data |
| accessories_value | DECIMAL(18,2) | Evet | yok |  |  | Aksesuar değeri | financial_data |
| pvg_number | NVARCHAR(40) | Evet | yok |  |  | PVG numarası | confidential |
| eu_pvg_number | NVARCHAR(40) | Evet | yok |  |  | AB PVG numarası | confidential |
| adr_code | NVARCHAR(40) | Evet | yok |  |  | ADR kodu | internal |
| engine_cc | INT | Evet | yok |  |  | Motor hacmi | internal |
| power_kw | INT | Evet | yok |  |  | Güç kW | internal |
| power_hp | INT | Evet | yok |  |  | Güç HP | internal |
| plate_cancellation_date | DATE | Evet | yok |  |  | Plaka iptali | internal |

## risk.InsurableRealEstate

Amaç: gayrimenkul'e özgü risk nitelikleri.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| insurable_object_id | UNIQUEIDENTIFIER | Hayır | yok | PK/FK | Kök risk | Gayrimenkul id | internal |
| realestate_type_code | NVARCHAR(80) | Hayır | yok | FK |  | Mülk türü | internal |
| description | NVARCHAR(255) | Evet | yok |  |  | Mülk açıklaması | confidential |
| use_type_code | NVARCHAR(80) | Hayır | yok | FK |  | Kullanım türü | internal |
| insured_role_code | NVARCHAR(80) | Hayır | yok | FK |  | Sahip/kiracı rolü | internal |
| residence_type_code | NVARCHAR(80) | Evet | yok | FK |  | Konut türü | internal |
| destination_type_code | NVARCHAR(80) | Evet | yok | FK |  | Hedef | internal |
| street | NVARCHAR(200) | Hayır | yok |  | Adres | Sokak | personal_data |
| number | NVARCHAR(30) | Hayır | yok |  | Adres | Kapı numarası | personal_data |
| box | NVARCHAR(30) | Evet | yok |  | Adres | Kutu | personal_data |
| postal_code | NVARCHAR(20) | Hayır | yok |  | Adres | Posta kodu | personal_data |
| city | NVARCHAR(120) | Hayır | yok |  | Adres | Şehir | personal_data |
| country_code | CHAR(2) | Hayır | 'BE' |  | Adres | Ülke | internal |
| adjacency_type_code | NVARCHAR(80) | Evet | yok | FK |  | Bitişiklik | internal |
| occupancy_level_code | NVARCHAR(80) | Evet | yok | FK |  | Doluluk | internal |
| construction_type_code | NVARCHAR(80) | Evet | yok | FK |  | Yapı | internal |
| roof_type_code | NVARCHAR(80) | Evet | yok | FK |  | Çatı | internal |
| build_year | INT | Evet | yok | CK | >= 1000 | Yapım yılı | internal |
| flammable_materials_pct | DECIMAL(5,2) | Evet | yok | CK | 0-100 | Yanıcı malzeme yüzdesi | internal |
| capital_building | DECIMAL(18,2) | Evet | yok |  |  | Bina sermayesi | financial_data |
| capital_roof | DECIMAL(18,2) | Evet | yok |  |  | Çatı sermayesi | financial_data |

## policy.Contract

Amaç: tenant farkında poliçe veya sözleşme kökü.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| contract_id | UNIQUEIDENTIFIER | Hayır | NEWSEQUENTIALID() | PK |  | Sözleşme id | internal |
| tenant_id | UNIQUEIDENTIFIER | Hayır | yok | FK/UQ | contract_number ile benzersiz | Sahip tenant | internal |
| contract_number | NVARCHAR(40) | Hayır | yok | UQ | UQ_Contract_tenant_number | Poliçe numarası | confidential |
| contract_domain_code | NVARCHAR(40) | Hayır | yok | FK | Domain/tür bileşik | Domain | internal |
| contract_type_code | NVARCHAR(80) | Hayır | yok | FK | Domain/tür bileşik | Sözleşme türü | internal |
| contract_status_code | NVARCHAR(40) | Hayır | yok | FK |  | Durum | internal |
| company_id | UNIQUEIDENTIFIER | Evet | yok | FK | Kuruluş | Sigortacı | confidential |
| handling_company_id | UNIQUEIDENTIFIER | Evet | yok | FK | Kuruluş | İşlemci şirket | confidential |
| start_date | DATE | Hayır | yok | CK | başlangıç <= bitiş | Başlangıç tarihi | internal |
| end_date | DATE | Evet | yok | CK | başlangıç <= bitiş | Bitiş tarihi | internal |
| created_by_user_id | UNIQUEIDENTIFIER | Evet | yok | FK |  | Oluşturan | security_sensitive |
| updated_by_user_id | UNIQUEIDENTIFIER | Evet | yok | FK |  | Güncelleyen | security_sensitive |
| is_deleted | BIT | Hayır | 0 |  | Geçici silme | Silinmiş işareti | internal |

## policy.ContractVersion

Amaç: versiyonlanmış poliçe yaşam döngüsü ayrıntıları.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| contract_version_id | UNIQUEIDENTIFIER | Hayır | NEWSEQUENTIALID() | PK/UQ | contract_id ile benzersiz | Versiyon id | internal |
| contract_id | UNIQUEIDENTIFIER | Hayır | yok | FK/UQ | FK_ContractVersion_Contract | Üst sözleşme | internal |
| version_no | INT | Hayır | yok | UQ/CK | > 0, sözleşme başına benzersiz | Versiyon numarası | internal |
| effective_from | DATE | Hayır | yok | CK | Tarih aralığı | Geçerlilik başlangıcı | internal |
| effective_to | DATE | Evet | yok | CK | >= effective_from | Geçerlilik sonu | internal |
| contract_version_status_code | NVARCHAR(40) | Hayır | yok | FK | Aktif durum tekrarı doğrulandı | Versiyon durumu | internal |
| duration_type_code | NVARCHAR(20) | Hayır | yok | FK |  | Süre türü | internal |
| periodicity_code | NVARCHAR(40) | Hayır | yok | FK |  | Periyodiklik | financial_data |
| collection_method_code | NVARCHAR(20) | Hayır | yok | FK |  | Tahsilat yöntemi | financial_data |
| initial_start_date | DATE | Evet | yok |  |  | Özgün başlangıç | internal |
| parent_contract_id | UNIQUEIDENTIFIER | Evet | yok | FK |  | Üst sözleşme | internal |
| coinsurance_participation_pct | DECIMAL(5,2) | Evet | yok | CK | 0-100 | Ko-sigorta payı | financial_data |
| manager_person_id | UNIQUEIDENTIFIER | Evet | yok | FK |  | Yönetici kişi | personal_data |
| is_deleted | BIT | Hayır | 0 |  | Geçici silme | Silinmiş işareti | internal |

## policy.ContractParty

Amaç: kişileri sözleşmelere eşler.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| contract_id | UNIQUEIDENTIFIER | Hayır | yok | PK/FK |  | Sözleşme | internal |
| person_id | UNIQUEIDENTIFIER | Hayır | yok | PK/FK |  | Taraf kişi | personal_data |
| contract_party_role_code | NVARCHAR(40) | Hayır | yok | PK/FK |  | Rol | internal |
| is_primary | BIT | Hayır | 0 |  |  | Birincil taraf bayrağı | internal |
| created_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Bağlantı oluşturma zamanı | internal |

## policy.ContractObject

Amaç: sözleşmeleri sigortalanabilir risklere eşler.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| contract_id | UNIQUEIDENTIFIER | Hayır | yok | PK/FK |  | Sözleşme | internal |
| insurable_object_id | UNIQUEIDENTIFIER | Hayır | yok | PK/FK | Tenant eşleşmesi doğrulandı | Risk nesnesi | confidential |
| contract_object_status_code | NVARCHAR(20) | Hayır | yok | FK |  | Bağlantı durumu | internal |
| is_primary | BIT | Hayır | 0 |  |  | Birincil nesne bayrağı | internal |
| to_date | DATE | Evet | yok |  |  | Bağlantı bitiş tarihi | internal |
| created_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Bağlantı oluşturma zamanı | internal |

## coverage.Coverage

Amaç: teminat kataloğu.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| coverage_code | NVARCHAR(80) | Hayır | yok | PK |  | Teminat kodu | public |
| label_nl | NVARCHAR(160) | Hayır | yok |  |  | Hollandaca etiket | public |
| label_fr | NVARCHAR(160) | Evet | yok |  |  | Fransızca etiket | public |
| label_en | NVARCHAR(160) | Evet | yok |  |  | İngilizce etiket | public |
| label_tr | NVARCHAR(160) | Evet | yok |  |  | Türkçe etiket | public |
| description | NVARCHAR(500) | Evet | yok |  |  | Teminat açıklaması | internal |
| is_active | BIT | Hayır | 1 |  |  | Aktif bayrağı | internal |
| sort_order | INT | Evet | yok |  |  | Görüntüleme sırası | internal |

## coverage.CoverageDomain

Amaç: teminatları sözleşme domain'lerine eşler.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| coverage_code | NVARCHAR(80) | Hayır | yok | PK/FK | FK_CoverageDomain_Coverage | Teminat | public |
| contract_domain_code | NVARCHAR(40) | Hayır | yok | PK/FK | FK_CoverageDomain_ContractDomain | Domain | public |
| is_default | BIT | Hayır | 0 |  |  | Domain için varsayılan | internal |
| sort_order | INT | Evet | yok |  |  | Görüntüleme sırası | internal |

## coverage.CoveragePackage

Amaç: domain bazında yeniden kullanılabilir teminat paketleri.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| coverage_package_id | UNIQUEIDENTIFIER | Hayır | NEWSEQUENTIALID() | PK |  | Paket id | internal |
| package_code | NVARCHAR(80) | Hayır | yok | UQ | UQ_CoveragePackage_package_code | Paket kodu | public |
| contract_domain_code | NVARCHAR(40) | Hayır | yok | FK |  | Domain | public |
| package_name | NVARCHAR(160) | Hayır | yok |  |  | Paket adı | public |
| description | NVARCHAR(500) | Evet | yok |  |  | Paket açıklaması | internal |
| is_active | BIT | Hayır | 1 |  |  | Aktif bayrağı | internal |
| created_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Oluşturma zamanı | internal |
| updated_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Son güncelleme zamanı | internal |

## coverage.CoveragePackageItem

Amaç: paketlerdeki teminat kalemleri.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| coverage_package_id | UNIQUEIDENTIFIER | Hayır | yok | PK/FK |  | Paket | internal |
| coverage_code | NVARCHAR(80) | Hayır | yok | PK/FK | Paket/domain doğrulandı | Teminat | public |
| is_mandatory | BIT | Hayır | 0 |  |  | Zorunlu kalem | internal |
| sort_order | INT | Evet | yok |  |  | Görüntüleme sırası | internal |

## claim.Claim

Amaç: tenant farkında hasar yaşam döngüsü kökü.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| claim_id | UNIQUEIDENTIFIER | Hayır | NEWSEQUENTIALID() | PK |  | Hasar id | internal |
| tenant_id | UNIQUEIDENTIFIER | Hayır | yok | FK/UQ | Tenant-sözleşme eşleşmesi | Sahip tenant | internal |
| claim_number | NVARCHAR(50) | Hayır | yok | UQ | Tenant başına benzersiz | Hasar numarası | confidential |
| contract_id | UNIQUEIDENTIFIER | Hayır | yok | FK | Tenant ile bileşik | Sözleşme | confidential |
| coverage_code | NVARCHAR(80) | Evet | yok | FK |  | Talep edilen teminat | internal |
| claim_status_code | NVARCHAR(40) | Hayır | yok | FK | Kapalı durum doğrulandı | Durum | internal |
| claims_handler_id | UNIQUEIDENTIFIER | Evet | yok | FK | Kişi | İşlemci | personal_data |
| incident_date | DATE | Evet | yok | CK | bildirilen >= olay | Olay tarihi | confidential |
| reported_date | DATE | Hayır | yok | CK | bildirilen >= olay | Bildirim tarihi | confidential |
| closed_date | DATE | Evet | yok | CK | KAPALI için zorunlu | Kapanış tarihi | confidential |
| description | NVARCHAR(500) | Evet | yok |  |  | Hasar açıklaması | confidential |
| paid_amount | DECIMAL(18,2) | Evet | yok | CK | >= 0 | Ödenen tutar | financial_data |
| reserved_amount | DECIMAL(18,2) | Evet | yok | CK | >= 0 | Rezerv tutarı | financial_data |
| payment_method_code | NVARCHAR(40) | Evet | yok | FK | ödenen > 0 ise zorunlu | Ödeme yöntemi | financial_data |
| is_deleted | BIT | Hayır | 0 |  | Geçici silme | Silinmiş işareti | internal |

## document.Document

Amaç: yalnızca dosya meta verisi; ikili içerik SQL Server dışında tutuluyor.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| document_id | UNIQUEIDENTIFIER | Hayır | NEWSEQUENTIALID() | PK |  | Belge id | internal |
| tenant_id | UNIQUEIDENTIFIER | Hayır | yok | FK |  | Sahip tenant | internal |
| owner_entity_type | NVARCHAR(60) | Hayır | yok | CK | PERSON/INSTITUTION/POLICY/CLAIM/RISK_OBJECT | Sahip türü | internal |
| owner_entity_id | UNIQUEIDENTIFIER | Hayır | yok |  | Polimorfik sahip | Sahip id | confidential |
| document_type_code | NVARCHAR(80) | Hayır | yok | FK |  | Belge türü | internal |
| file_name | NVARCHAR(260) | Hayır | yok |  |  | Dosya adı | confidential |
| file_extension | NVARCHAR(20) | Hayır | yok |  |  | Uzantı | internal |
| mime_type | NVARCHAR(120) | Hayır | yok |  |  | MIME türü | internal |
| file_size_bytes | BIGINT | Hayır | yok | CK | Doğrulamada pozitif | Dosya boyutu | internal |
| storage_provider | NVARCHAR(40) | Hayır | yok |  |  | Depolama arka ucu | security_sensitive |
| storage_key | NVARCHAR(500) | Hayır | yok |  | Boş olmayan doğrulama | Depolama nesne anahtarı | security_sensitive |
| checksum_sha256 | NVARCHAR(128) | Evet | yok |  |  | Dosya sağlama toplamı | security_sensitive |
| language_code | CHAR(2) | Evet | yok | FK |  | Belge dili | internal |
| uploaded_by_user_id | UNIQUEIDENTIFIER | Evet | yok | FK |  | Yükleyen | security_sensitive |
| uploaded_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Yükleme zamanı | internal |
| is_deleted | BIT | Hayır | 0 | CK | Silinmiş durum | Silinmiş bayrağı | internal |
| deleted_at_utc | DATETIME2(0) | Evet | yok | CK | Silindiğinde zorunlu | Silinme zaman damgası | internal |

## tasking.Task

Amaç: operasyonel görevler ve hatırlatıcılar.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| task_id | UNIQUEIDENTIFIER | Hayır | NEWSEQUENTIALID() | PK |  | Görev id | internal |
| tenant_id | UNIQUEIDENTIFIER | Hayır | yok | FK |  | Sahip tenant | internal |
| title | NVARCHAR(200) | Hayır | yok |  |  | Görev başlığı | confidential |
| description | NVARCHAR(MAX) | Evet | yok |  |  | Görev ayrıntıları | confidential |
| related_entity_type | NVARCHAR(60) | Evet | yok | CK | Polimorfik tür | İlgili tür | internal |
| related_entity_id | UNIQUEIDENTIFIER | Evet | yok | CK | Türle birlikte zorunlu | İlgili id | confidential |
| assigned_to_user_id | UNIQUEIDENTIFIER | Evet | yok | FK | Tenant eşleşmesi doğrulandı | Atanan | security_sensitive |
| created_by_user_id | UNIQUEIDENTIFIER | Evet | yok | FK | Tenant eşleşmesi doğrulandı | Oluşturan | security_sensitive |
| task_priority_code | NVARCHAR(20) | Hayır | 'NORMAL' | FK |  | Öncelik | internal |
| task_status_code | NVARCHAR(30) | Hayır | 'OPEN' | FK | Tamamlanma durumu doğrulandı | Durum | internal |
| due_at_utc | DATETIME2(0) | Evet | yok |  |  | Son tarih | internal |
| completed_at_utc | DATETIME2(0) | Evet | yok | CK | TAMAMLANDI için zorunlu | Tamamlanma zamanı | internal |
| is_deleted | BIT | Hayır | 0 |  | Geçici silme | Silinmiş işareti | internal |

## audit.AuditLog

Amaç: temel iş tabloları için denetim olayları.

| Sütun | Tür | Null | Varsayılan | Anahtar | Notlar | Anlam | Sınıflandırma |
| --- | --- | --- | --- | --- | --- | --- | --- |
| audit_log_id | BIGINT | Hayır | IDENTITY | PK |  | Denetim id | internal |
| tenant_id | UNIQUEIDENTIFIER | Evet | yok |  | Sistem kapsamı için Null olabilir | Tenant | internal |
| schema_name | SYSNAME | Hayır | yok |  | IX_AuditLog_entity | Kaynak schema | internal |
| table_name | SYSNAME | Hayır | yok |  | IX_AuditLog_entity | Kaynak tablo | internal |
| primary_key_value | NVARCHAR(200) | Hayır | yok |  | IX_AuditLog_entity | Satır anahtarı | confidential |
| action_type | NVARCHAR(20) | Hayır | yok | CK | INSERT/UPDATE/DELETE | Aksiyon | internal |
| changed_at_utc | DATETIME2(0) | Hayır | SYSUTCDATETIME() |  |  | Değişim zamanı | internal |
| changed_by_user_id | UNIQUEIDENTIFIER | Evet | yok |  |  | Kullanıcı id | security_sensitive |
| changed_by_name | NVARCHAR(200) | Evet | SUSER_SNAME() |  |  | Kullanıcı görüntüsü | security_sensitive |
| old_values_json | NVARCHAR(MAX) | Evet | yok |  | JSON özeti | Önceki değerler | confidential |
| new_values_json | NVARCHAR(MAX) | Evet | yok |  | JSON özeti | Yeni değerler | confidential |
| source_system | NVARCHAR(80) | Evet | yok |  |  | Kaynak sistem | internal |
| correlation_id | UNIQUEIDENTIFIER | Evet | yok |  |  | İstek korelasyonu | security_sensitive |

## Stored Procedure'ler

- `tasking.SP_CreateRenewalTasks`, `@days_ahead` gün içinde sona eren aktif poliçeler
  için tenant farkında yenileme takip görevleri oluşturur. Görev eklemeden önce adayları
  önizlemek için SSMS'de `@dry_run = 1` kullanın.

Örnek:

```sql
DECLARE @TenantId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000';

EXEC tasking.SP_CreateRenewalTasks
    @tenant_id = @TenantId,
    @days_ahead = 60,
    @assigned_to_user_id = NULL,
    @created_by_user_id = NULL,
    @dry_run = 1;
```

## Raporlama View'ları

- `person.VW_CustomerSummary`
- `institution.VW_InstitutionSummary`
- `risk.VW_InsurableObjectSummary`
- `policy.VW_ActivePolicy`
- `policy.VW_PolicyDashboard`
- `claim.VW_ClaimDashboard`
- `tasking.VW_OpenTaskDashboard`
