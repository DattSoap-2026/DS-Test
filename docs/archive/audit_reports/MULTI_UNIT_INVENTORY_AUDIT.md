# 📦 Multi-Unit Inventory Audit & Gap Analysis
## DattSoap ERP — Box + Bottle Sales Model

**Document Type:** Technical Audit Report  
**Audit Date:** 2026-02-21  
**Business Rule:** 1 Box = 12 Bottles  
**Constraint:** Offline-First, Local-First, No destructive DB changes  

---

## 📋 EXECUTIVE SUMMARY

The current DattSoap ERP **already has structural fields** for multi-unit support (`baseUnit`, `secondaryUnit`, `conversionFactor`, `secondaryPrice`) in the `Product` model, `ProductEntity`, `SaleItem`, `CartItem`, `AllocatedStockItem`, and dispatch item flows.

**However, critical gaps exist:**
- ✅ Fields exist in the schema
- ❌ **Stock is stored and compared as raw integers without any unit context**
- ❌ **Sale quantities are entered in ambiguous "units" — no Box vs Bottle selector in UI**
- ❌ **Dispatch quantities have no conversion — a "quantity: 10" could mean 10 boxes OR 10 bottles**  
- ❌ **Returns use float quantity with no unit tag — silent mix-up possible**
- ❌ **Reports total "units" without specifying base vs secondary unit**
- ❌ **No centralized unit conversion helper — factories duplicate math inline**
- ⚠️ `conversionFactor` defaults to `1.0` everywhere — meaning bottle/box conversion is silently disabled

---

## 🔍 PHASE 1 — CURRENT SYSTEM FLOW SUMMARY

### 1.1 Product Master Data
**File:** `lib/data/local/entities/product_entity.dart`  
**File:** `lib/models/types/product_types.dart`  
**File:** `lib/services/products_service.dart`

| Field | Status | Notes |
|-------|--------|-------|
| `baseUnit` | ✅ Exists | Required, e.g. "Bottle" |
| `secondaryUnit` | ✅ Exists | Optional, e.g. "Box" |
| `conversionFactor` | ✅ Exists | Defaults to **1.0** |
| `price` (base unit price) | ✅ Exists | e.g., price per Bottle |
| `secondaryPrice` | ✅ Exists | Optional, e.g., price per Box |
| `stock` | ⚠️ Exists | **No unit label — is this Bottles or Boxes?** |
| `bottlesPerBox` explicit field | ❌ MISSING | No dedicated field with clear name |

**Current Behavior:**  
Product creation accepts `baseUnit`, `secondaryUnit`, `conversionFactor`, and both prices. However:
- No **validation** ensuring `conversionFactor > 1` when a secondary unit exists
- `stock` is stored as a raw `double` with no label — unit is implicit from `baseUnit`
- `conversionFactor` defaults to `1.0` globally, which means all existing products treat 1 Box = 1 Bottle

---

### 1.2 Dispatch Module
**File:** `lib/services/inventory_service.dart` (performSync dispatch section, line 596+)  
**File:** `lib/models/inventory/stock_dispatch.dart`  
**File:** `lib/data/local/entities/dispatch_entity.dart`

```dart
// DispatchItem model:
class DispatchItem {
  final int quantity;       // ❌ No unit field indicating Box or Bottle
  final String unit;        // ✅ unit string exists but is set from baseUnit/secondaryUnit inconsistently
  ...
}
```

**Current Behavior:**
- The dispatch deducts from warehouse `product.stock` using raw `quantity`
- In Firestore sync: `FieldValue.increment(item.quantity)` is applied directly
- The `unit` field in `DispatchItem` is populated from `baseUnit ?? secondaryUnit ?? ''`
- **There is NO conversion applied.** If admin dispatches "10 Boxes", the system deducts `10` from `product.stock`, not `10 × 12 = 120` bottles.

---

### 1.3 Salesman Allocated Stock
**File:** `lib/services/inventory_service.dart` (getSalesmanCurrentStock, receiveDispatch)  
**File:** `lib/models/types/user_types.dart` — `AllocatedStockItem`

```dart
class AllocatedStockItem {
  final double quantity;       // ❌ Unit assumed = baseUnit
  final double? freeQuantity;  // ❌ Same unit assumption
  final String baseUnit;
  final String? secondaryUnit;
  final double conversionFactor;
  ...
}
```

