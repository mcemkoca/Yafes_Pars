#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [string]$Server = "localhost\ASSUREMANAGER",
    [string]$Database = "AssureManagerDB",
    [string]$ScriptPath = "C:\Setup\sql",
    [string]$SaPassword = "AssureManager@2025"
)

$ErrorActionPreference = "Stop"
$LogFile = "C:\Setup\db-deploy.log"

function Write-Log([string]$Message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Tee-Object -FilePath $LogFile -Append
}

Write-Log "Starting AssureManager database deployment..."

# SQL scripts to execute in order
$Scripts = @(
    @{ File = "01_create_database.sql"; Name = "Database Creation" },
    @{ File = "02_schema.sql"; Name = "Schema (Tables)" },
    @{ File = "03_constraints.sql"; Name = "Constraints (FK/CK/UQ)" },
    @{ File = "04_seeds.sql"; Name = "Seed Data (Lookups)" },
    @{ File = "05_triggers.sql"; Name = "Triggers" },
    @{ File = "06_stored_procedures.sql"; Name = "Stored Procedures" },
    @{ File = "07_views.sql"; Name = "Views" }
)

# Find sqlcmd
$SqlCmd = Get-Command "sqlcmd" -ErrorAction SilentlyContinue
if (-not $SqlCmd) {
    # Try common paths
    $Candidates = @(
        "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe",
        "C:\Program Files (x86)\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe",
        "C:\Program Files\Microsoft SQL Server\110\Tools\Binn\sqlcmd.exe"
    )
    foreach ($c in $Candidates) {
        if (Test-Path $c) {
            $SqlCmd = $c
            break
        }
    }
}

if (-not $SqlCmd) {
    Write-Log "ERROR: sqlcmd not found. Cannot deploy database."
    exit 1
}

$SqlCmdPath = if ($SqlCmd -is [string]) { $SqlCmd } else { $SqlCmd.Source }
Write-Log "Using sqlcmd: $SqlCmdPath"

# Test connection
Write-Log "Testing SQL Server connection..."
try {
    & $SqlCmdPath -S $Server -U "sa" -P $SaPassword -Q "SELECT @@VERSION" -b -h -1 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Connection failed" }
    Write-Log "Connection successful"
} catch {
    Write-Log "ERROR: Cannot connect to SQL Server. Is the service running?"
    exit 1
}

# Execute each script
$OverallStopwatch = [System.Diagnostics.Stopwatch]::StartNew()

for ($i = 0; $i -lt $Scripts.Count; $i++) {
    $Script = $Scripts[$i]
    $StepNum = $i + 1
    $FullPath = Join-Path $ScriptPath $Script.File
    
    if (-not (Test-Path $FullPath)) {
        Write-Log "WARNING: Script not found: $FullPath, skipping..."
        continue
    }
    
    Write-Progress -Activity "Deploying AssureManager Database" `
                   -Status "Step $StepNum/$($Scripts.Count): $($Script.Name)" `
                   -PercentComplete ([math]::Round(($StepNum / $Scripts.Count) * 100))
    
    Write-Log "Executing: $($Script.Name)..."
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    # First script (database creation) runs without database context
    $DbArg = if ($i -eq 0) { "" } else { "-d `"$Database`"" }
    
    $Result = & $SqlCmdPath -S $Server -U "sa" -P $SaPassword $DbArg -b -i "$FullPath" -r1 2>&1
    $ExitCode = $LASTEXITCODE
    $Stopwatch.Stop()
    
    if ($ExitCode -ne 0) {
        Write-Log "ERROR: $($Script.Name) failed!"
        Write-Log "Output: $Result"
        throw "Deployment failed at step $StepNum"
    }
    
    Write-Log "OK: $($Script.Name) completed in $($Stopwatch.Elapsed.ToString('mm\:ss'))"
}

Write-Progress -Activity "Deploying AssureManager Database" -Completed
$OverallStopwatch.Stop()

# Verify deployment
Write-Log "Verifying deployment..."
$VerifyQuery = "USE [$Database]; SELECT 'Tables' as type, COUNT(*) as count FROM sys.tables UNION ALL SELECT 'Procedures', COUNT(*) FROM sys.procedures UNION ALL SELECT 'Views', COUNT(*) FROM sys.views;"
$VerifyResult = & $SqlCmdPath -S $Server -U "sa" -P $SaPassword -Q $VerifyQuery -h -1 -w 100
Write-Log "Verification results:"
$VerifyResult | ForEach-Object { Write-Log "  $_" }

Write-Log ""
Write-Log "=========================================="
Write-Log " DEPLOYMENT COMPLETE!"
Write-Log " Database: $Database on $Server"
Write-Log " Time: $($OverallStopwatch.Elapsed.ToString('mm\:ss'))"
Write-Log "=========================================="
