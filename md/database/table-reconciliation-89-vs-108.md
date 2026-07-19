# Tablo Mutabakatı: Eski 89 ile Mevcut 108

Tablo kaldırmadan, birleştirmeden veya eklemeden önce bu belgeyi kullanın. Mevcut
migration kaynağı, üretim tasarım otoritesidir.

Kısa kural: eski 89 karşılaştırma tarihidir; mevcut 108 aktif modeldir.

## Gerçeğin Kaynağı

| Kaynak | Sayı | Durum |
| --- | ---: | --- |
| `database/legacy/schema.sql` | 89 | Yalnızca eski karşılaştırma kaynağı. |
| `database/migrations/000..018` | 108 | Aktif SQL Server gerçek kaynağı. |

Karar: aktif modeli 89 tabloya indirmeyin. 108 tablo modeli kasıtlıdır; tenant/RBAC/denetim
temellerini, belge/tasking operasyonlarını, daha net teminat yapılarını ve daha güvenli
risk/nesne adlandırmasını eklemektedir.

## Mevcut Schema Sayıları

| Schema | Tablo | Rol |
| --- | ---: | --- |
| `core` | 7 | Tenant, kullanıcılar, roller, izinler, migration defteri. |
| `ref` | 6 | Paylaşılan arama standartları. |
| `person` | 16 | Gerçek/tüzel kimlik, iletişim verisi, ilişkiler. |
| `institution` | 6 | Sigortacılar, bankalar, brokerlar, tanımlayıcılar, adresler. |
| `risk` | 33 | Sigortalanabilir nesneler ve alt tür ayrıntıları. |
| `policy` | 17 | Sözleşmeler, versiyonlar, taraflar, nesneler, devirler. |
| `coverage` | 4 | Teminat kataloğu, domain'ler, paketler. |
| `claim` | 8 | Hasar kökü, taraflar, nesneler, koşullar. |
| `document` | 4 | Belgeler, bağlantılar, versiyonlar, depolama meta verisi. |
| `tasking` | 5 | Görevler, yorumlar, hatırlatıcılar, öncelik/durum. |
| `audit` | 2 | Denetim günlüğü ve varlık değişim ayrıntıları. |

## Yeniden Adlandırma ve Bölme Kararları

| Eski tablo veya fikir | Mevcut tablo veya karar | Karar |
| --- | --- | --- |
| `Object` | `risk.InsurableObject` | Güvensiz genel tablo adlandırmasından kaçınmak için yeniden adlandırıldı. |
| `ObjectType` | `risk.InsurableObjectType` | Netlik için yeniden adlandırıldı. |
| `ObjectVehicle` | `risk.InsurableVehicle` | Daha güvenli adlandırmayla korundu. |
| `ObjectRealEstate` | `risk.InsurableRealEstate` | Daha güvenli adlandırmayla korundu. |
| `ObjectRealEstate_BurglaryProtection` | `risk.InsurableRealEstateBurglaryProtection` | Korundu ve adlandırma normalleştirildi. |
| `ObjectLoan` | `risk.InsurableLoan` | Daha güvenli adlandırmayla korundu. |
| `ObjectPerson` | `risk.InsurablePerson` | Daha güvenli adlandırmayla korundu. |
| `ObjectThing` | `risk.InsurableThing` | Daha güvenli adlandırmayla korundu. |
| `ObjectActivity` | `risk.InsurableActivity` | Daha güvenli adlandırmayla korundu. |
| `ObjectPersonSubtype` | `risk.InsurablePersonSubtype` | Daha güvenli adlandırmayla korundu. |
| `ObjectThingSubtype` | `risk.InsurableThingSubtype` | Daha güvenli adlandırmayla korundu. |
| `ObjectActivitySubtype` | `risk.InsurableActivitySubtype` | Daha güvenli adlandırmayla korundu. |
| `Person_PersonType` | `person.PersonPersonType` | SQL Server dostu adlandırmayla korundu. |
| `PersonRelation_Person` | `person.PersonRelationPerson` | SQL Server dostu adlandırmayla korundu. |
| `EconomicActivity_Nacebel` | `person.EconomicActivityNacebel` | SQL Server dostu adlandırmayla korundu. |
| `Contract_Object` | `policy.ContractObject` | SQL Server dostu adlandırmayla korundu. |
| `Contract_Party` | `policy.ContractParty` | SQL Server dostu adlandırmayla korundu. |
| `ContractVersion_Object` | `policy.ContractVersionObject` | SQL Server dostu adlandırmayla korundu. |
| `Claim_Circumstance` | `claim.ClaimCircumstance` | SQL Server dostu adlandırmayla korundu. |
| `Claim_Object` | `claim.ClaimObject` | SQL Server dostu adlandırmayla korundu. |
| `Claim_Party` | `claim.ClaimParty` | SQL Server dostu adlandırmayla korundu. |
| `lookup_coverage` | `coverage.Coverage` | Coverage schema'sına yeniden işlendi. |
| `coverage_domain` | `coverage.CoverageDomain` | Coverage schema'sına yeniden işlendi. |
| `NatureType` | Mevcut tablo olarak taşınmadı | Gelecekteki herhangi bir migration öncesinde sahip onayı gerektirir. |

## Eski 89'un Ötesindeki Eklemeler

| Alan | Eklenen tablolar | Gerekçe |
| --- | --- | --- |
| Tenant ve güvenlik | `core.Tenant`, `core.AppUser`, `core.Role`, `core.Permission`, `core.RolePermission`, `core.UserRole`, `core.SchemaMigration` | Çok kiracılı işlem, RBAC ve migration izlenebilirliği için zorunlu. |
| Belgeler | `document.DocumentType`, `document.Document`, `document.DocumentLink`, `document.DocumentVersion` | Poliçe, hasar, kişi, kuruluş ve risk belge işleme için zorunlu. |
| Tasking | `tasking.TaskStatus`, `tasking.TaskPriority`, `tasking.Task`, `tasking.TaskComment`, `tasking.TaskReminder` | Günlük operatör iş akışı ve yenileme/hasar takibi için zorunlu. |
| Denetim | `audit.AuditLog`, `audit.EntityChangeSet` | Korumalı düzenlemeler ve destek/denetim kanıtı için zorunlu. |
| Teminat paketleri | `coverage.CoveragePackage`, `coverage.CoveragePackageItem` | Yeniden kullanılabilir sigorta paketi yapısı için zorunlu. |

## Çalışma Kuralı

1. Mevcut 108 tablo migration hattını korumalı tutun.
2. Herhangi bir tablo değişikliği planlamadan önce `12__table_catalog_and_relationships.sql`
   kullanın.
3. Domain rotalarını ve hazırlığı incelemek için `13__visual_workflow_board.sql` kullanın.
4. Yeni schema değişikliklerini yalnızca ileri migration `019+` olarak ekleyin.
5. Eski paket daha az tablo içerdiği için tabloları silmeyin veya birleştirmeyin.

## Açık Sahip Kararları

| Konu | Mevcut konum | Gerekli sahip kararı |
| --- | --- | --- |
| `NatureType` | Mevcut tablo olarak uygulanmadı. | Policy, risk veya arama kapsamına ait olup olmadığını onaylayın. |
| Finans/komisyon | Henüz uygulanmadı. | `019+` tasarımından önce muhasebe akışını onaylayın. |
| İçe/dışa aktarma sahneleme | Henüz uygulanmadı. | `019+` tasarımından önce ekleme/içe aktarma sürecini onaylayın. |
| Ürün şablonları | Henüz uygulanmadı. | `019+` tasarımından önce ürün/derecelendirme sahipliğini onaylayın. |