**Current Behavior:**  
- Allocated stock is stored as a flat `quantity` in whatever unit was dispatched
- The `calculateStockUsage()` function reads `allocatedStock[productId].quantity` as the total allocated, and deducts `saleItem.quantity` from it
- There is no conversion step — if dispatch sends "quantity: 5 [Box]", and sale deducts "quantity: 60 [Bottles]", the remaining would show -55 (negative)

---

### 1.4 Salesman Sale (new_sale_screen.dart)
**File:** `lib/screens/sales/new_sale_screen.dart`  
**File:** `lib/models/types/sales_types.dart` — `SaleItem`, `CartItem`

```dart
// The subtotal calculation DOES handle boxes:
double get _subtotal {
  for (var item in _cart) {
    if (item.secondaryPrice != null && item.secondaryPrice! > 0 &&
        item.conversionFactor != null && item.conversionFactor! > 0 &&
        item.quantity >= item.conversionFactor!) {
      final secondaryUnits = (item.quantity / item.conversionFactor!).floor();
      final baseUnits = (item.quantity % item.conversionFactor!).toInt();
      total += (secondaryUnits * item.secondaryPrice!) + (baseUnits * item.price);
    } else {
      total += item.price * item.quantity;
    }
  }
}
```

**Findings:**
- ✅ **Price calculation already accounts for box-vs-bottle pricing**
- ❌ **BUT `item.quantity` is always entered in base units (Bottles)** — the UI has no selector
- ❌ **The quantity entered in the cart is directly deducted from allocated stock** without checking if the unit matches
- ❌ **`SaleItem.quantity` is `int` — no unit field except `baseUnit` and `secondaryUnit` labels**
- The `CartItem` stores `conversionFactor` but the user **cannot select "I want to sell 2 Boxes"** — they must enter `24` manually

---

### 1.5 Salesman Return
**File:** `lib/screens/returns/salesman_returns_screen.dart`  
**File:** `lib/data/local/entities/return_entity.dart`

```dart
// ReturnItemEntity:
late double quantity;   // ❌ Is this bottles or boxes?
late String unit;       // ✅ unit label exists
```

**Current Behavior:**
- `_submitBulkReturn()` creates a `ReturnItem` using `item.availableToday` as the quantity with `item.baseUnit` as the unit
- This is correct IF `availableToday` is in base units — but it depends on what was dispatched and how it was tracked

---

### 1.6 My Stock Screen
**File:** `lib/screens/inventory/my_stock_screen.dart`

```dart
// The display only shows raw numbers with base unit:
_formatQty(item.totalAllocated, item.baseUnit)  // e.g., "120 Bottle"
_formatQty(item.totalSold, item.baseUnit)        // e.g., "24 Bottle"
_formatQty(item.availableToday, item.baseUnit)   // e.g., "96 Bottle"
```

**Findings:**
- ✅ Displays in base unit consistently
- ❌ No "Box view" — salesman cannot see stock expressed as boxes (e.g., "8 Boxes + 0 Bottles")
- ❌ KPI cards show totals as raw integers — e.g., "96" without context of what unit

---

### 1.7 Inventory Service — Stock Calculation
**File:** `lib/services/inventory_service.dart` — `calculateStockUsage()`

```dart
// StockUsageData holds:
final String baseUnit;
final String? secondaryUnit;
final double conversionFactor;
```

**Findings:**
- ✅ `StockUsageData` carries unit metadata
- ❌ The calculation internally does NOT use `conversionFactor` to reconcile units
- ❌ Total deduction is `totalSold += saleItem.quantity` regardless of whether the sale was in boxes or bottles

---

## 🚨 PHASE 2 — GAP IDENTIFICATION TABLE

