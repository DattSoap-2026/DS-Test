import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:isar/isar.dart';

import '../../data/local/entities/category_entity.dart';
import '../../data/local/entities/product_type_entity.dart';
import '../../data/local/entities/unit_entity.dart';
import 'package:flutter_app/core/constants/collection_registry.dart';
import '../database_service.dart';
import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/sync_metric_entity.dart';
import 'package:flutter_app/services/outbox_codec.dart';

/// Delegate responsible for synchronizing master data (Units, Categories, Product Types).
class MasterDataSyncDelegate {
  final DatabaseService _dbService;
  final Future<void> Function({
    required String collection,
    required Map<String, dynamic> payload,
    String? explicitRecordKey,
  })
  deleteQueueItem;
  final Future<void> Function({
    required String entityId,
    required String entityType,
    required Map<String, dynamic> serverData,
    required BaseEntity? localEntity,
    required Map<String, dynamic> Function(BaseEntity) localToJson,
  })
  detectAndFlagConflict;
  final Future<void> Function(String collection, DateTime timestamp)
  setLastSyncTimestamp;
  final Future<DateTime?> Function(String collection) getLastSyncTimestamp;
  final Future<void> Function({
    required String entityType,
    required SyncOperation operation,
    required int recordCount,
    required int durationMs,
    required bool success,
    String? errorMessage,
  })
  recordMetric;
  final void Function(String step, Object error) markSyncIssue;
  final DateTime Function(dynamic value, {DateTime? fallback}) parseRemoteDate;
  final String Function(dynamic value) normalizeProductItemTypeLabel;
  final List<List<T>> Function<T>(List<T> list, int chunkSize) chunkList;

  MasterDataSyncDelegate(
    this._dbService, {
    required this.deleteQueueItem,
    required this.detectAndFlagConflict,
    required this.setLastSyncTimestamp,
    required this.getLastSyncTimestamp,
    required this.recordMetric,
    required this.markSyncIssue,
    required this.parseRemoteDate,
    required this.normalizeProductItemTypeLabel,
    required this.chunkList,
  });

