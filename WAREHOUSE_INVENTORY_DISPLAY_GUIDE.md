# Warehouse-Wise Inventory Display Implementation Guide

## ✅ COMPLETED: Navigation Menu

**File Modified:** `lib/constants/nav_items.dart`

**Change:**
Added "Warehouse Transfer" link to Inventory submenu:
```dart
NavItem(
  href: "/dashboard/inventory/warehouse-transfer",
  label: "Warehouse Transfer",
  icon: "",
  roles: [UserRole.admin, UserRole.storeIncharge],
  keyTip: "W",
),
```

**Result:** ✅ Warehouse Transfer now appears in Inventory menu

---

## 🔄 PENDING: Inventory Overview - Warehouse Columns

### Current State:
- Shows single "STOCK" column with total stock
- Expandable section shows "DEPARTMENT BREAKDOWN"
- Hardcoded department logic

### Required Changes:

#### **Option 1: Replace Department with Warehouse (Recommended)**

**Table Columns:**
```
| PRODUCT | GITA SHED | SONA SHED | MAIN WAREHOUSE | TOTAL | STATUS |
```

**Changes Needed:**

1. **Update InventoryTable Widget**
   - File: `lib/widgets/inventory/inventory_table.dart`
   - Replace department breakdown with warehouse breakdown
   - Add warehouse columns to main table
   - Remove expandable section (show inline)

2. **Create Warehouse Stock Provider**
   - File: `lib/providers/inventory_provider.dart`
   - Add `warehouseStocksProvider(productId)`
   - Fetch stock balances by warehouse

3. **Update Stock Balance Query**
   - Query `stock_balances` collection
   - Group by `locationId` (warehouse)
   - Sum quantities per warehouse

#### **Option 2: Keep Both Department & Warehouse**

**Table Columns:**
```
| PRODUCT | STOCK | PRICE | STATUS |
```

**Expandable Section:**
```
WAREHOUSE BREAKDOWN
├─ Gita Shed: 150 PCS
├─ Sona Shed: 200 PCS
└─ Main Warehouse: 300 PCS
   Total: 650 PCS

DEPARTMENT BREAKDOWN
├─ Production: 100 PCS
├─ Bhatti: 50 PCS
└─ Main Store: 500 PCS
   Total: 650 PCS
```

---

## 📋 Implementation Steps (Option 1 - Recommended)

### Step 1: Create Warehouse Stock Provider

**File:** `lib/providers/inventory_provider.dart`

Add:
```dart
@riverpod
Future<List<WarehouseStock>> warehouseStocks(
  WarehouseStocksRef ref,
  String productId,
) async {
  final dbService = ref.read(databaseServiceProvider);
  
  final balances = await dbService.stockBalances
      .filter()
      .productIdEqualTo(productId)
      .findAll();
  
  final warehouses = await dbService.inventoryLocations
      .filter()
      .typeEqualTo('warehouse')
      .findAll();
  
  final warehouseMap = {for (var w in warehouses) w.id: w.name};
  
  return balances
      .where((b) => warehouseMap.containsKey(b.locationId))
      .map((b) => WarehouseStock(
            warehouseId: b.locationId,
            warehouseName: warehouseMap[b.locationId]!,
            stock: b.quantity,
            unit: product.baseUnit,
          ))
      .toList();
}

class WarehouseStock {
  final String warehouseId;
  final String warehouseName;
  final double stock;
  final String unit;
  
  WarehouseStock({
    required this.warehouseId,
    required this.warehouseName,
    required this.stock,
    required this.unit,
  });
}
```

### Step 2: Update InventoryTable Widget

**File:** `lib/widgets/inventory/inventory_table.dart`

**Changes:**

1. **Add Warehouse Columns to Header:**
```dart
Row(
  children: [
    Expanded(flex: 3, child: Text('PRODUCT')),
    Expanded(flex: 2, child: Text('GITA SHED')),
    Expanded(flex: 2, child: Text('SONA SHED')),
    Expanded(flex: 2, child: Text('MAIN WH')),
    Expanded(flex: 2, child: Text('TOTAL')),
    SizedBox(width: 60, child: Text('STATUS')),
  ],
)
```

2. **Update Product Row:**
```dart
ref.watch(warehouseStocksProvider(product.id)).when(
  loading: () => Row(/* loading state */),
  error: (err, stack) => Row(/* error state */),
  data: (warehouseStocks) {
    final gitaStock = warehouseStocks
        .firstWhere((w) => w.warehouseId == 'Gita_Shed', 
                    orElse: () => WarehouseStock(..., stock: 0))
        .stock;
    
    final sonaStock = warehouseStocks
        .firstWhere((w) => w.warehouseId == 'Sona_Shed',
                    orElse: () => WarehouseStock(..., stock: 0))
        .stock;
    
    final mainStock = warehouseStocks
        .firstWhere((w) => w.warehouseId == 'Main',
                    orElse: () => WarehouseStock(..., stock: 0))
        .stock;
    
    final total = gitaStock + sonaStock + mainStock;
    
    return Row(
      children: [
        Expanded(flex: 3, child: Text(product.name)),
        Expanded(flex: 2, child: Text('$gitaStock')),
        Expanded(flex: 2, child: Text('$sonaStock')),
        Expanded(flex: 2, child: Text('$mainStock')),
        Expanded(flex: 2, child: Text('$total', bold)),
        SizedBox(width: 60, child: StatusBadge(status)),
      ],
    );
  },
)
```

