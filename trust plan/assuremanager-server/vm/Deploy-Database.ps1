<#
.SYNOPSIS
    Deploys the AssureManager database to SQL Server.

.DESCRIPTION
    Runs all SQL deployment scripts in order, verifies the deployment,
    and creates the API login/user for application access.

.PARAMETER Server
    SQL Server instance (default: localhost\ASSUREMANAGER).

.PARAMETER Database
    Database name (default: AssureManagerDB).

.PARAMETER SaPassword
    SA password for authentication.

.PARAMETER ScriptPath
    Path to SQL scripts (default: ..\sql relative to this script).

.PARAMETER ApiPassword
    Password for the API SQL login (default: auto-generated).

.EXAMPLE
    .\Deploy-Database.ps1 -SaPassword "YourStrongP@ssw0rd!"
    .\Deploy-Database.ps1 -Server "myserver" -SaPassword "P@ssw0rd123" -ApiPassword "ApiP@ss123"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Server = "localhost\ASSUREMANAGER",

    [Parameter(Mandatory=$false)]
    [string]$Database = "AssureManagerDB",

    [Parameter(Mandatory=$true)]
    [string]$SaPassword,

    [Parameter(Mandatory=$false)]
    [string]$ScriptPath = $null,

    [Parameter(Mandatory=$false)]
    [string]$ApiPassword = $null
)

# Auto-detect script path
if ([string]::IsNullOrEmpty($ScriptPath)) {
    $ScriptPath = Join-Path (Split-Path $PSScriptRoot -Parent) "sql"
}

# Generate API password if not provided
if ([string]::IsNullOrEmpty($ApiPassword)) {
    $ApiPassword = -join ((33..126) | Get-Random -Count 20 | ForEach-Object { [char]$_ })
    Write-Host "Generated API password: $ApiPassword" -ForegroundColor Yellow
    Write-Host "Save this password for your .env file!" -ForegroundColor Yellow
}

# ============================================================
# Functions
# ============================================================
function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host ">>> $Message" -ForegroundColor Cyan
}

