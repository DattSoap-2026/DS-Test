import 'package:isar/isar.dart';
import '../local/entities/bhatti_entry_entity.dart';
import '../local/base_entity.dart';
import '../local/entities/product_entity.dart';
import '../local/entities/stock_balance_entity.dart';
import '../../services/database_service.dart';
import '../../services/bhatti_service.dart';
import '../../services/tank_service.dart';
import '../../services/inventory_service.dart';
import '../../services/inventory_movement_engine.dart';
import '../../services/inventory_projection_service.dart';
import '../../core/firebase/firebase_config.dart';
import 'dart:developer' as developer;

/// Repository for Bhatti Daily Entries.
///
/// This repository acts as a bridge for production reporting, providing:
/// - Online-first write operations for high-integrity daily logs.
/// - Offline-first read operations using the local Isar cache.
/// - Automatic reconciliation between Firestore and Isar during full sync.
class BhattiRepository {
  final DatabaseService _dbService;
  final BhattiService _bhattiService;
  final InventoryProjectionService _inventoryProjectionService;
  final InventoryMovementEngine _inventoryMovementEngine;

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _normalizedToken(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _resolveBhattiKey(String bhattiId, String bhattiName) {
    final source = '$bhattiId $bhattiName'.toLowerCase();
    if (source.contains('gita')) return 'gita';
    if (source.contains('sona')) return 'sona';
    return '';
  }

  int _scoreSemiProductMatch(ProductEntity product, String key) {
    final normalizedKey = _normalizedToken(key);
    final name = product.name.toLowerCase();
    final normalizedName = _normalizedToken(name);
    final sku = product.sku.toLowerCase();
    final normalizedSku = _normalizedToken(sku);
    final category = (product.category ?? '').toLowerCase();
    final baseUnit = product.baseUnit.toLowerCase();

    var score = 0;
    if (normalizedName == normalizedKey) score += 1000;
    if (name == key) score += 900;
    if (normalizedName.startsWith(normalizedKey)) score += 500;
    if (name.startsWith('$key ') ||
        name.endsWith(' $key') ||
        name.contains(' $key ')) {
      score += 250;
    }
    if (normalizedSku == normalizedKey ||
        normalizedSku.startsWith(normalizedKey)) {
      score += 180;
    } else if (normalizedSku.contains(normalizedKey)) {
      score += 120;
    }
    if (category.contains(key)) score += 80;
    if (name.contains(key)) score += 60;
    if (baseUnit.contains('box') || baseUnit.contains('batch')) score += 10;
    return score;
  }

  Future<ProductEntity?> _findSemiProductForBhatti({
    required String bhattiId,
    required String bhattiName,
  }) async {
    final bhattiKey = _resolveBhattiKey(bhattiId, bhattiName);
    if (bhattiKey.isEmpty) return null;

    final allProducts = await _dbService.products.where().findAll();
    final semiProducts = allProducts
        .where((p) => !p.isDeleted && p.itemType == 'Semi-Finished Good')
        .toList();
    if (semiProducts.isEmpty) return null;

    semiProducts.sort((a, b) {
      final scoreDiff =
          _scoreSemiProductMatch(b, bhattiKey) -
          _scoreSemiProductMatch(a, bhattiKey);
      if (scoreDiff != 0) return scoreDiff;
      return a.name.compareTo(b.name);
    });

    final best = semiProducts.first;
    return _scoreSemiProductMatch(best, bhattiKey) > 0 ? best : null;
  }

  Future<void> _applySemiStockAdjustmentForEntry({
    required String bhattiId,
    required String bhattiName,
    required String entryId,
    required int deltaOutputBoxes,
    required String actorUid,
    required DateTime updatedAt,
  }) async {
    final semiProduct = await _findSemiProductForBhatti(
      bhattiId: bhattiId,
      bhattiName: bhattiName,
    );
    if (semiProduct == null) {
      developer.log(
        'No matching semi-finished product found for $bhattiName ($bhattiId)',
        name: 'BhattiRepo',
      );
      return;
    }

    final currentStock = semiProduct.stock ?? 0.0;
    final updatedStock = currentStock + deltaOutputBoxes;
    if (updatedStock < -1e-9) {
      throw Exception(
        'Semi stock cannot go negative for ${semiProduct.name}. '
        'Current: ${currentStock.toStringAsFixed(2)}, '
        'Requested delta: $deltaOutputBoxes',
      );
    }

    final quantity = deltaOutputBoxes.abs().toDouble();
    if (quantity < 1e-9) {
      return;
    }
    if (deltaOutputBoxes < 0) {
      await _seedWarehouseBalanceInTxn(
        productId: semiProduct.id,
        occurredAt: updatedAt,
      );
    }

    final virtualBhattiLocationId = _semiFinishedVirtualLocationId(bhattiId);
    final command = deltaOutputBoxes > 0
        ? InventoryCommand.internalTransfer(
            sourceLocationId: virtualBhattiLocationId,
            destinationLocationId:
                InventoryProjectionService.warehouseMainLocationId,
            referenceId: entryId,
            productId: semiProduct.id,
            quantityBase: quantity,
            actorUid: actorUid,
            reasonCode: 'bhatti_semi_output',
            referenceType: 'bhatti_entry',
            createdAt: updatedAt,
          )
        : InventoryCommand.internalTransfer(
            sourceLocationId:
                InventoryProjectionService.warehouseMainLocationId,
            destinationLocationId: virtualBhattiLocationId,
            referenceId: entryId,
            productId: semiProduct.id,
            quantityBase: quantity,
            actorUid: actorUid,
            reasonCode: 'bhatti_semi_adjustment',
            referenceType: 'bhatti_entry',
            createdAt: updatedAt,
          );
    await _inventoryMovementEngine.applyCommandInTxn(command);

    final updatedProduct = await _dbService.products.getById(semiProduct.id);
    final projectedStock = updatedProduct?.stock ?? updatedStock;

    // T9-P4 REMOVED: direct local products.stock mutation is replaced by the
    // InventoryMovementEngine internal_transfer command above.
    // semiProduct.stock = updatedStock;
    // semiProduct.updatedAt = updatedAt;
    // semiProduct.syncStatus = SyncStatus.pending;
    // await _dbService.products.put(semiProduct);

    developer.log(
      'Adjusted semi stock: ${semiProduct.name} '
      'delta=$deltaOutputBoxes new=${projectedStock.toStringAsFixed(2)}',
      name: 'BhattiRepo',
    );
  }

  BhattiRepository(
    this._dbService,
    FirebaseServices firebase, {
    InventoryProjectionService? inventoryProjectionService,
    InventoryMovementEngine? inventoryMovementEngine,
  }) : _inventoryProjectionService =
           inventoryProjectionService ?? InventoryProjectionService(_dbService),
       _inventoryMovementEngine =
           inventoryMovementEngine ??
           InventoryMovementEngine(
             _dbService,
             inventoryProjectionService ??
                 InventoryProjectionService(_dbService),
           ),
       _bhattiService = BhattiService(
         firebase,
         _dbService,
         TankService(firebase, _dbService),
         InventoryService(firebase, _dbService),
         inventoryMovementEngine ??
             InventoryMovementEngine(
               _dbService,
               inventoryProjectionService ??
                   InventoryProjectionService(_dbService),
             ),
       );

  String _semiFinishedVirtualLocationId(String bhattiId) {
    final token = _normalizedToken(bhattiId);
    return 'virtual:bhatti:${token.isEmpty ? 'unknown' : token}:output';
  }

  Future<void> _ensureWarehouseLocationReady() async {
    final existing = await _dbService.inventoryLocations.get(
      fastHash(InventoryProjectionService.warehouseMainLocationId),
    );
    if (existing != null) {
      return;
    }
    await _inventoryProjectionService.ensureCanonicalFoundation();
  }

  Future<void> _seedWarehouseBalanceInTxn({
    required String productId,
    required DateTime occurredAt,
  }) async {
    final balanceId = StockBalanceEntity.composeId(
      InventoryProjectionService.warehouseMainLocationId,
      productId,
    );
    final existing = await _dbService.stockBalances.get(fastHash(balanceId));
    if (existing != null) {
      return;
    }
    final product = await _dbService.products.getById(productId);
    final balance = StockBalanceEntity()
      ..id = balanceId
      ..locationId = InventoryProjectionService.warehouseMainLocationId
      ..productId = productId
      ..quantity = product?.stock ?? 0.0
      ..updatedAt = occurredAt
      ..syncStatus = product?.syncStatus ?? SyncStatus.pending
      ..isDeleted = false;
    await _dbService.stockBalances.put(balance);
  }

  // ===== WRITE OPERATIONS (Online-First) =====

  /// Save bhatti entry to Firebase, then auto-cache locally
  /// Returns the entry ID on success, null on failure
  /// Save bhatti entry to Local Isar first, then attempt background sync.
  /// Returns the entry ID on success (local persistence), null on failure.
  Future<String?> saveBhattiEntry({
    required DateTime date,
    required String bhattiId,
    required String bhattiName,
    String? teamCode,
    required int batchCount,
    required int outputBoxes,
    required double fuelConsumption,
    required String createdBy,
    required String createdByName,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final normalizedDate = _dateOnly(date);
      final entryId =
          '${bhattiId}_${normalizedDate.toIso8601String().split('T')[0]}';

      // 1. Create Entity (Pending Sync)
      final entity = BhattiDailyEntryEntity()
        ..id = entryId
        ..date = normalizedDate
        ..bhattiId = bhattiId
        ..bhattiName = bhattiName
        ..teamCode = teamCode
        ..batchCount = batchCount
        ..outputBoxes = outputBoxes
        ..fuelConsumption = fuelConsumption
        ..createdBy = createdBy
        ..createdByName = createdByName
        ..createdAt = now
        ..updatedAt = now
        ..notes = notes
        ..syncStatus = SyncStatus.pending
        ..isDeleted = false;

      // 2. Save entry + adjust semi stock in one local transaction
      await _ensureWarehouseLocationReady();
      await _dbService.db.writeTxn(() async {
        final existingEntry = await _dbService.bhattiEntries.get(
          fastHash(entryId),
        );
        final previousOutputBoxes = existingEntry?.outputBoxes ?? 0;

        await _dbService.bhattiEntries.put(entity);

        final deltaOutputBoxes = outputBoxes - previousOutputBoxes;
        if (deltaOutputBoxes != 0) {
          await _applySemiStockAdjustmentForEntry(
            bhattiId: bhattiId,
            bhattiName: bhattiName,
            entryId: entryId,
            deltaOutputBoxes: deltaOutputBoxes,
            actorUid: createdBy.trim().isEmpty ? 'system' : createdBy.trim(),
            updatedAt: normalizedDate,
          );
        }
      });
      developer.log('Bhatti entry locally saved: $entryId', name: 'BhattiRepo');

      // 3. Attempt Immediate Sync (Best Effort)
      _tryImmediateSync(entity);

      return entryId;
    } catch (e) {
      developer.log(
        'Failed to save Bhatti entry locally: $e',
        name: 'BhattiRepo',
      );
      return null;
    }
  }

  /// Helper to attempt immediate sync without blocking UI return
  Future<void> _tryImmediateSync(BhattiDailyEntryEntity entity) async {
    try {
      final firebaseData = entity.toFirebaseJson();
      await _bhattiService.saveDailyEntry(firebaseData);

      // If successful, mark as synced locally
      await _dbService.db.writeTxn(() async {
        entity.syncStatus = SyncStatus.synced;
        await _dbService.bhattiEntries.put(entity);
      });
      developer.log(
        'Bhatti entry immediately synced: ${entity.id}',
        name: 'BhattiRepo',
      );
    } catch (e) {
      developer.log('Immediate sync failed (offline?): $e', name: 'BhattiRepo');
      // Entity remains SyncStatus.pending for SyncManager to pick up later
    }
  }

  // ===== READ OPERATIONS (Cache-First, Local Only) =====

  /// Get bhatti entries by date range (local only)
  Future<List<BhattiDailyEntryEntity>> getBhattiEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? bhattiId,
  }) async {
    try {
      final db = _dbService.db;
      final startOfDay = _dateOnly(startDate);
      final endOfDay = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
        999,
      );

      var query = db.bhattiDailyEntryEntitys
          .filter()
          .dateBetween(startOfDay, endOfDay, includeUpper: true)
          .isDeletedEqualTo(false);

      if (bhattiId != null) {
        query = query.bhattiIdEqualTo(bhattiId);
      }

      final results = await query.sortByDateDesc().findAll();
      developer.log('Loaded ${results.length} bhatti entries from cache');
      return results;
    } catch (e) {
      developer.log('Failed to read bhatti entries: $e');
      return [];
    }
  }

  /// Get latest bhatti entry for a specific bhatti (local only)
  Future<BhattiDailyEntryEntity?> getLatestBhattiEntry(String bhattiId) async {
    try {
      final db = _dbService.db;

      final result = await db.bhattiDailyEntryEntitys
          .filter()
          .bhattiIdEqualTo(bhattiId)
          .isDeletedEqualTo(false)
          .sortByDateDesc()
          .findFirst();

      return result;
    } catch (e) {
      developer.log('Failed to read latest bhatti entry: $e');
      return null;
    }
  }

  /// Get bhatti entry by date (local only)
  Future<BhattiDailyEntryEntity?> getBhattiEntryByDate({
    required DateTime date,
    required String bhattiId,
  }) async {
    try {
      final db = _dbService.db;
      final normalizedDate = _dateOnly(date);
      final dayEnd = DateTime(
        normalizedDate.year,
        normalizedDate.month,
        normalizedDate.day,
        23,
        59,
        59,
        999,
      );

      final result = await db.bhattiDailyEntryEntitys
          .filter()
          .bhattiIdEqualTo(bhattiId)
          .dateBetween(normalizedDate, dayEnd, includeUpper: true)
          .isDeletedEqualTo(false)
          .findFirst();

      return result;
    } catch (e) {
      developer.log('Failed to read bhatti entry: $e');
      return null;
    }
  }

  // ===== AUTO-FETCH OPERATIONS =====

  /// Fetch bhatti entries from Firebase and cache locally
  /// Used for background sync and initial data loading
  Future<void> fetchAndCacheBhattiEntries({
    required DateTime startDate,
    required DateTime endDate,
    String? bhattiId,
  }) async {
    try {
      // Fetch from Firebase
      final firebaseEntries = await _bhattiService.getDailyEntries(
        startDate: startDate,
        endDate: endDate,
        bhattiName: bhattiId,
      );

      if (firebaseEntries.isEmpty) {
        developer.log(' No bhatti entries to cache');
        return;
      }

      // Convert to entities
      final entities = firebaseEntries
          .map((json) => BhattiDailyEntryEntity.fromFirebaseJson(json))
          .toList();

      // Cache locally
      await _dbService.db.writeTxn(() async {
        await _dbService.bhattiEntries.putAll(entities);
      });

      developer.log('Cached ${entities.length} bhatti entries');
    } catch (e) {
      developer.log('Failed to fetch bhatti entries: $e');
      // Don't throw - offline is acceptable
    }
  }
}
