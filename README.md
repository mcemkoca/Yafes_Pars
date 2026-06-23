<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://capsule-render.vercel.app/api?type=waving&color=0:0a1628,50:007acc,100:0a84ff&height=200&section=header&text=Yafes%20Pars&fontSize=52&fontColor=ffffff&fontAlignY=38&desc=Sigorta%20Y%C3%B6netim%20Sistemi%20%C2%B7%20SQL%20Server%202022&descAlignY=58&descSize=16&descColor=9fc6e8&animation=fadeIn">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:0a1628,50:007acc,100:0a84ff&height=200&section=header&text=Yafes%20Pars&fontSize=52&fontColor=ffffff&fontAlignY=38&desc=Sigorta%20Y%C3%B6netim%20Sistemi%20%C2%B7%20SQL%20Server%202022&descAlignY=58&descSize=16&descColor=9fc6e8&animation=fadeIn" alt="Yafes Pars Banner">
</picture>

<br/>

[![SQL Server](https://img.shields.io/badge/SQL_Server-2022-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)](https://www.microsoft.com/sql-server)
[![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)](https://dotnet.microsoft.com)
[![Azure](https://img.shields.io/badge/Azure-App_Service-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com)

<br/>

[![SQL Server Validation](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/sql-server-validation.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/sql-server-validation.yml)
[![Database Quality Gate](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/database-quality-gate.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/database-quality-gate.yml)
[![Backend Build](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/backend-build.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/backend-build.yml)
[![SSMS Workbench](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/ssms-workbench-validation.yml/badge.svg)](https://github.com/mcemkoca/Yafes_Pars/actions/workflows/ssms-workbench-validation.yml)

<br/>

**Brokerlik ve sigorta operasyonları için SQL Server tabanlı çok kiracılı yönetim platformu.**

[🎮 Canlı Demo](#-simülasyon) · [📖 Dökümanlar](#-belgeler) · [🚀 Başlangıç](#-hızlı-başlangıç) · [☁️ Azure Deploy](#-azure-deploy)

</div>

---

## 🗂️ Nedir?

Yafes Pars; **poliçe, hasar, müşteri, görev, belge ve denetim** iş akışlarını tek bir SQL Server veritabanında birleştiren SSMS-first sigorta operasyon platformudur.

> Kullanıcı deneyiminin merkezi bir web arayüzü değil **SQL Server Management Studio**'dur: Query Editor, Results Grid, SQLCMD Mode, yönlendirilmiş scriptler ve saklı yordam köprüleri.

---

## 🎮 Simülasyon

SSMS arayüzünün nasıl kullanıldığını görmek için tarayıcıda açın:

```
simulation/index.html
```

➡️ Sunucuya bağlanma · Nesne Gezgini · Tablo sorgulama · SQL yazma · Saklı yordam çalıştırma — **9 adımlı interaktif tutorial**

---

## 🏗️ Mimari

```
╔══════════════════════════════════════════════════════════╗
║              SSMS Operator (Birincil Arayüz)            ║
║         Query Editor · Results Grid · SQLCMD Mode       ║
╚═══════════════════════════╤══════════════════════════════╝
                            │
╔═══════════════════════════▼══════════════════════════════╗
║           SQL Server 2022 — YafesPars                   ║
║                                                          ║
║  person  ·  policy  ·  claim  ·  task  ·  document      ║
║  risk    ·  coverage ·  finance · security · audit       ║
║  tenant                                                  ║
║                                                          ║
║       108 tablo  ·  19 migration  ·  11 şema            ║
╚═══════════════════════════╤══════════════════════════════╝
                            │
╔═══════════════════════════▼══════════════════════════════╗
║          .NET 8 Web API  (Dapper · Minimal API)         ║
║     JWT/OIDC · Rate Limiting · Application Insights     ║
╚═══════════════════════════╤══════════════════════════════╝
                            │
╔═══════════════════════════▼══════════════════════════════╗
║                   Azure App Service                     ║
║      Key Vault  ·  Log Analytics  ·  GHCR  ·  Bicep    ║
╚══════════════════════════════════════════════════════════╝
```

---

## ✨ Özellikler

<table>
<tr>
<td width="50%">

### 👤 Müşteri & Kurum
Gerçek/tüzel kişi, adres, iletişim, belge yönetimi. Çoklu tenant izolasyonu ile her acenteye ayrı veri alanı.

### 📋 Poliçe Yönetimi
Sözleşme, taraf, nesne, teminat ve prim takibi. Kasko, sağlık, konut, hayat domain'leri.

### 🚨 Hasar Yönetimi
Olay kaydı, ekspertiz, ödeme takibi ve kapanış iş akışı. Belge bağlama ve audit trail.

</td>
<td width="50%">

### ✅ Görev & Belge
Görev atama, yorum, öncelik ve durum takibi. Tüm entity tiplerine belge bağlantısı.

### 🔐 RBAC & Denetim
Çok kiracılı rol/yetki matrisi, kullanıcı yönetimi ve tam audit trail. Least-privilege tasarımı.

### 🔌 Backend API
25+ endpoint, stored procedure entegrasyonu. JWT/OIDC, rate limiting, Application Insights.

</td>
</tr>
</table>

---

## 🗄️ Veritabanı Modeli

<div align="center">

| Şema | Tablolar | Kapsam |
|------|----------|--------|
| `person` | NaturalPersons, LegalPersons, Addresses | Müşteri ve kurum bilgileri |
| `policy` | Contracts, ContractParties, ContractObjects | Poliçe ve sözleşme |
| `coverage` | CoverageItems, Premiums | Teminat ve prim |
| `claim` | Claims, Payments, ClaimDocuments | Hasar ve ödeme |
| `risk` | RiskObjects, Vehicles, Properties | Risk varlıkları |
| `task` | Tasks, TaskComments, TaskDocuments | Görev yönetimi |
| `document` | Documents, DocumentLinks | Belge arşivi |
| `finance` | Invoices, PaymentPlans | Finansal işlemler |
| `security` | Users, Roles, Permissions, UserRoles | RBAC |
| `tenant` | Tenants, TenantSettings | Çok kiracılı yapı |
| `audit` | AuditLogs, ChangeHistory | Denetim izi |

</div>

---

## 🚀 Hızlı Başlangıç

### SSMS ile (Önerilen)

```sql
-- 1. SQL Server'a bağlan: localhost,1433 veya Azure SQL endpoint
-- 2. Veritabanı: YafesPars
-- 3. Query > SQLCMD Mode'u aç

-- Ana dashboard
:r database/ssms/05__operator_dashboard_home.sql

-- Günlük kontrol listesi
:r database/ssms/10__daily_operator_checklist.sql
```

### Script Sırası

| Adım | Script | Amaç |
|------|--------|-------|
| 1 | `00__open_first_safety_check.sql` | Sunucu ve veritabanı doğrulama |
| 2 | `05__operator_dashboard_home.sql` | Ana dashboard |
| 3 | `10__daily_operator_checklist.sql` | Günlük kontroller |
| 4 | `06__query_library_shortcuts.sql` | Kayıt arama |
| 5 | `07__data_entry_bridge_templates.sql` | Veri oluşturma |
| 6 | `08__data_editing_guardrails.sql` | Güvenli güncelleme |
| 7 | `09__graph_report_pack.sql` | Raporlar |
| 8 | `04__admin_security_audit_queries.sql` | RBAC & denetim |

### Docker ile

```bash
# Ortam dosyasını oluştur
cp .env.example .env

# Başlat (API + SQL Server 2022)
docker compose up -d

# Migration'ları çalıştır
$env:YAFES_SQL_SERVER   = "localhost,1433"
$env:YAFES_SQL_DATABASE = "YafesPars_DEV"
./database/tools/run-dev-migrations.ps1
```

### Backend API

```bash
cd backend/src/YafesPars.Api
dotnet run

# Swagger → http://localhost:5000/swagger
# Health  → http://localhost:5000/health
```

---

## ☁️ Azure Deploy

```bash
# Giriş yap
az login

# Resource group oluştur
az group create \
  --name rg-yafespars-prod \
  --location westeurope

# Bicep ile deploy
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

### GitHub Secrets (CI/CD için)

| Secret | Açıklama |
|--------|----------|
| `AZURE_CLIENT_ID` | Azure AD uygulama client ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure abonelik ID |
| `AZURE_RESOURCE_GROUP` | Resource group adı |
| `JWT_AUTHORITY` | OIDC authority URL |
| `JWT_AUDIENCE` | JWT audience değeri |

---

## 📁 Proje Yapısı

```
Yafes_Pars/
├── 📂 database/
│   ├── migrations/          # 001–018 sıralı migration scriptleri
│   ├── ssms/                # SSMS operator scriptleri (00–17)
│   ├── stored-procedures/   # İş mantığı SP'leri
│   └── tools/               # CI/CD ve migration araçları
├── 📂 backend/
│   └── src/
│       ├── YafesPars.Api/           # Minimal API endpoints
│       ├── YafesPars.Application/   # Commands & queries
│       └── YafesPars.Infrastructure/ # Dapper repositories
├── 📂 infra/
│   ├── main.bicep           # Azure IaC (App Service, Key Vault, AI)
│   └── main.bicepparam
├── 📂 simulation/
│   └── index.html           # İnteraktif SSMS tutorial simülasyonu
├── 📂 docs/
│   └── kullanim-kilavuzu.md
├── 📂 md/                   # Teknik belgeler
├── 🐳 Dockerfile
├── 🐳 docker-compose.yml
└── 📋 .github/workflows/    # CI/CD pipeline'ları
```

---

## 🔄 CI/CD Pipeline

```
git push → main
    │
    ├─▶ backend-build.yml          ✓ dotnet build + test
    ├─▶ sql-server-validation.yml  ✓ Migration syntax kontrolü
    ├─▶ database-quality-gate.yml  ✓ Destructive pattern tarama
    └─▶ deploy.yml
            │
            ├─▶ Docker build → GHCR push
            ├─▶ Azure Bicep → App Service deploy
            └─▶ Smoke test (health check)
```

---

## 📖 Belgeler

| Döküman | İçerik |
|---------|--------|
| [`docs/kullanim-kilavuzu.md`](docs/kullanim-kilavuzu.md) | Tam Türkçe kullanım kılavuzu |
| [`md/database/architecture.md`](md/database/architecture.md) | Veritabanı mimarisi |
| [`md/database/domain-model.md`](md/database/domain-model.md) | Domain model |
| [`md/ssms/operator-workbench.md`](md/ssms/operator-workbench.md) | SSMS operator kılavuzu |
| [`md/ssms/tutorials/`](md/ssms/tutorials/) | Tutorial serisi (01–11) |
| [`SECURITY.md`](SECURITY.md) | Güvenlik politikası |

---

## ⚙️ Gereksinimler

- **SQL Server 2022** — Developer Edition (yerel) veya Azure SQL (üretim)
- **SSMS 19+** veya Azure Data Studio
- **.NET 8 SDK** — backend için
- **Docker Desktop** — isteğe bağlı
- **PowerShell 7+** — migration araçları için
- **Azure CLI** — bulut deploy için

---

<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://capsule-render.vercel.app/api?type=waving&color=0:0a84ff,50:007acc,100:0a1628&height=100&section=footer">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:0a84ff,50:007acc,100:0a1628&height=100&section=footer" alt="footer">
</picture>

**SQL Server 2022 · .NET 8 · Azure · MIT License**

</div>
