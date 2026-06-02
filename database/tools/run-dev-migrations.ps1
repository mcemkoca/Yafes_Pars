[CmdletBinding()]
param(
    [string]$RunId = (Get-Date -Format 'yyyyMMdd_HHmmss'),
    [string]$BackupDirectory = $env:YAFES_SQL_BACKUP_DIR,
    [switch]$GenerateSsmsScriptOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$databaseRoot = Join-Path $repoRoot 'database'
$migrationRoot = Join-Path $databaseRoot 'migrations'
$validationRoot = Join-Path $databaseRoot 'validation'
$executionRoot = Join-Path $databaseRoot 'execution-logs'
$logRoot = Join-Path $executionRoot $RunId
$preparedRoot = Join-Path $logRoot 'prepared'
$migrationPreparedRoot = Join-Path $preparedRoot 'migrations'
$validationPreparedRoot = Join-Path $preparedRoot 'validation'

New-Item -ItemType Directory -Force -Path $logRoot | Out-Null
New-Item -ItemType Directory -Force -Path $migrationPreparedRoot | Out-Null
New-Item -ItemType Directory -Force -Path $validationPreparedRoot | Out-Null

$expectedMigrations = @(
    '000__create_database.sql',
    '001__create_schemas.sql',
    '002__create_core_infrastructure.sql',
    '003__create_person_domain.sql',
    '004__create_institution_domain.sql',
    '005__create_object_domain.sql',
    '006__create_contract_domain.sql',
    '007__create_coverage_domain.sql',
    '008__create_claim_domain.sql',
    '009__create_document_domain.sql',
    '010__create_task_domain.sql',
    '011__create_audit_domain.sql',
    '012__add_constraints.sql',
    '013__add_indexes.sql',
    '014__add_triggers.sql',
    '015__add_views.sql',
    '016__add_stored_procedures.sql',
    '017__seed_lookup_data.sql',
    '018__seed_demo_data.sql'
)

$expectedValidations = @(
    '001__validate_core_infrastructure.sql',
    '002__validate_person_domain.sql',
    '003__validate_institution_domain.sql',
    '004__validate_risk_domain.sql',
    '005__validate_policy_domain.sql',
    '006__validate_coverage_domain.sql',
    '007__validate_claim_domain.sql',
    '008__validate_document_domain.sql',
    '009__validate_task_domain.sql',
    '010__validate_audit_domain.sql',
    '011__validate_constraints_exist.sql',
    '012__validate_indexes.sql',
    '013__validate_triggers.sql',
    '014__validate_views.sql',
    '015__validate_stored_procedures.sql',
    '016__validate_seed_data.sql',
    '017__validate_demo_data.sql'
)

$script:MigrationResults = @()
$script:ValidationResults = @()
$script:Warnings = New-Object System.Collections.Generic.List[string]
$script:Errors = New-Object System.Collections.Generic.List[string]
$script:TargetServer = 'NOT VERIFIED'
$script:TargetDatabase = 'NOT VERIFIED'
$script:MachineName = 'NOT VERIFIED'
$script:BackupPath = 'NOT CREATED'
$script:SsmsScriptPath = 'NOT CREATED'
$script:FinalResult = 'FAILED'
$script:NextAction = 'Review the report and rerun after fixing the blocker.'

function Add-Warning {
    param([string]$Message)
    $script:Warnings.Add($Message) | Out-Null
}

function Add-ErrorMessage {
    param([string]$Message)
    $script:Errors.Add($Message) | Out-Null
}

function Write-FinalReport {
    param(
        [string]$FinalResult,
        [string]$NextAction
    )

    $reportPath = Join-Path $logRoot 'final-report.md'
    $lines = @()
    $lines += '# Dev database migration execution report'
    $lines += ''
    $lines += ('- Target server name: {0}' -f $script:TargetServer)
    $lines += ('- Target database name: {0}' -f $script:TargetDatabase)
    $lines += ('- Machine name: {0}' -f $script:MachineName)
    $lines += ('- Execution timestamp: {0}' -f $RunId)
    $lines += ('- Backup path: {0}' -f $script:BackupPath)
    $lines += ('- SSMS fallback script: {0}' -f $script:SsmsScriptPath)
    $lines += ''
    $lines += '## Migrations'
    foreach ($name in $expectedMigrations) {
        $result = $script:MigrationResults | Where-Object { $_.Name -eq $name } | Select-Object -First 1
        if ($null -eq $result) {
            $lines += ('- {0}: NOT RUN' -f $name)
        }
        else {
            $lines += ('- {0}: {1} ({2})' -f $result.Name, $result.Status, $result.Log)
        }
    }
    $lines += ''
    $lines += '## Validations'
    foreach ($name in $expectedValidations) {
        $result = $script:ValidationResults | Where-Object { $_.Name -eq $name } | Select-Object -First 1
        if ($null -eq $result) {
            $lines += ('- {0}: NOT RUN' -f $name)
        }
        else {
            $lines += ('- {0}: {1} ({2})' -f $result.Name, $result.Status, $result.Log)
        }
    }
    $lines += ''
    $lines += '## Warnings'
    if ($script:Warnings.Count -eq 0) {
        $lines += '- None'
    }
    else {
        foreach ($warning in $script:Warnings) {
            $lines += ('- {0}' -f $warning)
        }
    }
    $lines += ''
    $lines += '## Errors'
    if ($script:Errors.Count -eq 0) {
        $lines += '- None'
    }
    else {
        foreach ($errorMessage in $script:Errors) {
            $lines += ('- {0}' -f $errorMessage)
        }
    }
    $lines += ''
    $lines += ('- Final result: {0}' -f $FinalResult)
    $lines += ('- Next recommended action: {0}' -f $NextAction)

    Set-Content -Path $reportPath -Value $lines -Encoding ASCII
    Write-Host ('Final report: {0}' -f $reportPath)
}

function Resolve-OrderedSqlFiles {
    param(
        [string]$Directory,
        [string[]]$ExpectedNames,
        [string]$Label
    )

    if (-not (Test-Path -Path $Directory)) {
        throw ('Missing {0} directory: {1}' -f $Label, $Directory)
    }

    $allFiles = @(Get-ChildItem -Path $Directory -Filter '*.sql' | Sort-Object Name)
    if ($allFiles.Count -eq 0) {
        throw ('No SQL files found in {0}: {1}' -f $Label, $Directory)
    }

    $resolved = @()
    foreach ($expectedName in $ExpectedNames) {
        $exactPath = Join-Path $Directory $expectedName
        if (Test-Path -Path $exactPath) {
            $resolved += Get-Item -Path $exactPath
            continue
        }

        $prefix = $expectedName.Substring(0, 3)
        $matches = @($allFiles | Where-Object { $_.Name -match ('^{0}__.*\.sql$' -f [regex]::Escape($prefix)) })
        if ($matches.Count -eq 1) {
            Add-Warning ('Mapped {0} by numeric prefix {1}: {2}' -f $Label, $prefix, $matches[0].Name)
            $resolved += $matches[0]
            continue
        }

        if ($matches.Count -gt 1) {
            throw ('Multiple {0} files found for prefix {1}.' -f $Label, $prefix)
        }

        throw ('Missing expected {0} file: {1}' -f $Label, $expectedName)
    }

    return $resolved
}

function Assert-NoUnsupportedSqlSyntax {
    param([System.IO.FileInfo[]]$Files)

    $patterns = @(
        @{ Name = 'AUTO_INCREMENT'; Regex = '(?i)\bAUTO_INCREMENT\b' },
        @{ Name = 'SERIAL'; Regex = '(?i)\bSERIAL\b' },
        @{ Name = 'jsonb'; Regex = '(?i)\bjsonb\b' },
        @{ Name = 'uuid_generate'; Regex = '(?i)\buuid_generate' },
        @{ Name = 'RETURNING'; Regex = '(?i)\bRETURNING\b' },
        @{ Name = 'LIMIT n'; Regex = '(?i)\bLIMIT\s+[0-9]+' }
    )

    foreach ($file in $Files) {
        $content = Get-Content -Raw -Path $file.FullName
        foreach ($pattern in $patterns) {
            if ([regex]::IsMatch($content, $pattern.Regex)) {
                throw ('Unsupported non-SQL Server syntax found in {0}: {1}' -f $file.Name, $pattern.Name)
            }
        }
    }
}

function Assert-NoUnsafeMigrationOperations {
    param([System.IO.FileInfo[]]$Files)

    $patterns = @(
        @{ Name = 'DROP DATABASE'; Regex = '(?i)\bDROP\s+DATABASE\b' },
        @{ Name = 'DROP TABLE'; Regex = '(?i)\bDROP\s+TABLE\b' },
        @{ Name = 'TRUNCATE TABLE'; Regex = '(?i)\bTRUNCATE\s+TABLE\b' },
        @{ Name = 'ALTER TABLE DROP COLUMN'; Regex = '(?i)\bALTER\s+TABLE\b[\s\S]*?\bDROP\s+COLUMN\b' }
    )

    foreach ($file in $Files) {
        $content = Get-Content -Raw -Path $file.FullName
        foreach ($pattern in $patterns) {
            if ([regex]::IsMatch($content, $pattern.Regex)) {
                throw ('Unsafe migration operation found in {0}: {1}' -f $file.Name, $pattern.Name)
            }
        }

        $statements = [regex]::Split($content, '(?im)^\s*GO\s*$|;')
        foreach ($statement in $statements) {
            if ([regex]::IsMatch($statement, '(?is)\bDELETE\s+FROM\b') -and -not [regex]::IsMatch($statement, '(?is)\bWHERE\b')) {
                throw ('Unsafe migration operation found in {0}: DELETE FROM without WHERE' -f $file.Name)
            }
        }
    }
}

function Import-ConnectionSecretFile {
    param([hashtable]$Config)

    $secretFile = $env:YAFES_SQL_SECRET_FILE
    if ([string]::IsNullOrWhiteSpace($secretFile)) {
        return $Config
    }

    if (-not (Test-Path -Path $secretFile)) {
        throw 'YAFES_SQL_SECRET_FILE is set but the file cannot be found.'
    }

    $allowedKeys = @('YAFES_SQL_SERVER', 'YAFES_SQL_DATABASE', 'YAFES_SQL_USER', 'YAFES_SQL_PASSWORD')
    $lines = Get-Content -Path $secretFile
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if ($trimmed.Length -eq 0 -or $trimmed.StartsWith('#')) {
            continue
        }

        $separator = $trimmed.IndexOf('=')
        if ($separator -lt 1) {
            continue
        }

        $key = $trimmed.Substring(0, $separator).Trim()
        $value = $trimmed.Substring($separator + 1).Trim()
        if ($allowedKeys -contains $key -and [string]::IsNullOrWhiteSpace($Config[$key])) {
            $Config[$key] = $value
        }
    }

    return $Config
}