| # | Module | Gap Description | Severity |
|---|--------|----------------|----------|
| G-01 | Product Master | `conversionFactor` defaults to `1.0` even when secondary unit exists — silently disables box logic | 🔴 CRITICAL |
| G-02 | Product Master | No UI validation ensuring factor > 1 when secondary unit is set | 🟠 HIGH |
| G-03 | Product Master | `stock` field has no unit label in Isar — callers assume it's in `baseUnit` but no enforcement | 🔴 CRITICAL |
| G-04 | Dispatch | `DispatchItem.quantity` is dispatched in raw units without noting Box or Bottle | 🔴 CRITICAL |
| G-05 | Dispatch | No conversion: dispatching "10 Boxes" deducts 10 from stock, not 120 bottles | 🔴 CRITICAL |
| G-06 | Dispatch | `unit` field in `DispatchItem` comes from `baseUnit ?? secondaryUnit` — inconsistently assigned | 🟠 HIGH |
| G-07 | Dispatch | Allocated stock (`allocatedStock[id].quantity`) doesn't know if it received boxes or bottles | 🔴 CRITICAL |
| G-08 | Sale Screen | No Box/Bottle toggle in the UI — user cannot say "sell 2 boxes" | 🟠 HIGH |
| G-09 | Sale Screen | `SaleItem.quantity` integer does not track selling unit (box vs bottle) | 🟠 HIGH |
| G-10 | Sale/Stock | Stock deduction in `calculateStockUsage()` uses raw quantity without unit normalization | 🔴 CRITICAL |
| G-11 | Returns | `ReturnItemEntity.quantity` has no unit tag — return qty could mix box/bottle context | 🟠 HIGH |
| G-12 | Returns | Return approval adds `quantity` back to salesman stock without checking units | 🟠 HIGH |
| G-13 | My Stock | Displays in base units only — cannot show "You have 8 Boxes + 0 Bottles" | 🟡 MEDIUM |
| G-14 | Reports | All quantity totals are raw numbers — report header says "unit" but doesn't clarify base vs box | 🟡 MEDIUM |
| G-15 | Inventory | `StockUsageData.conversionFactor` present but unused in calculation | 🟠 HIGH |
| G-16 | Price Calc | `_subtotal` in `new_sale_screen.dart` correctly handles box pricing but depends on correct `conversionFactor` | 🟡 MEDIUM |
| G-17 | Master Data | No validation that `conversionFactor` is consistent across edit sessions | 🟡 MEDIUM |
| G-18 | Sync | Firestore stores `quantity` in allocatedStock without unit tag — sync can corrupt unit mix | 🔴 CRITICAL |

---

## ⚠️ PHASE 3 — RISK ANALYSIS

### 🔴 Risk Level: CRITICAL

#### R-01: Silent Stock Unit Mismatch (Dispatch vs Sale)
**Scenario:** Admin dispatches "10 Boxes" (quantity=10, unit="Box").  
Salesman allocated stock shows `quantity: 10`.  
Salesman sells "5 Bottles" (quantity=5).  
System deducts 5 from 10 → remaining = 5.  
**But in reality:** 10 Boxes = 120 Bottles. Salesman still has 115 Bottles.  
**Impact:** Stock appears depleted when it isn't. Or vice versa.

#### R-02: Negative Stock on Return
**Scenario:** If dispatch was in boxes and sale was counted in bottles, the return quantity (in bottles) added back to allocated stock could exceed what was originally dispatched.  
**Impact:** Allocated stock goes above original dispatch — violates "never-negative" rule.

#### R-03: Financial Error in Price Calculation
**Scenario:** Price calc assumes `item.quantity >= item.conversionFactor` to switch to box pricing.  
If `conversionFactor = 1.0` (default), box pricing NEVER kicks in.  
Salesman entering "12" (12 Bottles) is billed at bottle price × 12 instead of box price × 1.  
**Impact:** Revenue leakage or overcharge.

#### R-04: Firestore Sync Corruption
**Scenario:** `FieldValue.increment(item.quantity)` in Firestore dispatch sync doesn't know the unit. If two devices dispatch the same product in different units, the incremented value represents mixed units.  
**Impact:** Uncorrectable after sync — data integrity destroyed.

---

### 🟠 Risk Level: HIGH

#### R-05: Reports Show Meaningless Totals
All reports aggregate by `quantity` across base and secondary units mixed together.  
A "Total Dispatched: 150 units" report could mean 100 Bottles + 50 Boxes = 700 Bottles effective — completely wrong.

#### R-06: Offline-First Adds Risk
Because all writes happen locally first, a mismatch queued offline will sync incorrect data to Firestore and affect all other devices.

---

## 🔧 PHASE 4 — REFACTOR PLAN

### Plan Architecture Decision

**✅ DECISION: Store ALL stock in base units (Bottles) always.**  
Display in secondary units (Boxes) only in the UI layer.  
Conversion happens at entry and display points only.

```
Warehouse Stock:     120  [Bottles] ← always base unit
Dispatch "10 Boxes": 120 deducted from warehouse
Allocated Stock:     120  [Bottles] ← stored as base unit
Sale "2 Boxes":       24  deducted from allocated
Return "3 Bottles":   3   added back
```

---

### Step 1: Add `stockUnit` Constant + Centralize Conversion