  Map<String, dynamic> _unitToJson(UnitEntity unit) {
    return <String, dynamic>{
      'id': unit.id,
      'name': unit.name,
      'createdAt': unit.createdAt,
      'isDeleted': unit.isDeleted,
      'updatedAt': unit.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _categoryToJson(CategoryEntity category) {
    return <String, dynamic>{
      'id': category.id,
      'name': category.name,
      'itemType': normalizeProductItemTypeLabel(category.itemType),
      'createdAt': category.createdAt,
      'isDeleted': category.isDeleted,
      'updatedAt': category.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _productTypeToJson(ProductTypeEntity type) {
    return <String, dynamic>{
      'id': type.id,
      'name': normalizeProductItemTypeLabel(type.name),
      'description': type.description,
      'iconName': type.iconName,
      'color': type.color,
      'tabs': type.tabs,
      'defaultUom': type.defaultUom,
      'defaultGst': type.defaultGst,
      'skuPrefix': type.skuPrefix,
      'displayUnit': type.displayUnit,
      'createdAt': type.createdAt,
      'isDeleted': type.isDeleted,
      'updatedAt': type.updatedAt.toIso8601String(),
    };
  }

  Future<void> syncMasterData(
    firestore.FirebaseFirestore db, {
    bool forceRefresh = false,
  }) async {
    await syncUnitsCollection(db, forceRefresh: forceRefresh);
    await syncProductCategoriesCollection(db, forceRefresh: forceRefresh);
    await syncProductTypesCollection(db, forceRefresh: forceRefresh);
  }

  Future<void> syncUnitsCollection(
    firestore.FirebaseFirestore db, {
    bool forceRefresh = false,
  }) async {
    final pushStopwatch = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;
    try {
      final pending = await _dbService.units
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();
      final queueIds = pending
          .map(
            (unit) => OutboxCodec.buildQueueId(
              'units',
              {'id': unit.id},
              explicitRecordKey: unit.id,
            ),
          )
          .toList(growable: false);
      final queuedRecords = await _dbService.syncQueue.getAll(
        queueIds.map(fastHash).toList(growable: false),
      );
      final queuedIsarIdByUnitId = <String, int>{};
      for (var i = 0; i < queueIds.length; i++) {
        final queued = queuedRecords[i];
        if (queued != null) {
          queuedIsarIdByUnitId[pending[i].id] = queued.isarId;
        }
      }
      final unitsToUpdate = <UnitEntity>[];
      final queueIdsToDelete = <int>[];
      for (final unit in pending) {
        try {
          final payload = _unitToJson(unit);
          await db
              .collection(CollectionRegistry.units)
              .doc(unit.name)
              .set(payload, firestore.SetOptions(merge: true));
          if (unit.syncStatus != SyncStatus.conflict) {
            unit.syncStatus = SyncStatus.synced;
            unit.updatedAt = DateTime.now();
            unitsToUpdate.add(unit);
          }
          final queuedIsarId = queuedIsarIdByUnitId[unit.id];
          if (queuedIsarId != null) {
            queueIdsToDelete.add(queuedIsarId);
          }
          pushedCount++;
        } catch (e) {
          markSyncIssue('units push', e);
          pushError = e.toString();
        }
      }
      if (unitsToUpdate.isNotEmpty || queueIdsToDelete.isNotEmpty) {
        await _dbService.db.writeTxn(() async {
          if (unitsToUpdate.isNotEmpty) {
            await _dbService.units.putAll(unitsToUpdate);
          }
          if (queueIdsToDelete.isNotEmpty) {
            await _dbService.syncQueue.deleteAll(queueIdsToDelete);
          }
        });
      }
      pushSuccess = true;
    } catch (e) {
      pushError = e.toString();
      markSyncIssue('units push', e);
    } finally {
      pushStopwatch.stop();
      await recordMetric(
        entityType: 'units',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: pushStopwatch.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final pullStopwatch = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;
    try {
      final lastSync = forceRefresh
          ? null
          : await getLastSyncTimestamp('units');
      firestore.Query query = db.collection(CollectionRegistry.units);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }
      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        var maxUpdatedAt = lastSync ?? DateTime(2000);

        final unitNames = snapshot.docs
            .map(
              (doc) =>
                  ((doc.data() as Map)['name']?.toString() ?? doc.id).trim(),
            )
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList();

        final existingUnitsList = await _dbService.units
            .filter()
            .anyOf(unitNames, (q, String name) => q.nameEqualTo(name))
            .findAll();

        final existingUnitsMap = {for (final u in existingUnitsList) u.name: u};

        await _dbService.db.writeTxn(() async {
          for (final doc in snapshot.docs) {
            final data = Map<String, dynamic>.from(
              doc.data() as Map<String, dynamic>,
            );
            final name = (data['name']?.toString() ?? doc.id).trim();
            if (name.isEmpty) continue;
            final updatedAt = parseRemoteDate(data['updatedAt']);
            if (updatedAt.isAfter(maxUpdatedAt)) {
              maxUpdatedAt = updatedAt;
            }

            final existing = existingUnitsMap[name];
            if (existing != null &&
                (existing.syncStatus == SyncStatus.pending ||
                    existing.syncStatus == SyncStatus.conflict)) {
              await detectAndFlagConflict(
                entityId: existing.id,
                entityType: 'units',
                serverData: data,
                localEntity: existing,
                localToJson: (e) => _unitToJson(e as UnitEntity),
              );
              continue;
            }

            final unit = existing ?? UnitEntity();
            final remoteId = data['id']?.toString().trim();
            unit.id = (remoteId != null && remoteId.isNotEmpty)
                ? remoteId
                : name;
            unit.name = name;
            unit.createdAt =
                data['createdAt']?.toString() ??
                existing?.createdAt ??
                updatedAt.toIso8601String();
            unit.isDeleted = data['isDeleted'] == true;
            unit.updatedAt = updatedAt;
            unit.syncStatus = SyncStatus.synced;
            await _dbService.units.put(unit);
          }
        });
        pulledCount = snapshot.docs.length;
        await setLastSyncTimestamp('units', maxUpdatedAt);
      }
      pullSuccess = true;
    } catch (e) {
      pullError = e.toString();
      markSyncIssue('units pull', e);
    } finally {
      pullStopwatch.stop();
      await recordMetric(
        entityType: 'units',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: pullStopwatch.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncProductCategoriesCollection(
    firestore.FirebaseFirestore db, {
    bool forceRefresh = false,
  }) async {
    final pushStopwatch = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;
    try {
      final pending = await _dbService.categories
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();
      final queueIds = pending
          .map(
            (category) => OutboxCodec.buildQueueId(
              'product_categories',
              {'id': category.id},
              explicitRecordKey: category.id,
            ),
          )
          .toList(growable: false);
      final queuedRecords = await _dbService.syncQueue.getAll(
        queueIds.map(fastHash).toList(growable: false),
      );
      final queuedIsarIdByCategoryId = <String, int>{};
      for (var i = 0; i < queueIds.length; i++) {
        final queued = queuedRecords[i];
        if (queued != null) {
          queuedIsarIdByCategoryId[pending[i].id] = queued.isarId;
        }
      }
      final categoriesToUpdate = <CategoryEntity>[];
      final queueIdsToDelete = <int>[];
      for (final category in pending) {
        try {
          final payload = _categoryToJson(category);
          await db
              .collection(CollectionRegistry.productCategories)
              .doc(category.id)
              .set(payload, firestore.SetOptions(merge: true));
          if (category.syncStatus != SyncStatus.conflict) {
            category.syncStatus = SyncStatus.synced;
            category.updatedAt = DateTime.now();
            categoriesToUpdate.add(category);
          }
          final queuedIsarId = queuedIsarIdByCategoryId[category.id];
          if (queuedIsarId != null) {
            queueIdsToDelete.add(queuedIsarId);
          }
          pushedCount++;
        } catch (e) {
          markSyncIssue('product_categories push', e);
          pushError = e.toString();
        }
      }
      if (categoriesToUpdate.isNotEmpty || queueIdsToDelete.isNotEmpty) {
        await _dbService.db.writeTxn(() async {
          if (categoriesToUpdate.isNotEmpty) {
            await _dbService.categories.putAll(categoriesToUpdate);
          }
          if (queueIdsToDelete.isNotEmpty) {
            await _dbService.syncQueue.deleteAll(queueIdsToDelete);
          }
        });
      }
      pushSuccess = true;
    } catch (e) {
      pushError = e.toString();
      markSyncIssue('product_categories push', e);
    } finally {
      pushStopwatch.stop();
      await recordMetric(
        entityType: 'product_categories',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: pushStopwatch.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final pullStopwatch = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;
    try {
      final lastSync = forceRefresh
          ? null
          : await getLastSyncTimestamp('product_categories');
      firestore.Query query = db.collection(CollectionRegistry.productCategories);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }
      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        var maxUpdatedAt = lastSync ?? DateTime(2000);

        final categoryIds = snapshot.docs
            .map(
              (doc) => ((doc.data() as Map)['id']?.toString() ?? doc.id).trim(),
            )
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList();

        final existingCategoriesList = await _dbService.categories
            .filter()
            .anyOf(categoryIds, (q, String id) => q.idEqualTo(id))
            .findAll();

        final existingCategoriesMap = {
          for (final c in existingCategoriesList) c.id: c,
        };

        await _dbService.db.writeTxn(() async {
          for (final doc in snapshot.docs) {
            final data = Map<String, dynamic>.from(
              doc.data() as Map<String, dynamic>,
            );
            final id = (data['id']?.toString() ?? doc.id).trim();
            if (id.isEmpty) continue;
            final updatedAt = parseRemoteDate(data['updatedAt']);
            if (updatedAt.isAfter(maxUpdatedAt)) {
              maxUpdatedAt = updatedAt;
            }

            final existing = existingCategoriesMap[id];
            if (existing != null &&
                (existing.syncStatus == SyncStatus.pending ||
                    existing.syncStatus == SyncStatus.conflict)) {
              await detectAndFlagConflict(
                entityId: id,
                entityType: 'product_categories',
                serverData: data,
                localEntity: existing,
                localToJson: (e) => _categoryToJson(e as CategoryEntity),
              );
              continue;
            }

            final category = existing ?? CategoryEntity();
            category.id = id;
            category.name = data['name']?.toString() ?? existing?.name ?? '';
            category.itemType = normalizeProductItemTypeLabel(
              data['itemType']?.toString() ?? existing?.itemType ?? '',
            );
            category.createdAt =
                data['createdAt']?.toString() ??
                existing?.createdAt ??
                updatedAt.toIso8601String();
            category.isDeleted = data['isDeleted'] == true;
            category.updatedAt = updatedAt;
            category.syncStatus = SyncStatus.synced;
            await _dbService.categories.put(category);
          }
        });
        pulledCount = snapshot.docs.length;
        await setLastSyncTimestamp('product_categories', maxUpdatedAt);
      }
      pullSuccess = true;
    } catch (e) {
      pullError = e.toString();
      markSyncIssue('product_categories pull', e);
    } finally {
      pullStopwatch.stop();
      await recordMetric(
        entityType: 'product_categories',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: pullStopwatch.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }

  Future<void> syncProductTypesCollection(
    firestore.FirebaseFirestore db, {
    bool forceRefresh = false,
  }) async {
    final pushStopwatch = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;
    try {
      final pending = await _dbService.productTypes
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();
      final queueIds = pending
          .map(
            (type) => OutboxCodec.buildQueueId(
              'product_types',
              {'id': type.id},
              explicitRecordKey: type.id,
            ),
          )
          .toList(growable: false);
      final queuedRecords = await _dbService.syncQueue.getAll(
        queueIds.map(fastHash).toList(growable: false),
      );
      final queuedIsarIdByTypeId = <String, int>{};
      for (var i = 0; i < queueIds.length; i++) {
        final queued = queuedRecords[i];
        if (queued != null) {
          queuedIsarIdByTypeId[pending[i].id] = queued.isarId;
        }
      }
      final productTypesToUpdate = <ProductTypeEntity>[];
      final queueIdsToDelete = <int>[];
      for (final type in pending) {
        try {
          final payload = _productTypeToJson(type);
          await db
              .collection(CollectionRegistry.productTypes)
              .doc(type.id)
              .set(payload, firestore.SetOptions(merge: true));
          if (type.syncStatus != SyncStatus.conflict) {
            type.syncStatus = SyncStatus.synced;
            type.updatedAt = DateTime.now();
            productTypesToUpdate.add(type);
          }
          final queuedIsarId = queuedIsarIdByTypeId[type.id];
          if (queuedIsarId != null) {
            queueIdsToDelete.add(queuedIsarId);
          }
          pushedCount++;
        } catch (e) {
          markSyncIssue('product_types push', e);
          pushError = e.toString();
        }
      }
      if (productTypesToUpdate.isNotEmpty || queueIdsToDelete.isNotEmpty) {
        await _dbService.db.writeTxn(() async {
          if (productTypesToUpdate.isNotEmpty) {
            await _dbService.productTypes.putAll(productTypesToUpdate);
          }
          if (queueIdsToDelete.isNotEmpty) {
            await _dbService.syncQueue.deleteAll(queueIdsToDelete);
          }
        });
      }
      pushSuccess = true;
    } catch (e) {
      pushError = e.toString();
      markSyncIssue('product_types push', e);
    } finally {
      pushStopwatch.stop();
      await recordMetric(
        entityType: 'product_types',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: pushStopwatch.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    final pullStopwatch = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;
    try {
      final lastSync = forceRefresh
          ? null
          : await getLastSyncTimestamp('product_types');
      firestore.Query query = db.collection(CollectionRegistry.productTypes);
      if (lastSync != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }
      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        var maxUpdatedAt = lastSync ?? DateTime(2000);

        final typeIds = snapshot.docs
            .map(
              (doc) => ((doc.data() as Map)['id']?.toString() ?? doc.id).trim(),
            )
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList();

        final existingTypesList = await _dbService.productTypes
            .filter()
            .anyOf(typeIds, (q, String id) => q.idEqualTo(id))
            .findAll();

        final existingTypesMap = {for (final t in existingTypesList) t.id: t};

        await _dbService.db.writeTxn(() async {
          for (final doc in snapshot.docs) {
            final data = Map<String, dynamic>.from(
              doc.data() as Map<String, dynamic>,
            );
            final id = (data['id']?.toString() ?? doc.id).trim();
            if (id.isEmpty) continue;
            final updatedAt = parseRemoteDate(data['updatedAt']);
            if (updatedAt.isAfter(maxUpdatedAt)) {
              maxUpdatedAt = updatedAt;
            }

            final existing = existingTypesMap[id];
            if (existing != null &&
                (existing.syncStatus == SyncStatus.pending ||
                    existing.syncStatus == SyncStatus.conflict)) {
              await detectAndFlagConflict(
                entityId: id,
                entityType: 'product_types',
                serverData: data,
                localEntity: existing,
                localToJson: (e) => _productTypeToJson(e as ProductTypeEntity),
              );
              continue;
            }

            final type = existing ?? ProductTypeEntity();
            type.id = id;
            type.name = normalizeProductItemTypeLabel(
              data['name']?.toString() ?? existing?.name ?? '',
            );
            type.description = data['description']?.toString();
            type.iconName = data['iconName']?.toString();
            type.color = data['color']?.toString();
            if (data['tabs'] is List) {
              type.tabs = (data['tabs'] as List)
                  .map((e) => e.toString())
                  .toList();
            }
            type.defaultUom = data['defaultUom']?.toString();
            type.defaultGst = (data['defaultGst'] as num?)?.toDouble();
            type.skuPrefix = data['skuPrefix']?.toString();
            type.displayUnit = data['displayUnit']?.toString();
            type.createdAt =
                data['createdAt']?.toString() ??
                existing?.createdAt ??
                updatedAt.toIso8601String();
            type.isDeleted = data['isDeleted'] == true;
            type.updatedAt = updatedAt;
            type.syncStatus = SyncStatus.synced;
            await _dbService.productTypes.put(type);
          }
        });
        pulledCount = snapshot.docs.length;
        await setLastSyncTimestamp('product_types', maxUpdatedAt);
      }
      pullSuccess = true;
    } catch (e) {
      pullError = e.toString();
      markSyncIssue('product_types pull', e);
    } finally {
      pullStopwatch.stop();
      await recordMetric(
        entityType: 'product_types',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: pullStopwatch.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }
}
