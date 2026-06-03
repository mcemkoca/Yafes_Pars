# AssureManager - SQL Server Deployment Paketi

> **Belgian Insurance Management System** - Complete SQL Server database + REST API + Web frontend deployment package.

---

## Quick Start (3 Options)

### Option 1: SQL Server + API (Recommended)

```bash
# 1. Start SQL Server (Docker)
docker-compose up -d sqlserver

# 2. Deploy database
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -i sql/01_create_database.sql
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -d AssureManagerDB -i sql/02_schema.sql
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -d AssureManagerDB -i sql/03_constraints.sql
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -d AssureManagerDB -i sql/04_seeds.sql
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -d AssureManagerDB -i sql/05_triggers.sql
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -d AssureManagerDB -i sql/06_stored_procedures.sql
sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -d AssureManagerDB -i sql/07_views.sql

# 3. Start API
cd api && npm install && npm start

# 4. API runs at http://localhost:3001
```

### Option 2: Windows PowerShell (Full VHDX Setup)

```powershell
# 1. Create VHDX
.\vm\Create-VHDX.ps1 -Path "C:\VMs\AssureManager.vhdx" -SizeGB 50

# 2. Mount and install Windows Server, then run:
.\vm\Setup-VM.ps1

# Or step by step:
.\vm\Install-SQLServer.ps1 -SaPassword "YourStrong@Passw0rd"
.\vm\Deploy-Database.ps1 -Server "localhost" -Database "AssureManagerDB"
```

### Option 3: Docker Compose (Everything)

```bash
# Build frontend first
cd /path/to/webapp && npm run build && cp -r dist /path/to/server/

# Start everything
docker-compose up -d

# Access: http://localhost:8080
# API: http://localhost:3001/api/v1
```

---

## Package Contents

```
assuremanager-server/
|
|-- sql/                          # SQL Server Deployment Scripts
|   |-- 01_create_database.sql    # Database creation
|   |-- 02_schema.sql             # 50+ tables (6 domains)
|   |-- 03_constraints.sql        # FKs, unique, check constraints
|   |-- 04_seeds.sql              # 40+ lookup tables + sample data
|   |-- 05_triggers.sql           # Business rules + timestamps
|   |-- 06_stored_procedures.sql  # 18 CRUD stored procedures
|   |-- 07_views.sql              # 6 reporting views
|   |-- deploy.bat                # Windows batch deploy
|   |-- deploy.ps1                # PowerShell deploy with progress
|
|-- api/                          # Node.js REST API
|   |-- server.js                 # Express server
|   |-- package.json              # Dependencies
|   |-- .env.example              # Config template
|   |-- db.js                     # SQL Server connection pool
|   |-- mockData.js               # Fallback mock data
|   |-- Dockerfile                # Container image
|   |-- routes/
|       |-- index.js              # Route aggregator
|       |-- dashboard.js          # KPIs, charts, activities
|       |-- personen.js           # Person CRUD
|       |-- instellingen.js       # Institution CRUD
|       |-- objecten.js           # Object catalog CRUD
|       |-- contracten.js         # Contract CRUD
|       |-- schadeclaims.js       # Claims CRUD
|       |-- rapporten.js          # Reports & analytics
|       |-- beheer.js             # System management
|
|-- vm/                           # VM Automation
|   |-- Create-VHDX.ps1           # Create virtual disk
|   |-- Install-SQLServer.ps1     # SQL Server silent install
|   |-- Deploy-Database.ps1       # Database deployment
|   |-- Setup-VM.ps1              # Full VM orchestration
|   |-- README.md                 # VM setup guide
|
|-- docker-compose.yml            # Docker orchestration
|-- nginx.conf                    # Reverse proxy config
|-- .env                          # Environment variables
|-- README.md                     # This file
```

---

## Database Schema

### Domains

| Domain | Tables | Description |
|--------|--------|-------------|
| **Person** | 12+ | Natural & Legal persons, addresses, phones, emails, bank accounts |
| **PersonRelation** | 2 | Relationships between persons |
| **Institution** | 5 | Insurance companies, banks, intermediaries |
| **Object** | 12+ | Vehicles, real estate, loans, persons, things, activities |
| **Contract** | 8 | Insurance policies, versions, parties, objects, takeovers |
| **Claim** | 5 | Damage claims, parties, objects, circumstances |

