# Bridge Department Use-Case Matrix

Maps operational department needs to bridge actions.

## Claims Department

| Use Case | Bridge Action | Status |
|----------|--------------|--------|
| Open a new claim | CREATE_CLAIM | AVAILABLE |
| Close a resolved claim | CLOSE_CLAIM | AVAILABLE |
| Adjust reserve amount | UPDATE_CLAIM_RESERVE | AVAILABLE |
| Create settlement offer | CREATE_SETTLEMENT | AVAILABLE |
| Approve settlement | APPROVE_SETTLEMENT | AVAILABLE |
| Reopen a closed claim | REOPEN_CLAIM | FUTURE |
| Withdraw a settlement | WITHDRAW_SETTLEMENT | FUTURE |

## Policy / Underwriting Department

| Use Case | Bridge Action | Status |
|----------|--------------|--------|
| Register a new natural person | CREATE_NATURAL_PERSON | AVAILABLE |
| Register a company/organisation | CREATE_LEGAL_PERSON | AVAILABLE |
| Create a policy contract | CREATE_POLICY | AVAILABLE |
| Add a policy version | CREATE_POLICY_VERSION | AVAILABLE |
| Link policyholder to contract | ADD_POLICY_PARTY | AVAILABLE |
| Register a vehicle | CREATE_VEHICLE_OBJECT | AVAILABLE |
| Link vehicle to policy | ADD_POLICY_OBJECT | AVAILABLE |
| Cancel an active contract | CANCEL_CONTRACT | FUTURE |
| Update person contact details | UPDATE_NATURAL_PERSON | FUTURE |

## Operations / Tasking

| Use Case | Bridge Action | Status |
|----------|--------------|--------|
| Create a follow-up task | CREATE_TASK | AVAILABLE |
| Add comment to a task | ADD_TASK_COMMENT | AVAILABLE |
| Add reminder to a task | ADD_TASK_REMINDER | AVAILABLE |

## Import / Export (DBA / Reporting)

| Use Case | Bridge Action | Status |
|----------|--------------|--------|
| Register a bulk export run | REGISTER_EXPORT_JOB | AVAILABLE |
| Mark export as complete | COMPLETE_EXPORT_JOB | AVAILABLE |
| Attach file to export job | ADD_EXPORT_JOB_FILE | FUTURE |
