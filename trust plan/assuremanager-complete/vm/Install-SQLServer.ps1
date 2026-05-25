#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [string]$SaPassword = "AssureManager@2025",
    [string]$InstanceName = "ASSUREMANAGER"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "Continue"

$LogFile = "C:\Setup\sql-install.log"
function Write-Log([string]$Message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Tee-Object -FilePath $LogFile -Append
}

Write-Log "Starting SQL Server 2022 Express installation..."

# Download SQL Server 2022 Express
$DownloadUrl = "https://go.microsoft.com/fwlink/?linkid=2216019"
$InstallerPath = "C:\Setup\SQLEXPR_x64_ENU.exe"

if (-not (Test-Path $InstallerPath)) {
    Write-Log "Downloading SQL Server 2022 Express..."
    try {
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $InstallerPath -UseBasicParsing -TimeoutSec 300
        Write-Log "Download complete: $InstallerPath"
    } catch {
        Write-Log "ERROR: Download failed - $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Log "Installer already exists: $InstallerPath"
}

# Create configuration file
$ConfigFile = "C:\Setup\ConfigurationFile.ini"
@"
[OPTIONS]
ACTION="Install"
FEATURES=SQLENGINE
INSTANCENAME=$InstanceName
SQLSVCACCOUNT="NT AUTHORITY\SYSTEM"
SQLSVCPASSWORD="$SaPassword"
AGTSVCACCOUNT="NT AUTHORITY\NETWORK SERVICE"
ISSVCACCOUNT="NT AUTHORITY\NETWORK SERVICE"
SQLSYSADMINACCOUNTS="Builtin\Administrators"
SECURITYMODE="SQL"
SAPWD="$SaPassword"
TCPENABLED=1
NPENABLED=0
INSTALLSHAREDDIR="C:\Program Files\Microsoft SQL Server"
INSTALLSHAREDWOWDIR="C:\Program Files (x86)\Microsoft SQL Server"
INSTANCEDIR="C:\Program Files\Microsoft SQL Server"
SQLUSERDBDIR="C:\SQLData"
SQLUSERDBLOGDIR="C:\SQLLogs"
SQLBACKUPDIR="C:\SQLBackup"
UPDATEENABLED=0
USEMICROSOFTUPDATE=0
HELP="False"
INDICATEPROGRESS="True"
QUIET="True"
QUIETSIMPLE="False"
X86="False"
"@ | Set-Content -Path $ConfigFile -Encoding UTF8

Write-Log "Configuration file created: $ConfigFile"

# Create data directories
New-Item -ItemType Directory -Path "C:\SQLData" -Force | Out-Null
New-Item -ItemType Directory -Path "C:\SQLLogs" -Force | Out-Null
New-Item -ItemType Directory -Path "C:\SQLBackup" -Force | Out-Null

# Run installer
Write-Log "Starting SQL Server installation (this may take 15-30 minutes)..."
$Process = Start-Process -FilePath $InstallerPath -ArgumentList "/ConfigurationFile=`"$ConfigFile`"", "/IACCEPTSQLSERVERLICENSETERMS" -Wait -PassThru -NoNewWindow

if ($Process.ExitCode -ne 0) {
    Write-Log "ERROR: SQL Server installation failed with exit code $($Process.ExitCode)"
    exit 1
}

Write-Log "SQL Server 2022 Express installed successfully!"
Write-Log "Instance: localhost\$InstanceName"
Write-Log "SA Password: $SaPassword"

# Enable TCP/IP
Write-Log "Enabling TCP/IP..."
$Wmi = Get-WmiObject -Namespace "root\Microsoft\SqlServer\ComputerManagement16" -Class ServerNetworkProtocol -Filter "ProtocolName = 'Tcp'"
if ($Wmi) {
    $Wmi.SetEnable()
    Write-Log "TCP/IP enabled"
}

# Restart SQL Server service
Write-Log "Restarting SQL Server service..."
Restart-Service -Name "MSSQL`$$InstanceName" -Force
Write-Log "SQL Server service restarted"

Write-Log "SQL Server installation complete!"
