#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Yafes Pars — Azure kurulum ve GitHub Secrets otomasyon scripti

.DESCRIPTION
    Bu script sırasıyla şunları yapar:
      1. Azure AD App Registration oluşturur (Federated Credential ile)
      2. Resource Group oluşturur
      3. Bicep ile Azure altyapısını deploy eder
      4. Key Vault'a SQL connection string ekler
      5. GitHub Secrets'ı otomatik ayarlar

.EXAMPLE
    ./scripts/setup-azure.ps1 `
        -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
        -SqlPassword "Guclu!Parola123" `
        -GithubToken "ghp_..."
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$SubscriptionId,
    [Parameter(Mandatory)][string]$SqlPassword,
    [Parameter(Mandatory)][string]$GithubToken,
    [string]$ResourceGroup   = "rg-yafespars-prod",
    [string]$Location        = "westeurope",
    [string]$AppName         = "yafespars",
    [string]$GithubRepo      = "mcemkoca/Yafes_Pars",
    [string]$JwtAuthority    = "",
    [string]$JwtAudience     = "yafespars-api",
    [string]$CorsOrigins     = "",
    [string]$Environment     = "prod",
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Log  { param([string]$msg) Write-Host "  $msg" -ForegroundColor Cyan }
function OK   { param([string]$msg) Write-Host "  ✓ $msg" -ForegroundColor Green }
function Warn { param([string]$msg) Write-Host "  ⚠ $msg" -ForegroundColor Yellow }
function Step { param([string]$msg) Write-Host "`n► $msg" -ForegroundColor White }

Step "Ortam kontrolü"
foreach ($cmd in @("az","gh")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        throw "$cmd bulunamadı. Lütfen yükleyin: az → https://aka.ms/installazurecliwindows  gh → https://cli.github.com"
    }
}
OK "az ve gh mevcut"

Step "Azure girişi"
az account set --subscription $SubscriptionId
$tenantId = (az account show --query tenantId -o tsv)
OK "Subscription: $SubscriptionId  Tenant: $tenantId"

# ─── 1. App Registration ──────────────────────────────────
Step "Azure AD App Registration"
$appDisplayName = "$AppName-github-actions"
$existingApp = az ad app list --display-name $appDisplayName --query "[0].appId" -o tsv 2>$null

if ($existingApp) {
    Warn "Uygulama zaten mevcut: $existingApp"
    $clientId = $existingApp
} else {
    $clientId = az ad app create --display-name $appDisplayName --query appId -o tsv
    OK "App Registration oluşturuldu: $clientId"
}

# Service Principal
$spExists = az ad sp show --id $clientId --query id -o tsv 2>$null
if (-not $spExists) {
    az ad sp create --id $clientId | Out-Null
    OK "Service Principal oluşturuldu"
}

# Federated Credential (GitHub OIDC — password'suz)
$fcName = "github-actions-main"
$fcExists = az ad app federated-credential list --id $clientId --query "[?name=='$fcName'].id" -o tsv 2>$null
if (-not $fcExists) {
    $fcBody = @{
        name        = $fcName
        issuer      = "https://token.actions.githubusercontent.com"
        subject     = "repo:$GithubRepo`:ref:refs/heads/main"
        audiences   = @("api://AzureADTokenExchange")
        description = "GitHub Actions main branch"
    } | ConvertTo-Json
    az ad app federated-credential create --id $clientId --parameters $fcBody | Out-Null
    OK "Federated Credential eklendi (OIDC — parola yok)"
}

# ─── 2. Resource Group ────────────────────────────────────
Step "Resource Group: $ResourceGroup"
$rgExists = az group exists --name $ResourceGroup
if ($rgExists -eq "true") {
    Warn "$ResourceGroup zaten mevcut"
} else {
    if (-not $DryRun) { az group create --name $ResourceGroup --location $Location | Out-Null }
    OK "$ResourceGroup oluşturuldu ($Location)"
}

