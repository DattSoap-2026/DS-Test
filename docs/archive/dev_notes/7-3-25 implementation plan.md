# ERP Inventory Stabilization and Implementation Plan

Date: 2026-03-07
Source Audit: `7-3-25 audit.md`
Goal: Convert the current ERP into a stable, deterministic, offline-safe inventory architecture without breaking live dispatch and sales behavior.

## 1. Target Outcome

After this redesign:

- local and server stock must always converge for the same command set
- every stock mutation must flow through one deterministic movement engine
- every mutation must create:
  - local stock update
  - immutable ledger movement
  - durable queue command
- warehouse, department, salesman, and finished-goods balances must reconcile
- reports must be projection-based and reproducible from ledger plus balances

## 2. Core Architecture Decisions

## 2.1 Inventory Invariant

The system should standardize on this invariant:

- `products.stock` means `MAIN_WAREHOUSE_ON_HAND`
- it is not total factory stock
- it is not department stock
- it is not salesman stock

Reason:

- this preserves current dispatch and sales assumptions with minimum breakage
- dispatch already behaves like warehouse-to-salesman transfer
- department issue should also be treated as warehouse-to-department transfer
- total company stock must be derived, not stored in `products.stock`

Derived balances:

- main warehouse stock = `products.stock`
- department stock = `stock_balances` for department locations
- salesman stock = `stock_balances` for salesman locations
- total company stock = sum of all internal locations for product

## 2.2 New Canonical Inventory Model

Introduce canonical inventory entities:

### A. `inventory_locations`

Purpose: master table for every stock-holding location.

Fields:

- `id`
- `type`: `warehouse`, `department`, `salesman_van`, `virtual`
- `name`
- `code`
- `parentLocationId`
- `ownerUserUid` for salesman locations when relevant
- `isActive`
- `isPrimaryMainWarehouse`

Seeded records:

- `warehouse_main`
- all canonical departments
- one salesman location per active salesman

### B. `stock_balances`

Purpose: authoritative per-product per-location on-hand.

Fields:

- `id = {locationId}_{productId}`
- `locationId`
- `productId`
- `quantity`
- `updatedAt`
- `syncStatus`

Constraint:

- unique on `(locationId, productId)`

### C. `stock_movements`

Purpose: immutable ledger lines generated from commands.

Fields:

- `movementId`
- `commandId`
- `movementIndex`
- `productId`
- `sourceLocationId`
- `destinationLocationId`
- `quantityBase`
- `movementType`
- `reasonCode`
- `referenceType`
- `referenceId`
- `actorUid`
- `actorAppUserId`
- `occurredAt`
- `isReversal`

Constraint:

- unique on `movementId`
- unique on `(commandId, movementIndex)`

### D. `inventory_commands`

Purpose: durable command log and queue payload.

Fields:

- `commandId`
- `commandType`
- `payload`
- `actorUid`
- `createdAt`
- `appliedLocally`
- `appliedRemotely`
- `retryMeta`

Rule:

- all inventory-changing flows must enqueue one deterministic command

## 2.3 Compatibility Projections

To avoid breaking current UI immediately, keep legacy tables and fields as projections:

- `products.stock` remains a compatibility mirror of `warehouse_main`
- `departmentStocks` becomes a projection from `stock_balances`
- `users.allocatedStock` becomes a projection from salesman location balances

These projections must never be treated as the canonical write source after migration.

## 2.4 One Movement Engine

Create a single service, for example `InventoryMovementEngine`, that owns all stock mutations.

Responsibilities:

1. validate command payload
2. resolve source and destination locations
3. generate deterministic movement lines
4. apply local transaction
5. write stock balances
6. write stock ledger rows
7. update compatibility projections
8. enqueue durable command

No service should directly mutate `products.stock`, `departmentStocks`, or `users.allocatedStock` outside this engine.

## 3. Required Corrections by Audit Finding

## 3.1 R1 Department Stock Inconsistency

