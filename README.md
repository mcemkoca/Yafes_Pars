# Yafes Pars

[![SQL Server validation](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/sql-server-validation.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/sql-server-validation.yml)
[![Database quality gate](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/database-quality-gate.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/database-quality-gate.yml)
[![SSMS workbench validation](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/ssms-workbench-validation.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/ssms-workbench-validation.yml)
[![Backend build](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/backend-build.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/backend-build.yml)

## English

Yafes Pars is an SSMS-first SQL Server insurance operations platform for broker,
policy, claim, risk, customer, document, task, security, and audit workflows.
The primary user experience is SQL Server Management Studio: Query Editor,
Results Grid, Messages, SQLCMD Mode, guided scripts, bridge templates, guarded
editing, and report grids.

This is not a web-first product. The database core and SSMS operator workbench
come first; the .NET backend is an optional integration foundation.

### What The Client Gets

| Capability | Status | Value |
| --- | --- | --- |
| SQL Server core | Complete through migration `018` | Stable database foundation for DEV validation. |
| 108-table domain model | Available | Customer, institution, risk, policy, coverage, claim, document, task, RBAC, tenant, and audit areas are separated. |
| SSMS operator workbench | Available | Users start from one dashboard and move through safe daily workflows. |
| Working logic map | Available | Domain groups, subheadings, control points, and planning cards are visible from SSMS. |
| Table catalog and FK map | Available | Real SQL Server metadata supports table planning before new migrations. |
| Quality gates | Available | CI protects migration order, SQL Server syntax, destructive patterns, artifact policy, SSMS conventions, and documentation. |
| Documentation hub | Available | Human-readable docs are organized under `md/`. |

### SSMS Operator Flow

Open scripts from `database/ssms/` in SQL Server Management Studio. Enable
`Query > SQLCMD Mode` for files that use `:setvar` or `:r`.

1. `00__open_first_safety_check.sql` - confirm DEV database and safe server.
2. `05__operator_dashboard_home.sql` - keep this open as the SSMS home tab.
3. `11__schema_working_logic_map.sql` - review domain groups and planning cards.
4. `12__table_catalog_and_relationships.sql` - inspect the table catalog and FK map.
5. `10__daily_operator_checklist.sql` - run daily readiness checks.
6. `02__operations_dashboard.sql` - review operational result grids.
7. `06__query_library_shortcuts.sql` - search records and copy IDs from Results Grid.
8. `07__data_entry_bridge_templates.sql` - create data with preview-first bridges.
9. `08__data_editing_guardrails.sql` - update data with rollback-first guardrails.
10. `09__graph_report_pack.sql` - produce chart-ready/export-ready grids.
11. `03__create_renewal_tasks.sql` - run renewal tasks in dry-run mode first.
12. `04__admin_security_audit_queries.sql` - review RBAC, audit, and integrity.

### Documentation

| Path | Purpose |
| --- | --- |
| `md/README.md` | Documentation hub and writing rules. |
| `md/mustafaplan.md` | Living roadmap, expert assessment, risks, and next update queue. |
| `md/database/` | SQL Server architecture, deployment, migration, security, ERD, and readiness docs. |
| `md/ssms/` | SSMS workbench, tutorials, templates, and dashboard plan. |
| `md/backend/` | Optional .NET backend notes. |
| `md/reports/` | Delivery and progress reports. |

### Local Validation

```powershell
./database/tools/test-sql-quality-gate.ps1 -NoReportFile
./database/tools/run-dev-migrations.ps1 -GenerateSsmsScriptOnly
```

Run the guarded DEV migration workflow only against a verified DEV SQL Server:

```powershell
$env:YAFES_SQL_SERVER = "localhost,1433"
$env:YAFES_SQL_DATABASE = "YafesPars_DEV"
$env:YAFES_SQL_USER = "sa"
$env:YAFES_SQL_PASSWORD = "<dev-password>"
$env:YAFES_SQL_BACKUP_DIR = "C:\SqlBackups"

./database/tools/run-dev-migrations.ps1
```

### Next Updates

1. Run full DEV SQL Server validation and attach execution evidence.
2. Rotate any exposed coordination token and keep all credentials outside Git.
3. Review `md/trust-plan/` reference notes and keep only useful SSMS/product lessons.
4. Add role/permission test evidence for operator, admin, auditor, and deployer.
5. Add restore drill evidence to the production readiness checklist.
6. Design migration `019+` candidates only after owner approval: finance,
   import/export staging, entity notes, and product templates.
7. Extend bridge templates for high-frequency operator actions.
8. Add SQL Agent and monitoring result sets after DEV/TEST infrastructure exists.

## Turkce

Yafes Pars, brokerlik ve sigorta operasyonlari icin hazirlanan SSMS-first SQL
Server platformudur. Kullanici deneyiminin merkezi web sitesi degil, SQL Server
Management Studio icindeki Query Editor, Results Grid, Messages, SQLCMD Mode,
rehberli scriptler, bridge template'leri, guardrail guncellemeleri ve rapor
gridleridir.

Bu nedenle ana oncelik veri tabani cekirdegi ve SSMS operator deneyimidir.
.NET backend sadece ileride entegrasyon icin kullanilabilecek yardimci bir
katmandir.

### Musteri Degeri

| Yetenek | Durum | Deger |
| --- | --- | --- |
| SQL Server cekirdegi | `018` migration'a kadar tamam | DEV ortaminda kontrollu dogrulama icin saglam temel. |
| 108 tablolu domain model | Hazir | Musteri, kurum, risk, police, teminat, hasar, dokuman, gorev, RBAC, tenant ve audit ayrildi. |
| SSMS operator workbench | Hazir | Kullanici tek dashboard'dan guvenli gunluk is akisi baslatir. |
| Calisma mantigi haritasi | Hazir | Alanlar, alt basliklar, kontrol noktalari ve plan kartlari SSMS icinde gorunur. |
| Tablo katalogu ve FK haritasi | Hazir | Yeni tablo/migration oncesi gercek SQL Server metadata'si incelenir. |
| Kalite kapilari | Hazir | Migration sirasi, SQL Server syntax, destructive pattern, artifact policy, SSMS standartlari ve dokumanlar kontrol edilir. |
| Dokuman merkezi | Hazir | Okunabilir proje dokumanlari `md/` altinda toplandi. |

### SSMS Calisma Akisi

Scriptleri `database/ssms/` altindan SSMS icinde acin. `:setvar` veya `:r`
kullanan scriptlerde `Query > SQLCMD Mode` acik olmalidir.

1. `00__open_first_safety_check.sql` - DEV veritabani ve guvenli server kontrolu.
2. `05__operator_dashboard_home.sql` - SSMS ana dashboard sekmesi.
3. `11__schema_working_logic_map.sql` - alanlar, alt basliklar ve plan kartlari.
4. `12__table_catalog_and_relationships.sql` - tablo katalogu ve FK haritasi.
5. `10__daily_operator_checklist.sql` - gunluk hazirlik kontrolleri.
6. `02__operations_dashboard.sql` - operasyonel Results Grid ozetleri.
7. `06__query_library_shortcuts.sql` - kayit arama ve ID kopyalama.
8. `07__data_entry_bridge_templates.sql` - preview-first veri olusturma.
9. `08__data_editing_guardrails.sql` - rollback-first veri guncelleme.
10. `09__graph_report_pack.sql` - grafik/export hazir rapor gridleri.
11. `03__create_renewal_tasks.sql` - once dry-run ile yenileme gorevleri.
12. `04__admin_security_audit_queries.sql` - RBAC, audit ve veri kalite kontrolu.

### Dokumanlar

| Yol | Amac |
| --- | --- |
| `md/README.md` | Dokuman merkezi ve yazim kurallari. |
| `md/mustafaplan.md` | Canli plan, uzman degerlendirmesi, riskler ve siradaki isler. |
| `md/database/` | SQL Server mimari, deploy, migration, guvenlik, ERD ve readiness dokumanlari. |
| `md/ssms/` | SSMS workbench, tutorial, template ve dashboard plani. |
| `md/backend/` | Opsiyonel .NET backend notlari. |
| `md/reports/` | Ilerleme ve teslimat raporlari. |

### Sonraki Guncellemeler

1. Gercek DEV SQL Server validation calistirilacak ve execution evidence eklenecek.
2. Paylasilmis/riske girmis token varsa rotate edilecek; credential'lar Git disinda tutulacak.
3. `md/trust-plan/` referans notlari incelenecek; sadece SSMS/urun icin faydali kisimlar kalacak.
4. Operator, admin, auditor ve deployer rolleri icin permission test kaniti eklenecek.
5. Restore drill kaniti production readiness checklist'e eklenecek.
6. `019+` migration adaylari is sahibi onayi ile tasarlanacak: finance,
   import/export staging, entity notes, product templates.
7. Sik kullanilan operator aksiyonlari icin bridge template kapsami artirilacak.
8. DEV/TEST altyapisi netlesince SQL Agent ve monitoring result setleri eklenecek.

## Security

Security policy and vulnerability reporting rules are defined in `SECURITY.md`.
Do not commit credentials, database backups, connection strings, `.env` files,
package archives, VM images, or production data.
