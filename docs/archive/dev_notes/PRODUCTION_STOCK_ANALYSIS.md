# Production Stock Screen - "5 Bag" Display Analysis

## Summary
Production Stock screen mein "Gita" product ke samne "5 Bag" display ho raha hai. Yeh analysis explain karti hai ki yeh data kaha se aa raha hai aur "Bag" unit kaise import ho raha hai.

## Data Flow

### 1. Stock Value Source (5)
**File:** `lib/services/products_service.dart`

```dart
// Line 169-170
stock: entity.stock ?? 0.0, // Default to 0.0 if null
```

**Database:** 
- Stock value `ProductEntity` se aata hai jo Isar database mein store hota hai
- Path: `ProductEntity.stock` field
- Yeh value inventory transactions se update hoti hai (InventoryService ke through)

**Important:** Stock value directly ProductsService mein update nahi hota. Yeh sirf InventoryService ke through hi change ho sakta hai (Architecture Lock).

### 2. Display Unit Source ("Bag")
**File:** `lib/screens/production/production_stock_screen.dart`

```dart
// Line 485-497
String _getDisplayUnit(Product product) {
  final normalizedType = ProductType.fromString(product.itemType.value).value;
  final productType = _productTypes.firstWhere(
    (t) => t.name == normalizedType,
    orElse: () => DynamicProductType(...),
  );
  return productType.displayUnit ?? product.baseUnit;
}
```

**Logic:**
1. Product ki `itemType` ko normalize karta hai
2. `_productTypes` list mein se matching type dhundta hai
3. Agar `displayUnit` set hai to woh use karta hai
4. Nahi to `product.baseUnit` fallback ke taur par use hota hai

### 3. Product Types Data Source
**File:** `lib/services/master_data_service.dart`

```dart
// Line 56-68
class DynamicProductType {
  final String displayUnit;  // Yeh field "Bag" store karta hai
  // ...
}

// Line 548-590
Future<List<DynamicProductType>> getProductTypes() async {
  // 1. ISAR database se read karta hai
  final entities = await dbService.productTypes
      .where()
      .sortByName()
      .findAll();
  
  // 2. Agar local nahi mila to Firebase se fetch karta hai
  final snapshot = await firestore
      .collection("product_types")
      .orderBy("name")
      .get();
}
```

## Complete Data Chain

```
Firebase Firestore
    ↓
product_types collection
    ↓
displayUnit: "Bag" field
    ↓
MasterDataService.getProductTypes()
    ↓
ProductTypeEntity (Isar)
    ↓
DynamicProductType.displayUnit
    ↓
ProductionStockScreen._getDisplayUnit()
    ↓
UI Display: "5 Bag"
```

## Key Files

1. **Stock Value:**
   - `lib/data/local/entities/product_entity.dart` - Entity definition
   - `lib/services/products_service.dart` - Stock ko read karta hai
   - `lib/services/inventory_service.dart` - Stock ko update karta hai

2. **Display Unit:**
   - `lib/services/master_data_service.dart` - Product types manage karta hai
   - `lib/data/local/entities/product_type_entity.dart` - displayUnit field
   - `lib/screens/production/production_stock_screen.dart` - Display logic

3. **Firebase Collections:**
   - `products` - Product data with stock values
   - `product_types` - Product type definitions with displayUnit

## How "Bag" is Imported

"Bag" unit Firebase Firestore se import hota hai:

1. **Initial Setup:**
   - Admin/Setup process mein product types create hote hain
   - `product_types` collection mein document create hota hai
   - `displayUnit` field mein "Bag" set hota hai

2. **Sync Process:**
   - MasterDataService Firebase se data fetch karti hai
   - Local Isar database mein cache karti hai
   - ProductTypeEntity mein store hota hai

3. **Display:**
   - Screen load hone par `_fetchStock()` call hota hai
   - Product types load hote hain
   - `_getDisplayUnit()` appropriate unit return karta hai

## Example Product Type Document (Firebase)

```json
{
  "id": "semi_finished_123",
  "name": "Semi-Finished Good",
  "displayUnit": "Bag",
  "defaultUom": "Batch",
  "defaultGst": 0.0,
  "skuPrefix": "SFG",
  "description": "Manage Semi-Finished Good inventory",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

## Verification Steps

Agar aapko verify karna hai ki "Bag" kaha se aa raha hai:

1. **Firebase Console Check:**
   ```
   Firestore → product_types collection → 
   Find document where name = "Semi-Finished Good" →
   Check displayUnit field
   ```

2. **Local Database Check:**
   ```dart
   final types = await masterDataService.getProductTypes();
   final semiType = types.firstWhere((t) => t.name == "Semi-Finished Good");
   print(semiType.displayUnit); // Should print "Bag"
   ```

3. **Product Check:**
   ```dart
   final product = await productsService.getProductById("gita_id");
   print(product.itemType.value); // Should be "Semi-Finished Good"
   print(product.baseUnit); // Fallback unit
   ```

## Architecture Notes

- **Stock Updates:** Sirf InventoryService ke through (Architecture Lock)
- **Display Unit Priority:** `displayUnit` > `baseUnit`
- **Data Source:** Firebase Firestore (master) → Isar (local cache)
- **Sync:** Offline-first architecture with sync queue

## Related Files for Modification

Agar aapko display unit change karna hai:

1. **Firebase:** Update `product_types` collection
2. **Service:** `lib/services/master_data_service.dart` - `updateProductType()`
3. **UI:** `lib/screens/production/production_stock_screen.dart` - `_getDisplayUnit()`
