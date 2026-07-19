# Bridge Kapsam Raporu — 2026-07-19

## Özet

| Ölçüm | Değer |
|--------|-------|
| Toplam bridge aksiyonu | 17 |
| Kapsanan domain'ler | person, policy, claim (uzlaşma + rezerv), risk, tasking, import/export |
| Bu oturumda eklenen yeni aksiyonlar | 6 |
| Tüm aksiyonlar PREVIEW_FIRST kalıbını izliyor | Evet |
| Tüm aksiyonlarda tenant sahipliği doğrulaması var | Evet |

## Aksiyon Envanteri

| Aksiyon | SP | Domain | İlk Ekleme |
|--------|----|--------|-------|
| CREATE_NATURAL_PERSON | person.SP_CreateNaturalPerson | Person | Başlangıç |
| CREATE_LEGAL_PERSON | person.SP_CreateLegalPerson | Person | 2026-07-19 |
| CREATE_POLICY | policy.SP_CreateContract | Policy | Başlangıç |
| CREATE_POLICY_VERSION | policy.SP_CreateContractVersion | Policy | Başlangıç |
| ADD_POLICY_PARTY | policy.SP_AddContractParty | Policy | Başlangıç |
| ADD_POLICY_OBJECT | policy.SP_AddContractObject | Policy | Başlangıç |
| CREATE_VEHICLE_OBJECT | risk.SP_CreateVehicleObject | Risk | Başlangıç |
| CREATE_CLAIM | claim.SP_CreateClaim | Claim | Başlangıç |
| CLOSE_CLAIM | claim.SP_CloseClaim | Claim | Başlangıç |
| UPDATE_CLAIM_RESERVE | claim.SP_UpdateClaimReserve | Claim | 2026-07-19 |
| CREATE_SETTLEMENT | claim.SP_CreateSettlement | Claim/Settlement | 2026-07-19 |
| APPROVE_SETTLEMENT | claim.SP_ApproveSettlement | Claim/Settlement | 2026-07-19 |
| CREATE_TASK | tasking.SP_CreateTask | Tasking | Başlangıç |
| ADD_TASK_COMMENT | tasking.SP_AddTaskComment | Tasking | Başlangıç |
| ADD_TASK_REMINDER | tasking.SP_AddTaskReminder | Tasking | Başlangıç |
| REGISTER_EXPORT_JOB | import.SP_CreateExportJob | Export | 2026-07-19 |
| COMPLETE_EXPORT_JOB | import.SP_CompleteExportJob | Export | 2026-07-19 |

## Kapsam Boşlukları (Gelecek Adaylar)

| Aksiyon | SP | Öncelik | Engel |
|--------|----|----------|---------|
| UPDATE_NATURAL_PERSON | _(SP gerekli)_ | P2 | Henüz yazma SP'si yok |
| CANCEL_CONTRACT | _(SP gerekli)_ | P2 | Henüz SP yok |
| REOPEN_CLAIM | _(SP gerekli)_ | P3 | Henüz SP yok |
| ADD_EXPORT_JOB_FILE | import.SP_? | P3 | SP henüz tanımlanmadı |
| WITHDRAW_SETTLEMENT | _(SP gerekli)_ | P3 | Henüz SP yok |
