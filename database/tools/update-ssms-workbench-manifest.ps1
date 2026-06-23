[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$manifestPath = Join-Path $repoRoot "database/ssms/demo/workbench-manifest.json"
$ssmsRoot = Join-Path $repoRoot "database/ssms"
$migrationRoot = Join-Path $repoRoot "database/migrations"
$validationRoot = Join-Path $repoRoot "database/validation"
$backendEndpointFile = Join-Path $repoRoot "backend/src/YafesPars.Api/Endpoints/DomainReadEndpoints.cs"

function Get-RelativePath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $resolved = (Resolve-Path -LiteralPath $Path).Path
    return ($resolved.Substring($repoRoot.Length).TrimStart("\", "/") -replace "\\", "/")
}

function Get-FirstMatchValue {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Pattern
    )

    $content = Get-Content -LiteralPath $Path -Raw
    $match = [regex]::Match($content, $Pattern)
    if (-not $match.Success) {
        return $null
    }

    return $match.Groups[1].Value
}

function Convert-SqlString {
    param([Parameter(Mandatory = $true)][string]$Value)
    return $Value.Replace("''", "'")
}

$dashboardPath = Join-Path $ssmsRoot "05__operator_dashboard_home.sql"
$seedDataPath = Join-Path $migrationRoot "018__seed_demo_data.sql"

$databaseName = Get-FirstMatchValue -Path $dashboardPath -Pattern ':setvar\s+YAFES_SQL_DATABASE\s+"([^"]+)"'
$tenantCode = Get-FirstMatchValue -Path $seedDataPath -Pattern "tenant_code,\s+display_name,\s+legal_name[\s\S]+?N'([^']+)'"
if ([string]::IsNullOrWhiteSpace($tenantCode)) {
    $tenantCode = Get-FirstMatchValue -Path $dashboardPath -Pattern ':setvar\s+TENANT_CODE\s+"([^"]+)"'
}

$migrationFiles = @(Get-ChildItem -LiteralPath $migrationRoot -Filter "*.sql" | Sort-Object Name)
$validationFiles = @(Get-ChildItem -LiteralPath $validationRoot -Filter "*.sql" | Sort-Object Name)
$ssmsScripts = @(Get-ChildItem -LiteralPath $ssmsRoot -Filter "*.sql" | Sort-Object Name)

$tableRegex = [regex]'CREATE\s+TABLE\s+([a-zA-Z0-9_]+)\.([a-zA-Z0-9_]+)'
$tables = New-Object System.Collections.Generic.List[object]
foreach ($file in $migrationFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($match in $tableRegex.Matches($content)) {
        $schema = $match.Groups[1].Value
        $table = $match.Groups[2].Value
        $tables.Add([pscustomobject]@{
            Schema = $schema
            Table = $table
            FullName = "$schema.$table"
            Migration = $file.Name
        }) | Out-Null
    }
}

$uniqueTables = @($tables | Sort-Object FullName -Unique)

$domainMetadata = [ordered]@{
    core = [ordered]@{ order = 10; lane = "Foundation"; title = "Core"; subheading = "Tenant, users, RBAC, migration ledger"; entryPoint = "04__admin_security_audit_queries.sql" }
    ref = [ordered]@{ order = 20; lane = "Foundation"; title = "Reference"; subheading = "Shared lookup standards"; entryPoint = "06__query_library_shortcuts.sql" }
    person = [ordered]@{ order = 30; lane = "Customer"; title = "Person"; subheading = "Natural/legal identity, contacts, bank accounts, relations"; entryPoint = "07__data_entry_bridge_templates.sql" }
    institution = [ordered]@{ order = 40; lane = "Customer"; title = "Institution"; subheading = "Insurers, banks, brokers, identifiers, addresses"; entryPoint = "06__query_library_shortcuts.sql" }
    risk = [ordered]@{ order = 50; lane = "Insurance Core"; title = "Risk/Object"; subheading = "Insurable object root, subtypes, vehicles, real estate, loans"; entryPoint = "06__query_library_shortcuts.sql" }
    policy = [ordered]@{ order = 60; lane = "Insurance Core"; title = "Policy"; subheading = "Contracts, versions, parties, objects, status, renewal flow"; entryPoint = "03__create_renewal_tasks.sql" }
    coverage = [ordered]@{ order = 70; lane = "Insurance Core"; title = "Coverage"; subheading = "Coverage catalog, domains, packages"; entryPoint = "09__graph_report_pack.sql" }
    claim = [ordered]@{ order = 80; lane = "Operations"; title = "Claim"; subheading = "Claims, parties, objects, circumstances, payment method"; entryPoint = "06__query_library_shortcuts.sql" }
    document = [ordered]@{ order = 90; lane = "Operations"; title = "Document"; subheading = "Metadata, links, versions, external storage keys"; entryPoint = "08__data_editing_guardrails.sql" }
    tasking = [ordered]@{ order = 100; lane = "Operations"; title = "Tasking"; subheading = "Tasks, comments, reminders, priority/status"; entryPoint = "10__daily_operator_checklist.sql" }
    audit = [ordered]@{ order = 110; lane = "Control"; title = "Audit"; subheading = "Audit log and change details"; entryPoint = "04__admin_security_audit_queries.sql" }
}

$schemas = foreach ($schemaName in $domainMetadata.Keys) {
    $schemaTables = @($uniqueTables | Where-Object { $_.Schema -eq $schemaName } | Sort-Object Table)
    $meta = $domainMetadata[$schemaName]
    [ordered]@{
        order = $meta.order
        schema = $schemaName
        title = $meta.title
        lane = $meta.lane
        subheading = $meta.subheading
        entryPoint = $meta.entryPoint
        tableCount = $schemaTables.Count
        tables = @($schemaTables | ForEach-Object { $_.Table })
    }
}

$shortcutRegex = [regex]"\(\s*(\d+),\s*N'((?:[^']|'')*)',\s*N'((?:[^']|'')*)',\s*N'((?:[^']|'')*)',\s*N'((?:[^']|'')*)',\s*N'((?:[^']|'')*)'\s*\)"
$shortcutContent = Get-Content -LiteralPath $dashboardPath -Raw
$shortcuts = foreach ($match in $shortcutRegex.Matches($shortcutContent)) {
    $filePath = Convert-SqlString $match.Groups[4].Value
    [ordered]@{
        order = [int]$match.Groups[1].Value
        group = Convert-SqlString $match.Groups[2].Value
        action = Convert-SqlString $match.Groups[3].Value
        ssmsFile = $filePath
        fileName = Split-Path $filePath -Leaf
        safety = Convert-SqlString $match.Groups[5].Value
        infoTip = Convert-SqlString $match.Groups[6].Value
    }
}

$apiRoutes = @()
if (Test-Path -LiteralPath $backendEndpointFile -PathType Leaf) {
    $endpointContent = Get-Content -LiteralPath $backendEndpointFile -Raw
    $apiRoutes = @([regex]::Matches($endpointContent, 'api\.MapGet\("([^"]+)"') | ForEach-Object {
        "/api$($_.Groups[1].Value)"
    } | Sort-Object)
}

$manifest = [ordered]@{
    schemaVersion = 1
    product = [ordered]@{
        name = "Yafes Pars"
        workbenchTitle = "Microsoft SQL Server Management Studio - $databaseName - Corporate Operator Workbench"
        previewTitle = "Yafes Pars - SSMS Operator Workbench"
    }
    database = [ordered]@{
        defaultName = $databaseName
        environment = "DEV"
        schemaCount = $schemas.Count
        tableCount = $uniqueTables.Count
        legacyReferenceTableCount = 89
    }
    tenant = [ordered]@{
        defaultCode = $tenantCode
        displayName = "Belgium Broker Tenant"
        environmentLabel = "DEV"
    }
    migrations = [ordered]@{
        count = $migrationFiles.Count
        latest = $migrationFiles[-1].Name
        files = @($migrationFiles | ForEach-Object { $_.Name })
    }
    validations = [ordered]@{
        count = $validationFiles.Count
        latest = $validationFiles[-1].Name
        files = @($validationFiles | ForEach-Object { $_.Name })
    }
    ssmsScripts = @($ssmsScripts | ForEach-Object {
        [ordered]@{
            fileName = $_.Name
            path = Get-RelativePath $_.FullName
            sizeBytes = $_.Length
        }
    })
    shortcuts = @($shortcuts)
    schemas = @($schemas)
    backend = [ordered]@{
        apiRoutes = @($apiRoutes)
    }
}

$manifestJson = $manifest | ConvertTo-Json -Depth 12
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($manifestPath, "$manifestJson$([Environment]::NewLine)", $utf8NoBom)
Write-Host "Updated $(Get-RelativePath $manifestPath)"
