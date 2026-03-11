# Production Module

**Module:** Production Management  
**Version:** 2.7  
**Status:** Active

---

## Overview

The Production Module manages the manufacturing process for soap production, including batch creation, BOM (Bill of Materials) management, and stock adjustments.

---

## Features

### 1. Production Batches
- Create production batches
- Track raw material consumption
- Record semi-finished output
- Calculate yield and waste

### 2. Bill of Materials (BOM)
- Define product formulas
- Manage ingredient ratios
- Handle water evaporation (T10)
- Version control for formulas

### 3. Stock Adjustments
- Automatic stock deduction (raw materials)
- Automatic stock addition (semi-finished)
- Transaction-based updates
- Audit trail

---

## User Roles

### Production Supervisor
- Create production batches
- View production history
- Access production reports
- Cannot access other departments

### Production Manager
- All supervisor permissions
- Manage BOMs
- Configure production settings
- View analytics

### Admin
- Full access to all features

---

## Screens

### 1. Production Dashboard
**Route:** `/dashboard/production`

**Features:**
- Today's production summary
- Shift-wise breakdown
- Quick actions
- Recent batches

### 2. Production Batch Entry
**Route:** `/dashboard/production/batch/entry`

**Fields:**
- Date and shift
- Product selection
- Raw material inputs
- Semi-finished output
- Waste tracking

### 3. Production History
**Route:** `/dashboard/production/history`

**Features:**
- Batch list with filters
- Date range selection
- Product filter
- Batch details view

---

## Business Logic

### Batch Creation Flow

```
1. Select product and formula (BOM)
2. Enter raw material quantities
3. Calculate expected output
4. Enter actual output
5. Record waste
6. Validate stock availability
7. Create batch (transaction)
8. Adjust stock levels
9. Add to sync queue
```

### Stock Adjustments

**Raw Materials (Deduction):**
```
For each ingredient in BOM:
  Stock[ingredient] -= quantity_used
```

**Semi-Finished (Addition):**
```
Stock[semi_finished_product] += output_quantity
```

### Validation Rules

1. **Stock Availability**
   - All raw materials must be in stock
   - Sufficient quantity required

2. **Yield Validation**
   - Actual output within tolerance (±10%)
   - Waste percentage reasonable (<5%)

3. **Weight Balance**
   - Input weight ≈ Output weight + Waste
   - Tolerance: ±0.5%

---

## Database Schema

### Collection: `production_batches`

```json
{
  "id": "uuid",
  "batchNumber": "PB-20260307-001",
  "batchDate": "2026-03-07",
  "shift": "morning|evening|night",
  "productId": "product_id",
  "productName": "Product Name",
  "bomId": "bom_id",
  "bomVersion": "1.0",
  "inputs": [
    {
      "materialId": "material_id",
      "materialName": "Material Name",
      "quantityKg": 100.0,
      "unitCost": 50.0
    }
  ],
  "outputKg": 95.0,
  "wasteKg": 5.0,
  "yieldPercent": 95.0,
  "operatorId": "user_id",
  "operatorName": "Operator Name",
  "supervisorId": "user_id",
  "supervisorName": "Supervisor Name",
  "status": "completed",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## Reports

### 1. Production Report
**Route:** `/dashboard/reports/production`

**Metrics:**
- Total batches
- Total output (kg)
- Average yield %
- Waste analysis
- Operator performance

**Filters:**
- Date range
- Product
- Shift
- Operator

### 2. BOM Analysis
**Metrics:**
- Material consumption
- Cost analysis
- Formula efficiency

---

## Integration Points

### Inventory Module
- Stock deduction for raw materials
- Stock addition for semi-finished products
- Real-time stock updates

### Bhatti Module
- Semi-finished products from production
- Input for cooking process

### Reports Module
- Production analytics
- Cost analysis
- Efficiency metrics

---

## API Reference

### ProductionService

**File:** `lib/services/production_service.dart`

**Methods:**

```dart
// Create production batch
Future<bool> createProductionBatch({
  required DateTime batchDate,
  required String productId,
  required String bomId,
  required List<MaterialInput> inputs,
  required double outputKg,
  required double wasteKg,
  required ShiftType shift,
  required String operatorId,
  required String supervisorId,
});

// Get production history
Future<List<ProductionBatch>> getProductionHistory({
  DateTime? startDate,
  DateTime? endDate,
  String? productId,
});

// Get production summary
Future<ProductionSummary> getProductionSummary({
  required DateTime date,
  String? productId,
});
```

---

## Configuration

### Settings

```dart
{
  "yieldTolerance": 10.0,        // percent
  "wasteTolerance": 5.0,         // percent
  "weightBalanceTolerance": 0.5, // percent
  "autoStockAdjustment": true,
  "requireSupervisorApproval": false
}
```

---

## Known Issues

### Current Limitations

1. **Sync Queue** (T6 Planned)
   - Production batches use immediate sync
   - Should use durable queue pattern
   - Planned migration in T6

2. **Multi-Warehouse**
   - Currently single warehouse only
   - Multi-warehouse support planned

---

## Testing

### Test Scenarios

1. Create batch with sufficient stock
2. Create batch with insufficient stock (should fail)
3. Validate yield calculations
4. Verify stock adjustments
5. Test offline batch creation
6. Verify sync queue processing

---

## Troubleshooting

### Common Issues

**Issue:** Stock not adjusting
**Solution:** Check transaction completion, verify stock service

**Issue:** Yield validation failing
**Solution:** Check tolerance settings, verify calculations

**Issue:** Batch not syncing
**Solution:** Check sync queue, verify network connectivity

---

## Future Enhancements

### Planned Features

1. **T6: Queue Migration**
   - Move to durable queue pattern
   - Improve offline reliability

2. **Multi-Warehouse**
   - Support multiple production locations
   - Warehouse-specific stock

3. **Advanced Analytics**
   - Predictive maintenance
   - Optimization suggestions
   - Cost forecasting

---

## References

- [Architecture](../architecture.md)
- [Sync System](../sync_system.md)
- [Bhatti Module](bhatti_module.md)
- [Cutting Module](cutting_module.md)

---

**Maintained by DattSoap Development Team**
