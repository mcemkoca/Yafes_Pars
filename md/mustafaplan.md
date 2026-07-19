# Mustafa Plan

Bu Yafes Pars için canlı plandır. Yol haritasını, SSMS uzman değerlendirmesini,
temizlik kararlarını ve sonraki güncelleme kuyruğunu tek bir yerde tutar.

## Mevcut Temel

- Ürün yönü: SSMS öncelikli SQL Server operasyon platformu.
- Birincil kullanıcı yüzeyi: SQL Server Management Studio, Query Editor, Results Grid,
  Messages, SQLCMD Mode ve korumalı script'ler.
- Veri tabanı kapsamı: 11 domain schema'sında 108 tablo.
- Korumalı migration hattı: `000`'dan `018`'e; yeni schema değişiklikleri
  `019+` ile başlar.
- Belgeleme yapısı: operasyonel markdown artık `md/` altında yer almaktadır.
- Kök `README.md`: müşteriye yönelik, İngilizce/Türkçe iki dilli giriş noktası.
- Ürün sahibi ve sürüm atfı: `Deuterium12{MCK}`.
- Teknik çözüm paketi: feature dalında tamamlandı; birleştirme ve
  ortam kanıtları sürüm kapıları olarak kalmaya devam ediyor.

## SSMS Uzman Değerlendirmesi

### Güçlü Yönler

- Domain bölünmesi, içe aktarılan eski paketten daha sağlıklı: `risk`, güvensiz
  genel nesne adlandırmasının yerini aldı ve policy/claim/document/tasking ayrıldı.
- Operatör script'leri SQLCMD değişkenleri, DEV kontrolleri, bilgi ipuçları ve
  salt okunur ya da önce rollback kalıpları kullanıyor.
- CI zaten migration sırasını, SQL Server sözdizimini, yıkıcı SQL
  kalıplarını, SSMS kurallarını ve gerekli belgeleri koruyor.
- SSMS çalışma tezgahı önizlemesi artık gerçek domain sayısını, çalışan bir mantık
  haritasını, tablo kataloğunu ve planlama kartlarını gösteriyor.

### Bu Güncellemede Düzeltildi

- Proje markdown'ı temiz bir `md/` belgeleme merkezine taşındı.
- `md/mustafaplan.md` tek planlama dosyası olarak eklendi.
- İzlenen eski paket `.zip` dosyaları, izlenen `.env` dosyaları ve
  kalan üretim dışı `trust plan` kaynak/varlık klasörü kaldırıldı.
- Secret'lar, veri tabanı yedekleri, VM görüntüleri, paket
  arşivleri ve yerel derleme/çalışma gürültüsü için `.gitignore` genişletildi.
- İzlenen üretim yollarından güvenli olmayan örnek kimlik bilgileri ve genel CORS
  kalıpları kaldırıldı veya karantinaya alındı.
- İzlenen `.env`, paket, yedek, veri tabanı veya VM eserlerinin CI'yı
  başarısız kılması için bir kalite kapısı eseri politikası eklendi.
- `database/ssms/13__visual_workflow_board.sql`, görsel/zihin haritası fikrinin
  SSMS güvenli versiyonu olarak eklendi: domain kartları, alt başlık kartları,
  düğüm/kenar satırları, şablon rotaları ve hazırlık boşlukları.
- Görsel çalışma tezgahı, ayrı bir web öncelikli uygulama gibi davranmak yerine
  yeni SSMS board akışını yansıtacak şekilde güncellendi.
- SSMS çalışma tezgahı önizlemesi için ürünleştirme aşaması başlatıldı: araç çubuğu
  düğmeleri, menü komutları, sonuç sekmeleri, Object Explorer düğümleri, kopyalama/dışa
  aktarma komutları, ayrıştırma, yürütme, iptal ve durum geri bildirimi artık dekoratif
  değil, bağlı.
- Çalışma tezgahı önizlemesi oluşturulmuş bir altyapı manifestosuyla senkronize edildi:
  veri tabanı adı, tenant bağlamı, migration/doğrulama sayıları, SSMS kısayolları,
  schema grupları, tablo sayıları ve backend rota envanteri artık el ile tutulan
  UI sabitlerinden değil depo kaynağından geliyor.
- CI'da backend ve SQL Server doğrulamasının önü açıldı; DEV migration akışı artık
  SQLCMD alıntılanmış tanımlayıcılarla çalışıyor ve kullanışlı hata kayıtları sunuyor.
- Korumalı `000`'dan `018`'e migration hattı ve `001`'den `017`'ye doğrulama hattı
  gerçek bir SQL Server 2022 DEV container'ına karşı doğrulandı.
- `database/ssms/14__admin_role_permission_matrix.sql`, kullanıcı dostu
  RBAC/admin matrisi olarak eklendi: beklenen roller, izinler, tenant kullanıcı
  atamaları, en az ayrıcalık kontrolleri ve devir satırları.
