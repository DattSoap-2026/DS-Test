# Material Issue Screen - Visual Implementation Guide

## Screen Flow

```
┌─────────────────────────────────────────────────────────────┐
│  ← Issue Materials                                    🔄    │
│  Transfer stock to department                               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  STEP 1 — SELECT DEPARTMENT                                 │
│  ┌──────────┐ ┌──────────┐ ┌────────────────┐ ┌──────────┐│
│  │Sona Bhatti│ │Gita Bhatti│ │Sona Production │ │ Packing  ││
│  └──────────┘ └──────────┘ └────────────────┘ └──────────┘│
│  ┌──────────────┐ ┌──────────────┐ ┌─────────────────────┐│
│  │Gita Production│ │   Packing    │ │ ⊕ Add Dept.        ││
│  └──────────────┘ └──────────────┘ └─────────────────────┘│
│                                                              │
│  STEP 2 — ADD MATERIALS                                     │
│  Issuing to: Sona Production                                │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐│
│  │ 🔍  Search material...                    ▼            ││
│  │     [All] [Raw Material] [Packing]                     ││
│  └────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────┐
│  │ ⊕ Add Material                                          │
│  └─────────────────────────────────────────────────────────┘
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐
│  │ PRODUCT NAME    │  QUANTITY  │   STOCK   │   ACTION    ││
│  ├─────────────────┼────────────┼───────────┼─────────────┤│
│  │ SILICATE        │ [  ] KG    │ 95000.0 KG│     🗑️      ││
│  │ COCONUT OIL     │ [  ] LTR   │  1200.5 LTR│    🗑️      ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
│  ℹ️ 2 material(s) · To: Sona Production                     │
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐
│  │         ✓ CONFIRM MATERIAL ISSUE                        │
│  └─────────────────────────────────────────────────────────┘
└─────────────────────────────────────────────────────────────┘
```

## Feature Highlights

### 1. Add Material Dialog
```
┌──────────────────────────────────┐
│  Add Raw Material                │
├──────────────────────────────────┤
│  ┌────────────────────────────┐  │
│  │ 📦 Coconut Oil             │  │
│  │    Material Name           │  │
│  └────────────────────────────┘  │
│                                   │
│  ┌────────────────────────────┐  │
│  │ 📏 LTR                     │  │
│  │    Unit                    │  │
│  └────────────────────────────┘  │
│                                   │
│  [Cancel]          [Add]          │
└──────────────────────────────────┘
```

### 2. Stock Validation Feedback

**Success (Green)**
```
┌────────────────────────────────────┐
│ ✓ Silicate added to cart           │
└────────────────────────────────────┘
```

**Warning (Yellow)**
```
┌────────────────────────────────────┐
│ ⚠ Silicate is already in the cart  │
└────────────────────────────────────┘
```

**Error (Red)**
```
┌────────────────────────────────────────────────────────┐
│ ✗ Quantity exceeds available stock (95000.0 KG)       │
└────────────────────────────────────────────────────────┘
```

### 3. Autocomplete Dropdown
```
┌─────────────────────────────────────────────┐
│ 🔍 sil                                      │
└─────────────────────────────────────────────┘
  ┌───────────────────────────────────────────┐
  │ 📦 Silicate                               │
  │    Raw Material | 📊 95000.0 KG          │
  ├───────────────────────────────────────────┤
  │ 📦 Silicon Oil                            │
  │    Oils & Liquids | 📊 450.5 LTR         │
  └───────────────────────────────────────────┘
```

## Interaction Flow

### Adding Existing Material
```
1. User types in search → "silicate"
2. Dropdown shows matching products with stock
3. User clicks on "Silicate"
4. ✓ Success message: "Silicate added to cart"
5. Material appears in table with stock info
```

### Adding Custom Material
```
1. User clicks "Add Material" button
2. Dialog opens
3. User enters: Name = "Coconut Oil", Unit = "LTR"
4. User clicks "Add"
5. ✓ Success message: "Coconut Oil added to cart"
6. Custom material appears in table (no stock shown)
```

### Entering Quantity
```
1. User clicks quantity field
2. Types "100"
3. System validates against stock (95000.0 KG)
4. ✓ Valid - no error
5. User types "100000"
6. ✗ Error: "Quantity exceeds available stock"
```

### Submitting Issue
```
1. User reviews cart (2 materials)
2. Clicks "CONFIRM MATERIAL ISSUE"
3. System validates:
   - Department selected? ✓
   - Items in cart? ✓
   - All quantities > 0? ✓
   - Stock sufficient? ✓
4. ✓ Success: "2 material(s) issued to Sona Production"
5. Screen closes, returns to previous page
```

## Validation Rules Visualization

```
┌─────────────────────────────────────────────────────────┐
│  Validation Checkpoint                                  │
├─────────────────────────────────────────────────────────┤
│  1. Department Selected?                                │
│     ✗ → "Please select a department" (Yellow)          │
│     ✓ → Continue                                        │
│                                                          │
│  2. Cart Has Items?                                     │
│     ✗ → "Please add at least one item" (Yellow)        │
│     ✓ → Continue                                        │
│                                                          │
│  3. All Quantities > 0?                                 │
│     ✗ → "Please enter valid quantities" (Red)          │
│     ✓ → Continue                                        │
│                                                          │
│  4. Stock Sufficient? (for non-custom items)            │
│     ✗ → "Item: Quantity exceeds stock" (Red)           │
│     ✓ → Continue                                        │
│                                                          │
│  5. Submit to Backend                                   │
│     ✗ → Show error dialog                               │
│     ✓ → Success message + Close screen                  │
└─────────────────────────────────────────────────────────┘
```

## Color Coding System

```
🟢 GREEN (Success)
   - Stock available badges
   - Success confirmations
   - Valid operations
   
🟡 YELLOW (Warning)
   - Missing selections
   - Empty cart warnings
   - Duplicate items
   
🔴 RED (Error)
   - Validation failures
   - Insufficient stock
   - Out of stock items
   
🔵 BLUE (Primary)
   - Selected department
   - Active filters
   - Primary buttons
```

## Responsive Behavior

### Desktop/Tablet
- Full width search bar
- Side-by-side layout for filters
- Wide table with all columns visible
- Larger touch targets

### Mobile
- Stacked layout
- Scrollable filter chips
- Responsive table (may scroll horizontally)
- 44x44px minimum touch targets maintained

## Keyboard Navigation

```
Tab Order:
1. Department chips
2. Search field
3. Add Material button
4. Filter chips
5. Quantity inputs (in order)
6. Remove buttons
7. Confirm button

Shortcuts:
- Enter in search → Add first result
- Enter in quantity → Move to next field
- Esc → Close dialogs
```

## Accessibility Features

- ✅ Semantic labels for screen readers
- ✅ Color + text for all feedback
- ✅ Keyboard navigation support
- ✅ Minimum 44x44px touch targets
- ✅ High contrast text
- ✅ Clear focus indicators

---

**Visual Guide Version**: 1.0
**Last Updated**: January 2025