**New file:** `lib/utils/unit_converter.dart`

```dart
/// LOCKED: Central unit conversion utility.
/// All quantity conversions MUST use this class — never inline.
class UnitConverter {
  /// Convert a quantity FROM secondary unit (Box) TO base unit (Bottle).
  /// e.g., 5 Boxes × 12 = 60 Bottles
  static double toBaseUnit(double secondaryQty, double conversionFactor) {
    if (conversionFactor <= 0) return secondaryQty;
    return secondaryQty * conversionFactor;
  }

  /// Convert FROM base unit (Bottle) TO secondary unit (Box).
  /// e.g., 60 Bottles ÷ 12 = 5 Boxes  
  static double toSecondaryUnit(double baseQty, double conversionFactor) {
    if (conversionFactor <= 0) return baseQty;
    return baseQty / conversionFactor;
  }

  /// Format for UI display: "5 Boxes + 0 Bottles" or "60 Bottles"
  static String formatDual(
    double baseQty,
    String baseUnit,
    String? secondaryUnit,
    double conversionFactor,
  ) {
    if (secondaryUnit == null || secondaryUnit.isEmpty || conversionFactor <= 1) {
      return '${baseQty.toInt()} $baseUnit';
    }
    final boxes = (baseQty / conversionFactor).floor();
    final bottles = (baseQty % conversionFactor).toInt();
    if (boxes > 0 && bottles > 0) {
      return '$boxes $secondaryUnit + $bottles $baseUnit';
    } else if (boxes > 0) {
      return '$boxes $secondaryUnit';
    } else {
      return '$bottles $baseUnit';
    }
  }

  /// Validate conversion factor
  static bool isValidConversionFactor(double? factor) {
    return factor != null && factor > 0;
  }
}
```

---

### Step 2: Add Selling Unit Picker to Sale Screen

**File:** `lib/screens/sales/new_sale_screen.dart`  
**File:** `lib/models/types/sales_types.dart`

Add a `sellingUnit` field to `SaleItem` and `CartItem`:

```dart
// Add to SaleItem:
final String sellingUnit; // 'base' or 'secondary'

// Add to CartItem:
// When user selects "Box" as selling unit:
// - Display: 2 Boxes
// - qty deducted from stock: 2 × 12 = 24 (base units)
// - price shown: secondaryPrice × 2

// Quantity entered always stored internally in base units
int get quantityInBaseUnits {
  if (sellingUnit == 'secondary' && conversionFactor != null && conversionFactor! > 0) {
    return (quantity * conversionFactor!).round();
  }
  return quantity;
}
```

**UI Change:** Add a toggle button next to quantity input in cart:
```
[Qty: 2] [BOTTLE ↕]  → tap to switch to [BOX]
```

When "BOX" is selected, entering `2` means `2 × 12 = 24` bottles deducted from stock.

---

### Step 3: Fix Dispatch to Store in Base Units

**File:** `lib/services/inventory_service.dart` — performSync dispatch section

```dart
// CURRENT (WRONG):
itemUpdate['quantity'] = FieldValue.increment(quantity); // raw dispatch qty

// FIX: Convert to base units before allocation
final effectiveQuantity = item.unit == product.secondaryUnit
    ? quantity * (product.conversionFactor ?? 1.0)
    : quantity; // already in base unit

itemUpdate['quantity'] = FieldValue.increment(effectiveQuantity);
itemUpdate['baseUnit'] = product.baseUnit; // tag the unit
```

**Also fix local allocation when dispatch is received:**
```dart
// In receiveDispatch(), increment in base units
allocatedStock[item.productId] = allocatedStock[item.productId]?.copyWith(
  quantity: (allocatedStock[item.productId]?.quantity ?? 0) + effectiveQuantity,
) ?? AllocatedStockItem(quantity: effectiveQuantity, ...);
```

---

### Step 4: Fix Stock Deduction in Sale

**File:** `lib/services/sales_service.dart` — `_createSaleLocal()`

```dart
// For each cart item, use quantityInBaseUnits for stock deduction:
final baseQty = saleItem.sellingUnit == 'secondary' && saleItem.conversionFactor != null
    ? (saleItem.quantity * saleItem.conversionFactor!).round()
    : saleItem.quantity;

allocated[productId] = allocated[productId]?.copyWith(
  quantity: (allocated[productId]!.quantity - baseQty).clamp(0, double.infinity),
);
```

---

