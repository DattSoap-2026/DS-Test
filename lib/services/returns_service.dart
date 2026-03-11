import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/role_access_matrix.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/customer_entity.dart';
import '../data/local/entities/product_entity.dart';
import '../data/local/entities/return_entity.dart';
import '../data/local/entities/inventory_location_entity.dart';
import '../data/local/entities/stock_ledger_entity.dart';
import '../data/local/entities/stock_balance_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import '../data/local/entities/user_entity.dart';
import '../models/types/return_types.dart';
import '../models/types/user_types.dart';
import '../utils/app_logger.dart';
import 'customers_service.dart';
import 'database_service.dart';
import 'inventory_service.dart';
import 'inventory_movement_engine.dart';
import 'inventory_projection_service.dart';
import 'notification_service.dart';
import 'offline_first_service.dart';
import 'outbox_codec.dart';
import 'sales_service.dart';
import 'service_capability_guard.dart';

const returnsCollection = 'returns';
const productsCollection = 'products';
const usersCollection = 'users';
const customersCollection = 'customers';
const salesCollection = 'sales';

/// State machine for return status transitions
class ReturnStateMachine {
  static const Map<ReturnStatus, List<ReturnStatus>> validTransitions = {
    ReturnStatus.created: [
      ReturnStatus.approved, // Supervisor approves
      ReturnStatus.rejected, // Supervisor rejects
    ],
    ReturnStatus.approved: [
      ReturnStatus.received, // Stock arrives at warehouse
    ],
    ReturnStatus.received: [
      ReturnStatus.completed, // Stock added back to inventory
    ],
    ReturnStatus.completed: [], // Final state
    ReturnStatus.rejected: [], // Final state
  };

  /// Check if transition from one state to another is valid
  static bool canTransition(ReturnStatus from, ReturnStatus to) {
    return validTransitions[from]?.contains(to) ?? false;
  }

  /// Validate state transition, throws exception if invalid
  static void validateTransition(ReturnStatus from, ReturnStatus to) {
    if (!canTransition(from, to)) {
      final allowed =
          validTransitions[from]?.map((e) => e.value).join(', ') ?? 'none';
      throw Exception(
        'Invalid return state transition: ${from.value} → ${to.value}\n'
        'Allowed transitions from ${from.value}: $allowed',
      );
    }
  }
}

class ReturnsService extends OfflineFirstService {
  final DatabaseService _db;
  // ignore: unused_field
  final InventoryService _inventoryService;
  final InventoryMovementEngine _inventoryMovementEngine;

  ReturnsService(
    super.firebase,
    this._db,
    this._inventoryService,
    // ignore unused params for backward-compat with existing callers
    CustomersService customersService,
    SalesService salesService, {
    InventoryMovementEngine? inventoryMovementEngine,
  }) : _inventoryMovementEngine =
           inventoryMovementEngine ??
           InventoryMovementEngine(_db, InventoryProjectionService(_db));

  @override
  String get localStorageKey => 'local_returns';

  @override
  bool get useIsar => true;

  static const String _legacyMigrationFlag = 'migrated_returns_to_isar_v1';

  // Simple in-memory cache for returns count
  int? _cachedCount;
  DateTime? _countCacheTimestamp;
  static const _cacheTTL = Duration(minutes: 3);

  ServiceCapabilityGuard get _capabilityGuard =>
      ServiceCapabilityGuard(auth: auth, dbService: _db);