Correction:

- issue and return become the same command family: `internal_transfer`
- transfer between `warehouse_main` and `department:{id}`
- both local and remote use identical movement generation
- return is not a special path; it is the reverse transfer

Implementation:

- replace `transferToDepartment()` with command builder
- replace `returnFromDepartment()` with command builder
- remove special remote-only decrement logic
- server and local both apply the same movement pair:
  - main warehouse `-qty`
  - department location `+qty`

Result:

- local and remote no longer diverge

## 3.2 R2 Sales Bypassing Dispatch

Correction:

- remove stock allocation to salesman from `sales_service`
- salesman can only receive stock through `dispatch_create`

Implementation:

- block `recipientType == salesman` for inventory-moving sales
- keep `customer` and `dealer` sale flows
- if salesman transfer is needed operationally, redirect to dispatch workflow

Result:

- enforced chain becomes:
  - factory -> dispatch -> salesman -> sale

## 3.3 R4 Warehouse as Metadata Only

Correction:

- warehouse must become a real `inventory_location`
- opening stock and future warehouse transfers must hit `stock_balances`

Implementation:

- seed `warehouse_main`
- optionally seed additional warehouse records later
- stop relying on plain `warehouseId` as ledger metadata only

Result:

- warehouse balances become queryable and reconcilable

## 3.4 R5 Opening Stock Duplication

Correction:

- opening stock becomes `set opening balance`, not additive load

Implementation:

- unique key on `(productId, warehouseId, openingWindowId)`
- save computes delta:
  - `delta = targetBalance - currentWarehouseBalance`
- command type: `opening_set_balance`
- UI row locks after save
- row can be edited only through explicit pre-Go-Live "edit opening balance" flow

Result:

- duplicate save cannot inflate stock

## 3.5 R7 Production Using Best-Effort Sync

Correction:

- bhatti, cutting, department transfer, and all production outputs must use durable outbox commands

Implementation:

- command types:
  - `department_issue`
  - `department_return`
  - `bhatti_production_complete`
  - `cutting_production_complete`
  - `opening_set_balance`
  - `dispatch_create`
  - `sale_complete`
- remove direct best-effort `syncToFirebase` writes for stock-mutating flows

Result:

- stock-changing commands become replayable, idempotent, and auditable

## 3.6 R11 Identity Mismatch

Correction:

- standardize on `Firebase UID` as canonical actor and ownership key

Reason:

- auth rules and sync filtering already align more naturally with Firebase UID
- it is stable for permissions

Compatibility:

- keep `legacyAppUserId` on relevant records
- during migration, readers support both old and new keys
- all new writes must include:
  - `actorUid`
  - `legacyAppUserId`

Result:

- permission scope and filtered sync become deterministic

## 4. Department Master Normalization

Introduce `department_master` with fields:

- `departmentId`
- `departmentCode`
- `departmentName`
- `departmentType`
- `sourceWarehouseId`
- `isProductionDepartment`
- `isActive`

Rules:

- no ad hoc department names in UI
- issue and return screens load from the same master
- all stock records reference `departmentId`, not free-text name
- human-readable names become display only

Migration:

1. normalize current department names into canonical IDs
2. remap `departmentStocks`
3. update UI dropdowns to use master table
4. keep alias resolver only during migration, then remove it

## 5. Production Rule Enforcement

Introduce formula master tables:

- `product_formulas`
- `formula_lines`
- `formula_versions`

Each production command must reference a formula version snapshot.

Validation rules:

1. raw material list must match approved formula or approved tolerance override
2. output must stay within yield band
3. unit conversion must be centralized in one unit resolver
4. department location must have enough stock before consumption
5. finished output cannot post if consumption validation fails

Bhatti:

- validate raw input by department location
- validate tank-sourced input through tank stock service before posting
- generate both consume and output movement lines

Cutting:

- replace UI-driven box logic with service-side resolved stock plan
- UI should only display the resolved plan returned by service

