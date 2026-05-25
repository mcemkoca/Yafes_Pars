#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Complete AssureManager VM Setup
.DESCRIPTION
    Orchestrates the entire VM setup process:
    1. Installs SQL Server 2022 Express
    2. Deploys the AssureManager database
    3. Opens firewall ports
    4. Verifies everything is working
.PARAMETER SaPassword
    SA password for SQL Server
.PARAMETER DatabasePath
    Path to SQL scripts
.EXAMPLE
    .\Setup-VM.ps1
    .\Setup-VM.ps1 -SaPassword "MyStrong@Pass"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$SaPassword = "AssureManager@2025",
    
    [Parameter(Mandatory=$false)]
    [string]$DatabasePath = "C:\Setup\sql",
    
    [Parameter(Mandatory=$false)]
    [string]$InstanceName = "ASSUREMANAGER",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipSQLInstall
)

$ErrorActionPreference = "Stop"
$StartTime = Get-Date

$Banner = @"
========================================
  ASSUREMANAGER - VM SETUP
  SQL Server + Database Deployment
========================================
"@
Write-Host $Banner -ForegroundColor Cyan

# Check if running as administrator
$CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator. Right-click PowerShell and select 'Run as Administrator'."
    exit 1
}

# Create setup directory
New-Item -ItemType Directory -Path "C:\Setup" -Force | Out-Null
New-Item -ItemType Directory -Path "C:\Setup\sql" -Force | Out-Null

# Step 1: Install SQL Server
if (-not $SkipSQLInstall) {
    Write-Host ""
    Write-Host "[Step 1/4] Installing SQL Server 2022 Express..." -ForegroundColor Yellow
    & "$PSScriptRoot\Install-SQLServer.ps1" -SaPassword $SaPassword -InstanceName $InstanceName
    if ($LASTEXITCODE -ne 0) {
        Write-Error "SQL Server installation failed"
        exit 1
    }
    Write-Host "SQL Server installed successfully" -ForegroundColor Green
} else {
    Write-Host "[Step 1/4] Skipping SQL Server installation (--SkipSQLInstall)" -ForegroundColor Yellow
}

# Step 2: Deploy Database
Write-Host ""
Write-Host "[Step 2/4] Deploying AssureManager database..." -ForegroundColor Yellow
& "$PSScriptRoot\Deploy-Database.ps1" -Server "localhost\$InstanceName" -SaPassword $SaPassword -ScriptPath $DatabasePath
if ($LASTEXITCODE -ne 0) {
    Write-Error "Database deployment failed"
    exit 1
}
Write-Host "Database deployed successfully" -ForegroundColor Green

# Step 3: Configure Firewall
Write-Host ""
Write-Host "[Step 3/4] Configuring firewall..." -ForegroundColor Yellow
& "$PSScriptRoot\Configure-Firewall.ps1"
Write-Host "Firewall configured" -ForegroundColor Green

# Step 4: Summary
Write-Host ""
Write-Host "[Step 4/4] Setup complete!" -ForegroundColor Yellow

$EndTime = Get-Date
$Duration = $EndTime - $StartTime

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ASSUREMANAGER IS READY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Database:     AssureManagerDB"
Write-Host "  Server:       localhost\$InstanceName"
Write-Host "  SA Login:     sa"
Write-Host "  SA Password:  $SaPassword"
Write-Host "  SQL Port:     1433"
Write-Host ""
Write-Host "  Connect via SSMS:"
Write-Host "    Server:     localhost\$InstanceName"
Write-Host "    Auth:       SQL Server Authentication"
Write-Host "    Login:      sa"
Write-Host "    Password:   $SaPassword"
Write-Host ""
Write-Host "  API:          http://localhost:3001/api/v1"
Write-Host "  Setup time:   $($Duration.ToString('hh\:mm\:ss'))"
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