# Contributor rolü
$spObjectId = az ad sp show --id $clientId --query id -o tsv
$roleExists = az role assignment list --assignee $spObjectId --role Contributor --scope "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup" --query "[0].id" -o tsv 2>$null
if (-not $roleExists) {
    if (-not $DryRun) {
        az role assignment create `
            --assignee $spObjectId `
            --role Contributor `
            --scope "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup" | Out-Null
    }
    OK "Contributor rolü atandı"
}

# ─── 3. Bicep Deploy ──────────────────────────────────────
Step "Bicep deploy: $ResourceGroup"
$bicepPath = Join-Path $PSScriptRoot ".." "infra" "main.bicep"
$appUrl    = "https://$AppName-$Environment.azurewebsites.net"
$corsValue = if ($CorsOrigins) { $CorsOrigins } else { $appUrl }

if (-not $DryRun) {
    az deployment group create `
        --resource-group $ResourceGroup `
        --template-file $bicepPath `
        --parameters environment=$Environment `
        --parameters location=$Location `
        --parameters jwtAuthority=$JwtAuthority `
        --parameters jwtAudience=$JwtAudience `
        --parameters corsAllowedOrigins=$corsValue `
        --output none
    OK "Bicep deploy tamamlandı"
} else {
    Warn "[DryRun] Bicep deploy atlandı"
}

# Key Vault adını Bicep output'undan al
$kvName = az keyvault list --resource-group $ResourceGroup --query "[0].name" -o tsv 2>$null
if (-not $kvName) { $kvName = "kv-yafespars-$Environment" }
OK "Key Vault: $kvName"

# ─── 4. Key Vault Secrets ─────────────────────────────────
Step "Key Vault secrets"
$sqlServerName = "sql-yafespars-$Environment"
$connStr = "Server=${sqlServerName}.database.windows.net;Database=YafesPars;User Id=yafespars_app;Password=$SqlPassword;TrustServerCertificate=False;Encrypt=True;"

if (-not $DryRun) {
    az keyvault secret set --vault-name $kvName --name "YafesParsConnectionString" --value $connStr | Out-Null
    OK "ConnectionString eklendi"
    if ($JwtAuthority) {
        az keyvault secret set --vault-name $kvName --name "JwtAuthority" --value $JwtAuthority | Out-Null
        OK "JwtAuthority eklendi"
    }
} else {
    Warn "[DryRun] Key Vault secrets atlandı"
}

# ─── 5. GitHub Secrets ────────────────────────────────────
Step "GitHub Secrets → $GithubRepo"
$env:GH_TOKEN = $GithubToken

$secrets = [ordered]@{
    AZURE_CLIENT_ID       = $clientId
    AZURE_TENANT_ID       = $tenantId
    AZURE_SUBSCRIPTION_ID = $SubscriptionId
    AZURE_RESOURCE_GROUP  = $ResourceGroup
}
if ($JwtAuthority) { $secrets["JWT_AUTHORITY"]      = $JwtAuthority }
if ($JwtAudience)  { $secrets["JWT_AUDIENCE"]       = $JwtAudience  }
                     $secrets["CORS_ALLOWED_ORIGINS"] = $corsValue

foreach ($kv in $secrets.GetEnumerator()) {
    if (-not $DryRun) {
        $kv.Value | gh secret set $kv.Key --repo $GithubRepo
    }
    OK "Secret set: $($kv.Key)"
}

# ─── ÖZET ─────────────────────────────────────────────────
Write-Host ""
Write-Host "════════════════════════════════════════════════" -ForegroundColor Blue
Write-Host "  Kurulum tamamlandı!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════" -ForegroundColor Blue
Write-Host "  Client ID   : $clientId"
Write-Host "  Tenant ID   : $tenantId"
Write-Host "  Sub ID      : $SubscriptionId"
Write-Host "  Rg          : $ResourceGroup"
Write-Host "  Key Vault   : $kvName"
Write-Host "  App URL     : $appUrl"
Write-Host ""
Write-Host "  Sonraki adım: GitHub → Actions → deploy.yml → Run workflow" -ForegroundColor Yellow
Write-Host "  Veya:         git push origin main   (backend değişikliği ile)" -ForegroundColor Yellow
