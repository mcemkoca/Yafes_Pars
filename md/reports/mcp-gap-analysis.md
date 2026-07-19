# MCP Boşluk Analizi Raporu — 2026-07-19

**Durum:** KAPANDI
**Sahip:** Deuterium12{MCK}

## Kapsam

Migration 040–043 tarafından sunulan tüm stored procedure'lere karşı MCP araç kapsamı
değerlendirmesi ve araç kaydı görünürlük denetimi.

## Kapsam Matrisi

### Migration 040 — `policy.RenewalQueue` (RenewalTools.cs)

| Stored Procedure | MCP Aracı | Durum |
|---|---|---|
| `policy.SP_GetRenewalQueue` | `GetRenewalQueue` | KAPSANDI |
| `policy.SP_ProcessRenewal` | `ProcessRenewal` | KAPSANDI |
| `policy.SP_GetRenewalMetrics` | `GetRenewalMetrics` | KAPSANDI |
| *(toplu bildirim bonusu)* | `SendRenewalNotices` | KAPSANDI |

Tüm yenileme SP'leri kapsandı. E-posta bildirimi araç bonusu — SP_GetRenewalQueue
(PENDING filtresi) + IEmailService + kayıt başına SP_ProcessRenewal (NOTICE_SENT)
çağrısı yapıyor.

### Migration 041 — `finance.TariffRate` (PremiumCalculatorTools.cs)

| Stored Procedure | MCP Aracı | Durum |
|---|---|---|
| `finance.SP_CalculatePremium` | `CalculatePremium` | KAPSANDI |
| `finance.SP_GetPremiumSummary` | `GetPremiumSummary` | KAPSANDI |
| `finance.SP_GetTariffRates` | `GetTariffRates` | KAPSANDI |
| `finance.SP_UpsertTariffRate` | `UpsertTariffRate` | KAPSANDI |

Tam kapsam. Joker karakter tarife (`coverage_type_code = '*'`) SP tarafından işleniyor;
MCP doğru şekilde geçiriyor.

### Migration 043 — `import.Legacy*` (LegacyImportTools.cs — YENİ)

Mevcut `ImportTools.cs`, migration 030'dan `import.PolicyImport`'u hedefliyor — migration
043 tablolarından farklı bir tablo. Migration 043 tablolarını KAPSAMIYOR.

`LegacyImportTools.cs` tarafından belirlenen ve kapatılan boşluk:

| Stored Procedure | MCP Aracı | Durum |
|---|---|---|
| `import.SP_ImportLegacyPersons` | `ImportLegacyPersons` | KAPANDI (yeni) |
| `import.SP_GetImportSummary` | `GetLegacyImportSummary` | KAPANDI (yeni) |
| *(satır içi hata incelemesi)* | `GetLegacyImportErrors` | KAPANDI (yeni) |

Not: `import.SP_ImportLegacyContract` ve `import.SP_ImportLegacyClaim`, migration
043'te mevcut değil — yalnızca `SP_ImportLegacyPersons` ve `SP_GetImportSummary`
mevcut. `GetLegacyImportErrors`, adanmış bir SP olmadan hedefli hata incelemesi için
3 hazırlık tablosuna karşı doğrudan SQL kullanıyor.

## Araç Kaydı Denetimi

`backend/src/YafesPars.McpServer/Tools/` altında 33 araç sınıfı:

| Sınıf | `[McpServerToolType]` | Notlar |
|---|---|---|
| AdminTools | ✅ | |
| AuditQueryTools | ✅ | |
| AuditTools | ✅ | |
| AzureTools | ✅ | |
| ClaimSettlementTools | ✅ | |
| ClaimTools | ✅ | |
| CommissionTools | ✅ | |
| ComplianceTools | ✅ | |
| ComplaintTools | ✅ | |
| DashboardTools | ✅ | |
| DocumentTools | ✅ | |
| EmailTools | ✅ | |
| ExportJobTools | ✅ | |
| FinanceLedgerTools | ✅ | |
| FinanceTools | ✅ | |
| FsmaExportTools | ✅ | |
| ImportTools | ✅ | `import.PolicyImport`'u hedefliyor (migration 030) |
| LegacyImportTools | ✅ | YENİ — `import.Legacy*`'ı hedefliyor (migration 043) |
| NotificationTools | ✅ | |
| OperationalMonitoringTools | ✅ | |
| OperationsTools | ✅ | |
| PaymentTools | ✅ | |
| PersonTools | ✅ | |
| PersonWriteTools | ✅ | |
| PolicyTools | ✅ | |
| PolicyWriteTools | ✅ | |
| PortfolioTools | ✅ | |
| PremiumCalculatorTools | ✅ | |
| ProductionReadinessTools | ✅ | |
| RenewalTools | ✅ | |
| RiskTools | ✅ | |
| TaskTools | ✅ | |
| TenantManagementTools | ✅ | |

33 sınıfın tamamı `[McpServerToolType]` taşıyor. DI kaydı tarama tabanlı
(açık kayıt listesi yok), bu nedenle özelliğe sahip yeni bir sınıf eklemek yeterlidir.

## Manifesto `ssmsScripts` Sözleşme Düzeltmesi

`workbench-manifest.json`'da `ssmsScripts`, `{ count, latest, files }` nesneleri
olan `migrations` ve `validations`'la tutarsız şekilde ham dizi olarak yer alıyordu.

Bu oturumda düzeltildi:
- `ssmsScripts` → manifesto JSON'da `{ "count": 24, "items": [...] }`
- `update-ssms-workbench-manifest.ps1` — `{ count, items }` üretmek için oluşturucu
  güncellendi
- `test-sql-quality-gate.ps1` — tüketici `@($manifest.ssmsScripts).Count`'tan
  `[int]$manifest.ssmsScripts.count`'a güncellendi
- `ssms-workbench-validation.yml` — CI `manifest.ssmsScripts.length`'ten
  `manifest.ssmsScripts.count`'a güncellendi

## SQL Agent Güvenlik Düzeltmeleri (`18__sql_agent_job_setup.sql`)

İki hata bulundu ve düzeltildi:

1. **Zayıf DEV koruması** — Yalnızca `PRINT 'WARN...'` idi; yürütme devam ediyordu.
   `YAFES_SQL_DATABASE` DEV, TEST veya ACC içermiyorsa script sonlanacak şekilde
   `RAISERROR(..., 16, 1) WITH LOG` + `RETURN` olarak düzeltildi.

2. **İş 2'de hard-coded veri tabanı adı** — JOB 2, SQLCMD değişkeni yerine
   `YafesPars_Dev.core.Tenant`'a doğrudan referans veriyordu.
   `$(YAFES_SQL_DATABASE)` kullanan dinamik SQL ile `sp_executesql`'e düzeltildi.

## Track A Durumu (Ortama bağımlı — değişmedi)

| Öğe | Durum | Engel |
|---|---|---|
| TEST/PROD erişim inceleme kanıtı | KANIT_TOPLAMA_BEKLEMEDE | Gerçek DB erişimi gerekiyor |
| TEST/PROD geri yükleme tatbikatı kanıtı | PLAN_HAZIR | Gerçek DB + 2 imzalı gerekiyor |
| SQL Agent DBA onayı | SCRIPT_HAZIR | DBA imzası gerekiyor |