### Step 5: Fix Return to Restore Correct Base Quantity

**File:** `lib/services/returns_service.dart` — return approval  

Return items must specify `unit`. When approving:
```dart
final restoreQty = returnItem.unit == product.secondaryUnit
    ? returnItem.quantity * product.conversionFactor
    : returnItem.quantity; // already in base units

// Restore to salesman's allocated stock:
user.allocatedStock[productId]?.quantity += restoreQty;
```

---

### Step 6: Fix My Stock Display

**File:** `lib/screens/inventory/my_stock_screen.dart`

```dart
// Replace:
_formatQty(item.availableToday, item.baseUnit)

// With:
UnitConverter.formatDual(
  item.availableToday,
  item.baseUnit,
  item.secondaryUnit,
  item.conversionFactor,
)
// Output: "8 Boxes + 0 Bottles"
```

---

### Step 7: Validate ConversionFactor in Product Edit

**File:** `lib/screens/management/product_add_edit_screen.dart`

```dart
// Validation:
if (secondaryUnitController.text.isNotEmpty) {
  final factor = double.tryParse(conversionFactorController.text) ?? 0;
  if (factor <= 1) {
    _showError('Conversion factor must be > 1 when secondary unit is set. '
        'E.g., 12 Bottles per Box means factor = 12');
    return;
  }
}
```

---

### Step 8: Fix Reports

**File:** All report screens  

Add unit suffix to every quantity column header:
```dart
DataColumn(label: Text('Qty (${product.baseUnit})'))
// Or for totals:
Text('Total: ${UnitConverter.formatDual(total, baseUnit, secondaryUnit, factor)}')
```

---

## 🔄 PHASE 5 — SAFE MIGRATION STRATEGY

> ⚠️ **No destructive changes. All migrations are additive and tagged.**

### Step M-1: Audit Existing Stock Data

Before any migration, run this query to assess current unit state:

```dart
// New utility method in ProductsService:
Future<List<Map<String, dynamic>>> auditStockUnits() async {
  final products = await _dbService.products.where().findAll();
  return products.map((p) => {
    'id': p.id,
    'name': p.name,
    'stock': p.stock,
    'baseUnit': p.baseUnit,
    'secondaryUnit': p.secondaryUnit,
    'conversionFactor': p.conversionFactor,
    'issue': p.conversionFactor == null || p.conversionFactor == 1.0
      ? (p.secondaryUnit != null ? 'MISSING_CONVERSION' : 'OK')
      : 'OK',
  }).toList();
}
```

**Admin Screen:** Add an "Inventory Unit Audit" button in Admin Dashboard that shows this report.

---

### Step M-2: Classify Existing Products

Before migrating stock values, classify all products:

```
Status A: conversionFactor = 1.0 AND secondaryUnit = null → No change needed
Status B: conversionFactor = 1.0 AND secondaryUnit != null → NEEDS FIXING (conversion factor must be set)
Status C: conversionFactor > 1.0 AND secondaryUnit != null → OK — confirm if stock is already in base units
Status D: conversionFactor > 1.0 AND secondaryUnit = null → Data inconsistency — fix secondary unit
```

**Only Status B and D require attention.**

---

### Step M-3: Freeze Transactions During Migration

Because this is an offline-first system:
1. Do NOT make any migration that requires touching existing `stock` values if we cannot confirm the unit
2. For **new and future** products: enforce base-unit storage by validation
3. For **existing products**: add a `stockUnit` metadata flag:

```dart
// Add to product_entity.dart (additive only):
String? stockUnitConfirmed; // null = unknown, 'base' = confirmed base unit
```

Admin should manually confirm for existing products whether their current stock is in base or secondary unit.

---

### Step M-4: Fix Converting Existing Dispatched Stock

If existing dispatched allocations in Firestore/Isar are in "Boxes" and need to be in "Bottles":

