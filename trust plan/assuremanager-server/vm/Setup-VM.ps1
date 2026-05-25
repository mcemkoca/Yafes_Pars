<#
.SYNOPSIS
    AssureManager VM Setup - Master Orchestration Script

.DESCRIPTION
    Complete setup script that orchestrates the entire VM configuration:
    1. Installs SQL Server 2022 Express
    2. Deploys the AssureManager database
    3. Installs Node.js
    4. Sets up firewall rules
    5. Displays completion summary

.PARAMETER SaPassword
    SA password for SQL Server (required).

.PARAMETER ApiPassword
    Password for the API database user (auto-generated if not provided).

.PARAMETER NodeVersion
    Node.js version to install (default: 20).

.PARAMETER ScriptRoot
    Root directory containing sql and vm folders.

.EXAMPLE
    .\Setup-VM.ps1 -SaPassword "YourStrongP@ssw0rd!"
    .\Setup-VM.ps1 -SaPassword "P@ssw0rd123" -ApiPassword "ApiP@ss123" -NodeVersion 20
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$SaPassword,

    [Parameter(Mandatory=$false)]
    [string]$ApiPassword = $null,

    [Parameter(Mandatory=$false)]
    [string]$NodeVersion = "20",

    [Parameter(Mandatory=$false)]
    [string]$ScriptRoot = $null
)

# Requires admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator."
    exit 1
}

# Auto-detect script root
if ([string]::IsNullOrEmpty($ScriptRoot)) {
    $ScriptRoot = Split-Path $PSScriptRoot -Parent
}

$SqlScriptPath = Join-Path $ScriptRoot "sql"
$VmScriptPath = Join-Path $ScriptRoot "vm"

# ============================================================
# Banner
# ============================================================
function Show-Banner {
    Clear-Host
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "       ASSUREMANAGER VM SETUP" -ForegroundColor Cyan
    Write-Host "       Belgian Insurance Management System" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This script will:" -ForegroundColor White
    Write-Host "  1. Install SQL Server 2022 Express" -ForegroundColor White
    Write-Host "  2. Deploy AssureManager database" -ForegroundColor White
    Write-Host "  3. Install Node.js $NodeVersion" -ForegroundColor White
    Write-Host "  4. Configure Windows Firewall" -ForegroundColor White
    Write-Host "  5. Create API database user" -ForegroundColor White
    Write-Host ""
    Write-Host "Estimated time: 15-30 minutes" -ForegroundColor Yellow
    Write-Host ""
}

function Show-Summary {
    param(
        [string]$Server,
        [string]$Database,
        [string]$ApiUser,
        [string]$ApiPassword,
        [string]$NodePath
    )
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "       SETUP COMPLETE!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Database:" -ForegroundColor Cyan
    Write-Host "  Server   : $Server" -ForegroundColor White
    Write-Host "  Database : $Database" -ForegroundColor White
    Write-Host "  User     : $ApiUser" -ForegroundColor White
    Write-Host "  Password : $ApiPassword" -ForegroundColor White
    Write-Host ""
    Write-Host "Node.js:" -ForegroundColor Cyan
    Write-Host "  Path     : $NodePath" -ForegroundColor White
    Write-Host "  Version  : $(node --version 2>$null)" -ForegroundColor White
    Write-Host "  NPM      : $(npm --version 2>$null)" -ForegroundColor White
    Write-Host ""
    Write-Host "Firewall Ports:" -ForegroundColor Cyan
    Write-Host "  SQL Server : 1433 (TCP)" -ForegroundColor White
    Write-Host "  API        : 3000 (TCP)" -ForegroundColor White
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Set environment variables in .env:" -ForegroundColor White
    Write-Host "     DB_SERVER=$Server" -ForegroundColor Yellow
    Write-Host "     DB_NAME=$Database" -ForegroundColor Yellow
    Write-Host "     DB_USER=$ApiUser" -ForegroundColor Yellow
    Write-Host "     DB_PASSWORD=$ApiPassword" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  2. Start the API server:" -ForegroundColor White
    Write-Host "     cd C:\AssureManager\api" -ForegroundColor Yellow
    Write-Host "     npm install" -ForegroundColor Yellow
    Write-Host "     npm start" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  3. Access the application at:" -ForegroundColor White
    Write-Host "     http://localhost:3000/api/v1" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
}