function Invoke-SqlFile {
    param(
        [string]$FilePath,
        [string]$Description,
        [switch]$NoDatabase
    )
    if (-not (Test-Path $FilePath)) {
        throw "SQL file not found: $FilePath"
    }

    Write-Host "  Executing: $Description ..." -ForegroundColor Yellow -NoNewline
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    $dbArg = if (-not $NoDatabase) { "-d `"$Database`"" } else { "" }
    $result = sqlcmd -S "$Server" $dbArg -U sa -P $SaPassword -b -i "$FilePath" 2>&1
    $exitCode = $LASTEXITCODE

    $stopwatch.Stop()
    $elapsed = $stopwatch.Elapsed.ToString('mm\:ss')

    if ($exitCode -ne 0) {
        Write-Host " FAILED" -ForegroundColor Red
        Write-Host "  Error: $result" -ForegroundColor Red
        throw "SQL execution failed for: $Description"
    }
    Write-Host " OK (${elapsed})" -ForegroundColor Green
}

# ============================================================
# Main
# ============================================================
try {
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  AssureManager Database Deployment" -ForegroundColor Cyan
    Write-Host "  Server  : $Server" -ForegroundColor White
    Write-Host "  Database: $Database" -ForegroundColor White
    Write-Host "  Scripts : $ScriptPath" -ForegroundColor White
    Write-Host "============================================" -ForegroundColor Cyan

    # Verify sqlcmd
    $sqlcmd = Get-Command sqlcmd -ErrorAction SilentlyContinue
    if (-not $sqlcmd) {
        throw "sqlcmd not found. Install SQL Server Command Line Utilities."
    }

    # Test connection
    Write-Step "Testing SQL Server connection..."
    $testResult = sqlcmd -S "$Server" -U sa -P $SaPassword -Q "SELECT @@VERSION" -b -h -1 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Cannot connect to SQL Server: $Server"
    }
    Write-Host "  Connected: $($testResult.Split([Environment]::NewLine)[0].Trim())" -ForegroundColor Green

    # Deploy scripts in order
    $scripts = @(
        @{ File = "01_create_database.sql";   Description = "Create Database";         NoDatabase = $true },
        @{ File = "02_schema.sql";            Description = "Create Schema";           NoDatabase = $false },
        @{ File = "03_constraints.sql";       Description = "Apply Constraints";       NoDatabase = $false },
        @{ File = "04_seeds.sql";             Description = "Insert Seed Data";        NoDatabase = $false },
        @{ File = "05_triggers.sql";          Description = "Create Triggers";         NoDatabase = $false },
        @{ File = "06_stored_procedures.sql"; Description = "Create Stored Procedures"; NoDatabase = $false },
        @{ File = "07_views.sql";             Description = "Create Views";            NoDatabase = $false }
    )

    for ($i = 0; $i -lt $scripts.Count; $i++) {
        $script = $scripts[$i]
        $stepNum = $i + 1
        Write-Step "Step $stepNum/$($scripts.Count): $($script.Description)"
        $filePath = Join-Path $ScriptPath $script.File
        Invoke-SqlFile -FilePath $filePath -Description $script.Description -NoDatabase:$script.NoDatabase
    }

    # Create API login and user
    Write-Step "Creating API login and user..."
    $apiUserScript = @"
-- Create API login
IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'am_api_user')
BEGIN
    CREATE LOGIN am_api_user WITH PASSWORD = '$ApiPassword', CHECK_POLICY = OFF;
    PRINT 'Created login am_api_user';
END
ELSE
BEGIN
    ALTER LOGIN am_api_user WITH PASSWORD = '$ApiPassword';
    PRINT 'Updated password for am_api_user';
END
GO

USE [$Database];
GO

-- Create database user
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'am_api_user')
BEGIN
    CREATE USER am_api_user FOR LOGIN am_api_user;
    PRINT 'Created user am_api_user in $Database';
END
GO

-- Grant permissions
ALTER ROLE db_datareader ADD MEMBER am_api_user;
ALTER ROLE db_datawriter ADD MEMBER am_api_user;
GRANT EXECUTE TO am_api_user;
GRANT SELECT ON SCHEMA::dbo TO am_api_user;
PRINT 'Granted permissions to am_api_user';
GO
"@

    $tempFile = Join-Path $env:TEMP "am_create_api_user.sql"
    $apiUserScript | Out-File -FilePath $tempFile -Encoding UTF8 -Force
    Invoke-SqlFile -FilePath $tempFile -Description "Create API User"
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue

    # Verify deployment
    Write-Step "Verifying deployment..."
    $verifyQuery = "USE [$Database]; " +
        "SELECT 'tables' AS object_type, COUNT(*) AS count FROM sys.tables UNION ALL " +
        "SELECT 'procedures', COUNT(*) FROM sys.procedures UNION ALL " +
        "SELECT 'views', COUNT(*) FROM sys.views UNION ALL " +
        "SELECT 'triggers', COUNT(*) FROM sys.triggers;"

    $verifyResult = sqlcmd -S "$Server" -U sa -P $SaPassword -Q $verifyQuery -b -h -1 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Deployment verified:" -ForegroundColor Green
        $verifyResult | ForEach-Object { if ($_.Trim()) { Write-Host "    $_" -ForegroundColor White } }
    }

    # Row counts for seeded tables
    Write-Step "Seed data verification..."
    $seedQuery = "USE [$Database]; " +
        "SELECT 'Languages' AS table_name, COUNT(*) AS rows FROM Language UNION ALL " +
        "SELECT 'PhoneTypes', COUNT(*) FROM PhoneType UNION ALL " +
        "SELECT 'ContractDomains', COUNT(*) FROM ContractDomain UNION ALL " +
        "SELECT 'Coverages', COUNT(*) FROM lookup_coverage UNION ALL " +
        "SELECT 'CoverageDomains', COUNT(*) FROM coverage_domain UNION ALL " +
        "SELECT 'ClaimStatuses', COUNT(*) FROM ClaimStatus;"

    $seedResult = sqlcmd -S "$Server" -U sa -P $SaPassword -Q $seedQuery -b -h -1 2>&1
    $seedResult | ForEach-Object { if ($_.Trim()) { Write-Host "    $_" -ForegroundColor White } }

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  Database Deployment Complete!" -ForegroundColor Green
    Write-Host "  Database : $Database" -ForegroundColor White
    Write-Host "  Server   : $Server" -ForegroundColor White
    Write-Host "  API User : am_api_user" -ForegroundColor White
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Environment variables for API:" -ForegroundColor Cyan
    Write-Host "  DB_SERVER=$Server" -ForegroundColor Yellow
    Write-Host "  DB_NAME=$Database" -ForegroundColor Yellow
    Write-Host "  DB_USER=am_api_user" -ForegroundColor Yellow
    Write-Host "  DB_PASSWORD=$ApiPassword" -ForegroundColor Yellow
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Red
    Write-Host "  DEPLOYMENT FAILED" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    exit 1
}
