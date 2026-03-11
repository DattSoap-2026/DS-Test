# Display Unit Change Karne Ka Complete Guide

## Quick Summary
"5 Bag" ko change karne ke liye **Product Type** ki `displayUnit` property update karni hogi.

---

## Method 1: UI se Change (✅ Recommended)

### Steps:
1. **Login** karein (Admin/Owner role required)
2. **Navigate** karein:
   ```
   Main Menu → Management/Settings → Master Data
   ```
3. **Categorization Tab** par click karein
4. **Product Types** section mein scroll karein
5. **"Semi-Finished Good"** type ko **Edit** karein
6. **Display Unit** field mein change karein:
   - Current: `Bag`
   - Options: `Batch`, `Kg`, `Pcs`, `Ltr`, etc.
7. **Save** button click karein

### Files Involved:
- `lib/screens/management/master_data_screen.dart`
- `lib/screens/management/system_masters_screen.dart`

---

## Method 2: Firebase Console se (Direct Database Update)

### Steps:
1. **Firebase Console** open karein: https://console.firebase.google.com
2. **Firestore Database** section mein jaayein
3. **Collections** → `product_types` select karein
4. Document dhundein jiska:
   ```
   name = "Semi-Finished Good"
   ```
5. **displayUnit** field edit karein:
   - Click on field value
   - Type new unit (e.g., "Batch")
   - Press Enter to save
6. Changes automatically sync ho jayenge

### Verification:
- App restart karein ya refresh button press karein
- Production Stock screen check karein

---

## Method 3: Code se Update (Programmatic)

### Option A: Helper Utility Use Karein

```dart
import 'package:flutter_app/utils/update_display_unit_helper.dart';
import 'package:flutter_app/services/master_data_service.dart';

// In your screen or service
final masterDataService = context.read<MasterDataService>();
final helper = UpdateDisplayUnitHelper(masterDataService);

// Update display unit
await helper.updateDisplayUnit(
  typeName: 'Semi-Finished Good',
  newDisplayUnit: 'Batch', // Change to desired unit
);
```

### Option B: Direct Service Call

```dart
import 'package:flutter_app/services/master_data_service.dart';

final masterDataService = context.read<MasterDataService>();

// 1. Get product types
final types = await masterDataService.getProductTypes();

// 2. Find Semi-Finished Good type
final semiType = types.firstWhere(
  (t) => t.name == 'Semi-Finished Good',
);

// 3. Update display unit
await masterDataService.updateProductType(
  semiType.id,
  {'displayUnit': 'Batch'}, // Your new unit
);
```

### Option C: One-time Script

Create file: `scripts/update_display_units.dart`

```dart
import 'package:flutter_app/services/master_data_service.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/core/firebase/firebase_config.dart';

void main() async {
  // Initialize services
  final firebase = FirebaseServices();
  final dbService = DatabaseService.instance;
  final masterDataService = MasterDataService(firebase, dbService);

  // Update display unit
  final types = await masterDataService.getProductTypes();
  final semiType = types.firstWhere(
    (t) => t.name == 'Semi-Finished Good',
  );

  final success = await masterDataService.updateProductType(
    semiType.id,
    {'displayUnit': 'Batch'},
  );

  print(success ? '✅ Updated successfully' : '❌ Update failed');
}
```

Run: `dart run scripts/update_display_units.dart`

---

## Available Display Units

Common units aap use kar sakte hain:
- `Pcs` - Pieces
- `Kg` - Kilogram
- `Ltr` - Liter
- `Bag` - Bag (current)
- `Batch` - Batch
- `Box` - Box
- `Ton` - Ton
- `Carton` - Carton

---

## Impact Analysis

### What Changes:
✅ Production Stock screen mein display unit
✅ All screens jahan product display hota hai
✅ Reports mein unit display

### What Doesn't Change:
❌ Actual stock values (5 remains 5)
❌ Product's baseUnit field
❌ Inventory transactions
❌ Historical data

---

## Troubleshooting

### Issue 1: Changes Nahi Dikh Rahe
**Solution:**
1. App restart karein
2. Refresh button press karein
3. Cache clear karein:
   ```dart
   masterDataService.invalidateCache();
   ```

### Issue 2: Permission Denied
**Solution:**
- Admin/Owner role se login karein
- Firebase rules check karein

### Issue 3: Multiple Types Show Same Unit
**Solution:**
- Har product type ki alag displayUnit set karein
- Duplicate types check karein

---

## Best Practices

1. **Consistent Units:** Same category ke products ke liye same unit use karein
2. **Meaningful Units:** Product type ke according logical unit choose karein
   - Raw Material → Kg
   - Semi-Finished → Batch/Bag
   - Finished Good → Pcs
   - Oils → Ltr
3. **Test First:** Staging/test environment mein pehle test karein
4. **Backup:** Firebase export le lein before major changes

---

## Related Files

### Service Layer:
- `lib/services/master_data_service.dart` - Product types manage karta hai
- `lib/services/products_service.dart` - Product data fetch karta hai

### UI Layer:
- `lib/screens/production/production_stock_screen.dart` - Display logic
- `lib/screens/management/system_masters_screen.dart` - Edit UI

### Data Layer:
- `lib/data/local/entities/product_type_entity.dart` - Local storage
- Firebase: `product_types` collection - Remote storage

---

## Quick Reference Commands

### Check Current Display Unit:
```dart
final types = await masterDataService.getProductTypes();
final semiType = types.firstWhere((t) => t.name == 'Semi-Finished Good');
print('Current display unit: ${semiType.displayUnit}');
```

### Update Display Unit:
```dart
await masterDataService.updateProductType(
  semiType.id,
  {'displayUnit': 'NewUnit'},
);
```

### Verify Change:
```dart
masterDataService.invalidateCache();
final updatedTypes = await masterDataService.getProductTypes();
final updated = updatedTypes.firstWhere((t) => t.name == 'Semi-Finished Good');
print('New display unit: ${updated.displayUnit}');
```

---

## Support

Agar koi issue aaye to:
1. Check Firebase Console logs
2. Check app logs: `AppLogger` output
3. Verify user permissions
4. Contact system admin
