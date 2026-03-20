import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/core/constants/collection_registry.dart';
import 'package:flutter_app/core/sync/sync_queue_service.dart';
import 'package:flutter_app/core/sync/sync_service.dart';
import '../models/inventory/opening_stock_entry.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/opening_stock_entity.dart';
import '../data/local/entities/stock_ledger_entity.dart';
import '../data/local/entities/inventory_location_entity.dart';
import '../utils/app_logger.dart';
import 'delegates/firestore_query_delegate.dart';
import 'database_service.dart';
import 'package:uuid/uuid.dart';
import 'inventory_movement_engine.dart';

class OpeningStockService {
  static const String mainWarehouseId = 'warehouse_main';
  static const String _dedupeMigrationFlag =
      'opening_stock_set_balance_migrated_v1';
  final FirestoreQueryDelegate _remote;
  final Uuid _uuid = const Uuid();
  final DatabaseService _dbService;
  final InventoryMovementEngine _inventoryMovementEngine;
  static const String _openingCollection =
      CollectionRegistry.openingStockEntries;
  bool _dedupeMigrationChecked = false;
  bool _warehouseLocationEnsured = false;

  OpeningStockService(
    this._dbService,
    this._inventoryMovementEngine, [
    FirebaseFirestore? firestore,
  ]) : _remote = FirestoreQueryDelegate(firestore);

  Future<void> _enqueueOutbox({
    required String collection,
    required Map<String, dynamic> payload,
    String action = 'set',
    String? explicitRecordKey,
  }) async {
    final documentId = explicitRecordKey?.trim().isNotEmpty == true
        ? explicitRecordKey!.trim()
        : payload['id']?.toString().trim() ?? '';
    if (documentId.isEmpty) return;
    await SyncQueueService.instance.addToQueue(
      collectionName: collection,
      documentId: documentId,
      operation: action,
      payload: payload,
    );
  }

  Map<String, dynamic> _openingPayload(OpeningStockEntity entity) {
    final payload = entity.toDomain().toJson();
    payload['id'] = entity.id;
    payload['entryDate'] = entity.entryDate.toIso8601String();
    payload['createdAt'] = entity.createdAt.toIso8601String();
    payload['updatedAt'] = entity.updatedAt.toIso8601String();
    return payload;
  }

  String _openingKey(String productId, String warehouseId) =>
      '${productId.trim()}::${warehouseId.trim()}';

  OpeningStockEntity _pickCanonicalOpeningEntity(
    List<OpeningStockEntity> entities,
  ) {
    final sorted = [...entities]
      ..sort((a, b) {
        final updated = b.updatedAt.compareTo(a.updatedAt);
        if (updated != 0) return updated;
        final entryDate = b.entryDate.compareTo(a.entryDate);
        if (entryDate != 0) return entryDate;
        final created = b.createdAt.compareTo(a.createdAt);
        if (created != 0) return created;
        return b.id.compareTo(a.id);
      });
    return sorted.first;
  }

  StockLedgerEntity _pickCanonicalOpeningLedger(
    List<StockLedgerEntity> entities,
  ) {
    final sorted = [...entities]
      ..sort((a, b) {
        final updated = b.updatedAt.compareTo(a.updatedAt);
        if (updated != 0) return updated;
        final transactionDate = b.transactionDate.compareTo(a.transactionDate);
        if (transactionDate != 0) return transactionDate;
        return b.id.compareTo(a.id);
      });
    return sorted.first;
  }

