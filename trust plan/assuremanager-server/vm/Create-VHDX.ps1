<#
.SYNOPSIS
    Creates a VHDX file for AssureManager deployment.

.DESCRIPTION
    Creates a dynamically expanding VHDX file that can be mounted in Hyper-V.
    The VHDX is partitioned, formatted as NTFS, and ready for OS installation.

.PARAMETER Path
    Full path where the VHDX file will be created.

.PARAMETER SizeGB
    Maximum size of the VHDX in gigabytes (default: 50).

.PARAMETER Label
    Volume label for the partition (default: AssureManager).

.EXAMPLE
    .\Create-VHDX.ps1
    .\Create-VHDX.ps1 -Path "D:\VMs\AssureManager.vhdx" -SizeGB 100
    .\Create-VHDX.ps1 -SizeGB 50 -Label "AM-SERVER"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Path = "C:\VMs\AssureManager.vhdx",

    [Parameter(Mandatory=$false)]
    [int]$SizeGB = 50,

    [Parameter(Mandatory=$false)]
    [string]$Label = "AssureManager"
)

# Requires admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator. Right-click PowerShell and select 'Run as administrator'."
    exit 1
}

# Ensure directory exists
$dir = Split-Path $Path -Parent
if (-not (Test-Path $dir)) {
    Write-Host "Creating directory: $dir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

try {
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  Creating VHDX for AssureManager" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "Path     : $Path" -ForegroundColor White
    Write-Host "Size     : $SizeGB GB (dynamically expanding)" -ForegroundColor White
    Write-Host "Label    : $Label" -ForegroundColor White
    Write-Host ""

    # Create VHDX
    Write-Host "Step 1: Creating VHDX file..." -ForegroundColor Yellow
    New-VHD -Path $Path -SizeBytes ($SizeGB * 1GB) -Dynamic -ErrorAction Stop | Out-Null
    Write-Host "  [OK] VHDX created" -ForegroundColor Green

    # Mount VHDX
    Write-Host "Step 2: Mounting VHDX..." -ForegroundColor Yellow
    $disk = Mount-DiskImage -ImagePath $Path -Passthru | Get-Disk
    Write-Host "  [OK] Mounted as Disk $($disk.Number)" -ForegroundColor Green

    # Initialize and partition
    Write-Host "Step 3: Initializing disk and creating partition..." -ForegroundColor Yellow
    $disk | Initialize-Disk -PartitionStyle GPT -PassThru | Out-Null
    $partition = $disk | New-Partition -UseMaximumSize -AssignDriveLetter
    $driveLetter = $partition.DriveLetter
    Write-Host "  [OK] Partition created at drive ${driveLetter}:" -ForegroundColor Green

    # Format
    Write-Host "Step 4: Formatting as NTFS..." -ForegroundColor Yellow
    $volume = $partition | Format-Volume -FileSystem NTFS -NewFileSystemLabel $Label -Confirm:$false
    Write-Host "  [OK] Formatted $($volume.FileSystem) with label '$Label'" -ForegroundColor Green

    # Dismount
    Write-Host "Step 5: Dismounting..." -ForegroundColor Yellow
    Dismount-DiskImage -ImagePath $Path
    Write-Host "  [OK] Dismounted" -ForegroundColor Green

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  VHDX created successfully!" -ForegroundColor Green
    Write-Host "  Path : $Path" -ForegroundColor White
    Write-Host "  Size : $SizeGB GB (dynamic)" -ForegroundColor White
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Create Hyper-V VM using this VHDX" -ForegroundColor White
    Write-Host "  2. Install Windows Server 2022" -ForegroundColor White
    Write-Host "  3. Run Setup-VM.ps1 inside the VM" -ForegroundColor White
}
catch {
    Write-Error "Failed to create VHDX: $_"
    # Cleanup on failure
    if (Test-Path $Path) {
        Remove-Item $Path -Force -ErrorAction SilentlyContinue
        Write-Warning "Cleaned up partial VHDX file"
    }
    exit 1
}
