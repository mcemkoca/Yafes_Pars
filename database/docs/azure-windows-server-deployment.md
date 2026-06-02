# Azure Windows Server Deployment

This guide defines the target Azure Windows Server deployment model for Yafes
Pars while preserving the SSMS-first SQL Server operating model.

## Target Model

Yafes Pars is deployed as a SQL Server database core on a Windows Server virtual
machine in Azure. SQL Server Management Studio remains the primary operator
surface for deployment, validation, support, and controlled data operations.

The recommended production baseline is:

- Azure Windows Server VM joined to the organization network boundary.
- SQL Server Developer for DEV, SQL Server Standard or Enterprise for TEST and
  PROD according to licensing needs.
- SQL Server Management Studio installed on admin workstations or a hardened
  management VM.
- Private network access only for SQL Server.
- Azure Backup or SQL Server native backups stored outside the VM disk.
- Windows Event Log, SQL Server Error Log, SQL Agent history, and backup logs
  collected centrally.

## Environment Layout

| Environment | Purpose | Database name | Demo data | Access |
| --- | --- | --- | --- | --- |
| DEV | Developer validation and SSMS dry runs | `YafesPars_DEV` | Allowed | Engineering only |
| TEST | Release rehearsal and UAT | `YafesPars_TEST` | Optional sanitized data | Engineering and test users |
| PROD | Live business data | `YafesPars` | Not allowed | Restricted operations group |

DEV and TEST can be rebuilt from migrations. PROD must be changed only through
approved release execution.

## Azure Resource Baseline

| Resource | Baseline |
| --- | --- |
| Resource group | One group per environment or clear environment tags. |
| Virtual network | Private subnet for database VM. |
| Network security group | Allow SQL only from approved admin/app subnets. |
| VM disk | Premium SSD for data, log, and tempdb where possible. |
| Backup storage | Separate storage account or Recovery Services vault. |
| Monitoring | Azure Monitor plus SQL Server logs. |
| Secrets | Stored in approved secret manager, never in repository files. |

## SQL Server VM Layout

Use separate volumes when possible:

- `C:` operating system and tools.
- `D:` SQL Server data files.
- `L:` SQL Server log files.
- `T:` tempdb files.
- `B:` local staging area for backups before off-VM copy.

If a smaller DEV VM uses fewer disks, keep the logical folder separation so the
same runbooks still apply.

## Network Rules

- Disable public SQL Server exposure.
- Prefer VPN, Bastion, private endpoint patterns, or a jump host.
- Restrict TCP 1433 to approved source ranges.
- Keep RDP restricted to admin sources and just-in-time access where available.
- Record every temporary exception in the execution log.

## Deployment Flow

1. Provision the Windows Server VM.
2. Install and patch SQL Server.
3. Configure SQL Server service accounts and storage folders.
4. Create the target database for the environment.
5. Configure backup location and confirm SQL Server can write to it.
6. Run `database/ssms/00__open_first_safety_check.sql` in SSMS.
7. Run static quality gate from the repository.
8. Run migrations `000` through `018` in order.
9. Run validations `001` through `017` in order.
10. Complete the production readiness checklist.

## Production Guardrails

- Do not run demo seed `018__seed_demo_data.sql` in PROD.
- Do not run rollback scripts without a separate approval record.
- Do not store passwords, tokens, connection strings, or backup files in Git.
- Do not change migration numbers `000` through `018`.
- New forward migrations must start at `019`.
