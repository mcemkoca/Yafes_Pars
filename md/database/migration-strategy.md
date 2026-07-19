# Migration Stratejisi

Migration'lar, SQL Server Management Studio'dan çalıştırmak üzere tasarlanmış sıralı
T-SQL dosyalarıdır.

## Kurallar

- Yalnızca Microsoft SQL Server sözdizimi kullanın.
- Gerektiğinde `GO` toplu iş ayırıcılarını kullanın.
- `SET NOCOUNT ON;` ve `SET XACT_ABORT ON;` kullanın.
- Uygulanabilir olduğunda sıradan DDL etrafında işlem blokları kullanın.
- SQL Server gerektirdiğinde `CREATE OR ALTER VIEW`, `CREATE OR ALTER PROCEDURE` ve
  `CREATE OR ALTER TRIGGER` toplu işlerini ayırın.
- Büyük migration'lar için doğrulama script'leri ekleyin.
- Eski SQL'i `database/legacy/` altında saklayın.

## Takip

Migration tabanı, uygulanan script'lerin ad, sağlama toplamı, yürütme zamanı,
kullanıcı, durum ve hata mesajıyla takip edilebilmesi için `core.SchemaMigration`'ı
içerecektir.

## İlk Migration Tabanı

- `000__create_database.sql`, mevcut değilse `YafesPars`'ı oluşturur.
- `001__create_schemas.sql`, gerekli domain schema'larını oluşturur.
- `002__create_core_infrastructure.sql`, `core.SchemaMigration`'ı oluşturur.
- `001__validate_core_infrastructure.sql`, schema'ları ve migration takip nesnelerini
  doğrular.
- `003__create_person_domain.sql`, `person` schema'sı altında eski person domain'inden
  kişi ve iletişim tablolarını ve `ref` altında arama tablolarını oluşturur.
- `002__validate_person_domain.sql`, person migration'ını doğrular.
- `004__create_institution_domain.sql`, tenant farkında kuruluş, tanımlayıcı,
  adres ve arama tablolarını oluşturur.
- `003__validate_institution_domain.sql`, institution migration'ını doğrular.
- `005__create_object_domain.sql`, eski `Object` tablo adı yerine
  `risk.InsurableObject` kullanarak yeniden düzenlenmiş risk domain'ini oluşturur.
- `004__validate_risk_domain.sql`, risk migration'ını doğrular ve yasak `Object`
  tablolarının oluşturulmadığını kontrol eder.
- `006__create_contract_domain.sql`, policy sözleşmesi, versiyon, taraf, nesne,
  devir ve arama tablolarını oluşturur.
- `005__validate_policy_domain.sql`, policy migration'ını doğrular.
- `007__create_coverage_domain.sql`, teminat, domain eşleme, paket, paket kalem
  tablolarını ve temel teminat seed satırlarını oluşturur.
- `006__validate_coverage_domain.sql`, coverage migration'ını doğrular.
- `008__create_claim_domain.sql`, tenant farkında hasar, taraf, nesne, koşul, durum,
  rol ve ödeme yöntemi tablolarını oluşturur.
- `007__validate_claim_domain.sql`, claim migration'ını doğrular.
- `009__create_document_domain.sql`, SQL Server'da dosya ikilileri saklamaksızın
  belge meta verisi, bağlantı, versiyon ve tür tablolarını oluşturur.
- `008__validate_document_domain.sql`, document migration'ını doğrular.
- `010__create_task_domain.sql`, görev, yorum, hatırlatıcı, durum ve öncelik
  tablolarını oluşturur.
- `009__validate_task_domain.sql`, task migration'ını doğrular.
- `011__create_audit_domain.sql`, denetim tablolarını ve temel kök tablolar için
  minimal denetim trigger'larını oluşturur.
- `010__validate_audit_domain.sql`, audit migration'ını doğrular.
- `012__add_constraints.sql`, birden fazla önceki domain'e bağlı domain'ler arası
  kısıtlamaları ekler.
- `011__validate_constraints_exist.sql`, domain'ler arası kısıtlamaları doğrular.
- `013__add_indexes.sql`, SQL Server katalog meta verisinden eksik FK destekleyen
  indeksleri oluşturur ve dashboard/raporlama indeksleri ekler.
- `012__validate_indexes.sql`, FK indeks kapsamını ve raporlama indekslerini doğrular.
- `014__add_triggers.sql`, trigger aşamasını kaydeder; kök denetim trigger'ları
  `011__create_audit_domain.sql` tarafından oluşturulur.
- `013__validate_triggers.sql`, kök denetim trigger varlığını doğrular.
- `015__add_views.sql`, raporlama ve dashboard view'ları oluşturur.
- `014__validate_views.sql`, view varlığını doğrular.
- `016__add_stored_procedures.sql`, tenant farkında arama, oluşturma, kapatma
  ve denetim arama stored procedure'leri oluşturur.
- `015__validate_stored_procedures.sql`, stored procedure varlığını doğrular.
- `017__seed_lookup_data.sql`, üretim arama/referans verisini ve temel RBAC
  izinlerini ve sistem rollerini ekler.
- `016__validate_seed_data.sql`, gerekli seed verisini doğrular.
- `018__seed_demo_data.sql`, isteğe bağlı olarak kullanıcılar, kişiler, kurumlar,
  riskler, poliçeler, hasarlar, görevler ve belgelerle bir Belçika sigorta broker
  demo tenant'ı ekler.
- `017__validate_demo_data.sql`, demo seed çalıştırıldığında isteğe bağlı demo
  verisini doğrular.
