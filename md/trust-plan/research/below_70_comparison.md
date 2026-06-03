# %70 Altı Benzerlik: Açık Kaynak Sigorta Projeleri

## Metodoloji
Benzerlik skoru şu kriterlere göre hesaplanmıştır:
- Tablo yapısı ve entity sayısı (40 puan)
- Domain modeli (Person/Contract/Claim/Object) (30 puan)
- Belgian localization (RRN/KBO/FSMA) (15 puan)
- Frontend + API entegrasyonu (10 puan)
- VM/Docker deployment (5 puan)

---

## 1. pavith-raj/Insurance-Policy-Management-System ⭐ 30
**Benzerlik: %18**

| Özellik | AssureManager | Bu Proje |
|---------|--------------|----------|
| Tablo | 90 | 8 |
| Person/Natural+Legal | ✅ | ❌ (sadece Customer) |
| Contract versions | ✅ | ❌ |
| Claim parties/objects | ✅ | ❌ (basit Claim) |
| Object categories (6) | ✅ | ❌ (sadece vehicle/health/life) |
| Institution (KBO/FSMA) | ✅ | ❌ |
| Lookup tables (40+) | ✅ | ❌ (sadece PolicyType) |
| Belgian data | ✅ | ❌ |
| React frontend | ✅ | ❌ |
| REST API | ✅ | ❌ |

**Ne alabiliriz:**
- `premium_payment` tablosu fikri (Financial Transactions eksikliğini kapatmak için)
- Policy subtype pattern (health_insurance, life_insurance, vehicleInsurance ayrı tablolar)

---

## 2. Group2_Database_Project_Insurance_Management_System ⭐ 12
**Benzerlik: %12**

| Özellik | AssureManager | Bu Proje |
|---------|--------------|----------|
| Tablo | 90 | 5 |
| Person detail (RRN/KBO) | ✅ | ❌ (sadece name/email/phone) |
| Contract versions | ✅ | ❌ |
| Claim detail | ✅ | ❌ (basit status/amount) |
| Address/Phone/Email | ✅ | ❌ (tek string adres) |
| Institution | ✅ | ❌ (Agent tablosu var ama basit) |
| Belgian data | ✅ | ❌ |
| Stored Procedures | 18 | 0 |
| Triggers | 13 | 0 |

