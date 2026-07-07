[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$programPath = Join-Path $repoRoot 'backend/src/YafesPars.Api/Program.cs'

if (-not (Test-Path $programPath)) {
    throw "Program.cs not found: $programPath"
}

$content = Get-Content -Path $programPath -Raw

if ($content -match 'MapAssuranceEndpoints\(\)') {
    Write-Host 'Program.cs already maps Assurance endpoints.' -ForegroundColor Yellow
    exit 0
}

if ($content -notmatch 'app\.MapAuditEndpoints\(\);') {
    throw 'app.MapAuditEndpoints(); not found. Add app.MapAssuranceEndpoints(); manually near endpoint registration.'
}

$content = $content -replace 'app\.MapAuditEndpoints\(\);', "app.MapAuditEndpoints();`r`n    app.MapAssuranceEndpoints();"
Set-Content -Path $programPath -Value $content -Encoding UTF8
Write-Host 'Program.cs patched: app.MapAssuranceEndpoints(); added.' -ForegroundColor Green
