import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:isar/isar.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/product_entity.dart';
import 'package:flutter_app/data/local/entities/tank_entity.dart';
import 'package:flutter_app/data/local/entities/tank_transaction_entity.dart';
import 'package:flutter_app/data/local/entities/opening_stock_entity.dart';
import 'package:flutter_app/data/local/entities/sync_metric_entity.dart';
import 'package:flutter_app/data/local/entities/stock_ledger_entity.dart';
import 'package:flutter_app/data/local/entities/bhatti_entry_entity.dart';
import 'package:flutter_app/data/local/entities/production_entry_entity.dart';
import 'package:flutter_app/data/local/entities/vehicle_entity.dart';
import 'package:flutter_app/data/local/entities/route_entity.dart';
import 'package:flutter_app/data/local/entities/diesel_log_entity.dart';
import 'package:flutter_app/data/local/entities/trip_entity.dart';
import 'package:flutter_app/data/local/entities/route_order_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/models/types/route_order_types.dart';
import 'package:flutter_app/models/inventory/opening_stock_entry.dart';
import 'package:flutter_app/models/inventory/stock_ledger_entry.dart';
import 'package:flutter_app/core/constants/collection_registry.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/suppliers_service.dart';
import 'package:flutter_app/services/sync_common_utils.dart';
import 'package:flutter_app/services/tank_service.dart';
import 'package:flutter_app/utils/app_logger.dart';

class InventorySyncDelegate {
  final DatabaseService _dbService;
  final SyncCommonUtils _utils;
  final SuppliersService _suppliersService;
  final void Function(String step, Object error) _markSyncIssue;
  final String Function(dynamic value) _normalizeProductItemTypeLabel;

  static const String productsCollection = CollectionRegistry.products;
  static const String openingStockCollection =
      CollectionRegistry.openingStockEntries;
  static const String openingStockLegacySyncKey =
      CollectionRegistry.legacyOpeningStock;
  static const String tanksCollection = CollectionRegistry.tanks;
  static const String tankTransactionsCollection =
      CollectionRegistry.tankTransactions;
  static const String stockLedgerCollection = CollectionRegistry.stockLedger;
  static const String bhattiEntriesCollection =
      CollectionRegistry.bhattiEntries;
  static const String productionEntriesCollection =
      CollectionRegistry.productionEntries;
  static const String vehiclesCollection = CollectionRegistry.vehicles;
  static const String routesCollection = CollectionRegistry.routes;
  static const String dieselLogsCollection = CollectionRegistry.dieselLogs;
  static const String suppliersCollection = CollectionRegistry.suppliers;
  static const String tripsCollection = CollectionRegistry.deliveryTrips;
  static const String tripsLegacySyncKey = CollectionRegistry.legacyTrips;
  static const String routeOrdersCollection = CollectionRegistry.routeOrders;
  static const bool _allowDiagnosticProducts = bool.fromEnvironment(
    'DATT_ALLOW_DIAGNOSTIC_PRODUCTS',
    defaultValue: false,
  );

  InventorySyncDelegate({
    required DatabaseService dbService,
    required SyncCommonUtils utils,
    required SuppliersService suppliersService,
    required void Function(String step, Object error) markSyncIssue,
    required String Function(dynamic value) normalizeProductItemTypeLabel,
  }) : _dbService = dbService,
       _utils = utils,
       _suppliersService = suppliersService,
       _markSyncIssue = markSyncIssue,
       _normalizeProductItemTypeLabel = normalizeProductItemTypeLabel;

  Future<DateTime?> _getLastSyncTimestampWithLegacy({
    required String collection,
    String? legacyCollection,
  }) async {
    final direct = await _utils.getLastSyncTimestamp(collection);
    if (direct != null) return direct;
    if (legacyCollection == null || legacyCollection == collection) {
      return null;
    }
    final legacy = await _utils.getLastSyncTimestamp(legacyCollection);
    if (legacy != null) {
      await _utils.setLastSyncTimestamp(collection, legacy);
    }
    return legacy;
  }

  bool _isDiagnosticLiveTestProductDoc(
    String docId,
    Map<String, dynamic> data,
  ) {
    final id = docId.trim().toUpperCase();
    final name = (data['name']?.toString() ?? '').trim().toUpperCase();
    final sku = (data['sku']?.toString() ?? '').trim().toUpperCase();
    final category = (data['category']?.toString() ?? '').trim().toLowerCase();
    return category == 'live-test' ||
        id.startsWith('LIVE_') ||
        name.startsWith('LIVE_') ||
        sku.startsWith('LVS_');
  }