### Total: 50+ tables, 40+ lookup tables, 18 stored procedures, 6 views

### Lookup Tables (Dutch/Flemish)
- Languages, Titles, Phone Types, Social Media Types
- Professional Status, Person Types, Person Relation Types
- Vehicle Types, Fuel Types, Drive Types, License Plate Types
- Real Estate Types, Insured Roles, Use Types, Residence Types
- Construction Types, Roof Types, Adjacency Types, Burglary Protection Types
- Contract Domains (19), Contract Types, Contract Statuses, Contract Version Statuses
- Periodicity, Collection Method, Duration Types
- Claim Statuses, Claim Party Roles, Claim Circumstance Types
- Coverage Codes (200+) linked to Contract Domains

---

## REST API Reference

### Base URL
```
http://localhost:3001/api/v1
```

### Endpoints

#### Dashboard
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/dashboard/stats` | KPI statistics |
| GET | `/dashboard/charts` | Line, bar, donut chart data |
| GET | `/dashboard/activities` | Recent activity feed |
| GET | `/dashboard/alerts` | Expiring contracts + urgent claims |

#### Personen
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/personen?page=&limit=&search=&type=&stad=` | List persons |
| GET | `/personen/:id` | Person detail |
| POST | `/personen` | Create person |
| PUT | `/personen/:id` | Update person |
| DELETE | `/personen/:id` | Delete person |

#### Instellingen
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/instellingen?page=&limit=&search=&type=` | List institutions |
| GET | `/instellingen/:id` | Institution detail |
| POST | `/instellingen` | Create institution |
| PUT | `/instellingen/:id` | Update institution |
| DELETE | `/instellingen/:id` | Delete institution |

#### Objecten
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/objecten?page=&limit=&category=&search=` | List objects |
| GET | `/objecten/:id` | Object detail |
| POST | `/objecten` | Create object |
| PUT | `/objecten/:id` | Update object |
| DELETE | `/objecten/:id` | Delete object |

#### Contracten
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/contracten?page=&limit=&status=&search=` | List contracts |
| GET | `/contracten/:id` | Contract detail |
| POST | `/contracten` | Create contract |
| PUT | `/contracten/:id` | Update contract |
| DELETE | `/contracten/:id` | Delete contract |

#### Schadeclaims
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/schadeclaims?page=&limit=&status=&search=` | List claims |
| GET | `/schadeclaims/:id` | Claim detail |
| POST | `/schadeclaims` | Create claim |
| PUT | `/schadeclaims/:id` | Update claim |

#### Rapporten
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/rapporten/commissions` | Commission report |
| GET | `/rapporten/contracts` | Contract analytics |
| GET | `/rapporten/claims` | Claims analytics |
| GET | `/rapporten/clients` | Client demographics |

#### Beheer
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/beheer/users` | User list |
| GET | `/beheer/auditlog` | Audit log |
| GET | `/beheer/settings` | System settings |
| PUT | `/beheer/settings` | Update settings |

#### Health Check
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | API + DB health status |

---

## VHDX Deployment Guide

### Prerequisites
- Windows 10/11 Pro or Windows Server 2022
- Hyper-V enabled
- PowerShell 5.1+ (run as Administrator)

### Step 1: Create VHDX
```powershell
.\vm\Create-VHDX.ps1 -Path "C:\VMs\AssureManager.vhdx" -SizeGB 50
Mount-DiskImage -ImagePath "C:\VMs\AssureManager.vhdx"
```

### Step 2: Install Windows Server
- Create VM in Hyper-V Manager
- Attach the VHDX
- Install Windows Server 2022
- Complete initial configuration

### Step 3: Install SQL Server
```powershell
# Inside the VM, run:
.\vm\Install-SQLServer.ps1 `
    -InstanceName "ASSUREMANAGER" `
    -SaPassword "YourStrong@Passw0rd" `
    -DataPath "C:\SQLData" `
    -LogPath "C:\SQLLogs"
```

