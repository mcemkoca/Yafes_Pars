# AssureManager - VM Deployment Guide

## Prerequisites

- Windows Server 2022 ISO
- Hyper-V, QEMU/KVM, or VirtualBox
- At least 4GB RAM and 50GB disk space

---

## Option 1: Hyper-V (Windows)

### 1. Create VHDX from Raw Disk

```powershell
# Convert the raw disk to VHDX
# Download qemu-img for Windows or use:
# https://cloudbase.it/qemu-img-windows/
qemu-img convert -f raw -O vhdx assuremanager-base.raw AssureManager.vhdx
```

### 2. Create Answer ISO

```powershell
# Mount the Autounattend.xml and scripts into an ISO
oscdimg -n -bC:\WinPE\etfsboot.com C:\SetupFiles C:\SetupISO\setup.iso
```

### 3. Create VM

```powershell
New-VM -Name "AssureManager" -MemoryStartupBytes 4GB -Generation 2
Add-VMHardDiskDrive -VMName "AssureManager" -Path "C:\VMs\AssureManager.vhdx"
Add-VMDvdDrive -VMName "AssureManager" -Path "C:\ISOs\windows-server-2022.iso"
Add-VMDvdDrive -VMName "AssureManager" -Path "C:\SetupISO\setup.iso"
Set-VMFirmware -VMName "AssureManager" -FirstBootDevice (Get-VMDvdDrive -VMName "AssureManager")[0]
Start-VM -Name "AssureManager"
```

### 4. Automated Installation

Windows will install automatically using `Autounattend.xml`. After first login:
- SQL Server 2022 Express installs automatically
- Database deploys automatically
- Firewall ports open automatically

### 5. Connect

```
Server:     localhost\ASSUREMANAGER
Auth:       SQL Server Authentication
Login:      sa
Password:   AssureManager@2025
Port:       1433
```

---

## Option 2: QEMU/KVM (Linux)

### 1. Convert Raw to QCOW2

```bash
qemu-img convert -f raw -O qcow2 assuremanager-base.raw assuremanager.qcow2
```

### 2. Create Setup ISO with Scripts

```bash
# Install genisoimage if needed
sudo apt-get install genisoimage

# Create ISO with Autounattend.xml and scripts
genisoimage -o setup-files.iso -J -R -V "SETUP" \
  -graft-points \
  /Autounattend.xml=Autounattend.xml \
  /Setup/Install-SQLServer.ps1=Install-SQLServer.ps1 \
  /Setup/Deploy-Database.ps1=Deploy-Database.ps1 \
  /Setup/Configure-Firewall.ps1=Configure-Firewall.ps1 \
  /Setup/Setup-VM.ps1=Setup-VM.ps1 \
  /Setup/sql/=sql/
```

### 3. Boot VM

```bash
qemu-system-x86_64 \
  -enable-kvm \
  -m 4096 \
  -smp 4 \
  -cpu host \
  -hda assuremanager.qcow2 \
  -cdrom windows-server-2022.iso \
  -drive file=setup-files.iso,media=cdrom \
  -boot d \
  -netdev user,id=net0 -device e1000,netdev=net0 \
  -vnc :0
```

---

## Option 3: Existing VM / Manual Install

1. Copy all files from the `sql/` folder to `C:\Setup\sql\`
2. Copy all PowerShell scripts to `C:\Setup\`
3. Open PowerShell as Administrator
4. Run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
cd C:\Setup
.\Setup-VM.ps1 -SaPassword "AssureManager@2025"
```

---

## Option 4: Convert to VHDX for Azure

```bash
# Convert raw to VHD (fixed-size, required for Azure)
qemu-img convert -f raw -O vpc -o subformat=fixed assuremanager-base.raw AssureManager-Azure.vhd

# Or convert to VHDX for Hyper-V
qemu-img convert -f raw -O vhdx assuremanager-base.raw AssureManager.vhdx
```

---

## File Structure

```
vhdx-create/
|-- assuremanager-base.raw      # 50GB base disk image
|-- Autounattend.xml             # Windows unattended install config
|-- Install-SQLServer.ps1        # SQL Server silent installer
|-- Deploy-Database.ps1          # Database deployment script
|-- Configure-Firewall.ps1       # Firewall configuration
|-- Setup-VM.ps1                 # Master orchestrator
|-- VM-DEPLOY-README.md          # This file
|-- sql/
    |-- 01_create_database.sql
    |-- 02_schema.sql
    |-- 03_constraints.sql
    |-- 04_seeds.sql
    |-- 05_triggers.sql
    |-- 06_stored_procedures.sql
    |-- 07_views.sql
```

---

## Default Credentials

| Setting          | Value                    |
|-----------------|--------------------------|
| Windows Admin   | Administrator            |
| Windows Password| AssureManager@2025       |
| SQL Instance    | ASSUREMANAGER            |
| SQL SA Password | AssureManager@2025       |
| Database        | AssureManagerDB          |
| SQL Port        | 1433                     |
| API Port        | 3001                     |

---

## Post-Deployment

After deployment completes:

1. **Connect via RDP**: `mstsc` -> VM IP -> Administrator/AssureManager@2025
2. **Open SSMS**: Connect to `localhost\ASSUREMANAGER` with SA
3. **API**: Available at `http://<vm-ip>:3001/api/v1`
4. **SQL**: Available on port 1433 for external connections

---

## Troubleshooting

### SQL Server Installation Fails

```powershell
# Check logs
cat C:\Setup\sql-install.log

# Check SQL Server setup logs
cat "C:\Program Files\Microsoft SQL Server\160\Setup Bootstrap\Log\Summary.txt"
```

### Database Deployment Fails

```powershell
# Check logs
cat C:\Setup\db-deploy.log

# Manual deploy
cd C:\Setup
.\Deploy-Database.ps1 -SaPassword "AssureManager@2025"
```

### Cannot Connect Externally

```powershell
# Verify firewall
Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*SQL*" }

# Verify SQL TCP
test-netconnection localhost -Port 1433
```

### Convert Disk Format

```bash
# Raw to QCOW2
qemu-img convert -f raw -O qcow2 assuremanager-base.raw disk.qcow2

# Raw to VHDX
qemu-img convert -f raw -O vhdx assuremanager-base.raw disk.vhdx

# Raw to VMDK (VMware)
qemu-img convert -f raw -O vmdk assuremanager-base.raw disk.vmdk
```

---

## Security Notes

- **Change default passwords** before production use
- Use Windows Server 2022 Eval ISO for testing
- The KMS key provided is for evaluation only
- Disable autologon after setup is complete
- Review firewall rules for your environment
