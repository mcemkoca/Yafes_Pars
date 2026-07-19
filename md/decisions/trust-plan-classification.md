# Decision: Trust-Plan Folder Classification

**Date:** 2026-07-19
**Owner:** Deuterium12{MCK}
**Status:** DECIDED

## Context

The `md/trust-plan/` folder was created during the initial technical-discovery
phase when the team was evaluating whether to migrate from a legacy web-first
architecture to the current SSMS-first approach. It contains sanitized comparison
notes, table-count history, and UX lessons from the old imported package.

## Decision

Keep `md/trust-plan/` as a **read-only legacy reference folder**.

- Do NOT delete: it contains irreplaceable context about table-count evolution
  and the reasoning behind the SSMS-first pivot.
- Do NOT copy: old credentials, docker defaults, CORS examples, or web-first
  architecture must not be introduced into the active product from this folder.
- Do NOT update: the folder is frozen at the state when the legacy plan was
  superseded.

## Active Sources of Truth (supersede trust-plan)

| Concern | Active location |
|---------|----------------|
| Database schema | `database/migrations/` |
| SSMS workbench | `database/ssms/` |
| Project plan | `md/mustafaplan.md` |
| Table reconciliation | `md/database/table-reconciliation-89-vs-108.md` |
| Customer overview | `README.md` |

## Contents Classification

| File/Folder | Classification |
|------------|----------------|
| `trust-plan/README.md` | LEGACY — comparison context |
| `trust-plan/legacy-reference-summary.md` | LEGACY — table-count history |
| `trust-plan/research/` | LEGACY — early design research snapshots |

## Rationale

Deleting legacy notes removes audit trail for architectural decisions. The risk
of someone acting on stale instructions is mitigated by the classification header
already present in `trust-plan/README.md`.
