# Deep Research: Tutorial Basliklari vs Gercek Proje + Benzer SQL Semalari

## 1. Tutorial Basliklari ile Gercek Yapi Karsilastirmasi

| Tutorial Bolum | Gercek Dosya/Icerik | Uyum | Not |
|---------------|---------------------|------|-----|
| **Stap 1: SQL Server Installeren** | SQL Server 2022 Express | DOGRU | Standart kurulum |
| **Stap 2: Database Deployen** | 01-08.sql (8 script) | DOGRU | Sirali deploy |
| **Stap 3: API Starten** | Node.js + Express + mssql | DOGRU | 40+ endpoint |
| **Stap 4: Dashboard Gebruiken** | 8 sayfa (Personen, Instellingen, Objecten, Contracten, Schadeclaims, Rapporten, Beheer) | DOGRU | Sayfa isimleri dogru |
| **Architectuur** | React -> API -> SQL Server | DOGRU | 3 katmanli mimari |
| **Troubleshooting** | sqlcmd, TCP/IP, firewall | DOGRU | Standard sorunlar |

### Tutorial'in Dogru Yansittigi Yapilar:
- 90 tablo, 18 stored procedure, 6 view, 13 trigger
- 8 yonetim sayfasi
- REST API mimarisi
- SQL Server -> API -> Frontend akisi
- VHDX deployment opsiyonu

---

## 2. Buna Benzer SQL Yapisi Var Mi? - ARASTIRMA SONUCLARI

### A. EVET - ACORD Information Model (Endustri Standarti)

**ACORD (Association for Cooperative Operations Research and Development)**
- **1,000+ sigorta entity'si** (AssureManager: 90 tablo)
- **7 model**: Business Glossary, Information Model, Data Model, Capability Model, Component Model, Process Model, Product Model
- **6,000+ terim** tanimi

**ACORD Core Entities vs AssureManager:**

| ACORD Entity | AssureManager Karsiligi | Uyum |
|-------------|------------------------|------|
| Party (Contact) | Person (Natural/Legal) | YUKSEK |
| PartyRole | PersonRelation + Person_PersonType | YUKSEK |
| Policy | Contract (versions, parties, objects) | YUKSEK |
| Claim | Claim (parties, objects, circumstances) | YUKSEK |
| Coverage | Contract_Coverage | YUKSEK |
| Producer/Agency | Institution | ORTA |
| Risk Object | Object (Vehicle/RealEstate/Loan/Thing/Activity) | YUKSEK |
| Financial Transaction | (Yok - SP'lerde) | DUSUK |
| Address/ContactInfo | PersonAddress, PersonPhone, PersonEmail | YUKSEK |

### B. Guidewire (Endustri Lideri - $10B+ Sirket)

**Guidewire ClaimCenter/PolicyCenter:**
- 200-300+ tablo
- Entity inheritance model
- Core: Claim, Exposure, Incident, Contact, ContactRole, Payment, Recovery, Reserve

**Guidewire vs AssureManager:**

| Guidewire | AssureManager | Not |
|-----------|---------------|-----|
| Claim + Exposure | Claim (tek tablo) | AssureManager daha basit |
| Incident (Vehicle/Injury/Property) | Object (6 subtype) | Benzer inheritance |
| Contact + ContactRole | Person + PersonRelation | Benzer ayrim |
| Policy snapshot | Contract versions | Benzer versiyonlama |
| Transaction (Payment/Recovery/Reserve) | (SP'lerde hesaplaniyor) | AssureManager eksik |
| Activity | (Yok) | Eklenebilir |

### C. Open Source Alternatifler

#### 1. openIMIS (GitHub: 13M+ kullanici, 12 ulke)
- Saglik sigortasi odakli
- **MS SQL Server destegi var**
- Beneficiary, Provider, Payer, Claim, Policy
- Docker deployment mevcut

#### 2. openinsuranceplatform (aposin - GitHub)
- **Tam sigorta platformu**: CRM, Sales, Policy, Claims, Reinsurance, Commission
- Java tabanli, REST API
- Database catalog dokumantasyonu
- Rating engine (MOM)

#### 3. Insurance-Policy-Management-System (pavith-raj)
- MySQL, 5 temel tablo: Customer, Policy, Claim, Agent, Policies_Agents
- Cok basit (AssureManager'dan cok daha kucuk)

#### 4. Database-Design (jshah24)
- EER diyagrami, normalizasyon
- Egitim projesi

---

## 3. AssureManager'in Benzersiz Ozellikleri

| Ozellik | ACORD | Guidewire | AssureManager |
|---------|-------|-----------|---------------|
| Belcika lokallestirmesi (RRN, KBO, FSMA) | YOK | YOK | **VAR** |
| 6 kategori Object (Vehicle/RealEstate/Loan/Thing/Activity/Person) | Kismi | VAR | **VAR** |
| 40+ lookup tablosu (Felemenkce) | Ingilizce | Ingilizce | **VAR** |
| Contract versiyonlama + takeover | VAR | VAR | **VAR** |
| Claim urgency indicator (>45 gun) | YOK | YOK | **VAR** |
| React dashboard + CRUD modal formlar | YOK | Guidewire UI | **VAR** |
| VHDX + PowerShell otomasyon | YOK | YOK | **VAR** |
| REST API + mock fallback | API-first | Cloud API | **VAR** |

---

## 4. Endustri Standardindan Sapma Alanlari (Eksikler)

| Alan | Standart | AssureManager Durumu | Etki |
|------|----------|---------------------|------|
| **Financial Transactions** | Payment, Recovery, Reserve tablolari | SP'lerde hesaplaniyor | ORTA - Raporlama sinirli |
| **Activity/Timeline** | Claim activity log | (Yok) | DUSUK - Audit eksikligi |
| **Document Management** | Claim documents | (Yok) | DUSUK - Belge yonetimi yok |
| **Reinsurance** | Reinsurance agreements | (Yok) | DUSUK - Reasurans yok |
| **Commission tracking** | Agent commissions | SP'lerde | ORTA - Komisyon raporlamasi sinirli |
| **Multi-language UI** | NL/FR/EN | Sadece NL | DUSUK - FR eksik |

---

## 5. SONUC

### Evet, buna benzer SQL yapilari var:

1. **ACORD Information Model** - 1,000+ entity ile endustri standarti. AssureManager 90 tablo ile ACORD'un %9'unu kapsiyor ama core entity'ler (Party, Policy, Claim, Coverage) tam olarak eslesiyor.

2. **Guidewire ClaimCenter** - 200-300 tablo ile P&C sigorta lideri. AssureManager'in yapisi Guidewire'in basitlestirilmis versiyonu sayilir.

3. **openinsuranceplatform** - Acik kaynak tam sigorta platformu. CRM, Policy, Claims, Reinsurance, Commission modulleri var.

### AssureManager'in Konumlandirmasi:
**"Guidewire'in %30'u + ACORD'un %10'u + Belciya lokallestirmesi"**
- Endustri standardina uygun core model (Party->Person, Policy->Contract, Claim->Claim)
- Belciya'ya ozgu RRN/KBO/FSMA entegrasyonu (benzersiz)
- Reinsurance ve Document Management eksik
- 90 tablo ile KOB-Orta boy sigorta brokerlari icin yeterli
- Open source alternatiflerden (openIMIS, openinsuranceplatform) daha kapsamli
