import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar/isar.dart' as isar;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/sync/sync_queue_service.dart';
import '../constants/role_access_matrix.dart';
import 'offline_first_service.dart';
import '../services/database_service.dart';
import '../services/delegates/firestore_query_delegate.dart';
import '../services/field_encryption_service.dart';
import '../services/notification_service.dart';
import 'service_capability_guard.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/wastage_log_entity.dart';
import '../utils/app_logger.dart';

import '../models/inventory/stock_dispatch.dart'; // New Model
import '../data/local/entities/dispatch_entity.dart';
import '../data/local/entities/department_stock_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import 'delegates/inventory_queue_sync_delegate.dart';
import 'outbox_codec.dart';
import '../data/local/entities/stock_ledger_entity.dart';
import '../models/types/user_types.dart';
import '../models/types/sales_types.dart';
import '../models/types/inventory_types.dart';
import '../data/local/entities/product_entity.dart';
import '../data/local/entities/user_entity.dart';
import '../data/local/entities/sale_entity.dart';

import '../data/local/entities/stock_movement_entity.dart';

const stockMovementsCollection = 'stock_movements';
const salesCollection = 'sales';
const dispatchesCollection = 'dispatches';
const stockLedgerCollection = 'stock_ledger'; // Added

// Stock Usage Data model (from React StockUsageData interface)
class StockUsageData {
  final String productId;
  final String productName;
  final double allocatedPaid;
  final double allocatedFree;
  final double totalAllocated;
  final double paidSold;
  final double freeSold;
  final double totalSold;
  final double remainingPaid;
  final double remainingFree;
  final double remainingTotal;
  final double percentageSold;
  final String? lastSaleDate;
  final String baseUnit;
  final String? secondaryUnit;
  final double conversionFactor;
  final double price;
  final double? secondaryPrice;
  final String? category;
  final double todayAllocated;
  final double todaySold;
  final double availableToday;

  StockUsageData({
    required this.productId,
    required this.productName,
    required this.allocatedPaid,
    required this.allocatedFree,
    required this.totalAllocated,
    required this.paidSold,
    required this.freeSold,
    required this.totalSold,
    required this.remainingPaid,
    required this.remainingFree,
    required this.remainingTotal,
    required this.percentageSold,
    this.lastSaleDate,
    required this.baseUnit,
    this.secondaryUnit,
    required this.conversionFactor,
    required this.price,
    this.secondaryPrice,
    this.category,
    required this.todayAllocated,
    required this.todaySold,
    required this.availableToday,
  });
}

// Stock Movement Payload (from React AddStockMovementPayload)
class AddStockMovementPayload {
  final String productId;
  final String productName;
  final double quantity;
  final String movementType; // 'in' or 'out'
  final String reason;
  final String? referenceId;
  final String? referenceType;
  final String userId;
  final String? userName;

  AddStockMovementPayload({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.movementType,
    required this.reason,
    this.referenceId,
    this.referenceType,
    required this.userId,
    this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'movementType': movementType,
      'reason': reason,
      if (referenceId != null) 'referenceId': referenceId,
      if (referenceType != null) 'referenceType': referenceType,
      'userId': userId,
      if (userName != null) 'userName': userName,
    };
  }
}

/// [InventoryService] manages all stock-related operations in the system.
///
/// It handles:
/// - Stock movements (In/Out/Adjustments)
/// - Departmental stock issuance (e.g., to Bhatti or Production)
/// - Van loading (Dispatches) for salesmen
/// - Real-time stock usage calculation based on sales and allocations.
// ARCHITECTURE INVARIANT:
// products.stock = main warehouse stock only.
// Department stock is tracked separately in departmentStocks.
class InventoryService extends OfflineFirstService {
  final DatabaseService _dbService;
  final FieldEncryptionService _fieldEncryption =
      FieldEncryptionService.instance;
  ServiceCapabilityGuard get _capabilityGuard =>
      ServiceCapabilityGuard(auth: auth, dbService: _dbService);

  static const Set<UserRole> _warehouseMutationRoleOverrides = {
    UserRole.productionManager,
    UserRole.productionSupervisor,
    UserRole.bhattiSupervisor,
    UserRole.dispatchManager,
    UserRole.salesManager,
  };

  static const Set<UserRole> _dispatchReceiveRoleOverrides = {
    UserRole.salesman,
    UserRole.dealerManager,
    UserRole.dispatchManager,
    UserRole.salesManager,
    UserRole.productionManager,
    UserRole.productionSupervisor,
    UserRole.bhattiSupervisor,
  };

  static const Set<UserRole> _stockFinancialMutationRoles = {
    UserRole.owner,
    UserRole.admin,
    UserRole.storeIncharge,
    UserRole.productionManager,
    UserRole.productionSupervisor,
    UserRole.bhattiSupervisor,
    UserRole.dispatchManager,
    UserRole.salesManager,
    UserRole.dealerManager,
    UserRole.salesman,
  };

  static const double _priceMagnitude = 1e5;
  static const int _stockLedgerPageSize = 500;

  // [DIAGNOSTIC] Safe Mode to prevent Sync for testing crash
  // SET TO TRUE: Confirmed crash is in Firebase C++ SDK sync on Windows.
  // NOTE: This prevents complex Firestore transactions on Windows to ensure stability.
  static bool safeMode = true;

  InventoryService(super.firebase, this._dbService);

  Future<AppUser> _requireInventoryMutationActor(
    String operation, {
    bool requireInventoryCapability = true,
    Set<UserRole> allowedRoles = const <UserRole>{},
  }) {
    return _capabilityGuard.requireCapabilityOrRole(
      operation: operation,
      capability: requireInventoryCapability
          ? RoleCapability.inventoryMutate
          : null,
      allowedRoles: allowedRoles,
    );
  }

  bool get _isWindowsSafeMode {
    return safeMode &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.windows;
  }

  Future<List<StockLedgerEntity>> _fetchStockLedgerPaged({
    String? productId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _dbService.stockLedger.filter().isDeletedEqualTo(false);

    if (productId != null && productId.trim().isNotEmpty) {
      query = query.and().productIdEqualTo(productId.trim());
    }

    if (startDate != null) {
      query = query.and().transactionDateGreaterThan(startDate, include: true);
    }

    if (endDate != null) {
      query = query.and().transactionDateLessThan(endDate, include: true);
    }

    final entries = <StockLedgerEntity>[];
    var offset = 0;
    while (true) {
      final chunk = await query
          .offset(offset)
          .limit(_stockLedgerPageSize)
          .findAll();
      if (chunk.isEmpty) {
        break;
      }
      entries.addAll(chunk);
      if (chunk.length < _stockLedgerPageSize) {
        break;
      }
      offset += _stockLedgerPageSize;
    }
    return entries;
  }

  String _generateDispatchReference(String dispatchDocId) {
    final token = _sanitizeDeterministicToken(
      dispatchDocId,
    ).replaceAll('_', '');
    final normalized = token.isEmpty ? 'UNKNOWN' : token.toUpperCase();
    final suffix = normalized.length > 12
        ? normalized.substring(0, 12)
        : normalized.padRight(12, 'X');
    return 'DSP-$suffix';
  }

  /// Canonical department key used for all local department stock rows.
  ///
  /// Keeps Bhatti naming intact (`sona bhatti`, `gita bhatti`) and maps
  /// production aliases (`sona production`, `gita production`) to the
  /// production keys already used by cutting (`sona`, `gita`).
  String normalizeDepartmentKey(String departmentName) {
    final normalized = departmentName
        .trim()
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');

    if (normalized == 'sona production') return 'sona';
    if (normalized == 'gita production') return 'gita';

    return normalized;
  }

  List<String> _departmentAliasesForLookup(String departmentName) {
    final canonical = normalizeDepartmentKey(departmentName);
    final aliases = <String>{canonical};

    if (canonical == 'sona') {
      aliases
        ..add('sona production')
        ..add('sona_production');
    } else if (canonical == 'gita') {
      aliases
        ..add('gita production')
        ..add('gita_production');
    } else if (canonical == 'sona bhatti') {
      aliases.add('sona_bhatti');
    } else if (canonical == 'gita bhatti') {
      aliases.add('gita_bhatti');
    }

    final rawNormalized = departmentName.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    if (rawNormalized.isNotEmpty) {
      aliases
        ..add(rawNormalized)
        ..add(rawNormalized.replaceAll(' ', '_'))
        ..add(rawNormalized.replaceAll('_', ' '));
    }

    return aliases.toList(growable: false);
  }

  Map<String, AllocatedStockItem> _safeParseAllocatedStock(dynamic raw) {
    if (raw is! Map) return <String, AllocatedStockItem>{};
    final parsed = <String, AllocatedStockItem>{};
    raw.forEach((key, value) {
      if (key == null || value == null || value is! Map) return;
      try {
        parsed[key.toString()] = AllocatedStockItem.fromJson(
          Map<String, dynamic>.from(value),
        );
      } catch (e) {
        debugPrint('Skipping malformed allocated stock item for key=$key: $e');
      }
    });
    return parsed;
  }

  String _sanitizeDeterministicToken(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return 'unknown';
    return normalized.replaceAll(RegExp(r'[^a-z0-9_\-]'), '_');
  }

  String _buildStockMutationCommandKey({
    required String collection,
    required String action,
    required Map<String, dynamic> payload,
  }) {
    final explicit = OutboxCodec.readIdempotencyKey(payload);
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }
    final normalized = Map<String, dynamic>.from(payload)
      ..remove(OutboxCodec.idempotencyKeyField);
    final digest = fastHash(jsonEncode(normalized)).toString();
    return '${_sanitizeDeterministicToken(collection)}_${_sanitizeDeterministicToken(action)}_$digest';
  }

  String _deterministicDispatchMovementId({
    required String dispatchId,
    required String productId,
    required bool isFree,
    int itemIndex = 0,
  }) {
    final token =
        '${_sanitizeDeterministicToken(dispatchId)}_${_sanitizeDeterministicToken(productId)}_${isFree ? 'free' : 'paid'}_$itemIndex';
    final digest = fastHash(token).toString();
    return 'dispatch_move_$digest';
  }

  @override
  String get localStorageKey => 'local_stock_movements';

  // --- DISPATCH HISTORY & RECEIVING (Strict ERP Logic) ---

