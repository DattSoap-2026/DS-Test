# CUTTING HISTORY PAGE UPGRADE - AUDIT & IMPLEMENTATION

**Date**: 2024
**Scope**: Upgrade cutting history to show complete batch details in table format

---

## 🔍 CURRENT STATE ANALYSIS

### Current Display (Card Format)
- ✅ Batch number and date
- ✅ Semi-finished input (name + weight)
- ✅ Finished good output (name + units)
- ✅ Wastage (KG)
- ✅ Weight balance (%)
- ✅ Shift and department
- ❌ Missing: Boxes consumed
- ❌ Missing: Batch count
- ❌ Missing: Packaging materials consumed
- ❌ Missing: Operator name
- ❌ Missing: Actual vs standard weight
- ❌ Missing: Remarks/notes
- ❌ Not in table format

---

## 📊 REQUIRED UPGRADE

### New Table Format Requirements

**Columns Needed**:
1. Batch # & Date
2. Semi-Finished Input (Product + Boxes + Weight)
3. Finished Good Output (Product + Units + Weight)
4. Wastage (KG + %)
5. Packaging Materials (List with quantities)
6. Weight Balance (Input vs Output)
7. Operator & Shift
8. Remarks

### Data Available in CuttingBatch Model
```dart
class CuttingBatch {
  final String batchNumber;
  final DateTime createdAt;
  final String semiFinishedProductName;
  final double totalBatchWeightKg;
  final int boxesCount;  // ✅ Available
  final String finishedGoodName;
  final int unitsProduced;
  final double totalFinishedWeightKg;  // ✅ Available
  final double cuttingWasteKg;
  final double weightDifferencePercent;
  final String operatorName;  // ✅ Available
  final ShiftType shift;
  final String departmentName;
  final String? wasteRemark;  // ✅ Available
  final double standardWeightGm;  // ✅ Available
  final double actualAvgWeightGm;  // ✅ Available
  // ❌ Missing: packagingConsumptions
}
```

---

## 🐛 IDENTIFIED ISSUES

### Issue #1: Packaging Consumption Not Stored
**Problem**: Packaging materials consumed are calculated but not stored in cutting batch
**Location**: `cutting_batch_service.dart` - createCuttingBatch()
**Impact**: Cannot show packaging consumption in history

### Issue #2: Packaging Stock Not Reduced
**Problem**: Packaging materials are consumed but stock is not reduced
**Location**: `cutting_batch_service.dart` - Line 400-420
**Current Code**:
```dart
// 3. Adjust Packaging Materials
if (packagingConsumptions != null) {
  for (var pm in packagingConsumptions) {
    final mId = pm['materialId'];
    final qty = (pm['quantity'] as num).toDouble();
    final pmEntity = await _dbService.products.get(fastHash(mId));
    if (pmEntity != null) {
      await _inventoryService.applyProductStockChangeInTxn(
        productId: mId,
        quantityChange: -qty,
        updatedAt: now,
        markSyncPending: true,
        allowMissing: true,
      );
    }
  }
}
```
**Status**: ✅ Already implemented! Stock IS being reduced.

### Issue #3: Packaging Consumption Not in Entity
**Problem**: CuttingBatchEntity doesn't have packagingConsumptions field
**Location**: `cutting_batch_entity.dart`
**Fix Needed**: Add field to entity and Firestore sync

---

## ✅ REQUIRED FIXES

### Fix #1: Add Packaging Field to CuttingBatchEntity
**File**: `lib/data/local/entities/cutting_batch_entity.dart`

**Add Field**:
```dart
@Collection()
class CuttingBatchEntity extends BaseEntity {
  // ... existing fields ...
  late List<PackagingConsumptionItem> packagingConsumptions;
}

@Embedded()
class PackagingConsumptionItem {
  String? materialId;
  String? materialName;
  double? quantity;
  String? unit;
  
  PackagingConsumptionItem();
  
  factory PackagingConsumptionItem.fromJson(Map<String, dynamic> json) {
    return PackagingConsumptionItem()
      ..materialId = json['materialId'] as String?
      ..materialName = json['materialName'] as String?
      ..quantity = (json['quantity'] as num?)?.toDouble()
      ..unit = json['unit'] as String?;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'quantity': quantity,
      'unit': unit,
    };
  }
}
```

### Fix #2: Add Packaging to CuttingBatch Model
**File**: `lib/models/types/cutting_types.dart`

**Add Field**:
```dart
class CuttingBatch {
  // ... existing fields ...
  final List<Map<String, dynamic>>? packagingConsumptions;
  
  CuttingBatch({
    // ... existing parameters ...
    this.packagingConsumptions,
  });
  
  factory CuttingBatch.fromJson(Map<String, dynamic> json) {
    return CuttingBatch(
      // ... existing fields ...
      packagingConsumptions: json['packagingConsumptions'] != null
          ? List<Map<String, dynamic>>.from(json['packagingConsumptions'])
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      // ... existing fields ...
      'packagingConsumptions': packagingConsumptions,
    };
  }
}
```

### Fix #3: Store Packaging in Service
**File**: `lib/services/cutting_batch_service.dart`

