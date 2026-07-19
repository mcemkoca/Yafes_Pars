# Üretim Hazırlık Kontrol Listesi

Yafes Pars'ı üretim SQL Server ortamı için hazır ilan etmeden önce bu kontrol
listesini kullanın. ✅ ile işaretlenmiş öğeler mevcut depo durumunda doğrulanmıştır.

## Depo

- ✅ `000`'dan `018`'e migration sırası değişmedi (toplam 49 migration, `048`'e kadar)
- ✅ Tüm yeni migration'lar `019`'dan başlıyor
- ✅ Statik SQL kalite kapısı geçiyor (CI yeşil)
- ✅ SQL Server doğrulama iş akışı geçiyor (CI yeşil)
- ✅ SSMS çalışma tezgahı doğrulama iş akışı geçiyor (CI yeşil)
- ✅ Backend derlemesi ve entegrasyon testleri geçiyor (CI yeşil)
- ✅ README, dağıtım, güvenlik, yedek ve runbook belgelerine bağlantı veriyor
- ✅ Tablo mutabakatı `89 vs 108 vs 144` kabul edildi (`md/database/table-reconciliation-89-vs-108.md`)
- ✅ Depoda secret, token, bağlantı dizesi, yedek veya üretim verisi yok

## Veri Tabanı Schema'sı

- ✅ 15 domain schema'sı: core, ref, person, institution, risk, policy, coverage, claim, document, tasking, audit, finance, import, communication, assurance
- ✅ 144 tablo (49 migration)
- ✅ Schema'lar, kısıtlamalar, indeksler, trigger'lar, view'lar, procedure'lar, seed verisi DEV'de doğrulandı
- ✅ Tenant farkında sorgu ve mutasyon yolları doğrulandı (tüm SP bridge'ler tenant_id kontrolü içeriyor)
- ✅ RBAC seed verisi incelendi (4 rol, `14__admin_role_permission_matrix.sql`'de izin matrisi)
- ✅ Denetim trigger'ları doğrulandı (`011__create_audit_domain.sql`)
- [ ] TEST provası manuel script düzenlemeleri olmadan tamamlandı → `md/reports/test-migration-evidence.md`
- [ ] `018__seed_demo_data.sql` PROD çalışmasından hariç tutuldu

## MCP Araçları (Backend)

- ✅ 33 MCP araç sınıfı, hepsi `[McpServerToolType]` (bkz. `md/reports/mcp-gap-analysis.md`)
- ✅ Yenileme pipeline araçları: GetRenewalQueue, ProcessRenewal, SendRenewalNotices, GetRenewalMetrics
- ✅ Prim hesaplama araçları: CalculatePremium, GetPremiumSummary, GetTariffRates, UpsertTariffRate
- ✅ Eski içe aktarma araçları: ImportLegacyPersons, GetLegacyImportSummary, GetLegacyImportErrors
- ✅ Dışa aktarma işi araçları: StageImportRows, ValidateImportBatch, GetImportBatchStatus (+ bridge aksiyonları)
- ✅ JWT tenant kapsamlı okumalar; üretim JWT otorite/kitle zorunlu

## SSMS Bridge Şablonları

- ✅ `07__data_entry_bridge_templates.sql`'de 22 PREVIEW_FIRST bridge aksiyonu
- ✅ Tam yazma kapsamı: kişi, tüzel kişi, poliçe, versiyon, taraf, nesne, araç, gayrimenkul, teminat kalemi, hasar, uzlaşma, rezerv, görev, yorum, hatırlatıcı, belge, ödeme, ödeme planı, dışa aktarma işi
- ✅ Tüm SSMS script'lerinde DEV koruması (DB_NAME LIKE '%DEV%')

## Operasyonlar

- ✅ Azure Windows Server dağıtım mimarisi belgelendi
- ✅ SQL Server kurulum kontrol listesi belgelendi
- ✅ Yedek ve geri yükleme stratejisi belgelendi
- ✅ DEV geri yükleme tatbikatı tamamlandı (`md/reports/restore-drill-evidence-dev-2026-06-04.md`)
- ✅ DEV erişim incelemesi tamamlandı (`md/reports/access-review-evidence-dev-2026-06-04.md`)
- ✅ SSMS dağıtım runbook'u mevcut (`md/database/ssms-deployment-runbook.md`)
- ✅ Migration yürütme günlüğü şablonu mevcut
- ✅ SQL Agent kurulum script'i güçlendirildi (`18__sql_agent_job_setup.sql`)
- [ ] SQL Agent DBA onayı imzalandı → `md/reports/sql-agent-dba-approval.md`
- [ ] TEST geri yükleme tatbikatı tamamlandı → `md/reports/test-restore-drill-report.md`
- [ ] TEST erişim incelemesi imzalandı → `md/reports/access-review-evidence-test.md`
- [ ] TEST migration kanıtı toplandı → `md/reports/test-migration-evidence.md`
- [ ] İzleme sahibi atandı
- [ ] `15__monitoring_and_job_readiness.sql` TEST'te incelendi

## Güvenlik

- ✅ Depoda ortam dosyası, token veya secret yok (eser politikası CI kapısı)
- ✅ Kimlik bilgisi rotasyon süreci belgelendi (`md/database/security-hardening.md`)
- [ ] TEST/PROD'da SQL Server ağ erişimi özel ve kısıtlı
- [ ] TEST/PROD'da RDP erişimi kısıtlı
- [ ] SQL girişleri ve Windows grupları en az ayrıcalığa uyuyor (TEST kanıtı)
- [ ] Secret'lar Git dışında saklanıyor (hedef ortamda doğrulandı)
- [ ] Üretim destek erişimi denetlenebilir (iki imzalı tatbikat kanıtı)

## PROD'a Özgü Kapılar (TEST geçtikten sonra)

- [ ] İki imzalıyla PROD erişim incelemesi → `md/reports/access-review-evidence-prod.md`
- [ ] İki imzalıyla PROD geri yükleme tatbikatı → `md/reports/prod-restore-drill-report.md`
- [ ] PROD migration penceresi için değişiklik yönetimi onayı
- [ ] `018__seed_demo_data.sql` açıkça PROD migration çalışmasından hariç tutuldu
- [ ] PROD SQL Agent işleri DBA onayından sonra oluşturuldu

## Canlıya Geçiş Kararı

Canlıya geçiş ancak şu koşullar sağlandığında hazırdır:
1. Tüm depo kontrolleri ✅
2. TEST kanıtı tamamlandı (migration + erişim incelemesi + geri yükleme tatbikatı)
3. SQL Agent DBA onayı imzalandı
4. PROD kanıtı tamamlandı (her biri iki imzalı erişim incelemesi + geri yükleme tatbikatı)
5. Değişiklik yönetimi penceresi onaylandı