- `md/database/table-reconciliation-89-vs-108.md` eklendi; eski 89 tablo
  kaynağı artık karşılaştırma girdisi olarak kayıt altına alındı ve aktif 108 tablo
  migration modeli gerçeğin kaynağı olmaya devam ediyor.
- `md/trust-plan/` dizini, eski web öncelikli uygulamayı, VM/VHDX'i, paketi
  ve tekrarlanan planlama notlarını kaldırarak temizlendi; yalnızca karşılaştırma
  araştırması ve kısa bir eski referans özeti tutuldu.
- Erişim inceleme ve geri yükleme tatbikatı kanıt şablonları eklendi, ardından
  hazırlık, yedek ve güvenlik belgelerinden bağlantı verildi.
- DEV doğrulama kanıtı `md/reports/dev-validation-evidence-2026-06-04.md` dosyasına
  kaydedildi.
- DEV erişim inceleme kanıtı
  `md/reports/access-review-evidence-dev-2026-06-04.md` dosyasına kaydedildi.
- SQL Server yedeği, `RESTORE VERIFYONLY`, `YafesPars_RESTORE_DEV`'e geri yükleme,
  geri yüklenen doğrulamalar, dashboard kontrolü ve admin matrisi kontrolü aşamalarından
  oluşan bir DEV geri yükleme tatbikatı gerçekleştirildi; kanıt
  `md/reports/restore-drill-evidence-dev-2026-06-04.md` dosyasında.
- Stored procedure bridge'ler, policy tarafları, policy nesneleri, hasar
  işleyicileri, oluşturucu kullanıcılar ve hasar kapama güncelleyici kullanıcılar için
  tenant sahipliği kontrolleriyle güçlendirildi.
- `07__data_entry_bridge_templates.sql`, `CREATE_VEHICLE_OBJECT`,
  `ADD_POLICY_OBJECT` ve `CLOSE_CLAIM` ile birlikte doğru hasar işleyici e-posta
  adresi/`person_id` çözümlemesiyle genişletildi.
- Tasking bridge kapsamı `CREATE_TASK`, `ADD_TASK_COMMENT` ve
  `ADD_TASK_REMINDER` ile genişletildi; bunlar tenant farkında stored procedure'lerle
  destekleniyor.
- `08__data_editing_guardrails.sql`, boş/varsayılan ID'ler güvenli rollback modunda
  hata vermek yerine `NO_TARGET` önizleme satırları gösterecek şekilde güncellendi.
- DEV sağlığı, birikmiş iş, yedek görünürlüğü, SQL Agent gözlemlenen işleri ve
  DBA devir ızgaraları için `database/ssms/15__monitoring_and_job_readiness.sql`
  eklendi.
- `md/ssms/tutorials/09_monitoring_and_jobs.md` dosyasına izleme öğreticisi
  kapsamı eklendi.
- Migration'lar, doğrulamalar, `07`, `08` ve `15` ephemeral container'da SQL Server
  2022'ye karşı doğrulandı.
- Commit inceleme kapanması, bitmemiş teslimat boşlukları, sahip engelleyicileri ve
  sonraki SSMS aksiyonlarının salt okunur SSMS Results Grid çıktısı olarak görünmesi
  için `database/ssms/16__delivery_gap_register.sql` eklendi.
- Açık engelleyicilerin sahip kanıtı, 019+ kararı, bridge sıralaması, SQL Agent
  terfisi ve sürüm kapısı sonuç ızgaralarına dönüşmesi için
  `database/ssms/17__remaining_work_cockpit.sql` eklendi.
- `md/ssms/tutorials/10_delivery_gap_register.md` dosyasına teslimat boşluğu
  öğreticisi kapsamı eklendi.
- Backend domain okumaları kimliği doğrulanmış JWT `tenant_id` claim'ine bağlandı ve
  tenant kapsamlı endpoint'lerden arayan tarafça seçilen tenant tanımlayıcıları kaldırıldı.
- Üretim JWT otorite/kitle yapılandırması zorunlu kılındı, Swagger Development
  ortamıyla kısıtlandı ve veri tabanı sağlık detayları yetkilendirmeyle korundu.
- Backend kapsamı yedi geçen yetkilendirme ve tenant claim testiyle genişletildi.
- Migration çalıştırıcısı, bitişik `019+` migration ve doğrulama script'lerini
  otomatik olarak keşfedecek, yürütecek ve raporlara dahil edecek şekilde güncellendi.
- SQL Server CI, migration'lar ve doğrulamalardan sonra tüm kontrol altındaki SSMS
  operatör script'lerini tek kullanımlık SQL Server veri tabanına karşı çalıştıracak
  şekilde genişletildi.
- Kamuya açık ürün sahipliği ve sürüm atfı `Deuterium12{MCK}` olarak standartlaştırıldı.

### Kalan Riskler ve Boşluklar