**Update createCuttingBatch** (Line ~500):
```dart
// 4. Record Cutting Batch Entity
final batchEntity = CuttingBatchEntity()
  // ... existing fields ...
  ..packagingConsumptions = (packagingConsumptions ?? [])
      .map((e) => PackagingConsumptionItem.fromJson(e))
      .toList();
```

### Fix #4: Upgrade History Screen to Table
**File**: `lib/screens/production/cutting_history_screen.dart`

**Replace Card with Expandable Table**:
```dart
Widget _buildBatchTable(CuttingBatch batch) {
  return ExpansionTile(
    title: Row(
      children: [
        Text('BATCH #${batch.batchNumber}'),
        Spacer(),
        Text(DateFormat('dd MMM yyyy').format(batch.createdAt)),
      ],
    ),
    children: [
      Table(
        columnWidths: {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
        },
        children: [
          _buildTableRow('Semi-Finished Input', 
            '${batch.semiFinishedProductName} (${batch.boxesCount} BOX, ${batch.totalBatchWeightKg} KG)'),
          _buildTableRow('Finished Good Output', 
            '${batch.finishedGoodName} (${batch.unitsProduced} PCS, ${batch.totalFinishedWeightKg} KG)'),
          _buildTableRow('Wastage', 
            '${batch.cuttingWasteKg} KG (${batch.weightDifferencePercent}%)'),
          _buildTableRow('Weight Check', 
            'Std: ${batch.standardWeightGm}g, Actual: ${batch.actualAvgWeightGm}g'),
          _buildTableRow('Operator', 
            '${batch.operatorName} (${batch.shift.name})'),
          if (batch.packagingConsumptions != null && batch.packagingConsumptions!.isNotEmpty)
            _buildTableRow('Packaging Used', 
              _buildPackagingList(batch.packagingConsumptions!)),
          if (batch.wasteRemark != null && batch.wasteRemark!.isNotEmpty)
            _buildTableRow('Remarks', batch.wasteRemark!),
        ],
      ),
    ],
  );
}

TableRow _buildTableRow(String label, dynamic value) {
  return TableRow(
    children: [
      Padding(
        padding: EdgeInsets.all(8),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: EdgeInsets.all(8),
        child: value is Widget ? value : Text(value.toString()),
      ),
    ],
  );
}

Widget _buildPackagingList(List<Map<String, dynamic>> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: items.map((item) {
      return Text(
        '• ${item['materialName'] ?? 'Unknown'}: ${item['quantity']} ${item['unit'] ?? ''}',
        style: TextStyle(fontSize: 12),
      );
    }).toList(),
  );
}
```

---

## 📋 IMPLEMENTATION STEPS

### Step 1: Update Entity
1. Add PackagingConsumptionItem embedded class
2. Add packagingConsumptions field to CuttingBatchEntity
3. Run `flutter pub run build_runner build`

### Step 2: Update Model
1. Add packagingConsumptions to CuttingBatch
2. Update fromJson and toJson methods

### Step 3: Update Service
1. Store packaging consumptions in batch entity
2. Sync to Firestore

### Step 4: Upgrade UI
1. Replace card layout with expandable table
2. Show all batch details
3. Display packaging consumption
4. Show remarks if present

---

## 🧪 TESTING CHECKLIST

### Test 1: Create Batch with Packaging
- [ ] Create cutting batch with packaging rules
- [ ] Verify packaging stock reduced
- [ ] Check batch saved with packaging data

### Test 2: View History
- [ ] Open cutting history
- [ ] Expand batch details
- [ ] Verify all fields visible:
  - [ ] Batch number and date
  - [ ] Semi-finished (product, boxes, weight)
  - [ ] Finished good (product, units, weight)
  - [ ] Wastage (KG and %)
  - [ ] Packaging materials list
  - [ ] Operator and shift
  - [ ] Remarks (if any)

### Test 3: Packaging Stock Validation
- [ ] Note packaging stock before batch
- [ ] Create batch
- [ ] Verify stock reduced by consumed quantity
- [ ] Check stock ledger entry created

---

## 📊 BUSINESS LOGIC SUMMARY

### Complete Flow
```
1. User creates cutting batch
   ↓
2. System calculates packaging needed
   (based on Product.packagingRecipe)
   ↓
3. System reduces packaging stock
   (via InventoryService)
   ↓
4. System stores packaging consumption
   (in CuttingBatchEntity)
   ↓
5. System syncs to Firestore
   ↓
6. History shows complete details
   (including packaging used)
```

### Stock Impact
- **Semi-Finished**: -X BOX (reduced)
- **Finished Good**: +Y PCS (increased)
- **Packaging**: -Z units (reduced) ✅
- **Wastage**: Returns to raw material

---

## 🎯 EXPECTED OUTCOME

### Before Upgrade
- Card layout
- Basic info only
- No packaging details
- No remarks visible

### After Upgrade
- Expandable table layout
- Complete batch details
- Packaging consumption shown
- Remarks visible
- Easy to understand
- Professional appearance

**Status**: Ready for implementation ✅
