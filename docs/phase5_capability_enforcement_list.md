# Phase 5: Capability Enforcement List

## Scope
Service-layer RBAC guards were added on critical mutation entrypoints to align local behavior with Firestore authorization rules.

## Capability Map
| Capability | Service Methods Enforced | Firestore Rule Alignment |
|---|---|---|
| `paymentsCreate` | `PaymentsService.addManualPayment` | `payments` create: `isSalesTeam()` or `Accountant` |
| `paymentLinksCreate` | `PaymentsService.createPaymentLink` | `payment_links` create: `isSalesTeam()` or `Accountant` |
| `paymentLinksUpdate` | `PaymentsService.updatePaymentStatus` | `payment_links` update: `isAdminOrManager()` or `Accountant` |
| `returnsCreate` | `ReturnsService.addReturnRequest` | `returns` create: sales team; admin/manager override |
| `returnsApproveReject` | `ReturnsService.approveReturnRequest`, `ReturnsService.rejectReturnRequest` | `returns` update: `isAdminOrManager()` |
| `productionTargetMutate` | `ProductionService.addProductionTarget`, `ProductionService.deleteProductionTarget` | `production_targets` write: `isAdminOrManager()` |
| `productionLogMutate` | `ProductionService.addDetailedProductionLog`, `ProductionService.saveDailyEntry` | production collections write: `isProductionTeam()` |

## Role Resolution Contract
- Guard resolves actor from Firebase Auth UID first.
- Fallbacks: user doc id by normalized email, then user email field lookup.
- Authorization denies when actor context cannot be resolved locally.