function Assert-TargetIsDev {
    param(
        [string]$ServerName,
        [string]$DatabaseName
    )

    if ([string]::IsNullOrWhiteSpace($DatabaseName)) {
        throw 'Target database is missing.'
    }

    if ($DatabaseName -notmatch '(?i)DEV') {
        throw 'Target database name must contain DEV.'
    }

    if ($DatabaseName -match "[`r`n;]") {
        throw 'Target database name contains unsafe characters.'
    }

    if ([string]::IsNullOrWhiteSpace($ServerName)) {
        throw 'Target server is missing.'
    }

    if ($ServerName -match '(?i)(prod|production|prd)') {
        throw 'Target server name suggests production.'
    }
}

function Escape-SqlIdentifier {
    param([string]$Value)
    return $Value.Replace(']', ']]')
}

function Escape-SqlString {
    param([string]$Value)
    return $Value.Replace("'", "''")
}

function Convert-ToTargetDatabaseScript {
    param(
        [string]$Content,
        [string]$DatabaseName
    )

    $identifier = Escape-SqlIdentifier -Value $DatabaseName
    $sqlString = Escape-SqlString -Value $DatabaseName
    $output = $Content
    $output = [regex]::Replace($output, '\[YafesPars\]', { param($m) ('[{0}]' -f $identifier) })
    $output = [regex]::Replace($output, "N'YafesPars'", { param($m) ("N'{0}'" -f $sqlString) })
    $output = [regex]::Replace($output, "'YafesPars'", { param($m) ("'{0}'" -f $sqlString) })
    return $output
}

