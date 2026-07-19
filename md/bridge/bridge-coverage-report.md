# Bridge Coverage Report — 2026-07-19

## Summary

| Metric | Value |
|--------|-------|
| Total bridge actions | 17 |
| Domains covered | person, policy, claim (settlement + reserve), risk, tasking, import/export |
| New actions added this session | 6 |
| All actions follow PREVIEW_FIRST pattern | Yes |
| All actions have tenant ownership validation | Yes |

## Action Inventory

| Action | SP | Domain | Since |
|--------|----|--------|-------|
| CREATE_NATURAL_PERSON | person.SP_CreateNaturalPerson | Person | Initial |
| CREATE_LEGAL_PERSON | person.SP_CreateLegalPerson | Person | 2026-07-19 |
| CREATE_POLICY | policy.SP_CreateContract | Policy | Initial |
| CREATE_POLICY_VERSION | policy.SP_CreateContractVersion | Policy | Initial |
| ADD_POLICY_PARTY | policy.SP_AddContractParty | Policy | Initial |
| ADD_POLICY_OBJECT | policy.SP_AddContractObject | Policy | Initial |
| CREATE_VEHICLE_OBJECT | risk.SP_CreateVehicleObject | Risk | Initial |
| CREATE_CLAIM | claim.SP_CreateClaim | Claim | Initial |
| CLOSE_CLAIM | claim.SP_CloseClaim | Claim | Initial |
| UPDATE_CLAIM_RESERVE | claim.SP_UpdateClaimReserve | Claim | 2026-07-19 |
| CREATE_SETTLEMENT | claim.SP_CreateSettlement | Claim/Settlement | 2026-07-19 |
| APPROVE_SETTLEMENT | claim.SP_ApproveSettlement | Claim/Settlement | 2026-07-19 |
| CREATE_TASK | tasking.SP_CreateTask | Tasking | Initial |
| ADD_TASK_COMMENT | tasking.SP_AddTaskComment | Tasking | Initial |
| ADD_TASK_REMINDER | tasking.SP_AddTaskReminder | Tasking | Initial |
| REGISTER_EXPORT_JOB | import.SP_CreateExportJob | Export | 2026-07-19 |
| COMPLETE_EXPORT_JOB | import.SP_CompleteExportJob | Export | 2026-07-19 |

## Coverage Gaps (future candidates)

| Action | SP | Priority | Blocker |
|--------|----|----------|---------|
| UPDATE_NATURAL_PERSON | _(SP needed)_ | P2 | No write SP exists yet |
| CANCEL_CONTRACT | _(SP needed)_ | P2 | No SP exists yet |
| REOPEN_CLAIM | _(SP needed)_ | P3 | No SP exists yet |
| ADD_EXPORT_JOB_FILE | import.SP_? | P3 | SP not yet defined |
| WITHDRAW_SETTLEMENT | _(SP needed)_ | P3 | No SP exists yet |
