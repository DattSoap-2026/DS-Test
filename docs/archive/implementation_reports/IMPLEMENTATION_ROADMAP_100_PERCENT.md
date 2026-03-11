# DattSoap ERP - 100% Score Implementation Plan

**Current Score**: 92/100  
**Target Score**: 100/100  
**Gap**: 8 points  
**Timeline**: 2-3 days

---

## 📋 TASK BREAKDOWN

### TASK 1: Role-Based Screen Access Control ⭐ (+3 points)
**Priority**: CRITICAL  
**Effort**: 2-3 hours  
**Impact**: Security + UX

#### Subtasks:
- [x] 1.1: Add role extension methods
- [ ] 1.2: Protect Bhatti screens
- [ ] 1.3: Protect Production screens
- [ ] 1.4: Filter navigation menu
- [ ] 1.5: Test all roles

---

### TASK 2: Queue Item Management System ⭐ (+2 points)
**Priority**: HIGH  
**Effort**: 3-4 hours  
**Impact**: Operations

#### Subtasks:
- [ ] 2.1: Pre-sale stock validation
- [ ] 2.2: Queue item expiry logic
- [ ] 2.3: Admin dashboard for stuck items
- [ ] 2.4: Alert system for failures

---

### TASK 3: Windows Sync Safety ⭐ (+1 point)
**Priority**: MEDIUM  
**Effort**: 2 hours  
**Impact**: Data integrity on Windows

#### Subtasks:
- [ ] 3.1: Add mutex lock for Windows sales sync
- [ ] 3.2: Test concurrent sales on Windows
- [ ] 3.3: Add logging for race conditions

---

### TASK 4: Dashboard Role Separation ⭐ (+1 point)
**Priority**: MEDIUM  
**Effort**: 3-4 hours  
**Impact**: UX clarity

#### Subtasks:
- [ ] 4.1: Filter Bhatti Dashboard data
- [ ] 4.2: Filter Production Dashboard data
- [ ] 4.3: Update navigation routing
- [ ] 4.4: Test role-based dashboards

---

### TASK 5: Stock Visibility Filtering ⭐ (+0.5 points)
**Priority**: LOW  
**Effort**: 2 hours  
**Impact**: UX polish

#### Subtasks:
- [ ] 5.1: Add stock filtering by role
- [ ] 5.2: Update inventory screens
- [ ] 5.3: Test visibility rules

---

### TASK 6: Unit Tests ⭐ (+0.5 points)
**Priority**: LOW  
**Effort**: 4-6 hours  
**Impact**: Code quality

#### Subtasks:
- [ ] 6.1: Sales calculation tests
- [ ] 6.2: Stock validation tests
- [ ] 6.3: Role permission tests
- [ ] 6.4: Sync queue tests

---

## 🚀 IMPLEMENTATION ORDER

### Day 1: Critical Fixes (6 points)
```
Morning (4 hours):
✅ TASK 1: Role-Based Screen Access Control (+3)

Afternoon (4 hours):
✅ TASK 2: Queue Item Management System (+2)

Evening (2 hours):
✅ TASK 3: Windows Sync Safety (+1)
```

### Day 2: UX Improvements (2 points)
```
Morning (4 hours):
✅ TASK 4: Dashboard Role Separation (+1)

Afternoon (2 hours):
✅ TASK 5: Stock Visibility Filtering (+0.5)

Evening (2 hours):
✅ Testing & Bug Fixes (+0.5)
```

### Day 3: Quality & Polish
```
Morning (4 hours):
✅ TASK 6: Unit Tests (optional)

Afternoon (4 hours):
✅ Integration testing
✅ Documentation updates
✅ Final review
```

---

## 📝 DETAILED IMPLEMENTATION

### TASK 1: Role-Based Screen Access Control