function Convert-ToSsmsVariableScript {
    param([string]$Content)

    $output = $Content
    $output = [regex]::Replace($output, '\[YafesPars\]', { param($m) '[$(YAFES_SQL_DATABASE)]' })
    $output = [regex]::Replace($output, "N'YafesPars'", { param($m) "N'`$(YAFES_SQL_DATABASE)'" })
    $output = [regex]::Replace($output, "'YafesPars'", { param($m) "'`$(YAFES_SQL_DATABASE)'" })
    return $output
}

function New-PreparedScripts {
    param(
        [System.IO.FileInfo[]]$MigrationFiles,
        [System.IO.FileInfo[]]$ValidationFiles,
        [string]$DatabaseName
    )

    $preparedMigrations = @()
    foreach ($file in $MigrationFiles) {
        $content = Get-Content -Raw -Path $file.FullName
        $preparedContent = Convert-ToTargetDatabaseScript -Content $content -DatabaseName $DatabaseName
        $targetPath = Join-Path $migrationPreparedRoot $file.Name
        Set-Content -Path $targetPath -Value $preparedContent -Encoding ASCII
        $preparedMigrations += Get-Item -Path $targetPath
    }

    $preparedValidations = @()
    foreach ($file in $ValidationFiles) {
        $content = Get-Content -Raw -Path $file.FullName
        $preparedContent = Convert-ToTargetDatabaseScript -Content $content -DatabaseName $DatabaseName
        $targetPath = Join-Path $validationPreparedRoot $file.Name
        Set-Content -Path $targetPath -Value $preparedContent -Encoding ASCII
        $preparedValidations += Get-Item -Path $targetPath
    }

    return @{
        Migrations = $preparedMigrations
        Validations = $preparedValidations
    }
}