  bool _canCreateReturnForSalesman({
    required UserRole actorRole,
    required String actorId,
    required String salesmanId,
  }) {
    if (RoleAccessMatrix.hasCapability(
      actorRole,
      RoleCapability.returnsApproveReject,
    )) {
      return true;
    }
    return actorId == salesmanId;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  bool _isLegacyMutationPathEnabled() => false;

  String _resolveInventoryActorUid({String? fallbackUserId}) {
    final authUid = auth?.currentUser?.uid.trim();
    if (authUid != null && authUid.isNotEmpty) {
      return authUid;
    }
    final fallback = fallbackUserId?.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
    return 'system';
  }

  String? _resolveInventoryActorLegacyId(String? userId) {
    final normalized = userId?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  List<InventoryCommandItem> _commandItemsFromReturnItems(
    List<ReturnItem> items,
  ) {
    return items
        .map(
          (item) => InventoryCommandItem(
            productId: item.productId.trim(),
            quantityBase: item.quantity.abs(),
          ),
        )
        .where(
          (item) =>
              item.productId.isNotEmpty && item.quantityBase.abs() >= 1e-9,
        )
        .toList(growable: false);
  }

  Future<void> _ensureInventoryLocationInTxn(String locationId) async {
    final normalized = locationId.trim();
    if (normalized.isEmpty || normalized.startsWith('virtual:')) {
      return;
    }

    final existing = await _db.inventoryLocations.getById(normalized);
    if (existing != null) {
      return;
    }

    final now = DateTime.now();
    if (normalized == InventoryProjectionService.warehouseMainLocationId) {
      final entity = InventoryLocationEntity()
        ..id = normalized
        ..type = InventoryLocationEntity.warehouseType
        ..name = 'Main Warehouse'
        ..code = 'WAREHOUSE_MAIN'
        ..parentLocationId = null
        ..ownerUserUid = null
        ..isActive = true
        ..isPrimaryMainWarehouse = true
        ..updatedAt = now
        ..syncStatus = SyncStatus.pending
        ..isDeleted = false;
      await _db.inventoryLocations.put(entity);
      return;
    }

    const salesmanPrefix = 'salesman_van_';
    if (normalized.startsWith(salesmanPrefix)) {
      final ownerUid = normalized.substring(salesmanPrefix.length).trim();
      final user = await _db.users.getById(ownerUid);
      final userName = (user?.name ?? '').trim();
      final entity = InventoryLocationEntity()
        ..id = normalized
        ..type = InventoryLocationEntity.salesmanVanType
        ..name = userName.isNotEmpty ? '$userName Van' : 'Salesman Van'
        ..code = 'SALESMAN_VAN_${ownerUid.toUpperCase()}'
        ..parentLocationId = InventoryProjectionService.warehouseMainLocationId
        ..ownerUserUid = ownerUid.isEmpty ? null : ownerUid
        ..isActive = true
        ..isPrimaryMainWarehouse = false
        ..updatedAt = now
        ..syncStatus = SyncStatus.pending
        ..isDeleted = false;
      await _db.inventoryLocations.put(entity);
    }
  }

  Future<void> _seedSourceBalancesInTxn({
    required String sourceLocationId,
    required List<InventoryCommandItem> items,
    required DateTime occurredAt,
  }) async {
    for (final item in items) {
      final balanceId = StockBalanceEntity.composeId(
        sourceLocationId,
        item.productId,
      );
      final existing = await _db.stockBalances.getById(balanceId);
      if (existing != null) {
        continue;
      }

      double seedQuantity = 0.0;
      if (sourceLocationId ==
          InventoryProjectionService.warehouseMainLocationId) {
        final product = await _db.products.getById(item.productId);
        seedQuantity = product?.stock ?? 0.0;
      } else if (sourceLocationId.startsWith('salesman_van_')) {
        final ownerUid = sourceLocationId.substring('salesman_van_'.length);
        final user = await _db.users.getById(ownerUid);
        final allocatedItem = user?.getAllocatedStock()[item.productId];
        seedQuantity =
            ((allocatedItem?.quantity ?? 0) +
                    (allocatedItem?.freeQuantity ?? 0))
                .toDouble();
      }

      final balance = StockBalanceEntity()
        ..id = balanceId
        ..locationId = sourceLocationId
        ..productId = item.productId
        ..quantity = seedQuantity
        ..updatedAt = occurredAt
        ..syncStatus = SyncStatus.pending
        ..isDeleted = false;
      await _db.stockBalances.put(balance);
    }
  }

  String _resolveOriginalSaleCommandId(ReturnRequest request) {
    final originalSaleId = request.originalSaleId?.trim();
    final saleToken = originalSaleId != null && originalSaleId.isNotEmpty
        ? originalSaleId
        : request.id.trim();
    return 'sale:$saleToken';
  }

  InventoryCommand _buildReturnSaleReversalCommand({
    required ReturnRequest request,
    required String restoreLocationId,
    required List<InventoryCommandItem> items,
    required String actorUid,
    String? actorLegacyAppUserId,
    required DateTime occurredAt,
    required String referenceId,
  }) {
    final originalCommandId = _resolveOriginalSaleCommandId(request);
    return InventoryCommand(
      commandId: 'reversal:$originalCommandId',
      commandType: InventoryCommandType.saleReversal,
      payload: <String, dynamic>{
        'originalCommandId': originalCommandId,
        'sourceLocationId': InventoryProjectionService.virtualSoldLocationId,
        'destinationLocationId': restoreLocationId,
        'referenceId': referenceId,
        'referenceType': 'sale_reversal',
        'reasonCode': 'return_sale_reversal',
        'items': items.map((item) => item.toJson()).toList(growable: false),
      },
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      createdAt: occurredAt,
    );
  }

  Future<void> _applySalesReturnGoodStockInTxn({
    required ReturnRequest request,
    required String actorUid,
    String? actorLegacyAppUserId,
    required DateTime occurredAt,
    required String referenceId,
  }) async {
    final items = _commandItemsFromReturnItems(request.items);
    if (items.isEmpty) {
      return;
    }

    final salesmanLocationId =
        InventoryProjectionService.salesmanLocationIdForUid(request.salesmanId);
    await _ensureInventoryLocationInTxn(salesmanLocationId);
    final command = _buildReturnSaleReversalCommand(
      request: request,
      restoreLocationId: salesmanLocationId,
      items: items,
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      occurredAt: occurredAt,
      referenceId: referenceId,
    );
    await _inventoryMovementEngine.applyCommandInTxn(command);
  }

  Future<void> _applySalesReturnBadStockInTxn({
    required ReturnRequest request,
    required String actorUid,
    String? actorLegacyAppUserId,
    required DateTime occurredAt,
    required String referenceId,
  }) async {
    final items = _commandItemsFromReturnItems(request.items);
    if (items.isEmpty) {
      return;
    }

    final warehouseLocationId =
        InventoryProjectionService.warehouseMainLocationId;
    final salesmanLocationId =
        InventoryProjectionService.salesmanLocationIdForUid(request.salesmanId);
    await _ensureInventoryLocationInTxn(warehouseLocationId);
    await _ensureInventoryLocationInTxn(salesmanLocationId);

    final reversalCommand = _buildReturnSaleReversalCommand(
      request: request,
      restoreLocationId: salesmanLocationId,
      items: items,
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      occurredAt: occurredAt,
      referenceId: referenceId,
    );
    await _inventoryMovementEngine.applyCommandInTxn(reversalCommand);

    for (final item in items) {
      final command = InventoryCommand.internalTransfer(
        sourceLocationId: salesmanLocationId,
        destinationLocationId: warehouseLocationId,
        referenceId: referenceId,
        productId: item.productId,
        quantityBase: item.quantityBase,
        actorUid: actorUid,
        actorLegacyAppUserId: actorLegacyAppUserId,
        reasonCode: 'sales_return_warehouse_restore',
        referenceType: 'sales_return',
        createdAt: occurredAt,
      );
      await _inventoryMovementEngine.applyCommandInTxn(command);
    }
  }

  Future<void> _ensureReturnApprovalInventoryAppliedInTxn({
    required ReturnRequest request,
    required String referenceId,
    required String actorUid,
    String? actorLegacyAppUserId,
    required DateTime occurredAt,
  }) async {
    if (request.returnType == 'stock_return') {
      final salesmanLocationId =
          InventoryProjectionService.salesmanLocationIdForUid(
            request.salesmanId,
          );
      final warehouseLocationId =
          InventoryProjectionService.warehouseMainLocationId;
      await _ensureInventoryLocationInTxn(warehouseLocationId);
      await _ensureInventoryLocationInTxn(salesmanLocationId);

      for (final item in _commandItemsFromReturnItems(request.items)) {
        await _seedSourceBalancesInTxn(
          sourceLocationId: salesmanLocationId,
          items: [item],
          occurredAt: occurredAt,
        );
        final command = InventoryCommand.internalTransfer(
          sourceLocationId: salesmanLocationId,
          destinationLocationId: warehouseLocationId,
          referenceId: referenceId,
          productId: item.productId,
          quantityBase: item.quantityBase,
          actorUid: actorUid,
          actorLegacyAppUserId: actorLegacyAppUserId,
          reasonCode: 'stock_return_approval',
          referenceType: 'stock_return',
          createdAt: occurredAt,
        );
        await _inventoryMovementEngine.applyCommandInTxn(command);
      }
      return;
    }

    if (request.disposition == 'Good Stock') {
      await _applySalesReturnGoodStockInTxn(
        request: request,
        actorUid: actorUid,
        actorLegacyAppUserId: actorLegacyAppUserId,
        occurredAt: occurredAt,
        referenceId: referenceId,
      );
      return;
    }

    await _applySalesReturnBadStockInTxn(
      request: request,
      actorUid: actorUid,
      actorLegacyAppUserId: actorLegacyAppUserId,
      occurredAt: occurredAt,
      referenceId: referenceId,
    );
  }

  Future<void> _ensureReturnApprovalInventoryApplied({
    required ReturnRequest request,
    required String referenceId,
    required String actorUid,
    String? actorLegacyAppUserId,
    required DateTime occurredAt,
  }) async {
    await _db.db.writeTxn(() async {
      await _ensureReturnApprovalInventoryAppliedInTxn(
        request: request,
        referenceId: referenceId,
        actorUid: actorUid,
        actorLegacyAppUserId: actorLegacyAppUserId,
        occurredAt: occurredAt,
      );
    });
  }

  ReturnEntity _buildReturnEntityFromMap(
    Map<String, dynamic> data, {
    required SyncStatus syncStatus,
  }) {
    final createdAt =
        DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
        DateTime.now();
    final updatedAt =
        DateTime.tryParse(data['updatedAt']?.toString() ?? '') ?? createdAt;

    final itemsData = data['items'];
    final List<ReturnItemEntity> items = [];
    if (itemsData is List) {
      for (final entry in itemsData) {
        if (entry is! Map) continue;
        final map = Map<String, dynamic>.from(entry);
        items.add(
          ReturnItemEntity()
            ..productId = map['productId']?.toString() ?? ''
            ..name = map['name']?.toString() ?? ''
            ..quantity = _toDouble(map['quantity']) ?? 0.0
            ..unit = map['unit']?.toString() ?? ''
            ..price = _toDouble(map['price']),
        );
      }
    }

    return ReturnEntity()
      ..id = data['id']?.toString() ?? generateId()
      ..returnType = data['returnType']?.toString() ?? 'stock_return'
      ..salesmanId = data['salesmanId']?.toString() ?? ''
      ..salesmanName = data['salesmanName']?.toString() ?? ''
      ..items = items
      ..reason = data['reason']?.toString() ?? ''
      ..reasonCode = data['reasonCode']?.toString()
      ..status = data['status']?.toString() ?? 'pending'
      ..disposition = data['disposition']?.toString()
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..approvedBy = data['approvedBy']?.toString()
      ..originalSaleId = data['originalSaleId']?.toString()
      ..customerId = data['customerId']?.toString()
      ..customerName = data['customerName']?.toString()
      ..syncStatus = syncStatus;
  }

  Future<String> _enqueueReturnForSync(
    Map<String, dynamic> requestData, {
    required String action,
  }) async {
    final returnId = requestData['id']?.toString();
    if (returnId == null || returnId.isEmpty) return '';

    final queueId = 'returns_${action}_$returnId';
    final existing = await _db.syncQueue.getById(queueId);
    final now = DateTime.now();
    final existingMeta = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          ).meta;
    final normalizedPayload = OutboxCodec.ensureCommandPayload(
      collection: returnsCollection,
      action: action,
      payload: requestData,
      existingMeta: existingMeta,
      queueId: queueId,
    );
    requestData
      ..clear()
      ..addAll(normalizedPayload);

    final entity = SyncQueueEntity()
      ..id = queueId
      ..collection = returnsCollection
      ..action = action
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: normalizedPayload,
        existingMeta: existingMeta,
        now: now,
        resetRetryState: true,
      )
      ..createdAt = existing?.createdAt ?? now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;

    await _db.db.writeTxn(() async {
      await _db.syncQueue.put(entity);
    });
    return queueId;
  }