#### File 1: `lib/models/types/user_types.dart`
```dart
extension UserRoleAccess on UserRole {
  // Bhatti Operations
  bool get canAccessBhatti {
    return this == UserRole.bhattiSupervisor ||
           this == UserRole.admin ||
           this == UserRole.owner ||
           this == UserRole.productionManager;
  }

  // Production/Cutting Operations
  bool get canAccessProduction {
    return this == UserRole.productionSupervisor ||
           this == UserRole.admin ||
           this == UserRole.owner ||
           this == UserRole.productionManager;
  }

  // Raw Materials
  bool get canAccessRawMaterials {
    return this == UserRole.bhattiSupervisor ||
           this == UserRole.storeIncharge ||
           this == UserRole.admin ||
           this == UserRole.owner;
  }

  // Finished Goods
  bool get canAccessFinishedGoods {
    return this == UserRole.productionSupervisor ||
           this == UserRole.dispatchManager ||
           this == UserRole.salesManager ||
           this == UserRole.salesman ||
           this == UserRole.admin ||
           this == UserRole.owner;
  }

  // Sales Operations
  bool get canAccessSales {
    return this == UserRole.salesman ||
           this == UserRole.salesManager ||
           this == UserRole.dealerManager ||
           this == UserRole.admin ||
           this == UserRole.owner;
  }

  // HR Operations
  bool get canAccessHR {
    return this == UserRole.admin || this == UserRole.owner;
  }

  // Accounting Operations
  bool get canAccessAccounting {
    return this == UserRole.accountant ||
           this == UserRole.admin ||
           this == UserRole.owner;
  }
}
```

#### File 2: `lib/utils/access_guard.dart` (NEW)
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth/auth_provider.dart';
import '../models/types/user_types.dart';
import 'ui_notifier.dart';

class AccessGuard {
  static void checkAccess(
    BuildContext context, {
    required bool Function(UserRole) hasAccess,
    required String deniedMessage,
  }) {
    final user = context.read<AuthProvider>().currentUser;
    
    if (user == null || !hasAccess(user.role)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pop();
          UINotifier.showError(deniedMessage);
        }
      });
    }
  }

  static void checkBhattiAccess(BuildContext context) {
    checkAccess(
      context,
      hasAccess: (role) => role.canAccessBhatti,
      deniedMessage: 'Access Denied: Bhatti operations only',
    );
  }

  static void checkProductionAccess(BuildContext context) {
    checkAccess(
      context,
      hasAccess: (role) => role.canAccessProduction,
      deniedMessage: 'Access Denied: Production operations only',
    );
  }

  static void checkSalesAccess(BuildContext context) {
    checkAccess(
      context,
      hasAccess: (role) => role.canAccessSales,
      deniedMessage: 'Access Denied: Sales operations only',
    );
  }

  static void checkHRAccess(BuildContext context) {
    checkAccess(
      context,
      hasAccess: (role) => role.canAccessHR,
      deniedMessage: 'Access Denied: HR operations only',
    );
  }

  static void checkAccountingAccess(BuildContext context) {
    checkAccess(
      context,
      hasAccess: (role) => role.canAccessAccounting,
      deniedMessage: 'Access Denied: Accounting operations only',
    );
  }
}
```

#### File 3: Update Bhatti Screens
```dart
// lib/screens/bhatti/bhatti_cooking_screen.dart
@override
void initState() {
  super.initState();
  AccessGuard.checkBhattiAccess(context);
  // ... rest of initState
}

// lib/screens/bhatti/bhatti_supervisor_screen.dart
@override
void initState() {
  super.initState();
  AccessGuard.checkBhattiAccess(context);
  // ... rest of initState
}

// lib/screens/bhatti/bhatti_batch_edit_screen.dart
@override
void initState() {
  super.initState();
  AccessGuard.checkBhattiAccess(context);
  // ... rest of initState
}
```

#### File 4: Update Production Screens
```dart
// lib/screens/production/cutting_batch_entry_screen.dart
@override
void initState() {
  super.initState();
  AccessGuard.checkProductionAccess(context);
  // ... rest of initState
}

// lib/screens/production/cutting_history_screen.dart
@override
void initState() {
  super.initState();
  AccessGuard.checkProductionAccess(context);
  // ... rest of initState
}