function New-SsmsExecutionScript {
    param(
        [System.IO.FileInfo[]]$MigrationFiles,
        [System.IO.FileInfo[]]$ValidationFiles,
        [string]$OutputPath
    )

    $lines = @()
    $lines += '/*'
    $lines += 'Manual SSMS fallback for Yafes Pars DEV migrations.'
    $lines += 'Enable Query > SQLCMD Mode in SSMS before running this script.'
    $lines += 'Edit YAFES_SQL_DATABASE and YAFES_SQL_BACKUP_PATH before execution.'
    $lines += 'Do not run if the database name does not contain DEV.'
    $lines += '*/'
    $lines += ':ON ERROR EXIT'
    $lines += ':setvar YAFES_SQL_DATABASE "YafesPars_Dev"'
    $lines += ':setvar YAFES_SQL_BACKUP_PATH "C:\SqlBackups\YafesPars_Dev_PreMigration_YYYYMMDD_HHMMSS.bak"'
    $lines += ''
    $lines += 'SET NOCOUNT ON;'
    $lines += 'GO'
    $lines += 'USE [master];'
    $lines += 'GO'
    $lines += "DECLARE @TargetDatabase SYSNAME = N'`$(YAFES_SQL_DATABASE)';"
    $lines += "DECLARE @BackupPath NVARCHAR(4000) = N'`$(YAFES_SQL_BACKUP_PATH)';"
    $lines += "DECLARE @ServerName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), @@SERVERNAME));"
    $lines += "DECLARE @MachineName NVARCHAR(256) = LOWER(CONVERT(NVARCHAR(256), SERVERPROPERTY('MachineName')));"
    $lines += "IF @TargetDatabase NOT LIKE N'%DEV%' THROW 51001, 'Target database name must contain DEV.', 1;"
    $lines += "IF @ServerName LIKE N'%prod%' OR @ServerName LIKE N'%production%' OR @ServerName LIKE N'%prd%' THROW 51002, 'Target server name suggests production.', 1;"
    $lines += "IF @MachineName LIKE N'%prod%' OR @MachineName LIKE N'%production%' OR @MachineName LIKE N'%prd%' THROW 51003, 'Target machine name suggests production.', 1;"
    $lines += "IF DB_ID(@TargetDatabase) IS NULL THROW 51004, 'Target DEV database must exist so a pre-migration backup can be created.', 1;"
    $lines += "IF @BackupPath LIKE N'%YYYYMMDD%' OR @BackupPath LIKE N'%HHMMSS%' THROW 51005, 'Set a timestamped backup path before running.', 1;"
    $lines += "DECLARE @BackupSql NVARCHAR(MAX) = N'BACKUP DATABASE ' + QUOTENAME(@TargetDatabase) + N' TO DISK = N''' + REPLACE(@BackupPath, N'''', N'''''') + N''' WITH COPY_ONLY, INIT, STATS = 10;';"
    $lines += "EXEC sys.sp_executesql @BackupSql;"
    $lines += "PRINT 'Pre-migration backup completed.';"
    $lines += 'GO'
    $lines += ''

    foreach ($file in $MigrationFiles) {
        $lines += ("PRINT '=== MIGRATION {0} ===';" -f $file.Name)
        $lines += 'GO'
        $content = Get-Content -Raw -Path $file.FullName
        $lines += Convert-ToSsmsVariableScript -Content $content
        $lines += ''
    }

    foreach ($file in $ValidationFiles) {
        $lines += ("PRINT '=== VALIDATION {0} ===';" -f $file.Name)
        $lines += 'GO'
        $content = Get-Content -Raw -Path $file.FullName
        $lines += Convert-ToSsmsVariableScript -Content $content
        $lines += ''
    }

    $lines += "PRINT 'SSMS fallback completed successfully.';"
    $lines += 'GO'

    Set-Content -Path $OutputPath -Value $lines -Encoding ASCII
    $script:SsmsScriptPath = $OutputPath
}

