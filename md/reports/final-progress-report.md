# Son İlerleme Raporu

> **ARŞİV — 2026-07-19**
> Bu rapor, şu anda silinmiş olan
> `feature/complete-db-validation-backend-frontend-foundation` dalında
> tamamlanan çalışmaları açıklar.
> Yalnızca geçmiş kayıt olarak korunmaktadır.
> Mevcut sistem durumu yetkilidir; bu derleme sonuçlarını
> mevcut kod tabanı hakkında sonuç çıkarmak için kullanmayın.

Dal: `feature/complete-db-validation-backend-frontend-foundation` *(silindi — main'e birleştirildi)*

## Tamamlanan Veri Tabanı Çalışması

- Korumalı DEV migration iş akışı güçlendirmesi tamamlandı.
- SQL Server CI doğrulama iş akışı ve CI sarmalayıcı script eklendi.
- Domain'ler, teminatlar, paketler ve paket kalemleri için teminat seed verisi tamamlandı.
- Eksik gelişmiş risk arama seed verisi tamamlandı.
- `tasking.SP_CreateRenewalTasks` eklendi.
- Kişi, kuruluş, risk, poliçe, teminat, hasar, belge, tasking, denetim, domain'ler arası
  kısıtlamalar, stored procedure'ler ve seed verisi için doğrulama script'leri güçlendirildi.
- Aktif poliçe tarafı/nesnesi/versiyonu tutarlılığı için isteğe bağlı DEV örnek verisi
  güncellendi.
- SSMS geri dönüş script üretimi güncellendi.
- Policy tarafı, policy nesnesi, hasar işleyicisi, oluşturucu kullanıcı ve hasar kapama
  güncelleyici yolları için stored procedure bridge tenant sahipliği kontrolleri güçlendirildi.

## Doğrulama Sonucu

- Statik SQL Server uyumluluk kontrolleri: BAŞARILI.
- Yıkıcı migration kalıbı taraması: BAŞARILI.
- PowerShell çalıştırıcı ayrıştırma kontrolleri: BAŞARILI.
- Gerçek SQL Server DEV yürütmesi: SQL Server 2022 container'ında BAŞARILI.
- SSMS bridge, bariyer ve izleme script'leri: SQL Server 2022 container'ında BAŞARILI.
- DEV geri yükleme tatbikatı: BAŞARILI.
- DEV erişim inceleme kanıtı: BAŞARILI.

Kanıt raporları:

- `md/reports/dev-validation-evidence-2026-06-04.md`
- `md/reports/restore-drill-evidence-dev-2026-06-04.md`
- `md/reports/access-review-evidence-dev-2026-06-04.md`

## Seed Tamamlama Özeti

- Teminat domain'leri: AUTO, FIRE, FAMILY, LIABILITY, LEGAL_PROTECTION, HEALTH,
  LIFE, LOAN, BUSINESS, TRAVEL.
- Teminat örnekleri: BA_AUTO, OMNIUM, MINI_OMNIUM, DRIVER_PROTECTION,
  LEGAL_PROTECTION_AUTO, FIRE_BUILDING, FIRE_CONTENTS, THEFT, GLASS_BREAKAGE,
  WATER_DAMAGE, FAMILY_LIABILITY, LEGAL_PROTECTION_PRIVATE, HOSPITALIZATION,
  LIFE_COVER, OUTSTANDING_BALANCE, BUSINESS_LIABILITY, TRAVEL_ASSISTANCE.
- Teminat paketleri: AUTO_BASIC, AUTO_FULL, HOME_BASIC, HOME_FULL,
  FAMILY_BASIC, BUSINESS_BASIC.
- Araç, gayrimenkul, sigortalı roller, konut/hedef/bitişiklik/doluluk/yapı/çatı/
  hırsızlık koruması, sigortalı kişi, işçi/çalışan, yaş, nesne, malzeme, faaliyet
  ve faaliyet risk seviyeleri için risk arama teminatı genişletildi.

## Eklenen Stored Procedure'ler

- `tasking.SP_CreateRenewalTasks`
- Mevcut policy ve claim bridge procedure'leri, tenant'a ait kişi/nesne/işleyici/
  kullanıcı kontrolleriyle güçlendirildi.

Davranış:

- Tenant farkında.
- `@dry_run` destekliyor.
- Aynı sözleşme için yinelenen açık yenileme görevlerini önlüyor.
- Atanan ve oluşturucu kullanıcıların tenant'a ait olduğunu doğruluyor.
- İşlem güvenliği, `SET XACT_ABORT ON`, TRY/CATCH ve `THROW` kullanıyor.

## ERD ve Veri Sözlüğü

- `md/database/erd-notes.md` güncellendi.
- `md/database/erd-mermaid.md` eklendi.
- `md/database/data-dictionary.md`, ana operasyonel tablolar ve güvenlik
  sınıflandırmaları için sütun düzeyi ayrıntıyla genişletildi.

## SSMS Çalışma Tezgahı Durumu

- `database/ssms/` altında SSMS öncelikli operasyonel çalışma tezgahı eklendi.
- DEV hedef ve sunucu güvenlik kontrolü için `00__open_first_safety_check.sql` eklendi.
- SSMS SQLCMD modu migration başlatıcısı olarak `01__run_all_dev_migrations_sqlcmd.sql`
  eklendi.
- Müşteriler, kurumlar, riskler, poliçeler, hasarlar, belgeler, görevler, teminat
  ve arama sağlığı için tenant farkında Results Grid dashboard'ları için
  `02__operations_dashboard.sql` eklendi.
- `tasking.SP_CreateRenewalTasks`'ın kontrollü yürütmesi için
  `03__create_renewal_tasks.sql` eklendi.
- RBAC, denetim ve veri bütünlük kontrolleri için
  `04__admin_security_audit_queries.sql` eklendi.
- Rol kapsamı, izin matrisi, tenant kullanıcı atamaları, en az ayrıcalık kontrolleri
  ve admin deviri için `14__admin_role_permission_matrix.sql` eklendi.
- `CREATE_VEHICLE_OBJECT`, `ADD_POLICY_OBJECT` ve `CLOSE_CLAIM` önizleme öncelikli
  aksiyonlarıyla `07__data_entry_bridge_templates.sql` genişletildi.
- DEV veri tabanı sağlığı, biriktirme, yedek görünürlüğü, SQL Agent gözlemlenen
  işleri ve DBA devir ızgaraları için `15__monitoring_and_job_readiness.sql` eklendi.
- Commit inceleme kapanması, bitmemiş teslimat boşlukları, sahip engelleyicileri ve
  sonraki SSMS aksiyonları için `16__delivery_gap_register.sql` eklendi.
- Sahip kanıtı deviri, 019+ karar alımı, sonraki bridge sıralaması, SQL Agent terfisi
  ve sürüm kapıları için `17__remaining_work_cockpit.sql` eklendi.
- Birincil arayüz hedefi bir web sitesi değil SSMS Query Editor ve SQL Server motor
  davranışıdır.

## CI Pipeline Durumu

- `.github/workflows/sql-server-validation.yml` eklendi.
- `.github/workflows/backend-build.yml` eklendi.
- İstenen hedef SSMS öncelikli olduğundan frontend iş akışı kaldırıldı.
- GitHub Actions artık backend derlemesini, SQL Server doğrulamasını, veri tabanı
  kalite kapısını ve SSMS çalışma tezgahı doğrulamasını doğrulıyor.
- SQL Server doğrulaması artık korumalı migration ve doğrulama dizisinden sonra
  kontrol altındaki SSMS operatör script'lerini yürütüyor.
- Korumalı çalıştırıcı, kalıcı olarak sabit bir dosya listesine güvenmek yerine
  bitişik `019+` script'leri otomatik olarak içeriyor.

## Backend/API Durumu

- `backend/` altında isteğe bağlı .NET 8 Temiz Mimari temeli eklendi.
- API, Application, Domain, Infrastructure ve Tests projeleri eklendi.
- Swagger/OpenAPI kurulumu eklendi.
- JWT'ye hazır kimlik doğrulama bağlantısı eklendi.
- Tenant kapsamlı domain okumaları, kimliği doğrulanmış JWT `tenant_id` claim'ine
  bağlandı.
- Development dışında JWT otoritesi ve kitlesi zorunlu kılındı.
- Swagger Development ile kısıtlandı ve DB bağlantı sağlığı uç noktası
  yetkilendirmeyle korundu.
- Tenant'lar, kişiler, kurumlar, riskler, poliçeler, hasarlar, belgeler, görevler,
  teminat ve arama sağlığı için okuma/arama uç noktaları eklendi.
- Backend derlemesi CI'da onaylandı.
- Yedi backend yetkilendirme ve tenant claim testi yerel olarak geçiyor.

## Ürün Sahipliği

- Ürün sahibi, bakımcı, teknik yön ve sürüm atfı: `Deuterium12{MCK}`.
- Kamuya açık depo belgeleri ve katkı şablonları aynı sahiplik etiketini kullanır.
- GitHub hesap tanıtıcıları yalnızca platformun izinler ve inceleme yönlendirme için
  geçerli bir hesap gerektirdiği yerlerde saklanır.

## Frontend/Web Durumu

- Yön netleştirildikten sonra Next.js web admin paneli kaldırıldı.
- `.github/workflows/frontend-build.yml` kaldırıldı.
- Şu anda amaçlanan operatör yüzeyinin bir parçası olarak web UI yok.

## Kalan Riskler

- İfşa edilmiş koordinasyon token'ları iptal edilmeli/döndürülmelidir.
- TEST/PROD yürütme kanıtı onaylı altyapıda toplanmalıdır.
- TEST/PROD erişim inceleme kanıtı, adlandırılmış operatörler ve imzayla
  toplanmalıdır.
- TEST/PROD geri yükleme tatbikatı kanıtı canlıya geçişten önce toplanmalıdır.
- SQL Agent işleri hâlâ onaylı DEV/TEST sahiplerini ve zamanlamaları gerektiriyor.
- Gelecekteki `019+` migration'lar, finans, içe/dışa aktarma sahneleme, varlık
  notları veya ürün şablonu tabloları eklemeden önce sahip onayı gerektirir.
- Açık P0-P3 teslimat boşlukları her PR/commit incelemesinden sonra
  `16__delivery_gap_register.sql`'den incelenmelidir.
- Kalan sahip aksiyonları, schema veya iş oluşturmadan önce
  `17__remaining_work_cockpit.sql`'den atanmalıdır.

## Sonraki Önerilen Çalışma

1. İfşa edilmiş GitHub token'ını iptal edin/döndürün.
2. Commit/PR incelemesinden sonra `16__delivery_gap_register.sql` çalıştırın ve
   açık boşluk satırlarını güncel tutun.
3. Kanıt, 019+ kararı, bridge sıralaması ve DBA devir aksiyonlarını atamak için
   `17__remaining_work_cockpit.sql` çalıştırın.
4. Onaylı SQL Server hedefiyle TEST/PROD yürütme kanıtı toplayın.
5. Onaylı ortam prosedürünü kullanarak TEST/PROD erişim inceleme kanıtı toplayın.
6. TEST/PROD geri yükleme tatbikatı çalıştırın ve kanıt kaydedin.
7. `019+` tasarım adaylarını yalnızca sahip onayından sonra önceliklendirin.
8. DEV/TEST altyapı sahipleri zamanlamaları onayladıktan sonra izleme/iş hazırlık
   ızgaralarını onaylı SQL Agent işlerine dönüştürün.
