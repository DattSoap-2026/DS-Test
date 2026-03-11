# Dealer Dispatch Default Discount Issue - Technical Audit

## समस्या का विवरण (Problem Description)

जब dealer को dispatch करते हैं, तो finished goods में जो default discount है वो automatically add नहीं हो रहा है।

**Screenshot Analysis:**
- GOPI MALAIBAR 120G: ₹78 rate, 5 qty = ₹390 total
- GOPI WHITE 175G: ₹210 rate, 5 qty = ₹1050 total
- Subtotal (Gross): ₹3158.50
- **Product Discount: ₹0** ← यहाँ problem है
- Additional Discount: 0%
- Grand Total: ₹3158.50

## Technical Root Cause Analysis

### 1. **Product Model में Default Discount Field मौजूद है**

**File:** `lib/models/types/product_types.dart`

```dart
class Product {
  final double? defaultDiscount;  // ✅ Field exists
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      defaultDiscount: json['defaultDiscount']?.toDouble(),  // ✅ Parsed correctly
      // ...
    );
  }
}
```

**Status:** ✅ Model level पर कोई issue नहीं है।

---

### 2. **Cart Item में Discount Field है लेकिन Default Value नहीं ली जा रही**

**File:** `lib/screens/dispatch/dealer_dispatch_screen.dart`

**Problem Location - Line ~1050:**

```dart
void _addToCart(Product product) {
  final existingIndex = _cart.indexWhere(
    (item) => item.productId == product.id && !item.isFree,
  );
  if (existingIndex != -1) {
    _updateCartItemQty(existingIndex, _cart[existingIndex].quantity + 1);
  } else {
    setState(() {
      _cart.add(
        CartItem(
          productId: product.id,
          name: product.name,
          quantity: 0,
          price: product.price,
          discount: product.defaultDiscount ?? 0,  // ✅ यहाँ discount लिया जा रहा है
          baseUnit: product.baseUnit,
          stock: product.stock.toInt(),
          salesmanStock: null,
        ),
      );
      _applySchemes();
    });
  }
}
```

**Status:** ✅ Cart में add करते समय discount properly set हो रहा है।

---

### 3. **🔴 CRITICAL BUG: Discount Calculation में Item-Level Discount Use नहीं हो रहा**

**File:** `lib/screens/dispatch/dealer_dispatch_screen.dart`

**Problem Location - Line ~1150:**

```dart
double get _itemLevelDiscounts {
  double total = 0;
  for (final item in _cart) {
    if (item.isFree) continue;
    final itemSubtotal = item.price * item.quantity;
    final itemDiscount = itemSubtotal * (item.discount / 100);  // ✅ Calculation correct
    total += itemDiscount;
  }
  return total;
}
```

**Status:** ✅ Calculation logic सही है।

---

### 4. **🔴 ROOT CAUSE: CartItem Update करते समय Discount Lost हो रहा है**

**Problem Location - Line ~1200:**

```dart
CartItem _updateCartItem(CartItem item, int newQty) {
  return CartItem(
    productId: item.productId,
    name: item.name,
    quantity: newQty,
    price: item.price,
    baseUnit: item.baseUnit,
    stock: item.stock,
    isFree: item.isFree,
    schemeName: item.schemeName,
    // ❌ MISSING: discount field नहीं pass किया जा रहा!
  );
}
```

**Impact:**
- जब भी quantity update होती है, discount field reset हो जाता है
- Initial add में discount था, लेकिन quantity change पर lost हो गया

---

### 5. **Route Order Prefill में भी Discount Missing है**

**Problem Location - Line ~450:**

```dart
List<CartItem> _buildCartItemsFromPayload(RouteOrderDispatchPayload payload) {
  final mergedByProductId = <String, CartItem>{};
  for (final orderItem in payload.items) {
    // ...
    mergedByProductId[productId] = CartItem(
      productId: productId,
      name: orderItem.name.trim().isNotEmpty ? orderItem.name.trim() : (product?.name ?? 'Product'),
      quantity: mergedQty,
      price: price,
      baseUnit: orderItem.baseUnit.trim().isNotEmpty ? orderItem.baseUnit : (product?.baseUnit ?? 'Unit'),
      stock: product?.stock.toInt() ?? 0,
      secondaryPrice: product?.secondaryPrice,
      conversionFactor: product?.conversionFactor,
      secondaryUnit: product?.secondaryUnit,
      // ❌ MISSING: discount field नहीं add किया गया
    );
  }
  return mergedByProductId.values.toList();
}
```