// lib/screens/production/production_dashboard_consolidated_screen.dart
@override
void initState() {
  super.initState();
  AccessGuard.checkProductionAccess(context);
  // ... rest of initState
}
```

#### File 5: Filter Navigation Menu
```dart
// lib/constants/nav_items.dart
List<NavItem> getNavItemsForRole(UserRole role) {
  final items = <NavItem>[];

  // Dashboard (All)
  items.add(NavItem(
    title: 'Dashboard',
    icon: Icons.dashboard,
    route: '/dashboard',
  ));

  // Bhatti Section
  if (role.canAccessBhatti) {
    items.add(NavItem(
      title: 'Bhatti',
      icon: Icons.local_fire_department,
      children: [
        NavItem(title: 'Bhatti Dashboard', route: '/bhatti'),
        NavItem(title: 'Create Batch', route: '/bhatti/cooking'),
        NavItem(title: 'Batch History', route: '/bhatti/supervisor'),
      ],
    ));
  }

  // Production Section
  if (role.canAccessProduction) {
    items.add(NavItem(
      title: 'Production',
      icon: Icons.factory,
      children: [
        NavItem(title: 'Production Dashboard', route: '/production'),
        NavItem(title: 'Cutting Entry', route: '/production/cutting'),
        NavItem(title: 'Cutting History', route: '/production/history'),
      ],
    ));
  }

  // Sales Section
  if (role.canAccessSales) {
    items.add(NavItem(
      title: 'Sales',
      icon: Icons.point_of_sale,
      children: [
        NavItem(title: 'New Sale', route: '/sales/new'),
        NavItem(title: 'Sales History', route: '/sales'),
        NavItem(title: 'Customers', route: '/customers'),
      ],
    ));
  }

  // HR Section
  if (role.canAccessHR) {
    items.add(NavItem(
      title: 'HR',
      icon: Icons.people,
      children: [
        NavItem(title: 'Employees', route: '/hr/employees'),
        NavItem(title: 'Attendance', route: '/hr/attendance'),
        NavItem(title: 'Payroll', route: '/hr/payroll'),
      ],
    ));
  }

  // Accounting Section
  if (role.canAccessAccounting) {
    items.add(NavItem(
      title: 'Accounting',
      icon: Icons.account_balance,
      children: [
        NavItem(title: 'Accounts', route: '/accounting/accounts'),
        NavItem(title: 'Vouchers', route: '/accounting/vouchers'),
      ],
    ));
  }

  return items;
}
```

---

### TASK 2: Queue Item Management System

#### File 1: `lib/services/queue_management_service.dart` (NEW)
```dart
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/alert_service.dart';
import 'package:flutter_app/data/local/entities/sync_queue_entity.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/models/types/alert_types.dart';
import 'package:flutter_app/utils/app_logger.dart';

class QueueManagementService {
  final DatabaseService _dbService;
  final AlertService _alertService;

  QueueManagementService(this._dbService, this._alertService);

  // Check for stuck items and create alerts
  Future<void> checkStuckItems() async {
    final now = DateTime.now();
    final stuckItems = await _dbService.syncQueue
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();

    final criticalItems = <SyncQueueEntity>[];
    
    for (final item in stuckItems) {
      final age = now.difference(item.createdAt);
      final retryCount = _getRetryCount(item);
      
      // Mark as stuck if > 7 days old OR > 20 retries
      if (age.inDays > 7 || retryCount > 20) {
        criticalItems.add(item);
      }
    }

    if (criticalItems.isNotEmpty) {
      await _createStuckItemAlert(criticalItems.length);
    }
  }