Detailed production:

- route stock mutations through movement engine rather than ad hoc product updates

## 6. Stock Ledger Completeness

Rule:

- every stock mutation must create local movement lines and local stock ledger entries before queue submission

Required flow output per command:

1. command record
2. one or more movement rows
3. updated stock balances
4. updated compatibility projections
5. outbox queue item

Special correction:

- customer sales must create local ledger entries for van stock deduction
- sale edits and cancellations must create reversal or adjustment movements

## 7. Dispatch Transaction Safety

Dispatch must become a composite command:

- `dispatch_create`

Command payload should include:

- dispatch header
- item lines
- source location
- destination salesman location
- optional route order linkage

Local apply:

- decrement main warehouse
- increment salesman location
- write movement rows
- write dispatch entity
- mark route order as `dispatch_pending_confirmation`

Remote apply:

- one idempotent transaction writes:
  - dispatch
  - stock movements
  - location balance effects
  - route order completion

If remote route-order update fails:

- command remains pending
- reconciliation worker retries same command
- no separate manual split path

## 8. Durable Queue Convergence Strategy

All stock-mutating modules must converge to one queue structure:

- queue collection: existing durable outbox
- queue payload: inventory command envelope
- idempotency key: deterministic from command type plus business identity

Queue design rules:

- one queue item per command
- no direct remote mutation outside queue for stock-changing flows
- retry-safe
- replay-safe
- compensation only for commands that cannot remain pending

Recommended command key patterns:

- opening: `opening:{warehouseId}:{productId}:{openingWindowId}`
- department transfer: `transfer:{fromLocation}:{toLocation}:{referenceId}:{productId}`
- bhatti: `bhatti:{batchId}`
- cutting: `cutting:{batchId}`
- dispatch: `dispatch:{dispatchId}`
- sale: `sale:{saleId}`

## 9. Implementation Phases

## Phase 0 - Stabilization Guardrails

Goal:

- freeze semantics before refactor

Tasks:

- add feature flag for new inventory engine
- add reconciliation diagnostics
- add command-level audit logging
- add migration-safe compatibility readers

## Phase 1 - Canonical Masters and Identity

Tasks:

- create `department_master`
- create `inventory_locations`
- standardize canonical actor to Firebase UID
- add `legacyAppUserId` compatibility fields

Deliverable:

- master data layer stable without changing business operations yet

## Phase 2 - Canonical Balances and Projections

Tasks:

- create `stock_balances`
- build projection updater for:
  - `products.stock`
  - `departmentStocks`
  - `users.allocatedStock`
- backfill balances from current local and remote data

Deliverable:

- authoritative location balances exist

## Phase 3 - Movement Engine

Tasks:

- implement `InventoryMovementEngine`
- implement deterministic movement generator
- implement local transaction applier
- implement queue envelope for commands

Deliverable:

- one write path for all future inventory changes

## Phase 4 - Flow Migration

Tasks:

- migrate opening stock
- migrate department issue and return
- migrate bhatti production
- migrate cutting production
- migrate detailed production logs
- migrate dispatch to use movement engine
- migrate sales to consume van stock through movement engine
- block direct salesman allocation in sales

Deliverable:

- all stock-changing flows use the same command infrastructure

## Phase 5 - Remote Processor Unification

Tasks:

- create one remote command applier per command type
- move old ad hoc `performSync()` stock mutations behind command processor
- make route-order update part of dispatch remote apply

Deliverable:

- local and remote processing logic use the same command semantics

## Phase 6 - Validation and Cleanup

Tasks:

- run full lifecycle simulation
- compare local balances vs remote balances
- compare projections vs canonical balances
- remove obsolete alias logic and direct stock mutation paths

Deliverable:

- inventory architecture stabilized and simplified

## 10. Migration Strategy

Migration must be non-destructive and compatibility-first.

### 10.1 User Identity Migration

