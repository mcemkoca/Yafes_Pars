# Dev database migration execution report

- Target server name: NOT VERIFIED
- Target database name: NOT VERIFIED
- Machine name: NOT VERIFIED
- Execution timestamp: 20260602_124216
- Backup path: NOT CREATED
- SSMS fallback script: C:\Users\spqr_\Desktop\Yafes\Yafes_Pars\database\execution-logs\20260602_124216\ssms-dev-migrations.sql

## Migrations
- 000__create_database.sql: NOT RUN
- 001__create_schemas.sql: NOT RUN
- 002__create_core_infrastructure.sql: NOT RUN
- 003__create_person_domain.sql: NOT RUN
- 004__create_institution_domain.sql: NOT RUN
- 005__create_object_domain.sql: NOT RUN
- 006__create_contract_domain.sql: NOT RUN
- 007__create_coverage_domain.sql: NOT RUN
- 008__create_claim_domain.sql: NOT RUN
- 009__create_document_domain.sql: NOT RUN
- 010__create_task_domain.sql: NOT RUN
- 011__create_audit_domain.sql: NOT RUN
- 012__add_constraints.sql: NOT RUN
- 013__add_indexes.sql: NOT RUN
- 014__add_triggers.sql: NOT RUN
- 015__add_views.sql: NOT RUN
- 016__add_stored_procedures.sql: NOT RUN
- 017__seed_lookup_data.sql: NOT RUN
- 018__seed_demo_data.sql: NOT RUN

## Validations
- 001__validate_core_infrastructure.sql: NOT RUN
- 002__validate_person_domain.sql: NOT RUN
- 003__validate_institution_domain.sql: NOT RUN
- 004__validate_risk_domain.sql: NOT RUN
- 005__validate_policy_domain.sql: NOT RUN
- 006__validate_coverage_domain.sql: NOT RUN
- 007__validate_claim_domain.sql: NOT RUN
- 008__validate_document_domain.sql: NOT RUN
- 009__validate_task_domain.sql: NOT RUN
- 010__validate_audit_domain.sql: NOT RUN
- 011__validate_constraints_exist.sql: NOT RUN
- 012__validate_indexes.sql: NOT RUN
- 013__validate_triggers.sql: NOT RUN
- 014__validate_views.sql: NOT RUN
- 015__validate_stored_procedures.sql: NOT RUN
- 016__validate_seed_data.sql: NOT RUN
- 017__validate_demo_data.sql: NOT RUN

## Warnings
- sqlcmd is not available in this environment.
- SSMS fallback script generated: C:\Users\spqr_\Desktop\Yafes\Yafes_Pars\database\execution-logs\20260602_124216\ssms-dev-migrations.sql

## Errors
- Missing required connection variables: YAFES_SQL_SERVER, YAFES_SQL_DATABASE, YAFES_SQL_USER, YAFES_SQL_PASSWORD

- Final result: FAILED
- Next recommended action: Use the generated SSMS fallback script or install sqlcmd, set DEV connection variables, then rerun.
