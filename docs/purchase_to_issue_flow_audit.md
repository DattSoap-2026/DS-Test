# Purchase to Issue Flow Audit (Department, Tank, Godown, Unit Team)

Date: 2026-02-26
Project: DattSoap Flutter App

## 1) Scope

This audit documents the current flow from Purchase Order receipt up to material issue/distribution into:
- Main warehouse stock
- Tank/Godown storage units
- Department stock
- Unit/team scoped views (Sona/Gita)

Code references in this document point to current implementation files.

## 2) End-to-End Flow (As Implemented)

### Step 1: Purchase Receipt (PO -> Warehouse)

1. PO receive action validates incoming item quantities and prevents over-receipt.
2. If PO item has `baseUnit` + `conversionFactor`, quantity is converted into base quantity before inventory posting.
3. Inventory GRN bulk posting is triggered with base quantities.
4. PO status moves to:
- `received` when all items fully received
- `partiallyReceived` when at least one item is received but PO is not complete

References:
- `lib/services/purchase_order_service.dart:245`
- `lib/services/purchase_order_service.dart:376`
- `lib/services/purchase_order_service.dart:414`
- `lib/services/purchase_order_service.dart:444`

### Step 2: Inventory GRN Posting (Warehouse stock + cost + ledger)

1. GRN runs inside local Isar transaction.
2. Product stock increases.
3. Weighted average cost and last cost update.
4. Stock ledger GRN entry is created.

References:
- `lib/services/inventory_service.dart:2363`
- `lib/services/inventory_service.dart:2412`
- `lib/services/inventory_service.dart:2430`

### Step 3: Post-Receipt Distribution Prompt

After receiving stock from PO or GRN screen, user is prompted to distribute now:
- To Tanks/Godowns (storage transfer)
- To Departments (issue)

References:
- `lib/screens/purchase_orders/purchase_order_details_screen.dart:405`
- `lib/screens/purchase_orders/purchase_order_details_screen.dart:519`
- `lib/screens/procurement/goods_receipt_screen.dart:142`
- `lib/screens/procurement/goods_receipt_screen.dart:292`

### Step 4: Distribution Dialog Logic

1. User can allocate received quantity per product to storage units and/or departments.
2. Validation ensures:
- Valid product + storage/department selection
- No over-allocation vs received quantity
- No over-capacity vs tank/godown free capacity
- Storage material mapping must match product
3. Submit executes:
- `tankService.transferToTank(...)` for storage rows
- `inventoryService.transferToDepartment(...)` for department rows
4. Auto allocate mode fills compatible storage by remaining capacity.

References:
- `lib/screens/inventory/dialogs/post_grn_distribution_dialog.dart:206`
- `lib/screens/inventory/dialogs/post_grn_distribution_dialog.dart:319`
- `lib/screens/inventory/dialogs/post_grn_distribution_dialog.dart:406`
- `lib/screens/inventory/dialogs/post_grn_distribution_dialog.dart:430`
- `lib/screens/inventory/dialogs/post_grn_distribution_dialog.dart:464`

### Step 5: Department Issue (Manual)

Manual issue screen also sends warehouse stock to department through same inventory transfer service.

References:
- `lib/screens/inventory/material_issue_screen.dart:59`
- `lib/screens/inventory/material_issue_screen.dart:166`
- `lib/services/inventory_service.dart:1633`

## 3) Tank/Godown and Unit-Team Behavior

### Storage model

Tank model supports:
- `department`
- `assignedUnit` (team/unit tag)
- `type` (`tank` or `godown`)

References:
- `lib/services/tank_service.dart:33`
- `lib/services/tank_service.dart:34`
- `lib/services/tank_service.dart:35`

### UI filtering

Tanks screen filters by selected unit (`all`, `sona`, `gita`) using department/assigned unit matching.

References:
- `lib/screens/inventory/tanks_list_screen.dart:127`
- `lib/screens/inventory/tanks_list_screen.dart:134`

Bhatti screen also filters assigned tanks by selected department/unit keywords.

