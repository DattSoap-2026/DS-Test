# Quick Reference - Production Cutting Module

##  Quick Start

### Files Overview
```
lib/
 models/types/
    cutting_types.dart           Data models & types
 services/
    cutting_batch_service.dart   Business logic & DB operations
 screens/production/
    cutting_batch_entry_screen.dart            Entry form
    production_dashboard_consolidated_screen.dart  Dashboard
 screens/reports/
    cutting_yield_report_screen.dart     Yield analysis
    waste_analysis_report_screen.dart    Waste tracking
    reports_module_screen.dart           Reports hub
 routers/
     app_router.dart (updated)   Navigation config
```

---

##  Database Schema

### Firestore Collection: `cutting_batches`
```json
{
  "id": "doc_id",
  "batchNumber": "CT250122-001",
  "batchGeneId": "sha256_hash",
  "batchDate": "2025-01-22",
  "shift": "morning",
  "operatorId": "user_id",
  "operatorName": "John Doe",
  "supervisorId": "supervisor_id",
  "supervisorName": "Supervisor Name",
  "semiFinishedProductId": "product_id",
  "semiFinishedProductName": "Product Name",
  "totalBatchWeightKg": 50.5,
  "boxesCount": 10,
  "avgBoxWeightKg": 5.05,
  "finishedGoodId": "product_id",
  "finishedGoodName": "Finished Product",
  "standardWeightGm": 200,
  "actualAvgWeightGm": 198,
  "tolerancePercent": 5,
  "unitsProduced": 252,
  "cuttingWasteKg": 0.5,
  "wasteType": "scrap",
  "wasteRemark": "Optional note",
  "weightValidation": {
    "isValid": true,
    "standardWeightGm": 200,
    "minimumWeightGm": 190,
    "actualWeightGm": 198,
    "difference": -2,
    "message": "Valid"
  },
  "weightBalance": {
    "inputKg": 50.5,
    "outputKg": 50.296,
    "wasteKg": 0.5,
    "differenceKg": -0.296,
    "differencePercent": 0.59,
    "isValid": false
  },
  "stage": "completed",
  "syncStatus": "synced",
  "createdAt": "2025-01-22T08:30:00Z",
  "updatedAt": "2025-01-22T08:35:00Z",
  "completedAt": "2025-01-22T08:35:00Z"
}
```

---

##  Key Functions

### CuttingBatchService

#### Create Batch
```dart
final service = CuttingBatchService(firebaseServices);
final success = await service.createCuttingBatch(
  batchDate: DateTime.now(),
  semiFinishedProductId: 'product_id',
  finishedGoodId: 'product_id',
  totalBatchWeightKg: 50.5,
  standardWeightGm: 200,
  actualAvgWeightGm: 198,
  tolerancePercent: 5,
  unitsProduced: 252,
  cuttingWasteKg: 0.5,
  wasteType: WasteType.scrap,
  shift: ShiftType.morning,
  operatorId: 'op_id',
  operatorName: 'Operator Name',
  supervisorId: 'sup_id',
  supervisorName: 'Supervisor Name',
  departmentId: 'Bhatti',
  departmentName: 'Bhatti Department',
  boxesCount: 10,
  wasteRemark: 'Optional note',
);
```

#### Get Daily Summary
```dart
final summary = await service.getDailySummary(
  date: DateTime.now(),
  semiFinishedProductId: 'product_id',
);
// Returns: DailyProductionSummary with shift-wise metrics
```

#### Get Yield Report
```dart
final report = await service.getYieldReport(
  startDate: DateTime(2025, 1, 1),
  endDate: DateTime(2025, 1, 31),
  finishedGoodId: 'product_id',
);
// Returns: List<CuttingYieldReport> with metrics
```

#### Get Waste Analysis
```dart
final waste = await service.getWasteAnalysis(
  startDate: DateTime(2025, 1, 1),
  endDate: DateTime(2025, 1, 31),
  semiFinishedProductId: 'product_id',
);
// Returns: WasteAnalysisReport with breakdown
```

---

##  Navigation

### Routes Available
```dart
// Entry Screen
context.go('/dashboard/production/cutting/entry');

// Reports
context.go('/dashboard/reports/cutting-yield');
context.go('/dashboard/reports/waste-analysis');

// Dashboard
context.go('/dashboard/production');
```

### Navigation from Code
```dart
// Go to entry screen
GoRouter.of(context).go('/dashboard/production/cutting/entry');

// Push to entry screen
GoRouter.of(context).push('/dashboard/production/cutting/entry');
```

---

##  Validation Rules

### Weight Validation
```dart
final validation = service.validateWeight(
  actualWeightGm: 198,
  standardWeightGm: 200,
  tolerancePercent: 5,
);

// validation.isValid: true
// validation.minimumWeightGm: 190 (standard - tolerance%)
// validation.message: "Valid"
```

**Rule:** `actualWeight >= (standard - tolerance%)`

