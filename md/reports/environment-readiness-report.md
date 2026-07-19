# Ortam Hazırlık Raporu — 2026-07-19

**Sahip:** Deuterium12{MCK}
**Durum:** DEV — HAZIR | TEST — BEKLEMEDE | PROD — ENGELLENDİ

---

## Yönetici Özeti

Yafes Pars sistemi depo düzeyinde özellik açısından tamdır. Tüm veri tabanı
migration'ları, MCP araçları, bridge şablonları ve CI kapıları yerli yerindedir.
Kalan tek yayın kapıları, bu deponun dışında gerçek SQL Server erişimi gerektiren
ortam tarafı kanıt öğeleridir.

---

## Ortam Durum Matrisi

| Ortam | Migration Yürütmesi | Erişim İncelemesi | Geri Yükleme Tatbikatı | SQL Agent | Genel |
|---|---|---|---|---|---|
| DEV | ✅ DOĞRULANDI | ✅ DOĞRULANDI | ✅ DOĞRULANDI | 🔶 DBA BEKLİYOR | HAZIR |
| TEST | 🔶 BEKLEMEDE | 🔶 BEKLEMEDE | 🔶 BEKLEMEDE | 🔶 DBA BEKLİYOR | ENGELLENDİ |
| PROD | ⛔ HENÜZ DEĞİL | ⛔ HENÜZ DEĞİL | ⛔ HENÜZ DEĞİL | ⛔ HENÜZ DEĞİL | BAŞLAMAДИ |

---

## DEV Kanıtı (Tamamlandı)

| Kanıt Öğesi | Rapor | Tarih | Durum |
|---|---|---|---|
| Migration yürütmesi | `md/reports/dev-validation-evidence-2026-06-04.md` | 2026-06-04 | ✅ DOĞRULANDI |
| Erişim incelemesi | `md/reports/access-review-evidence-dev-2026-06-04.md` | 2026-06-04 | ✅ DOĞRULANDI |
| Geri yükleme tatbikatı | `md/reports/restore-drill-evidence-dev-2026-06-04.md` | 2026-06-04 | ✅ DOĞRULANDI |
| Backend derlemesi / birim testleri | CI: `backend-build.yml` | Sürekli | ✅ YEŞİL |
| SQL kalite kapısı | CI: `ssms-workbench-validation.yml` | Sürekli | ✅ YEŞİL |
| Yazma akışı entegrasyonu | CI: SQL Server container | Sürekli | ✅ YEŞİL |

---

## TEST Ortamı — Bekleyen Öğeler

Şablonlar ve runbook'lar hazır. Tüm öğeler ortam erişimi gerektiriyor.

| Öğe | Şablon/Script | Engel | Durum |
|---|---|---|---|
| Korumalı migration'ları çalıştır | `database/tools/run-dev-migrations.ps1` (TEST için uyarla) | TEST SQL Server erişimi | BEKLEMEDE |
| Erişim incelemesi | `md/database/access-review-evidence-template.md` | Adlandırılmış DBA + TEST erişimi | BEKLEMEDE |
| Geri yükleme tatbikatı | `md/restore/test-restore-drill-plan.md` | TEST yedek dosyaları + geri yükleme hedefi | BEKLEMEDE |
| SQL Agent işi oluşturma | `database/ssms/18__sql_agent_job_setup.sql` | DBA onayı + TEST SQLServerAgent | DBA BEKLİYOR |

---

## PROD Ortamı — Engellendi

PROD yürütmesi, TEST kanıtı tamamlanana kadar engellidir.