References:
- `lib/screens/bhatti/bhatti_cooking_screen.dart:698`

### Unit scope utility

Generic user unit scope normalization/matching is available in utility layer.

References:
- `lib/utils/unit_scope_utils.dart:48`
- `lib/utils/unit_scope_utils.dart:103`

## 4) Sync and Audit Trail Coverage

### Department issue sync path

`transferToDepartment`:
- updates local product stock + department stock
- writes stock ledger entry
- queues outbox event (`department_stocks`, `issue_to_department`)
- sync delegate routes this collection to inventory sync handler

References:
- `lib/services/inventory_service.dart:1633`
- `lib/services/inventory_service.dart:1690`
- `lib/services/inventory_service.dart:1724`
- `lib/services/delegates/sync_queue_processor_delegate.dart:293`

### Tank transfer path

`transferToTank` writes directly to Firestore transaction/batch and creates tank transfer, lot, transaction records.

References:
- `lib/services/tank_service.dart:1170`
- `lib/services/tank_service.dart:1232`
- `lib/services/tank_service.dart:1352`

## 5) Audit Findings

### Critical

1. `assignedUnit` is not persisted in local tank entity/service writes.
- `TankEntity` schema/domain mapping has no `assignedUnit` field.
- Tank create/update local entity write path also does not write `assignedUnit`.
- Impact: unit/team filtering can break in local/offline reads; Sona/Gita scoped visibility becomes inconsistent.

References:
- `lib/data/local/entities/tank_entity.dart:21`
- `lib/data/local/entities/tank_entity.dart:32`
- `lib/services/tank_service.dart:286`
- `lib/services/tank_service.dart:327`

2. Tank transfer/fill/consume paths are Firestore-direct, not local-first outbox based.
- If firestore handle is unavailable (`db == null`), operation returns false.
- Local stock and local analytics can drift until refresh/sync cycle.
- This conflicts with strict offline-first expectation.

References:
- `lib/services/tank_service.dart:894`
- `lib/services/tank_service.dart:1052`
- `lib/services/tank_service.dart:1185`

### High

3. Distribution dialog department list is static default, not settings-driven.
- New/custom departments may not appear for immediate GRN distribution.

Reference:
- `lib/screens/inventory/dialogs/post_grn_distribution_dialog.dart:39`

4. GRN screen sets PO mode with a hardcoded true condition.
- `_isPOBased = widget.poId != null || true;`
- This is logically always true and can hide PO vs direct GRN branch issues.

Reference:
- `lib/screens/procurement/goods_receipt_screen.dart:44`

## 6) Recommended Target Flow (Purchase -> Issue)

1. Receive PO in base units and post GRN locally.
2. Prompt distribution immediately with dynamic departments and storage filtered by material mapping.
3. For storage movement, use local transaction + outbox queue (same pattern as department issue).
4. Preserve `assignedUnit` end-to-end in entity schema and create/update APIs.
5. Keep all movement types ledger-backed for reconciliation:
- GRN
- Warehouse -> Tank/Godown
- Warehouse -> Department
- Tank/Godown -> Consumption

## 7) Practical Example (100 Ton Oil)

1. PO received: 100 Ton oil added to main product stock via GRN.
2. Distribution split example:
- 40 Ton -> Oil Tank G03 (unit/team mapped)
- 30 Ton -> Oil Tank G02 / Godown (if mapped and capacity available)
- 20 Ton -> Sona Bhatti department issue
- 10 Ton -> Gita Bhatti department issue
3. Every leg must produce auditable movement records and be sync-safe.

## 8) Immediate Action Checklist

1. Add `assignedUnit` in `TankEntity` + generated schema + mapping methods.
2. Patch `TankService.createTank/updateTank` to persist `assignedUnit`.
3. Refactor tank transfer/fill/consume to local-first + outbox sync strategy.
4. Replace static department list in distribution dialog with settings/departments source.
5. Remove hardcoded `|| true` in GRN PO mode flag and retest direct GRN.
6. Run role-based smoke test for Sona/Gita/Bhatti Supervisor visibility after backfill.
