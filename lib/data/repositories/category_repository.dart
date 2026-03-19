import 'package:isar/isar.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../local/base_entity.dart';
import '../local/entities/category_entity.dart';
import '../../services/database_service.dart';

class CategoryRepository {
  CategoryRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  Future<List<CategoryEntity>> getAllCategories() async {
    return _dbService.categories
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  Stream<List<CategoryEntity>> watchAllCategories() {
    return _dbService.categories
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .watch(fireImmediately: true);
  }

  Future<CategoryEntity?> getCategoryById(String id) async {
    return _dbService.categories
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<void> saveCategory(CategoryEntity category) async {
    final now = DateTime.now();
    final entityId = category.id.trim().isEmpty
        ? _fallbackId(category.name)
        : category.id.trim();
    final existing = await _dbService.categories.getById(entityId);

    category
      ..id = entityId
      ..createdAt = _resolveCreatedAt(category, now)
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false
      ..isSynced = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.categories.put(category);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.productCategories,
      documentId: category.id,
      operation: existing == null ? 'create' : 'update',
      payload: category.toJson(),
    );

    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }

  Future<void> deleteCategory(String id) async {
    final existing = await _dbService.categories.getById(id);
    if (existing == null || existing.isDeleted) {
      return;
    }

    final now = DateTime.now();
    existing
      ..isDeleted = true
      ..deletedAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1;

    await _dbService.db.writeTxn(() async {
      await _dbService.categories.put(existing);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.productCategories,
      documentId: existing.id,
      operation: 'delete',
      payload: existing.toJson(),
    );

    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }

  String _resolveCreatedAt(CategoryEntity category, DateTime now) {
    try {
      if (category.createdAt.trim().isNotEmpty) {
        return category.createdAt;
      }
    } catch (_) {
      // Late initialization fallback.
    }
    return now.toIso8601String();
  }

  String _fallbackId(String name) {
    final normalized = name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    if (normalized.isNotEmpty) {
      return normalized;
    }
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
