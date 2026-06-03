# SQL Server Installation Checklist

Use this checklist before running Yafes Pars migrations on a new SQL Server
instance.

## Windows Server

- [ ] Windows Server is patched.
- [ ] Time zone and NTP synchronization are configured.
- [ ] Local administrator access is restricted.
- [ ] RDP access is restricted to approved sources.
- [ ] Windows Defender or approved endpoint protection is enabled.
- [ ] Data, log, tempdb, and backup folders are created.
- [ ] Disk free space alerts are configured.

## SQL Server Setup

- [ ] SQL Server edition matches the environment.
- [ ] Latest approved SQL Server cumulative update is installed.
- [ ] SQL Server service account is dedicated and non-interactive.
- [ ] SQL Server Agent service account is dedicated where Agent is used.
- [ ] Mixed mode is enabled only when SQL logins are required.
- [ ] `sa` is disabled or protected by policy where possible.
- [ ] TCP/IP is enabled only for required interfaces.
- [ ] SQL Browser is disabled unless explicitly needed.
- [ ] Maximum server memory is configured.
- [ ] tempdb has appropriate file count, size, and growth settings.
- [ ] Database default collation is documented.

## Required Tools

- [ ] SQL Server Management Studio is installed for operators.
- [ ] `sqlcmd` is installed for automated DEV/CI validation where needed.
- [ ] PowerShell can run repository tools.
- [ ] Git client is available on engineering workstations.

## Database Preparation

- [ ] Target database name matches the environment matrix.
- [ ] Database owner is approved.
- [ ] Data and log file locations are correct.
- [ ] Recovery model matches backup strategy.
- [ ] Backup location is writable by SQL Server.
- [ ] Pre-migration backup has been tested.

## Repository Preparation

- [ ] Release branch or tag is approved.
- [ ] Static quality gate passes.
- [ ] Migration order `000` through `018` is unchanged.
- [ ] New migrations, if any, start at `019`.
- [ ] Secrets are not present in repository files.
