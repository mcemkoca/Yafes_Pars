# Yafes Pars — Kullanım Kılavuzu

> SSMS Sigorta Yönetim Sistemi · .NET 8 Web API · Azure App Service · SQL Server 2022

---

## İçindekiler

1. [Genel Mimari](#1-genel-mimari)
2. [Yerel Geliştirme Ortamı](#2-yerel-geliştirme-ortamı)
3. [Veritabanı Kurulumu](#3-veritabanı-kurulumu)
4. [API Kullanımı](#4-api-kullanımı)
5. [Kimlik Doğrulama (JWT)](#5-kimlik-doğrulama-jwt)
6. [Azure'a Deploy](#6-azureya-deploy)
7. [GitHub Secrets Yapılandırması](#7-github-secrets-yapılandırması)
8. [SSMS Operatör Scriptleri](#8-ssms-operatör-scriptleri)
9. [Sık Karşılaşılan Sorunlar](#9-sık-karşılaşılan-sorunlar)

---

## 1. Genel Mimari

```
[İstemci / SSMS]
      │
      ▼
[Azure App Service]  ← Docker container (ghcr.io/mcemkoca/yafes_pars)
      │
      ├─ JWT doğrulama (Azure AD / Auth0 / Okta)
      ├─ Tenant-aware yetkilendirme
      │
      ▼
[Azure SQL / SQL Server 2022]
      │
      ├─ 11 domain schema (core, person, institution, risk, policy,
      │   coverage, claim, document, tasking, audit, ref)
      └─ 108 tablo · 19 migration · Views + SSMS scriptleri
```

**Katmanlı Backend Mimarisi:**

```
YafesPars.Api          → HTTP endpoints, auth middleware, Swagger
YafesPars.Application  → Read models, repository sözleşmeleri
YafesPars.Infrastructure → Dapper + SQL Server bağlantısı
YafesPars.Domain       → Sabitler, domain kuralları
```

---

## 2. Yerel Geliştirme Ortamı

### Gereksinimler

| Araç | Sürüm |
|------|-------|
| .NET SDK | 8.0+ |
| Docker Desktop | 24+ |
| SQL Server 2022 | (Docker ile otomatik) |
| SSMS | 20+ (opsiyonel, operatör scriptleri için) |

### Docker Compose ile Başlatma

```bash
# Ortam değişkenlerini ayarla
cp .env.example .env
# .env dosyasını düzenle (SA_PASSWORD zorunlu)

# Servisleri başlat (API + SQL Server)
docker compose up -d

# Logları izle
docker compose logs -f api
```

**`.env` dosyası içeriği:**

```env
SA_PASSWORD=YourStr0ng!Pass
AUTH_AUTHORITY=           # JWT provider URL (dev'de boş bırakılabilir)
AUTH_AUDIENCE=            # JWT audience (dev'de boş bırakılabilir)
```

> **Not:** `ASPNETCORE_ENVIRONMENT=Development` iken JWT doğrulama zorlanmaz,
> `AllowedOrigins` kısıtı uygulanmaz. Sadece local dev için uygundur.

### .NET CLI ile Doğrudan Çalıştırma

```bash
cd backend/src/YafesPars.Api

# Connection string ile çalıştır
dotnet run --environment Development \
  --YAFES_SQL_CONNECTION_STRING "Server=localhost,1433;Database=YafesPars;User Id=sa;Password=YourPass;TrustServerCertificate=True;"
```

Swagger UI: `http://localhost:5000/swagger`
Health check: `http://localhost:5000/health`

---

## 3. Veritabanı Kurulumu

### Migration Sırası

```
database/migrations/
  000__create_database.sql         ← Önce bu
  001__create_schemas.sql
  002__create_core_infrastructure.sql
  003__create_person_domain.sql
  004__create_institution_domain.sql
  005__create_object_domain.sql
  006__create_contract_domain.sql
  007__create_coverage_domain.sql
  008__create_claim_domain.sql
  009__create_document_domain.sql
  ...
  018__seed_demo_data.sql          ← SADECE dev/test ortamında çalıştır
```

### SSMS'de Migration Çalıştırma

1. SSMS'i açın, SQL Server'a bağlanın
2. `database/migrations/` klasöründeki dosyaları **sırayla** çalıştırın (000 → 018)
3. Migration 018 demo data içerir — production'da **çalıştırmayın**

### Validation

```sql
-- Migration başarıyla uygulandı mı?
SELECT schema_name FROM information_schema.schemata
WHERE schema_name IN ('core','person','institution','risk','policy','coverage','claim','document','tasking','audit','ref')
ORDER BY schema_name;
-- 11 satır dönmeli

-- Tenant sayısı
SELECT COUNT(*) FROM core.Tenant;
```

---

## 4. API Kullanımı

### Base URL

| Ortam | URL |
|-------|-----|
| Local | `http://localhost:8080` |
| Azure Prod | `https://yafespars-prod.azurewebsites.net` |

### Endpoint Listesi

| Method | Endpoint | Açıklama |
|--------|----------|----------|
| GET | `/health` | API sağlık durumu |
| GET | `/health/db` | Veritabanı bağlantı kontrolü |
| GET | `/api/tenants` | Tenant bilgisi |
| GET | `/api/persons?search=&take=` | Müşteri listesi |
| GET | `/api/institutions?search=&take=` | Kurum listesi |
| GET | `/api/risks?search=&take=` | Sigortalı nesne listesi |
| GET | `/api/policies?search=&take=` | Poliçe listesi |
| GET | `/api/claims?search=&take=` | Hasar listesi |
| GET | `/api/documents?ownerEntityType=&take=` | Döküman listesi |
| GET | `/api/tasks?take=` | Görev listesi |
| GET | `/api/coverage?domain=` | Teminat kataloğu |
| GET | `/api/settings/lookups` | Lookup sağlık kontrolü |

### Query Parametreleri

| Parametre | Tür | Varsayılan | Açıklama |
|-----------|-----|-----------|----------|
| `search` | string | - | Ad, kod, numara içinde arama (LIKE) |
| `take` | int | 50 | Sonuç sayısı (max 200) |
| `domain` | string | - | Coverage domain filtresi |
| `ownerEntityType` | string | - | `Policy`, `Claim` vb. |

### Örnek İstek

```bash
# Bearer token ile poliçe listesi
curl -s https://yafespars-prod.azurewebsites.net/api/policies?search=AUT&take=10 \
  -H "Authorization: Bearer <JWT_TOKEN>" | jq .
```

```json
[
  {
    "contractNumber": "AUT-2024-001234",
    "companyName": "Güven Sigorta A.Ş.",
    "policyHolderName": "Ahmet Yılmaz",
    "startDate": "2024-01-01",
    "endDate": "2025-01-01",
    "status": "Active"
  }
]
```

---

## 5. Kimlik Doğrulama (JWT)

Yafes Pars **herhangi bir OIDC-uyumlu provider** ile çalışır.

### Azure AD (Entra ID) — Önerilen

1. Azure Portal → **App registrations** → New registration
   - Name: `YafesPars`
   - Supported account types: Single tenant
2. **Expose an API** → Add scope: `api.read`
3. **Certificates & secrets** → New client secret (not et)
4. `appsettings.Production.json` veya App Service ayarlarını güncelle:

```json
{
  "Authentication": {
    "Authority": "https://login.microsoftonline.com/{TENANT_ID}/v2.0",
    "Audience": "api://{CLIENT_ID}"
  }
}
```

### Auth0 (Alternatif)

```json
{
  "Authentication": {
    "Authority": "https://{YOUR_DOMAIN}.auth0.com/",
    "Audience": "{YOUR_API_IDENTIFIER}"
  }
}
```

### JWT Token Yapısı

API, `tenant_id` claim'ini okur. Token içinde bu claim zorunludur:

```json
{
  "sub": "user-uuid",
  "tenant_id": "00000000-0000-0000-0000-000000000001",
  "aud": "api://yafespars",
  "exp": 1234567890
}
```

---

## 6. Azure'a Deploy

### Ön Koşullar

- Azure hesabı + subscription
- Azure CLI kurulu (`az login`)
- GitHub repository'de Actions etkin

### Adım 1 — Resource Group Oluştur

```bash
az group create \
  --name rg-yafespars-prod \
  --location westeurope
```

### Adım 2 — Bicep ile Infrastructure Deploy Et

```bash
az deployment group create \
  --resource-group rg-yafespars-prod \
  --template-file infra/main.bicep \
  --parameters \
      containerImage=ghcr.io/mcemkoca/yafes_pars \
      jwtAuthority="https://login.microsoftonline.com/{TENANT_ID}/v2.0" \
      jwtAudience="api://{CLIENT_ID}" \
      corsAllowedOrigins="https://yourfrontend.com"
```

### Adım 3 — SQL Bağlantı String'ini Key Vault'a Ekle

```bash
az keyvault secret set \
  --vault-name kv-yafespars-prod \
  --name sql-connection-string \
  --value "Server=your-sql-server.database.windows.net;Database=YafesPars;Authentication=Active Directory Managed Identity;"
```

### Adım 4 — GitHub Actions ile Otomatik Deploy

`main` branch'e push yapıldığında `.github/workflows/deploy.yml` otomatik tetiklenir:

1. Docker image build & push → GHCR
2. Bicep ile Azure infra güncelleme
3. Smoke test (health check)

### Azure SQL Server Kurulumu

```bash
# Azure SQL Server oluştur
az sql server create \
  --name yafespars-sql-prod \
  --resource-group rg-yafespars-prod \
  --location westeurope \
  --admin-user sqladmin \
  --admin-password "YourStr0ng!Pass"

# Database oluştur
az sql db create \
  --resource-group rg-yafespars-prod \
  --server yafespars-sql-prod \
  --name YafesPars \
  --edition Standard \
  --capacity 10

# Migration çalıştır (SSMS veya sqlcmd ile)
```

---

## 7. GitHub Secrets Yapılandırması

Repo → **Settings** → **Secrets and variables** → **Actions** altına ekleyin:

| Secret | Açıklama | Örnek |
|--------|----------|-------|
| `AZURE_CLIENT_ID` | Service principal client ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_TENANT_ID` | Azure AD tenant ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_RESOURCE_GROUP` | Resource group adı | `rg-yafespars-prod` |
| `JWT_AUTHORITY` | OIDC authority URL | `https://login.microsoftonline.com/{id}/v2.0` |
| `JWT_AUDIENCE` | API audience | `api://yafespars` |
| `CORS_ALLOWED_ORIGINS` | İzinli frontend origin | `https://yourapp.com` |

### Service Principal Oluşturma

```bash
az ad sp create-for-rbac \
  --name "yafespars-github-actions" \
  --role Contributor \
  --scopes /subscriptions/{SUBSCRIPTION_ID}/resourceGroups/rg-yafespars-prod \
  --sdk-auth
```

Çıktıdaki `clientId`, `tenantId`, `subscriptionId` değerlerini ilgili secret'lara kopyalayın.

---

## 8. SSMS Operatör Scriptleri

`database/ssms/` klasöründe 18 adet hazır script bulunur:

| Script | Açıklama |
|--------|----------|
| `01_dashboard.sql` | Genel sistem özeti |
| `02_customer_search.sql` | Müşteri arama |
| `03_policy_management.sql` | Poliçe yönetimi |
| `04_claim_workflow.sql` | Hasar iş akışı |
| `05_task_cockpit.sql` | Görev takibi |
| `06_security_audit.sql` | Güvenlik denetim raporu |
| `07_monitoring.sql` | Sistem izleme |
| ... | ... |

### SSMS'de Kullanım

1. SSMS'i açın
2. `database/ssms/` içindeki `.sql` dosyasını açın
3. Bağlantı parametrelerini (`@TenantId`, `@StartDate` vb.) düzenleyin
4. `F5` ile çalıştırın

---

## 9. Sık Karşılaşılan Sorunlar

### API başlamıyor — `Authentication:Authority is required`

**Neden:** Production ortamında JWT ayarları eksik.

**Çözüm:**
```bash
# App Service'te ortam değişkenini ayarla
az webapp config appsettings set \
  --resource-group rg-yafespars-prod \
  --name yafespars-prod \
  --settings Authentication__Authority="https://..." Authentication__Audience="api://..."
```

---

### `Could not connect to SQL Server`

**Neden:** Connection string yanlış veya Key Vault erişimi yok.

**Kontrol:**
```bash
# Key Vault secret var mı?
az keyvault secret show --vault-name kv-yafespars-prod --name sql-connection-string

# App Service managed identity Key Vault'a erişebiliyor mu?
az role assignment list --assignee <principalId> --scope /subscriptions/.../kv-yafespars-prod
```

---

### CORS hatası (frontend'den API'ye istek yapılamıyor)

**Neden:** `Cors:AllowedOrigins` boş veya yanlış.

**Çözüm:**
```bash
az webapp config appsettings set \
  --resource-group rg-yafespars-prod \
  --name yafespars-prod \
  --settings Cors__AllowedOrigins__0="https://yourfrontend.com"
```

---

### Migration çalıştırma sırası bozuldu

**Kontrol:**
```sql
SELECT * FROM core.MigrationHistory ORDER BY applied_at_utc;
```

Eksik migration'ları sırayla tekrar çalıştırın. Idempotent scriptler tekrar çalıştırılabilir.

---

### Docker image pull hatası (private GHCR)

```bash
# GHCR'a login ol
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Image'ı çek
docker pull ghcr.io/mcemkoca/yafes_pars:latest
```

---

## Versiyon Geçmişi

| Tarih | Değişiklik |
|-------|-----------|
| 2026-06-23 | Dockerfile, docker-compose, Bicep IaC, CI/CD deploy pipeline eklendi |
| 2026-06-23 | HTTPS middleware, CORS policy, global exception handler eklendi |
| 2026-06-04 | 19 migration tamamlandı (000–018) |
| 2026-06-02 | Backend API v1 (read endpoints) |
