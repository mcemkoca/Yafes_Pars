<#
.SYNOPSIS
    Silently installs SQL Server 2022 Express for AssureManager.

.DESCRIPTION
    Downloads SQL Server 2022 Express installer, configures the instance
    named ASSUREMANAGER, sets mixed-mode authentication, enables TCP/IP,
    and configures Windows Firewall rules.

.PARAMETER SaPassword
    SA password for SQL Server (must meet complexity requirements).

.PARAMETER DownloadDir
    Directory to download installer files (default: C:\SQLInstall).

.PARAMETER SqlEdition
    SQL Server edition (default: Express).

.EXAMPLE
    .\Install-SQLServer.ps1 -SaPassword "YourStrongP@ssw0rd!"
    .\Install-SQLServer.ps1 -SaPassword "P@ssw0rd123" -DownloadDir "D:\SQLSetup"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$SaPassword,

    [Parameter(Mandatory=$false)]
    [string]$DownloadDir = "C:\SQLInstall",

    [Parameter(Mandatory=$false)]
    [string]$SqlEdition = "Express"
)

# Requires admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Run as Administrator required."
    exit 1
}

# ============================================================
# Configuration
# ============================================================
$InstanceName = "ASSUREMANAGER"
$SqlInstallerUrl = "https://go.microsoft.com/fwlink/?linkid=2215158"  # SQL 2022 Express
$InstallerPath = Join-Path $DownloadDir "SQLEXPR_x64_ENU.exe"
$ExtractPath = Join-Path $DownloadDir "SQLEXPR"
$ConfigFilePath = Join-Path $DownloadDir "ConfigurationFile.ini"

# ============================================================
# Functions
# ============================================================
function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host ">>> $Message" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message = "Done")
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Fail {
    param([string]$Message)
    Write-Host "  [FAIL] $Message" -ForegroundColor Red
}