| Kapı | Gereksinim | Durum |
|---|---|---|
| TEST kanıtı tamamlandı | Tüm TEST öğeleri imzalandı | TEST'TE ENGELLENDİ |
| Değişiklik yönetimi penceresi | PROD migration için CM onayı gerekli | BAŞLAMAДИ |
| Adlandırılmış imzalılar | Geri yükleme tatbikatı için iki imzalı | DÜZENLENMEDİ |
| PROD geri yükleme tatbikatı | İzole geri yükleme hedefi (PROD'un kendisi değil) | BAŞLAMAДИ |

---

## Depo Hazırlığı (Tamamı Bitti)

| Alan | Öğe | PR | Durum |
|---|---|---|---|
| Veri Tabanı | Migration'lar 000–048 (toplam 49) | Çeşitli | ✅ |
| Veri Tabanı | Doğrulamalar 001–017 (toplam 17) | Çeşitli | ✅ |
| Veri Tabanı | 22 SSMS bridge şablonu | #97, #99, bu oturum | ✅ |
| Veri Tabanı | SQL Agent kurulumu + güvenlik düzeltmesi | PR #99 | ✅ |
| MCP | 33 araç sınıfı, hepsi `[McpServerToolType]` | Çeşitli | ✅ |
| MCP | RenewalTools (4 araç) | Önceden mevcut | ✅ |
| MCP | PremiumCalculatorTools (4 araç) | Önceden mevcut | ✅ |
| MCP | LegacyImportTools (3 araç) | PR #99 | ✅ |
| MCP | ImportTools / ExportJobTools | Önceden mevcut | ✅ |
| CI | Backend derlemesi + birim testleri | CI | ✅ |
| CI | SQL Server yazma akışı entegrasyonu | CI | ✅ |
| CI | SSMS çalışma tezgahı doğrulaması (manifesto, script'ler, kontroller) | CI | ✅ |
| Manifesto | `ssmsScripts` sözleşmesi düzeltildi (`{ count, items }`) | PR #99 | ✅ |
| Belgeler | Erişim inceleme şablonları | Önceden mevcut | ✅ |
| Belgeler | Geri yükleme tatbikatı planları | Önceden mevcut | ✅ |
| Belgeler | MCP boşluk analizi | PR #99 | ✅ |

---

## SQL Agent DBA Onay Paketi

Script: `database/ssms/18__sql_agent_job_setup.sql`

**Oluşturulacak işler:**

| İş | Zamanlama | Çağrılan SP | Tenant |
|---|---|---|---|
| `YafesPars_DailyMarkOverdueInvoices` | Günlük 06:00 | `finance.SP_MarkOverdueInvoices` | N/A |
| `YafesPars_DailyRenewalTasks` | Günlük 07:00 | `tasking.SP_CreateRenewalTasks` | SQLCMD değişkeni |
| `YafesPars_WeeklyFsmaPortfolioCheck` | Pazartesi 08:00 | Satır içi SELECT | N/A |

**Güvenlik notları:**
- `YAFES_SQL_DATABASE` DEV, TEST veya ACC içermiyorsa script sonlanır (RAISERROR seviye 16 + LOG).
- İş 2, tenant araması için SQLCMD değişkeniyle `sp_executesql` kullanır — hard-coded veri tabanı adı yok.
- Tüm işler idempotent: zaten mevcutsa atla.
- `sysadmin` veya `SQLAgentOperatorRole` gerektirir.

**TEST/PROD üzerinde çalıştırmadan önce DBA imzası gereklidir.**

---

## Sonraki Yayın Kapıları (sırasıyla)

1. DBA `18__sql_agent_job_setup.sql`'i inceler ve onaylar → `md/reports/sql-agent-dba-approval.md`'yi imzalar
2. TEST'te migration'ları çalıştır + kanıt topla → `md/reports/test-migration-evidence.md`
3. TEST'te erişim incelemesi çalıştır → `md/reports/access-review-evidence-test.md`
4. TEST'te geri yükleme tatbikatı çalıştır → `md/reports/test-restore-drill-report.md`
5. İki imzalıyla PROD için 2–4 adımlarını tekrarla
6. PROD kanıtını üretim hazırlık kontrol listesiyle birleştir
