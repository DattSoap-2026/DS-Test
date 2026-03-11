# Cutting Module

**Module:** Cutting & Finished Goods  
**Version:** 2.7  
**Status:** Active

---

## Overview

The Cutting Module manages the cutting process where semi-finished soap is cut into finished products. Tracks yield, waste, and stock adjustments.

---

## Features

- Create cutting batches
- Track semi-finished input
- Record finished goods output
- Calculate yield percentage
- Waste analysis (scrap vs reprocess)
- Automatic stock adjustments

---

## User Roles

**Production Supervisor:** Create batches, view history, access reports  
**Admin:** Full access

---

## Screens

**Cutting Entry** `/dashboard/production/cutting/entry`  
**History** `/dashboard/production/cutting/history`  
**Yield Report** `/dashboard/reports/cutting-yield`  
**Waste Report** `/dashboard/reports/waste-analysis`

---

## Business Logic

### Batch Creation Flow
1. Select semi-finished product
2. Enter input weight (kg)
3. Select finished product
4. Enter units produced
5. Record waste (kg)
6. Validate weight balance
7. Adjust stock (transaction)
8. Add to sync queue

### Stock Adjustments
- **Deduct:** Semi-finished input
- **Add:** Finished goods output
- **Track:** Waste separately

### Validation
- Weight balance: Input ≈ Output + Waste (±0.5%)
- Yield tolerance: ±10%
- Waste limit: <5%

---

## Database Schema

**Collection:** `cutting_batches`

```json
{
  "id": "uuid",
  "batchNumber": "CT-20260307-001",
  "batchDate": "2026-03-07",
  "shift": "morning|evening|night",
  "semiFinishedProductId": "product_id",
  "totalBatchWeightKg": 50.0,
  "finishedGoodId": "product_id",
  "unitsProduced": 250,
  "cuttingWasteKg": 0.5,
  "wasteType": "scrap|reprocess",
  "yieldPercent": 95.0,
  "operatorId": "user_id",
  "supervisorId": "user_id",
  "status": "completed",
  "createdAt": "timestamp"
}
```

---

## API Reference

**File:** `lib/services/cutting_batch_service.dart`

```dart
Future<bool> createCuttingBatch({
  required DateTime batchDate,
  required String semiFinishedProductId,
  required double totalBatchWeightKg,
  required String finishedGoodId,
  required int unitsProduced,
  required double cuttingWasteKg,
  required WasteType wasteType,
  required ShiftType shift,
});
```

---

## Reports

**Yield Report:** Total batches, output, yield %, waste analysis  
**Waste Report:** Scrap vs reprocess breakdown

---

## Known Issues

**T6 Planned:** Migration to durable queue pattern for offline reliability

---

## References

- [Architecture](../architecture.md)
- [Production Module](production_module.md)
- [Bhatti Module](bhatti_module.md)
