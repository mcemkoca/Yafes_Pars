# AssureManager :belgium:

> **Belgian Insurance Management System** *(Verzekeringsbeheersysteem / Système de gestion d'assurances)*
>
> Complete server management solution designed for insurance brokers operating in the Belgian market. Built on SQL Server 2022 with a modern React frontend and a robust REST API layer.

<p align="center">
  <img src="https://img.shields.io/badge/build-passing-brightgreen" alt="Build Status" />
  <img src="https://img.shields.io/badge/SQL%20Server-2022-cc2927?logo=microsoftsqlserver&logoColor=white" alt="SQL Server 2022" />
  <img src="https://img.shields.io/badge/Node.js-20-339933?logo=nodedotjs&logoColor=white" alt="Node.js 20" />
  <img src="https://img.shields.io/badge/React-19-61DAFB?logo=react&logoColor=black" alt="React 19" />
  <img src="https://img.shields.io/badge/Express-4-404040?logo=express&logoColor=white" alt="Express 4" />
  <img src="https://img.shields.io/badge/license-Private-orange" alt="License: Private" />
</p>

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Database](#database)
- [REST API](#rest-api)
- [Frontend Dashboard](#frontend-dashboard)
- [VM Deployment](#vm-deployment)
- [Screenshots](#screenshots)
- [Tutorial](#tutorial)
- [Project Structure](#project-structure)
- [Technologies](#technologies)
- [Contributing](#contributing)
- [License](#license)

---

## Features

### Core Modules

| Module | Description | Entities |
|--------|-------------|----------|
| **Personen** | Natural & legal persons management | Individuals, companies, RRN/KBO numbers, addresses, contacts |
| **Instellingen** | Insurance market participants | Insurance companies, banks, intermediaries, regulatory bodies |
| **Objecten** | Insurable object catalog | Vehicles, real estate, loans, general items, professional activities |
| **Contracten** | Insurance policy lifecycle | Policy versions, coverage periods, linked parties & objects, renewals |
| **Schadeclaims** | Claims & damage management | Claim registration, parties involved, linked objects, circumstances, reserves |
| **Rapporten** | Business intelligence | Commission analytics, contract portfolio, claims trends, expiry alerts |
| **Beheer** | System administration | User management, role-based access, audit logging, system settings |

### Key Capabilities

- **90 database tables** with full referential integrity via 36 foreign keys
- **18 stored procedures** for optimized CRUD operations
- **6 reporting views** including Open Claims, Expiring Contracts, and Commission Overview
- **13 database triggers** for automatic audit timestamps and business rule enforcement
- **40+ REST API endpoints** with intelligent mock-data fallback for offline development
- **Interactive React dashboard** featuring 8 management pages
- **Real-time toast notifications** and fully working CRUD forms with validation
- **VM automation scripts** for VHDX provisioning and silent SQL Server installation

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT LAYER                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                       │
│  │   Browser    │  │   Browser    │  │   Browser    │                       │
│  │   (User)     │  │   (Admin)    │  │  (Manager)   │                       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                       │
└─────────┼─────────────────┼─────────────────┼───────────────────────────────┘
          │                 │                 │
          └─────────────────┴─────────────────┘
                            │ HTTP/HTTPS
                            ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION LAYER                                 │
│  ┌──────────────────────────────────────────────────────────────────────┐    │
│  │                    React 19 SPA Dashboard                             │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌───────────┐  │    │
│  │  │Dashboard │ │ Personen │ │Contracten│ │Schadecl. │ │ Rapporten │  │    │
│  │  │ (KPIs)   │ │  (CRUD)  │ │  (CRUD)  │ │  (CRUD)  │ │(Analytics)│  │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └───────────┘  │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐                               │    │
│  │  │Instelling│ │ Objecten │ │  Beheer  │                               │    │
│  │  │  (CRUD)  │ │  (CRUD)  │ │ (Admin)  │                               │    │
│  │  └──────────┘ └──────────┘ └──────────┘                               │    │
│  │                                                                      │    │
│  │  Port: 80  •  Tailwind CSS  •  shadcn/ui  •  Recharts               │    │
│  └──────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
                            │ REST JSON
                            ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              API LAYER                                       │
│  ┌──────────────────────────────────────────────────────────────────────┐    │
│  │                Node.js 20 + Express 4 REST API                       │    │
│  │                                                                      │    │
│  │   /api/v1/dashboard/stats    /api/v1/personen      GET|POST|PUT|DEL  │    │
│  │   /api/v1/instellingen       /api/v1/objecten      GET|POST|PUT|DEL  │    │
│  │   /api/v1/contracten         /api/v1/schadeclaims  GET|POST|PUT|DEL  │    │
│  │   /api/v1/rapporten/*        /api/v1/beheer/*      GET|PUT           │    │
│  │                                                                      │    │
│  │   Port: 3001  •  mssql (Tedious)  •  dotenv  •  cors                 │    │
│  └──────────────────────┬───────────────────────────────────────────────┘    │
└─────────────────────────┼────────────────────────────────────────────────────┘
                          │ TDS (Tabular Data Stream)
                          ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            DATA LAYER                                        │
│  ┌──────────────────────────────────────────────────────────────────────┐    │
│  │              Microsoft SQL Server 2022 Express                         │    │
│  │                                                                      │    │
│  │   Database: AssureManagerDB                                          │    │
│  │                                                                      │    │
│  │   ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │    │
│  │   │ 90 Tables│ │  18 SPs  │ │ 6 Views  │ │13 Triggers│ │  36 FKs  │  │    │
│  │   │ 2000 Seed│ │   CRUD   │ │ Reports  │ │  Audit   │ │   Ref    │  │    │
│  │   │ 300 Test │ │          │ │          │ │  Rules   │ │Integrity │  │    │
│  │   └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘  │    │
│  │                                                                      │    │
│  │   Port: 1433  •  Full-text search  •  Row-level security             │    │
│  └──────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Technology Flow

```
User Request
     │
     ▼
┌─────────┐    ┌──────────┐    ┌───────────┐    ┌─────────────┐
│ Browser │───▶│  Nginx   │───▶│  Express  │───▶│ SQL Server  │
│         │    │  :80     │    │  :3001    │    │   :1433     │
└─────────┘    └──────────┘    └───────────┘    └─────────────┘
                                    │
                              ┌─────┴─────┐
                              │  Mock     │
                              │  Fallback │
                              └───────────┘
```

---

## Quick Start

### Prerequisites

| Component | Minimum Version | Recommended |
|-----------|----------------|-------------|
| Windows Server / Windows 10+ | 2019 / 20H2 | Server 2022 / 11 |
| SQL Server | 2019 Express | 2022 Express |
| Node.js | 18 LTS | 20 LTS |
| npm | 9 | 10 |
| PowerShell | 5.1 | 7.x |

### Option 1: Automated PowerShell Deployment (Recommended)

The fastest way to get up and running:

```powershell
# 1. Clone the repository
git clone https://github.com/your-org/assuremanager-complete.git
cd assuremanager-complete

# 2. Deploy the database (adjust server name as needed)
.\sql\deploy.ps1 -Server "localhost" -Database "AssureManagerDB"

# 3. Install API dependencies
cd api
npm install

# 4. Start the API server
npm start
# API running at: http://localhost:3001

# 5. Open the dashboard (in a new terminal)
# Serve frontend/index.html via any web server, or simply open in browser
```

### Option 2: Manual SQL Server Management Studio (SSMS)

Execute scripts in strict numerical order:

| Order | Script File | Purpose | Objects Created |
|-------|-------------|---------|----------------|
| 1 | `01_create_database.sql` | Create the database container | Database + filegroups |
| 2 | `02_schema.sql` | Core schema definition | 90 tables with primary keys |
| 3 | `03_constraints.sql` | Referential integrity | 36 foreign keys, unique constraints |
| 4 | `04_seeds.sql` | Lookup & reference data | 2,000+ seed records |
| 5 | `05_triggers.sql` | Automated business logic | 13 triggers (audit, timestamps, validation) |
| 6 | `06_stored_procedures.sql` | Application CRUD interface | 18 stored procedures |
| 7 | `07_views.sql` | Reporting layer | 6 analytical views |
| 8 | `08_test_data.sql` | Development sample data | 300 realistic business records |

### Option 3: Docker Compose

```bash
# Build and start all services
docker-compose up -d

# Services:
#   - Frontend:    http://localhost:80
#   - API:         http://localhost:3001
#   - SQL Server:  localhost:1433
```

### Verify Installation

```bash
# Check database connectivity
curl http://localhost:3001/api/v1/dashboard/stats

# Expected response:
# {
#   "totalPersons": 47,
#   "totalContracts": 128,
#   "openClaims": 23,
#   "expiringContracts": 15
# }
```

---

## Database

### Schema Overview

The AssureManager database is designed as a comprehensive **star schema** optimized for insurance broker operations. Every module interconnects through well-defined foreign key relationships ensuring data consistency across all business processes.

### Quantitative Metrics

| Metric | Count | Description |
|--------|-------|-------------|
| **Tables** | 90 | Core entities, junction tables, lookups, audit logs |
| **Stored Procedures** | 18 | Application-level CRUD and business operations |
| **Views** | 6 | Pre-aggregated reporting datasets |
| **Triggers** | 13 | Automatic audit trails, timestamp management, validation |
| **Foreign Keys** | 36 | Referential integrity constraints |
| **Seed Records** | 2,000+ | Belgian insurance reference data, postal codes, NACE codes |
| **Test Records** | 300 | Realistic sample data for development/testing |

### Entity Relationship Summary

```
                    ┌──────────────┐
                    │   Personen   │
                    │  (Persons)   │
                    └──────┬───────┘
                           │
           ┌───────────────┼───────────────┐
           │               │               │
           ▼               ▼               ▼
    ┌────────────┐  ┌────────────┐  ┌────────────┐
    │  Contracten │  │Schadeclaims│  │  Objecten  │
    │ (Contracts) │  │  (Claims)  │  │  (Objects) │
    └──────┬──────┘  └──────┬──────┘  └──────┬──────┘
           │               │               │
           │         ┌─────┴─────┐         │
           │         │  Parties  │         │
           │         │ (Junction)│         │
           │         └───────────┘         │
           │                               │
           └──────────────┬────────────────┘
                          │
                   ┌──────▼──────┐
                   │ Instellingen │
                   │(Institutions)│
                   └──────────────┘
```

### SSMS Connection Details

```
Server type:     Database Engine
Server name:     localhost\ASSUREMANAGER
Authentication:  SQL Server Authentication
Login:           sa
Password:        (configured during SQL Server installation)
Database:        AssureManagerDB
```

### Reporting Views

| View Name | Purpose | Key Columns |
|-----------|---------|-------------|
| `vw_OpenClaims` | Active damage claims | Claim number, status, reserve amount, days open |
| `vw_ExpiringContracts` | Upcoming renewals | Policy number, expiry date, premium, broker |
| `vw_CommissionOverview` | Revenue analytics | Period, insurer, commission amount, percentage |
| `vw_PolicyPortfolio` | Complete policy register | Holder, insurer, coverage, premium, start/end |
| `vw_ClaimReserveAnalysis` | Financial exposure | Total reserves, paid amounts, outstanding |
| `vw_ActivityAudit` | System audit trail | User, action, timestamp, entity affected |

---

## REST API

### Base Configuration

| Setting | Value |
|---------|-------|
| **Base URL** | `http://localhost:3001/api/v1` |
| **Content-Type** | `application/json` |
| **CORS** | Enabled for dashboard origin |
| **Mock Fallback** | Returns sample data when DB is unavailable |

### Authentication

The API currently operates in **trusted mode** (intranet deployment). Authentication middleware can be enabled via the `ENABLE_AUTH` environment variable.

### Endpoint Reference

#### Dashboard & Analytics

| Endpoint | Method | Description | Response |
|----------|--------|-------------|----------|
| `/dashboard/stats` | `GET` | KPI summary cards | `{ totalPersons, totalContracts, openClaims, expiringContracts }` |
| `/dashboard/activity` | `GET` | Recent activity feed | Array of recent operations |
| `/dashboard/chart/contract-trends` | `GET` | Monthly contract volume | Time series data for charting |

#### Core Entity CRUD

| Endpoint | GET | POST | PUT | DELETE | Description |
|----------|-----|------|-----|--------|-------------|
| `/personen` | List | Create | - | - | Persons (natural & legal) |
| `/personen/:id` | Detail | - | Update | Delete | Single person record |
| `/instellingen` | List | Create | - | - | Insurance institutions |
| `/instellingen/:id` | Detail | - | Update | Delete | Single institution |
| `/objecten` | List | Create | - | - | Insurable objects |
| `/objecten/:id` | Detail | - | Update | Delete | Single object |
| `/contracten` | List | Create | - | - | Insurance contracts |
| `/contracten/:id` | Detail | - | Update | Delete | Single contract |
| `/schadeclaims` | List | Create | - | - | Damage claims |
| `/schadeclaims/:id` | Detail | - | Update | Delete | Single claim |

#### Reporting Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/rapporten/commissies` | `GET` | Commission report with filters |
| `/rapporten/contracten` | `GET` | Contract portfolio analysis |
| `/rapporten/schadeclaims` | `GET` | Claims register and statistics |
| `/rapporten/vervaldag` | `GET` | Expiry horizon report |

#### System Management

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/beheer/gebruikers` | `GET` | List system users |
| `/beheer/rollen` | `GET` | List security roles |
| `/beheer/auditlog` | `GET` | System audit trail |
| `/beheer/instellingen` | `GET` / `PUT` | System configuration |

### Example API Call

```bash
# Get all persons
curl -X GET http://localhost:3001/api/v1/personen

# Create a new person
curl -X POST http://localhost:3001/api/v1/personen \
  -H "Content-Type: application/json" \
  -d '{
    "voornaam": "Jean",
    "achternaam": "Dupont",
    "type": "natuurlijk",
    "rrn": "85.12.15-123.45",
    "email": "jean.dupont@email.be",
    "telefoon": "+32 471 12 34 56",
    "straat": "Rue de la Loi 16",
    "postcode": "1000",
    "stad": "Brussel",
    "land": "Belgie"
  }'

# Update a contract
curl -X PUT http://localhost:3001/api/v1/contracten/15 \
  -H "Content-Type: application/json" \
  -d '{
    "status": "actief",
    "premie": 1250.00,
    "vervaldatum": "2026-01-01"
  }'
```

---

## Frontend Dashboard

### Management Pages

| # | Page | Route | Key Features |
|---|------|-------|-------------|
| 1 | **Dashboard** | `/` | KPI cards, Recharts visualizations, activity feed, quick actions |
| 2 | **Personen** | `/personen` | Person CRUD, search & filter, detail drawer, RRN/KBO validation |
| 3 | **Instellingen** | `/instellingen` | Institution management, regulatory reference numbers |
| 4 | **Objecten** | `/objecten` | 6-category object catalog, type-specific forms |
| 5 | **Contracten** | `/contracten` | Contract lifecycle, version history, linked parties/objects |
| 6 | **Schadeclaims** | `/schadeclaims` | Claims with urgency color indicators, reserve tracking |
| 7 | **Rapporten** | `/rapporten` | Filterable analytics, exportable datasets, chart views |
| 8 | **Beheer** | `/beheer` | User management, role assignment, audit log viewer, settings |

### UI/UX Features

- **Responsive Design**: Fully adaptive from mobile to ultra-wide desktop
- **Toast Notifications**: Success, error, warning, and info toasts for all CRUD operations
- **Form Validation**: Client-side validation with server-side confirmation
- **Loading States**: Skeleton screens and spinners for async operations
- **Error Handling**: Graceful degradation with retry options
- **Dark Mode Support**: Automatic system preference detection
- **Keyboard Shortcuts**: Power-user navigation and quick actions
- **Print Styles**: Optimized layouts for report printing

### Frontend Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Framework | React 19 | UI component architecture |
| Language | TypeScript | Type safety and IDE support |
| Styling | Tailwind CSS | Utility-first responsive styling |
| Components | shadcn/ui | Accessible, customizable UI primitives |
| Charts | Recharts | Interactive data visualization |
| Icons | Lucide React | Consistent iconography |
| Notifications | Sonner | Toast notification system |
| Routing | React Router | Client-side navigation |

---

## VM Deployment

### Prerequisites

- Hyper-V Manager (Windows Server 2019+ or Windows 10/11 Pro)
- 8 GB RAM minimum, 16 GB recommended
- 50 GB available disk space

### Step 1: Create Virtual Hard Disk

```powershell
# Create a 50 GB dynamically expanding VHDX
.\vm\Create-VHDX.ps1 -Path "C:\VMs\AssureManager.vhdx" -SizeGB 50

# Parameters:
#   -Path       : Output path for the VHDX file
#   -SizeGB     : Maximum disk size (default: 50)
#   -Dynamic    : Expand dynamically (default: $true)
```

### Step 2: Automated VM Setup

```powershell
# Deploy Windows Server + SQL Server 2022 silently
.\vm\Setup-VM.ps1 -SaPassword "YourStrong@Pass" -VmName "AssureManager-Prod"

# Parameters:
#   -SaPassword    : SA password for SQL Server
#   -VmName        : Virtual machine name (default: AssureManager)
#   -MemoryGB      : RAM allocation (default: 8)
#   -CpuCount      : Virtual CPU cores (default: 4)
```

### Default Credentials

> :warning: **Security Notice**: Change default credentials immediately after first login.

| Component | Username | Default Password | Access |
|-----------|----------|-----------------|--------|
| Windows Server | `Administrator` | `AssureManager@2025` | RDP / Console |
| SQL Server SA | `sa` | `AssureManager@2025` | SSMS / Connection String |
| AssureManagerDB | (app pool) | (integrated) | Application-only |

### Post-Deployment Checklist

- [ ] Change Windows Administrator password
- [ ] Change SQL Server SA password
- [ ] Configure Windows Firewall rules (ports 80, 443, 1433, 3001)
- [ ] Install Windows Updates
- [ ] Deploy AssureManager database schema
- [ ] Configure API environment variables in `.env`
- [ ] Start API service (`npm start` or PM2)
- [ ] Verify dashboard accessibility
- [ ] Configure automated backups

---

## Screenshots

> Screenshots are located in the `screenshots/` directory and referenced in the interactive tutorial at `tutoruak/index.html`.

### Expected Views

| View | Description |
|------|-------------|
| **Dashboard Overview** | KPI cards showing total persons, contracts, open claims, and expiring policies with trend indicators |
| **Personen List** | Sortable, filterable table of all persons with quick actions and detail drawer |
| **Contract Detail** | Full contract view with linked parties, objects, premium breakdown, and version history |
| **Schadeclaims Board** | Claims organized by status with urgency indicators (green/yellow/red) and reserve amounts |
| **Rapporten Analytics** | Interactive Recharts visualizations with period filters and data export |
| **Beheer Settings** | User management grid, role assignment panel, and system configuration forms |

---

## Tutorial

A complete interactive tutorial is included in the repository:

```
tutoruak/
├── index.html          # Main tutorial page
├── css/
│   └── styles.css      # Tutorial-specific styles
├── js/
│   └── tutorial.js     # Interactive tutorial engine
└── images/
    ├── step-1-*.png    # Installation screenshots
    ├── step-2-*.png    # Configuration screenshots
    ├── step-3-*.png    # Database setup screenshots
    ├── step-4-*.png    # Dashboard walkthrough screenshots
    └── step-5-*.png    # Advanced features screenshots
```

### Tutorial Sections

1. **Installation Guide** - Step-by-step database and API setup
2. **Configuration** - Environment variables, connection strings, system settings
3. **Database Setup** - Running scripts, verifying tables, seed data overview
4. **Dashboard Walkthrough** - Using each management page effectively
5. **Advanced Features** - Reporting, VM deployment, backup strategies

**Open `tutoruak/index.html` in any modern browser to launch the tutorial.**

---

## Project Structure

```
assuremanager-complete/
│
├── :file_folder: sql/                          # Database deployment scripts
│   ├── 01_create_database.sql                  # Database creation
│   ├── 02_schema.sql                           # 90 table definitions
│   ├── 03_constraints.sql                      # 36 foreign keys & constraints
│   ├── 04_seeds.sql                            # 2,000+ lookup records
│   ├── 05_triggers.sql                         # 13 audit/business triggers
│   ├── 06_stored_procedures.sql                # 18 CRUD procedures
│   ├── 07_views.sql                            # 6 reporting views
│   ├── 08_test_data.sql                        # 300 sample records
│   └── deploy.ps1                              # Automated deployment script
│
├── :file_folder: api/                          # Node.js REST API
│   ├── server.js                               # Express application entry
│   ├── routes/                                 # API route handlers
│   │   ├── dashboard.js                        # KPI and analytics routes
│   │   ├── personen.js                         # Person CRUD routes
│   │   ├── instellingen.js                     # Institution routes
│   │   ├── objecten.js                         # Object catalog routes
│   │   ├── contracten.js                       # Contract lifecycle routes
│   │   ├── schadeclaims.js                     # Claims management routes
│   │   ├── rapporten.js                        # Reporting routes
│   │   └── beheer.js                           # System admin routes
│   ├── config/                                 # Configuration files
│   │   └── database.js                         # SQL Server connection pool
│   ├── middleware/                             # Express middleware
│   │   ├── errorHandler.js                     # Global error handling
│   │   └── mockFallback.js                     # Mock data fallback
│   ├── package.json                            # Dependencies & scripts
│   └── .env.example                            # Environment template
│
├── :file_folder: frontend/                     # React dashboard application
│   ├── index.html                              # Application shell
│   ├── src/
│   │   ├── main.tsx                            # React entry point
│   │   ├── App.tsx                             # Root component with routing
│   │   ├── pages/                              # Page-level components
│   │   │   ├── Dashboard.tsx                   # KPI overview page
│   │   │   ├── Personen.tsx                    # Person management page
│   │   │   ├── Instellingen.tsx                # Institution management
│   │   │   ├── Objecten.tsx                    # Object catalog page
│   │   │   ├── Contracten.tsx                  # Contract lifecycle page
│   │   │   ├── Schadeclaims.tsx                # Claims management page
│   │   │   ├── Rapporten.tsx                   # Analytics & reporting page
│   │   │   └── Beheer.tsx                      # System administration page
│   │   ├── components/                         # Reusable UI components
│   │   │   ├── DataTable.tsx                   # Sortable/filterable table
│   │   │   ├── DetailDrawer.tsx                # Slide-out detail panel
│   │   │   ├── CrudForm.tsx                    # Generic create/edit form
│   │   │   ├── StatCard.tsx                    # KPI summary card
│   │   │   ├── ChartWidget.tsx                 # Recharts wrapper
│   │   │   └── ToastProvider.tsx               # Notification system
│   │   ├── hooks/                              # Custom React hooks
│   │   │   ├── useApi.ts                       # API fetch with loading/error
│   │   │   ├── useCrud.ts                      # Generic CRUD operations
│   │   │   └── useToast.ts                     # Toast notification hook
│   │   ├── types/                              # TypeScript interfaces
│   │   │   └── index.ts                        # Shared type definitions
│   │   └── styles/                             # Tailwind & custom styles
│   │       └── globals.css                     # Global CSS overrides
│   ├── package.json                            # Frontend dependencies
│   ├── tsconfig.json                           # TypeScript configuration
│   ├── vite.config.ts                          # Vite build configuration
│   └── tailwind.config.js                      # Tailwind theme settings
│
├── :file_folder: vm/                           # Virtual machine automation
│   ├── Create-VHDX.ps1                         # VHDX disk creation
│   ├── Setup-VM.ps1                            # Full VM provisioning
│   ├── sql-server-silent.ini                   # SQL Server unattended config
│   └── Install-SQLServer.ps1                   # SQL Server silent installer
│
├── :file_folder: tutoruak/                     # Interactive tutorial
│   ├── index.html                              # Tutorial main page
│   ├── css/styles.css                          # Tutorial styles
│   ├── js/tutorial.js                          # Tutorial interactivity
│   └── images/                                 # Tutorial screenshots
│
├── :file_folder: test-data/                    # Database test engine
│   └── generate-test-data.sql                  # Test data generation script
│
├── :file_folder: screenshots/                  # Application screenshots
│
├── docker-compose.yml                          # Full stack Docker orchestration
├── nginx.conf                                  # Reverse proxy configuration
├── .env                                        # Environment variables
├── .gitignore                                  # Git exclusions
└── README.md                                   # This file
```

---

## Technologies

### Data Layer

| Technology | Version | Role |
|-----------|---------|------|
| Microsoft SQL Server 2022 Express | 16.x | Primary relational database |
| T-SQL | 2022 | Stored procedures, triggers, views |
| Full-Text Search | Built-in | Person and entity search |

### API Layer

| Technology | Version | Role |
|-----------|---------|------|
| Node.js | 20 LTS | JavaScript runtime |
| Express.js | 4.x | Web framework |
| mssql (Tedious) | 10.x | SQL Server database driver |
| dotenv | 16.x | Environment configuration |
| cors | 2.x | Cross-origin resource sharing |

### Presentation Layer

| Technology | Version | Role |
|-----------|---------|------|
| React | 19.x | UI library |
| TypeScript | 5.x | Type-safe JavaScript |
| Tailwind CSS | 3.x | Utility-first CSS framework |
| shadcn/ui | Latest | Accessible component primitives |
| Recharts | 2.x | Interactive charting library |
| Lucide React | 0.x | Icon system |
| Vite | 5.x | Build tool & dev server |

### Infrastructure

| Technology | Role |
|-----------|------|
| Hyper-V | Windows virtualization platform |
| Docker / Docker Compose | Containerized deployment |
| Nginx | Reverse proxy & static file serving |
| PowerShell 7 | Automation & VM provisioning |

---

## Contributing

This is a **private project**. Contributions are managed through direct collaboration.

### For Collaborators

1. Contact the project maintainer for repository access
2. Create a feature branch from `main`
3. Follow the existing code style (ESLint + Prettier configurations included)
4. Include tests for new stored procedures and API endpoints
5. Submit a pull request with a detailed description

### Code of Conduct

- Respect Belgian insurance industry regulations (FSMA guidelines)
- Ensure RRN/KBO data handling complies with GDPR requirements
- All database changes must include rollback scripts
- API changes must maintain backward compatibility

---

## License

**Private - All Rights Reserved**

Copyright (c) 2025 AssureManager. Unauthorized copying, distribution, or use of this software is strictly prohibited. This software is licensed exclusively to authorized Belgian insurance intermediaries.

For licensing inquiries, contact the project maintainer.

---

<p align="center">
  <strong>AssureManager</strong> - Powering Belgian Insurance Professionals
  <br />
  <sub>Built with care in Belgium :belgium: for the Belgian insurance market.</sub>
</p>
