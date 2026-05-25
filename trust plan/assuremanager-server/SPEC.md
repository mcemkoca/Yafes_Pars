# AssureManager - SQL Server Deployment Paketi - SPEC.md

## Overview
AssureManager Insurance Management System'in tam SQL Server deployment paketi. VHDX sanal disk icinde calistirilmak uzere tasarlandi. Node.js REST API + SQL Server 2022 + React frontend mimarisi.

## Architecture
```
[User] <-> [React Frontend] <-> [Express REST API] <-> [SQL Server 2022]
                                     (Node.js + mssql)
```

## Database

### Schema
Belgium-centered insurance management system with 6 domains:
- Person Domain (Person, NaturalPerson, LegalPerson, Address, Phone, Email, etc.)
- PersonRelation Domain (PersonRelation, PersonRelation_Person)
- Institution Domain (Institution, InstitutionIdentifier, InstitutionAddress)
- Object Domain (Object, ObjectVehicle, ObjectRealEstate, ObjectLoan, ObjectPerson, ObjectThing, ObjectActivity)
- Contract Domain (Contract, ContractVersion, Contract_Party, Contract_Object, ContractTakeover)
- Claim Domain (Claim, Claim_Party, Claim_Object, Claim_Circumstance)

All tables with 40+ lookup tables for Belgian insurance codes.

### Stored Procedures
| SP Name | Purpose |
|---------|---------|
| sp_Person_GetAll | List persons with pagination and filters |
| sp_Person_GetById | Person detail with all related data |
| sp_Person_Create | Insert new person (Natural or Legal) |
| sp_Person_Update | Update person data |
| sp_Person_Delete | Soft delete person |
| sp_Institution_GetAll | List institutions with filters |
| sp_Institution_GetById | Institution detail |
| sp_Object_GetAll | List objects by category |
| sp_Object_GetById | Object detail |
| sp_Contract_GetAll | List contracts with status filters |
| sp_Contract_GetById | Contract detail with parties and objects |
| sp_Claim_GetAll | List claims with urgency indicators |
| sp_Claim_GetById | Claim detail with timeline |
| sp_Dashboard_GetStats | KPI statistics for dashboard |
| sp_Dashboard_GetCharts | Chart data for dashboard |
| sp_Rapporten_Commissions | Commission report |
| sp_Rapporten_Contracts | Contract analytics |
| sp_Rapporten_Claims | Claims analytics |

### Views
| View Name | Purpose |
|-----------|---------|
| vw_Person_Full | Person with Natural/Legal details |
| vw_Contract_Full | Contract with versions, parties, objects |
| vw_Claim_Full | Claim with parties, objects, circumstances |
| vw_Dashboard_KPIs | Aggregated KPI metrics |
| vw_OpenClaims | Open claims with aging >45 days |
| vw_ExpiringContracts | Contracts expiring within 90 days |

## REST API (Express + mssql)

### Base URL: `/api/v1`

### Endpoints

#### Dashboard
- `GET /dashboard/stats` → KPI statistics
- `GET /dashboard/charts` → Chart data (line, bar, donut)
- `GET /dashboard/activities` → Recent activity feed
- `GET /dashboard/alerts` → Expiring contracts & urgent claims

#### Personen
- `GET /personen?page=&limit=&search=&type=&stad=` → List
- `GET /personen/:id` → Detail with all related data
- `POST /personen` → Create
- `PUT /personen/:id` → Update
- `DELETE /personen/:id` → Delete

#### Instellingen
- `GET /instellingen?page=&limit=&search=&type=` → List
- `GET /instellingen/:id` → Detail
- `POST /instellingen` → Create
- `PUT /instellingen/:id` → Update
- `DELETE /instellingen/:id` → Delete

#### Objecten
- `GET /objecten?page=&limit=&category=&search=` → List
- `GET /objecten/:id` → Detail
- `POST /objecten` → Create
- `PUT /objecten/:id` → Update
- `DELETE /objecten/:id` → Delete

#### Contracten
- `GET /contracten?page=&limit=&status=&search=` → List
- `GET /contracten/:id` → Detail
- `POST /contracten` → Create
- `PUT /contracten/:id` → Update
- `DELETE /contracten/:id` → Delete

#### Schadeclaims
- `GET /schadeclaims?page=&limit=&status=&search=` → List
- `GET /schadeclaims/:id` → Detail
- `POST /schadeclaims` → Create
- `PUT /schadeclaims/:id` → Update

#### Rapporten
- `GET /rapporten/commissions` → Commission data
- `GET /rapporten/contracts` → Contract analytics
- `GET /rapporten/claims` → Claims analytics
- `GET /rapporten/clients` → Client demographics

#### Beheer
- `GET /beheer/users` → User list
- `GET /beheer/auditlog` → Audit log entries
- `GET /beheer/settings` → System settings

### Database Connection
```javascript
const config = {
  server: process.env.DB_SERVER || 'localhost',
  database: process.env.DB_NAME || 'AssureManagerDB',
  user: process.env.DB_USER || 'sa',
  password: process.env.DB_PASSWORD || '',
  options: { encrypt: false, trustServerCertificate: true }
}
```

## Frontend Integration
- Replace mock data with API calls
- Axios with baseURL `/api/v1`
- Loading states and error handling
- Environment-based config (REACT_APP_API_URL)

## VHDX Deployment

### PowerShell Scripts
1. `Create-VHDX.ps1` - Creates VHDX (50GB dynamically expanding)
2. `Install-SQLServer.ps1` - Installs SQL Server 2022 Express silently
3. `Deploy-Database.ps1` - Creates DB, runs all SQL scripts
4. `Setup-VM.ps1` - Master script calling all above

### Manual Steps
1. Create VM in Hyper-V with the VHDX
2. Install Windows Server 2022
3. Run Setup-VM.ps1
4. Access frontend at http://localhost:5173

## File Structure
```
/mnt/agents/output/assuremanager-server/
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_schema.sql
│   ├── 03_constraints.sql
│   ├── 04_seeds.sql
│   ├── 05_triggers.sql
│   ├── 06_stored_procedures.sql
│   ├── 07_views.sql
│   ├── deploy.bat
│   └── deploy.ps1
├── api/
│   ├── server.js
│   ├── package.json
│   ├── .env.example
│   ├── db.js
│   └── routes/
│       ├── dashboard.js
│       ├── personen.js
│       ├── instellingen.js
│       ├── objecten.js
│       ├── contracten.js
│       ├── schadeclaims.js
│       ├── rapporten.js
│       └── beheer.js
├── vm/
│   ├── Create-VHDX.ps1
│   ├── Install-SQLServer.ps1
│   ├── Deploy-Database.ps1
│   ├── Setup-VM.ps1
│   └── README.md
├── docker-compose.yml
├── Dockerfile
├── .env
└── README.md
```

## Tech Stack
- SQL Server 2022 Express
- Node.js 20 + Express 4
- mssql (tedious driver) for SQL connectivity
- React 19 + TypeScript (existing)
- Docker + Docker Compose (optional)

## Mock Mode
When DB is not available, API returns mock data from existing mockData.ts files.
