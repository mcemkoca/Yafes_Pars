[CmdletBinding()]
param(
    [switch]$NoReportFile,
    [switch]$StrictStyle
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$results = New-Object System.Collections.Generic.List[object]
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

function Get-RelativePath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $resolved = (Resolve-Path -LiteralPath $Path).Path
    if ($resolved.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return ($resolved.Substring($repoRoot.Length).TrimStart("\", "/") -replace "\\", "/")
    }

    return $resolved
}

function Add-Result {
    param(
        [Parameter(Mandatory = $true)][string]$Status,
        [Parameter(Mandatory = $true)][string]$Scope,
        [Parameter(Mandatory = $true)][string]$Message
    )

    $results.Add([pscustomobject]@{
        Status = $Status
        Scope = $Scope
        Message = $Message
    }) | Out-Null

    switch ($Status) {
        "PASS" { Write-Host "[PASS] $Scope - $Message" -ForegroundColor Green }
        "WARN" {
            $warnings.Add("$Scope - $Message") | Out-Null
            Write-Host "[WARN] $Scope - $Message" -ForegroundColor Yellow
        }
        "FAIL" {
            $failures.Add("$Scope - $Message") | Out-Null
            Write-Host "[FAIL] $Scope - $Message" -ForegroundColor Red
        }
        default { Write-Host "[$Status] $Scope - $Message" }
    }
}

function Test-RequiredFiles {
    param(
        [Parameter(Mandatory = $true)][string[]]$RelativePaths,
        [Parameter(Mandatory = $true)][string]$Scope
    )

    foreach ($relativePath in $RelativePaths) {
        $fullPath = Join-Path $repoRoot $relativePath
        if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
            Add-Result "PASS" $Scope "$relativePath exists"
        }
        else {
            Add-Result "FAIL" $Scope "$relativePath is missing"
        }
    }
}

function Get-NumberedSqlFiles {
    param([Parameter(Mandatory = $true)][string]$Folder)

    $items = New-Object System.Collections.Generic.List[object]
    foreach ($file in Get-ChildItem -LiteralPath $Folder -Filter "*.sql" | Sort-Object Name) {
        if ($file.Name -match "^(\d{3})__") {
            $items.Add([pscustomobject]@{
                Number = [int]$Matches[1]
                Name = $file.Name
                FullName = $file.FullName
            }) | Out-Null
        }
        else {
            Add-Result "FAIL" "numbering" "$(Get-RelativePath $file.FullName) must start with NNN__"
        }
    }

    return @($items | Sort-Object Number, Name)
}

function Test-OrderedSqlSet {
    param(
        [Parameter(Mandatory = $true)][string]$Folder,
        [Parameter(Mandatory = $true)][string[]]$ExpectedNames,
        [Parameter(Mandatory = $true)][string]$Scope
    )

    $files = Get-NumberedSqlFiles -Folder $Folder
    $maxRequired = [int]($ExpectedNames[-1].Substring(0, 3))
    $requiredWindow = @($files | Where-Object { $_.Number -le $maxRequired } | Sort-Object Number, Name)

    $duplicates = @($files | Group-Object Number | Where-Object { $_.Count -gt 1 })
    foreach ($duplicate in $duplicates) {
        $names = ($duplicate.Group | Select-Object -ExpandProperty Name) -join ", "
        Add-Result "FAIL" $Scope "duplicate numeric prefix $($duplicate.Name): $names"
    }

    if ($requiredWindow.Count -ne $ExpectedNames.Count) {
        Add-Result "FAIL" $Scope "expected $($ExpectedNames.Count) protected scripts through $maxRequired, found $($requiredWindow.Count)"
    }

    for ($index = 0; $index -lt $ExpectedNames.Count; $index++) {
        $expected = $ExpectedNames[$index]
        if ($index -ge $requiredWindow.Count) {
            Add-Result "FAIL" $Scope "missing protected script $expected"
            continue
        }

        $actual = $requiredWindow[$index].Name
        if ($actual -eq $expected) {
            Add-Result "PASS" $Scope "$expected order preserved"
        }
        else {
            Add-Result "FAIL" $Scope "expected $expected at protected position $index, found $actual"
        }
    }

    $futureFiles = @($files | Where-Object { $_.Number -gt $maxRequired } | Sort-Object Number, Name)
    for ($index = 0; $index -lt $futureFiles.Count; $index++) {
        $expectedNumber = $maxRequired + 1 + $index
        if ($futureFiles[$index].Number -ne $expectedNumber) {
            Add-Result "FAIL" $Scope "future script $($futureFiles[$index].Name) must continue at prefix $("{0:000}" -f $expectedNumber)"
        }
    }

    if ($futureFiles.Count -eq 0) {
        Add-Result "PASS" $Scope "no future scripts beyond protected range"
    }
}

function Test-PatternScan {
    param(
        [Parameter(Mandatory = $true)][string[]]$RelativeFolders,
        [Parameter(Mandatory = $true)][string]$Pattern,
        [Parameter(Mandatory = $true)][string]$Scope,
        [Parameter(Mandatory = $true)][string]$FailureMessage
    )

    $regex = [regex]::new($Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $found = $false

    foreach ($relativeFolder in $RelativeFolders) {
        $folder = Join-Path $repoRoot $relativeFolder
        if (-not (Test-Path -LiteralPath $folder -PathType Container)) {
            Add-Result "WARN" $Scope "$relativeFolder does not exist, scan skipped"
            continue
        }

        foreach ($file in Get-ChildItem -LiteralPath $folder -Filter "*.sql" -Recurse) {
            $content = Get-Content -LiteralPath $file.FullName -Raw
            foreach ($match in $regex.Matches($content)) {
                $line = (($content.Substring(0, $match.Index) -split "`n").Count)
                Add-Result "FAIL" $Scope "$FailureMessage in $(Get-RelativePath $file.FullName):$line [$($match.Value)]"
                $found = $true
            }
        }
    }

    if (-not $found) {
        Add-Result "PASS" $Scope "no matches"
    }
}

function Test-TrackedArtifactPolicy {
    $trackedFiles = @(& git -C $repoRoot ls-files)
    $blocked = New-Object System.Collections.Generic.List[string]

    foreach ($path in $trackedFiles) {
        $normalized = $path -replace "\\", "/"

        if ($normalized -match '(^|/)\.env($|\.)' -and $normalized -notmatch '(^|/)\.env\.example$') {
            $blocked.Add("$normalized is an environment/secret file") | Out-Null
            continue
        }

        if ($normalized -match '\.(zip|7z|rar|bak|bacpac|dacpac|mdf|ldf|ndf|trn|vhd|vhdx|iso)$') {
            $blocked.Add("$normalized is a packaged, backup, database, or VM artifact") | Out-Null
        }
    }

    foreach ($item in $blocked) {
        Add-Result "FAIL" "artifact-policy" $item
    }

    if ($blocked.Count -eq 0) {
        Add-Result "PASS" "artifact-policy" "no tracked secrets, packages, database backups, or VM artifacts"
    }
}

function Test-StyleConventions {
    param([Parameter(Mandatory = $true)][string[]]$RelativeFolders)

    $missingXactAbort = New-Object System.Collections.Generic.List[string]

    foreach ($relativeFolder in $RelativeFolders) {
        $folder = Join-Path $repoRoot $relativeFolder
        foreach ($file in Get-ChildItem -LiteralPath $folder -Filter "*.sql") {
            $content = Get-Content -LiteralPath $file.FullName -Raw
            $relativePath = Get-RelativePath $file.FullName

            if ($content -notmatch "(?im)^\s*SET\s+NOCOUNT\s+ON\s*;") {
                if ($StrictStyle) {
                    Add-Result "FAIL" "style" "$relativePath is missing SET NOCOUNT ON"
                }
                else {
                    Add-Result "WARN" "style" "$relativePath is missing SET NOCOUNT ON"
                }
            }

            if ($content -notmatch "(?im)^\s*SET\s+XACT_ABORT\s+ON\s*;") {
                if ($StrictStyle) {
                    Add-Result "FAIL" "style" "$relativePath is missing SET XACT_ABORT ON"
                }
                else {
                    $missingXactAbort.Add($relativePath) | Out-Null
                }
            }
        }
    }

    if (-not $StrictStyle) {
        if ($missingXactAbort.Count -eq 0) {
            Add-Result "PASS" "style" "all migration and validation scripts include SET XACT_ABORT ON"
        }
        else {
            Add-Result "INFO" "style" "$($missingXactAbort.Count) script(s) omit SET XACT_ABORT ON; run with -StrictStyle to enforce this advisory"
        }
    }
}

function Test-SsmsOperatorConventions {
    $operatorFiles = @(
        "database/ssms/05__operator_dashboard_home.sql",
        "database/ssms/06__query_library_shortcuts.sql",
        "database/ssms/07__data_entry_bridge_templates.sql",
        "database/ssms/08__data_editing_guardrails.sql",
        "database/ssms/09__graph_report_pack.sql",
        "database/ssms/10__daily_operator_checklist.sql",
        "database/ssms/11__schema_working_logic_map.sql",
        "database/ssms/12__table_catalog_and_relationships.sql"
    )

    foreach ($relativePath in $operatorFiles) {
        $fullPath = Join-Path $repoRoot $relativePath
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
            Add-Result "FAIL" "ssms" "$relativePath is missing"
            continue
        }

        $content = Get-Content -LiteralPath $fullPath -Raw
        foreach ($requiredText in @(":ON ERROR EXIT", "TENANT_CODE", "INFO TIP")) {
            if ($content.Contains($requiredText)) {
                Add-Result "PASS" "ssms" "$relativePath contains $requiredText"
            }
            else {
                Add-Result "FAIL" "ssms" "$relativePath is missing $requiredText"
            }
        }
    }
}

function Write-Report {
    if ($NoReportFile) {
        return
    }

    $reportDir = Join-Path $repoRoot "database/execution-logs/quality-gate"
    New-Item -ItemType Directory -Force -Path $reportDir | Out-Null
    $reportPath = Join-Path $reportDir "latest-quality-gate-report.md"

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# SQL Quality Gate Report") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("Generated UTC: $([DateTime]::UtcNow.ToString("yyyy-MM-dd HH:mm:ss"))") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("| Status | Scope | Message |") | Out-Null
    $lines.Add("| --- | --- | --- |") | Out-Null

    foreach ($result in $results) {
        $message = $result.Message.Replace("|", "\|")
        $lines.Add("| $($result.Status) | $($result.Scope) | $message |") | Out-Null
    }

    Set-Content -LiteralPath $reportPath -Value $lines -Encoding UTF8
    Write-Host "Quality gate report: $(Get-RelativePath $reportPath)"
}

$expectedMigrations = @(
    "000__create_database.sql",
    "001__create_schemas.sql",
    "002__create_core_infrastructure.sql",
    "003__create_person_domain.sql",
    "004__create_institution_domain.sql",
    "005__create_object_domain.sql",
    "006__create_contract_domain.sql",
    "007__create_coverage_domain.sql",
    "008__create_claim_domain.sql",
    "009__create_document_domain.sql",
    "010__create_task_domain.sql",
    "011__create_audit_domain.sql",
    "012__add_constraints.sql",
    "013__add_indexes.sql",
    "014__add_triggers.sql",
    "015__add_views.sql",
    "016__add_stored_procedures.sql",
    "017__seed_lookup_data.sql",
    "018__seed_demo_data.sql"
)

$expectedValidations = @(
    "001__validate_core_infrastructure.sql",
    "002__validate_person_domain.sql",
    "003__validate_institution_domain.sql",
    "004__validate_risk_domain.sql",
    "005__validate_policy_domain.sql",
    "006__validate_coverage_domain.sql",
    "007__validate_claim_domain.sql",
    "008__validate_document_domain.sql",
    "009__validate_task_domain.sql",
    "010__validate_audit_domain.sql",
    "011__validate_constraints_exist.sql",
    "012__validate_indexes.sql",
    "013__validate_triggers.sql",
    "014__validate_views.sql",
    "015__validate_stored_procedures.sql",
    "016__validate_seed_data.sql",
    "017__validate_demo_data.sql"
)

$requiredDocs = @(
    "md/README.md",
    "md/mustafaplan.md",
    "md/database/azure-windows-server-deployment.md",
    "md/database/ssms-deployment-runbook.md",
    "md/database/sql-server-installation-checklist.md",
    "md/database/backup-restore-strategy.md",
    "md/database/security-hardening.md",
    "md/database/migration-execution-log-template.md",
    "md/database/environment-matrix.md",
    "md/database/production-readiness-checklist.md",
    "md/database/repository-development-plan.md"
)

Test-RequiredFiles -RelativePaths $requiredDocs -Scope "docs"
Test-TrackedArtifactPolicy
Test-OrderedSqlSet -Folder (Join-Path $repoRoot "database/migrations") -ExpectedNames $expectedMigrations -Scope "migrations"
Test-OrderedSqlSet -Folder (Join-Path $repoRoot "database/validation") -ExpectedNames $expectedValidations -Scope "validation"
Test-PatternScan -RelativeFolders @("database/migrations", "database/validation", "database/ssms", "database/templates") -Pattern "\b(AUTO_INCREMENT|SERIAL|jsonb|uuid_generate|RETURNING|LIMIT\s+[0-9]+)\b" -Scope "syntax" -FailureMessage "unsupported non-SQL Server syntax"
Test-PatternScan -RelativeFolders @("database/migrations", "database/ssms", "database/templates") -Pattern "\b(DROP\s+DATABASE|DROP\s+TABLE|TRUNCATE\s+TABLE|ALTER\s+TABLE[^\r\n;]+DROP\s+COLUMN)\b" -Scope "safety" -FailureMessage "destructive SQL pattern"
Test-PatternScan -RelativeFolders @("database/migrations", "database/validation", "database/ssms", "database/templates") -Pattern "CREATE\s+TABLE\s+(\[?dbo\]?\.)?\[?Object\]?\b" -Scope "naming" -FailureMessage "forbidden Object table name"
Test-StyleConventions -RelativeFolders @("database/migrations", "database/validation")
Test-SsmsOperatorConventions
Write-Report

Write-Host ""
Write-Host "Quality gate summary: $($failures.Count) failure(s), $($warnings.Count) warning(s)."

if ($failures.Count -gt 0) {
    exit 1
}

exit 0
