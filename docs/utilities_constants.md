# Utilities & Constants

**Version:** 2.7  
**Last Updated:** March 2026

---

## Overview

Common utilities, helpers, and constants used across the DattSoap ERP application.

---

## Constants

### App Constants
**File:** `lib/constants/app_constants.dart`

```dart
// App Info
static const String appName = 'DattSoap ERP';
static const String appVersion = '2.7';

// Pagination
static const int defaultPageSize = 50;
static const int maxPageSize = 100;

// Timeouts
static const Duration networkTimeout = Duration(seconds: 30);
static const Duration syncInterval = Duration(minutes: 5);

// Validation
static const double minStockLevel = 0.0;
static const double maxDiscountPercent = 100.0;
static const int minPasswordLength = 6;
```

### Navigation Items
**File:** `lib/constants/nav_items.dart`

Role-based navigation configuration:
```dart
final List<NavItem> navItems = [
  NavItem(
    title: 'Production',
    icon: Icons.factory,
    route: '/dashboard/production',
    roles: [UserRole.admin, UserRole.productionSupervisor],
  ),
  // ... more items
];
```

### Theme Constants
**File:** `lib/core/theme/app_colors.dart`

```dart
// Primary Colors
static const Color primaryLight = Color(0xFF4F5BFF);
static const Color primaryDark = Color(0xFF6D7CFF);

// No pure black/white (eye safety)
static const Color surfaceLight = Color(0xFFFAFAFA);
static const Color surfaceDark = Color(0xFF1A1A1A);
```

---

## Utilities

### Date Helpers
**File:** `lib/utils/date_helpers.dart`

```dart
// Format date for display
String formatDate(DateTime date) => DateFormat('dd-MMM-yyyy').format(date);

// Format date for API
String formatDateApi(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

// Get date range
DateTimeRange getMonthRange(DateTime date);
DateTimeRange getWeekRange(DateTime date);
```

### Number Helpers
**File:** `lib/utils/number_helpers.dart`

```dart
// Format currency
String formatCurrency(double amount) => '₹${amount.toStringAsFixed(2)}';

// Format weight
String formatWeight(double kg) => '${kg.toStringAsFixed(2)} kg';

// Round to decimal places
double roundTo(double value, int places);
```

### Validation Helpers
**File:** `lib/utils/validators.dart`

```dart
// Email validation
String? validateEmail(String? value);

// Phone validation
String? validatePhone(String? value);

// Required field
String? validateRequired(String? value, String fieldName);

// Number range
String? validateRange(double? value, double min, double max);
```

### Access Guard
**File:** `lib/utils/access_guard.dart`

```dart
// Check bhatti access
static void checkBhattiAccess(BuildContext context);

// Check production access
static void checkProductionAccess(BuildContext context);

// Check admin access
static void checkAdminAccess(BuildContext context);
```

### String Helpers
**File:** `lib/utils/string_helpers.dart`

```dart
// Capitalize first letter
String capitalize(String text);

// Truncate with ellipsis
String truncate(String text, int maxLength);

// Generate ID
String generateId() => const Uuid().v4();
```

### Dialog Helpers
**File:** `lib/utils/dialog_helpers.dart`

```dart
// Show confirmation dialog
Future<bool> showConfirmDialog(BuildContext context, String message);

// Show error dialog
void showErrorDialog(BuildContext context, String message);

// Show success snackbar
void showSuccess(BuildContext context, String message);
```

---

## Enums

### User Roles
```dart
enum UserRole {
  admin,
  storeIncharge,
  productionSupervisor,
  bhattiSupervisor,
  salesman,
  fuelIncharge,
  driver,
}
```

### Product Types
```dart
enum ProductType {
  raw,
  semiFinished,
  finished,
}
```

### Shift Types
```dart
enum ShiftType {
  morning,
  evening,
  night,
}
```

### Sync Status
```dart
enum SyncStatus {
  pending,
  syncing,
  synced,
  failed,
}
```

---

## Extensions

### DateTime Extensions
```dart
extension DateTimeX on DateTime {
  bool isSameDay(DateTime other);
  DateTime get startOfDay;
  DateTime get endOfDay;
  String toApiFormat();
}
```

### String Extensions
```dart
extension StringX on String {
  bool get isValidEmail;
  bool get isValidPhone;
  String get capitalize;
}
```

### BuildContext Extensions
```dart
extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  void showSnackbar(String message);
}
```

---

## Usage Examples

### Date Formatting
```dart
final date = DateTime.now();
print(formatDate(date)); // "07-Mar-2026"
print(formatDateApi(date)); // "2026-03-07"
```

### Validation
```dart
final emailError = validateEmail('test@example.com');
final phoneError = validatePhone('1234567890');
```

### Access Control
```dart
@override
void initState() {
  super.initState();
  AccessGuard.checkProductionAccess(context);
}
```

### Dialog
```dart
final confirmed = await showConfirmDialog(
  context,
  'Delete this item?',
);
if (confirmed) {
  // Delete
}
```

---

## Best Practices

1. **Use constants** instead of magic numbers
2. **Reuse helpers** instead of duplicating logic
3. **Validate early** using validators
4. **Check access** at screen initialization
5. **Format consistently** using helpers

---

## References

- [Architecture](architecture.md)
- [Security & RBAC](security_rbac.md)
- [Theme System](../README.md#theme-system-neutral-future)
