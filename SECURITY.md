# Security Policy

## Supported Scope

Security review currently covers the SSMS-first SQL Server database platform,
the guarded migration tooling, CI workflows, and the optional .NET backend
foundation in this repository.

The project is not production-ready until a verified DEV database execution,
environment-specific hardening, and deployment review have been completed.

## Reporting A Vulnerability

Do not open public issues for vulnerabilities, credentials, database backups,
production data, or tenant/customer data.

Report security concerns privately to product owner `Deuterium12{MCK}`. Include:

- affected path, workflow, script, or component
- impact and exploitability summary
- reproduction steps using non-production data only
- suggested remediation, if known

Expected triage flow:

1. Acknowledge the report.
2. Reproduce and classify severity.
3. Patch on a private or protected branch.
4. Validate with the SQL Server and backend CI workflows.
5. Publish a sanitized fix summary.

## Secret Handling

- Never commit GitHub tokens, SQL passwords, connection strings, backups, or
  exported production data.
- Use GitHub Actions secrets for long-lived credentials.
- Use generated, masked, short-lived credentials for CI-only SQL Server
  containers.
- Keep local `.env`, secret files, and SQL backups outside version control.
- Rotate any credential that was shared in chat, logs, screenshots, commits, or
  pull request text.

## Database Safety Rules

- Run migration scripts only against DEV targets unless a separate production
  release process has been approved.
- Database names used by automation must contain `DEV`.
- Production-like server names such as `prod`, `prd`, `production`, or `live`
  are rejected by the guarded migration workflow.
- A pre-migration backup path is required before executable migration runs.
- Rollback scripts are kept separate from forward migrations.

## Security Controls In This Repository

- `database/tools/run-dev-migrations.ps1` performs target checks, SQL Server
  syntax checks, unsafe migration pattern scans, backup preflight, and
  execution logging.
- `.github/workflows/sql-server-validation.yml` validates migrations in a
  disposable SQL Server container.
- `.github/dependabot.yml` keeps GitHub Actions and NuGet dependencies visible
  for review.
- `.github/CODEOWNERS` routes sensitive database, workflow, and security changes
  to the repository maintainer for review under `Deuterium12{MCK}` ownership.

## Out Of Scope For Public Discussion

- live credentials
- tenant data
- customer/person data
- database backups
- private infrastructure details
- exploit code against non-demo systems
