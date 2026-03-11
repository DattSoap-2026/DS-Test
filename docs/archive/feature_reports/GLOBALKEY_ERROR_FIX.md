# DUPLICATE GLOBALKEY ERROR - FIXED

**Date**: 02 Mar 2026, 20:15
**Errors**: 2 (Duplicate GlobalKey + Cascade Error)
**Status**:  **BOTH FIXED**

---

##  ROOT CAUSE ANALYSIS

### Error 1: Duplicate GlobalKey
```
[GlobalKey#6bfc8] specified multiple times in widget tree
```

**Cause**: Widget being created multiple times, same GlobalKey instance appears twice

**Location**: `cutting_batch_entry_screen.dart:27`
```dart
final _formKey = GlobalKey<FormState>();
```

**Why**: When widget rebuilds/navigates, new instance created but old one still in tree

---

### Error 2: Build Scheduled During Frame (CASCADE)
```
setState() called from layout or paint callback
```

**Cause**: Error handler itself calls `setState()` during build phase

**Location**: `main.dart:144`
```dart
FlutterError.onError = (details) {
  GlobalNotificationService.instance.showWarning(...); //  Calls setState
};
```

**Chain Reaction**:
```
1. Duplicate GlobalKey error occurs

2. FlutterError.onError triggered

3. showWarning() calls setState()

4. setState() during build  Second error

5. Second error triggers handler again

6. Infinite loop of errors
```

---

##  SOLUTIONS APPLIED

### Fix 1: Static GlobalKey

**File**: `cutting_batch_entry_screen.dart`

```dart
// Before
final _formKey = GlobalKey<FormState>();

// After
static final _formKey = GlobalKey<FormState>();
```

**Why This Works**:
- `static` = One instance shared across all widget instances
- No duplicate keys even if widget recreated
- Safe for forms (form state is per-widget anyway)

---

### Fix 2: Post-Frame Callback

**File**: `main.dart`

```dart
// Before
FlutterError.onError = (details) {
  GlobalNotificationService.instance.showWarning(...); // Immediate setState
};

// After
FlutterError.onError = (details) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    GlobalNotificationService.instance.showWarning(...); // Deferred
  });
};
```

**Why This Works**:
- `addPostFrameCallback` = Wait until frame complete
- No setState during build
- Error shown after frame finishes
- No cascade errors

---

##  ERROR FLOW

### Before Fix:
```
User opens screen

Widget created (GlobalKey #1)

Navigation/rebuild

Widget created again (GlobalKey #1 duplicate)

ERROR: Duplicate GlobalKey

Error handler calls setState()

ERROR: Build scheduled during frame

Error handler calls setState() again

ERROR: Build scheduled during frame

[Infinite loop]
```

### After Fix:
```
User opens screen

Widget created (static GlobalKey)

Navigation/rebuild

Widget reuses same static GlobalKey

No errors
```

---

##  KEY LEARNINGS

### 1. GlobalKey Best Practices

**Use `static` when**:
- Form keys in StatefulWidget
- Keys that identify widget type, not instance
- Keys used for navigation/routing

**Don't use `static` when**:
- Need unique key per widget instance
- Multiple instances must coexist
- Key identifies specific data item

### 2. Error Handler Rules

**Never in error handlers**:
-  `setState()`
-  `showDialog()`
-  `showSnackBar()`
-  Any UI updates

**Always use**:
-  `addPostFrameCallback()`
-  `Future.microtask()`
-  `scheduleMicrotask()`

### 3. Cascade Error Prevention

```dart
//  BAD - Can cause cascade
FlutterError.onError = (details) {
  showDialog(...); // setState during error
};

//  GOOD - Deferred
FlutterError.onError = (details) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(...);
  });
};
```

---

##  VERIFICATION

- [x] Static GlobalKey applied
- [x] Post-frame callbacks added
- [x] Flutter analyze: 0 issues
- [x] No duplicate key errors
- [x] No cascade errors
- [x] Error notifications still work

---

##  FILES MODIFIED

1. `cutting_batch_entry_screen.dart`
   - Line 27: Made _formKey static

2. `main.dart`
   - Line 138-150: Wrapped showWarning in addPostFrameCallback
   - Line 151-162: Wrapped showWarning in addPostFrameCallback

---

**Status**:  **BOTH ERRORS FIXED**
**Impact**: No more error loops, clean error handling
**Ready**: Production
