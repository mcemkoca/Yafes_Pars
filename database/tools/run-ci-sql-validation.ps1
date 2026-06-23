[CmdletBinding()]
param(
    [string]$Server = $env:YAFES_SQL_SERVER,
    [string]$Database = $env:YAFES_SQL_DATABASE,
    [string]$User = $env:YAFES_SQL_USER,
    [string]$Password = $env:YAFES_SQL_PASSWORD,
    [string]$BackupDirectory = $env:YAFES_SQL_BACKUP_DIR
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Server)) {
    $Server = 'localhost,1433'
}
if ([string]::IsNullOrWhiteSpace($Database)) {
    $Database = 'YafesPars_DEV'
}
if ([string]::IsNullOrWhiteSpace($User)) {
    $User = 'sa'
}
if ([string]::IsNullOrWhiteSpace($Password)) {
    throw 'YAFES_SQL_PASSWORD is required for CI SQL validation.'
}
if ([string]::IsNullOrWhiteSpace($BackupDirectory)) {
    $BackupDirectory = '/var/opt/mssql/backup'
}

if ($Database -notmatch '(?i)DEV') {
    throw 'CI database name must contain DEV.'
}

$env:YAFES_SQL_SERVER = $Server
$env:YAFES_SQL_DATABASE = $Database
$env:YAFES_SQL_USER = $User
$env:YAFES_SQL_PASSWORD = $Password
$env:YAFES_SQL_BACKUP_DIR = $BackupDirectory
$env:YAFES_SQL_TRUST_SERVER_CERTIFICATE = '1'

$runner = Join-Path $PSScriptRoot 'run-dev-migrations.ps1'
& $runner -BackupDirectory $BackupDirectory -TrustServerCertificate $true
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