  String _typeNameFromItemType(dynamic rawItemType) {
    final normalizedItemType = _normalizeProductItemTypeLabel(rawItemType);
    switch (normalizedItemType) {
      case 'Raw Material':
      case 'Oils & Liquids':
      case 'Chemicals & Additives':
        return 'raw';
      case 'Semi-Finished Good':
        return 'semi';
      case 'Finished Good':
        return 'finished';
      case 'Traded Good':
        return 'traded';
      case 'Packaging Material':
        return 'packaging';
      default:
        return 'raw';
    }
  }

  String _normalizeProductTypeName(dynamic rawType, dynamic rawItemType) {
    final value = rawType?.toString().trim().toLowerCase() ?? '';
    if (value.isNotEmpty) {
      if (value == 'raw' || value.contains('raw')) return 'raw';
      if (value == 'semi' || value.contains('semi')) return 'semi';
      if (value == 'finished' || value.contains('finish')) return 'finished';
      if (value == 'traded' || value.contains('trade')) return 'traded';
      if (value == 'packaging' || value.contains('packag')) return 'packaging';
    }
    return _typeNameFromItemType(rawItemType);
  }

  String _normalizeProductItemTypeForProduct(
    dynamic rawItemType,
    dynamic rawType,
  ) {
    final explicitItemType = rawItemType?.toString().trim() ?? '';
    if (explicitItemType.isNotEmpty) {
      return _normalizeProductItemTypeLabel(explicitItemType);
    }

    final typeName = _normalizeProductTypeName(rawType, rawItemType);
    switch (typeName) {
      case 'raw':
        return 'Raw Material';
      case 'semi':
        return 'Semi-Finished Good';
      case 'finished':
        return 'Finished Good';
      case 'traded':
        return 'Traded Good';
      case 'packaging':
        return 'Packaging Material';
      default:
        return '';
    }
  }