function Invoke-SqlcmdFile {
    param(
        [string]$SqlcmdPath,
        [string]$Server,
        [string]$Database,
        [string]$User,
        [string]$Password,
        [string]$InputFile,
        [string]$OutputFile
    )

    $arguments = @(
        '-S', $Server,
        '-d', $Database,
        '-U', $User,
        '-P', $Password,
        '-b',
        '-r', '1',
        '-i', $InputFile,
        '-o', $OutputFile
    )

    & $SqlcmdPath @arguments
    if ($LASTEXITCODE -ne 0) {
        throw ('sqlcmd failed for {0}. Log: {1}' -f (Split-Path -Leaf $InputFile), $OutputFile)
    }
}

function Invoke-SqlcmdQuery {
    param(
        [string]$SqlcmdPath,
        [string]$Server,
        [string]$Database,
        [string]$User,
        [string]$Password,
        [string]$Query,
        [string]$OutputFile
    )

    $arguments = @(
        '-S', $Server,
        '-d', $Database,
        '-U', $User,
        '-P', $Password,
        '-b',
        '-r', '1',
        '-h', '-1',
        '-W',
        '-s', '|',
        '-Q', $Query,
        '-o', $OutputFile
    )

    & $SqlcmdPath @arguments
    if ($LASTEXITCODE -ne 0) {
        throw ('sqlcmd query failed. Log: {0}' -f $OutputFile)
    }
}

