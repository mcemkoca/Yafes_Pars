# Yafes Pars — Kullanım Kılavuzu

> Sigorta Yönetim Sistemi · SQL Server 2022 · .NET 8 Web API · Azure App Service

---

## İçindekiler

1. [Sisteme Genel Bakış](#1-sisteme-genel-bakış)
2. [Yerel Kurulum (İlk Kez)](#2-yerel-kurulum-ilk-kez)
3. [Veritabanı Kurulumu](#3-veritabanı-kurulumu)
4. [Web Arayüzü (Frontend)](#4-web-arayüzü-frontend)
5. [API Kullanımı](#5-api-kullanımı)
6. [SSMS Operatör Scriptleri](#6-ssms-operatör-scriptleri)
7. [Kimlik Doğrulama (JWT)](#7-kimlik-doğrulama-jwt)
8. [Azure'a Deploy](#8-azureya-deploy)
9. [GitHub Secrets Yapılandırması](#9-github-secrets-yapılandırması)
10. [SQL Agent Jobs](#10-sql-agent-jobs)
11. [İzleme — Application Insights](#11-izleme--application-insights)
12. [Sık Karşılaşılan Sorunlar](#12-sık-karşılaşılan-sorunlar)
13. [Versiyon Geçmişi](#13-versiyon-geçmişi)

---

## 1. Sisteme Genel Bakış

Yafes Pars; **poliçe, hasar, müşteri, görev, belge ve finans** iş akışlarını tek platformda birleştiren çok kiracılı sigorta yönetim sistemidir.

```
┌────────────────────────────────────────────┐
│            Kullanıcı / Tarayıcı            │
│          frontend/index.html               │
└────────────────┬───────────────────────────┘
                 │ HTTP / JSON
┌────────────────▼───────────────────────────┐
│         .NET 8 Minimal API                 │
│   JWT · Rate Limiting · Swagger · CORS     │
└────────────────┬───────────────────────────┘
                 │ Dapper (stored procedures)
┌────────────────▼───────────────────────────┐
│          SQL Server 2022                   │
│  12 şema · 114 tablo · 20 migration        │
│  finance · coverage · risk · document …    │
└────────────────────────────────────────────┘
                 │
┌────────────────▼───────────────────────────┐
│          Azure App Service                 │
│  Key Vault · App Insights · GHCR · Bicep  │
└────────────────────────────────────────────┘
```

### Ne Yapabilirsiniz?

| Alan | Yapabilecekleriniz |
|------|--------------------|
| **Müşteriler** | Kişi ve kurum ekleme, arama, adres/iletişim yönetimi |
| **Poliçeler** | Sözleşme oluşturma, taraf/nesne bağlama, teminat takibi |
| **Hasarlar** | Hasar bildirimi, ekspertiz, ödeme kaydı |
| **Görevler** | Görev atama, yorum, öncelik belirleme |
| **Finans** | Fatura oluşturma, ödeme kaydetme, taksit planı |
| **Belgeler** | Belge yükleme, poliçe/hasara bağlama, arşivleme |
| **Risk** | Araç, mülk ve genel risk objesi yönetimi |
| **Raporlar** | SSMS üzerinden grafik ve dashboard sorguları |

---

## 2. Yerel Kurulum (İlk Kez)

### Gereksinimler

| Araç | Sürüm | Neden? |
|------|-------|--------|
| .NET SDK | 8.0+ | Backend API |
| Docker Desktop | 24+ | SQL Server container |
| SSMS veya Azure Data Studio | 19+ | Veritabanı yönetimi |
| PowerShell | 7+ | Migration araçları |

### Adım 1 — Depoyu Klonla

```bash
git clone https://github.com/mcemkoca/Yafes_Pars.git
cd Yafes_Pars
```

### Adım 2 — Docker ile SQL Server Başlat

```bash
# Ortam dosyasını oluştur
cp .env.example .env
```

`.env` dosyasını açıp şu değerleri ayarlayın:

```env
SA_PASSWORD=YourStr0ng!Pass        # En az 8 karakter, büyük harf + rakam + özel karakter
AUTH_AUTHORITY=                    # Boş bırakın (dev modunda JWT zorunlu değil)
AUTH_AUDIENCE=                     # Boş bırakın
```

```bash
# SQL Server + API'yi başlat
docker compose up -d

# API loglarını izle
docker compose logs -f api
```

### Adım 3 — API'yi Doğrula

```bash
# Sağlık kontrolü
curl http://localhost:8080/health
# → {"status":"Healthy"}
```

Tarayıcıda Swagger: **http://localhost:8080/swagger**

---

## 3. Veritabanı Kurulumu

### Migration Sırası

Migrationlar `database/migrations/` klasöründe **sırayla** uygulanır:

```
000__create_database.sql              ← Veritabanını oluşturur
001__create_schemas.sql               ← 12 şema (person, policy, finance…)
002__create_core_infrastructure.sql   ← Tenant, kullanıcı, RBAC
003__create_person_domain.sql         ← Müşteri tabloları
004__create_institution_domain.sql    ← Kurum tabloları
005__create_object_domain.sql         ← Sigortalı nesne
006__create_contract_domain.sql       ← Poliçe/sözleşme
007__create_coverage_domain.sql       ← Teminat ve prim
008__create_claim_domain.sql          ← Hasar
009__create_document_domain.sql       ← Belge
010__create_task_domain.sql           ← Görev
011__create_audit_domain.sql          ← Denetim izi
012-015__...                          ← Constraint, index, trigger, view
016__add_stored_procedures.sql        ← Saklı yordamlar
017__seed_lookup_data.sql             ← Lookup verileri (zorunlu)
018__seed_demo_data.sql               ← SADECE dev/test ortamında çalıştırın
019__add_finance_document_tables.sql  ← Fatura, ödeme, belge bağlantı tabloları
020__add_write_stored_procedures.sql  ← Write SP'leri (person, risk, coverage, finance, document)
```

> **Not:** Migration 020 Copilot ile SP body'leri rafine etmek için tasarlanmıştır. Stub'lar çalışır durumdadır.

### SSMS ile Migration Çalıştırma (Önerilen)

1. SSMS'i açın, `localhost,1433` adresine `sa` kullanıcısıyla bağlanın
2. **Query → SQLCMD Mode**'u açın (Ctrl+Shift+Q)
3. Migration dosyalarını **000'dan 020'ye** sırayla çalıştırın:

```sql
-- Her dosya için sırayla:
:r C:\Yafes_Pars\database\migrations\000__create_database.sql
:r C:\Yafes_Pars\database\migrations\001__create_schemas.sql
-- ... devam edin
```

### PowerShell ile Otomatik Migration

```powershell
$env:YAFES_SQL_SERVER   = "localhost,1433"
$env:YAFES_SQL_DATABASE = "YafesPars_DEV"
$env:YAFES_SQL_USER     = "sa"
$env:YAFES_SQL_PASSWORD = "YourStr0ng!Pass"

.\database\tools\run-dev-migrations.ps1
```

### Migration Başarısını Doğrulama

```sql
-- Şemaların oluştuğunu doğrula (12 satır dönmeli)
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN (
  'core','ref','person','institution','risk',
  'policy','coverage','claim','document',
  'tasking','audit','finance'
)
ORDER BY schema_name;

-- Tablo sayısını kontrol et (115 civarı)
SELECT COUNT(*) AS table_count
FROM information_schema.tables
WHERE table_type = 'BASE TABLE';

-- Tenant kaydı var mı?
SELECT tenant_code, display_name FROM core.Tenant;
```

---

## 4. Web Arayüzü (Frontend)

`frontend/index.html` dosyası doğrudan tarayıcıda açılabilen tek sayfalık web uygulamasıdır. Harici bağımlılık yoktur, kurulum gerekmez.

### Nasıl Açılır?

**Seçenek A — Dosyadan Doğrudan:**
```
Dosya Gezgini → frontend/index.html → çift tıklayın
```

**Seçenek B — Yerel Sunucuyla:**
```bash
npx serve frontend -p 5501
# → http://localhost:5501
```

### Özellikler

| Ekran | Yapabilecekleriniz |
|-------|--------------------|
| **Dashboard** | Poliçe, hasar, müşteri, görev özeti; son poliçe listesi |
| **Poliçeler** | Tüm poliçeleri listele, ada/numaraya göre filtrele |
| **Hasarlar** | Açık hasar listesi, rezerv tutarları |
| **Müşteriler** | Kişi ve kurumları listele |
| **Görevler** | Görev durumu ve öncelikleri |
| **Finans** | Fatura ve ödeme özeti |
| **Ayarlar** | API adresini değiştir ve bağlantıyı test et |

### API Adresi Ayarlama

Arayüz açıldığında sağ üstte API bağlantı durumu görünür.

1. **Ayarlar** sayfasına gidin (sol menü altı)
2. API Base URL'yi girin:
   - Yerel: `http://localhost:8080`
   - Azure: `https://yafespars-prod.azurewebsites.net`
3. **Kaydet & Test Et** butonuna tıklayın

> **Not:** API bağlı değilse veriler yüklenemez ama arayüz çalışmaya devam eder.

---

## 5. API Kullanımı

### Base URL

| Ortam | URL |
|-------|-----|
| Yerel | `http://localhost:8080` |
| Azure Prod | `https://yafespars-prod.azurewebsites.net` |

### Tüm Endpoint'ler

**Okuma (GET)**

| Endpoint | Parametreler | Açıklama |
|----------|-------------|----------|
| `GET /health` | — | API sağlık durumu |
| `GET /api/persons` | `search`, `take` | Müşteri listesi |
| `GET /api/institutions` | `search`, `take` | Kurum listesi |
| `GET /api/policies` | `search`, `take` | Poliçe listesi |
| `GET /api/claims` | `search`, `take` | Hasar listesi |
| `GET /api/tasks` | `take` | Görev listesi |
| `GET /api/documents` | `ownerEntityType`, `take` | Belge listesi |
| `GET /api/coverage` | `domain` | Teminat kataloğu |
| `GET /api/settings/lookups` | — | Lookup verisi |

**Yazma (POST/PUT) — JWT Gerektirir**

| Endpoint | Açıklama |
|----------|----------|
| `POST /api/persons` | Yeni müşteri oluştur |
| `POST /api/policies` | Yeni sözleşme oluştur |
| `POST /api/claims` | Yeni hasar bildir |
| `POST /api/tasks` | Görev oluştur |
| `POST /api/finance/invoices` | Fatura oluştur |
| `POST /api/finance/invoices/{id}/payments` | Ödeme kaydet |
| `POST /api/finance/payment-plans` | Taksit planı oluştur |
| `POST /api/documents` | Belge ekle |
| `POST /api/documents/links` | Belgeyi entity'ye bağla |
| `POST /api/coverage/items` | Teminat ekle |
| `PUT /api/coverage/items/{id}` | Teminat güncelle |
| `POST /api/risk/vehicles` | Araç risk kaydı |
| `POST /api/risk/properties` | Mülk risk kaydı |

### Örnek İstekler

```bash
# Poliçe listesi (ilk 10)
curl http://localhost:8080/api/policies?take=10 \
  -H "Authorization: Bearer <TOKEN>"

# Yeni müşteri oluştur
curl -X POST http://localhost:8080/api/persons \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Ahmet",
    "lastName": "Yılmaz",
    "nationalId": "12345678901",
    "birthDate": "1985-03-15"
  }'

# Fatura oluştur
curl -X POST http://localhost:8080/api/finance/invoices \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "contractId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "issueDate": "2026-06-24",
    "dueDate": "2026-07-24",
    "amount": 2500.00,
    "currencyCode": "TRY"
  }'

# Ödeme kaydet
curl -X POST http://localhost:8080/api/finance/invoices/{invoiceId}/payments \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "invoiceId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "paymentDate": "2026-06-24",
    "amount": 2500.00,
    "paymentMethodCode": "BANK_TRANSFER"
  }'

# Taksit planı oluştur
curl -X POST http://localhost:8080/api/finance/payment-plans \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "contractId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "installmentCount": 12,
    "firstDueDate": "2026-07-01",
    "totalAmount": 6000.00,
    "currencyCode": "TRY"
  }'

# Araç risk nesnesi oluştur
curl -X POST http://localhost:8080/api/risk/vehicles \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "plateNumber": "34 ABC 001",
    "brand": "Toyota",
    "model": "Corolla",
    "modelYear": 2022,
    "chassisNumber": "JTDBZ42E670018001"
  }'

# Mülk risk nesnesi oluştur
curl -X POST http://localhost:8080/api/risk/properties \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "address": "Bağcılar Mah. Atatürk Cd. No:5 İstanbul",
    "propertyTypeCode": "APARTMENT",
    "constructionArea": 120.0,
    "constructionYear": 2015,
    "insuredValue": 1500000.00,
    "currencyCode": "TRY"
  }'

# Teminat kalemi ekle
curl -X POST http://localhost:8080/api/coverage/items \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "contractId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "coverageTypeCode": "FIRE",
    "coverageLimit": 500000.00,
    "deductible": 5000.00,
    "currencyCode": "TRY"
  }'

# Belge ekle
curl -X POST http://localhost:8080/api/documents \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "documentTypeCode": "POLICY_PDF",
    "fileName": "police-2026-001234.pdf",
    "mimeType": "application/pdf",
    "fileSizeBytes": 204800,
    "description": "Poliçe belgesi"
  }'
```

> **Not:** Write endpoint'lerin iş kuralı mantığı (SP body'leri) Copilot ile geliştirilebilir.
> `database/migrations/020__add_write_stored_procedures.sql` dosyasındaki SP'ler stub'dır ve çalışır durumdadır.

### Swagger ile Etkileşimli Test

Yerel ortamda `http://localhost:8080/swagger` adresini açın.  
Her endpoint için **Try it out** → **Execute** ile test yapabilirsiniz.

---

## 6. SSMS Operatör Scriptleri

`database/ssms/` klasöründe 18 hazır script bulunur. SSMS'de **SQLCMD Mode** açık olmalıdır.

### Kullanım Adımları

1. SSMS'i açın → SQL Server'a bağlanın
2. **Query menüsü → SQLCMD Mode** (Ctrl+Shift+Q)
3. İstediğiniz scripti açın (`Ctrl+O`)
4. Üstteki değişkenleri düzenleyin:
   ```sql
   :SETVAR YAFES_SQL_DATABASE "YafesPars_DEV"
   :SETVAR TENANT_CODE "DEV-BE-BROKER"
   ```
5. `F5` ile çalıştırın

### Script Rehberi

| # | Dosya | Kullanım Amacı | Güvenlik |
|---|-------|---------------|----------|
| 00 | `00__open_first_safety_check.sql` | İlk açılışta sunucu ve DB doğrula | Sadece okur |
| 01 | `01__run_all_dev_migrations_sqlcmd.sql` | Tüm migrationları sırayla çalıştır | Yedek alın! |
| 02 | `02__operations_dashboard.sql` | Günlük operasyon özeti | Sadece okur |
| 03 | `03__create_renewal_tasks.sql` | Yenileme görevi oluştur | DRY_RUN=1 ile test et |
| 04 | `04__admin_security_audit_queries.sql` | RBAC ve denetim raporu | Sadece okur |
| 05 | `05__operator_dashboard_home.sql` | Ana işletmen ekranı | Sadece okur |
| 06 | `06__query_library_shortcuts.sql` | Müşteri/poliçe arama | Sadece okur |
| 07 | `07__data_entry_bridge_templates.sql` | Kayıt oluşturma şablonları | Onay gerekir |
| 08 | `08__data_editing_guardrails.sql` | Güvenli güncelleme | Varsayılan ROLLBACK |
| 09 | `09__graph_report_pack.sql` | Raporlar ve grafikler | Sadece okur |
| 10 | `10__daily_operator_checklist.sql` | Günlük kontrol listesi | Sadece okur |
| 11 | `11__schema_working_logic_map.sql` | Şema mimari haritası | Sadece okur |
| 12 | `12__table_catalog_and_relationships.sql` | Tablo kataloğu ve FK haritası | Sadece okur |
| 13 | `13__visual_workflow_board.sql` | İş akışı görsel tahtası | Sadece okur |
| 14 | `14__admin_role_permission_matrix.sql` | RBAC yetki matrisi | Sadece okur |
| 15 | `15__monitoring_and_job_readiness.sql` | Sistem izleme ve job sağlığı | Sadece okur |
| 16 | `16__delivery_gap_register.sql` | Teslimat açıkları | Sadece okur |
| 17 | `17__remaining_work_cockpit.sql` | Kalan iş paneli | Sadece okur |

### Günlük Operatör Rutini

```
Sabah:
  1. Script 00 → Sunucu ve DB doğrula
  2. Script 05 → Ana dashboard'u aç
  3. Script 10 → Günlük checklist çalıştır

Öğleden Sonra:
  4. Script 02 → Operasyon özetini gözden geçir
  5. Script 06 → Gerekirse müşteri/poliçe ara

Akşam:
  6. Script 09 → Günlük rapor al
  7. Script 15 → Sistem izleme kontrolü
```

---

## 7. Kimlik Doğrulama (JWT)

Yafes Pars **herhangi bir OIDC-uyumlu provider** ile çalışır (Azure AD, Auth0, Okta…).

### Azure AD ile Kurulum (Önerilen)

**Seçenek A — Otomatik (setup-azure.ps1):**

```powershell
.\scripts\setup-azure.ps1 `
  -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
  -SqlPassword    "GucluParola!123" `
  -GithubToken    "ghp_..." `
  -JwtAuthority   "https://login.microsoftonline.com/{TENANT_ID}/v2.0" `
  -JwtAudience    "api://yafespars"
```

Bu script otomatik olarak şunları yapar:
1. Azure AD App Registration oluşturur (parola gerekmez — OIDC Federated Credential)
2. Resource Group ve Bicep altyapısını deploy eder
3. Key Vault'a connection string ekler
4. GitHub Secrets'ı ayarlar

**Seçenek B — Manuel:**

1. Azure Portal → **App registrations → Yeni kayıt**
   - Ad: `YafesPars`
   - Desteklenen hesap: Tek tenant
2. **Expose an API → Kapsam ekle:** `api.read`
3. Uygulama (Client) ID'yi not edin

```json
{
  "Authentication": {
    "Authority": "https://login.microsoftonline.com/{TENANT_ID}/v2.0",
    "Audience": "api://{CLIENT_ID}"
  }
}
```

### JWT Token Yapısı

API, her istekte `tenant_id` claim'ini okur. Token bu alanı içermelidir:

```json
{
  "sub": "kullanici-uuid",
  "tenant_id": "00000000-0000-0000-0000-000000000001",
  "aud": "api://yafespars",
  "exp": 1234567890
}
```

### Geliştirme Ortamında JWT'siz Çalıştırma

`.env` dosyasında `AUTH_AUTHORITY` boş bırakıldığında `Development` modunda JWT doğrulama atlanır:

```bash
ASPNETCORE_ENVIRONMENT=Development dotnet run
```

---

## 8. Azure'a Deploy

### Ön Koşullar

- Azure hesabı + abonelik
- Azure CLI kurulu ve giriş yapılmış (`az login`)
- GitHub repo'da Actions etkin

### Tek Komutla Tam Kurulum

```powershell
.\scripts\setup-azure.ps1 `
  -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
  -SqlPassword    "GucluParola!123" `
  -GithubToken    "ghp_..." `
  -DryRun         # Önce bu flag ile test edin!
```

`-DryRun` kaldırıldığında gerçek kaynaklar oluşturulur.

### Adım Adım Manuel Kurulum

```bash
# 1. Giriş yap
az login
az account set --subscription "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# 2. Resource Group oluştur
az group create --name rg-yafespars-prod --location westeurope

# 3. Bicep ile altyapıyı deploy et
az deployment group create \
  --resource-group rg-yafespars-prod \
  --template-file infra/main.bicep \
  --parameters \
    appName=yafespars \
    jwtAuthority="https://login.microsoftonline.com/{TENANT_ID}/v2.0" \
    jwtAudience="api://yafespars"

# 4. SQL bağlantı string'ini Key Vault'a ekle
az keyvault secret set \
  --vault-name kv-yafespars-prod \
  --name YafesParsConnectionString \
  --value "Server=yafespars-sql.database.windows.net;Database=YafesPars;..."

# 5. Application Insights connection string ekle (opsiyonel)
az keyvault secret set \
  --vault-name kv-yafespars-prod \
  --name AppInsightsConnectionString \
  --value "InstrumentationKey=...;IngestionEndpoint=..."
```

### Otomatik CI/CD Deploy

`main` branch'e her push yapıldığında deploy pipeline otomatik çalışır:

```
git push origin main
    │
    ├─▶ Backend Build & Test
    ├─▶ SQL Validation
    └─▶ Build & Deploy
           ├─▶ Docker build → GHCR push
           ├─▶ Azure Bicep → App Service güncelle
           └─▶ Smoke test (health check)
```

Manuel tetiklemek için: GitHub → **Actions → Build & Deploy → Run workflow**

---

## 9. GitHub Secrets Yapılandırması

**Repo → Settings → Secrets and variables → Actions**

| Secret | Açıklama | Nasıl Edinilir |
|--------|----------|----------------|
| `AZURE_CLIENT_ID` | Service principal Client ID | `setup-azure.ps1` çıktısı |
| `AZURE_TENANT_ID` | Azure AD Tenant ID | `az account show --query tenantId` |
| `AZURE_SUBSCRIPTION_ID` | Abonelik ID | `az account show --query id` |
| `AZURE_RESOURCE_GROUP` | Resource group adı | `rg-yafespars-prod` |
| `JWT_AUTHORITY` | OIDC authority URL | Azure AD App → Overview |
| `JWT_AUDIENCE` | API audience | `api://{CLIENT_ID}` |
| `CORS_ALLOWED_ORIGINS` | Frontend origin | `https://sizin-alan-adiniz.com` |

> **Güvenlik notu:** `setup-azure.ps1` scripti parola yerine **Federated Credential (OIDC)** kullanır. GitHub Actions, Azure'a parola olmadan giriş yapar.

---

## 10. SQL Agent Jobs

`database/tools/create-sql-agent-jobs.sql` scripti 4 otomatik job oluşturur:

| Job | Zamanlama | Yapacağı İş |
|-----|-----------|------------|
| **Daily Renewal Task Creation** | Her gün 06:00 | 30 gün içinde süresi dolacak poliçeler için görev oluşturur |
| **Overdue Invoice Status Update** | Her gün 07:00 | Vadesi geçmiş faturaları OVERDUE olarak işaretler |
| **Audit Log Cleanup** | Her Pazar 02:00 | 90 günden eski audit kayıtlarını temizler |
| **Weekly Database Backup** | Her Cumartesi 01:00 | Tam veritabanı yedeği alır |

### Nasıl Kurulur?

```sql
-- SSMS'de sa veya sysadmin rolüyle:
:r C:\Yafes_Pars\database\tools\create-sql-agent-jobs.sql
```

### Job Durumu Kontrolü

```sql
-- Tüm Yafes Pars job'larını listele
SELECT
    j.name,
    j.enabled,
    CONVERT(NVARCHAR, MAX(h.run_date)) AS last_run_date,
    CASE MAX(h.run_status)
        WHEN 1 THEN 'Başarılı'
        WHEN 0 THEN 'Başarısız'
        ELSE 'Çalışıyor'
    END AS last_status
FROM msdb.dbo.sysjobs j
LEFT JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id
WHERE j.name LIKE 'YafesPars%'
GROUP BY j.name, j.enabled;
```

---

## 11. İzleme — Application Insights

### Yapılandırma

**Azure Portal'dan:**
```bash
# Application Insights oluştur (Bicep zaten kurar, sadece key'i kopyalayın)
az monitor app-insights component show \
  --app ai-yafespars-prod \
  --resource-group rg-yafespars-prod \
  --query connectionString -o tsv
```

**App Service ortam değişkeni olarak ekle:**
```bash
az webapp config appsettings set \
  --resource-group rg-yafespars-prod \
  --name yafespars-prod \
  --settings APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=...;..."
```

**Yerel geliştirmede** `appsettings.json`'a ekleyin:
```json
{
  "APPLICATIONINSIGHTS_CONNECTION_STRING": "InstrumentationKey=...;IngestionEndpoint=..."
}
```

### İzlenebilecekler

- **Canlı Metrikler:** Azure Portal → Application Insights → Live Metrics
- **Hata Takibi:** Failures → Exceptions sekmesi
- **API Performansı:** Performance → Operation Name göre
- **Özel Sorgular:** Logs → Kusto sorguları

```kusto
-- Son 1 saatin istek listesi
requests
| where timestamp > ago(1h)
| summarize count() by name, resultCode
| order by count_ desc
```

---

## 12. Sık Karşılaşılan Sorunlar

### Docker başlatılamıyor — port 1433 kullanımda

```bash
# Hangi uygulama portu kullanıyor?
netstat -ano | findstr :1433
# PID'i not et, sonra:
taskkill /PID <pid> /F
# veya .env dosyasında portu değiştir:
SQL_PORT=1434
```

---

### API başlamıyor — `Authentication:Authority is required`

**Neden:** Production modunda JWT ayarları eksik.

**Çözüm:**
```bash
az webapp config appsettings set \
  --resource-group rg-yafespars-prod \
  --name yafespars-prod \
  --settings \
    Authentication__Authority="https://login.microsoftonline.com/{id}/v2.0" \
    Authentication__Audience="api://yafespars"
```

Veya yerel geliştirmede:
```bash
ASPNETCORE_ENVIRONMENT=Development dotnet run
```

---

### `Could not connect to SQL Server`

```bash
# 1. Container çalışıyor mu?
docker ps | grep sql

# 2. Key Vault secret var mı?
az keyvault secret show \
  --vault-name kv-yafespars-prod \
  --name YafesParsConnectionString

# 3. App Service managed identity erişim yetkisi var mı?
az keyvault show --name kv-yafespars-prod --query properties.accessPolicies
```

---

### Docker image pull hatası (private GHCR)

```bash
# GHCR'a giriş yap
echo $GITHUB_TOKEN | docker login ghcr.io -u mcemkoca --password-stdin

# Image'ı çek
docker pull ghcr.io/mcemkoca/yafes_pars:latest
```

---

### Migration bozuldu — tekrar çalıştırmak güvenli mi?

Evet. Tüm migration scriptleri `IF NOT EXISTS` kontrolü kullanır, tekrar çalıştırılabilir.

```sql
-- Hangi migration'lar uygulanmış?
SELECT * FROM core.SchemaMigration ORDER BY applied_at_utc;
```

---

### CORS hatası (frontend'den API'ye istek yapılamıyor)

```bash
# Izinli origin'i güncelle
az webapp config appsettings set \
  --resource-group rg-yafespars-prod \
  --name yafespars-prod \
  --settings Cors__AllowedOrigins__0="https://sizin-frontend.com"
```

Yerel geliştirmede `ASPNETCORE_ENVIRONMENT=Development` tüm origin'lere izin verir.

---

### GitHub Actions — Azure login başarısız

```
Error: Not all values are present. Ensure 'client-id' and 'tenant-id' are supplied
```

**Kontrol listesi:**
1. GitHub → Settings → Secrets → `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` var mı?
2. Değerler `placeholder` içeriyor mu? (deploy.yml bu durumu atlayarak devam eder)
3. Federated Credential doğru repo'ya mı işaret ediyor?
   ```bash
   az ad app federated-credential list --id <CLIENT_ID>
   # subject: "repo:mcemkoca/Yafes_Pars:ref:refs/heads/main" olmalı
   ```

---

### Docker build — Cache export hatası

```
ERROR: Cache export is not supported for the docker driver
```

`deploy.yml`'da `setup-buildx-action` adımında `driver: docker-container` olduğunu doğrulayın. Bu satır eksikse PR #20'deki düzeltmeyi merge edin.

---

## 13. Versiyon Geçmişi

| Tarih | Versiyon | Değişiklik |
|-------|----------|-----------|
| 2026-06-24 | v1.5 | Migration 020: 14 write SP + coverage.ContractCoverageItem; kurulum rehberi (HTML simülasyon); write endpoint curl örnekleri; Dependabot güncellemeleri |
| 2026-06-24 | v1.4 | Finance/Coverage/Risk/Document write endpoints; Migration 019; SQL Agent Jobs; Frontend UI; Application Insights yapılandırması; CI/CD düzeltmeleri |
| 2026-06-23 | v1.3 | SSMS interaktif simülasyon; README yeniden tasarım; branch protection kuralları |
| 2026-06-23 | v1.2 | Azure deploy pipeline; Key Vault entegrasyonu; Bicep IaC |
| 2026-06-04 | v1.1 | 19 migration tamamlandı (000–018); SSMS scriptleri |
| 2026-06-02 | v1.0 | Backend API v1 (read endpoints); JWT/OIDC desteği |