  Future<void> syncInventory(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      if (user.role == UserRole.admin ||
          user.role == UserRole.productionManager) {
        final pending = await _dbService.products
            .filter()
            .syncStatusEqualTo(SyncStatus.pending)
            .findAll();

        if (pending.isNotEmpty) {
          final chunks = _utils.chunkList(pending, 450);
          for (final chunk in chunks) {
            final batch = db.batch();
            for (final product in chunk) {
              final data = product.toDomain().toJson();
              data['updatedAt'] = product.updatedAt.toIso8601String();
              final docRef = db.collection(productsCollection).doc(product.id);
              batch.set(docRef, data, firestore.SetOptions(merge: true));
            }
            await batch.commit();

            await _dbService.db.writeTxn(() async {
              final updatedProducts = <ProductEntity>[];
              for (final product in chunk) {
                product.syncStatus = SyncStatus.synced;
                updatedProducts.add(product);
              }
              if (updatedProducts.isNotEmpty) {
                await _dbService.products.putAll(updatedProducts);
              }
            });
            pushedCount += chunk.length;
          }
        }
      } else {
        final unauthorizedPending = await _dbService.products
            .filter()
            .syncStatusEqualTo(SyncStatus.pending)
            .findAll();

        if (unauthorizedPending.isNotEmpty) {
          AppLogger.warning(
            'Unauthorized pending product changes found (${unauthorizedPending.length}). Moving to conflict state.',
            tag: 'Sync',
          );
          
          final productIds = unauthorizedPending.map((p) => p.id).toList();
          final serverProducts = await Future.wait(
            productIds.map((id) => db.collection(productsCollection).doc(id).get()),
          );
          
          await _dbService.db.writeTxn(() async {
            final conflictProducts = <ProductEntity>[];
            for (var i = 0; i < unauthorizedPending.length; i++) {
              final product = unauthorizedPending[i];
              final serverDoc = serverProducts[i];
              
              if (serverDoc.exists && serverDoc.data() != null) {
                final serverData = serverDoc.data()!;
                await _utils.detectAndFlagConflict<ProductEntity>(
                  entityId: product.id,
                  entityType: 'products',
                  serverData: serverData,
                  localEntity: product,
                  localToJson: (ProductEntity e) => e.toDomain().toJson(),
                );
                
                product.syncStatus = SyncStatus.conflict;
                conflictProducts.add(product);
              } else {
                product.syncStatus = SyncStatus.conflict;
                conflictProducts.add(product);
              }
            }
            if (conflictProducts.isNotEmpty) {
              await _dbService.products.putAll(conflictProducts);
            }
          });
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing inventory', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: 'products',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final rawLastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('products');
      DateTime? lastSync = rawLastSync;
      final now = DateTime.now();

      if (lastSync != null &&
          lastSync.isAfter(now.add(const Duration(minutes: 5)))) {
        AppLogger.warning(
          'Products lastSync cursor is in the future ($lastSync). Falling back to full pull.',
          tag: 'Sync',
        );
        lastSync = null;
      }

      var useFullPull = forceRefresh || lastSync == null;
      firestore.Query query = db.collection(productsCollection);
      if (!useFullPull) {
        final lastSyncIso = lastSync.toIso8601String();
        query = query.where('updatedAt', isGreaterThan: lastSyncIso);
      }

      firestore.QuerySnapshot snapshot;
      try {
        snapshot = await query.get();
      } catch (e) {
        if (!useFullPull) {
          AppLogger.warning(
            'Delta pull failed for products; retrying full pull. Error: $e',
            tag: 'Sync',
          );
          useFullPull = true;
          snapshot = await db.collection(productsCollection).get();
        } else {
          rethrow;
        }
      }

      final shouldFallbackToFullPull =
          !useFullPull &&
          snapshot.docs.isEmpty &&
          now.difference(lastSync ?? now).inHours >= 6;
      if (shouldFallbackToFullPull) {
        useFullPull = true;
        snapshot = await db.collection(productsCollection).get();
      }

      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt =
            lastSync ?? DateTime.fromMillisecondsSinceEpoch(0);

        final productIds = snapshot.docs.map((doc) => doc.id).toList();
        final existingProducts = await _dbService.products.getAllById(
          productIds,
        );
        final existingProductsMap = {
          for (int i = 0; i < snapshot.docs.length; i++)
            if (existingProducts[i] != null)
              snapshot.docs[i].id: existingProducts[i]!,
        };

        final productsToPut = <ProductEntity>[];

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (!_allowDiagnosticProducts &&
              _isDiagnosticLiveTestProductDoc(doc.id, data)) {
            continue;
          }
          final updatedAt = _utils.parseRemoteDate(
            data['updatedAt'] ?? data['lastUpdatedAt'] ?? data['createdAt'],
            fallback: DateTime.fromMillisecondsSinceEpoch(0),
          );
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          final existing = existingProductsMap[doc.id];
          if (existing != null && existing.syncStatus == SyncStatus.pending) {
            await _utils.detectAndFlagConflict<ProductEntity>(
              entityId: doc.id,
              entityType: 'products',
              serverData: data,
              localEntity: existing,
              localToJson: (ProductEntity e) => e.toDomain().toJson(),
            );
            continue;
          }
          if (existing != null && existing.syncStatus == SyncStatus.conflict) {
            continue;
          }

          final allowedSemiRaw = data['allowedSemiFinishedIds'];
          final allowedSemi = allowedSemiRaw is List
              ? allowedSemiRaw.map((e) => e.toString()).toList()
              : <String>[];
          final allowedDepartmentsRaw = data['allowedDepartmentIds'];
          final allowedDepartments = allowedDepartmentsRaw is List
              ? allowedDepartmentsRaw.map((e) => e.toString()).toList()
              : <String>[];
          final storageRequirementsRaw = data['storageRequirements'];
          final storageRequirements = storageRequirementsRaw is List
              ? storageRequirementsRaw.map((e) => e.toString()).toList()
              : <String>[];
          final ppeRequiredRaw = data['ppeRequired'];
          final ppeRequired = ppeRequiredRaw is List
              ? ppeRequiredRaw.map((e) => e.toString()).toList()
              : <String>[];
          final remoteLocalImageRaw =
              (data['localImagePath'] ?? data['local_image_path'])?.toString();
          final remoteLocalImagePath =
              remoteLocalImageRaw == null || remoteLocalImageRaw.trim().isEmpty
              ? null
              : remoteLocalImageRaw.trim();
          final isDeleted = data['isDeleted'] as bool? ?? false;
          final deletedAt = isDeleted
              ? _utils.parseRemoteDate(data['deletedAt'], fallback: updatedAt)
              : null;

          final product = ProductEntity()
            ..id = doc.id
            ..name = data['name']?.toString() ?? ''
            ..sku = data['sku']?.toString() ?? doc.id
            ..itemType = _normalizeProductItemTypeForProduct(
              data['itemType'],
              data['type'],
            )
            ..type = _normalizeProductTypeName(data['type'], data['itemType'])
            ..departmentId = data['departmentId']?.toString()
            ..baseSemiId = data['baseSemiId']?.toString()
            ..category = data['category']?.toString() ?? ''
            ..subcategory = data['subcategory']?.toString()
            ..baseUnit = data['baseUnit']?.toString() ?? 'Pcs'
            ..secondaryUnit = data['secondaryUnit']?.toString()
            ..conversionFactor =
                (data['conversionFactor'] as num?)?.toDouble() ?? 1.0
            ..stock = (data['stock'] as num?)?.toDouble() ?? 0.0
            ..price = (data['price'] as num?)?.toDouble() ?? 0.0
            ..secondaryPrice = (data['secondaryPrice'] as num?)?.toDouble()
            ..mrp = (data['mrp'] as num?)?.toDouble()
            ..purchasePrice = (data['purchasePrice'] as num?)?.toDouble()
            ..averageCost = (data['averageCost'] as num?)?.toDouble()
            ..lastCost = (data['lastCost'] as num?)?.toDouble()
            ..gstRate = (data['gstRate'] as num?)?.toDouble()
            ..defaultDiscount = (data['defaultDiscount'] as num?)?.toDouble()
            ..status = data['status']?.toString() ?? 'active'
            ..supplierId = data['supplierId']?.toString()
            ..supplierName = data['supplierName']?.toString()
            ..reorderLevel = (data['reorderLevel'] as num?)?.toDouble()
            ..stockAlertLevel = (data['stockAlertLevel'] as num?)?.toDouble()
            ..minimumSafetyStock = (data['minimumSafetyStock'] as num?)
                ?.toDouble()
            ..unitWeightGrams =
                (data['unitWeightGrams'] as num?)?.toDouble() ?? 0.0
            ..weightPerUnit = (data['weightPerUnit'] as num?)?.toDouble()
            ..volumePerUnit = (data['volumePerUnit'] as num?)?.toDouble()
            ..density = (data['density'] as num?)?.toDouble()
            ..packagingType = data['packagingType']?.toString()
            ..shelfLife = (data['shelfLife'] as num?)?.toDouble()
            ..barcode = data['barcode']?.toString()
            ..productionStage = data['productionStage']?.toString()
            ..wastagePercent = (data['wastagePercent'] as num?)?.toDouble()
            ..boxesPerBatch = (data['boxesPerBatch'] as num?)?.toInt()
            ..internalCost = (data['internalCost'] as num?)?.toDouble()
            ..expiryDays = (data['expiryDays'] as num?)?.toDouble()
            ..batchMandatory = data['batchMandatory'] as bool? ?? false
            ..storageConditions = data['storageConditions']?.toString()
            ..isTankMaterial = data['isTankMaterial'] as bool? ?? false
            ..sizeVariant = data['sizeVariant']?.toString()
            ..hazardLevel = data['hazardLevel']?.toString()
            ..safetyPrecautions = data['safetyPrecautions']?.toString()
            ..storageRequirements = storageRequirements
            ..ppeRequired = ppeRequired
            ..allowedSemiFinishedIds = allowedSemi
            ..allowedDepartmentIds = allowedDepartments
            // Preserve device-local image path when server payload does not carry it.
            ..localImagePath = remoteLocalImagePath ?? existing?.localImagePath
            ..isDeleted = isDeleted
            ..deletedAt = deletedAt
            ..syncStatus = SyncStatus.synced
            ..updatedAt = updatedAt;

          productsToPut.add(product);
        }

        if (productsToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.products.putAll(productsToPut);
          });
        }
        await _utils.setLastSyncTimestamp('products', maxUpdatedAt);
        pulledCount = productsToPut.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Inventory sync pull failed', error: e, tag: 'Sync');
      _markSyncIssue('inventory pull', e);
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: 'products',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncOpeningStock(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      final pending = await _dbService.openingStocks
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pending.isNotEmpty) {
        final chunks = _utils.chunkList(pending, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final stock in chunk) {
            final data = stock.toDomain().toJson();
            data['updatedAt'] = stock.updatedAt.toIso8601String();
            final docRef = db.collection(openingStockCollection).doc(stock.id);
            batch.set(docRef, data, firestore.SetOptions(merge: true));
          }
          await batch.commit();

          await _dbService.db.writeTxn(() async {
            final updatedOpeningStocks = <OpeningStockEntity>[];
            for (final stock in chunk) {
              stock.syncStatus = SyncStatus.synced;
              updatedOpeningStocks.add(stock);
            }
            if (updatedOpeningStocks.isNotEmpty) {
              await _dbService.openingStocks.putAll(updatedOpeningStocks);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing opening stock', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: openingStockCollection,
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _getLastSyncTimestampWithLegacy(
              collection: openingStockCollection,
              legacyCollection: openingStockLegacySyncKey,
            );
      firestore.Query query = db.collection(openingStockCollection);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final dedupedStocks = <String, OpeningStockEntity>{};

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          final entity = OpeningStockEntity.fromDomain(
            OpeningStockEntry.fromJson(data),
          );
          entity.updatedAt = updatedAt;
          entity.syncStatus = SyncStatus.synced;
          final key = '${entity.productId}::${entity.warehouseId}';
          final existing = dedupedStocks[key];
          if (existing == null ||
              entity.updatedAt.isAfter(existing.updatedAt)) {
            dedupedStocks[key] = entity;
          }
        }

        final stocksToPut = dedupedStocks.values.toList();
        if (stocksToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.openingStocks.putAll(stocksToPut);
          });
        }
        await _utils.setLastSyncTimestamp(openingStockCollection, maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling opening stock', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: openingStockCollection,
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncTanks(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      final pendingTanks = await TankEntityQueryFilter(
        _dbService.tanks.filter(),
      ).syncStatusEqualTo(SyncStatus.pending).findAll();

      if (pendingTanks.isNotEmpty) {
        final chunks = _utils.chunkList(pendingTanks, 450);

        for (final chunk in chunks) {
          final batch = db.batch();

          for (final tankEntity in chunk) {
            final tank = tankEntity.toDomain();
            final data = tank.toJson();
            data['updatedAt'] = tankEntity.updatedAt.toIso8601String();

            final docRef = db.collection(tanksCollection).doc(tank.id);
            batch.set(docRef, data, firestore.SetOptions(merge: true));
          }

          await batch.commit();

          await _dbService.db.writeTxn(() async {
            final updatedTanks = <TankEntity>[];
            for (final tankEntity in chunk) {
              tankEntity.syncStatus = SyncStatus.synced;
              updatedTanks.add(tankEntity);
            }
            if (updatedTanks.isNotEmpty) {
              await _dbService.tanks.putAll(updatedTanks);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error syncing tanks', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: 'tanks',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;
    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('tanks');
      firestore.Query query = db.collection(tanksCollection);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final tanksToPut = <TankEntity>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          final tank = TankEntity.fromDomain(Tank.fromJson(data));
          tank.updatedAt = updatedAt;
          tank.syncStatus = SyncStatus.synced;
          tanksToPut.add(tank);
        }

        if (tanksToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.tanks.putAll(tanksToPut);
          });
        }
        await _utils.setLastSyncTimestamp('tanks', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling tanks', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: 'tanks',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncTankTransactions(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      final pending = await _dbService.tankTransactions
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pending.isNotEmpty) {
        final chunks = _utils.chunkList(pending, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final tx in chunk) {
            final data = tx.toFirebaseJson();
            data['updatedAt'] = tx.updatedAt.toIso8601String();
            final docRef = db.collection(tankTransactionsCollection).doc(tx.id);
            batch.set(docRef, data, firestore.SetOptions(merge: true));
          }
          await batch.commit();

          await _dbService.db.writeTxn(() async {
            final updatedTransactions = <TankTransactionEntity>[];
            for (final tx in chunk) {
              tx.syncStatus = SyncStatus.synced;
              updatedTransactions.add(tx);
            }
            if (updatedTransactions.isNotEmpty) {
              await _dbService.tankTransactions.putAll(updatedTransactions);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing tank transactions', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: 'tank_transactions',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('tank_transactions');
      firestore.Query query = db.collection(tankTransactionsCollection);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final txsToPut = <TankTransactionEntity>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          final tx = TankTransactionEntity()
            ..id = doc.id
            ..tankId = data['tankId'] ?? ''
            ..tankName = data['tankName'] ?? ''
            ..type = data['type'] ?? 'REFULL'
            ..quantity =
                (data['quantity'] as num?)?.toDouble() ??
                (data['amount'] as num?)?.toDouble() ??
                0.0
            ..previousStock =
                (data['previousStock'] as num?)?.toDouble() ??
                (data['previousLevel'] as num?)?.toDouble() ??
                0.0
            ..newStock =
                (data['newStock'] as num?)?.toDouble() ??
                (data['newLevel'] as num?)?.toDouble() ??
                0.0
            ..operatorId = data['operatorId'] ?? data['performedBy'] ?? ''
            ..operatorName =
                data['operatorName'] ?? data['performedByName'] ?? ''
            ..materialId = data['materialId'] ?? ''
            ..materialName = data['materialName'] ?? ''
            ..referenceId = data['referenceId'] ?? ''
            ..referenceType = data['referenceType'] ?? 'MANUAL'
            ..timestamp =
                DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now()
            ..updatedAt = updatedAt
            ..syncStatus = SyncStatus.synced;

          txsToPut.add(tx);
        }

        if (txsToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.tankTransactions.putAll(txsToPut);
          });
        }
        await _utils.setLastSyncTimestamp('tank_transactions', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling tank transactions', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: 'tank_transactions',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncStockLedger(
    firestore.FirebaseFirestore db,
    AppUser currentUser, {
    String? firebaseUid,
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      final pending = await _dbService.stockLedger
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pending.isNotEmpty) {
        final chunks = _utils.chunkList(pending, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final entry in chunk) {
            batch.set(
              db.collection(stockLedgerCollection).doc(entry.id),
              entry.toDomain().toJson(),
              firestore.SetOptions(merge: true),
            );
          }
          await batch.commit();

          await _dbService.db.writeTxn(() async {
            final updatedLedgerEntries = <StockLedgerEntity>[];
            for (final entry in chunk) {
              entry.syncStatus = SyncStatus.synced;
              updatedLedgerEntries.add(entry);
            }
            if (updatedLedgerEntries.isNotEmpty) {
              await _dbService.stockLedger.putAll(updatedLedgerEntries);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing stock ledger', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _utils.recordMetric(
        userId: currentUser.id,
        entityType: stockLedgerCollection,
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp(stockLedgerCollection);
      firestore.Query query = db.collection(stockLedgerCollection);

      if (!currentUser.isAdmin) {
        final scopedFirebaseUid = firebaseUid?.trim();
        if (scopedFirebaseUid == null || scopedFirebaseUid.isEmpty) {
          throw StateError(
            'Firebase UID must be provided for stock ledger sync.',
          );
        }
        query = query.where('performedBy', isEqualTo: scopedFirebaseUid);
      }

      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final entriesToPut = <StockLedgerEntity>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;

          final updateStr = data['updatedAt'] ?? data['transactionDate'];
          final updatedAt =
              DateTime.tryParse(updateStr.toString()) ?? DateTime.now();
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          try {
            final domainModel = StockLedgerEntry.fromJson(data);
            final entity = StockLedgerEntity.fromDomain(domainModel);
            entity.syncStatus = SyncStatus.synced;
            entriesToPut.add(entity);
          } catch (e) {
            AppLogger.error(
              'Error parsing stock ledger entry ${doc.id}',
              error: e,
              tag: 'Sync',
            );
          }
        }

        if (entriesToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.stockLedger.putAll(entriesToPut);
          });
        }
        await _utils.setLastSyncTimestamp(stockLedgerCollection, maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Stock ledger sync pull failed', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _utils.recordMetric(
        userId: currentUser.id,
        entityType: stockLedgerCollection,
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncBhattiEntries(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      final pending = await _dbService.bhattiEntries
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pending.isNotEmpty) {
        final chunks = _utils.chunkList(pending, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final entry in chunk) {
            final data = entry.toFirebaseJson();
            final docRef = db.collection(bhattiEntriesCollection).doc(entry.id);
            batch.set(docRef, data, firestore.SetOptions(merge: true));
          }
          await batch.commit();

          await _dbService.db.writeTxn(() async {
            final updatedBhattiEntries = <BhattiDailyEntryEntity>[];
            for (final entry in chunk) {
              entry.syncStatus = SyncStatus.synced;
              updatedBhattiEntries.add(entry);
            }
            if (updatedBhattiEntries.isNotEmpty) {
              await _dbService.bhattiEntries.putAll(updatedBhattiEntries);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing bhatti entries', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: 'bhatti_entries',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('bhatti_entries');
      firestore.Query query = db.collection(bhattiEntriesCollection);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final entriesToPut = <BhattiDailyEntryEntity>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          final entry = BhattiDailyEntryEntity.fromFirebaseJson(data);
          entry.updatedAt = updatedAt;
          entry.syncStatus = SyncStatus.synced;

          entriesToPut.add(entry);
        }

        if (entriesToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.bhattiEntries.putAll(entriesToPut);
          });
        }
        await _utils.setLastSyncTimestamp('bhatti_entries', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling bhatti entries', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: 'bhatti_entries',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncProductionEntries(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      final pending = await _dbService.productionEntries
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pending.isNotEmpty) {
        final chunks = _utils.chunkList(pending, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final entry in chunk) {
            final data = entry.toFirebaseJson();
            final docRef = db
                .collection(productionEntriesCollection)
                .doc(entry.id);
            batch.set(docRef, data, firestore.SetOptions(merge: true));
          }
          await batch.commit();

          await _dbService.db.writeTxn(() async {
            final updatedProductionEntries = <ProductionDailyEntryEntity>[];
            for (final entry in chunk) {
              entry.syncStatus = SyncStatus.synced;
              updatedProductionEntries.add(entry);
            }
            if (updatedProductionEntries.isNotEmpty) {
              await _dbService.productionEntries.putAll(
                updatedProductionEntries,
              );
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error(
        'Error pushing production entries',
        error: e,
        tag: 'Sync',
      );
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: productionEntriesCollection,
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp(productionEntriesCollection);
      firestore.Query query = db.collection(productionEntriesCollection);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final entriesToPut = <ProductionDailyEntryEntity>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          final entry = ProductionDailyEntryEntity.fromFirebaseJson(data);
          entry.updatedAt = updatedAt;
          entry.syncStatus = SyncStatus.synced;

          entriesToPut.add(entry);
        }

        if (entriesToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.productionEntries.putAll(entriesToPut);
          });
        }
        await _utils.setLastSyncTimestamp(
          productionEntriesCollection,
          maxUpdatedAt,
        );
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error(
        'Error pulling production entries',
        error: e,
        tag: 'Sync',
      );
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: productionEntriesCollection,
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncVehicles(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
  }) async {
    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('vehicles');
      firestore.Query query = db.collection(vehiclesCollection);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final vehiclesToPut = <VehicleEntity>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          final vehicle = VehicleEntity.fromFirebaseJson(data);
          vehicle.id = doc.id;
          vehicle.updatedAt = updatedAt;
          vehicle.syncStatus = SyncStatus.synced;

          vehiclesToPut.add(vehicle);
        }

        if (vehiclesToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.vehicles.putAll(vehiclesToPut);
          });
        }
        await _utils.setLastSyncTimestamp('vehicles', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling vehicles', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: 'vehicles',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncRoutes(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
  }) async {
    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('routes');
      firestore.Query query = db.collection(routesCollection);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final routesToPut = <RouteEntity>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          final route = RouteEntity()
            ..id = doc.id
            ..name = data['name'] ?? ''
            ..description = data['description']
            ..isActive = data['isActive'] ?? true
            ..createdAt = data['createdAt'] ?? DateTime.now().toIso8601String()
            ..updatedAt = updatedAt
            ..syncStatus = SyncStatus.synced;

          routesToPut.add(route);
        }

        if (routesToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.routes.putAll(routesToPut);
          });
        }
        await _utils.setLastSyncTimestamp('routes', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling routes', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: 'routes',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncDieselLogs(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      final pending = await _dbService.dieselLogs
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pending.isNotEmpty) {
        final chunks = _utils.chunkList(pending, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final log in chunk) {
            final data = log.toFirebaseJson();
            final docRef = db.collection(dieselLogsCollection).doc(log.id);
            batch.set(docRef, data, firestore.SetOptions(merge: true));
          }
          await batch.commit();

          await _dbService.db.writeTxn(() async {
            final updatedDieselLogs = <DieselLogEntity>[];
            for (final log in chunk) {
              log.syncStatus = SyncStatus.synced;
              updatedDieselLogs.add(log);
            }
            if (updatedDieselLogs.isNotEmpty) {
              await _dbService.dieselLogs.putAll(updatedDieselLogs);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing diesel logs', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: 'diesel_logs',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('diesel_logs');
      firestore.Query query = db.collection(dieselLogsCollection);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final logsToPut = <DieselLogEntity>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          final log = DieselLogEntity.fromFirebaseJson(data);
          log.updatedAt = updatedAt;
          log.syncStatus = SyncStatus.synced;

          logsToPut.add(log);
        }

        if (logsToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.dieselLogs.putAll(logsToPut);
          });
        }
        await _utils.setLastSyncTimestamp('diesel_logs', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling diesel logs', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: 'diesel_logs',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncSuppliers(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
  }) async {
    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('suppliers');
      firestore.Query query = db.collection(suppliersCollection);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          data['id'] = doc.id;
          await _suppliersService.upsertToLocal(data);
        }
        await _utils.setLastSyncTimestamp('suppliers', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling suppliers', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: 'suppliers',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncDispatches(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      final pending = await _dbService.trips
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pending.isNotEmpty) {
        final chunks = _utils.chunkList(pending, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final trip in chunk) {
            final data = trip.toDomain().toJson();
            data['updatedAt'] = trip.updatedAt.toIso8601String();
            final docRef = db.collection(tripsCollection).doc(trip.id);
            batch.set(docRef, data, firestore.SetOptions(merge: true));
          }
          await batch.commit();

          await _dbService.db.writeTxn(() async {
            final updatedTrips = <TripEntity>[];
            for (final trip in chunk) {
              trip.syncStatus = SyncStatus.synced;
              updatedTrips.add(trip);
            }
            if (updatedTrips.isNotEmpty) {
              await _dbService.trips.putAll(updatedTrips);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing dispatches', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: tripsCollection,
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _getLastSyncTimestampWithLegacy(
              collection: tripsCollection,
              legacyCollection: tripsLegacySyncKey,
            );
      firestore.Query query = db.collection(tripsCollection);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final tripsToPut = <TripEntity>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          final trip = TripEntity()
            ..id = data['id'] ?? doc.id
            ..tripId = data['tripId'] ?? ''
            ..vehicleNumber = data['vehicleNumber'] ?? ''
            ..driverName = data['driverName'] ?? ''
            ..driverPhone = data['driverPhone']
            ..salesIds = (data['salesIds'] as List?)
                ?.map((e) => e.toString())
                .toList()
            ..status = data['status'] ?? 'pending'
            ..createdAt = data['createdAt'] ?? DateTime.now().toIso8601String()
            ..startedAt = data['startedAt']
            ..completedAt = data['completedAt']
            ..notes = data['notes']
            ..updatedAt = updatedAt
            ..syncStatus = SyncStatus.synced;

          tripsToPut.add(trip);
        }

        if (tripsToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.trips.putAll(tripsToPut);
          });
        }
        await _utils.setLastSyncTimestamp(tripsCollection, maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling dispatches', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: tripsCollection,
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncRouteOrders(
    firestore.FirebaseFirestore db,
    AppUser user, {
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      final pending = await _dbService.routeOrders
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pending.isNotEmpty) {
        final chunks = _utils.chunkList(pending, 450);
        for (final chunk in chunks) {
          final batch = db.batch();
          for (final order in chunk) {
            final data = order.toDomain().toJson();
            data['updatedAt'] = order.updatedAt.toIso8601String();
            final docRef = db.collection(routeOrdersCollection).doc(order.id);
            batch.set(docRef, data, firestore.SetOptions(merge: true));
          }
          await batch.commit();

          await _dbService.db.writeTxn(() async {
            final updatedRouteOrders = <RouteOrderEntity>[];
            for (final order in chunk) {
              order.syncStatus = SyncStatus.synced;
              updatedRouteOrders.add(order);
            }
            if (updatedRouteOrders.isNotEmpty) {
              await _dbService.routeOrders.putAll(updatedRouteOrders);
            }
          });
          pushedCount += chunk.length;
        }
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing route orders', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: 'route_orders',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final lastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('route_orders');
      firestore.Query query = db.collection(routeOrdersCollection);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final ordersToPut = <RouteOrderEntity>[];
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final updatedAt = _utils.parseRemoteDate(data['updatedAt']);
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          final order = RouteOrder.fromJson({
            ...data,
            'id': data['id'] ?? doc.id,
          });
          final entity = RouteOrderEntity.fromDomain(order);
          entity.updatedAt = updatedAt;
          entity.syncStatus = SyncStatus.synced;

          ordersToPut.add(entity);
        }

        if (ordersToPut.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.routeOrders.putAll(ordersToPut);
          });
        }
        await _utils.setLastSyncTimestamp('route_orders', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling route orders', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _utils.recordMetric(
        userId: user.id,
        entityType: 'route_orders',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }
}