---

## Impact Analysis

### Financial Impact
1. **Revenue Loss:** Dealers को expected discount नहीं मिल रहा
2. **Pricing Inconsistency:** Manual sales vs dispatch में price difference
3. **Customer Dissatisfaction:** Dealers को promised discount नहीं मिलने से trust issue

### Operational Impact
1. **Manual Correction Required:** हर dispatch के बाद manual adjustment करनी पड़ती है
2. **Accounting Mismatch:** Books में discount entry manually करनी पड़ती है
3. **Time Wastage:** Dispatch process slow हो जाती है

---

## Solution Implementation

### Fix 1: Update CartItem Creation to Preserve Discount

**File:** `lib/screens/dispatch/dealer_dispatch_screen.dart`

**Location:** Line ~1200

```dart
CartItem _updateCartItem(CartItem item, int newQty) {
  return CartItem(
    productId: item.productId,
    name: item.name,
    quantity: newQty,
    price: item.price,
    discount: item.discount,  // ✅ ADD THIS LINE
    baseUnit: item.baseUnit,
    stock: item.stock,
    isFree: item.isFree,
    schemeName: item.schemeName,
    secondaryPrice: item.secondaryPrice,  // Also preserve other fields
    conversionFactor: item.conversionFactor,
    secondaryUnit: item.secondaryUnit,
  );
}
```

---

### Fix 2: Add Discount in Route Order Prefill

**File:** `lib/screens/dispatch/dealer_dispatch_screen.dart`

**Location:** Line ~450

```dart
List<CartItem> _buildCartItemsFromPayload(RouteOrderDispatchPayload payload) {
  final mergedByProductId = <String, CartItem>{};
  for (final orderItem in payload.items) {
    final productId = orderItem.productId.trim();
    if (productId.isEmpty || orderItem.qty <= 0) continue;

    Product? product;
    for (final candidate in _allProducts) {
      if (candidate.id == productId) {
        product = candidate;
        break;
      }
    }

    final existing = mergedByProductId[productId];
    final mergedQty = (existing?.quantity ?? 0) + orderItem.qty;
    final price = orderItem.price > 0 ? orderItem.price : (product?.price ?? 0.0);

    mergedByProductId[productId] = CartItem(
      productId: productId,
      name: orderItem.name.trim().isNotEmpty ? orderItem.name.trim() : (product?.name ?? 'Product'),
      quantity: mergedQty,
      price: price,
      discount: product?.defaultDiscount ?? 0,  // ✅ ADD THIS LINE
      baseUnit: orderItem.baseUnit.trim().isNotEmpty ? orderItem.baseUnit : (product?.baseUnit ?? 'Unit'),
      stock: product?.stock.toInt() ?? 0,
      secondaryPrice: product?.secondaryPrice,
      conversionFactor: product?.conversionFactor,
      secondaryUnit: product?.secondaryUnit,
    );
  }
  return mergedByProductId.values.toList();
}
```

---

### Fix 3: Ensure Discount Preserved in Scheme Application

**File:** `lib/screens/dispatch/dealer_dispatch_screen.dart`

**Location:** Line ~1100

```dart
void _applySchemes() {
  // Remove existing free items
  _cart.removeWhere((item) => item.isFree);

  if (_allProducts.isEmpty) {
    return;
  }

  List<CartItem> newFreeItems = [];

  // Group paid items by product ID
  Map<String, double> productQuantities = {};
  for (var item in _cart) {
    if (!item.isFree) {
      productQuantities[item.productId] = (productQuantities[item.productId] ?? 0) + item.quantity;
    }
  }

  // Check schemes
  for (var scheme in _allSchemes) {
    final buyQty = productQuantities[scheme.buyProductId];
    if (buyQty != null && buyQty >= scheme.buyQuantity) {
      final timesQualified = (buyQty / scheme.buyQuantity).floor();
      final freeQty = timesQualified * scheme.getQuantity;

      final freeProduct = _allProducts.firstWhere(
        (p) => p.id == scheme.getProductId,
        orElse: () => _allProducts.first,
      );

      if (freeQty > 0) {
        newFreeItems.add(
          CartItem(
            productId: freeProduct.id,
            name: freeProduct.name,
            quantity: freeQty.toInt(),
            price: 0,
            discount: 0,  // ✅ Explicitly set for free items
            isFree: true,
            baseUnit: freeProduct.baseUnit,
            stock: 9999,
            schemeName: scheme.name,
          ),
        );
      }
    }
  }

  setState(() {
    _cart.addAll(newFreeItems);
  });
}
```

