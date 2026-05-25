# AssureManager - SQL Server VHDX Deployment Paketi

## Hedef
Web uygulamasini SQL Server Management Studio (SSMS) ile yonetilebilir, VHDX tabanli bir deployment paketine donusturmek.

## Paket Icerigi

### 1. SQL Server Veritabani Deployment Scripts
- `sql/01_create_database.sql` - Veritabani olusturma
- `sql/02_schema.sql` - Tum tablolari olusturma
- `sql/03_constraints.sql` - Foreign keys, unique, check constraints
- `sql/04_seeds.sql` - Lookup tablolari ve ornek veriler
- `sql/05_triggers.sql` - Business rule triggers + timestamp updates
- `sql/06_stored_procedures.sql` - CRUD stored procedure'leri
- `sql/07_views.sql` - Raporlama view'lari
- `sql/deploy.bat` - Butun scriptleri sirasiyla calistir
- `sql/deploy.ps1` - PowerShell versiyonu

### 2. Backend REST API (Node.js + Express)
- `api/server.js` - Express server
- `api/routes/` - CRUD endpoint'leri (personen, instellingen, objecten, contracten, schadeclaims, rapporten)
- `api/db.js` - SQL Server baglanti yonetimi (mssql/tedious)
- `api/package.json` - Bagimliliklar
- `api/.env.example` - Ortam degiskenleri ornegi

### 3. Web Uygulamasi Entegrasyonu
- Frontend mock data yerine API'ye baglanacak
- `src/services/api.ts` - Axios-based API client
- `src/hooks/useApi.ts` - React hooks for data fetching
- Environment-based config (mock vs real API)

### 4. VHDX & VM Kurulum Otomasyonu
- `vm/Create-VHDX.ps1` - VHDX sanal disk olusturma
- `vm/Install-SQLServer.ps1` - SQL Server 2022 Express kurulum
- `vm/Deploy-Database.ps1` - Veritabani deploy
- `vm/Setup-VM.ps1` - Tam VM kurulum otomasyonu
- `vm/README.md` - VM kurulum adimlari

### 5. Docker Compose (Alternatif)
- `docker-compose.yml` - SQL Server 2022 + API + Frontend
- `.env` - Ortam degiskenleri

### 6. Kurulum Rehberi
- `README.md` - Tam kurulum dokumantasyonu
