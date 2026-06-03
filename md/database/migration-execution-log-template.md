# Migration Execution Log Template

Copy this template into the release ticket or execution record for every TEST
or PROD deployment.

## Summary

| Field | Value |
| --- | --- |
| Environment |  |
| SQL Server |  |
| Database |  |
| Release branch/tag |  |
| Commit SHA |  |
| Release owner |  |
| Database operator |  |
| Maintenance window |  |

## Pre-Checks

| Check | Result | Notes |
| --- | --- | --- |
| Static SQL quality gate passed |  |  |
| Target environment confirmed |  |  |
| SSMS safety check passed |  |  |
| Pre-deployment backup created |  |  |
| Backup copied off VM or protected storage |  |  |
| Rollback decision owner confirmed |  |  |

## Scripts Executed

| Order | Script | Start time | Finish time | Result | Notes |
| --- | --- | --- | --- | --- | --- |
| 000 | `database/migrations/000__create_database.sql` |  |  |  |  |
| 001 | `database/migrations/001__create_schemas.sql` |  |  |  |  |
| 002 | `database/migrations/002__create_core_infrastructure.sql` |  |  |  |  |
| 003 | `database/migrations/003__create_person_domain.sql` |  |  |  |  |
| 004 | `database/migrations/004__create_institution_domain.sql` |  |  |  |  |
| 005 | `database/migrations/005__create_object_domain.sql` |  |  |  |  |
| 006 | `database/migrations/006__create_contract_domain.sql` |  |  |  |  |
| 007 | `database/migrations/007__create_coverage_domain.sql` |  |  |  |  |
| 008 | `database/migrations/008__create_claim_domain.sql` |  |  |  |  |
| 009 | `database/migrations/009__create_document_domain.sql` |  |  |  |  |
| 010 | `database/migrations/010__create_task_domain.sql` |  |  |  |  |
| 011 | `database/migrations/011__create_audit_domain.sql` |  |  |  |  |
| 012 | `database/migrations/012__add_constraints.sql` |  |  |  |  |
| 013 | `database/migrations/013__add_indexes.sql` |  |  |  |  |
| 014 | `database/migrations/014__add_triggers.sql` |  |  |  |  |
| 015 | `database/migrations/015__add_views.sql` |  |  |  |  |
| 016 | `database/migrations/016__add_stored_procedures.sql` |  |  |  |  |
| 017 | `database/migrations/017__seed_lookup_data.sql` |  |  |  |  |
| 018 | `database/migrations/018__seed_demo_data.sql` |  |  |  | DEV/TEST only |

## Validation Results

| Validation | Result | Notes |
| --- | --- | --- |
| `001__validate_core_infrastructure.sql` |  |  |
| `002__validate_person_domain.sql` |  |  |
| `003__validate_institution_domain.sql` |  |  |
| `004__validate_risk_domain.sql` |  |  |
| `005__validate_policy_domain.sql` |  |  |
| `006__validate_coverage_domain.sql` |  |  |
| `007__validate_claim_domain.sql` |  |  |
| `008__validate_document_domain.sql` |  |  |
| `009__validate_task_domain.sql` |  |  |
| `010__validate_audit_domain.sql` |  |  |
| `011__validate_constraints_exist.sql` |  |  |
| `012__validate_indexes.sql` |  |  |
| `013__validate_triggers.sql` |  |  |
| `014__validate_views.sql` |  |  |
| `015__validate_stored_procedures.sql` |  |  |
| `016__validate_seed_data.sql` |  |  |
| `017__validate_demo_data.sql` |  | DEV/TEST only |

## Post-Checks

| Check | Result | Notes |
| --- | --- | --- |
| SSMS dashboard opens |  |  |
| Daily operator checklist reviewed |  |  |
| RBAC/audit checks reviewed |  |  |
| Backup job status reviewed |  |  |
| Monitoring window assigned |  |  |

## Decision

| Field | Value |
| --- | --- |
| Release accepted |  |
| Follow-up actions |  |
| Rollback required |  |
| Sign-off |  |