# ============================================================
# Main
# ============================================================
try {
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  SQL Server 2022 Express Installation" -ForegroundColor Cyan
    Write-Host "  Instance: $InstanceName" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan

    # Create download directory
    if (-not (Test-Path $DownloadDir)) {
        New-Item -ItemType Directory -Path $DownloadDir -Force | Out-Null
    }

    # Download installer
    Write-Step "Downloading SQL Server 2022 Express..."
    if (-not (Test-Path $InstallerPath)) {
        Write-Host "  Downloading from Microsoft... (this may take a few minutes)" -ForegroundColor Yellow
        Invoke-WebRequest -Uri $SqlInstallerUrl -OutFile $InstallerPath -UseBasicParsing
        Write-Ok "Downloaded"
    } else {
        Write-Ok "Installer already exists"
    }

    # Extract
    Write-Step "Extracting installer..."
    if (-not (Test-Path $ExtractPath)) {
        New-Item -ItemType Directory -Path $ExtractPath -Force | Out-Null
        & $InstallerPath /ACTION=Extract /QUIET /EXTRACTDIR="$ExtractPath"
        Start-Sleep -Seconds 5
        Write-Ok "Extracted to $ExtractPath"
    } else {
        Write-Ok "Already extracted"
    }

    # Create configuration file
    Write-Step "Creating configuration..."
    $setupExe = Join-Path $ExtractPath "SETUP.EXE"
    $dataDir = "C:\SQLData"
    $logDir = "C:\SQLLogs"

    foreach ($d in @($dataDir, $logDir)) {
        if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    }

    $configContent = @"
[OPTIONS]
ACTION="Install"
QUIET="True"
QUIETSIMPLE="False"
FEATURES=SQLENGINE
INSTANCENAME="$InstanceName"
INSTANCEID="$InstanceName"
SQLSVCINSTANTFILEINIT="True"
SQLSVCACCOUNT="NT Service\MSSQL`$$InstanceName"
SQLSVCPASSWORD=""
SQLSYSADMINACCOUNTS="BUILTIN\Administrators"
SECURITYMODE="SQL"
SAPWD="$SaPassword"
SQLUSERDBDIR="$dataDir"
SQLUSERDBLOGDIR="$logDir"
SQLBACKUPDIR="$dataDir\Backup"
SQLTEMPDBDIR="$dataDir"
SQLTEMPDBLOGDIR="$logDir"
TCPENABLED="1"
NPENABLED="0"
IACCEPTSQLSERVERLICENSETERMS="True"
"@

    $configPath = Join-Path $DownloadDir "ConfigurationFile.ini"
    $configContent | Out-File -FilePath $configPath -Encoding ASCII -Force
    Write-Ok "Configuration saved"

    # Install SQL Server
    Write-Step "Installing SQL Server (this may take 10-20 minutes)..." -ForegroundColor Yellow
    $arguments = "/ACTION=Install /CONFIGURATIONFILE=`"$configPath`" /IACCEPTSQLSERVERLICENSETERMS"
    Write-Host "  Running: $setupExe $arguments" -ForegroundColor DarkGray

    $process = Start-Process -FilePath $setupExe -ArgumentList $arguments -Wait -PassThru -NoNewWindow

    if ($process.ExitCode -ne 0) {
        # Check if instance already exists (exit code 3010 = success, needs reboot)
        if ($process.ExitCode -eq 3010) {
            Write-Ok "Installed (reboot required)"
        } else {
            Write-Fail "Installation exited with code $($process.ExitCode)"
            Write-Host "  Check logs at: C:\Program Files\Microsoft SQL Server\160\Setup Bootstrap\Log\" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Ok "SQL Server installed successfully"
    }

    # Enable TCP/IP
    Write-Step "Enabling TCP/IP protocol..."
    Import-Module SqlServer -ErrorAction SilentlyContinue
    $smoAssembly = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")
    $wmi = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer "localhost"
    $tcp = $wmi.ServerInstances[$InstanceName].ServerProtocols["Tcp"]
    $tcp.IsEnabled = $true
    $tcp.Alter()

    # Set TCP port to 1433
    $ipAll = $tcp.IPAddresses["IPAll"]
    $ipAll.IPAddressProperties["TcpPort"].Value = "1433"
    $ipAll.IPAddressProperties["TcpDynamicPorts"].Value = ""
    $tcp.Alter()
    Write-Ok "TCP/IP enabled on port 1433"

    # Restart SQL Server service
    Write-Step "Restarting SQL Server service..."
    $serviceName = "MSSQL`$$InstanceName"
    Restart-Service -Name $serviceName -Force
    Write-Ok "Service restarted"

    # Configure Windows Firewall
    Write-Step "Configuring Windows Firewall..."
    New-NetFirewallRule -DisplayName "SQL Server - $InstanceName" `
        -Direction Inbound -Protocol TCP -LocalPort 1433 `
        -Action Allow -Profile Any -ErrorAction SilentlyContinue | Out-Null
    Write-Ok "Firewall rule added for port 1433"

    # Test connection
    Write-Step "Testing connection..."
    $testResult = sqlcmd -S "localhost\$InstanceName" -U sa -P $SaPassword -Q "SELECT @@VERSION" -b 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "Connected successfully"
    } else {
        Write-Fail "Connection test failed"
        Write-Host "  Error: $testResult" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  SQL Server Installation Complete!" -ForegroundColor Green
    Write-Host "  Instance : localhost\$InstanceName" -ForegroundColor White
    Write-Host "  Port     : 1433" -ForegroundColor White
    Write-Host "  Auth     : Mixed (Windows + SQL)" -ForegroundColor White
    Write-Host "============================================" -ForegroundColor Green
}
catch {
    Write-Fail "Installation failed: $_"
    Write-Host "  Stack trace: $($_.ScriptStackTrace)" -ForegroundColor DarkGray
    exit 1
}
