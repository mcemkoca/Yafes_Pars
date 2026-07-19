# MCP Gap Analysis Report — 2026-07-19

**Status:** CLOSED  
**Owner:** Deuterium12{MCK}

## Scope

Assessment of MCP tool coverage against all stored procedures introduced by
migrations 040–043, plus tool registry visibility audit.

## Coverage Matrix

### Migration 040 — `policy.RenewalQueue` (RenewalTools.cs)

| Stored Procedure | MCP Tool | Status |
|---|---|---|
| `policy.SP_GetRenewalQueue` | `GetRenewalQueue` | COVERED |
| `policy.SP_ProcessRenewal` | `ProcessRenewal` | COVERED |
| `policy.SP_GetRenewalMetrics` | `GetRenewalMetrics` | COVERED |
| *(bulk notification bonus)* | `SendRenewalNotices` | COVERED |

All renewal SPs covered. Email notification tool bonus — calls SP_GetRenewalQueue
(PENDING filter) + IEmailService + SP_ProcessRenewal (NOTICE_SENT) per record.

### Migration 041 — `finance.TariffRate` (PremiumCalculatorTools.cs)

| Stored Procedure | MCP Tool | Status |
|---|---|---|
| `finance.SP_CalculatePremium` | `CalculatePremium` | COVERED |
| `finance.SP_GetPremiumSummary` | `GetPremiumSummary` | COVERED |
| `finance.SP_GetTariffRates` | `GetTariffRates` | COVERED |
| `finance.SP_UpsertTariffRate` | `UpsertTariffRate` | COVERED |

Full coverage. Wildcard tariff (`coverage_type_code = '*'`) handled by the SP;
MCP passes through correctly.

### Migration 043 — `import.Legacy*` (LegacyImportTools.cs — NEW)

Pre-existing `ImportTools.cs` targets `import.PolicyImport` — a different table
from migration 030 (bulk policy staging). It does NOT cover migration 043 tables.

Gap identified and closed by `LegacyImportTools.cs`:

| Stored Procedure | MCP Tool | Status |
|---|---|---|
| `import.SP_ImportLegacyPersons` | `ImportLegacyPersons` | CLOSED (new) |
| `import.SP_GetImportSummary` | `GetLegacyImportSummary` | CLOSED (new) |
| *(inline error inspection)* | `GetLegacyImportErrors` | CLOSED (new) |

Note: `import.SP_ImportLegacyContract` and `import.SP_ImportLegacyClaim` are
not present in migration 043 — only `SP_ImportLegacyPersons` and
`SP_GetImportSummary` exist. `GetLegacyImportErrors` uses direct SQL against
the 3 staging tables for targeted error inspection without a dedicated SP.

## Tool Registry Audit

33 tool classes under `backend/src/YafesPars.McpServer/Tools/`:

| Class | `[McpServerToolType]` | Notes |
|---|---|---|
| AdminTools | ✅ | |
| AuditQueryTools | ✅ | |
| AuditTools | ✅ | |
| AzureTools | ✅ | |
| ClaimSettlementTools | ✅ | |
| ClaimTools | ✅ | |
| CommissionTools | ✅ | |
| ComplianceTools | ✅ | |
| ComplaintTools | ✅ | |
| DashboardTools | ✅ | |
| DocumentTools | ✅ | |
| EmailTools | ✅ | |
| ExportJobTools | ✅ | |
| FinanceLedgerTools | ✅ | |
| FinanceTools | ✅ | |
| FsmaExportTools | ✅ | |
| ImportTools | ✅ | targets `import.PolicyImport` (migration 030) |
| LegacyImportTools | ✅ | NEW — targets `import.Legacy*` (migration 043) |
| NotificationTools | ✅ | |
| OperationalMonitoringTools | ✅ | |
| OperationsTools | ✅ | |
| PaymentTools | ✅ | |
| PersonTools | ✅ | |
| PersonWriteTools | ✅ | |
| PolicyTools | ✅ | |
| PolicyWriteTools | ✅ | |
| PortfolioTools | ✅ | |
| PremiumCalculatorTools | ✅ | |
| ProductionReadinessTools | ✅ | |
| RenewalTools | ✅ | |
| RiskTools | ✅ | |
| TaskTools | ✅ | |
| TenantManagementTools | ✅ | |

All 33 classes carry `[McpServerToolType]`. DI registration is scanning-based
(no explicit registration list), so adding a new class with the attribute is
sufficient.

## Manifest `ssmsScripts` Contract Fix

`workbench-manifest.json` had `ssmsScripts` as a raw array, inconsistent with
`migrations` and `validations` which are `{ count, latest, files }` objects.

Fixed in this session:
- `ssmsScripts` → `{ "count": 24, "items": [...] }` in the manifest JSON
- `update-ssms-workbench-manifest.ps1` — generator updated to produce `{ count, items }`
- `test-sql-quality-gate.ps1` — consumer updated from `@($manifest.ssmsScripts).Count`
  to `[int]$manifest.ssmsScripts.count`
- `ssms-workbench-validation.yml` — CI updated from `manifest.ssmsScripts.length`
  to `manifest.ssmsScripts.count`

## SQL Agent Security Fixes (`18__sql_agent_job_setup.sql`)

Two bugs found and fixed:

1. **Weak DEV guard** — Was `PRINT 'WARN...'` only; execution continued regardless.
   Fixed to `RAISERROR(..., 16, 1) WITH LOG` + `RETURN` — script aborts if
   `YAFES_SQL_DATABASE` does not contain DEV, TEST, or ACC.

2. **Hard-coded database name in tenant lookup** — JOB 2 referenced
   `YafesPars_Dev.core.Tenant` literally instead of using the SQLCMD variable.
   Fixed to `sp_executesql` with dynamic SQL using `$(YAFES_SQL_DATABASE)`.

## Track A Status (Environment-dependent — unchanged)

| Item | Status | Blocker |
|---|---|---|
| TEST/PROD access-review evidence | EVIDENCE_COLLECTION_PENDING | Needs real DB access |
| TEST/PROD restore drill evidence | PLAN_READY | Needs real DB + 2 signatories |
| SQL Agent DBA approval | SCRIPT_READY | Needs DBA sign-off |