---

## Testing Checklist

### Test Case 1: New Product Addition
- [ ] Add product with defaultDiscount = 5%
- [ ] Verify discount shows in cart
- [ ] Verify "PRODUCT DISCOUNT" row appears in summary
- [ ] Verify calculation: Subtotal - Product Discount = correct amount

### Test Case 2: Quantity Update
- [ ] Add product with discount
- [ ] Change quantity using input field
- [ ] Verify discount percentage remains same
- [ ] Verify discount amount recalculates correctly

### Test Case 3: Route Order Prefill
- [ ] Create route order with products having default discount
- [ ] Open dealer dispatch with route order prefill
- [ ] Verify discount is applied to prefilled items
- [ ] Verify total calculation includes discount

### Test Case 4: Scheme Application
- [ ] Add products that trigger scheme
- [ ] Verify free items added
- [ ] Verify paid items retain their discount
- [ ] Verify total calculation correct

### Test Case 5: Multiple Products
- [ ] Add Product A (5% discount)
- [ ] Add Product B (8% discount)
- [ ] Add Product C (no discount)
- [ ] Verify individual discounts calculated correctly
- [ ] Verify total discount = sum of all item discounts

---

## Verification Steps

### Before Fix:
```
GOPI MALAIBAR 120G: ₹78 × 5 = ₹390
GOPI WHITE 175G: ₹210 × 5 = ₹1050
Subtotal (Gross): ₹3158.50
Product Discount: ₹0  ❌
Grand Total: ₹3158.50
```

### After Fix (Assuming 5% default discount on both):
```
GOPI MALAIBAR 120G: ₹78 × 5 = ₹390
GOPI WHITE 175G: ₹210 × 5 = ₹1050
Subtotal (Gross): ₹3158.50
Product Discount: ₹157.93 (5% of ₹3158.50)  ✅
Grand Total: ₹3000.57
```

---

## Database Verification

### Check Product Default Discounts:
```dart
// In Firebase Console or using query
products
  .where('type', '==', 'FINISHED')
  .where('status', '==', 'active')
  .get()
  .then((snapshot) => {
    snapshot.docs.forEach((doc) => {
      print('${doc.data()['name']}: ${doc.data()['defaultDiscount']}%');
    });
  });
```

### Expected Output:
```
GOPI MALAIBAR 120G X10 X10 PC: 5%
GOPI WHITE 175G X 20: 8%
...
```

---

## Related Files to Review

1. **CartItem Model:** Check if discount field exists
   - Location: `lib/models/types/sales_types.dart` (likely)
   
2. **Sales Service:** Verify discount is saved to database
   - Location: `lib/services/sales_service.dart`
   
3. **Invoice Generation:** Ensure discount shows in PDF
   - Location: `lib/utils/pdf_generator.dart`

---

## Priority: 🔴 CRITICAL

**Reason:**
- Direct financial impact
- Affects dealer relationships
- Creates accounting discrepancies
- Simple fix with high business value

**Estimated Fix Time:** 30 minutes
**Testing Time:** 1 hour
**Total Resolution Time:** 1.5 hours

---

## Conclusion

**Root Cause:** CartItem update method में discount field preserve नहीं हो रहा था।

**Solution:** तीन जगह fix करना है:
1. `_updateCartItem` method में discount field add करें
2. Route order prefill में product.defaultDiscount use करें  
3. Scheme application में discount preserve करें

**Business Impact:** Fix के बाद dealers को automatically correct discount मिलेगा, manual adjustment की जरूरत नहीं पड़ेगी।