# ============================================================
# Step Functions
# ============================================================
function Install-NodeJS {
    param([string]$Version)

    Write-Host ""
    Write-Host ">>> STEP 3: Installing Node.js $Version..." -ForegroundColor Cyan

    # Check if already installed
    $existingNode = Get-Command node -ErrorAction SilentlyContinue
    if ($existingNode) {
        $currentVersion = node --version 2>$null
        Write-Host "  Node.js already installed: $currentVersion" -ForegroundColor Yellow
        return $existingNode.Source
    }

    # Download Node.js installer
    $installerUrl = "https://nodejs.org/dist/v${Version}.latest/node-v${Version}.latest-x64.msi"
    $downloadDir = "C:\Temp"
    if (-not (Test-Path $downloadDir)) { New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null }

    $installerPath = Join-Path $downloadDir "node-${Version}-x64.msi"

    Write-Host "  Downloading Node.js $Version..." -ForegroundColor Yellow
    try {
        # Try to find exact version
        $releaseUrl = "https://nodejs.org/dist/latest-v${Version}.x/"
        $releasePage = Invoke-WebRequest -Uri $releaseUrl -UseBasicParsing -ErrorAction Stop
        $msiLink = ($releasePage.Links | Where-Object { $_.href -like "*x64.msi" } | Select-Object -First 1).href
        if ($msiLink) {
            $installerUrl = $releaseUrl + $msiLink
        }
    } catch {
        Write-Host "  Using default URL..." -ForegroundColor Yellow
    }

    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
    Write-Host "  Installing Node.js..." -ForegroundColor Yellow
    $arguments = "/i `"$installerPath`" /qn /norestart"
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru

    if ($process.ExitCode -ne 0) {
        Write-Warning "Node.js installation exited with code $($process.ExitCode)"
    } else {
        Write-Host "  [OK] Node.js installed" -ForegroundColor Green
    }

    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    $nodePath = (Get-Command node -ErrorAction SilentlyContinue).Source
    if ($nodePath) {
        Write-Host "  Node version: $(node --version)" -ForegroundColor Green
        Write-Host "  NPM version: $(npm --version)" -ForegroundColor Green
    }

    # Cleanup
    Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
    return $nodePath
}

function Set-FirewallRules {
    Write-Host ""
    Write-Host ">>> STEP 4: Configuring Windows Firewall..." -ForegroundColor Cyan

    # SQL Server
    $sqlRule = Get-NetFirewallRule -DisplayName "AssureManager SQL Server" -ErrorAction SilentlyContinue
    if (-not $sqlRule) {
        New-NetFirewallRule -DisplayName "AssureManager SQL Server" `
            -Direction Inbound -Protocol TCP -LocalPort 1433 `
            -Action Allow -Profile Any | Out-Null
        Write-Host "  [OK] SQL Server rule (port 1433)" -ForegroundColor Green
    } else {
        Write-Host "  [OK] SQL Server rule already exists" -ForegroundColor Green
    }

    # API
    $apiRule = Get-NetFirewallRule -DisplayName "AssureManager API" -ErrorAction SilentlyContinue
    if (-not $apiRule) {
        New-NetFirewallRule -DisplayName "AssureManager API" `
            -Direction Inbound -Protocol TCP -LocalPort 3000 `
            -Action Allow -Profile Any | Out-Null
        Write-Host "  [OK] API rule (port 3000)" -ForegroundColor Green
    } else {
        Write-Host "  [OK] API rule already exists" -ForegroundColor Green
    }

    # Enable ping
    $pingRule = Get-NetFirewallRule -DisplayName "AssureManager Ping" -ErrorAction SilentlyContinue
    if (-not $pingRule) {
        New-NetFirewallRule -DisplayName "AssureManager Ping" `
            -Direction Inbound -Protocol ICMPv4 -IcmpType 8 `
            -Action Allow -Profile Any | Out-Null
        Write-Host "  [OK] Ping rule (ICMP)" -ForegroundColor Green
    }
}

# ============================================================
# Main Execution
# ============================================================
Show-Banner

# Confirm
Write-Host "Press Enter to continue or Ctrl+C to cancel..." -ForegroundColor Yellow -NoNewline
Read-Host

$overallStopwatch = [System.Diagnostics.Stopwatch]::StartNew()

try {
    # Step 1: Install SQL Server
    Write-Host ""
    Write-Host ">>> STEP 1: Installing SQL Server 2022 Express..." -ForegroundColor Cyan
    $installSqlParams = @{
        SaPassword = $SaPassword
    }
    & (Join-Path $VmScriptPath "Install-SQLServer.ps1") @installSqlParams

    # Step 2: Deploy Database
    Write-Host ""
    Write-Host ">>> STEP 2: Deploying AssureManager database..." -ForegroundColor Cyan
    $deployDbParams = @{
        Server     = "localhost\ASSUREMANAGER"
        Database   = "AssureManagerDB"
        SaPassword = $SaPassword
        ScriptPath = $SqlScriptPath
    }
    if ($ApiPassword) {
        $deployDbParams['ApiPassword'] = $ApiPassword
    }
    $deployResult = & (Join-Path $VmScriptPath "Deploy-Database.ps1") @deployDbParams

    # Capture generated API password from deploy output
    if ([string]::IsNullOrEmpty($ApiPassword)) {
        # Extract from deploy output - Deploy-Database.ps1 prints: "Generated API password: <password>"
        $deployOutput = $deployResult | Out-String
        $passwordMatch = [regex]::Match($deployOutput, 'Generated API password:\s*(\S+)')
        if ($passwordMatch.Success) {
            $ApiPassword = $passwordMatch.Groups[1].Value
            Write-Host "Captured API password from deploy output" -ForegroundColor Yellow
        }
        else {
            # Fallback: generate a new password (database user will need manual password reset)
            $ApiPassword = "$(-join ((33..126) | Get-Random -Count 20 | ForEach-Object { [char]$_ }))"
            Write-Warning "Could not extract API password from deploy output. Generated new password (database user may need password reset)."
            Write-Host "API Password: $ApiPassword" -ForegroundColor Yellow
        }
    }

    # Step 3: Install Node.js
    $nodePath = Install-NodeJS -Version $NodeVersion

    # Step 4: Firewall rules
    Set-FirewallRules

    # Step 5: Create application directories
    Write-Host ""
    Write-Host ">>> STEP 5: Setting up application directories..." -ForegroundColor Cyan
    $appDir = "C:\AssureManager"
    foreach ($sub in @("api", "logs", "backup")) {
        $d = Join-Path $appDir $sub
        if (-not (Test-Path $d)) {
            New-Item -ItemType Directory -Path $d -Force | Out-Null
            Write-Host "  [OK] Created $d" -ForegroundColor Green
        }
    }

    # Completion
    $overallStopwatch.Stop()
    Write-Host ""
    Write-Host "Total setup time: $($overallStopwatch.Elapsed.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan

    Show-Summary `
        -Server "localhost\ASSUREMANAGER" `
        -Database "AssureManagerDB" `
        -ApiUser "am_api_user" `
        -ApiPassword $ApiPassword `
        -NodePath $nodePath

    Write-Host ""
    Write-Host "Log saved to: C:\AssureManager\logs\setup.log" -ForegroundColor DarkGray
}
catch {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host "  SETUP FAILED" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  - Check SQL Server logs: Event Viewer > Application" -ForegroundColor White
    Write-Host "  - Check setup logs: C:\AssureManager\logs\" -ForegroundColor White
    Write-Host "  - Verify SA password meets complexity requirements" -ForegroundColor White
    Write-Host "  - Ensure Windows is fully updated" -ForegroundColor White
    exit 1
}