  // Get retry count from queue item metadata
  int _getRetryCount(SyncQueueEntity item) {
    try {
      final decoded = jsonDecode(item.dataJson);
      return decoded['_meta']?['retryCount'] ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // Create alert for admin
  Future<void> _createStuckItemAlert(int count) async {
    final alertId = 'stuck_queue_${DateTime.now().millisecondsSinceEpoch}';
    
    await _dbService.db.writeTxn(() async {
      await _dbService.alerts.put(
        AlertEntity()
          ..id = alertId
          ..alertId = alertId
          ..title = 'Sync Queue Issues'
          ..message = '$count items stuck in sync queue. Admin action required.'
          ..severity = AlertSeverity.high
          ..type = AlertType.syncIssue
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..isRead = false,
      );
    });

    AppLogger.warning('Created alert for $count stuck queue items', tag: 'Queue');
  }

  // Get stuck items for admin dashboard
  Future<List<Map<String, dynamic>>> getStuckItems() async {
    final now = DateTime.now();
    final stuckItems = await _dbService.syncQueue
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();

    final result = <Map<String, dynamic>>[];
    
    for (final item in stuckItems) {
      final age = now.difference(item.createdAt);
      final retryCount = _getRetryCount(item);
      
      if (age.inDays > 7 || retryCount > 20) {
        result.add({
          'id': item.id,
          'collection': item.collection,
          'action': item.action,
          'age_days': age.inDays,
          'retry_count': retryCount,
          'created_at': item.createdAt,
          'error': _getLastError(item),
        });
      }
    }

    return result;
  }

  String? _getLastError(SyncQueueEntity item) {
    try {
      final decoded = jsonDecode(item.dataJson);
      return decoded['_meta']?['lastError'];
    } catch (_) {
      return null;
    }
  }

  // Delete stuck item (admin action)
  Future<void> deleteStuckItem(String itemId) async {
    await _dbService.db.writeTxn(() async {
      final item = await _dbService.syncQueue.getById(itemId);
      if (item != null) {
        await _dbService.syncQueue.delete(item.isarId);
        AppLogger.info('Deleted stuck queue item: $itemId', tag: 'Queue');
      }
    });
  }
}
```

#### File 2: `lib/widgets/sales/pre_sale_stock_validator.dart` (NEW)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/models/types/user_types.dart';

class PreSaleStockValidator {
  final DatabaseService _dbService;

  PreSaleStockValidator(this._dbService);

  Future<bool> validateStock({
    required String salesmanId,
    required List<SaleItemForValidation> items,
    required BuildContext context,
  }) async {
    final user = await _dbService.users
        .filter()
        .idEqualTo(salesmanId)
        .findFirst();

    if (user == null) {
      _showError(context, 'User not found');
      return false;
    }

    final allocated = user.allocatedStockMap;
    final insufficientItems = <String>[];

    for (final item in items) {
      final stockItem = allocated[item.productId];
      final available = item.isFree
          ? (stockItem?.freeQuantity ?? 0.0)
          : (stockItem?.quantity ?? 0.0);

      if (available < item.quantity) {
        insufficientItems.add(
          '${item.name}: Available ${available.toStringAsFixed(1)}, '
          'Required ${item.quantity.toStringAsFixed(1)}',
        );
      }
    }

    if (insufficientItems.isNotEmpty) {
      _showInsufficientStockDialog(context, insufficientItems);
      return false;
    }

    return true;
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInsufficientStockDialog(
    BuildContext context,
    List<String> items,
  ) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insufficient Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You do not have enough allocated stock for:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('• $item'),
            )),
            const SizedBox(height: 12),
            const Text(
              'Please request dispatch from admin or reduce quantities.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class SaleItemForValidation {
  final String productId;
  final String name;
  final double quantity;
  final bool isFree;

  SaleItemForValidation({
    required this.productId,
    required this.name,
    required this.quantity,
    this.isFree = false,
  });
}
```

#### File 3: Update Sales Creation Screen
```dart
// lib/screens/sales/create_sale_screen.dart
Future<void> _saveSale() async {
  // ... existing validation ...

  // NEW: Pre-sale stock validation
  final validator = PreSaleStockValidator(context.read<DatabaseService>());
  final items = _saleItems.map((item) => SaleItemForValidation(
    productId: item.productId,
    name: item.name,
    quantity: item.quantity,
    isFree: item.isFree,
  )).toList();

  final hasStock = await validator.validateStock(
    salesmanId: _currentUser.id,
    items: items,
    context: context,
  );

  if (!hasStock) {
    return; // Stop sale creation
  }

  // ... continue with sale creation ...
}
```

---

### TASK 3: Windows Sync Safety

#### File: `lib/services/sales_service.dart`
```dart
// Add at class level
static final Map<String, Completer<void>> _windowsSyncLocks = {};

Future<void> _performSalesAddSyncWindows({
  required firestore.FirebaseFirestore firestore,
  required Map<String, dynamic> data,
  required String recipientType,
  required String seriesType,
  required String salesmanId,
  required String saleId,
  required List<Map<String, dynamic>> items,
}) async {
  // Mutex lock for Windows to prevent race conditions
  final lockKey = 'salesman_$salesmanId';
  
  // Wait if another sync is in progress for this salesman
  while (_windowsSyncLocks.containsKey(lockKey)) {
    AppLogger.debug(
      'Waiting for existing sync to complete for $salesmanId',
      tag: 'Sync',
    );
    await _windowsSyncLocks[lockKey]!.future;
  }
  
  // Acquire lock
  final completer = Completer<void>();
  _windowsSyncLocks[lockKey] = completer;
  
  try {
    AppLogger.debug('Acquired sync lock for $salesmanId', tag: 'Sync');
    
    // ... existing Windows batch write logic ...
    
  } finally {
    // Release lock
    _windowsSyncLocks.remove(lockKey);
    completer.complete();
    AppLogger.debug('Released sync lock for $salesmanId', tag: 'Sync');
  }
}
```

---

### TASK 4: Dashboard Role Separation

#### File: `lib/screens/bhatti/bhatti_dashboard_screen.dart`
```dart
// Filter to show only Bhatti-relevant data
Future<void> _loadDashboardData() async {
  final user = context.read<AuthProvider>().currentUser;
  
  // Only load Bhatti batches
  final batches = await _bhattiRepo.getBhattiEntries(
    startDate: _startDate,
    endDate: _endDate,
  );
  
  // Only show raw materials and semi-finished
  final products = await _dbService.products
      .filter()
      .itemTypeEqualTo('Raw Material')
      .or()
      .itemTypeEqualTo('Semi-Finished Good')
      .findAll();
  
  setState(() {
    _batches = batches;
    _products = products;
  });
}
```

#### File: `lib/screens/production/production_dashboard_consolidated_screen.dart`
```dart
// Filter to show only Production-relevant data
Future<void> _loadDashboardData() async {
  final user = context.read<AuthProvider>().currentUser;
  
  // Only load cutting batches
  final batches = await _cuttingService.getCuttingBatches(
    startDate: _startDate,
    endDate: _endDate,
  );
  
  // Only show semi-finished and finished goods
  final products = await _dbService.products
      .filter()
      .itemTypeEqualTo('Semi-Finished Good')
      .or()
      .itemTypeEqualTo('Finished Good')
      .findAll();
  
  setState(() {
    _batches = batches;
    _products = products;
  });
}
```

---

## ✅ TESTING CHECKLIST

### Role Access Tests
- [ ] Bhatti Supervisor cannot access Production screens
- [ ] Production Supervisor cannot access Bhatti screens
- [ ] Salesman cannot access HR screens
- [ ] Accountant cannot access Production screens
- [ ] Admin can access all screens

### Queue Management Tests
- [ ] Pre-sale validation blocks insufficient stock
- [ ] Stuck items show in admin dashboard
- [ ] Admin can delete stuck items
- [ ] Alerts created for stuck items

### Windows Sync Tests
- [ ] Concurrent sales don't cause race conditions
- [ ] Mutex lock prevents double deduction
- [ ] Logs show lock acquisition/release

### Dashboard Tests
- [ ] Bhatti Dashboard shows only Bhatti data
- [ ] Production Dashboard shows only Production data
- [ ] Stock filtered by role

---

## 📊 SCORE TRACKING

| Task | Points | Status |
|------|--------|--------|
| TASK 1: Role Access | +3 | ⏳ In Progress |
| TASK 2: Queue Management | +2 | ⏳ Pending |
| TASK 3: Windows Safety | +1 | ⏳ Pending |
| TASK 4: Dashboard Separation | +1 | ⏳ Pending |
| TASK 5: Stock Filtering | +0.5 | ⏳ Pending |
| TASK 6: Unit Tests | +0.5 | ⏳ Optional |
| **TOTAL** | **+8** | **Target: 100/100** |

---

## 🎯 SUCCESS CRITERIA

### Must Have (100% Score)
✅ All role-based access controls implemented  
✅ Pre-sale stock validation working  
✅ Stuck queue items manageable by admin  
✅ Windows sync race conditions prevented  
✅ Dashboards filtered by role  
✅ All tests passing

### Nice to Have (Bonus)
✅ Unit test coverage > 70%  
✅ Integration tests for critical flows  
✅ Performance benchmarks  
✅ Documentation updated

---

## 📝 NEXT STEPS

1. **Start with TASK 1** (highest impact)
2. **Test each task** before moving to next
3. **Document changes** as you go
4. **Get user feedback** on UX improvements
5. **Deploy incrementally** to production

**Estimated Timeline**: 2-3 days  
**Confidence**: 95%  
**Risk**: Low
