# AssureManager VM Setup Guide

Complete guide for deploying the AssureManager Insurance Management System on a Hyper-V virtual machine with SQL Server 2022 Express.

## Prerequisites

- Windows 10/11 Pro or Windows Server 2022
- Hyper-V enabled
- 8GB+ RAM available for VM
- 50GB+ free disk space

## Quick Start

### 1. Create VHDX

```powershell
# Run as Administrator
.\Create-VHDX.ps1 -Path "C:\VMs\AssureManager.vhdx" -SizeGB 50
```

### 2. Create Hyper-V VM

```powershell
New-VM -Name "AssureManager" -MemoryStartupBytes 4GB -BootDevice VHD -VHDPath "C:\VMs\AssureManager.vhdx" -Generation 2
Set-VMProcessor -VMName "AssureManager" -Count 2
Start-VM -Name "AssureManager"
```

### 3. Install Windows Server 2022

Install from ISO, configure:
- Language: English/Dutch
- Administrator password
- Network: DHCP or static IP

### 4. Run Setup Script (Inside VM)

```powershell
# Run as Administrator inside the VM
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\Setup-VM.ps1 -SaPassword "YourStrongP@ssw0rd!"
```

This installs SQL Server, deploys the database, installs Node.js, and configures the firewall.

## Manual Steps

If you prefer manual installation, follow these steps:

### SQL Server 2022 Express Installation

```powershell
# Download
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2215158" -OutFile "C:\Temp\SQLEXPR.exe"

# Install with instance name ASSUREMANAGER
C:\Temp\SQLEXPR.exe /ACTION=Install /QUIET /FEATURES=SQLENGINE /INSTANCENAME=ASSUREMANAGER /SQLSVCACCOUNT="NT SERVICE\MSSQL$ASSUREMANAGER" /SQLSYSADMINACCOUNTS="BUILTIN\Administrators" /SECURITYMODE=SQL /SAPWD="YourStrongP@ssw0rd!" /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS

# Enable TCP/IP
Import-Module SqlServer
$wmi = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer "localhost"
$tcp = $wmi.ServerInstances["ASSUREMANAGER"].ServerProtocols["Tcp"]
$tcp.IsEnabled = $true
$tcp.Alter()
Restart-Service -Name "MSSQL$ASSUREMANAGER" -Force

# Firewall
New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
```

### Database Deployment

```powershell
# Run deployment scripts in order
sqlcmd -S localhost\ASSUREMANAGER -i sql\01_create_database.sql
sqlcmd -S localhost\ASSUREMANAGER -d AssureManagerDB -i sql\02_schema.sql
sqlcmd -S localhost\ASSUREMANAGER -d AssureManagerDB -i sql\03_constraints.sql
sqlcmd -S localhost\ASSUREMANAGER -d AssureManagerDB -i sql\04_seeds.sql
sqlcmd -S localhost\ASSUREMANAGER -d AssureManagerDB -i sql\05_triggers.sql
sqlcmd -S localhost\ASSUREMANAGER -d AssureManagerDB -i sql\06_stored_procedures.sql
sqlcmd -S localhost\ASSUREMANAGER -d AssureManagerDB -i sql\07_views.sql
```

Or use the PowerShell deploy script:
```powershell
.\sql\deploy.ps1 -Server "localhost\ASSUREMANAGER"
```

### API Setup

```powershell
# Install Node.js 20
# Download from https://nodejs.org/ and install

# Setup API
mkdir C:\AssureManager\api
cd C:\AssureManager\api
npm init -y
npm install express mssql dotenv cors helmet bcryptjs jsonwebtoken

# Create .env file
@"
DB_SERVER=localhost\ASSUREMANAGER
DB_NAME=AssureManagerDB
DB_USER=am_api_user
DB_PASSWORD=your_api_password
PORT=3000
JWT_SECRET=your_jwt_secret_here
NODE_ENV=production
"@ | Out-File -FilePath .env -Encoding UTF8

# Start
node server.js
```

## File Structure

```
C:\AssureManager\
├── api\                  # Node.js REST API
├── logs\                 # Application logs
├── backup\              # Database backups
├── sql\                  # SQL deployment scripts
│   ├── 01_create_database.sql
│   ├── 02_schema.sql
│   ├── 03_constraints.sql
│   ├── 04_seeds.sql
│   ├── 05_triggers.sql
│   ├── 06_stored_procedures.sql
│   ├── 07_views.sql
│   ├── deploy.bat
│   └── deploy.ps1
└── vm\
    ├── Create-VHDX.ps1
    ├── Install-SQLServer.ps1
    ├── Deploy-Database.ps1
    ├── Setup-VM.ps1
    └── README.md
```

## SQL Scripts Reference

| Script | Purpose | Estimated Time |
|--------|---------|----------------|
| 01_create_database.sql | Create AssureManagerDB | 2s |
| 02_schema.sql | Create all tables | 10s |
| 03_constraints.sql | FK, CK, UQ constraints | 5s |
| 04_seeds.sql | Insert Belgian insurance reference data | 30s |
| 05_triggers.sql | Create triggers | 5s |
| 06_stored_procedures.sql | Create 18 stored procedures | 10s |
| 07_views.sql | Create 6 views | 5s |

## Database Users

| User | Purpose | Permissions |
|------|---------|-------------|
| sa | Admin | sysadmin |
| am_api_user | API access | db_datareader, db_datawriter, EXECUTE |

## Troubleshooting

### SQL Server Connection Issues

```powershell
# Check if SQL Server is running
Get-Service MSSQL$ASSUREMANAGER

# Check if TCP/IP is enabled
sqlcmd -S localhost\ASSUREMANAGER -Q "SELECT @@VERSION"

# Test with SQL auth
sqlcmd -S localhost\ASSUREMANAGER -U sa -P YourPassword -Q "SELECT @@VERSION"
```

### Firewall Issues

```powershell
# Check firewall rules
Get-NetFirewallRule -DisplayName "*AssureManager*" | Format-Table DisplayName, Enabled, Action

# Enable rules if disabled
Enable-NetFirewallRule -DisplayName "AssureManager SQL Server"
Enable-NetFirewallRule -DisplayName "AssureManager API"
```

### Database Corruption

```powershell
# Re-deploy (drops and recreates)
sqlcmd -S localhost\ASSUREMANAGER -Q "ALTER DATABASE AssureManagerDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE AssureManagerDB;"
sqlcmd -S localhost\ASSUREMANAGER -i sql\01_create_database.sql
# ... continue with remaining scripts
```

### VM Performance

- Allocate at least 4GB RAM to the VM
- Use SSD storage for the VHDX
- Enable Dynamic Memory in Hyper-V
- Keep SQL Server data/log files on separate VHDX if high I/O

## Security Notes

- Change default SA password immediately after installation
- Use Windows Authentication where possible
- Restrict SQL Server port 1433 to specific IPs
- Enable SQL Server audit logging
- Regular database backups: `sqlcmd -Q "BACKUP DATABASE AssureManagerDB TO DISK='C:\AssureManager\backup\db.bak'"`
- Update Windows and SQL Server regularly

## Support

For issues, check:
1. SQL Server logs: `C:\Program Files\Microsoft SQL Server\MSSQL16.ASSUREMANAGER\MSSQL\Log\`
2. Windows Event Viewer
3. AssureManager application logs: `C:\AssureManager\logs\`
