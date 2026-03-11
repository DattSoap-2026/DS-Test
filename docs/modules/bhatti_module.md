# Bhatti Module (Soap Cooking)

**Module:** Bhatti Cooking Operations  
**Version:** 2.7  
**Status:** Active

---

## Overview

The Bhatti Module manages the soap cooking process, where raw materials are cooked in large vessels (bhattis) to produce semi-finished soap. This is a critical step in the soap manufacturing process.

---

## Features

### 1. Batch Cooking
- Create cooking batches
- Track material consumption
- Monitor cooking process
- Record semi-finished output

### 2. Formula Management
- Define cooking formulas
- Manage ingredient ratios
- Handle water evaporation
- Version control

### 3. Material Issue
- Issue raw materials to bhatti
- Track material consumption
- Return unused materials
- Stock adjustments

### 4. Department Assignment
- Assign batches to departments
- Auto-select formula for single option
- Department-based access control

---

## User Roles

### Bhatti Supervisor
- Create cooking batches
- Issue materials
- View bhatti reports
- Manage cooking process
- Cannot access other departments

### Production Manager
- All supervisor permissions
- Manage formulas
- Configure bhatti settings
- View analytics

### Admin
- Full access to all features

---

## Screens

### 1. Bhatti Dashboard
**Route:** `/bhatti/dashboard`

**Features:**
- Today's cooking summary
- Active batches
- Material stock levels
- Quick actions

### 2. Bhatti Cooking Screen
**Route:** `/bhatti/cooking`

**Features:**
- Create new batch
- Select formula
- Department assignment
- Material issue tracking
- Output recording

**Recent Improvements:**
- ✅ Department-based access control
- ✅ Auto-select formula when single option
- ✅ Improved UX for supervisors

### 3. Batch Management
**Route:** `/bhatti/batches`

**Features:**
- Active batches list
- Batch status tracking
- Edit batch details
- Complete batches

### 4. Material Issue
**Route:** `/bhatti/material-issue`

**Features:**
- Issue materials to bhatti
- Track issued quantities
- Return unused materials
- Stock adjustments

---

## Business Logic

### Cooking Batch Flow

```
1. Select formula
2. Assign to department
3. Issue raw materials
4. Start cooking process
5. Monitor cooking
6. Record output (semi-finished)
7. Calculate yield
8. Complete batch
9. Adjust stock levels
10. Add to sync queue
```

### Stock Adjustments

**Raw Materials (Issue):**
```
For each ingredient:
  Stock[ingredient] -= issued_quantity
  Bhatti_Stock[ingredient] += issued_quantity
```

**Semi-Finished (Output):**
```
Stock[semi_finished] += output_quantity
Bhatti_Stock[raw_materials] -= consumed_quantity
```

**Material Return:**
```
Bhatti_Stock[ingredient] -= returned_quantity
Stock[ingredient] += returned_quantity
```

### Validation Rules

1. **Material Availability**
   - All materials must be in stock
   - Sufficient quantity for formula

2. **Formula Validation**
   - Formula must be active
   - All ingredients defined
   - Ratios must sum to 100%

3. **Output Validation**
   - Output within expected range
   - Waste percentage reasonable
   - Weight balance maintained

---

## Database Schema

### Collection: `bhatti_batches`