  /// 1. Get Dispatches for Salesman (Read-Only History)
  /// Queries the 'dispatches' collection. Does NOT calculate stock.
  Future<List<StockDispatch>> getDispatchesForSalesman({
    required String salesmanId,
    String? routeName,
    int limit = 20,
    firestore.DocumentSnapshot? lastDoc,
  }) async {
    try {
      final normalizedRouteName = routeName?.trim();
      var query = _dbService.dispatches.filter().salesmanIdEqualTo(salesmanId);

      if (normalizedRouteName != null && normalizedRouteName.isNotEmpty) {
        query = query.dispatchRouteEqualTo(normalizedRouteName);
      }

      var localDispatches = await query
          .sortByCreatedAtDesc()
          .limit(limit)
          .findAll();

      if (localDispatches.isEmpty && db != null) {
        final firestoreRef = db;
        if (firestoreRef != null) {
          var fbQuery = firestoreRef
              .collection(dispatchesCollection)
              .where('salesmanId', isEqualTo: salesmanId)
              .orderBy('createdAt', descending: true);

          if (normalizedRouteName != null && normalizedRouteName.isNotEmpty) {
            fbQuery = fbQuery.where(
              'dispatchRoute',
              isEqualTo: normalizedRouteName,
            );
          }
          fbQuery = fbQuery.limit(limit);

          if (lastDoc != null) {
            fbQuery = fbQuery.startAfterDocument(lastDoc);
          }

          final snapshot = await fbQuery.get();
          final mapped = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return DispatchEntity.fromDomain(StockDispatch.fromJson(data));
          }).toList();

          await _dbService.db.writeTxn(() async {
            await _dbService.dispatches.putAll(mapped);
          });
          localDispatches = mapped;
        }
      }