### Step 4: Deploy Database
```powershell
.\vm\Deploy-Database.ps1 `
    -Server "localhost\ASSUREMANAGER" `
    -Database "AssureManagerDB" `
    -ScriptPath ".\sql"
```

### Step 5: Install API & Frontend
```powershell
# Install Node.js (download from nodejs.org)
# Then:
cd api
npm install
npm start

# Frontend (existing built files)
copy dist folder to C:\inetpub\wwwroot or run with nginx
```

### Or run everything automated:
```powershell
.\vm\Setup-VM.ps1 -FullSetup
```

---

## Configuration

### Environment Variables (.env)

| Variable | Default | Description |
|----------|---------|-------------|
| DB_SERVER | localhost | SQL Server hostname |
| DB_NAME | AssureManagerDB | Database name |
| DB_USER | sa | SQL Server username |
| DB_PASSWORD | YourStrong@Passw0rd | SQL Server password |
| PORT | 3001 | API port |
| NODE_ENV | development | Environment mode |
| CORS_ORIGINS | * | Allowed CORS origins |

### SQL Server Connection
The API automatically detects if SQL Server is available. If not, it falls back to mock data. To force mock mode, set `MOCK_MODE=true` in `.env`.

---

## Database Connection from SSMS

```
Server:     localhost\ASSUREMANAGER  (or just localhost for default instance)
Auth:       SQL Server Authentication
Login:      sa
Password:   YourStrong@Passw0rd
Database:   AssureManagerDB
```

### Useful SSMS Queries
```sql
-- Check all tables
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

-- Check row counts
SELECT 
    t.name AS TableName,
    p.rows AS RowCount
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
ORDER BY p.rows DESC;

-- Execute stored procedure
EXEC sp_Dashboard_GetStats;

-- Query view
SELECT * FROM vw_Dashboard_KPIs;

-- Check open claims with aging
SELECT * FROM vw_OpenClaims WHERE AgingDays > 45;
```

---

## Mock Data Mode

When SQL Server is not available, the API automatically returns realistic Belgian insurance mock data:

- **28 persons** - Belgian names, RRN format (85.12.31-123.45), addresses in Mechelen/Brussel/Gent
- **16 institutions** - Ethias, AXA, KBC, ING, BNP Paribas Fortis, etc.
- **24 objects** - Vehicles with Belgian plates, real estate, loans, things, activities
- **23 contracts** - Various domains (Auto, Brand, Leven, AO, Hospitalisatie)
- **18 claims** - Different types and statuses with urgency indicators

All data is in Dutch/Flemish as used in Belgian insurance practice.

---

## Troubleshooting

### SQL Server Connection Failed
```bash
# Check if SQL Server is running
sqlcmd -S localhost -U sa -Q "SELECT @@VERSION"

# Enable TCP/IP
# SQL Server Configuration Manager -> SQL Server Network Configuration -> Protocols -> Enable TCP/IP

# Restart SQL Server
net stop MSSQLSERVER && net start MSSQLSERVER
```

### Port 1433 Not Accessible
```bash
# Open Windows Firewall
netsh advfirewall firewall add rule name="SQL Server" dir=in action=allow protocol=tcp localport=1433
```

### API Mock Mode
If the API shows `WARNING: SQL Server not available, using mock data`, check:
1. SQL Server is running
2. Connection string is correct in `.env`
3. TCP/IP is enabled in SQL Server Configuration Manager
4. Firewall allows port 1433

### VHDX Mount Issues
```powershell
# Check if VHDX is valid
Test-VHD -Path "C:\VMs\AssureManager.vhdx"

# Mount manually
Mount-DiskImage -ImagePath "C:\VMs\AssureManager.vhdx"

# Dismount
Dismount-DiskImage -ImagePath "C:\VMs\AssureManager.vhdx"
```

---

## License
Private - For demonstration and educational purposes.

## Support
For issues or questions, refer to the `vm/README.md` file or check the API health endpoint at `/api/v1/health`.
