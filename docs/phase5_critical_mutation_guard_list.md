# Phase 5: Critical Mutation Guard List

## Guarded Mutation Points
| Priority | Module | Method | Guard |
|---|---|---|---|
| Critical | Payments | `addManualPayment` | `paymentsCreate` |
| Critical | Payments | `createPaymentLink` | `paymentLinksCreate` |
| Critical | Payments | `updatePaymentStatus` | `paymentLinksUpdate` |
| Critical | Returns | `addReturnRequest` | `returnsCreate` + actor/salesman ownership check for non-admin/manager |
| Critical | Returns | `approveReturnRequest` | `returnsApproveReject` |
| Critical | Returns | `rejectReturnRequest` | `returnsApproveReject` |
| Critical | Production | `addDetailedProductionLog` | `productionLogMutate` |
| Critical | Production | `saveDailyEntry` | `productionLogMutate` |
| High | Production | `addProductionTarget` | `productionTargetMutate` |
| High | Production | `deleteProductionTarget` | `productionTargetMutate` |

## Notes
- Sync replay/queue internals are unchanged.
- Stock and accounting invariants are untouched.
- Guards are applied at service entrypoint before local mutation writes.
