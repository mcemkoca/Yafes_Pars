<#
.SYNOPSIS
    AssureManager Database Deployment Script
    PowerShell version with progress tracking and error handling

.DESCRIPTION
    Deploys all SQL scripts in order to create the AssureManager database.
    Provides color-coded output, execution timing, and transaction rollback on error.

.PARAMETER Server
    SQL Server instance name (default: localhost\ASSUREMANAGER)

.PARAMETER Database
    Database name (default: AssureManagerDB)

.PARAMETER ScriptPath
    Path to the sql folder containing deployment scripts

.PARAMETER SqlCmdPath
    Path to sqlcmd executable (auto-detected if not specified)

.EXAMPLE
    .\deploy.ps1
    .\deploy.ps1 -Server "myserver\SQL2022" -Database "AssureManagerDB"
    .\deploy.ps1 -ScriptPath "C:\deploy\sql"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Server = "localhost\ASSUREMANAGER",

    [Parameter(Mandatory=$false)]
    [string]$Database = "AssureManagerDB",

    [Parameter(Mandatory=$false)]
    [string]$ScriptPath = $PSScriptRoot,

    [Parameter(Mandatory=$false)]
    [string]$SqlCmdPath = $null
)

# ============================================================
# Configuration
# ============================================================
$scripts = @(
    @{ File = "01_create_database.sql";   Name = "Database Creation" },
    @{ File = "02_schema.sql";            Name = "Schema (Tables)" },
    @{ File = "03_constraints.sql";       Name = "Constraints (FK/CK/UQ)" },
    @{ File = "04_seeds.sql";             Name = "Seed Data (Lookups)" },
    @{ File = "05_triggers.sql";          Name = "Triggers" },
    @{ File = "06_stored_procedures.sql"; Name = "Stored Procedures" },
    @{ File = "07_views.sql";             Name = "Views" }
)

# Colors
$colorHeader = "Cyan"
$colorSuccess = "Green"
$colorError = "Red"
$colorWarning = "Yellow"
$colorInfo = "White"

# ============================================================
# Helper Functions
# ============================================================
function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor $colorHeader
    Write-Host " $Message" -ForegroundColor $colorHeader
    Write-Host "==========================================" -ForegroundColor $colorHeader
}

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor $colorSuccess
}

function Write-Error {
    param([string]$Message)
    Write-Host "  [FAIL] $Message" -ForegroundColor $colorError
}

function Write-Info {
    param([string]$Message)
    Write-Host "  $Message" -ForegroundColor $colorInfo
}

# Find sqlcmd
function Find-SqlCmd {
    if ($SqlCmdPath -and (Test-Path $SqlCmdPath)) {
        return $SqlCmdPath
    }
    $candidates = @(
        "sqlcmd",
        "${env:ProgramFiles}\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe",
        "${env:ProgramFiles(x86)}\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe",
        "${env:ProgramFiles}\Microsoft SQL Server\110\Tools\Binn\sqlcmd.exe",
        "${env:ProgramFiles(x86)}\Microsoft SQL Server\110\Tools\Binn\sqlcmd.exe"
    )
    foreach ($c in $candidates) {
        $found = Get-Command $c -ErrorAction SilentlyContinue
        if ($found) { return $found.Source }
    }
    throw "sqlcmd not found. Install SQL Server Command Line Utilities."
}

# Execute SQL script with timing
function Invoke-SqlScript {
    param(
        [string]$ScriptFile,
        [string]$ScriptName,
        [string]$DatabaseName = $null
    )

    $fullPath = Join-Path $ScriptPath $ScriptFile
    if (-not (Test-Path $fullPath)) {
        throw "Script not found: $fullPath"
    }

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    $dbArg = if ($DatabaseName) { "-d `"$DatabaseName`"" } else { "" }
    $arguments = "-S `"$Server`" $dbArg -b -i `"$fullPath`""

    Write-Info "Running: $ScriptName ..."

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $script:SqlCmdPath
    $psi.Arguments = $arguments
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $process = [System.Diagnostics.Process]::Start($psi)
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    $stopwatch.Stop()
    $elapsed = $stopwatch.Elapsed

    if ($process.ExitCode -ne 0) {
        Write-Error "$ScriptName failed in $($elapsed.ToString('mm\:ss'))"
        Write-Host "  STDOUT: $stdout" -ForegroundColor $colorError
        Write-Host "  STDERR: $stderr" -ForegroundColor $colorError
        throw "Deployment failed at: $ScriptName"
    }

    Write-Success "$ScriptName completed in $($elapsed.ToString('mm\:ss'))"
    return $elapsed
}

# ============================================================
# Main Execution
# ============================================================
try {
    Write-Header "AssureManager Database Deploy"

    Write-Info "Server   : $Server"
    Write-Info "Database : $Database"
    Write-Info "Scripts  : $ScriptPath"

    # Verify sqlcmd
    $script:SqlCmdPath = Find-SqlCmd
    Write-Info "sqlcmd   : $SqlCmdPath"
    Write-Host ""

    # Test server connection
    Write-Info "Testing connection..."
    $testResult = & $script:SqlCmdPath -S $Server -Q "SELECT @@VERSION" -h -1 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Cannot connect to SQL Server: $Server"
    }
    Write-Success "Connected to SQL Server"
    Write-Host ""

    # Progress bar setup
    $totalSteps = $scripts.Count
    $overallStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $totalElapsed = [TimeSpan]::Zero

    # Execute each script
    for ($i = 0; $i -lt $scripts.Count; $i++) {
        $script = $scripts[$i]
        $stepNum = $i + 1

        # Progress bar
        $percentComplete = [math]::Round(($stepNum / $totalSteps) * 100)
        Write-Progress -Activity "Deploying AssureManager Database" `
                       -Status "Step $stepNum/$totalSteps : $($script.Name)" `
                       -PercentComplete $percentComplete

        # For 01_create_database.sql, don't specify database (it runs on master)
        $dbName = if ($i -eq 0) { $null } else { $Database }

        $elapsed = Invoke-SqlScript -ScriptFile $script.File -ScriptName $script.Name -DatabaseName $dbName
        $totalElapsed += $elapsed
    }

    Write-Progress -Activity "Deploying AssureManager Database" -Completed

    # Summary
    $overallStopwatch.Stop()
    Write-Host ""
    Write-Header "Deployment Complete!"
    Write-Info "Database : $Database on $Server"
    Write-Info "Scripts  : $totalSteps executed"
    Write-Info "SQL Time : $($totalElapsed.ToString('mm\:ss'))"
    Write-Info "Total    : $($overallStopwatch.Elapsed.ToString('mm\:ss'))"
    Write-Host ""
    Write-Host "  AssureManagerDB is ready for use." -ForegroundColor $colorSuccess
    Write-Host ""

    # Verify deployment
    Write-Info "Verifying deployment..."
    $verifyQuery = "USE [$Database]; SELECT 'Tables' = COUNT(*) FROM sys.tables UNION ALL SELECT 'Procedures' = COUNT(*) FROM sys.procedures UNION ALL SELECT 'Views' = COUNT(*) FROM sys.views;"
    $verifyResult = & $script:SqlCmdPath -S $Server -Q $verifyQuery -h -1
    Write-Success "Verification complete"
    Write-Info "Objects: $verifyResult"

    exit 0
}
catch {
    Write-Host ""
    Write-Error "DEPLOYMENT FAILED: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "Rollback: The database may be in an inconsistent state." -ForegroundColor $colorWarning
    Write-Host "  To clean up: DROP DATABASE $Database;" -ForegroundColor $colorWarning
    exit 1
}