      return localDispatches.map((e) => e.toDomain()).toList();
    } catch (e) {
      throw handleError(e, 'getDispatchesForSalesman');
    }
  }

  /// For Admin History View
  Future<List<StockDispatch>> getAllDispatches({
    String? salesmanId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      var query = _dbService.dispatches.filter().isDeletedEqualTo(false);
      if (salesmanId != null) {
        query = query.and().salesmanIdEqualTo(salesmanId);
      }
      if (startDate != null) {
        query = query.and().createdAtGreaterThan(startDate);
      }
      if (endDate != null) {
        query = query.and().createdAtLessThan(endDate);
      }

      var localDispatches = await query.findAll();
      localDispatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (localDispatches.length > limit) {
        localDispatches = localDispatches.sublist(0, limit);
      }

      if (localDispatches.isEmpty && db != null) {
        final firestoreRef = db;
        if (firestoreRef != null) {
          var fbQuery = firestoreRef
              .collection(dispatchesCollection)
              .orderBy('createdAt', descending: true);

          if (salesmanId != null) {
            fbQuery = fbQuery.where('salesmanId', isEqualTo: salesmanId);
          }

          if (startDate != null) {
            fbQuery = fbQuery.where(
              'createdAt',
              isGreaterThanOrEqualTo: startDate.toIso8601String(),
            );
          }
          if (endDate != null) {
            fbQuery = fbQuery.where(
              'createdAt',
              isLessThanOrEqualTo: endDate.toIso8601String(),
            );
          }

          fbQuery = fbQuery.limit(limit);

          final snapshot = await fbQuery.get();
          final mapped = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return DispatchEntity.fromDomain(StockDispatch.fromJson(data));
          }).toList();

          await _dbService.db.writeTxn(() async {
            await _dbService.dispatches.putAll(mapped);
          });
          localDispatches = mapped;
        }
      }

      return localDispatches.map((e) => e.toDomain()).toList();
    } catch (e) {
      throw handleError(e, 'getAllDispatches');
    }
  }

  /// 2. Get Salesman Current Stock (State)
  /// Reads ONLY from available stock. No history calculation.
  Future<bool> _hasPendingSalesSyncForSalesman(String salesmanId) async {
    final pendingLocalSales = await _dbService.sales
        .filter()
        .salesmanIdEqualTo(salesmanId)
        .and()
        .syncStatusEqualTo(SyncStatus.pending)
        .count();
    if (pendingLocalSales > 0) return true;

    final pendingQueueItems = await _dbService.syncQueue
        .filter()
        .collectionEqualTo(salesCollection)
        .and()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
    if (pendingQueueItems.isEmpty) return false;

    for (final item in pendingQueueItems) {
      try {
        final envelope = OutboxCodec.decode(
          item.dataJson,
          fallbackQueuedAt: item.createdAt,
        );
        final payloadSalesmanId =
            envelope.payload['salesmanId']?.toString().trim() ?? '';
        if (payloadSalesmanId == salesmanId) {
          return true;
        }
      } catch (_) {
        // Ignore malformed queue rows and continue checking other items.
      }
    }
    return false;
  }

  Future<Map<String, AllocatedStockItem>> getSalesmanCurrentStock(
    String salesmanId,
  ) async {
    try {
      Map<String, AllocatedStockItem> localStock = {};
      UserEntity? localUser;

      // Try Local First
      final user = await _dbService.users.getById(salesmanId);
      localUser = user;
      if (user != null && user.allocatedStockJson != null) {
        final dynamic localJson = jsonDecode(user.allocatedStockJson!);
        localStock = _safeParseAllocatedStock(localJson);
      }
      final hasPendingSales = await _hasPendingSalesSyncForSalesman(salesmanId);

      // Refresh from Firestore when available, then mirror locally.
      final firestoreRef = db;
      if (firestoreRef != null) {
        final doc = await FirestoreQueryDelegate(firestoreRef).getDocument(
          collection: 'users',
          documentId: salesmanId,
        );
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data['allocatedStock'] != null) {
            final dynamic rawStock = data['allocatedStock'];
            final remoteStock = _safeParseAllocatedStock(rawStock);
            final remoteJson = jsonEncode(rawStock);
            if (hasPendingSales && localStock.isNotEmpty) {
              // Preserve locally-adjusted stock while sales are waiting in queue.
              return localStock;
            }
            if (!hasPendingSales &&
                localUser != null &&
                localUser.allocatedStockJson != remoteJson) {
              final existingUser = localUser;
              await _dbService.db.writeTxn(() async {
                existingUser
                  ..allocatedStockJson = remoteJson
                  ..updatedAt = DateTime.now()
                  ..syncStatus = SyncStatus.synced;
                await _dbService.users.put(existingUser);
              });
            }
            return remoteStock;
          }
        }
      }
      return localStock;
    } catch (e) {
      throw handleError(e, 'getSalesmanCurrentStock');
    }
  }

  /// 3. Receive Dispatch (Strict Transaction)
  /// - Updates Dispatch Status -> RECEIVED
  /// - Increments Salesman Stock
  /// - Idempotent (Checks status first)
  Future<void> receiveDispatch(String dispatchId) async {
    try {
      await _requireInventoryMutationActor(
        'receive dispatch',
        requireInventoryCapability: false,
        allowedRoles: _dispatchReceiveRoleOverrides,
      );
      final dispatchEntity = await _dbService.dispatches.getById(dispatchId);
      if (dispatchEntity == null || dispatchEntity.isDeleted) {
        throw Exception('Dispatch $dispatchId not found locally');
      }

      final currentStatus = dispatchEntity.status.trim().toLowerCase();
      if (currentStatus == 'received' ||
          currentStatus == 'closed' ||
          currentStatus == 'completed') {
        return;
      }

      final receivedAt = DateTime.now();
      Map<String, dynamic>? queuePayload;
      await _dbService.db.writeTxn(() async {
        dispatchEntity
          ..status = DispatchStatus.received.name
          ..receivedAt = receivedAt
          ..updatedAt = receivedAt
          ..syncStatus = SyncStatus.pending;
        await _dbService.dispatches.put(dispatchEntity);
        queuePayload = dispatchEntity.toDomain().toJson()
          ..['id'] = dispatchEntity.id
          ..['status'] = DispatchStatus.received.name
          ..['receivedAt'] = receivedAt.toIso8601String()
          ..['updatedAt'] = receivedAt.toIso8601String()
          ..['isSynced'] = false;
      });
      if (queuePayload != null) {
        await SyncQueueService.instance.addToQueue(
          collectionName: dispatchesCollection,
          documentId: dispatchId,
          operation: 'update',
          payload: queuePayload!,
        );
      }
    } catch (e) {
      throw handleError(e, 'receiveDispatch');
    }
  }

  @override
  Future<void> performSync(
    String action,
    String collection,
    Map<String, dynamic> data,
  ) async {
    final isStockFinancialMutation =
        (collection == stockMovementsCollection && action == 'add') ||
        (collection == 'department_stocks' &&
            (action == 'issue_to_department' ||
                action == 'return_from_department')) ||
        (collection == dispatchesCollection && action == 'add') ||
        (collection == stockLedgerCollection &&
            (action == 'add' || action == 'set' || action == 'update'));
    if (isStockFinancialMutation) {
      final allowedRoles = collection == dispatchesCollection
          ? _dispatchReceiveRoleOverrides
          : _warehouseMutationRoleOverrides;
      await _requireInventoryMutationActor(
        'sync inventory mutation [$collection/$action]',
        requireInventoryCapability: true,
        allowedRoles: allowedRoles,
      );
    }

    final firestoreRef = db;
    if (firestoreRef == null) return;
    final delegate = InventoryQueueSyncDelegate(firestoreRef);
    final handled = await delegate.performSync(
      action,
      collection,
      data,
      useWindowsSafeMode: _isWindowsSafeMode,
    );
    if (handled) {
      return;
    }

    await super.performSync(action, collection, data);
  }

  /// Issues stock to a department via Firestore Batch (safe mode, Windows only).
  ///
  /// ISSUE B NOTE (Documented Limitation): Same as `_safeDispatchSync` — uses
  /// `firestore.batch()` instead of `runTransaction()` due to Firebase C++ SDK
  /// limitations on Windows. The read (get product stock) and write (batch.commit)
  /// are NOT atomic. Risk is accepted under single-user-device assumption.
  // ignore: unused_element
  /// Syncs a dispatch to Firestore using a Firestore Batch (not a Transaction).
  ///
  /// BUG 4 NOTE (Documented Limitation): This uses `firestore.batch()` instead of
  /// `runTransaction()` because the Firebase C++ SDK on Windows has known issues
  /// with nested transactions. As a result, this is NOT fully atomic — if two
  /// dispatches for the same product run concurrently (e.g., a retry racing with
  /// a new dispatch), there is a theoretical race condition where stock could go
  /// negative between the `productRef.get()` read and the `batch.commit()` write.
  ///
  /// ASSUMPTION: Safe-mode dispatches are processed from a **single-user,
  /// single-device** context (Windows admin station). Multi-user concurrent
  /// dispatch via Windows is not a supported workflow, so this risk is accepted.
  /// If concurrent dispatch on Windows is ever needed, replace with a Cloud
  /// Function or a server-side transaction.
  // ignore: unused_element
  /// Calculates the real-time stock usage for a specific [salesmanId].
  ///
  /// This aggregates local sales data against the [allocatedStock] to determine
  /// sold quantities, remaining balance, and sales velocity (percentage sold).
  /// It follows a single-source-of-truth local-first strategy with a Firestore fallback.
  Future<List<StockUsageData>> calculateStockUsage(
    String salesmanId,
    Map<String, AllocatedStockItem> allocatedStock,
  ) async {
    try {
      if (allocatedStock.isEmpty) {
        return [];
      }

      // 1. Try Local First (Strategy: Single Source of Truth)
      List<Sale> sales = await _getLocalSales(salesmanId);

      // 2. Fallback / Bootstrap (Optional - logic similar to SalesService)
      if (sales.isEmpty) {
        final firestore = db;
        if (firestore != null) {
          try {
            final salesRef = firestore.collection(salesCollection);
            final q = salesRef
                .where('salesmanId', isEqualTo: salesmanId)
                .where('recipientType', isEqualTo: 'customer')
                .limit(100); // Limit for safety

            final snapshot = await q.get().timeout(const Duration(seconds: 10));
            sales = snapshot.docs.map((doc) {
              final data = Map<String, dynamic>.from(doc.data());
              data['id'] = doc.id;
              return Sale.fromJson(data);
            }).toList();
          } catch (_) {
            // Ignore sync errors, stick to empty local
          }
        }
      }

      // Get today's date range
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayStr = todayStart.toIso8601String();

      // Calculate sold quantities per product
      final soldQuantities = <String, Map<String, dynamic>>{};

      for (final sale in sales) {
        // Ensure we only process CUSTOMER sales
        if (sale.recipientType != 'customer') continue;

        final isTodaySale = sale.createdAt.compareTo(todayStr) >= 0;

        for (final item in sale.items) {
          if (!soldQuantities.containsKey(item.productId)) {
            soldQuantities[item.productId] = {
              'paid': 0.0,
              'free': 0.0,
              'todaySold': 0.0,
              'lastSaleDate': null,
            };
          }

          if (item.isFree) {
            soldQuantities[item.productId]!['free'] += item.quantity;
          } else {
            soldQuantities[item.productId]!['paid'] += item.quantity;
          }

          // Track today's sales
          if (isTodaySale) {
            soldQuantities[item.productId]!['todaySold'] += item.quantity;
          }

          // Track last sale date
          final currentLastDate =
              soldQuantities[item.productId]!['lastSaleDate'];
          if (currentLastDate == null ||
              sale.createdAt.compareTo(currentLastDate) > 0) {
            soldQuantities[item.productId]!['lastSaleDate'] = sale.createdAt;
          }
        }
      }

      // Build stock usage data
      final stockUsageData = allocatedStock.entries.map((entry) {
        final productId = entry.key;
        final stock = entry.value;
        final sold =
            soldQuantities[productId] ??
            {'paid': 0.0, 'free': 0.0, 'todaySold': 0.0};

        final remainingPaid = stock.quantity.toDouble();
        final remainingFree = (stock.freeQuantity ?? 0.0).toDouble();
        final remainingTotal = remainingPaid + remainingFree;

        final paidSold = (sold['paid'] as double? ?? 0.0);
        final freeSold = (sold['free'] as double? ?? 0.0);
        final totalSold = paidSold + freeSold;

        // Reconstruct "Start" allocation for display purposes
        final allocatedPaid = remainingPaid + paidSold;
        final allocatedFree = remainingFree + freeSold;
        final totalAllocated = allocatedPaid + allocatedFree;
        final percentageSold = totalAllocated > 0
            ? (totalSold / totalAllocated) * 100
            : 0.0;

        // Today's metrics
        final todayAllocated = totalAllocated;
        final todaySold = (sold['todaySold'] as double? ?? 0.0);
        final availableToday = remainingTotal.clamp(0.0, double.infinity);

        return StockUsageData(
          productId: productId,
          productName: stock.name,
          allocatedPaid: allocatedPaid.toDouble(),
          allocatedFree: allocatedFree.toDouble(),
          totalAllocated: totalAllocated.toDouble(),
          paidSold: paidSold,
          freeSold: freeSold,
          totalSold: totalSold,
          remainingPaid: remainingPaid,
          remainingFree: remainingFree,
          remainingTotal: remainingTotal,
          percentageSold: percentageSold,
          lastSaleDate: sold['lastSaleDate'] as String?,
          baseUnit: stock.baseUnit,
          secondaryUnit: stock.secondaryUnit,
          conversionFactor: stock.conversionFactor.toDouble(),
          price: stock.price,
          secondaryPrice: stock.secondaryPrice,
          todayAllocated: todayAllocated.toDouble(),
          todaySold: todaySold.toDouble(),
          availableToday: availableToday.toDouble(),
        );
      }).toList();

      return stockUsageData;
    } catch (e) {
      handleError(e, 'calculateStockUsage');
      // Fallback: Return allocated only
      return allocatedStock.entries.map((entry) {
        final stock = entry.value;
        final total = stock.quantity + (stock.freeQuantity ?? 0);
        return StockUsageData(
          productId: entry.key,
          productName: stock.name,
          allocatedPaid: stock.quantity.toDouble(),
          allocatedFree: (stock.freeQuantity ?? 0).toDouble(),
          totalAllocated: total.toDouble(),
          paidSold: 0,
          freeSold: 0,
          totalSold: 0, // No sales data
          remainingPaid: stock.quantity.toDouble(),
          remainingFree: (stock.freeQuantity ?? 0).toDouble(),
          remainingTotal: total.toDouble(),
          percentageSold: 0,
          baseUnit: stock.baseUnit,
          conversionFactor: stock.conversionFactor.toDouble(),
          price: stock.price,
          todayAllocated: total.toDouble(),
          todaySold: 0,
          availableToday: total.toDouble(),
        );
      }).toList();
    }
  }

  // Add stock movement record
  Future<String> addStockMovement(AddStockMovementPayload payload) async {
    try {
      await _requireInventoryMutationActor(
        'add stock movement',
        requireInventoryCapability: true,
        allowedRoles: _warehouseMutationRoleOverrides,
      );
      final now = DateTime.now();

      // ATOMIC: Update Stock + Ledger
      await _dbService.db.writeTxn(() async {
        final change = payload.movementType == 'in'
            ? payload.quantity
            : -payload.quantity;

        // Capture updated product to get accurate post-update stock for ledger
        final updatedProduct = await applyProductStockChangeInTxn(
          productId: payload.productId,
          quantityChange: change,
          enforceNonNegative: payload.movementType == 'out',
          updatedAt: now,
          markSyncPending: true,
        );

        // 2. Create Stock Ledger Entry with ACCURATE running balance
        await _createLedgerEntry(
          productId: payload.productId,
          warehouseId: 'Main',
          transactionType: payload.movementType.toUpperCase(),
          quantityChange: change,
          performedBy: payload.userId,
          reason: payload.reason,
          referenceId: payload.referenceId,
          notes: payload.reason,
          // FIX #4: Pass post-update balance explicitly (never stale)
          runningBalanceOverride: updatedProduct?.stock,
        );
      });

      return payload.toJson()['id'] ?? generateId();
    } catch (e) {
      handleError(e, 'addStockMovement');
      return '';
    }
  }

  /// Validates that sufficient stock exists for a deduction.
  /// Throws exception if stock would go negative.
  ///
  /// ARCHITECTURE LOCK: INVARIANT stock >= 0 ALWAYS
  /// MUST be called inside transaction BEFORE any stock deduction.

  /// Internal helper to create and save a Stock Ledger Entry locally (Isar)
  /// NOTE: This is now PURE. It does NOT update product stock.
  /// Stock updates must be handled by the caller within the same transaction.
  /// Running balance is derived centrally from the current product stock (or an override for non-product ledgers).
  Future<void> _createLedgerEntry({
    required String productId,
    required String warehouseId,
    required String transactionType,
    required double quantityChange,
    String? unit,
    required String performedBy,
    required String reason,
    String? referenceId,
    String? notes,
    double? runningBalanceOverride,
  }) async {
    try {
      final now = DateTime.now();

      // Derive running balance centrally; fallback to override for non-product ledgers (e.g., salesman allocation)
      final product = await _dbService.products.getById(productId);
      final runningBalance = runningBalanceOverride ?? product?.stock ?? 0.0;
      final effectiveUnit = unit ?? product?.baseUnit ?? 'Unit';

      final entry = StockLedgerEntity()
        ..id = generateId()
        ..productId = productId
        ..warehouseId = warehouseId
        ..transactionDate = now
        ..transactionType = transactionType
        ..referenceId = referenceId
        ..quantityChange = quantityChange
        ..runningBalance = runningBalance
        ..unit = effectiveUnit
        ..performedBy = performedBy
        ..notes = notes
        ..syncStatus = SyncStatus.pending
        ..updatedAt = now;

      await _dbService.stockLedger.put(entry);
    } catch (e) {
      handleError(e, '_createLedgerEntry');
      rethrow;
    }
  }

  /// Apply a product stock delta inside an existing Isar writeTxn.
  /// Caller is responsible for validation and transaction scope.
  Future<ProductEntity?> applyProductStockChangeInTxn({
    required String productId,
    required double quantityChange,
    String? unit,
    double? conversionFactorOverride,
    bool enforceNonNegative = true,
    DateTime? updatedAt,
    bool markSyncPending = true,
    bool allowMissing = false,
    String warehouseId = 'Main',
    bool createLedger = false,
    String? transactionType,
    String? performedBy,
    String? reason,
    String? referenceId,
    String? notes,
    void Function(ProductEntity product)? mutate,
  }) async {
    final product = await _dbService.products.getById(productId);
    if (product == null) {
      if (allowMissing) return null;
      throw Exception('Product not found: $productId');
    }

    // Normalize quantity to base unit if caller passed secondary unit
    final conversionFactor =
        conversionFactorOverride ?? product.conversionFactor ?? 1.0;
    final baseQuantityChange =
        (unit != null &&
            product.secondaryUnit != null &&
            unit == product.secondaryUnit &&
            conversionFactor > 0)
        ? quantityChange * conversionFactor
        : quantityChange;

    final newStock = (product.stock ?? 0) + baseQuantityChange;
    if (enforceNonNegative && newStock < -1e-9) {
      throw Exception(
        'Insufficient stock for product $productId. Available: ${product.stock ?? 0}, required change: $quantityChange',
      );
    }

    product.stock = newStock;
    if (mutate != null) {
      mutate(product);
    }
    if (updatedAt != null) {
      product.updatedAt = updatedAt;
    }
    if (markSyncPending) {
      product.syncStatus = SyncStatus.pending;
    }

    await _dbService.products.put(product);

    if (createLedger && transactionType != null) {
      await _createLedgerEntry(
        productId: productId,
        warehouseId: warehouseId,
        transactionType: transactionType,
        quantityChange: baseQuantityChange,
        unit: unit ?? product.baseUnit,
        performedBy: performedBy ?? 'system',
        reason: reason ?? transactionType,
        referenceId: referenceId,
        notes: notes,
      );
    }

    return product;
  }

  /// Apply a department stock delta inside an existing Isar writeTxn.
  /// Caller is responsible for validation and transaction scope.
  Future<DepartmentStockEntity?> applyDepartmentStockChangeInTxn({
    required String departmentName,
    required String productId,
    required double quantityChange,
    String? productName,
    String? unit,
    DateTime? updatedAt,
    bool markSyncPending = true,
    bool createIfMissing = true,
    bool enforceNonNegative = true,
  }) async {
    final normalizedDept = normalizeDepartmentKey(departmentName);
    final lookupAliases = _departmentAliasesForLookup(departmentName);

    final existingForProduct = await _dbService.departmentStocks
        .filter()
        .productIdEqualTo(productId)
        .findAll();

    DepartmentStockEntity? stockEntity;
    for (final alias in lookupAliases) {
      for (final candidate in existingForProduct) {
        if (candidate.departmentName == alias) {
          stockEntity = candidate;
          break;
        }
      }
      if (stockEntity != null) break;
    }

    final bool isNew = stockEntity == null;

    if (stockEntity == null) {
      if (!createIfMissing || quantityChange < 0) {
        return null;
      }
      stockEntity = DepartmentStockEntity()
        ..id =
            "${normalizedDept}_$productId" // BUG 5 FIX: normalized key
        ..departmentName =
            normalizedDept // BUG 5 FIX: normalized name
        ..productId = productId
        ..productName = productName ?? 'Unknown'
        ..stock = quantityChange
        ..unit = unit ?? 'Unit';
    } else {
      if (stockEntity.departmentName != normalizedDept) {
        stockEntity
          ..departmentName = normalizedDept
          ..id = "${normalizedDept}_$productId";
      }
      final newStock = stockEntity.stock + quantityChange;
      if (enforceNonNegative && newStock < -1e-9) {
        throw Exception(
          'Insufficient department stock for $productId in $departmentName. Available: ${stockEntity.stock}, requested change: $quantityChange',
        );
      }
      stockEntity.stock = newStock;
    }

    if (updatedAt != null) {
      stockEntity.updatedAt = updatedAt;
    } else if (isNew) {
      stockEntity.updatedAt = DateTime.now();
    }

    if (markSyncPending) {
      stockEntity.syncStatus = SyncStatus.pending;
    }

    await _dbService.departmentStocks.put(stockEntity);
    return stockEntity;
  }

  Future<List<Map<String, dynamic>>> getStockMovements({
    String? productId,
    String? movementType,
    DateTime? startDate,
    DateTime? endDate,
    int? limitCount,
  }) async {
    try {
      var query = _dbService.stockMovements.filter().isDeletedEqualTo(false);

      if (productId != null) {
        query = query.and().productIdEqualTo(productId);
      }

      if (movementType != null) {
        query = query.and().movementTypeEqualTo(movementType);
      }

      if (startDate != null) {
        query = query.and().createdAtGreaterThan(startDate);
      }

      if (endDate != null) {
        query = query.and().createdAtLessThan(endDate);
      }

      var localMovements = await query.findAll();
      localMovements.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (limitCount != null) {
        localMovements = localMovements.take(limitCount).toList();
      }

      if (localMovements.isEmpty && db != null) {
        final firestoreRef = db;
        if (firestoreRef != null) {
          firestore.Query fbQuery = firestoreRef.collection(
            stockMovementsCollection,
          );

          if (productId != null) {
            fbQuery = fbQuery.where('productId', isEqualTo: productId);
          }
          if (movementType != null) {
            fbQuery = fbQuery.where('movementType', isEqualTo: movementType);
          }
          if (startDate != null) {
            fbQuery = fbQuery.where(
              'createdAt',
              isGreaterThanOrEqualTo: startDate.toIso8601String(),
            );
          }
          if (endDate != null) {
            fbQuery = fbQuery.where(
              'createdAt',
              isLessThanOrEqualTo: endDate.toIso8601String(),
            );
          }

          fbQuery = fbQuery.orderBy('createdAt', descending: false);

          if (limitCount != null) {
            fbQuery = fbQuery.limit(limitCount);
          }

          final snapshot = await fbQuery.get();
          final fetchedEntities = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            data['id'] = doc.id;

            DateTime createdAt;
            final dynamic rawDate = data['createdAt'];
            if (rawDate is firestore.Timestamp) {
              createdAt = rawDate.toDate();
            } else if (rawDate is String) {
              createdAt = DateTime.tryParse(rawDate) ?? DateTime.now();
            } else {
              createdAt = DateTime.now();
            }

            return StockMovementEntity()
              ..id = data['id'] as String
              ..productId = data['productId'] as String
              ..productName = data['productName'] as String? ?? 'Unknown'
              ..quantity = (data['quantity'] as num?)?.toDouble() ?? 0.0
              ..type = data['type'] as String? ?? 'out'
              ..movementType = data['movementType'] as String? ?? 'out'
              ..source = data['source'] as String? ?? 'unknown'
              ..reason = data['reason'] as String? ?? 'unknown'
              ..referenceId = data['referenceId'] as String?
              ..referenceNumber = data['referenceNumber'] as String?
              ..referenceType = data['referenceType'] as String?
              ..notes = data['notes'] as String?
              ..userId = data['userId'] as String? ?? 'system'
              ..userName = data['userName'] as String? ?? 'System'
              ..createdBy = data['createdBy'] as String? ?? 'system'
              ..createdAt = createdAt
              ..isSynced = true
              ..syncStatus = SyncStatus.synced;
          }).toList();

          await _dbService.db.writeTxn(() async {
            await _dbService.stockMovements.putAll(fetchedEntities);
          });

          localMovements = fetchedEntities;
        }
      }

      // Convert back to map format expected by UI
      return localMovements
          .map(
            (e) => {
              'id': e.id,
              'productId': e.productId,
              'productName': e.productName,
              'quantity': e.quantity,
              'type': e.type,
              'movementType': e.movementType,
              'source': e.source,
              'reason': e.reason,
              'referenceId': e.referenceId,
              'referenceNumber': e.referenceNumber,
              'referenceType': e.referenceType,
              'notes': e.notes,
              'userId': e.userId,
              'userName': e.userName,
              'createdBy': e.createdBy,
              'createdAt': e.createdAt.toIso8601String(),
              'isSynced': e.syncStatus == SyncStatus.synced,
            },
          )
          .toList();
    } catch (e) {
      throw handleError(e, 'getStockMovements');
    }
  }

  Future<List<StockLedgerEntity>> getStockLedgerEntries({
    String? productId,
    DateTime? startDate,
    DateTime? endDate,
    int? limitCount,
  }) async {
    try {
      var entries = await _fetchStockLedgerPaged(
        productId: productId,
        startDate: startDate,
        endDate: endDate,
      );
      entries.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

      if (limitCount != null && entries.length > limitCount) {
        entries = entries.sublist(entries.length - limitCount);
      }

      return entries;
    } catch (e) {
      throw handleError(e, 'getStockLedgerEntries');
    }
  }

  // Issue materials (reduce stock and log movement)
  Future<bool> issueMaterials({
    required List<Map<String, dynamic>> items,
    required String reason,
    required String issuedTo,
    required String userId,
    required String userName,
    String? referenceId,
  }) async {
    await _requireInventoryMutationActor(
      'issue materials',
      requireInventoryCapability: true,
      allowedRoles: _warehouseMutationRoleOverrides,
    );
    return transferToDepartment(
      departmentName: issuedTo,
      items: items,
      issuedByUserId: userId,
      issuedByUserName: userName,
      notes: reason,
      referenceId: referenceId,
    );
  }

  /// Transfers stock from the main warehouse to a specific department.
  ///
  /// This performs an atomic local transaction:
  /// 1. Decrements the warehouse product stock.
  /// 2. Increments the target department's stock.
  /// 3. Queues a sync action for Firestore reconciliation.
  Future<bool> transferToDepartment({
    required String departmentName,
    required List<Map<String, dynamic>> items,
    required String issuedByUserId,
    required String issuedByUserName,
    String? notes,
    String? referenceId,
  }) async {
    try {
      await _requireInventoryMutationActor(
        'transfer stock to department',
        requireInventoryCapability: true,
        allowedRoles: _warehouseMutationRoleOverrides,
      );
      final now = DateTime.now();
      final syncPayloads = <Map<String, dynamic>>[];

      await _dbService.db.writeTxn(() async {
        for (final item in items) {
          final productId = item['productId'] as String;
          final quantity = (item['quantity'] as num).toDouble();
          final productName = item['productName'] as String? ?? 'Unknown';

          final updatedProduct = await applyProductStockChangeInTxn(
            productId: productId,
            quantityChange: -quantity,
            unit: item['unit'] as String? ?? 'Unit',
            enforceNonNegative: true,
            updatedAt: now,
            markSyncPending: true,
          );

          final deptStock = await applyDepartmentStockChangeInTxn(
            departmentName: departmentName,
            productId: productId,
            quantityChange: quantity,
            productName: productName,
            unit: item['unit'] as String? ?? 'Unit',
            updatedAt: now,
            markSyncPending: true,
            createIfMissing: true,
            enforceNonNegative: false,
          );
          if (deptStock == null) {
            throw Exception(
              'Failed to update department stock for $productName in $departmentName',
            );
          }

          // 3. Log Movement (Ledger) - INSIDE SAME TRANSACTION with ACCURATE balance
          await _createLedgerEntry(
            productId: item['productId'],
            warehouseId: 'Main',
            transactionType: 'ISSUE_DEPT',
            quantityChange: -quantity,
            unit: item['unit'] ?? 'Unit',
            performedBy: issuedByUserId,
            reason: 'Issue to $departmentName',
            referenceId: referenceId,
            notes: notes,
            runningBalanceOverride: updatedProduct?.stock,
          );

          syncPayloads.add({
            'id': '${deptStock.departmentName}_$productId',
            'departmentName': deptStock.departmentName,
            'productId': productId,
            'productName': productName,
            'quantity': quantity,
            'unit': item['unit'] ?? 'Unit',
            'issuedByUserId': issuedByUserId,
            'issuedByUserName': issuedByUserName,
            'referenceId': referenceId,
            'notes': notes,
            'createdAt': now.toIso8601String(),
          });
        }
      });

      for (final payload in syncPayloads) {
        final commandKey = _buildStockMutationCommandKey(
          collection: 'department_stocks',
          action: 'issue_to_department',
          payload: payload,
        );
        final queuePayload = <String, dynamic>{
          ...payload,
          OutboxCodec.idempotencyKeyField: commandKey,
        };
        await SyncQueueService.instance.addToQueue(
          collectionName: 'department_stocks',
          documentId: payload['id']?.toString() ?? '',
          operation: 'issue_to_department',
          payload: queuePayload,
        );
      }

      return true;
    } catch (e) {
      throw handleError(e, 'transferToDepartment');
    }
  }

  Future<bool> returnFromDepartment({
    required String departmentName,
    required List<Map<String, dynamic>> items,
    required String returnedByUserId,
    required String returnedByUserName,
    String? notes,
    String? referenceId,
  }) async {
    try {
      await _requireInventoryMutationActor(
        'return stock from department',
        requireInventoryCapability: true,
        allowedRoles: _warehouseMutationRoleOverrides,
      );
      final now = DateTime.now();
      final syncPayloads = <Map<String, dynamic>>[];

      await _dbService.db.writeTxn(() async {
        for (final item in items) {
          final productId = item['productId'] as String;
          final quantity = (item['quantity'] as num).toDouble();
          final productName = item['productName'] as String? ?? 'Unknown';

          final deptStock = await applyDepartmentStockChangeInTxn(
            departmentName: departmentName,
            productId: productId,
            quantityChange: -quantity,
            updatedAt: now,
            markSyncPending: true,
            createIfMissing: false,
            enforceNonNegative: true,
          );

          if (deptStock == null) {
            throw Exception(
              "Insufficient department stock for $productName in $departmentName",
            );
          }

          final updatedProduct = await applyProductStockChangeInTxn(
            productId: productId,
            quantityChange: quantity,
            unit: item['unit'] as String? ?? 'Unit',
            updatedAt: now,
            markSyncPending: true,
          );

          // 3. Create Stock Ledger Entry - INSIDE SAME TRANSACTION with accurate main balance
          await _createLedgerEntry(
            productId: item['productId'],
            warehouseId: 'Main',
            transactionType: 'RETURN_DEPT',
            quantityChange: quantity,
            unit: item['unit'] ?? 'Unit',
            performedBy: returnedByUserId,
            reason: 'Return from $departmentName',
            referenceId: referenceId,
            notes: notes,
            runningBalanceOverride: updatedProduct?.stock,
          );

          syncPayloads.add({
            'id': '${deptStock.departmentName}_$productId',
            'departmentName': deptStock.departmentName,
            'productId': productId,
            'productName': productName,
            'quantity': quantity,
            'unit': item['unit'] ?? 'Unit',
            'returnedByUserId': returnedByUserId,
            'returnedByUserName': returnedByUserName,
            'referenceId': referenceId,
            'notes': notes,
            'createdAt': now.toIso8601String(),
          });
        }
      });

      for (final payload in syncPayloads) {
        final commandKey = _buildStockMutationCommandKey(
          collection: 'department_stocks',
          action: 'return_from_department',
          payload: payload,
        );
        final queuePayload = <String, dynamic>{
          ...payload,
          OutboxCodec.idempotencyKeyField: commandKey,
        };
        await SyncQueueService.instance.addToQueue(
          collectionName: 'department_stocks',
          documentId: payload['id']?.toString() ?? '',
          operation: 'return_from_department',
          payload: queuePayload,
        );
      }

      return true;
    } catch (e) {
      throw handleError(e, 'returnFromDepartment');
    }
  }

  Future<List<WastageLogEntity>> getWastageLogs() async {
    try {
      // Local-first
      return await _dbService.wastageLogs
          .where()
          .sortByCreatedAtDesc()
          .findAll();
    } catch (e) {
      throw handleError(e, 'getWastageLogs');
    }
  }

  Future<bool> adjustStock({
    required List<Map<String, dynamic>> items,
    required String reason,
    required String userId,
    required String userName,
    required UserRole userRole, // NEW: Role-based access control
    String? notes,
    String? referenceId,
    String? referenceType,
  }) async {
    await _requireInventoryMutationActor(
      'adjust warehouse stock',
      requireInventoryCapability: true,
      allowedRoles: _warehouseMutationRoleOverrides,
    );
    // SECURITY: Prevent salesmen from adjusting warehouse stock
    if (userRole == UserRole.salesman) {
      throw Exception(
        'Permission Denied: Salesmen cannot adjust warehouse stock. '
        'Only Store Incharge, Production Manager, or Admin can modify inventory.',
      );
    }

    try {
      debugPrint('[InventoryService] adjustStock called. SafeMode=\$safeMode');
      final now = DateTime.now();
      final movementPayloads = <Map<String, dynamic>>[];

      // 1. ATOMIC TRANSACTION: Stock Update + Ledger Entry
      debugPrint('[InventoryService] Starting Isar Write Transaction...');
      await _dbService.db.writeTxn(() async {
        for (final item in items) {
          final productId = item['productId'];
          final quantity = (item['quantity'] as num).toDouble();
          final movementType = item['movementType'];
          final quantityChange = movementType == 'in' ? quantity : -quantity;

          debugPrint(
            '[InventoryService] Processing item: \$productId, Qty: \$quantity, Type: \$movementType',
          );

          // A. Update Product Stock (centralized guard + normalization)
          final updatedProduct = await applyProductStockChangeInTxn(
            productId: productId,
            quantityChange: quantityChange,
            unit: item['unit'] as String?,
            conversionFactorOverride: (item['conversionFactor'] as num?)
                ?.toDouble(),
            enforceNonNegative: movementType == 'out',
            updatedAt: now,
            markSyncPending: true,
          );

          // B. Create Stock Ledger Entry with ACCURATE post-update balance
          await _createLedgerEntry(
            productId: productId,
            warehouseId: 'Main',
            transactionType: movementType == 'in'
                ? 'ADJUSTMENT_IN'
                : 'ADJUSTMENT_OUT',
            quantityChange: quantityChange,
            unit: item['unit'] ?? 'Unit',
            performedBy: userId,
            reason: reason,
            referenceId: referenceId,
            notes: notes,
            // FIX #4: Post-update balance
            runningBalanceOverride: updatedProduct?.stock,
          );
        }
      });
      debugPrint('[InventoryService] Transaction committed successfully.');

      // 3. Queue Movement Logs to Sync Queue (OUTBOX PATTERN)
      await _dbService.db.writeTxn(() async {
        for (final item in items) {
          final movementData = {
            'id': generateId(),
            'productId': item['productId'],
            'productName': item['name'],
            'quantity': (item['quantity'] as num).toDouble(),
            'movementType': item['movementType'],
            'reason': reason,
            'userId': userId,
            'userName': userName,
            'notes': notes,
            'referenceId': referenceId,
            'referenceType': referenceType,
            'createdAt': now.toIso8601String(),
            'isSynced': false,
          };

          debugPrint(
            '[InventoryService] Adding movement to local & sync queue...',
          );

          final entity = StockMovementEntity()
            ..id = movementData['id'] as String
            ..productId = movementData['productId'] as String
            ..productName = movementData['productName'] as String
            ..quantity = movementData['quantity'] as double
            ..movementType = movementData['movementType'] as String
            ..reason = movementData['reason'] as String
            ..userId = movementData['userId'] as String
            ..userName = movementData['userName'] as String
            ..notes = movementData['notes'] as String?
            ..referenceId = movementData['referenceId'] as String?
            ..referenceType = movementData['referenceType'] as String?
            ..createdAt = DateTime.parse(movementData['createdAt'] as String)
            ..isSynced = false
            ..syncStatus = SyncStatus.pending;

          await _dbService.stockMovements.put(entity);
          movementPayloads.add(Map<String, dynamic>.from(movementData));
        }
      });
      for (final movementData in movementPayloads) {
        await SyncQueueService.instance.addToQueue(
          collectionName: stockMovementsCollection,
          documentId: movementData['id']?.toString() ?? '',
          operation: 'add',
          payload: movementData,
        );
      }
      return true;
    } catch (e) {
      debugPrint('[InventoryService] CRASH/ERROR in adjustStock: $e');
      throw handleError(e, 'adjustStock');
    }
  }

  /// Reconcile Physical Stock with System Stock
  /// Calculates difference and applies adjustments atomically.
  Future<Map<String, dynamic>> reconcileInventory({
    required List<Map<String, dynamic>> items, // {productId, physicalCount}
    required String userId,
    required String userName,
    String? notes,
  }) async {
    try {
      await _requireInventoryMutationActor(
        'reconcile inventory',
        requireInventoryCapability: true,
        allowedRoles: _warehouseMutationRoleOverrides,
      );
      final now = DateTime.now();
      int adjustmentsCount = 0;
      final adjustmentLogId = generateId();
      final List<Map<String, dynamic>> movementsForSync = [];

      await _dbService.db.writeTxn(() async {
        for (final item in items) {
          final productId = item['productId'];
          final physicalCount = (item['physicalCount'] as num).toDouble();

          final product = await _dbService.products.getById(productId);
          if (product != null) {
            final currentStock = product.stock ?? 0.0;
            final diff = physicalCount - currentStock;

            if (diff.abs() > 0.001) {
              // Floating point tolerance
              adjustmentsCount++;
              final movementType = diff > 0
                  ? 'ADJUSTMENT_IN'
                  : 'ADJUSTMENT_OUT';

              // 1. Update Product (centralized guard)
              final updatedProduct = await applyProductStockChangeInTxn(
                productId: productId,
                quantityChange: diff,
                enforceNonNegative: true,
                updatedAt: now,
                markSyncPending: true,
              );

              // 2. Ledger with ACCURATE post-update balance
              await _createLedgerEntry(
                productId: productId,
                warehouseId: 'Main',
                transactionType: movementType,
                quantityChange: diff,
                performedBy: userId,
                reason: 'Reconciliation',
                notes: notes ?? 'Physical Count: $physicalCount',
                referenceId: adjustmentLogId,
                // FIX #4: Post-update balance
                runningBalanceOverride: updatedProduct?.stock,
              );

              // Add to sync list
              movementsForSync.add({
                'id': generateId(),
                'productId': productId,
                'productName': product.name,
                'quantity': diff.abs(),
                'movementType': diff > 0 ? 'in' : 'out',
                'reason': 'Reconciliation',
                'userId': userId,
                'userName': userName,
                'notes': notes,
                'referenceId': adjustmentLogId,
                'referenceType': 'reconciliation',
                'createdAt': now.toIso8601String(),
                'isSynced': false,
              });
            }
          }
        }
      });

      // 3. Sync Legacy Logs (Outside Transaction) - Converted to Outbox
      final queuedMovements = <Map<String, dynamic>>[];
      await _dbService.db.writeTxn(() async {
        for (final m in movementsForSync) {
          final entity = StockMovementEntity()
            ..id = m['id'] as String
            ..productId = m['productId'] as String
            ..productName = m['productName'] as String
            ..quantity = m['quantity'] as double
            ..movementType = m['movementType'] as String
            ..reason = m['reason'] as String
            ..userId = m['userId'] as String
            ..userName = m['userName'] as String
            ..notes = m['notes'] as String?
            ..referenceId = m['referenceId'] as String?
            ..referenceType = m['referenceType'] as String?
            ..createdAt = DateTime.parse(m['createdAt'] as String)
            ..isSynced = false
            ..syncStatus = SyncStatus.pending;

          await _dbService.stockMovements.put(entity);
          queuedMovements.add(Map<String, dynamic>.from(m));
        }
      });
      for (final movement in queuedMovements) {
        await SyncQueueService.instance.addToQueue(
          collectionName: stockMovementsCollection,
          documentId: movement['id']?.toString() ?? '',
          operation: 'add',
          payload: movement,
        );
      }

      return {
        'success': true,
        'adjustments': adjustmentsCount,
        'refId': adjustmentLogId,
      };
    } catch (e) {
      throw handleError(e, 'reconcileInventory');
    }
  }

  /// Reconciles product stock against stock ledger entries.
  /// Returns list of discrepancies where product.stock != ledger sum.
  /// Resolves Issue #9: Inventory Reconciliation Report
  Future<List<StockDiscrepancy>> generateReconciliationReport({
    List<String>? productIds, // Optional filter
  }) async {
    final discrepancies = <StockDiscrepancy>[];

    // Get products to check
    List<ProductEntity> products;
    if (productIds != null && productIds.isNotEmpty) {
      products = await Future.wait(
        productIds.map((id) => _dbService.products.getById(id)),
      ).then((list) => list.whereType<ProductEntity>().toList());
    } else {
      products = await _dbService.products
          .filter()
          .isDeletedEqualTo(false)
          .findAll();
    }

    for (final product in products) {
      // Sum all ledger entries for this product
      final ledgerEntries = await _dbService.stockLedger
          .filter()
          .productIdEqualTo(product.id)
          .findAll();

      final ledgerSum = ledgerEntries.fold<double>(
        0.0,
        (sum, entry) => sum + entry.quantityChange,
      );

      final productStock = product.stock ?? 0.0;
      final difference = productStock - ledgerSum;

      // Allow small floating point tolerance
      if (difference.abs() > 0.001) {
        discrepancies.add(
          StockDiscrepancy(
            productId: product.id,
            productName: product.name,
            productSku: product.sku,
            systemStock: productStock,
            ledgerStock: ledgerSum,
            difference: difference,
            ledgerEntryCount: ledgerEntries.length,
          ),
        );
      }
    }

    return discrepancies;
  }

  /// Returns stock from salesman back to warehouse
  Future<void> returnFromSalesman({
    required String salesmanId,
    required List<Map<String, dynamic>> items,
    required String returnedByUserId,
    required String returnedByUserName,
    String? notes,
    String? referenceId,
  }) async {
    try {
      await _requireInventoryMutationActor(
        'return stock from salesman',
        requireInventoryCapability: false,
        allowedRoles: _dispatchReceiveRoleOverrides,
      );
      final now = DateTime.now();
      final returnId = referenceId ?? generateId();

      await _dbService.db.writeTxn(() async {
        final salesmanEntity = await _dbService.users.getById(salesmanId);
        if (salesmanEntity == null) {
          throw Exception('Salesman not found: $salesmanId');
        }

        final allocatedMap = salesmanEntity.getAllocatedStock();

        for (final item in items) {
          final productId = item['productId']?.toString().trim();
          if (productId == null || productId.isEmpty) {
            throw Exception('Product ID required for return');
          }

          final returnQty = (item['quantity'] as num?)?.toDouble() ?? 0.0;
          if (returnQty <= 0) {
            throw Exception('Return quantity must be positive');
          }

          final isFree = item['isFree'] == true;
          final stockItem = allocatedMap[productId];
          if (stockItem == null) {
            throw Exception('Product $productId not allocated to salesman');
          }

          final available = isFree
              ? (stockItem.freeQuantity ?? 0).toDouble()
              : stockItem.quantity.toDouble();

          if (available < returnQty) {
            throw Exception(
              'Insufficient allocated stock for ${stockItem.name}. '
              'Available: $available, Requested: $returnQty',
            );
          }

          // Decrement salesman stock
          if (isFree) {
            allocatedMap[productId] = stockItem.copyWith(
              freeQuantity: (stockItem.freeQuantity ?? 0) - returnQty.toInt(),
            );
          } else {
            allocatedMap[productId] = stockItem.copyWith(
              quantity: stockItem.quantity - returnQty.toInt(),
            );
          }

          // Increment warehouse stock
          final updatedProduct = await applyProductStockChangeInTxn(
            productId: productId,
            quantityChange: returnQty,
            unit: item['unit'] as String? ?? stockItem.baseUnit,
            enforceNonNegative: false,
            updatedAt: now,
            markSyncPending: true,
          );

          // Create ledger entry
          await _createLedgerEntry(
            productId: productId,
            warehouseId: 'Main',
            transactionType: 'RETURN_FROM_SALESMAN',
            quantityChange: returnQty,
            unit: item['unit'] ?? stockItem.baseUnit,
            performedBy: returnedByUserId,
            reason: 'Return from salesman',
            referenceId: returnId,
            notes: notes ?? 'Stock returned from ${salesmanEntity.name}',
            runningBalanceOverride: updatedProduct?.stock,
          );
        }

        // Update salesman allocated stock
        salesmanEntity.setAllocatedStock(allocatedMap);
        salesmanEntity.updatedAt = now;
        salesmanEntity.syncStatus = SyncStatus.pending;
        await _dbService.users.put(salesmanEntity);
      });

      // Enqueue for sync
      final returnData = {
        'id': returnId,
        'salesmanId': salesmanId,
        'items': items,
        'returnedBy': returnedByUserId,
        'returnedByName': returnedByUserName,
        'notes': notes,
        'createdAt': now.toIso8601String(),
      };

      await SyncQueueService.instance.addToQueue(
        collectionName: 'salesman_returns',
        documentId: returnId,
        operation: 'add',
        payload: returnData,
      );

      AppLogger.success(
        'Stock returned from salesman: $salesmanId',
        tag: 'Inventory',
      );
    } catch (e) {
      throw handleError(e, 'returnFromSalesman');
    }
  }

  Future<String> dispatchToSalesman({
    required AppUser salesman,
    required String vehicleId,
    required String vehicleNumber,
    required String dispatchRoute,
    required String salesRoute,
    required List<SaleItem> items,
    required double subtotal,
    required double totalAmount,
    required String userId,
    required String userName,
    double additionalDiscount = 0,
    bool isOrderBasedDispatch = false,
    String? sourceOrderId,
    String? sourceOrderNo,
    String? sourceDealerId,
    String? sourceDealerName,
    String dispatchSource = 'direct',
  }) async {
    try {
      await _requireInventoryMutationActor(
        'dispatch stock to salesman',
        requireInventoryCapability: true,
        allowedRoles: _warehouseMutationRoleOverrides,
      );

      return await _performDispatch(
        salesman: salesman,
        vehicleId: vehicleId,
        vehicleNumber: vehicleNumber,
        dispatchRoute: dispatchRoute,
        salesRoute: salesRoute,
        items: items,
        subtotal: subtotal,
        totalAmount: totalAmount,
        userId: userId,
        userName: userName,
        additionalDiscount: additionalDiscount,
        isOrderBasedDispatch: isOrderBasedDispatch,
        sourceOrderId: sourceOrderId,
        sourceOrderNo: sourceOrderNo,
        sourceDealerId: sourceDealerId,
        sourceDealerName: sourceDealerName,
        dispatchSource: dispatchSource,
      ).timeout(const Duration(seconds: 30));
    } catch (e) {
      throw handleError(e, 'dispatchToSalesman');
    }
  }

  Future<String> _performDispatch({
    required AppUser salesman,
    required String vehicleId,
    required String vehicleNumber,
    required String dispatchRoute,
    required String salesRoute,
    required List<SaleItem> items,
    required double subtotal,
    required double totalAmount,
    required String userId,
    required String userName,
    double additionalDiscount = 0,
    bool isOrderBasedDispatch = false,
    String? sourceOrderId,
    String? sourceOrderNo,
    String? sourceDealerId,
    String? sourceDealerName,
    String dispatchSource = 'direct',
  }) async {
    try {
      await _requireInventoryMutationActor(
        'dispatch stock to salesman',
        requireInventoryCapability: true,
        allowedRoles: _warehouseMutationRoleOverrides,
      );
      final now = DateTime.now();
      final dispatchDocId = generateId();
      final dispatchId = _generateDispatchReference(dispatchDocId);
      final itemMovementIdsByIndex = <int, String>{};
      final runningBalancesByIndex = <int, double?>{};
      final validItems = items
          .where((item) => item.quantity > 0)
          .toList(growable: false);

      if (validItems.isEmpty) {
        throw Exception(
          'Dispatch must include at least one item with quantity greater than zero.',
        );
      }
      for (final item in validItems) {
        if (item.productId.trim().isEmpty) {
          throw Exception(
            'Invalid dispatch item detected: missing product id.',
          );
        }
      }

      // ATOMIC TRANSACTION: Validate Stock -> Update Product -> Allocate to User -> Create Dispatch -> Create Movements
      await _dbService.db.writeTxn(() async {
        try {
          // T17: Bulk prefetch products to avoid N+1 queries
          final productIds = validItems.map((item) => item.productId).toList();
          final products = await _dbService.products.getAllById(productIds);
          final productsMap = <String, ProductEntity>{};
          for (var i = 0; i < productIds.length; i++) {
            if (products[i] != null) {
              productsMap[productIds[i]] = products[i]!;
            }
          }

          // 1. Validation & Deduction Phase
          for (final entry in validItems.asMap().entries) {
            final item = entry.value;
            final product = productsMap[item.productId];
            if (product == null) {
              throw Exception('Product ${item.name} not found');
            }
            final currentStock = product.stock ?? 0.0;
            if (currentStock < item.quantity.toDouble()) {
              throw Exception(
                'Insufficient stock for ${item.name}. Available: $currentStock, Required: ${item.quantity}',
              );
            }

            final updatedProduct = await applyProductStockChangeInTxn(
              productId: item.productId,
              quantityChange: -item.quantity.toDouble(),
              unit: item.baseUnit,
              conversionFactorOverride: item.conversionFactor,
              enforceNonNegative: true,
              updatedAt: now,
              markSyncPending: true,
            );
            runningBalancesByIndex[entry.key] = updatedProduct?.stock;
          }

          // 2. Allocation Phase (Immediate)
          // BUSINESS RULE: Dispatch is treated as received for salesman availability.
          final salesmanEntity = await _dbService.users.getById(salesman.id);
          if (salesmanEntity == null) {
            throw Exception('Salesman not found locally: ${salesman.id}');
          }

          final allocatedMap = salesmanEntity.getAllocatedStock();
          for (final item in validItems) {
            final current = allocatedMap[item.productId];
            final currentQty = current?.quantity ?? 0;
            final currentFreeQty = current?.freeQuantity ?? 0;

            // BUSINESS RULE: Main inventory decreases, salesman stock increases
            if (item.isFree) {
              allocatedMap[item.productId] =
                  (current ??
                          AllocatedStockItem(
                            name: item.name,
                            quantity: 0,
                            productId: item.productId,
                            price: item.price,
                            secondaryPrice: item.secondaryPrice,
                            baseUnit: item.baseUnit,
                            secondaryUnit: item.secondaryUnit,
                            conversionFactor: item.conversionFactor ?? 1.0,
                            freeQuantity: 0,
                          ))
                      .copyWith(
                        name: item.name,
                        productId: item.productId,
                        price: item.price,
                        secondaryPrice: item.secondaryPrice,
                        baseUnit: item.baseUnit,
                        secondaryUnit: item.secondaryUnit,
                        conversionFactor: item.conversionFactor ?? 1.0,
                        freeQuantity: currentFreeQty + item.quantity,
                      );
            } else {
              allocatedMap[item.productId] =
                  (current ??
                          AllocatedStockItem(
                            name: item.name,
                            quantity: 0,
                            productId: item.productId,
                            price: item.price,
                            secondaryPrice: item.secondaryPrice,
                            baseUnit: item.baseUnit,
                            secondaryUnit: item.secondaryUnit,
                            conversionFactor: item.conversionFactor ?? 1.0,
                            freeQuantity: 0,
                          ))
                      .copyWith(
                        name: item.name,
                        productId: item.productId,
                        price: item.price,
                        secondaryPrice: item.secondaryPrice,
                        baseUnit: item.baseUnit,
                        secondaryUnit: item.secondaryUnit,
                        conversionFactor: item.conversionFactor ?? 1.0,
                        quantity: currentQty + item.quantity,
                      );
            }
          }

          salesmanEntity.setAllocatedStock(allocatedMap);
          salesmanEntity.updatedAt = now;
          salesmanEntity.syncStatus = SyncStatus.pending;
          await _dbService.users.put(salesmanEntity);

          // 3. Create Stock Ledger Entries (Audit Trail) with ACCURATE per-item balance
          for (final entry in validItems.asMap().entries) {
            final item = entry.value;
            await _createLedgerEntry(
              productId: item.productId,
              warehouseId: 'Main',
              transactionType: 'DISPATCH_OUT',
              quantityChange: -(item.quantity.toDouble()),
              unit: item.baseUnit,
              performedBy: userId,
              reason: 'Dispatch to ${salesman.name}',
              referenceId: dispatchId,
              notes:
                  'Van Loading - Dispatch Route: $dispatchRoute, Sales Route: $salesRoute',
              runningBalanceOverride: runningBalancesByIndex[entry.key],
            );
          }

          // 4. Movement Logs Phase
          for (final entry in validItems.asMap().entries) {
            final item = entry.value;
            final mId = _deterministicDispatchMovementId(
              dispatchId: dispatchDocId,
              productId: item.productId,
              isFree: item.isFree,
              itemIndex: entry.key,
            );
            itemMovementIdsByIndex[entry.key] = mId;
          }
        } catch (e) {
          AppLogger.error('Dispatch transaction failed', error: e, tag: 'Inventory');
          rethrow;
        }
      });

      // 4. Create Dispatch Record (Local + Sync)
      final dispatchItemsPayload = validItems
          .asMap()
          .entries
          .map((entry) {
            final payload = entry.value.toJson();
            final movementId = itemMovementIdsByIndex[entry.key];
            if (movementId != null && movementId.isNotEmpty) {
              payload['movementId'] = movementId;
            }
            return payload;
          })
          .toList(growable: false);

      final totalQuantity = validItems.fold<int>(
        0,
        (sum, item) => sum + item.quantity,
      );
      final dispatchData = {
        'id': dispatchDocId,
        'dispatchId': dispatchId,
        'salesmanId': salesman.id,
        'salesmanName': salesman.name,
        'vehicleId': vehicleId,
        'vehicleNumber': vehicleNumber,
        'dispatchRoute': dispatchRoute,
        'salesRoute': salesRoute,
        'route': dispatchRoute, // Legacy compatibility
        'items': dispatchItemsPayload,
        'totalQuantity': totalQuantity,
        'movementIds': itemMovementIdsByIndex.values.toList(),
        'subtotal': subtotal,
        'additionalDiscount': additionalDiscount,
        'totalAmount': totalAmount,
        'status': DispatchStatus.received.name,
        'receivedAt': now.toIso8601String(),
        'createdBy': userId,
        'createdByName': userName,
        'createdAt': now.toIso8601String(),
        'isSynced': false,
        'isOrderBasedDispatch': isOrderBasedDispatch,
        'dispatchSource': dispatchSource.trim().isEmpty
            ? 'direct'
            : dispatchSource.trim(),
        if (sourceOrderId != null && sourceOrderId.trim().isNotEmpty)
          'orderId': sourceOrderId.trim(),
        if (sourceOrderNo != null && sourceOrderNo.trim().isNotEmpty)
          'orderNo': sourceOrderNo.trim(),
        if (sourceDealerId != null && sourceDealerId.trim().isNotEmpty)
          'dealerId': sourceDealerId.trim(),
        if (sourceDealerName != null && sourceDealerName.trim().isNotEmpty)
          'dealerName': sourceDealerName.trim(),
      };

      Map<String, dynamic>? queuedDispatchData;

      // Save to true Isar via Outbox
      await _dbService.db.writeTxn(() async {
        try {
          final dispatchEntity = DispatchEntity.fromDomain(
            StockDispatch.fromJson(dispatchData),
          )..syncStatus = SyncStatus.pending;
          await _dbService.dispatches.put(dispatchEntity);
          queuedDispatchData = Map<String, dynamic>.from(dispatchData);
        } catch (e) {
          AppLogger.error('Dispatch entity creation failed', error: e, tag: 'Inventory');
          rethrow;
        }
      });
      if (queuedDispatchData != null) {
        await SyncQueueService.instance.addToQueue(
          collectionName: dispatchesCollection,
          documentId: queuedDispatchData!['id']?.toString() ?? '',
          operation: 'add',
          payload: queuedDispatchData!,
        );
      }

      await NotificationService().publishNotificationEvent(
        title: 'Dispatch Assigned',
        body: 'Dispatch $dispatchId is ready for ${salesman.name}.',
        eventType: 'dispatch_assigned',
        targetUserIds: {salesman.id},
        targetRoles: const {UserRole.salesman},
        data: {
          'dispatchId': dispatchId,
          'salesmanId': salesman.id,
          'salesmanName': salesman.name,
          'totalQuantity': totalQuantity,
          'dispatchRoute': dispatchRoute,
          'salesRoute': salesRoute,
        },
        route: '/dashboard/dispatch/history',
        forceSound: true,
      );

      return dispatchId;
    } catch (e) {
      AppLogger.error('Dispatch operation failed', error: e, tag: 'Inventory');
      throw handleError(e, 'dispatchToSalesman');
    }
  }

  // Process Bulk GRN (Isar First)
  Future<void> processBulkGRN({
    required List<Map<String, dynamic>> items,
    required String referenceId,
    required String referenceNumber,
    required String userId,
    required String userName,
  }) async {
    try {
      await _requireInventoryMutationActor(
        'process bulk GRN',
        requireInventoryCapability: true,
        allowedRoles: _warehouseMutationRoleOverrides,
      );
      final now = DateTime.now();

      // 1. Process Products in Isar Transaction
      await _dbService.db.writeTxn(() async {
        for (final item in items) {
          final productId = item['productId'] as String;
          final quantity = (item['quantity'] as num).toDouble();
          final unitPrice = (item['unitPrice'] as num).toDouble();

          final product = await _dbService.products.getById(productId);
          if (product != null) {
            final double oldStock = product.stock ?? 0.0;
            final double oldAvgCost = _fieldEncryption.isEnabled
                ? (_decryptProductDouble(
                        product.id,
                        'averageCost',
                        product.averageCost,
                      ) ??
                      _decryptProductDouble(
                        product.id,
                        'purchasePrice',
                        product.purchasePrice,
                      ) ??
                      0.0)
                : (product.averageCost ?? product.purchasePrice ?? 0.0);

            final incomingQty = quantity;
            final purchaseRate = unitPrice;

            final double totalQty = oldStock + incomingQty;
            double newAvgCost = purchaseRate;

            if (totalQty > 0) {
              final validOldStock = oldStock.clamp(0.0, double.infinity);
              final oldTotalValue = validOldStock * oldAvgCost;
              final incomingValue = incomingQty * purchaseRate;
              newAvgCost =
                  (oldTotalValue + incomingValue) /
                  (validOldStock + incomingQty);
            }

            await applyProductStockChangeInTxn(
              productId: productId,
              quantityChange: incomingQty,
              enforceNonNegative: true,
              updatedAt: now,
              markSyncPending: true,
              mutate: (p) {
                p.averageCost =
                    _encryptProductDouble(p.id, 'averageCost', newAvgCost) ??
                    newAvgCost;
                p.lastCost =
                    _encryptProductDouble(p.id, 'lastCost', purchaseRate) ??
                    purchaseRate;
              },
            );
          }

          // 2. Create Stock Ledger Entries - INSIDE SAME TRANSACTION
          await _createLedgerEntry(
            productId: item['productId'],
            warehouseId: 'Main',
            transactionType: 'GRN',
            quantityChange: (item['quantity'] as num).toDouble(),
            performedBy: userId,
            reason: 'Purchase',
            referenceId: referenceId,
            notes: 'GRN for PO: $referenceNumber',
          );
        }
      });

      // Legacy support removal: We rely on StockLedger now.
    } catch (e) {
      handleError(e, 'processBulkGRN');
      rethrow;
    }
  }

  // Process Goods Received Note (GRN) from Purchase Order
  Future<void> processGRN({
    required String productId,
    required double quantity,
    required double unitPrice, // Rate per unit (exclusive of GST)
    required String referenceId,
    required String referenceNumber,
    required String userId,
    required String userName,
  }) async {
    try {
      await _requireInventoryMutationActor(
        'process GRN',
        requireInventoryCapability: true,
        allowedRoles: _warehouseMutationRoleOverrides,
      );
      // 1. Fetch Product and Calculate Weighted Average Cost (WAC)
      await _dbService.db.writeTxn(() async {
        final product = await _dbService.products.getById(productId);

        if (product != null) {
          final double oldStock = product.stock ?? 0.0;
          final double oldAvgCost = _fieldEncryption.isEnabled
              ? (_decryptProductDouble(
                      product.id,
                      'averageCost',
                      product.averageCost,
                    ) ??
                    _decryptProductDouble(
                      product.id,
                      'purchasePrice',
                      product.purchasePrice,
                    ) ??
                    0.0)
              : (product.averageCost ?? product.purchasePrice ?? 0.0);

          // Weighted Average Cost Formula
          // WAC = (oldStock * oldAvgCost + receivedQty * purchaseRate) / totalQty
          final incomingQty = quantity;
          final purchaseRate = unitPrice;
          final double totalQty = oldStock + incomingQty;

          double newAvgCost = purchaseRate; // Default if first purchase

          if (totalQty > 0) {
            // Handle valid stock scenarios
            // If oldStock is negative (correction), we clamp calculation to 0
            final validOldStock = oldStock.clamp(0.0, double.infinity);
            final oldTotalValue = validOldStock * oldAvgCost;
            final incomingValue = incomingQty * purchaseRate;
            newAvgCost =
                (oldTotalValue + incomingValue) / (validOldStock + incomingQty);
          }

          // Update product cost fields + stock (centralized)
          await applyProductStockChangeInTxn(
            productId: productId,
            quantityChange: incomingQty,
            enforceNonNegative: true,
            updatedAt: DateTime.now(),
            markSyncPending: true,
            mutate: (p) {
              p.averageCost =
                  _encryptProductDouble(p.id, 'averageCost', newAvgCost) ??
                  newAvgCost;
              p.lastCost =
                  _encryptProductDouble(p.id, 'lastCost', purchaseRate) ??
                  purchaseRate;
            },
          );
        }

        // 2. Create Stock Ledger Entry (Atomic)
        await _createLedgerEntry(
          productId: productId,
          warehouseId: 'Main',
          transactionType: 'GRN',
          quantityChange: quantity,
          unit: 'Unit',
          performedBy: userId,
          reason: 'Purchase',
          referenceId: referenceId,
          notes: 'GRN for PO: $referenceNumber',
        );
      });
    } catch (e) {
      handleError(e, 'processGRN');
      rethrow;
    }
  }

  // INTERNAL HELPER: Access local sales
  Future<List<Sale>> _getLocalSales(String salesmanId) async {
    final localEntities = await _dbService.sales
        .filter()
        .salesmanIdEqualTo(salesmanId)
        .and()
        .recipientTypeEqualTo('customer')
        .findAll();
    if (localEntities.isNotEmpty) {
      return localEntities.map((e) => e.toDomain()).toList(growable: false);
    }

    // Backward-compatible fallback for legacy SharedPreferences records.
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('local_sales');
    if (jsonStr == null) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    return list
        .map((e) => Sale.fromJson(e))
        .where(
          (s) => s.salesmanId == salesmanId && s.recipientType == 'customer',
        )
        .toList();
  }

  /// Adjust allocated stock for a salesman (e.g., Customer Returns)
  Future<void> adjustSalesmanStock({
    required String salesmanId,
    required String productId,
    required double
    quantity, // Positive = Add (Return), Negative = Remove (Sale)
    required String reason,
    required String referenceId,
    String? referenceType,
    bool inTransaction = false,
  }) async {
    try {
      await _requireInventoryMutationActor(
        'adjust salesman stock',
        requireInventoryCapability: false,
        allowedRoles: _stockFinancialMutationRoles,
      );
      final now = DateTime.now();

      Future<void> applyAdjustment() async {
        final user = await _dbService.users.getById(salesmanId);
        if (user == null) {
          throw Exception('Salesman not found locally: $salesmanId');
        }

        Map<String, dynamic> allocMap = {};
        if (user.allocatedStockJson != null) {
          allocMap =
              jsonDecode(user.allocatedStockJson!) as Map<String, dynamic>;
        }

        final currentAlloc = allocMap[productId] as Map<String, dynamic>?;
        if (currentAlloc != null) {
          final currentQty = (currentAlloc['quantity'] as num).toDouble();
          final newQty = currentQty + quantity; // Add/Remove

          if (newQty < -1e-9) {
            throw Exception(
              'Insufficient allocated stock for $productId. Available: $currentQty, requested change: $quantity',
            );
          }

          // If return, we assume price/unit are same as existing allocation
          currentAlloc['quantity'] = newQty;
          allocMap[productId] = currentAlloc;
        } else {
          // If item not in allocation - weird for return, but possible if totally sold out?
          // Or if return from old stock.
          // We need product details to create entry.
          // Fetch Product locally to get details.
          if (quantity > 0) {
            final product = await _dbService.products.getById(productId);
            if (product != null) {
              final price = _fieldEncryption.isEnabled
                  ? (_decryptProductDouble(
                          product.id,
                          'price',
                          product.price,
                        ) ??
                        0.0)
                  : (product.price ?? 0.0);
              allocMap[productId] = {
                'productId': productId,
                'name': product.name,
                'quantity': quantity,
                'freeQuantity': 0.0,
                'price': price,
                'baseUnit': product.baseUnit,
              };
            }
          } else {
            throw Exception(
              'Allocated stock not found for $productId to deduct $quantity',
            );
          }
        }

        user.allocatedStockJson = jsonEncode(allocMap);
        user.updatedAt = now;
        user.syncStatus = SyncStatus.pending;
        await _dbService.users.put(user);

        // 3. Log to Stock Ledger (Offline History) - ATOMIC
        // For salesman stock, runningBalance is the new allocated quantity
        final allocatedQty = (allocMap[productId]?['quantity'] as num? ?? 0)
            .toDouble();
        final freeQty = (allocMap[productId]?['freeQuantity'] as num? ?? 0)
            .toDouble();
        await _createLedgerEntry(
          productId: productId,
          warehouseId: 'Salesman', // Dedicated bucket for salesman stock
          transactionType: quantity > 0 ? 'RETURN_IN' : 'SALE_OUT',
          quantityChange: quantity,
          runningBalanceOverride:
              allocatedQty + freeQty, // Total allocated after change
          unit: allocMap[productId]?['baseUnit'] ?? 'Unit',
          performedBy: salesmanId,
          reason: reason,
          referenceId: referenceId,
          notes: referenceType != null ? 'Ref Type: $referenceType' : null,
        );
      }

      if (inTransaction) {
        await applyAdjustment();
      } else {
        await _dbService.db.writeTxn(() async {
          await applyAdjustment();
        });
      }
    } catch (e) {
      handleError(e, 'adjustSalesmanStock');
      rethrow;
    }
  }

  /// Reverts stock for a cancelled sale.
  /// Handles both Van Sales (Allocated Stock) and Direct Sales (Warehouse Stock).
  Future<void> revertSaleStock({
    required String saleId,
    required List<dynamic> items, // List of SaleItem (entity) or Maps
    required String
    recipientType, // 'customer' (Van) or 'dealer'/'distributor' (Direct)
    String? salesmanId,
    required String performedBy,
    bool inTransaction = false,
  }) async {
    try {
      await _requireInventoryMutationActor(
        'revert sale stock',
        requireInventoryCapability: false,
        allowedRoles: _stockFinancialMutationRoles,
      );
      final now = DateTime.now();

      for (final item in items) {
        String productId;
        double quantity;
        // double finalQty; // Including free/etc if structure differs - commented out as not used
        String? baseUnit;

        // Handle different item structures (Entity vs Map)
        if (item is Map<String, dynamic>) {
          productId = item['productId'];
          quantity = (item['quantity'] as num).toDouble();
          baseUnit = item['baseUnit'];
        } else {
          // Handle SaleItem, SaleItemEntity, or similar dynamic item shapes.
          productId = item.productId;
          quantity = (item.quantity as num).toDouble();
          baseUnit = item.baseUnit ?? item.unit;
        }

        if (recipientType == 'customer') {
          // --- VAN SALE ROLLBACK: Return to Salesman Allocation ---
          if (salesmanId == null) {
            throw Exception('Salesman ID required for Van Sale rollback');
          }

          await adjustSalesmanStock(
            salesmanId: salesmanId,
            productId: productId,
            quantity: quantity, // POSITIVE to add back
            reason: 'Sale Cancellation',
            referenceId: saleId,
            referenceType: 'CANCEL_ROLLBACK',
            inTransaction: inTransaction,
          );
        } else {
          // --- DIRECT SALE ROLLBACK: Return to Main Warehouse ---
          Future<void> applyWarehouseRollback() async {
            await applyProductStockChangeInTxn(
              productId: productId,
              quantityChange: quantity,
              unit: baseUnit,
              enforceNonNegative: true,
              updatedAt: now,
              markSyncPending: true,
            );

            // Ledger Entry
            await _createLedgerEntry(
              productId: productId,
              warehouseId: 'Main',
              transactionType: 'CANCEL_ROLLBACK',
              quantityChange: quantity,
              unit: baseUnit,
              performedBy: performedBy,
              reason: 'Sale Cancellation',
              referenceId: saleId,
              notes: 'Restocking cancelled sale',
            );
          }

          if (inTransaction) {
            await applyWarehouseRollback();
          } else {
            await _dbService.db.writeTxn(() async {
              await applyWarehouseRollback();
            });
          }
        }
      }
    } catch (e) {
      handleError(e, 'revertSaleStock');
      rethrow;
    }
  }

  double? _decryptProductDouble(String productId, String field, double? value) {
    if (value == null) return null;
    if (!_fieldEncryption.isEnabled) return value;
    return _fieldEncryption.decryptDouble(
      value,
      'product:$productId:$field',
      magnitude: _priceMagnitude,
    );
  }

  double? _encryptProductDouble(String productId, String field, double? value) {
    if (value == null) return null;
    if (!_fieldEncryption.isEnabled) return value;
    return _fieldEncryption.encryptDouble(
      value,
      'product:$productId:$field',
      magnitude: _priceMagnitude,
    );
  }
}