  Future<void> _migrateOpeningStockSetBalanceIfNeeded() async {
    if (_dedupeMigrationChecked) return;
    _dedupeMigrationChecked = true;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_dedupeMigrationFlag) == true) return;

    final openingEntries = await _dbService.openingStockEntries
        .where()
        .findAll();
    final openingLedgers = await _dbService.stockLedger.where().findAll();
    final groupedEntries = <String, List<OpeningStockEntity>>{};

    for (final entry in openingEntries) {
      groupedEntries
          .putIfAbsent(
            _openingKey(entry.productId, entry.warehouseId),
            () => [],
          )
          .add(entry);
    }

    final duplicateGroups = groupedEntries.values.where((e) => e.length > 1);
    final hasDuplicateEntries = duplicateGroups.isNotEmpty;
    final hasDuplicateOpeningLedgers = openingLedgers
        .where((entry) => entry.transactionType == 'OPENING')
        .fold<Map<String, int>>({}, (counts, entry) {
          final key = _openingKey(entry.productId, entry.warehouseId);
          counts[key] = (counts[key] ?? 0) + 1;
          return counts;
        })
        .values
        .any((entryCount) => entryCount > 1);

    if (!hasDuplicateEntries && !hasDuplicateOpeningLedgers) {
      await prefs.setBool(_dedupeMigrationFlag, true);
      return;
    }

    final products = await _dbService.products.where().findAll();
    final productById = {for (final product in products) product.id: product};
    final openingLedgersByKey = <String, List<StockLedgerEntity>>{};
    for (final ledger in openingLedgers.where(
      (entry) => entry.transactionType == 'OPENING',
    )) {
      openingLedgersByKey
          .putIfAbsent(
            _openingKey(ledger.productId, ledger.warehouseId),
            () => [],
          )
          .add(ledger);
    }

    await _dbService.db.writeTxn(() async {
      for (final bucket in groupedEntries.entries) {
        final key = bucket.key;
        final entries = bucket.value;
        final canonicalEntry = _pickCanonicalOpeningEntity(entries);
        final duplicateEntries = entries
            .where((entry) => entry.id != canonicalEntry.id)
            .toList();
        final ledgers = openingLedgersByKey[key] ?? const <StockLedgerEntity>[];
        final canonicalLedger = ledgers.isEmpty
            ? null
            : _pickCanonicalOpeningLedger(ledgers);
        final duplicateLedgers = canonicalLedger == null
            ? ledgers
            : ledgers.where((entry) => entry.id != canonicalLedger.id).toList();

        if (duplicateEntries.isEmpty && duplicateLedgers.isEmpty) {
          continue;
        }

        final product = productById[canonicalEntry.productId];
        if (product != null) {
          product
            ..stock = canonicalEntry.quantity
            ..updatedAt = DateTime.now()
            ..syncStatus = SyncStatus.pending;
          await _dbService.products.put(product);
        }

        for (final duplicate in duplicateEntries) {
          await _dbService.openingStockEntries.delete(duplicate.isarId);
        }

        StockLedgerEntity ledgerToKeep;
        if (canonicalLedger != null) {
          ledgerToKeep = canonicalLedger
            ..referenceId = canonicalEntry.id
            ..quantityChange = canonicalEntry.quantity
            ..runningBalance = canonicalEntry.quantity
            ..unit = canonicalEntry.unit
            ..performedBy = canonicalEntry.createdBy
            ..transactionDate = canonicalEntry.entryDate
            ..notes = 'Initial Opening Stock'
            ..updatedAt = canonicalEntry.updatedAt
            ..syncStatus = SyncStatus.pending;
        } else {
          ledgerToKeep = StockLedgerEntity()
            ..id = _uuid.v4()
            ..productId = canonicalEntry.productId
            ..warehouseId = canonicalEntry.warehouseId
            ..transactionDate = canonicalEntry.entryDate
            ..transactionType = 'OPENING'
            ..referenceId = canonicalEntry.id
            ..quantityChange = canonicalEntry.quantity
            ..runningBalance = canonicalEntry.quantity
            ..unit = canonicalEntry.unit
            ..performedBy = canonicalEntry.createdBy
            ..notes = 'Initial Opening Stock'
            ..updatedAt = canonicalEntry.updatedAt
            ..syncStatus = SyncStatus.pending;
        }

        await _dbService.stockLedger.put(ledgerToKeep);
        for (final duplicateLedger in duplicateLedgers) {
          await _dbService.stockLedger.delete(duplicateLedger.isarId);
        }
      }
    });

    await prefs.setBool(_dedupeMigrationFlag, true);
    AppLogger.info(
      'Opening stock set-balance migration completed.',
      tag: 'Inventory',
    );
  }

  Future<OpeningStockEntity?> _findOpeningStockEntity({
    required String productId,
    required String warehouseId,
  }) async {
    final matches = await _dbService.openingStockEntries
        .filter()
        .productIdEqualTo(productId)
        .and()
        .warehouseIdEqualTo(warehouseId)
        .findAll();
    if (matches.isEmpty) return null;
    return _pickCanonicalOpeningEntity(matches);
  }

  Future<OpeningStockEntry?> getOpeningStock({
    required String productId,
    required String warehouseId,
  }) async {
    await _migrateOpeningStockSetBalanceIfNeeded();
    final entity = await _findOpeningStockEntity(
      productId: productId,
      warehouseId: warehouseId,
    );
    return entity?.toDomain();
  }

  Future<List<OpeningStockEntry>> getAllOpeningStocks() async {
    await _migrateOpeningStockSetBalanceIfNeeded();
    final entities = await _dbService.openingStockEntries.where().findAll();
    return entities.map((e) => e.toDomain()).toList();
  }

  /// Ensures Main warehouse location exists in database
  Future<void> _ensureMainWarehouseLocation() async {
    if (_warehouseLocationEnsured) return;

    final existing = await _dbService.inventoryLocations.getById(mainWarehouseId);
    if (existing != null) {
      _warehouseLocationEnsured = true;
      return;
    }

    await _dbService.db.writeTxn(() async {
      final warehouseLocation = InventoryLocationEntity()
        ..id = mainWarehouseId
        ..type = 'warehouse'
        ..name = 'Main Warehouse'
        ..code = 'WAREHOUSE_MAIN'
        ..parentLocationId = null
        ..ownerUserUid = null
        ..isActive = true
        ..isPrimaryMainWarehouse = true
        ..updatedAt = DateTime.now()
        ..syncStatus = SyncStatus.synced
        ..isDeleted = false;
      await _dbService.inventoryLocations.put(warehouseLocation);
    });

    _warehouseLocationEnsured = true;
    AppLogger.info(
      'Main warehouse location created',
      tag: 'Inventory',
    );
  }

  /// Creates an opening stock entry.
  ///
  /// CRITICAL RULES:
  /// 1. Checks strict "Go-Live" global lock. (If true, rejects).
  /// 2. Saves to Isar (Local) first to ensure Offline-first operation.
  /// 3. Creates the `OpeningStockEntry` record locally.
  /// 4. Updates Product `stock` cache in Isar.
  /// 5. Async-syncs to Firestore (Cloud Ledger + Cloud Product).
  Future<void> createOpeningStock({
    required String productId,
    required String productType,
    required String warehouseId,
    required double quantity,
    required String unit,
    double? openingRate,
    String? batchNumber,
    required String userId,
  }) async {
    await _migrateOpeningStockSetBalanceIfNeeded();
    await _ensureMainWarehouseLocation();

    // 1. CHECK GO-LIVE LOCK (Try Local First if available, or fetch)
    // For now we check Firestore directly for lock, but we could cache this too
    final generalSettingsDoc = await _remote.getDocument(
      collection: CollectionRegistry.settings,
      documentId: 'general',
    );

    if (generalSettingsDoc.exists) {
      final data = generalSettingsDoc.data();
      final goLiveCompleted = data?['goLiveCompleted'] == true;
      if (goLiveCompleted) {
        throw Exception(
          'SYSTEM LOCKED: Opening stock cannot be added after Go-Live.',
        );
      }
    }

    if (quantity <= 0) {
      throw Exception('Quantity must be greater than zero.');
    }

    final String entryId = _uuid.v4();
    final DateTime now = DateTime.now();
    OpeningStockEntity? openingForSync;
    final existingOpening = await _findOpeningStockEntity(
      productId: productId,
      warehouseId: warehouseId,
    );

    final duplicateOpenings = existingOpening == null
        ? <OpeningStockEntity>[]
        : (await _dbService.openingStockEntries
                  .filter()
                  .productIdEqualTo(productId)
                  .and()
                  .warehouseIdEqualTo(warehouseId)
                  .findAll())
              .where((entry) => entry.id != existingOpening.id)
              .toList();

    // 2. ISAR LOCAL TRANSACTION (Offline-First)
    await _dbService.db.writeTxn(() async {
      final product = await _dbService.products.get(fastHash(productId));
      if (product == null) {
        throw Exception('Product not found in local DB: $productId');
      }

      final openingEntity = existingOpening ?? OpeningStockEntity();
      openingEntity
        ..id = existingOpening?.id ?? entryId
        ..productId = productId
        ..productType = productType
        ..warehouseId = warehouseId
        ..quantity = quantity
        ..unit = unit
        ..openingRate = openingRate
        ..batchNumber = batchNumber
        ..entryDate = now
        ..reason = 'OPENING_STOCK'
        ..createdBy = userId
        ..createdAt = existingOpening?.createdAt ?? now
        ..updatedAt = now
        ..syncStatus = SyncStatus.pending;

      await _dbService.openingStockEntries.put(openingEntity);
      for (final duplicate in duplicateOpenings) {
        await _dbService.openingStockEntries.delete(duplicate.isarId);
      }
      openingForSync = openingEntity;
    });
    if (openingForSync != null) {
      await _enqueueOutbox(
        collection: _openingCollection,
        payload: _openingPayload(openingForSync!),
        action: 'set',
        explicitRecordKey: openingForSync!.id,
      );
    }

    final cmd = InventoryCommand.openingSetBalance(
      warehouseId: warehouseId,
      productId: productId,
      setQuantityBase: quantity,
      openingWindowId: openingForSync?.id ?? entryId,
      actorUid: userId,
      createdAt: now,
    );
    await _inventoryMovementEngine.applyCommand(cmd);

    AppLogger.success(
      existingOpening == null
          ? 'Opening stock created locally for product $productId'
          : 'Opening stock updated locally for product $productId',
      tag: 'Inventory',
    );

    // Note: Remote sync is handled by the sync coordinator later.
    // We avoid direct Firestore transaction here to maintain strict offline-first rule.
  }

  /// LOCKS the system for Go-Live. Irreversible by normal means.
  Future<void> markGoLiveCompleted() async {
    final payload = <String, dynamic>{
      'id': 'general',
      'goLiveCompleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _enqueueOutbox(
      collection: 'settings',
      payload: payload,
      action: 'set',
      explicitRecordKey: 'general',
    );

    try {
      await SyncService.instance.trySync();
    } catch (_) {
      // Keep durable outbox record for sync coordinator retry.
    }
  }

  /// Checks if the system is already locked
  Future<bool> isSystemLocked() async {
    try {
      final doc = await _remote
          .getDocument(
            collection: CollectionRegistry.settings,
            documentId: 'general',
          )
          .timeout(const Duration(seconds: 3));
      return doc.data()?['goLiveCompleted'] == true;
    } catch (e) {
      // Fail safe: assume locked if we can't fetch it
      return true;
    }
  }
}
