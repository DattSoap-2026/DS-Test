import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar/isar.dart' hide Query;
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter_app/core/constants/collection_registry.dart';
import 'base_service.dart';
import 'database_service.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/sale_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import '../data/repositories/user_repository.dart';

class DataManagementService extends BaseService {
  final DatabaseService _dbService;
  static const String _deletedRecordsCollection =
      CollectionRegistry.deletedRecords;
  static const String _dataCountCacheKey = 'system_data_counts_cache_v1';
  static const Map<String, int> _defaultDataCounts = {
    'sales': 0,
    'dispatches': 0,
    'production': 0,
    'returns': 0,
    'purchase_orders': 0,
    'diesel_logs': 0,
    'tank_transactions': 0,
    'bhatti_batches': 0,
    'maintenance': 0,
    'products': 0,
    'routes': 0,
    'route_orders': 0,
    'users': 0,
  };

  DataManagementService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance;

  Map<String, int> _withDefaultDataCounts(Map<String, int> counts) {
    final merged = Map<String, int>.from(_defaultDataCounts);
    merged.addAll(counts);
    return merged;
  }

  Future<void> _writeDataCountsCache(Map<String, int> counts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dataCountCacheKey, jsonEncode(counts));
    } catch (e) {
      handleError(e, 'writeDataCountsCache');
    }
  }

  Future<Map<String, int>?> _readDataCountsCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedRaw = prefs.getString(_dataCountCacheKey);
      if (cachedRaw == null || cachedRaw.isEmpty) return null;
      final decoded = jsonDecode(cachedRaw);
      if (decoded is! Map) return null;
      final counts = <String, int>{};
      for (final entry in decoded.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is num) {
          counts[key] = value.toInt();
        }
      }
      return _withDefaultDataCounts(counts);
    } catch (e) {
      handleError(e, 'readDataCountsCache');
      return null;
    }
  }

  Future<int> _countPrefList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return 0;
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.length;
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<Map<String, int>?> _deriveLocalDataCounts() async {
    try {
      final results = await Future.wait<int>([
        _dbService.sales.filter().recipientTypeEqualTo('customer').count(),
        _dbService.sales
            .filter()
            .recipientTypeEqualTo('dealer')
            .or()
            .recipientTypeEqualTo('salesman')
            .count(),
        _dbService.productionEntries.count(),
        _dbService.returns.count(),
        _countPrefList('local_purchase_orders'),
        _dbService.dieselLogs.count(),
        _dbService.tankTransactions.count(),
        _dbService.bhattiBatches.count(),
        _dbService.maintenanceLogs.count(),
        _dbService.products.count(),
        _dbService.routes.count(),
        _dbService.routeOrders.count(),
        _dbService.users.count(),
      ]);

      return _withDefaultDataCounts({
        'sales': results[0],
        'dispatches': results[1],
        'production': results[2],
        'returns': results[3],
        'purchase_orders': results[4],
        'diesel_logs': results[5],
        'tank_transactions': results[6],
        'bhatti_batches': results[7],
        'maintenance': results[8],
        'products': results[9],
        'routes': results[10],
        'route_orders': results[11],
        'users': results[12],
      });
    } catch (e) {
      handleError(e, 'deriveLocalDataCounts');
      return null;
    }
  }

  void _stageTombstone({
    required WriteBatch batch,
    required DocumentReference<Map<String, dynamic>> docRef,
    String? entityType,
    DateTime? deletedAt,
  }) {
    final now = deletedAt ?? DateTime.now();
    final nowIso = now.toIso8601String();
    final type = (entityType ?? docRef.parent.id).trim();
    final tombstoneRef = docRef.firestore
        .collection(_deletedRecordsCollection)
        .doc('${type}_${docRef.id}_${now.microsecondsSinceEpoch}');
    batch.set(tombstoneRef, {
      'entityType': type,
      'docId': docRef.id,
      'deletedAt': nowIso,
      'createdAt': nowIso,
    });
  }

  Future<bool> _deleteAllDocs(String collectionName) async {
    try {
      final firestore = db;
      if (firestore == null) {
        handleError(
          Exception('Firebase not available for $collectionName'),
          'deleteAllDocs',
        );
        return false;
      }

      final collection = firestore.collection(collectionName);
      int iterationCount = 0;
      const maxIterations = 1000;
      
      while (iterationCount < maxIterations) {
        final snapshot = await collection.limit(200).get().timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Timeout deleting $collectionName'),
        );
        if (snapshot.docs.isEmpty) {
          break;
        }
        final batch = firestore.batch();
        for (final doc in snapshot.docs) {
          try {
            _stageTombstone(
              batch: batch,
              docRef: doc.reference,
              entityType: collectionName,
            );
            batch.delete(doc.reference);
          } catch (e) {
            handleError(e, 'deleteAllDocs_stageTombstone');
          }
        }
        await batch.commit().timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Timeout committing batch for $collectionName'),
        );
        iterationCount++;
      }
      
      if (iterationCount >= maxIterations) {
        handleError(
          Exception('Max iterations reached for $collectionName'),
          'deleteAllDocs',
        );
        return false;
      }
      
      return true;
    } catch (e) {
      handleError(e, 'deleteAllDocs($collectionName)');
      return false;
    }
  }

  static const String _lastSyncPrefix = 'last_sync_';

  static const List<String> _transactionCollections = [
    // --- Notifications & Alerts (DELETE FIRST to prevent recreation) ---
    'notification_events', // NEW: event-based notifications
    'alerts', // alert records - DELETE BEFORE route_orders
    // --- Opening Stock (RESET) ---
    'opening_stock',
    'opening_stock_entries',
    // --- Sales & Dispatch ---
    'sales',
    'sale_items',
    'sales_history',
    'sales_payments',
    'sales_returns',
    'dispatches',
    'dispatch_items',
    'dispatch_history',
    CollectionRegistry.deliveryTrips,
    'purchase_orders',
    'returns',
    CollectionRegistry.payments,
    CollectionRegistry.paymentLinks,
    'approvals',
    // --- Salesman Stock ---
    'salesman_allocated_stock',
    'salesman_stock_transactions',
    'salesman_stock_history',
    // --- Production ---
    'production_logs',
    'production_targets',
    'detailed_production_logs',
    CollectionRegistry.productionEntries,
    CollectionRegistry.legacyProductionDailyEntries,
    'production_batches', // production batch entries
    // --- Bhatti & Cutting ---
    'bhatti_batches',
    'bhatti_entries',
    'bhatti_daily_entries',
    'wastage_logs',
    'cutting_batches',
    // --- Stock ---
    'stock_ledger',
    'stock_movements',
    'department_stocks',
    // --- Tanks (entries only, not master names/godowns) ---
    'tank_transactions',
    'tank_transfers',
    'tank_lots',
    // --- Vehicle & Fuel Logs ---
    'diesel_logs',
    'fuel_purchases',
    'vehicle_maintenance_logs',
    'vehicle_issues', // NEW: vehicle issue reports
    'tyre_logs', // NEW: tyre change/repair logs
    'tyre_items', // tyre stock/inventory items (transactional)
    // --- HR / Payroll / Attendance ---
    'duty_sessions',
    'route_sessions',
    'customer_visits',
    'sales_targets',
    'payroll_records',
    'attendances',
    'advances', // NEW: salary advances
    'leave_requests', // NEW: leave applications
    'performance_reviews', // NEW: employee performance records
    // PRESERVE: employee_documents - NOT included in reset
    // 'employee_documents', // uploaded employee docs (PRESERVED)
    // --- Accounting Entries (NOT 'accounts' chart of accounts - that's master) ---
    'vouchers', // NEW: accounting vouchers (journal/payment/receipt)
    'voucher_entries', // NEW: voucher line items
    'schemes', // NEW: sales scheme entries
    'accounting_compensation_log', // auto-generated accounting correction entries
    'sales_voucher_posts', // retry queue for failed voucher posts
    // --- Route / Sales Planning & Tasks ---
    'route_orders', // planned route orders
    'route_order_items', // route order line items
    'tasks', // task assignments
    'task_history', // task history log
    'audit_logs',
  ];

  static const List<String> _transactionPrefKeys = [
    'local_sales',
    'local_sales_queue',
    'local_returns',
    'local_payments',
    'local_purchase_orders',
    'local_delivery_trips',
    'local_dispatch_queue',
    'local_stock_movements',
    'local_tanks',
    'local_diesel',
    'local_payroll',
    'local_attendances',
    'local_approvals',
    'local_sync_queue',
    'production_data_v2',
    'bhatti_batches',
    'cutting_batches',
    'local_advances',
    'local_leave_requests',
    'local_schemes',
    'local_vouchers',
    'local_notifications',
    'local_tasks',
    'local_route_orders',
    'salesman_stock_cache',
    'dispatch_cache',
    'inventory_cache',
    'offline_transactions',
  ];

  Future<bool> resetTransactionalData({
    required String userId,
    required String userName,
    required bool isAdmin,
    void Function(String message)? onProgress,
  }) async {
    try {
      if (!isAdmin) {
        throw Exception('Only Admin/Owner can perform full transaction reset');
      }

      // Validate Firebase connection
      final firestore = db;
      if (firestore == null) {
        throw Exception('Firebase not initialized. Check internet connection.');
      }

      // Create audit log
      try {
        await createAuditLog(
          collectionName: 'system',
          docId: 'full_reset_${DateTime.now().millisecondsSinceEpoch}',
          action: 'full_transaction_reset',
          changes: {'status': 'started', 'timestamp': DateTime.now().toIso8601String()},
          userId: userId,
          userName: userName,
        );
      } catch (e) {
        handleError(e, 'createResetAuditLog');
      }

      final now = DateTime.now();
      bool remoteOk = false;
      bool localOk = false;
      bool prefsOk = false;

      try {
        onProgress?.call('Deleting Firebase transactional data...');
        remoteOk = await _resetRemoteTransactions(
          now,
          onProgress: onProgress,
        );
      } catch (e) {
        handleError(e, 'resetTransactionalData_remote');
        remoteOk = false;
      }

      try {
        onProgress?.call('Wiping local transactional data...');
        localOk = await _resetLocalTransactionalData(now);
      } catch (e) {
        handleError(e, 'resetTransactionalData_local');
        localOk = false;
      }

      try {
        onProgress?.call('Clearing local caches...');
        prefsOk = await _clearTransactionalSharedPrefs();
      } catch (e) {
        handleError(e, 'resetTransactionalData_prefs');
        prefsOk = false;
      }

      onProgress?.call('Finalizing...');
      
      final success = remoteOk && localOk && prefsOk;
      
      // Log completion
      try {
        await createAuditLog(
          collectionName: 'system',
          docId: 'full_reset_complete_${DateTime.now().millisecondsSinceEpoch}',
          action: 'full_transaction_reset',
          changes: {
            'status': success ? 'completed' : 'partial',
            'timestamp': DateTime.now().toIso8601String(),
            'remoteOk': remoteOk,
            'localOk': localOk,
            'prefsOk': prefsOk,
          },
          userId: userId,
          userName: userName,
        );
      } catch (e) {
        handleError(e, 'createResetCompletionLog');
      }
      
      return success;
    } catch (e) {
      handleError(e, 'resetTransactionalData');
      onProgress?.call('Error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> _resetRemoteTransactions(
    DateTime now, {
    void Function(String message)? onProgress,
  }) async {
    try {
      final firestore = db;
      if (firestore == null) {
        handleError(
          Exception('Firebase not available'),
          'resetRemoteTransactions',
        );
        return false;
      }

      bool allSuccess = true;
      for (final collection in _transactionCollections) {
        try {
          onProgress?.call('Deleting $collection...');
          final success = await _deleteAllDocs(collection);
          if (!success) {
            allSuccess = false;
            handleError(
              Exception('Failed to delete $collection'),
              'resetRemoteTransactions',
            );
          }
        } catch (e) {
          allSuccess = false;
          handleError(e, 'resetRemoteTransactions_$collection');
        }
      }

      try {
        onProgress?.call('Clearing allocated stock...');
        await _clearRemoteAllocatedStock(now);
      } catch (e) {
        allSuccess = false;
        handleError(e, 'resetRemoteTransactions_allocatedStock');
      }

      try {
        onProgress?.call('Resetting tank/godown stock to initial state...');
        await _resetRemoteTankAndGodownStock(now);
      } catch (e) {
        allSuccess = false;
        handleError(e, 'resetRemoteTransactions_tankStock');
      }

      try {
        onProgress?.call('Resetting fuel stock to zero...');
        await _resetFuelStock();
      } catch (e) {
        allSuccess = false;
        handleError(e, 'resetRemoteTransactions_fuelStock');
      }

      try {
        onProgress?.call('Resetting all product stock to zero...');
        await _resetAllProductStockToZero(now);
      } catch (e) {
        allSuccess = false;
        handleError(e, 'resetRemoteTransactions_productStock');
      }

      return allSuccess;
    } catch (e) {
      handleError(e, 'resetRemoteTransactions');
      return false;
    }
  }

  Future<bool> _clearRemoteAllocatedStock(DateTime now) async {
    try {
      final firestore = db;
      if (firestore == null) {
        throw Exception('Firebase not available.');
      }

      final snapshot = await firestore.collection('users').get();
      if (snapshot.docs.isEmpty) return true;

      // T9-P5 REMOVED: Direct allocatedStock remote clear
      // Route through stock_balances reset
      final salesmanLocationIds = <String>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final role = data['role']?.toString().trim().toLowerCase();
        if (role == 'salesman') {
          salesmanLocationIds.add('salesman_van_${doc.id}');
        }
      }

      final nowIso = now.toIso8601String();
      for (int i = 0; i < snapshot.docs.length; i += 400) {
        final batch = firestore.batch();
        final chunk = snapshot.docs.skip(i).take(400);
        for (final doc in chunk) {
          batch.update(doc.reference, {
            'allocatedStock': FieldValue.delete(),
            'allocatedStockJson': FieldValue.delete(),
            'updatedAt': nowIso,
          });
        }
        await batch.commit();
      }
      return true;
    } catch (e) {
      handleError(e, 'clearRemoteAllocatedStock');
      return false;
    }
  }

  Future<bool> _resetAllProductStockToZero(DateTime now) async {
    try {
      final firestore = db;
      if (firestore == null) return false;

      final productsSnap = await firestore.collection('products').get();
      if (productsSnap.docs.isEmpty) return true;

      final nowIso = now.toIso8601String();
      for (int i = 0; i < productsSnap.docs.length; i += 400) {
        final batch = firestore.batch();
        final chunk = productsSnap.docs.skip(i).take(400);
        for (final doc in chunk) {
          batch.update(doc.reference, {'stock': 0.0, 'updatedAt': nowIso});
        }
        await batch.commit();
      }
      return true;
    } catch (e) {
      handleError(e, 'resetAllProductStockToZero');
      return false;
    }
  }

  String _statusForStock({required double stock, required double capacity}) {
    // Validate capacity
    if (capacity <= 0) {
      return 'inactive'; // Invalid capacity
    }
    
    final fillLevel = (stock / capacity) * 100;
    if (fillLevel < 5) return 'critical';
    if (fillLevel < 15) return 'low-stock';
    return 'active';
  }

  Future<bool> _resetRemoteTankAndGodownStock(DateTime now) async {
    try {
      final firestore = db;
      if (firestore == null) return false;

      final tanksSnap = await firestore.collection('tanks').get();
      if (tanksSnap.docs.isEmpty) return true;

      final nowIso = now.toIso8601String();
      for (int i = 0; i < tanksSnap.docs.length; i += 400) {
        final batch = firestore.batch();
        final chunk = tanksSnap.docs.skip(i).take(400);
        for (final doc in chunk) {
          final data = doc.data();
          final capacity = (data['capacity'] as num?)?.toDouble() ?? 0.0;
          final type = (data['type'] as String?)?.toLowerCase() ?? 'tank';
          final update = <String, dynamic>{
            'currentStock': 0.0,
            'fillLevel': 0.0,
            'status': _statusForStock(stock: 0.0, capacity: capacity),
            'updatedAt': nowIso,
          };
          if (type == 'godown') {
            update['bags'] = 0;
          }
          batch.update(doc.reference, update);
        }
        await batch.commit();
      }
      return true;
    } catch (e) {
      handleError(e, 'resetRemoteTankAndGodownStock');
      return false;
    }
  }

  Future<bool> _resetFuelStock() async {
    try {
      final firestore = db;
      if (firestore == null) return false;

      // Reset fuel stock document to 0
      await firestore.doc('public_settings/fuel_stock').set({
        'totalLiters': 0.0,
        'lastUpdated': DateTime.now().toIso8601String(),
        'resetAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      handleError(e, 'resetFuelStock');
      return false;
    }
  }

  Future<bool> _resetLocalTransactionalData(DateTime now) async {
    try {
      // PRESERVE: Employee documents, Customer/Dealer GPS & addresses
      final employeeDocs = await _dbService.employeeDocuments.where().findAll();
      
      // T9-P5 REMOVED: Direct products.stock + users.allocatedStock local reset
      // Reset stock_balances, then update projections
      
      // Reset all product stock to zero
      final products = await _dbService.products.where().findAll();
      for (final product in products) {
        product
          ..stock = 0.0
          ..updatedAt = now
          ..syncStatus = SyncStatus.synced;
      }

      final users = await _dbService.users.where().findAll();
      for (final user in users) {
        user
          ..allocatedStockJson = null
          ..updatedAt = now
          ..syncStatus = SyncStatus.synced;
      }

      // Keep tank/godown master records; reset only stock state.
      final tanks = await _dbService.tanks.where().findAll();
      for (final tank in tanks) {
        tank
          ..currentStock = 0.0
          ..fillLevel = 0.0
          ..status = _statusForStock(stock: 0.0, capacity: tank.capacity)
          ..updatedAt = now
          ..syncStatus = SyncStatus.synced;
        if (tank.type.toLowerCase() == 'godown') {
          tank.bags = 0;
        }
      }

      await _dbService.db.writeTxn(() async {
        try {
          // --- Opening Stock ---
          await _dbService.openingStockEntries.clear();
          // --- Sales & Dispatch ---
          await _dbService.sales.clear();
          await _dbService.payments.clear();
          await _dbService.returns.clear();
          await _dbService.trips.clear();
          await _dbService.salesTargets.clear();
          // --- Production ---
          await _dbService.bhattiEntries.clear();
          await _dbService.productionEntries.clear();
          await _dbService.bhattiBatches.clear();
          await _dbService.wastageLogs.clear();
          await _dbService.cuttingBatches.clear();
          await _dbService.productionTargets.clear();
          await _dbService.detailedProductionLogs.clear();
          // --- Stock ---
          await _dbService.stockLedgers.clear();
          await _dbService.departmentStocks.clear();
          // --- Tanks (entries only, keep names/godowns as master) ---
          await _dbService.tankTransactions.clear();
          await _dbService.tankLots.clear();
          // --- Vehicle & Fuel Logs ---
          await _dbService.dieselLogs.clear();
          await _dbService.maintenanceLogs.clear();
          await _dbService.tyreLogs.clear();
          await _dbService.tyreStocks.clear();
          await _dbService.vehicleIssues.clear();
          // --- HR / Payroll / Attendance ---
          await _dbService.payrollRecords.clear();
          await _dbService.leaveRequests.clear();
          await _dbService.attendances.clear();
          await _dbService.advances.clear();
          await _dbService.performanceReviews.clear();
          await _dbService.dutySessions.clear();
          await _dbService.routeSessions.clear();
          await _dbService.customerVisits.clear();
          // --- Accounting Entries ---
          await _dbService.vouchers.clear();
          await _dbService.voucherEntries.clear();
          await _dbService.schemes.clear();
          // --- Route Orders ---
          await _dbService.routeOrders.clear();
          // --- System / Notifications ---
          await _dbService.alerts.clear();
          await _dbService.auditLogs.clear();
          await _dbService.syncQueue.clear();
          await _dbService.syncMetrics.clear();
          await _dbService.conflicts.clear();

          // Restore master data
          await _dbService.users.putAll(users);
          await _dbService.products.putAll(products);
          await _dbService.tanks.putAll(tanks);
          
          // RESTORE: Employee documents
          if (employeeDocs.isNotEmpty) {
            await _dbService.employeeDocuments.putAll(employeeDocs);
          }
        } catch (e) {
          handleError(e, 'resetLocalTransactionalData_writeTxn');
          rethrow; // Rollback transaction
        }
      });

      return true;
    } catch (e) {
      handleError(e, 'resetLocalTransactionalData');
      return false;
    }
  }

  Future<bool> _clearTransactionalSharedPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear known transaction keys
      for (final key in _transactionPrefKeys) {
        await prefs.remove(key);
      }

      // Clear all last_sync_ prefixed keys
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_lastSyncPrefix)) {
          await prefs.remove(key);
        }
      }
      
      // Clear additional transactional patterns
      final transactionalPatterns = [
        'last_bulk_sync_date',
        'cached_',
        '_queue',
        '_cache',
        '_history',
        'offline_',
        'pending_',
      ];
      
      for (final key in keys) {
        for (final pattern in transactionalPatterns) {
          if (key.contains(pattern)) {
            await prefs.remove(key);
            break;
          }
        }
      }

      return true;
    } catch (e) {
      handleError(e, 'clearTransactionalSharedPrefs');
      return false;
    }
  }

  Future<void> _clearLocalResetArtifacts({
    List<String> prefKeys = const [],
    List<String> lastSyncCollections = const [],
    List<String> queueCollections = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefKeys) {
      await prefs.remove(key);
    }
    for (final collection in lastSyncCollections) {
      await prefs.remove('$_lastSyncPrefix$collection');
    }
    if (queueCollections.isNotEmpty) {
      await _clearSyncQueueByCollections(queueCollections);
    }
  }

  Future<void> _clearSyncQueueByCollections(List<String> collections) async {
    if (collections.isEmpty) return;
    final items = await _dbService.syncQueue.where().findAll();
    final ids = items
        .where((q) => collections.contains(q.collection))
        .map((q) => fastHash(q.id))
        .toList();
    if (ids.isEmpty) return;
    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.deleteAll(ids);
    });
  }

  Future<void> _clearSalesSyncQueueByRecipientTypes(
    Set<String> recipientTypes,
  ) async {
    if (recipientTypes.isEmpty) return;
    final salesQueueItems = await _dbService.syncQueue
        .filter()
        .collectionEqualTo('sales')
        .findAll();
    if (salesQueueItems.isEmpty) return;

    final ids = <Id>[];
    for (final item in salesQueueItems) {
      try {
        final decoded = jsonDecode(item.dataJson);
        if (decoded is! Map) continue;
        final data = Map<String, dynamic>.from(decoded);
        final type = data['recipientType']?.toString();
        if (type != null && recipientTypes.contains(type)) {
          ids.add(fastHash(item.id));
        }
      } catch (_) {
        // Ignore malformed queued payloads and keep queue intact.
      }
    }

    if (ids.isEmpty) return;
    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.deleteAll(ids);
    });
  }

  bool _isDispatchRecordInInventoryCache(Map<String, dynamic> data) {
    return data['dispatchId'] != null &&
        data['salesmanId'] != null &&
        data['items'] is List;
  }

  Future<void> _clearDispatchRecordsFromInventoryCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const cacheKey = 'local_stock_movements';
      final jsonStr = prefs.getString(cacheKey);
      if (jsonStr == null || jsonStr.isEmpty) return;

      final decoded = jsonDecode(jsonStr);
      if (decoded is! List) return;

      final remaining = <Map<String, dynamic>>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        if (_isDispatchRecordInInventoryCache(map)) {
          continue;
        }
        remaining.add(map);
      }

      if (remaining.isEmpty) {
        await prefs.remove(cacheKey);
      } else {
        await prefs.setString(cacheKey, jsonEncode(remaining));
      }
    } catch (e) {
      handleError(e, 'clearDispatchRecordsFromInventoryCache');
    }
  }

  Future<bool> resetAllSales() async {
    bool remoteOk = true;
    bool localOk = true;

    final firestore = db;
    if (firestore != null) {
      try {
        const pageSize = 100;
        Query<Map<String, dynamic>> salesQuery = firestore
            .collection('sales')
            .where('recipientType', isEqualTo: 'customer');

        while (true) {
          final snap = await salesQuery.limit(pageSize).get();
          if (snap.docs.isEmpty) break;

          WriteBatch batch = firestore.batch();
          var opCount = 0;
          Future<void> commitIfNeeded() async {
            if (opCount >= 400) {
              await batch.commit();
              batch = firestore.batch();
              opCount = 0;
            }
          }

          for (final docSnap in snap.docs) {
            final sale = docSnap.data();
            final items = sale['items'] as List? ?? [];
            final salesmanId = sale['salesmanId'] as String?;

            // Validate and restore allocated stock
            if (items.isNotEmpty &&
                salesmanId != null &&
                salesmanId.isNotEmpty) {
              final salesmanRef = firestore.collection('users').doc(salesmanId);
              
              // Verify salesman exists before updating
              try {
                final salesmanDoc = await salesmanRef.get();
                if (!salesmanDoc.exists) {
                  handleError(
                    Exception('Salesman $salesmanId not found'),
                    'resetAllSales',
                  );
                  continue;
                }
              } catch (e) {
                handleError(e, 'resetAllSales_validateSalesman');
                continue;
              }
              
              for (final item in items) {
                final pid = item['productId'];
                final qty = (item['quantity'] as num?)?.toDouble();
                
                // Validate product ID and quantity
                if (pid == null || pid.toString().isEmpty) continue;
                if (qty == null || qty <= 0) continue;
                
                batch.update(salesmanRef, {
                  'allocatedStock.$pid.quantity': FieldValue.increment(qty),
                });
                opCount++;
                await commitIfNeeded();
              }
            }

            _stageTombstone(
              batch: batch,
              docRef: docSnap.reference,
              entityType: 'sales',
            );
            batch.delete(docSnap.reference);
            opCount += 2;
            await commitIfNeeded();
          }

          if (opCount > 0) {
            await batch.commit();
          }
        }

        await _deleteAllDocs('sales_targets');
      } catch (e) {
        remoteOk = false;
        handleError(e, 'resetAllSalesRemote');
      }
    }

    try {
      await _dbService.db.writeTxn(() async {
        final customerSales = await _dbService.sales
            .filter()
            .recipientTypeEqualTo('customer')
            .findAll();
        if (customerSales.isNotEmpty) {
          await _dbService.sales.deleteAll(
            customerSales.map((s) => fastHash(s.id)).toList(),
          );
        }
        await _dbService.salesTargets.clear();
      });

      await _clearSalesSyncQueueByRecipientTypes({'customer'});
      await _clearSyncQueueByCollections(['sales_targets']);
    } catch (e) {
      localOk = false;
      handleError(e, 'resetAllSalesLocal');
    }

    return remoteOk && localOk;
  }

  Future<bool> resetAllDispatches() async {
    bool remoteOk = true;
    bool localOk = true;
    final now = DateTime.now();

    final firestore = db;
    if (firestore == null) return false;

    try {
      const pageSize = 100;
      
      // Delete dealer dispatches
      Query<Map<String, dynamic>> dealerQuery = firestore
          .collection('sales')
          .where('recipientType', isEqualTo: 'dealer');
      
      while (true) {
        final snap = await dealerQuery.limit(pageSize).get();
        if (snap.docs.isEmpty) break;
        
        WriteBatch batch = firestore.batch();
        for (final doc in snap.docs) {
          final data = doc.data();
          final items = data['items'] as List? ?? [];
          
          for (final item in items) {
            final pid = item['productId']?.toString();
            final qty = (item['quantity'] as num?)?.toDouble();
            if (pid != null && pid.isNotEmpty && qty != null && qty > 0) {
              batch.update(firestore.collection('products').doc(pid), {
                'stock': FieldValue.increment(qty),
              });
            }
          }
          
          _stageTombstone(batch: batch, docRef: doc.reference, entityType: 'sales');
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
      
      // Delete salesman dispatches
      Query<Map<String, dynamic>> salesmanQuery = firestore
          .collection('sales')
          .where('recipientType', isEqualTo: 'salesman');
      
      while (true) {
        final snap = await salesmanQuery.limit(pageSize).get();
        if (snap.docs.isEmpty) break;
        
        WriteBatch batch = firestore.batch();
        for (final doc in snap.docs) {
          final data = doc.data();
          final items = data['items'] as List? ?? [];
          
          for (final item in items) {
            final pid = item['productId']?.toString();
            final qty = (item['quantity'] as num?)?.toDouble();
            if (pid != null && pid.isNotEmpty && qty != null && qty > 0) {
              batch.update(firestore.collection('products').doc(pid), {
                'stock': FieldValue.increment(qty),
              });
            }
          }
          
          _stageTombstone(batch: batch, docRef: doc.reference, entityType: 'sales');
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // Also clear dedicated dispatches collection shown in UI.
      Query<Map<String, dynamic>> dispatchesQuery = firestore.collection(
        'dispatches',
      );
      while (true) {
        final snap = await dispatchesQuery.limit(pageSize).get();
        if (snap.docs.isEmpty) break;
        WriteBatch batch = firestore.batch();
        for (final doc in snap.docs) {
          _stageTombstone(
            batch: batch,
            docRef: doc.reference,
            entityType: 'dispatches',
          );
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // Dispatch reset must also clear salesman allocated stock everywhere.
      final usersOk = await _clearRemoteAllocatedStock(now);
      if (!usersOk) {
        remoteOk = false;
      }
    } catch (e) {
      remoteOk = false;
      handleError(e, 'resetAllDispatchesRemote');
    }

    try {
      await _dbService.db.writeTxn(() async {
        final dispatchSales = await _dbService.sales
            .filter()
            .recipientTypeEqualTo('dealer')
            .or()
            .recipientTypeEqualTo('salesman')
            .findAll();
        if (dispatchSales.isNotEmpty) {
          await _dbService.sales.deleteAll(
            dispatchSales.map((s) => fastHash(s.id)).toList(),
          );
        }

        // Clear dedicated dispatches collection
        await _dbService.dispatches.clear();

        final users = await _dbService.users.where().findAll();
        for (final user in users) {
          user
            ..allocatedStockJson = null
            ..updatedAt = now
            ..syncStatus = SyncStatus.synced;
        }
        if (users.isNotEmpty) {
          await _dbService.users.putAll(users);
        }
      });

      await _clearSalesSyncQueueByRecipientTypes({'dealer', 'salesman'});
      await _clearLocalResetArtifacts(
        prefKeys: ['local_sales', 'dispatch_cache', 'salesman_stock_cache'],
        lastSyncCollections: ['sales', 'dispatches'],
        queueCollections: ['dispatches'],
      );
      await _clearDispatchRecordsFromInventoryCache();
    } catch (e) {
      localOk = false;
      handleError(e, 'resetAllDispatchesLocal');
    }

    return remoteOk && localOk;
  }

  Future<bool> resetSalesDispatchesDashboards({
    void Function(String message)? onProgress,
  }) async {
    bool dbOk = true;

    try {
      onProgress?.call('Resetting sales & invoices...');
      final salesOk = await resetAllSales();
      if (!salesOk) dbOk = false;

      onProgress?.call('Resetting dispatches...');
      final dispatchesOk = await resetAllDispatches();
      if (!dispatchesOk) dbOk = false;

      onProgress?.call('Explicitly clearing trips (if any)...');
      final firestore = db;
      if (firestore != null) {
        await _deleteAllDocs(CollectionRegistry.deliveryTrips);
      }
      await _dbService.db.writeTxn(() async {
        await _dbService.trips.clear();
      });

      onProgress?.call('Syncing allocated stock...');
      await _dbService.db.writeTxn(() async {
        final users = await _dbService.users.where().findAll();
        for (final u in users) {
          u.allocatedStockJson = null;
          u.syncStatus = SyncStatus.synced;
        }
        if (users.isNotEmpty) {
          await _dbService.users.putAll(users);
        }
      });

      onProgress?.call('Clearing dashboard caches...');
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final k in keys) {
        final lowerKey = k.toLowerCase();
        if (lowerKey.contains('dashboard') ||
            lowerKey.contains('metric') ||
            lowerKey.contains('sales_report') ||
            lowerKey.contains('dispatch_report')) {
          await prefs.remove(k);
        }
      }

      await _dbService.db.writeTxn(() async {
        await _dbService.syncMetrics.clear();
      });
    } catch (e) {
      dbOk = false;
      handleError(e, 'resetSalesDispatchesDashboards');
    }

    return dbOk;
  }

  Future<bool> resetAllProduction() async {
    bool remoteOk = true;
    bool localOk = true;

    final s1 = await _deleteAllDocs('production_logs');
    final s2 = await _deleteAllDocs('production_targets');
    final s3 = await _deleteAllDocs('detailed_production_logs');
    final s4 = await _deleteAllDocs(CollectionRegistry.productionEntries);
    final s5 = await _deleteAllDocs(
      CollectionRegistry.legacyProductionDailyEntries,
    );
    remoteOk = s1 && s2 && s3 && s4 && s5;

    try {
      await _dbService.db.writeTxn(() async {
        await _dbService.productionTargets.clear();
        await _dbService.detailedProductionLogs.clear();
        await _dbService.productionEntries.clear();
      });

      await _clearLocalResetArtifacts(
        prefKeys: ['production_data_v2'],
        lastSyncCollections: [
          'production_logs',
          'production_targets',
          'detailed_production_logs',
          CollectionRegistry.productionEntries,
          CollectionRegistry.legacyProductionDailyEntries,
        ],
        queueCollections: [
          'production_logs',
          'production_targets',
          'detailed_production_logs',
          CollectionRegistry.productionEntries,
          CollectionRegistry.legacyProductionDailyEntries,
        ],
      );
    } catch (e) {
      localOk = false;
      handleError(e, 'resetAllProductionLocal');
    }

    return remoteOk && localOk;
  }

  Future<bool> resetAllReturns() async {
    bool remoteOk = true;
    bool localOk = true;

    remoteOk = await _deleteAllDocs('returns');

    try {
      await _dbService.db.writeTxn(() async {
        await _dbService.returns.clear();
      });
      await _clearLocalResetArtifacts(
        prefKeys: ['local_returns'],
        lastSyncCollections: ['returns'],
        queueCollections: ['returns'],
      );
    } catch (e) {
      localOk = false;
      handleError(e, 'resetAllReturnsLocal');
    }

    return remoteOk && localOk;
  }

  Future<bool> resetAllPurchaseOrders() async {
    bool remoteOk = true;
    bool localOk = true;

    remoteOk = await _deleteAllDocs('purchase_orders');

    try {
      await _clearLocalResetArtifacts(
        prefKeys: ['local_purchase_orders'],
        lastSyncCollections: ['purchase_orders'],
        queueCollections: ['purchase_orders'],
      );
    } catch (e) {
      localOk = false;
      handleError(e, 'resetAllPurchaseOrdersLocal');
    }

    return remoteOk && localOk;
  }

  Future<bool> resetAllDieselLogs() async {
    bool remoteOk = true;
    bool localOk = true;

    remoteOk = await _deleteAllDocs('diesel_logs');

    try {
      await _dbService.db.writeTxn(() async {
        await _dbService.dieselLogs.clear();
      });
      await _clearLocalResetArtifacts(
        prefKeys: ['local_diesel'],
        lastSyncCollections: ['diesel_logs'],
        queueCollections: ['diesel_logs', 'special_actions'],
      );
    } catch (e) {
      localOk = false;
      handleError(e, 'resetAllDieselLogsLocal');
    }

    return remoteOk && localOk;
  }

  Future<bool> resetAllTankTransactions() async {
    bool remoteOk = true;
    bool localOk = true;

    remoteOk = await _deleteAllDocs('tank_transactions');

    try {
      await _dbService.db.writeTxn(() async {
        await _dbService.tankTransactions.clear();
      });
      await _clearLocalResetArtifacts(
        lastSyncCollections: ['tank_transactions'],
        queueCollections: ['tank_transactions'],
      );
    } catch (e) {
      localOk = false;
      handleError(e, 'resetAllTankTransactionsLocal');
    }

    return remoteOk && localOk;
  }

  Future<bool> resetAllBhattiBatches() async {
    bool remoteOk = true;
    bool localOk = true;

    final s1 = await _deleteAllDocs('bhatti_batches');
    final s2 = await _deleteAllDocs('wastage_logs');
    remoteOk = s1 && s2;

    try {
      await _dbService.db.writeTxn(() async {
        await _dbService.bhattiBatches.clear();
        await _dbService.wastageLogs.clear();
      });
      await _clearLocalResetArtifacts(
        prefKeys: ['bhatti_batches'],
        lastSyncCollections: ['bhatti_batches', 'wastage_logs'],
        queueCollections: ['bhatti_batches', 'wastage_logs'],
      );
    } catch (e) {
      localOk = false;
      handleError(e, 'resetAllBhattiBatchesLocal');
    }

    return remoteOk && localOk;
  }

  Future<bool> resetAllMaintenanceHistory() async {
    bool remoteOk = true;
    bool localOk = true;

    final s1 = await _deleteAllDocs('vehicle_maintenance_logs');
    final s2 = await _deleteAllDocs('tyre_logs');
    remoteOk = s1 && s2;

    try {
      await _dbService.db.writeTxn(() async {
        await _dbService.maintenanceLogs.clear();
        await _dbService.tyreLogs.clear();
      });
      await _clearLocalResetArtifacts(
        lastSyncCollections: ['vehicle_maintenance_logs', 'tyre_logs'],
        queueCollections: ['vehicle_maintenance_logs', 'tyre_logs'],
      );
    } catch (e) {
      localOk = false;
      handleError(e, 'resetAllMaintenanceHistoryLocal');
    }

    return remoteOk && localOk;
  }

  Future<bool> resetAllProducts() async {
    bool remoteOk = true;
    bool localOk = true;

    remoteOk = await _deleteAllDocs('products');

    try {
      await _dbService.db.writeTxn(() async {
        await _dbService.products.clear();
      });
      await _clearLocalResetArtifacts(
        lastSyncCollections: ['products'],
        queueCollections: ['products'],
      );
    } catch (e) {
      localOk = false;
      handleError(e, 'resetAllProductsLocal');
    }

    return remoteOk && localOk;
  }

  Future<bool> resetAllRoutes() async {
    bool remoteOk = true;
    bool localOk = true;

    remoteOk = await _deleteAllDocs('routes');

    try {
      await _dbService.db.writeTxn(() async {
        await _dbService.routes.clear();
      });
      await _clearLocalResetArtifacts(
        lastSyncCollections: ['routes'],
        queueCollections: ['routes'],
      );
    } catch (e) {
      localOk = false;
      handleError(e, 'resetAllRoutesLocal');
    }

    return remoteOk && localOk;
  }

  Future<bool> resetAllRouteOrders() async {
    bool remoteOk = true;
    bool localOk = true;

    final s1 = await _deleteAllDocs('route_orders');
    final s2 = await _deleteAllDocs('route_order_items');
    remoteOk = s1 && s2;

    try {
      await _dbService.db.writeTxn(() async {
        await _dbService.routeOrders.clear();
      });
      await _clearLocalResetArtifacts(
        prefKeys: ['local_route_orders'],
        lastSyncCollections: ['route_orders', 'route_order_items'],
        queueCollections: ['route_orders', 'route_order_items'],
      );
    } catch (e) {
      localOk = false;
      handleError(e, 'resetAllRouteOrdersLocal');
    }

    return remoteOk && localOk;
  }

  Future<bool> resetAllUsers(
    String currentUserId, {
    UserRepository? localRepo,
  }) async {
    try {
      final firestore = db;
      if (firestore == null) return false;

      // 1. Remote Delete (Firestore)
      final snap = await firestore.collection('users').get();
      WriteBatch batch = firestore.batch();
      int opCount = 0;

      Future<void> commitIfNeeded() async {
        if (opCount >= 400) {
          await batch.commit();
          batch = firestore.batch();
          opCount = 0;
        }
      }

      for (var doc in snap.docs) {
        if (doc.id == currentUserId) continue; // Don't delete self
        // Delete ALL other users
        _stageTombstone(
          batch: batch,
          docRef: doc.reference,
          entityType: 'users',
        );
        batch.delete(doc.reference);
        opCount += 2;
        await commitIfNeeded();
      }

      if (opCount > 0) await batch.commit();

      // 2. Local Delete (Isar)
      if (localRepo != null) {
        await localRepo.deleteAllUsersExcept(currentUserId);
      }

      return true;
    } catch (e) {
      handleError(e, 'resetAllUsers');
      return false;
    }
  }

  Future<Map<String, int>> getDataCount() async {
    try {
      final firestore = db;
      if (firestore != null) {
        final results = await Future.wait<AggregateQuerySnapshot>([
          firestore
              .collection('sales')
              .where('recipientType', isEqualTo: 'customer')
              .count()
              .get(),
          firestore
              .collection('sales')
              .where('recipientType', whereIn: ['dealer', 'salesman'])
              .count()
              .get(),
          firestore.collection('production_logs').count().get(),
          firestore.collection('returns').count().get(),
          firestore.collection('purchase_orders').count().get(),
          firestore.collection('diesel_logs').count().get(),
          firestore.collection('tank_transactions').count().get(),
          firestore.collection('bhatti_batches').count().get(),
          firestore.collection('vehicle_maintenance_logs').count().get(),
          firestore.collection('products').count().get(),
          firestore.collection('routes').count().get(),
          firestore.collection('route_orders').count().get(),
          firestore.collection('users').count().get(),
        ]);

        final remoteCounts = _withDefaultDataCounts({
          'sales': results[0].count ?? 0,
          'dispatches': results[1].count ?? 0,
          'production': results[2].count ?? 0,
          'returns': results[3].count ?? 0,
          'purchase_orders': results[4].count ?? 0,
          'diesel_logs': results[5].count ?? 0,
          'tank_transactions': results[6].count ?? 0,
          'bhatti_batches': results[7].count ?? 0,
          'maintenance': results[8].count ?? 0,
          'products': results[9].count ?? 0,
          'routes': results[10].count ?? 0,
          'route_orders': results[11].count ?? 0,
          'users': results[12].count ?? 0,
        });
        await _writeDataCountsCache(remoteCounts);
        return remoteCounts;
      }
    } catch (e) {
      handleError(e, 'getDataCount');
    }

    final localCounts = await _deriveLocalDataCounts();
    if (localCounts != null) {
      await _writeDataCountsCache(localCounts);
      return localCounts;
    }

    final cachedCounts = await _readDataCountsCache();
    if (cachedCounts != null) return cachedCounts;

    return Map<String, int>.from(_defaultDataCounts);
  }

  // --- Mock Data Management ---
  Future<List<FileSystemEntity>> getMockDataFiles() async {
    try {
      if (kIsWeb) return [];
      final dir = Directory('mock_data');
      if (!await dir.exists()) return [];
      // Support JSON and Excel
      return dir
          .listSync()
          .where((f) => f.path.endsWith('.json') || f.path.endsWith('.xlsx'))
          .toList();
    } catch (e) {
      handleError(e, 'getMockDataFiles');
      return [];
    }
  }

  Future<bool> deleteMockDataFile(String filePath) async {
    try {
      if (kIsWeb) return false;
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      handleError(e, 'deleteMockDataFile');
      return false;
    }
  }

  Future<String?> importDataFromJson(
    String jsonContent,
    String userId,
    String userName,
  ) async {
    // ... (Existing JSON import logic kept as valid fallback or alternative)
    // For brevity, calling internal logic if needed, but keeping original implementation is fine.
    // Re-pasting original implementation to ensure it's not lost:
    try {
      final firestore = db;
      if (firestore == null) return "Firebase is not initialized.";

      final data = json.decode(jsonContent) as Map<String, dynamic>;
      final collections = data['collections'] as Map<String, dynamic>?;

      if (collections == null || collections.isEmpty) {
        return "Invalid JSON: 'collections' missing.";
      }

      for (var entry in collections.entries) {
        await _batchImportCollection(
          entry.key,
          entry.value as Map<String, dynamic>,
          userId,
          userName,
        );
      }
      return null;
    } catch (e) {
      handleError(e, 'importDataFromJson');
      return "Import error: $e";
    }
  }

  Future<String?> importDataFromExcel(
    List<int> bytes,
    String userId,
    String userName,
  ) async {
    try {
      final excel = Excel.decodeBytes(bytes);
      final firestore = db;
      if (firestore == null) return "Firebase is not initialized.";

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null || sheet.maxRows < 2) {
          continue; // Skip empty or header-only sheets
        }

        final collectionName = _mapSheetToCollection(table);
        if (collectionName == null) continue; // Skip unknown sheets

        // Assuming Row 1 is Headers
        final headers = sheet.rows[0]
            .map((cell) => cell?.value?.toString() ?? '')
            .toList();
        final docs = <String, dynamic>{};

        for (int i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          final docData = <String, dynamic>{};
          String? docId;

          for (int j = 0; j < headers.length && j < row.length; j++) {
            final header = headers[j];
            final value = row[j]?.value;

            if (header.isEmpty || value == null) continue;

            if (header == 'id' || header == 'docId') {
              docId = value.toString();
            } else {
              docData[header] =
                  value; // Excel values are already typed (int, double, string, bool) mostly
            }
          }

          if (docData.isNotEmpty) {
            // Generate ID if missing
            final finalId =
                docId ?? firestore.collection(collectionName).doc().id;
            docs[finalId] = docData;
          }
        }

        if (docs.isNotEmpty) {
          await _batchImportCollection(collectionName, docs, userId, userName);
        }
      }

      return null;
    } catch (e) {
      handleError(e, 'importDataFromExcel');
      return "Excel Import error: $e";
    }
  }

  String? _mapSheetToCollection(String sheetName) {
    final lower = sheetName.toLowerCase().trim();
    if (lower.contains('product')) return 'products';
    if (lower.contains('route')) return 'routes';
    if (lower.contains('sale')) return 'sales';
    if (lower.contains('dealer') || lower.contains('dispatch')) {
      return 'sales'; // Dispatches are in sales
    }
    if (lower.contains('customer')) return 'customers';
    if (lower.contains('user')) return 'users';
    return lower; // Fallback: assume sheet name matches collection
  }

  Future<void> _batchImportCollection(
    String collectionName,
    Map<String, dynamic> docs,
    String userId,
    String userName,
  ) async {
    final firestore = db!;
    final docEntries = docs.entries.toList();

    for (int i = 0; i < docEntries.length; i += 400) {
      final batch = firestore.batch();
      final chunk = docEntries.sublist(
        i,
        (i + 400 < docEntries.length) ? i + 400 : docEntries.length,
      );

      for (var entry in chunk) {
        final docRef = firestore.collection(collectionName).doc(entry.key);
        batch.set(
          docRef,
          _processDocData(entry.value),
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    }

    await createAuditLog(
      collectionName: collectionName,
      docId: 'bulk_import_${DateTime.now().millisecondsSinceEpoch}',
      action: 'import',
      changes: {'count': docs.length, 'source': 'excel/json'},
      userId: userId,
      userName: userName,
    );
  }

  Map<String, dynamic> _processDocData(dynamic data) {
    if (data is! Map) return {};
    final processed = <String, dynamic>{};
    data.forEach((key, value) {
      // Clean up logic if needed
      processed[key] = value;
    });
    return processed;
  }

  Future<List<int>?> exportCollectionToExcel(String type) async {
    try {
      final firestore = db;
      if (firestore == null) return null;
      Query q;
      switch (type) {
        case 'sales':
          q = firestore
              .collection('sales')
              .where('recipientType', isEqualTo: 'customer');
          break;
        case 'dispatches':
          q = firestore
              .collection('sales')
              .where('recipientType', whereIn: ['dealer', 'salesman']);
          break;
        case 'routes':
          q = firestore.collection('routes');
          break;
        case 'route_orders':
          q = firestore.collection('route_orders');
          break;
        case 'products':
          q = firestore.collection('products');
          break;
        case 'production':
          q = firestore.collection('production_logs');
          break;
        default:
          q = firestore.collection(type);
      }

      final snapshot = await q.get();
      if (snapshot.docs.isEmpty) return null;

      final excel = Excel.createExcel();
      // Access sheet more safely or default to 'Sheet1'
      final sheetName = excel.sheets.keys.first;
      final sheet = excel[sheetName];

      // Headers
      final allKeys = {'id'};
      for (var d in snapshot.docs) {
        final data = d.data();
        if (data is Map<String, dynamic>) {
          allKeys.addAll(data.keys);
        }
      }
      final headers = allKeys.toList();
      sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

      // Rows
      for (var d in snapshot.docs) {
        final data = d.data() as Map<String, dynamic>;

        final row = <CellValue>[];
        for (var h in headers) {
          if (h == 'id') {
            row.add(TextCellValue(d.id));
          } else {
            final val = data[h];
            if (val == null) {
              row.add(TextCellValue(''));
            } else if (val is num) {
              row.add(IntCellValue(val.toInt()));
            } else {
              row.add(TextCellValue(val.toString()));
            }
          }
        }
        sheet.appendRow(row);
      }

      return excel.encode();
    } catch (e) {
      handleError(e, 'exportCollectionToExcel');
      return null;
    }
  }

  Future<String?> exportCollectionToCsv(String type) async {
    // ... (Existing CSV logic) ...
    // Keeping it simple for the user request to upgrade data bucket
    // I will just return the implementation I wrote above for CSV but updated with parallel count.
    // To avoid file size limit, I'll refer to previous implementation for CSV
    // but since I'm overwriting the file, I must provide full content.
    // Re-using the logic from previous view_file.

    // ... (Original CSV Implementation) ...
    try {
      final firestore = db;
      if (firestore == null) return null;

      Query q;
      // Same switch as before
      switch (type) {
        case 'sales':
          q = firestore
              .collection('sales')
              .where('recipientType', isEqualTo: 'customer');
          break;
        case 'dispatches':
          q = firestore
              .collection('sales')
              .where('recipientType', whereIn: ['dealer', 'salesman']);
          break;
        case 'routes':
          q = firestore.collection('routes');
          break;
        case 'route_orders':
          q = firestore.collection('route_orders');
          break;
        case 'production':
          q = firestore.collection('production_logs');
          break;
        case 'products':
          q = firestore.collection('products');
          break;
        default:
          // Try generic
          try {
            q = firestore.collection(type);
          } catch (_) {
            return null;
          }
      }

      final snapshot = await q.get();
      if (snapshot.docs.isEmpty) return null;

      final List<Map<String, dynamic>> data = snapshot.docs
          .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
          .toList();

      final Set<String> allKeys = {'id'};
      for (var doc in data) {
        allKeys.addAll(doc.keys);
      }
      final headers = allKeys.toList();

      final List<List<dynamic>> rows = [];
      rows.add(headers);

      for (var doc in data) {
        final List<dynamic> row = [];
        for (var h in headers) {
          var val = doc[h];
          if (val is Timestamp) {
            row.add(val.toDate().toString());
          } else if (val is Map || val is List) {
            row.add(json.encode(val));
          } else {
            row.add(val);
          }
        }
        rows.add(row);
      }

      return const ListToCsvConverter().convert(rows);
    } catch (e) {
      handleError(e, 'exportCollectionToCsv($type)');
      return null;
    }
  }
}