**Ne alabiliriz:**
- `Policies_Agents` junction table pattern (Contract_Party'ye benzer ama çok basit)
- Başlangıç seviyesi eğitim projesi, bizden alınacak bir şey yok

---

## 3. huyHA9597/InsuranceClaimSystem ⭐ 45
**Benzerlik: %8**

| Özellik | AssureManager | Bu Proje |
|---------|--------------|----------|
| Teknoloji | SQL Server + Node + React | .NET 8 + Blazor |
| Tablo | 90 | 1 (Claim) |
| Database | SQL Server (gerçek) | In-memory |
| Person/Contract | ✅ | ❌ (sadece Claim) |
| CRUD | ✅ | ✅ (sadece Claim CRUD) |
| Validation | ✅ | ✅ (FluentValidation) |
| Auth | ❌ | ❌ (JWT planlanmış) |
| Belgian data | ✅ | ❌ |

**Ne alabiliriz:**
- Vertical slice architecture pattern (API endpoint'leri organize etme şekli)
- FluentValidation kütüphanesi (form validasyonu için)
- Integration test pattern (xUnit + WebApplicationFactory)
- MudBlazor UI component kütüphanesi (ileride Blazor geçişi için)

---

## 4. VINAYKUMARKUNDER/Insurance-Management-System ⭐ 48
**Benzerlik: %15**

| Özellik | AssureManager | Bu Proje |
|---------|--------------|----------|
| Teknoloji | Node + React | Java 17 + Spring Boot |
| Tablo | 90 | ~10 |
| Person | ✅ (detaylı) | ✅ (basit Client) |
| Policy | ✅ (Contract versions) | ✅ (basit) |
| Claim | ✅ (detaylı) | ✅ (basit) |
| Auth | ❌ | ✅ (JWT + Spring Security) |
| API Docs | ❌ | ✅ (Swagger UI) |
| Belgian data | ✅ | ❌ |

**Ne alabiliriz:**
- **JWT Authentication** sistemi (AssureManager'da yok!)
- **Swagger/OpenAPI** dokümantasyonu (API endpoint'leri otomatik dokümante)
- Spring Boot'un layer architecture pattern'i (Repository → Service → Controller)

---

## 5. sumitkumar1503/insurancemanagement ⭐ 150
**Benzerlik: %10**

| Özellik | AssureManager | Bu Proje |
|---------|--------------|----------|
| Teknoloji | React + Node | Python Django |
| Tablo | 90 | ~8 |
| Admin/Customer ayrımı | ❌ | ✅ (admin onaylı) |
| Policy category | ✅ (40+ lookup) | ✅ (basit: Life/Health/Motor/Travel) |
| Question/FAQ | ❌ | ✅ |
| Belgian data | ✅ | ❌ |

**Ne alabiliriz:**
- Admin/Customer rol ayrımı (Beheer sayfasında basit)
- Policy application + approval workflow
- FAQ/Soru sistemini Beheer'e ekleme fikri

---

## 6. ritenchhatrala2/insurance-management-system-JAVA ⭐ 8
**Benzerlik: %10**

3 modül: Policy, Claim, User management. Çok basit. Alınacak bir şey yok.

---

## 7. InsuranceProCRM (prolinkinfo) ⭐ ~50
**Benzerlik: %22**

| Özellik | AssureManager | Bu Proje |
|---------|--------------|----------|
| Teknoloji | React + Node | React + MERN (MongoDB) |
| Tablo | 90 (SQL Server) | ~15 (MongoDB) |
| CRM odaklı | ❌ (Policy odaklı) | ✅ (Lead/Customer tracking) |
| Dashboard | ✅ | ✅ |
| Belgian data | ✅ | ❌ |

**Ne alabiliriz:**
- Lead management modülü (Personen'e "Prospect" statüsü eklenebilir)
- Customer interaction tracking (Person activity log)

---

## 8. Openkoda Insurance Policy Management
**Benzerlik: %25**

| Özellik | AssureManager | Bu Proje |
|---------|--------------|----------|
| Açık kaynak | ✅ (bizimki) | ✅ |
| Customizable | ✅ | ✅ (daha fazla) |
| AI Reporting | ❌ | ✅ |
| Reinsurance | ❌ | ✅ |
| Document repo | ❌ | ✅ |
| Belgian data | ✅ | ❌ |

**Ne alabiliriz:**
- AI-powered reporting (Rapporten sayfasına LLM entegrasyonu)
- Document management system (Schadeclaims'e belge yükleme)
- Smart reminders (Contract vervaldatum bildirimleri)

---

## Özet Tablo

| Proje | Benzerlik | Alınabilecek Şey |
|-------|----------|------------------|
| pavith-raj/Insurance-Policy-Mgmt | %18 | premium_payment tablosu, policy subtype pattern |
| Group2_Database_Project | %12 | Junction table pattern (zaten var) |
| huyHA9597/InsuranceClaimSystem | %8 | Vertical slice arch, FluentValidation, MudBlazor |
| VINAYKUMARKUNDER/Insurance-Mgmt | %15 | JWT Auth, Swagger API Docs |
| sumitkumar1503/insurancemanagement | %10 | Admin/Customer rol ayrımı, FAQ sistemi |
| ritenchhatrala2/insurance-mgmt-JAVA | %10 | - |
| InsuranceProCRM | %22 | Lead management, interaction tracking |
| Openkoda Insurance | %25 | AI Reporting, Document repo, Smart reminders |

---

## Bizim Yapmamız Gerekenler (%30)

### 1. Authentication & Authorization (JWT)
- VINAYKUMARKUNDER'dan ilham
- Login/Register endpoint'leri
- Role-based access control (Admin, Manager, Medewerker, Lezer)

### 2. API Documentation (Swagger/OpenAPI)
- VINAYKUMARKUNDER'dan ilham
- `/api-docs` endpoint'i
- Otomatik API dokümantasyonu

### 3. Financial Transactions Tablosu
- pavith-raj'dan ilham
- `FinancialTransaction` (payment_id, contract_id, claim_id, amount, type, date)
- Payment, Recovery, Reserve kayıtları

### 4. Document Management
- Openkoda'dan ilham
- `Document` tablosu (document_id, entity_type, entity_id, file_name, file_path, uploaded_at)
- Contract, Claim, Person belgeleri

### 5. Activity/Interaction Log
- InsuranceProCRM'den ilham
- `Activity` tablosu (activity_id, person_id, contract_id, claim_id, type, description, date)
- Müşteri etkileşim takibi

### 6. Smart Reminders
- Openkoda'dan ilham
- Contract vervaldatum bildirimleri
- Claim açık >30 gün uyarıları

### 7. AI-Powered Reporting
- Openkoda'dan ilham
- LLM entegrasyonu ile doğal dil raporlama
- "Bu ayki komisyonları özetle" gibi sorgular
