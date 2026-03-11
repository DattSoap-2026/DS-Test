# Bhatti Consumption Audit & Multi-Tank Feature

## Overview
This implementation adds consumption audit capabilities for Bhatti supervisors to verify material usage and track multi-tank consumption.

## Features Implemented

### 1. **Consumption Audit Screen** ✅
- **Location**: `lib/screens/bhatti/bhatti_consumption_audit_screen.dart`
- **Route**: `/dashboard/bhatti/batch/:batchId/audit`
- **Access**: Available from batch edit screen via audit icon button

#### What it shows:
- **Batch Information**: Bhatti name, product, batch count, output boxes, supervisor, status
- **Tank Consumption Details**: 
  - Tank-wise breakdown showing which tanks were used
  - Quantity consumed from each tank
  - Lot-level details (which lot was consumed from each tank)
- **Material Consumption**: 
  - Total quantity consumed per material
  - Aggregated view across all sources (tanks + warehouse)

### 2. **Multi-Tank Consumption** ✅ (Already Supported)
The system already supports consuming materials from multiple tanks! The `bhatti_cooking_screen.dart` allows:
- Selecting multiple tanks for the same material
- Distributing consumption across tanks (e.g., Silicate 370 kg: Tank 1 = 100kg, Tank 2 = 200kg, Tank 3 = 70kg)
- Automatic tank selection based on stock availability
- Manual override of tank quantities

#### How it works:
1. When a formula is selected, the system automatically suggests tank distribution
2. Supervisor can modify quantities for each tank
3. System validates against available stock
4. All tank consumptions are saved with the batch

### 3. **Tank Distribution Memory** ✅ (Already Implemented)
The `_seedTankControllersForFormula()` function automatically:
- Remembers which tanks were used for similar batches
- Pre-fills tank quantities based on formula requirements
- Distributes material across multiple tanks intelligently
- Prioritizes tanks with higher stock levels

## Usage Flow

### For Bhatti Supervisor:

1. **Creating a Batch** (Consumption Entry):
   ```
   Dashboard → Bhatti → Consumption & Batch Entry
   → Select Department (Sona/Gita)
   → Select Formula
   → System auto-fills tank quantities
   → Adjust quantities if needed (multi-tank support)
   → Submit batch
   ```

2. **Viewing Audit** (Verification):
   ```
   Dashboard → Bhatti → Batch History
   → Select a batch
   → Click "Audit" icon (fact_check icon)
   → View detailed consumption breakdown
   ```

## Technical Details

### Data Structure
The `BhattiBatch` entity stores:
```dart
tankConsumptions: [
  {
    'tankId': 'tank_id',
    'tankName': 'S-Silicate-1',
    'materialId': 'material_id',
    'quantity': 100.0,
    'lots': [
      {
        'lotId': 'lot_id',
        'quantity': 100.0,
        'cost': 5000.0
      }
    ]
  }
]
```

### Key Files Modified:
1. ✅ `bhatti_batch_edit_screen.dart` - Added audit button
2. ✅ `app_router.dart` - Added audit route
3. ✅ `bhatti_consumption_audit_screen.dart` - New audit screen

### Key Files (Already Supporting Multi-Tank):
1. `bhatti_cooking_screen.dart` - Tank selection and distribution
2. `bhatti_service.dart` - Tank consumption logic
3. `tank_service.dart` - Tank stock management
4. `bhatti_batch_entity.dart` - Data persistence

## Benefits

### For Bhatti Supervisor:
- ✅ **Audit Capability**: Verify actual consumption vs formula
- ✅ **Multi-Tank Flexibility**: Use any combination of tanks
- ✅ **Time Saving**: Auto-filled tank distribution
- ✅ **Transparency**: See exactly which tanks and lots were used
- ✅ **Stock Tracking**: Real-time validation against available stock

### For Management:
- ✅ **Traceability**: Complete audit trail of material consumption
- ✅ **Cost Tracking**: Lot-level cost tracking
- ✅ **Inventory Control**: Accurate tank stock management
- ✅ **Quality Control**: Track material sources (supplier via lots)

## Example Scenario

**Batch**: Sona Bhatti, 5 batches of Laundry Soap
**Formula Requirement**: Silicate 370 kg

**Multi-Tank Consumption**:
- S-Silicate-1: 150 kg (from Lot ABC123)
- S-Silicate-2: 120 kg (from Lot DEF456)
- S-Silicate-3: 100 kg (from Lot GHI789)
- **Total**: 370 kg ✅

**Audit View Shows**:
```
TANK CONSUMPTION DETAILS
━━━━━━━━━━━━━━━━━━━━━━━━
🔵 S-SILICATE-1          150.00 KG
   Lot: ABC123 → 150.00 KG

🔵 S-SILICATE-2          120.00 KG
   Lot: DEF456 → 120.00 KG

🔵 S-SILICATE-3          100.00 KG
   Lot: GHI789 → 100.00 KG

MATERIAL CONSUMPTION
━━━━━━━━━━━━━━━━━━━━━━━━
SILICATE
Actual Consumed: 370.00 KG
```

## Future Enhancements (Optional)

1. **Formula Comparison**: Show expected vs actual side-by-side
2. **Variance Analysis**: Highlight deviations from formula
3. **Cost Analysis**: Show cost per batch with tank-wise breakdown
4. **Supplier Tracking**: Show which supplier's material was used
5. **Export Reports**: PDF/Excel export of audit data
6. **Batch Comparison**: Compare consumption across multiple batches

## Notes

- The multi-tank feature was already fully implemented in the system
- This update adds the audit/verification layer for supervisors
- No changes to core bhatti service logic were needed
- All existing batches will show audit data (backward compatible)
- Tank distribution is automatically saved and reused for efficiency