### Weight Balance
```dart
final balance = service.calculateWeightBalance(
  inputKg: 50.5,
  outputKg: 50.296,
  wasteKg: 0.5,
);

// balance['differencePercent']: 0.59%
// balance['isValid']: false (> 0.5%)
// Shows warning: "Weight difference > 0.5%"
```

**Rule:** `|input - (output + waste)| <= 0.5%`

---

##  Form Entry Fields

### Required Fields
- [ ] Date
- [ ] Shift (Morning/Evening/Night)
- [ ] Department
- [ ] Operator
- [ ] Semi-Finished Product
- [ ] Total Batch Weight (kg)
- [ ] Finished Product
- [ ] Actual Average Weight (gm)
- [ ] Units Produced
- [ ] Cutting Waste (kg)
- [ ] Waste Type

### Optional Fields
- [ ] Boxes Count
- [ ] Waste Remark

---

##  Reports Available

### Cutting Yield Report
**Path:** `/dashboard/reports/cutting-yield`

**Metrics:**
- Total Batches
- Total Input (kg)
- Finished Units Produced
- Total Waste (kg)
- Yield % = (Output / Input)  100
- Avg Weight Difference %

**Filters:**
- Product Selection
- Date Range (Default: 30 days)

---

### Waste Analysis Report
**Path:** `/dashboard/reports/waste-analysis`

**Metrics:**
- Total Waste (kg)
- Waste % = (Waste / Input)  100
- Scrap Amount & %
- Reprocess Amount & %

**Filters:**
- Product Selection
- Date Range (Default: 30 days)

---

##  Access Control

### Role Permissions
```dart
// Check role
if (user.role == UserRole.productionSupervisor || 
    user.role == UserRole.admin) {
  // Can create batches
}

// Check from context
final user = context.watch<AuthProvider>().state.user;
final canEdit = user.role == UserRole.admin;
```

---

##  Stock Adjustment Example

### Before Batch Creation
```
Semi-Finished "Soap-A": 100 kg
Finished Product "Soap-A-Cut": 1000 units
```

### Create Batch (50 kg input, 250 units output, 0.5 kg waste)
```dart
await service.createCuttingBatch(
  semiFinishedProductId: 'semi-a',
  finishedGoodId: 'finished-a',
  totalBatchWeightKg: 50,
  unitsProduced: 250,
  cuttingWasteKg: 0.5,
  // ... other params
);
```

### After Batch Creation (Automatic)
```
Semi-Finished "Soap-A": 50 kg (100 - 50)
Finished Product "Soap-A-Cut": 1250 units (1000 + 250)
Waste Accumulated: 0.5 kg
```

---

##  Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Weight validation fails | Check if actual >= (standard - tolerance%) |
| Stock not adjusting | Verify semi-finished stock is sufficient |
| Report showing no data | Check date range and product filter |
| Null error on product | Ensure product exists in database |
| Access denied | Verify user role is supervisor or admin |

---

##  Testing Checklist

### Unit Tests
- [ ] validateWeight() with various inputs
- [ ] calculateWeightBalance() with edge cases
- [ ] generateBatchNumber() format validation
- [ ] generateBatchGeneId() uniqueness

### Integration Tests
- [ ] Create batch with valid data
- [ ] Create batch with invalid weight
- [ ] Verify stock adjustment transaction
- [ ] Verify audit log entry creation

### UI Tests
- [ ] Form validation on entry screen
- [ ] Weight validation real-time feedback
- [ ] Report generation on different date ranges
- [ ] Dashboard metric calculations

### E2E Tests
- [ ] Complete workflow: entry  dashboard  reports
- [ ] Offline sync functionality
- [ ] User role-based access control
- [ ] Multi-user concurrent batch creation

---

##  Useful Code Snippets

### Get Current User ID
```dart
import 'package:firebase_auth/firebase_auth.dart';

final userId = FirebaseAuth.instance.currentUser?.uid;
final userName = FirebaseAuth.instance.currentUser?.displayName;
```

### Get Products List
```dart
final service = ProductsService(firebaseServices);
final products = await service.getProducts(
  type: ProductTypeEnum.semiFinished,
);
```

### Format Date for Display
```dart
import 'package:intl/intl.dart';

final formatted = DateFormat('dd-MMM-yyyy').format(DateTime.now());
// Output: 22-Jan-2025
```

### Show Snackbar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Message'),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
  ),
);
```

---

##  Useful Links & Resources

- **Firestore Documentation:** https://firebase.google.com/docs/firestore
- **Flutter Provider:** https://pub.dev/packages/provider
- **Go Router:** https://pub.dev/packages/go_router
- **Firebase Auth:** https://firebase.google.com/docs/auth

---

##  Contact & Support

For issues or questions:
1. Check this reference guide
2. Review code comments in files
3. Check flutter analyze output for errors
4. Review test files for usage examples

---

**Last Updated:** January 22, 2025  
**Version:** 1.0.0  
**Status:**  Production Ready