try {
    Write-Host 'Preflight: resolving migration and validation files.'
    $migrationFiles = @(Resolve-OrderedSqlFiles -Directory $migrationRoot -ExpectedNames $expectedMigrations -Label 'migration')
    $validationFiles = @(Resolve-OrderedSqlFiles -Directory $validationRoot -ExpectedNames $expectedValidations -Label 'validation')

    Write-Host 'Preflight: checking SQL Server compatibility and unsafe migration operations.'
    Assert-NoUnsupportedSqlSyntax -Files ($migrationFiles + $validationFiles)
    Assert-NoUnsafeMigrationOperations -Files $migrationFiles

    $sqlcmd = Get-Command sqlcmd -ErrorAction SilentlyContinue
    if ($GenerateSsmsScriptOnly -or $null -eq $sqlcmd) {
        $ssmsPath = Join-Path $logRoot 'ssms-dev-migrations.sql'
        New-SsmsExecutionScript -MigrationFiles $migrationFiles -ValidationFiles $validationFiles -OutputPath $ssmsPath
        if ($null -eq $sqlcmd) {
            Add-Warning 'sqlcmd is not available in this environment.'
        }
        Add-Warning ('SSMS fallback script generated: {0}' -f $ssmsPath)
    }

    if ($GenerateSsmsScriptOnly) {
        $script:FinalResult = 'MANUAL_SCRIPT_CREATED'
        $script:NextAction = 'Open the generated SSMS script, set the SQLCMD variables, enable SQLCMD Mode, and run it against DEV only.'
        Write-FinalReport -FinalResult $script:FinalResult -NextAction $script:NextAction
        exit 0
    }

    $config = @{
        YAFES_SQL_SERVER = $env:YAFES_SQL_SERVER
        YAFES_SQL_DATABASE = $env:YAFES_SQL_DATABASE
        YAFES_SQL_USER = $env:YAFES_SQL_USER
        YAFES_SQL_PASSWORD = $env:YAFES_SQL_PASSWORD
    }
    $config = Import-ConnectionSecretFile -Config $config

    $missingKeys = @()
    foreach ($key in @('YAFES_SQL_SERVER', 'YAFES_SQL_DATABASE', 'YAFES_SQL_USER', 'YAFES_SQL_PASSWORD')) {
        if ([string]::IsNullOrWhiteSpace($config[$key])) {
            $missingKeys += $key
        }
    }
    if ($missingKeys.Count -gt 0) {
        throw ('Missing required connection variables: {0}' -f ($missingKeys -join ', '))
    }

    if ($null -eq $sqlcmd) {
        throw 'sqlcmd is not available. Manual SSMS execution is required using the generated fallback script.'
    }

    $server = [string]$config['YAFES_SQL_SERVER']
    $database = [string]$config['YAFES_SQL_DATABASE']
    $user = [string]$config['YAFES_SQL_USER']
    $password = [string]$config['YAFES_SQL_PASSWORD']

    Assert-TargetIsDev -ServerName $server -DatabaseName $database
    $script:TargetServer = $server
    $script:TargetDatabase = $database

    $prepared = New-PreparedScripts -MigrationFiles $migrationFiles -ValidationFiles $validationFiles -DatabaseName $database
    $preparedMigrations = @($prepared.Migrations)
    $preparedValidations = @($prepared.Validations)

    $preflightLog = Join-Path $logRoot 'preflight-verify-target.log'
    $verifyQuery = "SET NOCOUNT ON; SELECT CONVERT(NVARCHAR(256), @@SERVERNAME) + N'|' + DB_NAME() + N'|' + CONVERT(NVARCHAR(256), SERVERPROPERTY('MachineName'));"
    Write-Host 'Preflight: verifying SQL Server target.'
    Invoke-SqlcmdQuery -SqlcmdPath $sqlcmd.Source -Server $server -Database $database -User $user -Password $password -Query $verifyQuery -OutputFile $preflightLog

    $verifyLine = (Get-Content -Path $preflightLog | Where-Object { $_.Trim().Length -gt 0 } | Select-Object -First 1)
    if ([string]::IsNullOrWhiteSpace($verifyLine)) {
        throw 'Current database cannot be verified.'
    }

    $parts = $verifyLine.Split('|')
    if ($parts.Count -lt 3) {
        throw 'Current database verification returned an unexpected shape.'
    }

    $script:TargetServer = $parts[0].Trim()
    $script:TargetDatabase = $parts[1].Trim()
    $script:MachineName = $parts[2].Trim()

    Assert-TargetIsDev -ServerName $script:TargetServer -DatabaseName $script:TargetDatabase
    if ($script:MachineName -match '(?i)(prod|production|prd)') {
        throw 'Target machine name suggests production.'
    }
    if ($script:TargetDatabase -ne $database) {
        throw 'Connected database does not match YAFES_SQL_DATABASE.'
    }

    if ([string]::IsNullOrWhiteSpace($BackupDirectory)) {
        $BackupDirectory = $logRoot
    }
    New-Item -ItemType Directory -Force -Path $BackupDirectory | Out-Null
    $backupName = ('{0}_PreMigration_{1}.bak' -f ($database -replace '[^A-Za-z0-9_]+', '_'), $RunId)
    $script:BackupPath = Join-Path $BackupDirectory $backupName

    $backupFile = Join-Path $logRoot 'backup.sql'
    $backupLog = Join-Path $logRoot 'backup.log'
    $backupSql = "BACKUP DATABASE [{0}] TO DISK = N'{1}' WITH COPY_ONLY, INIT, STATS = 10;" -f (Escape-SqlIdentifier -Value $database), (Escape-SqlString -Value $script:BackupPath)
    Set-Content -Path $backupFile -Value $backupSql -Encoding ASCII

    Write-Host ('Backup: {0}' -f $script:BackupPath)
    Invoke-SqlcmdFile -SqlcmdPath $sqlcmd.Source -Server $server -Database 'master' -User $user -Password $password -InputFile $backupFile -OutputFile $backupLog

    foreach ($file in $preparedMigrations) {
        $logFile = Join-Path $logRoot ('migration_{0}.log' -f $file.Name)
        Write-Host ('Migration: {0}' -f $file.Name)
        try {
            $executionDatabase = $database
            if ($file.Name.StartsWith('000__')) {
                $executionDatabase = 'master'
            }
            Invoke-SqlcmdFile -SqlcmdPath $sqlcmd.Source -Server $server -Database $executionDatabase -User $user -Password $password -InputFile $file.FullName -OutputFile $logFile
            $script:MigrationResults += [pscustomobject]@{ Name = $file.Name; Status = 'SUCCESS'; Log = $logFile }
        }
        catch {
            $script:MigrationResults += [pscustomobject]@{ Name = $file.Name; Status = 'FAILED'; Log = $logFile }
            throw
        }
    }

    foreach ($file in $preparedValidations) {
        $logFile = Join-Path $logRoot ('validation_{0}.log' -f $file.Name)
        Write-Host ('Validation: {0}' -f $file.Name)
        try {
            Invoke-SqlcmdFile -SqlcmdPath $sqlcmd.Source -Server $server -Database $database -User $user -Password $password -InputFile $file.FullName -OutputFile $logFile
            $script:ValidationResults += [pscustomobject]@{ Name = $file.Name; Status = 'SUCCESS'; Log = $logFile }
        }
        catch {
            $script:ValidationResults += [pscustomobject]@{ Name = $file.Name; Status = 'FAILED'; Log = $logFile }
            throw
        }
    }

    $script:FinalResult = 'SUCCESS'
    $script:NextAction = 'Proceed to backend/API integration using the validated DEV schema.'
    Write-FinalReport -FinalResult $script:FinalResult -NextAction $script:NextAction
    exit 0
}
catch {
    Add-ErrorMessage $_.Exception.Message
    if ($script:FinalResult -ne 'SUCCESS') {
        $script:FinalResult = 'FAILED'
    }
    if ($script:SsmsScriptPath -ne 'NOT CREATED') {
        $script:NextAction = 'Use the generated SSMS fallback script or install sqlcmd, set DEV connection variables, then rerun.'
    }
    Write-FinalReport -FinalResult $script:FinalResult -NextAction $script:NextAction
    Write-Error $_.Exception.Message
    exit 1
}