| Öncelik | Alan | Bulgu | En İyi Düzeltme |
| --- | --- | --- | --- |
| P0 | Token hijyeni | Koordinasyon sırasında bir token paylaşıldı. İfşa edilmiş olarak değerlendirilmeli. | Token'ı döndürün/iptal edin ve yalnızca GitHub secret'ları veya yerel kimlik bilgisi yöneticisini kullanın. |
| P1 | Çalışma tezgahı önizleme derinliği | Çalışma tezgahı kontrolleri artık bağlı ve manifestodan senkronize, ancak yürütme hâlâ kalıcı değil ve hazırlanmış DEV önizleme verilerini kullanıyor. | Gerçek veri çalışmasını SSMS DEV içinde tutun; SSMS sözleşmesi kararlı hale geldikten sonra backend destekli önizleme davranışı ekleyin. |
| P1 | Operatör izinleri | DEV erişim inceleme kanıtı mevcut, ancak son SQL girişleri/rolleri hâlâ TEST/PROD ortam kanıtına ihtiyaç duyuyor. | Onaylanmış TEST/PROD erişim incelemesini çalıştırın, imzayı kaydedin ve `17__remaining_work_cockpit.sql` üzerinden sahip aksiyonunu takip edin. |
| P1 | Yedek ve geri yükleme | DEV geri yükleme tatbikatı kanıtı mevcut, ancak TEST/PROD geri yükleme tatbikatı kanıtı hâlâ ortama bağımlı. | Onaylanmış TEST/PROD altyapısında geri yükleme tatbikatı çalıştırın, imzayı kaydedin ve `17__remaining_work_cockpit.sql` üzerinden takip edin. |
| ✅ P2 → Tamamlandı | Kılavuzlu bridge kapsamı | Toplam 22 bridge (17'ydi). Eklenenler: CREATE_REAL_ESTATE_OBJECT, ADD_COVERAGE_ITEM, ATTACH_DOCUMENT, RECORD_PAYMENT, CREATE_PAYMENT_PLAN. Temel yazma yüzeyi mülk/yangın sigortası için tamamlandı. | Tamamlandı. |
| ✅ P2 → Tamamlandı | Finans modeli | Faz 17 (migration 045) `finance.LedgerAccount` + `finance.LedgerEntry` çift girişli defter ekledi. Faz 18 (migration 046) FK kısıtlamaları, bileşik indeks ve `SP_FsmaExport`'u iptal edilmiş komisyonları hariç tutacak şekilde düzeltti. | Çözüldü. |
| ✅ P2 → Tamamlandı | İçe/dışa aktarma | LegacyImportTools.cs eklendi (migration 043 boşluğu kapatıldı). ExportJobTools.cs + REGISTER/COMPLETE_EXPORT_JOB bridge'leriyle dışa aktarma işi yaşam döngüsü tamamlandı. | Tamamlandı. |
| P3 | İzleme | SSMS izleme ve iş hazırlık sonuç kümeleri mevcut, ancak onaylanmış SQL Agent işleri ve TEST/PROD zamanlamaları hâlâ ortama bağımlı. | DBA deviri için iş oluşturmadan önce `17__remaining_work_cockpit.sql` kullanın. |

## Temiz Yapı Kuralı

- Kaynak kodu, SQL script'leri ve iş akışlarını işlevsel klasörlerinde tutun.
- İnsan tarafından okunabilir operasyonel belgeleri `md/` altında tutun.
- GitHub'ın gerektirdiği dosyaları alışılmış konumlarda tutun.
- Yerel paketleri, yedekleri, VM görüntülerini, `.env` dosyalarını veya secret'ları commit etmeyin.
- `md/trust-plan/` dizinine eski referans notları olarak bakın, üretim gerçeği olarak değil.

## Sonraki Güncelleme Kuyruğu

1. İfşa edilmiş koordinasyon token'ını döndürün ve aktif token'ın
   Git'te saklanmadığını doğrulayın.
2. Her PR/commit incelemesinden sonra `database/ssms/16__delivery_gap_register.sql`
   çalıştırın ve açık boşluk satırlarını güncel tutun.
3. Sahip kanıtı, 019+ kararları, kenar bridge sıralaması ve DBA devir
   aksiyonlarını atamak için `database/ssms/17__remaining_work_cockpit.sql` çalıştırın.
4. Hedef ortamlar yenilendikten sonra TEST/PROD yürütme kanıtı ekleyin.
5. Operatör, admin, denetçi ve dağıtıcı için TEST/PROD rol/izin kanıtı ekleyin.
6. TEST/PROD geri yükleme tatbikatı kanıtını üretim hazırlık kontrol listesine ekleyin.
7. Migration `019+` adaylarını yalnızca sahip onayından sonra tasarlayın:
   finans/komisyon, içe/dışa aktarma sahneleme, varlık notları, ürün şablonları.
8. Departmana özgü yüksek frekanslı işlemler için daha fazla bridge şablonu ekleyin.
9. DEV/TEST sahipleri ve zamanlamaları onaylandıktan sonra izleme sonuç kümelerini
   onaylanmış SQL Agent işlerine dönüştürün.

## Çalışma Anlaşması

Her güncelleme şunlarla bitmelidir:

- odaklı diff,
- yerel doğrulama,
- commit,
- push,
- kısa rapor.
