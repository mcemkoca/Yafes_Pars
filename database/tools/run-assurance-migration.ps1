[CmdletBinding()]
param(
    [string]$SqlServer = $env:YAFES_SQL_SERVER,
    [string]$DatabaseName = $env:YAFES_SQL_DATABASE,
    [string]$SqlUser = $env:YAFES_SQL_USER,
    [string]$SqlPassword = $env:YAFES_SQL_PASSWORD
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path (Join-Path $PSScriptRoot '..') '..')).Path
$migrationPath = Join-Path $repoRoot 'database/migrations/021__create_assurance_domain.sql'

if (-not (Test-Path $migrationPath)) {
    throw "Migration not found: $migrationPath"
}

if ([string]::IsNullOrWhiteSpace($SqlServer)) {
    $SqlServer = 'localhost,1433'
}

if ([string]::IsNullOrWhiteSpace($DatabaseName)) {
    $DatabaseName = 'YafesPars'
}

if (-not (Get-Command sqlcmd -ErrorAction SilentlyContinue)) {
    throw 'sqlcmd bulunamadÄ±. SQL Server tools kurulu olmalÄ±.'
}

if ([string]::IsNullOrWhiteSpace($SqlUser)) {
    Write-Host "Running with Windows authentication: $SqlServer / $DatabaseName"
    sqlcmd -S $SqlServer -d $DatabaseName -E -b -v YAFES_SQL_DATABASE=$DatabaseName -i $migrationPath
}
else {
    if ([string]::IsNullOrWhiteSpace($SqlPassword)) {
        throw 'YAFES_SQL_PASSWORD veya -SqlPassword gerekli.'
    }

    Write-Host "Running with SQL authentication: $SqlServer / $DatabaseName / $SqlUser"
    sqlcmd -S $SqlServer -d $DatabaseName -U $SqlUser -P $SqlPassword -C -b -v YAFES_SQL_DATABASE=$DatabaseName -i $migrationPath
}

Write-Host 'Assurance migration completed.' -ForegroundColor Green
