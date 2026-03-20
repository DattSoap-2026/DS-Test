# Product Discount Feature - Fix Complete

## Issue Summary
Product-level discount (DISC %) was not appearing in Dealer Dispatch and Customer Dispatch billing summaries, even though products had the discount percentage set in their catalog records.

## Root Cause
The `defaultDiscount` field was being stored in `ProductEntity` (Isar database) but was **NOT being mapped** to the `Product` domain model in the `toDomain()` method. This caused all products to have `defaultDiscount = null` when loaded into the dispatch screens.

## Fix Applied
**File**: `lib/data/local/entities/product_entity.dart`

**Change**: Added `defaultDiscount` field to the `toDomain()` method at line 423:

```dart
return Product(
  ...
  gstRate: gstRate,
  defaultDiscount: defaultDiscount,  // ← ADDED THIS LINE
  internalCost: internalCostValue,
  ...
);
```

## How It Works Now

### 1. Product Catalog
- Products have a "Default Discount (%)" field in the product management screen
- This is saved as `defaultDiscount` in the database
- Example: GITA 175G X10 has DISC % = 8%

### 2. Cart/Order Creation
When a product is added to cart in Dealer or Customer Dispatch:
```dart
CartItem(
  productId: product.id,
  name: product.name,
  quantity: 10,
  price: 109,
  discount: product.defaultDiscount ?? 0,  // ← Captures 8%
  ...
)
```

### 3. Billing Calculation
The `SaleCalculationEngine` calculates discounts in cascade:

```dart
// Step 1: Gross subtotal
grossSubtotal = 10 × ₹109 = ₹1090

// Step 2: Product discount (from product.defaultDiscount)
productDiscAmount = ₹1090 × 8% = ₹87.20
discountedSubtotal = ₹1090 - ₹87.20 = ₹1002.80

// Step 3: Additional discount (on discounted amount)
additionalDiscAmount = ₹1002.80 × 5% = ₹50.14

// Step 4: Special discount (on remaining amount)
afterAdditional = ₹1002.80 - ₹50.14 = ₹952.66
specialDiscAmount = ₹952.66 × 5% = ₹47.63

// Step 5: Grand Total
grandTotal = ₹952.66 - ₹47.63 = ₹905.03
```

### 4. UI Display
The billing summary now shows:

```
SUBTOTAL (GROSS)          ₹1090.00
PRODUCT DISCOUNT (8%)      -₹87.20
DISCOUNTED SUBTOTAL        ₹1002.80
ADDITIONAL DISCOUNT (5%)   -₹50.14
SPECIAL DISCOUNT (5%)      -₹47.63
GRAND TOTAL                ₹905.03
```

**Display Rules**:
- Row is shown ONLY if `productDiscAmount > 0`
- If all products have disc % = 0 → row is hidden
- If single product → shows "PRODUCT DISCOUNT (8%)"
- If multiple products with different disc % → shows "PRODUCT DISCOUNT" (no % in label)

## Verification Checklist

✅ Product disc % field found in Isar product schema (`defaultDiscount`)  
✅ Disc % carried into cart/order line item model (`CartItem.discount`)  
✅ Product discount calculated before additional/special disc  
✅ Additional and special disc recalculate on discounted amount  
✅ UI shows PRODUCT DISCOUNT row between subtotal and addl disc  
✅ Row hidden when disc % = 0  
✅ Same fix in both Dealer and Customer dispatch  
✅ `flutter analyze`: 0 errors  
✅ Existing Additional and Special discount unchanged  

## Files Modified
1. `lib/data/local/entities/product_entity.dart` - Added `defaultDiscount` to `toDomain()` method

## Files Already Correct (No Changes Needed)
- `lib/models/types/product_types.dart` - Product model has `defaultDiscount` field
- `lib/models/types/sales_types.dart` - CartItem/SaleItem have `discount` field
- `lib/domain/engines/sale_calculation_engine.dart` - Calculates product discount correctly
- `lib/screens/dispatch/dealer_dispatch_screen.dart` - UI displays product discount
- `lib/screens/sales/new_sale_screen.dart` - UI displays product discount
- `lib/screens/management/product_add_edit_screen.dart` - Has "Default Discount (%)" field

## Testing Instructions

### Test Case 1: Single Product with Discount
1. Go to Management > Products
2. Edit product "GITA 175G X10"
3. Set "Default Discount (%)" = 8
4. Save product
5. Go to Dealer Dispatch
6. Add GITA 175G X10, Qty = 10, Rate = ₹109
7. Set Additional Discount = 5%
8. Set Special Discount = 5%
9. Verify billing shows:
   - SUBTOTAL (GROSS): ₹1090.00
   - PRODUCT DISCOUNT (8%): -₹87.20
   - ADDITIONAL DISCOUNT (5%): -₹50.14
   - SPECIAL DISCOUNT (5%): -₹47.63
   - GRAND TOTAL: ₹905.03

### Test Case 2: Product with Zero Discount
1. Edit product, set "Default Discount (%)" = 0
2. Add to cart
3. Verify PRODUCT DISCOUNT row does NOT appear
4. Verify Additional and Special discounts calculate on gross subtotal

### Test Case 3: Multiple Products with Different Discounts
1. Product A: disc % = 5%
2. Product B: disc % = 10%
3. Add both to cart
4. Verify label shows "PRODUCT DISCOUNT" (no percentage)
5. Verify amount is sum of both line discounts

## Impact
- **Dealer Dispatch**: ✅ Fixed
- **Customer Dispatch**: ✅ Fixed
- **Existing Sales**: No impact (historical data unchanged)
- **Sync**: No impact (field already in schema)
- **Reports**: No impact (calculation engine unchanged)

## Notes
- The feature was already 95% implemented
- Only the entity-to-domain mapping was missing
- No database migration needed (field already exists)
- No UI changes needed (display logic already correct)
- No calculation changes needed (engine already correct)
