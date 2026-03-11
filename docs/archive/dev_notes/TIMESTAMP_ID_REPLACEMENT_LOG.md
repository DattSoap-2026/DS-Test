# Timestamp ID Replacement Log

## Objective
Replace all `DateTime.now().millisecondsSinceEpoch` and `DateTime.now().microsecondsSinceEpoch` used for ID generation with UUID v4 or deterministic IDs.

## Files Identified (31 locations)

###  COMPLETED

1. **lib/services/cutting_batch_service.dart** - Line 248
   - `generateBatchGeneId()` - Replaced timestamp with UUID
   - Status: FIXED

###  IN PROGRESS

2. **lib/data/local/entities/holiday_entity.dart**
   - Line: `id = model.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : model.id`
   
3. **lib/data/local/entities/vehicle_entity.dart**
   - Line: `'v_${DateTime.now().millisecondsSinceEpoch}_${(json['number'] ?? '').toString().hashCode.abs()}'`

4. **lib/modules/hr/screens/add_edit_employee_screen.dart**
   - Line: `'EMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'`

5. **lib/screens/inventory/dialogs/refill_tank_dialog.dart**
   - Line: `'REFILL-${DateTime.now().millisecondsSinceEpoch}'`

6. **lib/screens/inventory/material_issue_screen.dart** (2 locations)
   - Line: `'productId': 'custom_${DateTime.now().millisecondsSinceEpoch}'`
   - Line: `referenceId: 'REFILL-${DateTime.now().millisecondsSinceEpoch}'`

7. **lib/screens/management/products_list_screen.dart**
   - Line: `'No-SKU-${DateTime.now().millisecondsSinceEpoch}'`

8. **lib/screens/management/product_add_edit_screen.dart** (2 locations)
   - Line: `widget.product?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}'`
   - Line: `'img_${DateTime.now().millisecondsSinceEpoch}'`

9. **lib/screens/procurement/goods_receipt_screen.dart**
   - Line: `'DIRECT_GRN_${DateTime.now().millisecondsSinceEpoch}'`

10. **lib/services/data_management_service.dart**
    - Line: `docId: 'bulk_import_${DateTime.now().millisecondsSinceEpoch}'`

11. **lib/services/dispatch_service.dart** (2 locations)
    - Line: `final timestamp = DateTime.now().millisecondsSinceEpoch;`
    - Line: `'delivery_trips_update_${trip.id}_${DateTime.now().millisecondsSinceEpoch}'`

12. **lib/services/master_data_service.dart**
    - Line: `final id = DateTime.now().millisecondsSinceEpoch.toString();`

13. **lib/services/payments_service.dart**
    - Line: `DateTime.now().millisecondsSinceEpoch;`

14. **lib/services/production_batch_service.dart**
    - Line: `final timestamp = DateTime.now().millisecondsSinceEpoch;`

15. **lib/services/purchase_order_service.dart** (3 locations)
    - Line: `'id': '${po.id}-grn-${DateTime.now().millisecondsSinceEpoch}'`
    - Line: `'comp_po_${po.id}_${DateTime.now().microsecondsSinceEpoch}'`
    - Line: `'comp_grn_${poBeforeReceive.id}_${DateTime.now().microsecondsSinceEpoch}'`

16. **lib/services/route_order_service.dart**
    - Line: `'createdAtEpoch': DateTime.now().millisecondsSinceEpoch`

17. **lib/services/settings_service.dart** (3 locations)
    - Line: `'logo_${DateTime.now().millisecondsSinceEpoch}.png'`
    - Line: `DateTime.now().millisecondsSinceEpoch.toString()`
    - Line: `final deptId = DateTime.now().millisecondsSinceEpoch.toString();`

18. **lib/services/tank_service.dart**
    - Line: `final transId = DateTime.now().millisecondsSinceEpoch.toString();`

19. **lib/modules/accounting/screens/voucher_entry_screen.dart**
    - Line: `'manual_${widget.voucherType}_${DateTime.now().microsecondsSinceEpoch}'`

20. **lib/screens/bhatti/bhatti_batch_edit_screen.dart**
    - Line: `String _newRowId() => DateTime.now().microsecondsSinceEpoch.toString();`

21. **lib/services/roles_service.dart**
    - Line: `'role_${DateTime.now().microsecondsSinceEpoch}'`

22. **lib/services/settings_service.dart**
    - Line: `final currencyId = 'currency_${DateTime.now().microsecondsSinceEpoch}';`

23. **lib/services/task_history_service.dart**
    - Line: `'id': 'task_history_${DateTime.now().microsecondsSinceEpoch}'`

###  EXCLUDED (Non-ID Usage)

24. **lib/screens/settings/data_management_screen.dart**
    - Line: `fileName: '${key}_export_${DateTime.now().millisecondsSinceEpoch}.csv'`
    - Reason: Filename generation, not entity ID

25. **lib/screens/vehicles/dialogs/bulk_operations_dialog.dart**
    - Line: `fileName: 'vehicles_export_${DateTime.now().millisecondsSinceEpoch}.csv'`
    - Reason: Filename generation, not entity ID

26. **lib/services/csv_service.dart** (2 locations)
    - Lines: CSV export filenames
    - Reason: Filename generation, not entity ID

27. **lib/services/gps_service.dart**
    - Line: `DateTime.now().millisecondsSinceEpoch - 10 * 60 * 1000;`
    - Reason: Time calculation, not ID generation

28. **lib/services/master_data_service.dart** (2 locations - cache)
    - Lines: Cache timestamp tracking
    - Reason: Cache TTL mechanism, not ID generation

## Replacement Strategy

### For Entity IDs
```dart
// OLD
final id = DateTime.now().millisecondsSinceEpoch.toString();

// NEW
final id = const Uuid().v4();
```

### For Prefixed IDs
```dart
// OLD
final id = 'EMP-${DateTime.now().millisecondsSinceEpoch}';

// NEW
final id = 'EMP-${const Uuid().v4().substring(0, 8)}';
```

### For Composite IDs
```dart
// OLD
final id = 'v_${DateTime.now().millisecondsSinceEpoch}_${hash}';

// NEW
final id = 'v_${const Uuid().v4().substring(0, 8)}_${hash}';
```

## Verification Command
```bash
findstr /s /i /c:"DateTime.now().millisecondsSinceEpoch" lib\*.dart
findstr /s /i /c:"DateTime.now().microsecondsSinceEpoch" lib\*.dart
```

## Expected Result
Zero matches for ID generation contexts after replacement.