3. **Remove Expandable Section:**
- Remove `_expandedProducts` set
- Remove expand/collapse logic
- Remove department breakdown UI

### Step 3: Update Mobile View (Optional)

For mobile, keep expandable but show warehouses:

```dart
// Main row (collapsed)
Row(
  children: [
    Expanded(child: ProductInfo),
    Text('Total: $total'),
    StatusBadge,
  ],
)

// Expanded section
if (isExpanded)
  WarehouseBreakdown(
    warehouses: [
      {'name': 'Gita Shed', 'stock': gitaStock},
      {'name': 'Sona Shed', 'stock': sonaStock},
      {'name': 'Main Warehouse', 'stock': mainStock},
    ],
  )
```

---

## 🎨 UI Design

### Desktop View:
```
┌─────────────────────────────────────────────────────────────────┐
│ PRODUCT          │ GITA SHED │ SONA SHED │ MAIN WH │ TOTAL │ ✓ │
├─────────────────────────────────────────────────────────────────┤
│ Soap Bar 175g    │   150     │    200    │   300   │  650  │ ✓ │
│ SKU-001 • Soap   │           │           │         │       │   │
├─────────────────────────────────────────────────────────────────┤
│ Gita 100g x20    │   100     │     50    │   200   │  350  │ ⚠ │
│ FG0IT81 • Gita   │           │           │         │       │   │
└─────────────────────────────────────────────────────────────────┘
```

### Mobile View (Collapsed):
```
┌────────────────────────────────────┐
│ Soap Bar 175g          Total: 650  │
│ SKU-001 • Soap              ✓      │
└────────────────────────────────────┘
```

### Mobile View (Expanded):
```
┌────────────────────────────────────┐
│ Soap Bar 175g          Total: 650  │
│ SKU-001 • Soap              ✓      │
│                                    │
│ WAREHOUSE BREAKDOWN                │
│ ├─ Gita Shed:        150 PCS      │
│ ├─ Sona Shed:        200 PCS      │
│ └─ Main Warehouse:   300 PCS      │
│    Total:            650 PCS      │
└────────────────────────────────────┘
```

---

## 🔧 Database Query

**Current Query (Department):**
```dart
final deptStocks = await dbService.stockBalances
    .filter()
    .productIdEqualTo(productId)
    .and()
    .locationIdStartsWith('dept_')
    .findAll();
```

**New Query (Warehouse):**
```dart
final warehouseStocks = await dbService.stockBalances
    .filter()
    .productIdEqualTo(productId)
    .findAll();

// Filter for warehouse locations only
final warehouses = await dbService.inventoryLocations
    .filter()
    .typeEqualTo('warehouse')
    .findAll();

final warehouseIds = warehouses.map((w) => w.id).toSet();

final filteredStocks = warehouseStocks
    .where((b) => warehouseIds.contains(b.locationId))
    .toList();
```

---

## ⚡ Quick Implementation (Minimal Changes)

If you want the quickest solution, just update the expandable section:

**File:** `lib/widgets/inventory/inventory_table.dart`

**Find:**
```dart
ref.watch(deptStocksProvider(product.id))
```

**Replace with:**
```dart
ref.watch(warehouseStocksProvider(product.id))
```

**Update UI:**
```dart
Text('WAREHOUSE BREAKDOWN', ...)

...warehouseStocks.map((ws) => 
  Row(
    children: [
      Text(ws.warehouseName.toUpperCase()),
      Text('${ws.stock} ${ws.unit}'),
    ],
  ),
),
```

This keeps the same expandable UI but shows warehouses instead of departments.

---

## 📝 Summary

**Completed:**
- ✅ Navigation menu updated
- ✅ Warehouse Transfer screen created
- ✅ Warehouse Transfer routing added

**Pending:**
- 🔄 Inventory Overview warehouse columns
- 🔄 Warehouse stock provider
- 🔄 Remove hardcoded departments

**Recommendation:**
Start with **Quick Implementation** (update expandable section only), then later add full warehouse columns if needed.

**Estimated Time:**
- Quick Implementation: 1-2 hours
- Full Column Implementation: 4-6 hours

---

**Next Steps:**
1. Create `warehouseStocksProvider` in inventory_provider.dart
2. Update expandable section in inventory_table.dart
3. Test with sample data
4. Add warehouse columns to desktop view (optional)
