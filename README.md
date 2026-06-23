<div align="center">

<img src="https://img.shields.io/badge/SQL%20Server-2022-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white"/>
<img src="https://img.shields.io/badge/.NET-8.0-512BD4?style=for-the-badge&logo=dotnet&logoColor=white"/>
<img src="https://img.shields.io/badge/Azure-App%20Service-0089D6?style=for-the-badge&logo=microsoftazure&logoColor=white"/>
<img src="https://img.shields.io/badge/Docker-Enabled-2496ED?style=for-the-badge&logo=docker&logoColor=white"/>

# Yafes Pars — Sigorta Yönetim Sistemi

**Brokerlik ve sigorta operasyonları için SQL Server tabanlı çok kiracılı yönetim platformu.**

[![SQL Server Validation](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/sql-server-validation.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/sql-server-validation.yml)
[![Database Quality Gate](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/database-quality-gate.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/database-quality-gate.yml)
[![Backend Build](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/backend-build.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/backend-build.yml)
[![SSMS Workbench](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/ssms-workbench-validation.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/ssms-workbench-validation.yml)

</div>

---

## Nedir?

Yafes Pars; poliçe, hasar, müşteri, görev, belge ve denetim iş akışlarını tek bir SQL Server veritabanında birleştiren **SSMS-first** bir sigorta operasyon platformudur.

Kullanıcı deneyiminin merkezi bir web arayüzü değil, SQL Server Management Studio'dur: Query Editor, Results Grid, SQLCMD Mode, yönlendirilmiş scriptler ve güvenli bridge template'leri.

> **Canlı Simülasyon →** [`simulation/index.html`](simulation/index.html) dosyasını tarayıcıda açarak SSMS arayüzünün interaktif tutorial'ını görebilirsiniz.

---

## Mimari

```
┌─────────────────────────────────────────────────────────┐
│                     SSMS Operator                       │
│           Query Editor · Results Grid · SQLCMD          │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│              SQL Server 2022 — YafesPars DB             │
│                                                         │
│  person · policy · claim · task · document · tenant     │
│  risk · coverage · finance · security · audit           │
│                                                         │
│  108 tablo  ·  19 migration  ·  11 domain şeması        │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│           .NET 8 Web API (Dapper + Minimal API)         │
│      JWT/OIDC · Rate Limiting · Application Insights    │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│                  Azure App Service                      │
│      Key Vault · Log Analytics · GHCR · Bicep IaC      │
└─────────────────────────────────────────────────────────┘
```

---

## Özellikler

| Alan | Kapsam |
|------|--------|
| **Müşteri & Kurum** | Gerçek/tüzel kişi, adres, iletişim, belge |
| **Risk & Poliçe** | Sözleşme, taraf, nesne, teminat, prim |
| **Hasar** | Olay kaydı, ödeme, kapanış iş akışı |
| **Görev & Belge** | Görev atama, yorum, belge bağlama |
| **Tenant & RBAC** | Çok kiracılı izolasyon, rol/yetki matrisi |
| **Denetim** | Değişiklik kaydı, audit trail, güvenlik |
| **Backend API** | 25+ endpoint, stored procedure entegrasyonu |
| **CI/CD** | GitHub Actions → GHCR → Azure Bicep deploy |

---

## Veritabanı Şeması

```
11 Domain Şeması · 108 Tablo · 19 Migration
─────────────────────────────────────────────
person     →  NaturalPersons, LegalPersons, Addresses, Contacts
policy     →  Contracts, ContractParties, ContractObjects
coverage   →  CoverageItems, Premiums
claim      →  Claims, Payments, ClaimDocuments
risk       →  RiskObjects, Vehicles, Properties
task       →  Tasks, TaskComments, TaskDocuments
document   →  Documents, DocumentLinks
finance    →  Invoices, PaymentPlans
security   →  Users, Roles, Permissions, UserRoles
tenant     →  Tenants, TenantSettings
audit      →  AuditLogs, ChangeHistory
```

---

## Hızlı Başlangıç

### SSMS ile (Birincil İş Akışı)

```sql
-- 1. Bağlan: yafespars-sql veya localhost,1433
-- 2. Veritabanı: YafesPars

-- Dashboard'u aç
:r database/ssms/05__operator_dashboard_home.sql

-- Günlük kontrol
:r database/ssms/10__daily_operator_checklist.sql
```

> `Query → SQLCMD Mode` açık olmalıdır.

### Script Sırası

| # | Script | Amaç |
|---|--------|-------|
| 1 | `00__open_first_safety_check.sql` | Sunucu ve veritabanı doğrulama |
| 2 | `05__operator_dashboard_home.sql` | Ana dashboard sekmesi |
| 3 | `10__daily_operator_checklist.sql` | Günlük hazırlık kontrolleri |
| 4 | `06__query_library_shortcuts.sql` | Kayıt arama ve ID kopyalama |
| 5 | `07__data_entry_bridge_templates.sql` | Kişi, poliçe, hasar oluşturma |
| 6 | `08__data_editing_guardrails.sql` | Güvenli veri güncelleme |
| 7 | `09__graph_report_pack.sql` | Rapor ve grafik gridleri |
| 8 | `04__admin_security_audit_queries.sql` | RBAC ve denetim |

---

### Docker ile Yerel Çalıştırma

```bash
# .env oluştur
cp .env.example .env

# Başlat
docker compose up -d

# Migration'ları çalıştır
$env:YAFES_SQL_SERVER = "localhost,1433"
$env:YAFES_SQL_DATABASE = "YafesPars_DEV"
./database/tools/run-dev-migrations.ps1
```

### Backend API

```bash
cd backend/src/YafesPars.Api
dotnet run

# Swagger: http://localhost:5000/swagger
# Health:  http://localhost:5000/health
```

---

## Proje Yapısı

```
Yafes_Pars/
├── database/
│   ├── migrations/          # 001–018 sıralı migration scriptleri
│   ├── ssms/                # SSMS operator scriptleri
│   ├── stored-procedures/   # İş mantığı SP'leri
│   └── tools/               # CI/CD ve migration araçları
├── backend/
│   └── src/
│       ├── YafesPars.Api/           # Minimal API endpoints
│       ├── YafesPars.Application/   # CQRS commands & queries
│       └── YafesPars.Infrastructure/ # Dapper + repositories
├── infra/
│   ├── main.bicep           # Azure App Service, Key Vault, App Insights
│   └── main.bicepparam      # Parametre dosyası
├── simulation/
│   └── index.html           # İnteraktif SSMS tutorial simülasyonu
├── docs/
│   └── kullanim-kilavuzu.md # Türkçe kullanım kılavuzu
├── Dockerfile               # Multi-stage .NET 8 image
└── docker-compose.yml       # API + SQL Server 2022
```

---

## CI/CD Pipeline

```
git push main
    │
    ├─► backend-build.yml        # dotnet build + test
    ├─► sql-server-validation.yml # Migration syntax + sıra kontrolü
    ├─► database-quality-gate.yml # Destructive pattern tarama
    └─► deploy.yml (main)
            │
            ├─► Docker build → GHCR push
            ├─► Bicep → Azure App Service deploy
            └─► Smoke test (health check)
```

---

## Azure Deploy

```bash
# Azure login
az login

# Resource group
az group create --name rg-yafespars-prod --location westeurope

# Bicep deploy
az deployment group create \
  --resource-group rg-yafespars-prod \
  --template-file infra/main.bicep \
  --parameters @infra/main.bicepparam

# Key Vault'a connection string ekle
az keyvault secret set \
  --vault-name <vault-name> \
  --name YafesParsConnectionString \
  --value "Server=...;Database=YafesPars;..."
```

---

## Belgeler

| Yol | İçerik |
|-----|--------|
| [`docs/kullanim-kilavuzu.md`](docs/kullanim-kilavuzu.md) | Tam Türkçe kullanım kılavuzu |
| [`md/database/architecture.md`](md/database/architecture.md) | Veritabanı mimarisi |
| [`md/database/domain-model.md`](md/database/domain-model.md) | Domain model açıklamaları |
| [`md/ssms/operator-workbench.md`](md/ssms/operator-workbench.md) | SSMS operator kılavuzu |
| [`md/ssms/tutorials/`](md/ssms/tutorials/) | Adım adım tutorial serisi |
| [`SECURITY.md`](SECURITY.md) | Güvenlik politikası |

---

## Gereksinimler

- SQL Server 2022 (Developer veya Express yerel, Azure SQL üretim)
- SSMS 19+ veya Azure Data Studio
- .NET 8 SDK (backend için)
- Docker Desktop (isteğe bağlı)
- PowerShell 7+ (migration araçları için)

---

<div align="center">

**Yafes Pars** · SQL Server 2022 · .NET 8 · Azure · MIT License

</div>