  Future<void> _dequeueReturnSync(String queueId) async {
    if (queueId.isEmpty) return;
    final existing = await _db.syncQueue.getById(queueId);
    if (existing == null) return;
    await _db.db.writeTxn(() async {
      await _db.syncQueue.delete(existing.isarId);
    });
  }

  Future<bool> _queueAndSyncReturn({
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final queueId = await _enqueueReturnForSync(payload, action: action);
    if (db == null) return false;
    try {
      await performSync(action, returnsCollection, payload);
      await _dequeueReturnSync(queueId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _migrateLegacyReturnsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool(_legacyMigrationFlag) ?? false;
    if (migrated) return;

    final jsonStr = prefs.getString(localStorageKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      await prefs.setBool(_legacyMigrationFlag, true);
      return;
    }

    List<dynamic> legacyList;
    try {
      legacyList = jsonDecode(jsonStr) as List<dynamic>;
    } catch (_) {
      return;
    }

    if (legacyList.isEmpty) {
      await prefs.setBool(_legacyMigrationFlag, true);
      return;
    }

    final existingReturns = await _db.returns.where().findAll();
    final existingIds = existingReturns.map((e) => e.id).toSet();

    final existingQueueItems = await _db.syncQueue
        .filter()
        .collectionEqualTo(returnsCollection)
        .findAll();
    final queuedIds = <String>{};
    for (final item in existingQueueItems) {
      queuedIds.add(item.id);
    }

    await _db.db.writeTxn(() async {
      for (final entry in legacyList) {
        if (entry is! Map) continue;
        final data = Map<String, dynamic>.from(entry);
        final id = data['id']?.toString();
        if (id == null || id.isEmpty) continue;
        if (existingIds.contains(id)) continue;

        final isSynced = data['isSynced'] == true;
        final needsSync = !isSynced;

        final entity = _buildReturnEntityFromMap(
          data,
          syncStatus: needsSync ? SyncStatus.pending : SyncStatus.synced,
        );
        await _db.returns.put(entity);
        existingIds.add(id);

        if (needsSync) {
          final queueId = 'returns_set_$id';
          if (!queuedIds.contains(queueId)) {
            final queueEntity = SyncQueueEntity()
              ..id = queueId
              ..collection = returnsCollection
              ..action = 'set'
              ..dataJson = OutboxCodec.encodeEnvelope(
                payload: data,
                now: DateTime.now(),
                resetRetryState: true,
              )
              ..createdAt = DateTime.now()
              ..updatedAt = DateTime.now()
              ..syncStatus = SyncStatus.pending;
            await _db.syncQueue.put(queueEntity);
            queuedIds.add(queueId);
          }
        }
      }
    });

    await prefs.remove(localStorageKey);
    await prefs.setBool(_legacyMigrationFlag, true);
  }

  // Get pending return requests count
  Future<int> getReturnRequestsCount({String? salesmanId}) async {
    // Check cache first (primitive implementation)
    if (_cachedCount != null &&
        _countCacheTimestamp != null &&
        DateTime.now().difference(_countCacheTimestamp!) < _cacheTTL &&
        salesmanId == null) {
      // Only cache global count
      return _cachedCount!;
    }

    try {
      await _migrateLegacyReturnsIfNeeded();
      final count = await _db.returns.filter().statusEqualTo('pending').count();
      return count;
    } catch (e) {
      handleError(e, 'getReturnRequestsCount');
      return 0;
    }
  }

  // 🔒 LOCKED FIX #3 (2026-02-16): Local-first Isar query.
  // DO NOT revert to Firestore-only. See .agent/LOCKED_FIXES_returns_service.md
  Future<List<ReturnRequest>> getReturnRequests({
    String? status,
    String? salesmanId,
    int? limitCount,
  }) async {
    try {
      await _migrateLegacyReturnsIfNeeded();

      // ── 1. Local Isar query (always fast, works offline) ──
      var query = _db.returns.filter().optional(
        status != null,
        (q) => q.statusEqualTo(status!),
      );

      if (salesmanId != null) {
        query = query.salesmanIdEqualTo(salesmanId);
      }

      var localResults = await query.sortByCreatedAtDesc().findAll();

      if (limitCount != null && localResults.length > limitCount) {
        localResults = localResults.sublist(0, limitCount);
      }

      final returns = localResults.map((e) => e.toDomain()).toList();

      // DEDUPLICATE to prevent duplicate returns in UI
      return deduplicate(returns, (r) => r.id);
    } catch (e) {
      handleError(e, 'getReturnRequests');
      rethrow;
    }
  }

  // Submit return request
  Future<bool> addReturnRequest({
    required String returnType,
    required String salesmanId,
    required String salesmanName,
    required List<ReturnItem> items,
    required String reason,
    String? reasonCode,
    String? disposition,
    String? customerId,
    String? customerName,
    String? originalSaleId,
  }) async {
    try {
      await _migrateLegacyReturnsIfNeeded();
      final actor = await _capabilityGuard.requireCapability(
        RoleCapability.returnsCreate,
        operation: 'create return request',
      );
      if (!_canCreateReturnForSalesman(
        actorRole: actor.role,
        actorId: actor.id,
        salesmanId: salesmanId,
      )) {
        throw Exception(
          'Access denied for create return request: salesman assignment mismatch.',
        );
      }
      final newId = generateId();
      final now = DateTime.now();

      final returnEntity = ReturnEntity()
        ..id = newId
        ..returnType = returnType
        ..salesmanId = salesmanId
        ..salesmanName = salesmanName
        ..items = items
            .map(
              (i) => ReturnItemEntity()
                ..productId = i.productId
                ..name = i.name
                ..quantity = i.quantity
                ..unit = i.unit
                ..price = i.price,
            )
            .toList()
        ..reason = reason
        ..reasonCode = reasonCode
        ..status =
            'pending' // Always starts as pending Supervisor Approval
        ..disposition = disposition
        ..createdAt = now
        ..updatedAt = now
        ..customerId = customerId
        ..customerName = customerName
        ..originalSaleId = originalSaleId
        ..syncStatus = SyncStatus.pending;

      // 1. Save to Local DB (Isar)
      await _db.db.writeTxn(() async {
        await _db.returns.put(returnEntity);
      });

      // 🔒 LOCKED FIX #2 (2026-02-16): Fire-and-forget sync — DO NOT await.
      final requestData = returnEntity.toDomain().toJson();
      _queueAndSyncReturn(action: 'set', payload: requestData)
          .then((synced) async {
            if (synced) {
              try {
                await _db.db.writeTxn(() async {
                  final existing = await _db.returns
                      .filter()
                      .idEqualTo(newId)
                      .findFirst();
                  if (existing != null) {
                    existing.syncStatus = SyncStatus.synced;
                    existing.updatedAt = DateTime.now();
                    await _db.returns.put(existing);
                  }
                });
              } catch (e) {
                AppLogger.warning(
                  'Failed to mark return $newId as synced: $e',
                  tag: 'Returns',
                );
              }
            }
          })
          .catchError((e) {
            AppLogger.warning(
              'Background sync failed for new return $newId: $e',
              tag: 'Returns',
            );
          });

      _cachedCount = null;
      AppLogger.success(
        'Return request submitted locally: $newId',
        tag: 'Returns',
      );
      return true;
    } catch (e) {
      handleError(e, 'addReturnRequest');
      rethrow;
    }
  }

  // Approve return request (Offline First)
  // FIX: All local mutations are now in a SINGLE writeTxn to prevent
  // nested transaction errors from adjustSalesmanStock/adjustCustomerBalance/
  // updateSaleItemReturnedQty which each open their own writeTxn.
  Future<bool> approveReturnRequest(String returnId, String approverId) async {
    try {
      await _migrateLegacyReturnsIfNeeded();
      await _capabilityGuard.requireCapability(
        RoleCapability.returnsApproveReject,
        operation: 'approve return request',
      );
      final now = DateTime.now();

      // 1. Fetch Local Request
      final requestEntity = await _db.returns.get(fastHash(returnId));
      if (requestEntity == null) {
        throw Exception('Return request not found locally.');
      }
      if (requestEntity.status != 'pending') {
        throw Exception(
          'Return request has already been ${requestEntity.status}.',
        );
      }

      final request = requestEntity.toDomain();
      final inventoryActorUid = _resolveInventoryActorUid(
        fallbackUserId: approverId,
      );
      final inventoryActorLegacyId = _resolveInventoryActorLegacyId(approverId);

      // 2. SINGLE ATOMIC TRANSACTION — all local mutations happen here.
      //    This avoids nested writeTxn crashes from calling
      //    adjustSalesmanStock / adjustCustomerBalance / updateSaleItemReturnedQty
      //    which each open their own writeTxn.
      await _db.db.writeTxn(() async {
        // ── A. Sales-Return specific: customer balance & sale qty ──
        if (request.returnType == 'sales_return') {
          // A1. Adjust Customer Balance (inline from CustomersService)
          double totalCredit = 0;
          for (final item in request.items) {
            totalCredit += (item.price ?? 0) * item.quantity;
          }
          if (request.customerId != null && totalCredit > 0) {
            final customer = await _db.customers
                .filter()
                .idEqualTo(request.customerId!)
                .findFirst();
            if (customer != null) {
              customer.balance -= totalCredit;
              customer.updatedAt = now;
              customer.syncStatus = SyncStatus.pending;
              await _db.customers.put(customer);
            }
          }

          // A2. Update Sale Item Returned Qty (inline from SalesService)
          if (request.originalSaleId != null) {
            final saleEntity = await _db.sales.get(
              fastHash(request.originalSaleId!),
            );
            if (saleEntity != null) {
              final saleItems = saleEntity.items ?? [];
              for (final returnItem in request.items) {
                for (var i = 0; i < saleItems.length; i++) {
                  if (saleItems[i].productId == returnItem.productId) {
                    // Use round() not toInt() — toInt() truncates 2.9 to 2
                    saleItems[i].returnedQuantity =
                        (saleItems[i].returnedQuantity ?? 0) +
                        returnItem.quantity.round();
                    break;
                  }
                }
              }
              saleEntity.items = saleItems;
              saleEntity.syncStatus = SyncStatus.pending;
              saleEntity.updatedAt = now;
              await _db.sales.put(saleEntity);
            }
          }
        }

        // ── B. Stock Adjustments ──
        for (final item in request.items) {
          if (request.returnType == 'stock_return') {
            // B1. Add to Main Warehouse — use returned balance for accurate ledger
            // T9-P3 REMOVED: warehouse restore now happens through the
            // InventoryMovementEngine transfer inside _adjustSalesmanStockInTxn.
            // final product = await _db.products.get(fastHash(item.productId));
            double newBalance = 0.0;
            // T9-P3 REMOVED: direct warehouse stock mutation moved to the
            // single transfer command applied below.
            // if (product != null) {
            //   final updatedProduct = await _inventoryService
            //       .applyProductStockChangeInTxn(
            //         productId: item.productId,
            //         quantityChange: item.quantity,
            //         updatedAt: now,
            //         markSyncPending: true,
            //       );
            //   newBalance =
            //       updatedProduct?.stock ??
            //       ((product.stock ?? 0) + item.quantity);
            // }

            // B2. Deduct from Salesman (inline — no nested writeTxn)
            await _adjustSalesmanStockInTxn(
              salesmanId: request.salesmanId,
              productId: item.productId,
              quantity: -item.quantity,
              reason: 'Stock Return Approved',
              referenceId: returnId,
              referenceType: 'stock_return',
              now: now,
            );
            final updatedProduct = await _db.products.getById(item.productId);
            newBalance = updatedProduct?.stock ?? 0.0;

            // B3. Create Stock Ledger Entry with CORRECT post-change balance
            final ledgerEntry = StockLedgerEntity()
              ..id = generateId()
              ..productId = item.productId
              ..warehouseId = 'Main'
              ..transactionDate = now
              ..transactionType = 'RETURN_IN'
              ..referenceId = returnId
              ..quantityChange = item.quantity
              ..runningBalance = newBalance
              ..unit = item.unit
              ..performedBy = approverId
              ..notes = 'Stock Return: $returnId from ${request.salesmanName}'
              ..syncStatus = SyncStatus.pending
              ..updatedAt = now;
            await _db.stockLedger.put(ledgerEntry);
          } else if (request.returnType == 'sales_return') {
            if (request.disposition == 'Good Stock') {
              // Return good stock back to salesman's allocation
              if (request.items.length == 1) {
                await _adjustSalesmanStockInTxn(
                  salesmanId: request.salesmanId,
                  productId: item.productId,
                  quantity: item.quantity,
                  reason: 'Customer Return: Good Stock',
                  referenceId: returnId,
                  referenceType: 'sales_return',
                  now: now,
                );
              } else if (identical(item, request.items.first)) {
                await _applySalesReturnGoodStockInTxn(
                  request: request,
                  actorUid: inventoryActorUid,
                  actorLegacyAppUserId: inventoryActorLegacyId,
                  occurredAt: now,
                  referenceId: returnId,
                );
              }
            } else {
              // Bad stock → Return to main inventory
              if (identical(item, request.items.first)) {
                await _applySalesReturnBadStockInTxn(
                  request: request,
                  actorUid: inventoryActorUid,
                  actorLegacyAppUserId: inventoryActorLegacyId,
                  occurredAt: now,
                  referenceId: returnId,
                );
              }
              // T9-P3 REMOVED: direct warehouse product stock mutation replaced
              // by sale_reversal + internal_transfer commands.
              // final product = await _db.products.get(fastHash(item.productId));
              final updatedProduct = await _db.products.getById(item.productId);
              final updatedStock = updatedProduct?.stock;
              // if (product != null) {
              //   await _inventoryService.applyProductStockChangeInTxn(
              //     productId: item.productId,
              //     quantityChange: item.quantity,
              //     updatedAt: now,
              //     markSyncPending: true,
              //   );
              // }
              // Create Stock Ledger Entry (Main Warehouse IN - Bad Stock)
              final ledgerEntry = StockLedgerEntity()
                ..id = generateId()
                ..productId = item.productId
                ..warehouseId = 'Main'
                ..transactionDate = now
                ..transactionType = 'RETURN_BAD_STOCK'
                ..referenceId = returnId
                ..quantityChange = item.quantity
                ..runningBalance = updatedStock ?? 0.0
                ..unit = item.unit
                ..performedBy = approverId
                ..notes =
                    'Bad Stock Return: $returnId (Original Sale: ${request.originalSaleId})'
                ..syncStatus = SyncStatus.pending
                ..updatedAt = now;
              await _db.stockLedger.put(ledgerEntry);
            }
          }
        }

        // ── C. Mark request as approved locally ──
        requestEntity.status = 'approved';
        requestEntity.updatedAt = now;
        requestEntity.syncStatus = SyncStatus.pending;
        await _db.returns.put(requestEntity);
      });

      // 🔒 LOCKED FIX #2 (2026-02-16): Fire-and-forget sync — DO NOT await.
      //    The local Isar write is already committed (offline-first).
      //    Sync runs in background; if it fails, the sync queue retries later.
      final requestData = {
        'id': returnId,
        'approverId': approverId,
        'updatedAt': now.toIso8601String(),
      };

      _queueAndSyncReturn(action: 'approve', payload: requestData)
          .then((synced) async {
            if (synced) {
              try {
                await _db.db.writeTxn(() async {
                  final existing = await _db.returns
                      .filter()
                      .idEqualTo(returnId)
                      .findFirst();
                  if (existing != null) {
                    existing.syncStatus = SyncStatus.synced;
                    existing.updatedAt = now;
                    await _db.returns.put(existing);
                  }
                });
              } catch (e) {
                AppLogger.warning(
                  'Failed to mark return $returnId as synced: $e',
                  tag: 'Returns',
                );
              }
            }
          })
          .catchError((e) {
            AppLogger.warning(
              'Background sync failed for return approval $returnId: $e',
              tag: 'Returns',
            );
          });

      await NotificationService().publishNotificationEvent(
        title: 'Return Approved',
        body: 'Return request $returnId has been approved.',
        eventType: 'return_approved',
        targetUserIds: {request.salesmanId},
        targetRoles: const {UserRole.salesman},
        data: {
          'returnId': returnId,
          'status': 'approved',
          'salesmanName': request.salesmanName,
        },
        route: '/dashboard/returns',
        forceSound: true,
      );

      _cachedCount = null;
      return true;
    } catch (e) {
      handleError(e, 'approveReturnRequest');
      rethrow;
    }
  }

  /// Inline salesman stock adjustment for use inside an existing writeTxn.
  /// Mirrors InventoryService.adjustSalesmanStock but without opening its own transaction.
  Future<void> _adjustSalesmanStockInTxn({
    required String salesmanId,
    required String productId,
    required double quantity,
    required String reason,
    required String referenceId,
    String? referenceType,
    required DateTime now,
  }) async {
    final user = await _db.users.filter().idEqualTo(salesmanId).findFirst();
    if (user == null) {
      // Salesman user record may not be synced to this device (e.g. admin
      // approving from a different device). Skip local stock adjustment —
      // the server-side performSync will handle Firestore stock correctly,
      // and next delta-sync will reconcile local data.
      AppLogger.warning(
        'Salesman $salesmanId not found locally — skipping local stock adjustment. '
        'Server sync will reconcile.',
        tag: 'Returns',
      );
      return;
    }

    final actorUid = _resolveInventoryActorUid(fallbackUserId: salesmanId);
    final actorLegacyAppUserId = _resolveInventoryActorLegacyId(salesmanId);
    final salesmanLocationId =
        InventoryProjectionService.salesmanLocationIdForUid(salesmanId);
    final commandItem = InventoryCommandItem(
      productId: productId,
      quantityBase: quantity.abs(),
    );
    Map<String, dynamic> allocMap = {};
    if (quantity.abs() >= 1e-9) {
      await _ensureInventoryLocationInTxn(salesmanLocationId);
      if (quantity < 0) {
        await _ensureInventoryLocationInTxn(
          InventoryProjectionService.warehouseMainLocationId,
        );
        await _seedSourceBalancesInTxn(
          sourceLocationId: salesmanLocationId,
          items: [commandItem],
          occurredAt: now,
        );
        final command = InventoryCommand.internalTransfer(
          sourceLocationId: salesmanLocationId,
          destinationLocationId:
              InventoryProjectionService.warehouseMainLocationId,
          referenceId: referenceId,
          productId: productId,
          quantityBase: quantity.abs(),
          actorUid: actorUid,
          actorLegacyAppUserId: actorLegacyAppUserId,
          reasonCode: 'return_salesman_to_warehouse',
          referenceType: referenceType ?? 'stock_return',
          createdAt: now,
        );
        await _inventoryMovementEngine.applyCommandInTxn(command);
      } else {
        final returnEntity = await _db.returns
            .filter()
            .idEqualTo(referenceId)
            .findFirst();
        final request = returnEntity?.toDomain();
        final originalCommandId = request == null
            ? 'sale:$referenceId'
            : _resolveOriginalSaleCommandId(request);
        final command = InventoryCommand(
          commandId: 'reversal:$originalCommandId',
          commandType: InventoryCommandType.saleReversal,
          payload: <String, dynamic>{
            'originalCommandId': originalCommandId,
            'sourceLocationId':
                InventoryProjectionService.virtualSoldLocationId,
            'destinationLocationId': salesmanLocationId,
            'referenceId': referenceId,
            'referenceType': 'sale_reversal',
            'reasonCode': 'return_salesman_restore',
            'items': [commandItem.toJson()],
          },
          actorUid: actorUid,
          actorLegacyAppUserId: actorLegacyAppUserId,
          createdAt: now,
        );
        await _inventoryMovementEngine.applyCommandInTxn(command);
      }
    }
    final updatedUser = await _db.users.getById(salesmanId);
    if (updatedUser == null) {
      throw Exception(
        'Salesman not found after inventory adjustment: $salesmanId',
      );
    }
    if (updatedUser.allocatedStockJson != null) {
      allocMap =
          jsonDecode(updatedUser.allocatedStockJson!) as Map<String, dynamic>;
    }

    // T9-P3 REMOVED: direct allocatedStock mutation is no longer the write path.
    final currentAlloc = allocMap[productId] as Map<String, dynamic>?;
    if (_isLegacyMutationPathEnabled() && currentAlloc != null) {
      final currentQty = (currentAlloc['quantity'] as num).toDouble();
      final newQty = currentQty + quantity;

      if (newQty < -1e-9) {
        throw Exception(
          'Insufficient allocated stock for $productId. Available: $currentQty, requested change: $quantity',
        );
      }

      currentAlloc['quantity'] = newQty;
      allocMap[productId] = currentAlloc;
    } else if (_isLegacyMutationPathEnabled()) {
      if (quantity > 0) {
        final product = await _db.products
            .filter()
            .idEqualTo(productId)
            .findFirst();
        if (product != null) {
          allocMap[productId] = {
            'productId': productId,
            'name': product.name,
            'quantity': quantity,
            'freeQuantity': 0.0,
            'price': product.price ?? 0.0,
            'baseUnit': product.baseUnit,
          };
        }
      } else {
        // Allocation record missing locally — server sync will reconcile.
        AppLogger.warning(
          'Allocated stock not found locally for $productId (change: $quantity). '
          'Server sync will reconcile.',
          tag: 'Returns',
        );
        return;
      }
    }

    updatedUser.allocatedStockJson = jsonEncode(allocMap);
    updatedUser.updatedAt = now;
    updatedUser.syncStatus = SyncStatus.pending;
    await _db.users.put(updatedUser);

    // Create ledger entry for salesman stock change
    final allocatedQty = (allocMap[productId]?['quantity'] as num? ?? 0)
        .toDouble();
    final freeQty = (allocMap[productId]?['freeQuantity'] as num? ?? 0)
        .toDouble();
    final ledgerEntry = StockLedgerEntity()
      ..id = generateId()
      ..productId = productId
      ..warehouseId = 'Salesman'
      ..transactionDate = now
      ..transactionType = quantity > 0 ? 'RETURN_IN' : 'SALE_OUT'
      ..referenceId = referenceId
      ..quantityChange = quantity
      ..runningBalance = allocatedQty + freeQty
      ..unit = allocMap[productId]?['baseUnit'] ?? 'Unit'
      ..performedBy = salesmanId
      ..notes = referenceType != null ? 'Ref Type: $referenceType' : null
      ..syncStatus = SyncStatus.pending
      ..updatedAt = now;
    await _db.stockLedger.put(ledgerEntry);
  }

  Future<void> applySalesmanStockAdjustmentForTest({
    required String salesmanId,
    required String productId,
    required double quantity,
    required String reason,
    required String referenceId,
    String? referenceType,
    DateTime? occurredAt,
  }) async {
    await _db.db.writeTxn(() async {
      await _adjustSalesmanStockInTxn(
        salesmanId: salesmanId,
        productId: productId,
        quantity: quantity,
        reason: reason,
        referenceId: referenceId,
        referenceType: referenceType,
        now: occurredAt ?? DateTime.now(),
      );
    });
  }

  // Reject return request (Offline First)
  Future<bool> rejectReturnRequest(String returnId, String rejectorId) async {
    try {
      await _migrateLegacyReturnsIfNeeded();
      await _capabilityGuard.requireCapability(
        RoleCapability.returnsApproveReject,
        operation: 'reject return request',
      );
      final now = DateTime.now();

      // 1. Fetch Local
      final requestEntity = await _db.returns.get(fastHash(returnId));
      if (requestEntity == null) {
        throw Exception('Return request not found locally.');
      }

      // 2. Update Local
      await _db.db.writeTxn(() async {
        requestEntity.status = 'rejected';
        requestEntity.updatedAt = now;
        requestEntity.syncStatus = SyncStatus.pending;
        await _db.returns.put(requestEntity);
      });

      // 🔒 LOCKED FIX #2 (2026-02-16): Fire-and-forget sync — DO NOT await.
      final requestData = {
        'id': returnId,
        'rejectorId': rejectorId,
        'updatedAt': now.toIso8601String(),
      };

      _queueAndSyncReturn(action: 'reject', payload: requestData)
          .then((synced) async {
            if (synced) {
              try {
                await _db.db.writeTxn(() async {
                  final existing = await _db.returns
                      .filter()
                      .idEqualTo(returnId)
                      .findFirst();
                  if (existing != null) {
                    existing.syncStatus = SyncStatus.synced;
                    existing.updatedAt = now;
                    await _db.returns.put(existing);
                  }
                });
              } catch (e) {
                AppLogger.warning(
                  'Failed to mark return $returnId as synced: $e',
                  tag: 'Returns',
                );
              }
            }
          })
          .catchError((e) {
            AppLogger.warning(
              'Background sync failed for return rejection $returnId: $e',
              tag: 'Returns',
            );
          });

      await NotificationService().publishNotificationEvent(
        title: 'Return Rejected',
        body: 'Return request $returnId has been rejected.',
        eventType: 'return_rejected',
        targetUserIds: {requestEntity.salesmanId},
        targetRoles: const {UserRole.salesman},
        data: {'returnId': returnId, 'status': 'rejected'},
        route: '/dashboard/returns',
        forceSound: true,
      );

      _cachedCount = null;
      return true;
    } catch (e) {
      handleError(e, 'rejectReturnRequest');
      rethrow;
    }
  }

  // 🔒 LOCKED FIX #1 (2026-02-16): WriteBatch instead of runTransaction.
  // DO NOT use runTransaction — it crashes Windows (platform-channel threading).
  // See .agent/LOCKED_FIXES_returns_service.md
  @override
  Future<void> performSync(
    String action,
    String collection,
    Map<String, dynamic> data,
  ) async {
    final firestoreDb = db;
    if (firestoreDb == null) return;

    try {
      if (collection == returnsCollection) {
        if (action == 'approve') {
          final String returnId = data['id'];
          final String approverId = data['approverId'];
          final commandKey =
              OutboxCodec.readIdempotencyKey(data) ??
              OutboxCodec.buildCommandKey(
                collection: collection,
                action: action,
                payload: data,
              );

          // Read the return document first (outside transaction to avoid
          // platform-channel threading crash on Windows desktop).
          final returnRef = firestoreDb
              .collection(returnsCollection)
              .doc(returnId);
          final returnDoc = await returnRef.get();
          if (!returnDoc.exists) return;
          final returnData = returnDoc.data() ?? const <String, dynamic>{};
          if (returnData['status']?.toString() == 'approved') {
            // Idempotent replay guard: financial/stock effects already applied.
            return;
          }

          final request = ReturnRequest.fromJson(returnData);
          final occurredAt =
              DateTime.tryParse(data['updatedAt']?.toString() ?? '') ??
              DateTime.now();
          await _ensureReturnApprovalInventoryApplied(
            request: request,
            referenceId: returnId,
            actorUid: _resolveInventoryActorUid(fallbackUserId: approverId),
            actorLegacyAppUserId: _resolveInventoryActorLegacyId(approverId),
            occurredAt: occurredAt,
          );

          // Use WriteBatch instead of runTransaction — avoids platform
          // channel crash on Windows while still being atomic for writes.
          final batch = firestoreDb.batch();

          // T9-P3 REMOVED: direct Firestore stock writes are replaced by
          // InventoryMovementEngine commands and the inventory-command outbox.
          if (_isLegacyMutationPathEnabled()) {
            for (final item in request.items) {
              final productRef = firestoreDb
                  .collection(productsCollection)
                  .doc(item.productId);

              if (request.returnType == 'stock_return') {
                final salesmanRef = firestoreDb
                    .collection(usersCollection)
                    .doc(request.salesmanId);
                batch.update(productRef, {
                  'stock': fs.FieldValue.increment(item.quantity),
                });
                batch.update(salesmanRef, {
                  'allocatedStock.${item.productId}.quantity':
                      fs.FieldValue.increment(-item.quantity),
                });
              } else if (request.returnType == 'sales_return') {
                if (request.disposition == 'Good Stock') {
                  final salesmanRef = firestoreDb
                      .collection(usersCollection)
                      .doc(request.salesmanId);
                  batch.set(salesmanRef, {
                    'allocatedStock': {
                      item.productId: {
                        'quantity': fs.FieldValue.increment(item.quantity),
                        'name': item.name,
                        'unit': item.unit,
                      },
                    },
                  }, fs.SetOptions(merge: true));
                } else {
                  batch.update(productRef, {
                    'stock': fs.FieldValue.increment(item.quantity),
                  });
                }
              }
            }
          }

          if (request.returnType == 'sales_return') {
            double totalCredit = 0;
            for (final item in request.items) {
              totalCredit += (item.price ?? 0) * item.quantity;
            }

            if (request.customerId != null && totalCredit > 0) {
              final customerRef = firestoreDb
                  .collection(customersCollection)
                  .doc(request.customerId);
              batch.update(customerRef, {
                'balance': fs.FieldValue.increment(-totalCredit),
              });
            }

            if (request.originalSaleId != null) {
              final saleRef = firestoreDb
                  .collection(salesCollection)
                  .doc(request.originalSaleId);
              final saleSnap = await saleRef.get();
              if (saleSnap.exists) {
                final saleData = saleSnap.data()!;
                final items = (saleData['items'] as List)
                    .cast<Map<String, dynamic>>();
                for (final returnItem in request.items) {
                  for (final saleItem in items) {
                    if (saleItem['productId'] == returnItem.productId) {
                      saleItem['returnedQuantity'] =
                          (saleItem['returnedQuantity'] ?? 0) +
                          returnItem.quantity;
                      break;
                    }
                  }
                }
                batch.update(saleRef, {
                  'items': items,
                  'updatedAt': data['updatedAt'],
                });
              }
            }
          }

          batch.update(returnRef, {
            'status': 'approved',
            'updatedAt': data['updatedAt'],
            'approvedBy': approverId,
            'approvalIdempotencyKey': commandKey,
          });

          await batch.commit();
        } else if (action == 'reject') {
          await firestoreDb
              .collection(returnsCollection)
              .doc(data['id'])
              .update({
                'status': 'rejected',
                'updatedAt': data['updatedAt'],
                'approvedBy': data['rejectorId'],
              });
        } else {
          // Default set for 'add'/'set'
          await firestoreDb
              .collection(collection)
              .doc(data['id'])
              .set(data, fs.SetOptions(merge: true));
        }
      }
    } catch (e) {
      AppLogger.error(
        'performSync failed for $action on $collection',
        error: e,
        tag: 'Returns',
      );
      rethrow; // Let the sync queue handle retry
    }
  }
}