1. add `canonicalUid` to local user profile if missing
2. add compatibility reader support for old IDs
3. backfill remote docs where possible
4. switch all new writes to canonical UID
5. after data convergence, remove dual-write dependence

### 10.2 Department Migration

1. build alias map from existing department names
2. create canonical `department_master`
3. remap existing department stock docs to canonical IDs
4. keep read alias compatibility temporarily
5. cut UI to master-driven IDs only

### 10.3 Stock Balance Migration

1. backfill `warehouse_main` balances from `products.stock`
2. backfill department balances from `departmentStocks`
3. backfill salesman balances from `users.allocatedStock`
4. run reconciliation report:
   - compare legacy values against derived balances
5. if mismatch exists, freeze writes and correct before enabling new engine

## 11. Module-Level Implementation Map

Primary modules to refactor:

- `lib/services/inventory_service.dart`
- `lib/services/opening_stock_service.dart`
- `lib/services/sales_service.dart`
- `lib/services/production_service.dart`
- `lib/services/cutting_batch_service.dart`
- `lib/services/bhatti_service.dart`
- `lib/services/delegates/sync_queue_processor_delegate.dart`
- `lib/services/delegates/inventory_sync_delegate.dart`
- `lib/services/delegates/sales_sync_delegate.dart`
- `lib/screens/inventory/material_issue_screen.dart`
- `lib/screens/inventory/material_return_screen.dart`
- `lib/screens/inventory/opening_stock_setup_screen.dart`
- `lib/screens/dispatch/dispatch_screen.dart`
- `lib/screens/production/cutting_batch_entry_screen.dart`

New modules recommended:

- `lib/services/inventory_movement_engine.dart`
- `lib/services/inventory_projection_service.dart`
- `lib/services/department_master_service.dart`
- `lib/services/reconciliation_service.dart`
- `lib/data/local/entities/inventory_location_entity.dart`
- `lib/data/local/entities/stock_balance_entity.dart`
- `lib/data/local/entities/inventory_command_entity.dart`
- `lib/data/local/entities/department_master_entity.dart`

## 12. Validation Plan

Run one full deterministic lifecycle simulation:

1. Opening Stock
2. Department Issue
3. Bhatti Production
4. Cutting Production
5. Finished Goods Inventory
6. Dispatch
7. Salesman Inventory
8. Customer Sale
9. Sale Cancellation
10. Department Return

For each step verify:

- command created once
- local movement rows created once
- local balances updated correctly
- projections updated correctly
- queue item created once
- remote apply idempotent
- second replay produces zero duplicate stock effect

Offline validation:

- perform step locally without network
- restart app
- sync later
- verify same balances and same movement count

Cross-device validation:

- device A creates command offline
- server sync applies later
- device B pulls changes
- product, department, salesman, and report balances must match

## 13. Acceptance Criteria

The redesign is complete only when all conditions hold:

- no stock-changing flow mutates inventory outside movement engine
- all production flows use durable queue
- direct salesman allocation from sales is impossible
- opening stock duplicate save cannot inflate stock
- department queries use canonical department IDs
- all filtered sync uses canonical actor UID
- ledger entries exist for every stock mutation
- `products.stock` reconciles exactly to `warehouse_main`
- derived reports reconcile to canonical balances
- replaying the same command produces zero extra stock movement

## 14. Recommended Execution Order

Implement in this exact order:

1. canonical identity
2. department master
3. inventory locations and stock balances
4. movement engine
5. opening stock conversion
6. department transfer migration
7. production migration
8. dispatch composite command
9. sales restriction and van ledger completion
10. reconciliation tooling
11. lifecycle simulation

## 15. Immediate Next Build Scope

The safest first implementation slice is:

1. choose `products.stock = main warehouse on hand`
2. add `department_master`
3. add `inventory_locations`
4. add `stock_balances`
5. migrate opening stock to set-balance
6. migrate department issue and return to movement engine
7. standardize actor UID

This first slice removes the largest divergence risks before touching deeper production flows.