```json
{
  "id": "uuid",
  "batchNumber": "BH-20260307-001",
  "batchDate": "2026-03-07",
  "formulaId": "formula_id",
  "formulaName": "Formula Name",
  "formulaVersion": "1.0",
  "departmentId": "dept_id",
  "departmentName": "Department Name",
  "materials": [
    {
      "materialId": "material_id",
      "materialName": "Material Name",
      "issuedKg": 100.0,
      "consumedKg": 95.0,
      "returnedKg": 5.0
    }
  ],
  "outputKg": 90.0,
  "wasteKg": 5.0,
  "yieldPercent": 90.0,
  "operatorId": "user_id",
  "operatorName": "Operator Name",
  "supervisorId": "user_id",
  "supervisorName": "Supervisor Name",
  "status": "active|completed",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Collection: `material_issues`

```json
{
  "id": "uuid",
  "issueNumber": "MI-20260307-001",
  "issueDate": "2026-03-07",
  "batchId": "batch_id",
  "departmentId": "dept_id",
  "materials": [
    {
      "materialId": "material_id",
      "materialName": "Material Name",
      "quantityKg": 100.0,
      "unitCost": 50.0
    }
  ],
  "issuedBy": "user_id",
  "issuedByName": "User Name",
  "status": "issued|returned",
  "createdAt": "timestamp"
}
```

---

## Reports

### 1. Bhatti Production Report
**Metrics:**
- Total batches
- Total output (kg)
- Average yield %
- Material consumption
- Operator performance

**Filters:**
- Date range
- Formula
- Department
- Operator

### 2. Material Consumption Report
**Metrics:**
- Material usage by type
- Cost analysis
- Waste tracking
- Return analysis

---

## Integration Points

### Production Module
- Semi-finished products to production
- Stock flow coordination

### Inventory Module
- Material issue and return
- Stock adjustments
- Real-time stock updates

### Cutting Module
- Semi-finished products to cutting
- Batch tracking

---

## API Reference

### BhattiService

**File:** `lib/services/bhatti_service.dart`

**Methods:**

```dart
// Create cooking batch
Future<bool> createBhattiBatch({
  required DateTime batchDate,
  required String formulaId,
  required String departmentId,
  required List<MaterialInput> materials,
  required double outputKg,
  required double wasteKg,
  required String operatorId,
  required String supervisorId,
});

// Issue materials
Future<bool> issueMaterials({
  required String batchId,
  required String departmentId,
  required List<MaterialIssue> materials,
  required String issuedBy,
});

// Return materials
Future<bool> returnMaterials({
  required String issueId,
  required List<MaterialReturn> materials,
  required String returnedBy,
});

// Get active batches
Future<List<BhattiBatch>> getActiveBatches({
  String? departmentId,
});

// Complete batch
Future<bool> completeBatch({
  required String batchId,
  required double actualOutputKg,
  required double wasteKg,
});
```

---

## Configuration

### Settings

```dart
{
  "yieldTolerance": 10.0,        // percent
  "wasteTolerance": 5.0,         // percent
  "autoMaterialIssue": true,
  "requireSupervisorApproval": false,
  "departmentBasedAccess": true
}
```

---

## Recent Improvements

### Department Assignment (Fixed)
**Issue:** Bhatti supervisors couldn't assign batches to departments  
**Solution:** Added department-based access control and auto-selection

**Changes:**
- ✅ Department dropdown in cooking screen
- ✅ Auto-select when single department
- ✅ Department-based filtering
- ✅ Improved UX for supervisors

**File:** `lib/screens/bhatti/bhatti_cooking_screen.dart`

---

## Known Issues

### Current Limitations

1. **Sync Queue** (T6 Planned)
   - Bhatti batches use immediate sync
   - Should use durable queue pattern
   - Planned migration in T6

2. **Multi-Department**
   - Currently supports single department per batch
   - Multi-department support planned

---

## Testing

### Test Scenarios

1. Create batch with material issue
2. Complete batch with output recording
3. Return unused materials
4. Validate stock adjustments
5. Test department-based access
6. Verify formula auto-selection
7. Test offline batch creation
8. Verify sync queue processing

---

## Troubleshooting

### Common Issues

**Issue:** Materials not issuing
**Solution:** Check stock availability, verify department access

**Issue:** Formula not auto-selecting
**Solution:** Verify only one formula exists for department

**Issue:** Batch not syncing
**Solution:** Check sync queue, verify network connectivity

**Issue:** Department access denied
**Solution:** Verify user role and department assignment

---

## Future Enhancements

### Planned Features

1. **T6: Queue Migration**
   - Move to durable queue pattern
   - Improve offline reliability

2. **Multi-Department Support**
   - Support multiple departments per batch
   - Department-wise analytics

3. **Advanced Monitoring**
   - Real-time cooking monitoring
   - Temperature tracking
   - Quality control integration

4. **Mobile Optimization**
   - Improved mobile UI
   - Offline-first enhancements
   - Quick actions

---

## References

- [Architecture](../architecture.md)
- [Sync System](../sync_system.md)
- [Production Module](production_module.md)
- [Cutting Module](cutting_module.md)
- [Inventory Module](inventory_module.md)

---

**Maintained by DattSoap Development Team**
