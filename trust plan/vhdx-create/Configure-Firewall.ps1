#Requires -RunAsAdministrator
[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"
$LogFile = "C:\Setup\firewall.log"

function Write-Log([string]$Message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$timestamp - $Message"
}

Write-Log "Configuring firewall..."

# SQL Server (default port 1433)
New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow -ErrorAction SilentlyContinue
Write-Log "SQL Server port 1433 opened"

# SQL Server Browser (port 1434)
New-NetFirewallRule -DisplayName "SQL Server Browser" -Direction Inbound -Protocol UDP -LocalPort 1434 -Action Allow -ErrorAction SilentlyContinue
Write-Log "SQL Server Browser port 1434 opened"

# API port
New-NetFirewallRule -DisplayName "AssureManager API" -Direction Inbound -Protocol TCP -LocalPort 3001 -Action Allow -ErrorAction SilentlyContinue
Write-Log "API port 3001 opened"

# RDP
New-NetFirewallRule -DisplayName "RDP" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow -ErrorAction SilentlyContinue
Write-Log "RDP port 3389 opened"

Write-Log "Firewall configuration complete"