```dart
// Migration function (one-time, run by admin):
Future<void> migrateAllocatedStockToBaseUnits() async {
  final users = await _dbService.users.where().findAll();
  for (final user in users) {
    if (user.allocatedStockJson == null) continue;
    
    final stock = jsonDecode(user.allocatedStockJson!) as Map<String, dynamic>;
    bool modified = false;
    
    for (final productId in stock.keys) {
      final item = AllocatedStockItem.fromJson(stock[productId]);
      final product = await _dbService.products.getById(productId);
      
      if (product == null) continue;
      final factor = product.conversionFactor ?? 1.0;
      
      // If stock was dispatched in boxes (unit == secondaryUnit) and factor > 1
      if (item.baseUnit == product.secondaryUnit && factor > 1) {
        stock[productId] = item.copyWith(
          quantity: item.quantity * factor, // Convert to base units
          baseUnit: product.baseUnit,        // Fix the unit label
        ).toJson();
        modified = true;
      }
    }
    
    if (modified) {
      await _dbService.db.writeTxn(() async {
        user.allocatedStockJson = jsonEncode(stock);
        user.updatedAt = DateTime.now();
        user.syncStatus = SyncStatus.pending; // Queued for sync
        await _dbService.users.put(user);
      });
    }
  }
}
```

**This migration is safe because:**
- It only modifies local Isar data
- It marks modified records for sync
- It is idempotent (running twice won't double-convert)
- It only converts records where `baseUnit == secondaryUnit` (active mismatch marker)

---

### Step M-5: Add Migration Flag

```dart
// Run once, mark completion:
await SharedPreferences.getInstance()
  ..setBool('stock_unit_migration_v1_done', true);
```

---

## 📋 RECOMMENDED IMPLEMENTATION ORDER

| Priority | Task | Files | Risk |
|----------|------|-------|------|
| 🔴 Now | Create `UnitConverter` utility class | `lib/utils/unit_converter.dart` (new) | Zero |
| 🔴 Now | Run stock unit audit report | `ProductsService` + audit screen | Zero |
| 🔴 Now | Fix `conversionFactor` validation in product create/edit | `product_add_edit_screen.dart`, `products_service.dart` | Low |
| 🟠 Next | Add `sellingUnit` field to `SaleItem`/`CartItem` | `sales_types.dart`, `sale_entity.dart` (additive) | Low |
| 🟠 Next | Add Box/Bottle picker to the sale screen | `new_sale_screen.dart` | Medium |
| 🟠 Next | Fix dispatch to store in base units | `inventory_service.dart` | High (test well) |
| 🟠 Next | Fix `calculateStockUsage` to normalize units | `inventory_service.dart` | Medium |
| 🟡 Later | Fix My Stock display to show dual-unit format | `my_stock_screen.dart` | Low |
| 🟡 Later | Fix Reports to include unit labels | `reports_service.dart`, report screens | Low |
| 🟡 Later | Run one-time allocation migration | New migration method | High (admin-triggered only) |

---

## 🔒 LOCKING RULES (Post-Implementation)

After each phase is implemented and verified:

```
🔒 LOCK: Stock is always stored and computed in base units (Bottles).
- NEVER store Boxes directly in product.stock or allocatedStock.quantity
- ALL display must pass through UnitConverter.formatDual()
- EVERY sale/dispatch input must normalize to base units before saving
- conversionFactor must ALWAYS be validated > 1 when secondaryUnit exists
```

---

## 📁 KEY FILES REFERENCE

| File | Role | Status |
|------|------|--------|
| `lib/data/local/entities/product_entity.dart` | Isar entity with unit fields | ✅ Has fields, needs validation |
| `lib/models/types/product_types.dart` — `Product` | Domain model | ✅ Has fields, no enforcement |
| `lib/models/types/sales_types.dart` — `SaleItem`, `CartItem` | Sale models | ⚠️ Missing `sellingUnit` field |
| `lib/services/products_service.dart` | Product CRUD | ✅ SKU validation done, unit validation missing |
| `lib/services/inventory_service.dart` | Stock ops + dispatch | 🔴 No unit conversion in dispatch |
| `lib/services/sales_service.dart` | Sale creation + stock deduction | 🔴 No unit awareness in deduction |
| `lib/services/returns_service.dart` | Return + stock restore | 🟠 No unit check on quantity |
| `lib/screens/sales/new_sale_screen.dart` | Sale UI + price calc | ⚠️ Price calc is correct, qty entry missing box picker |
| `lib/screens/inventory/my_stock_screen.dart` | Stock display for salesman | 🟡 Base unit display only |
| `lib/screens/dispatch/dispatch_screen.dart` | Admin dispatch creation | 🔴 No unit conversion at dispatch |
| `lib/screens/returns/salesman_returns_screen.dart` | Salesman return screen | 🟠 Reads available in base unit (ok), but return qty not tagged |

---

*Document generated from automated code audit — DattSoap ERP v2026-02-21*  
*Next Review: After Phase 4 Step 3 (Dispatch Fix) is implemented*
