import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../local/base_entity.dart';
import '../local/entities/dealer_entity.dart';
import '../../services/database_service.dart';

class DealerRepository {
  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  static const Uuid _uuid = Uuid();

  DealerRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  // ==================== READ OPERATIONS ====================

  /// Fetch all dealers - Local First
  Future<List<DealerEntity>> getAllDealers() async {
    return _dbService.dealers
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  /// Streams all non-deleted dealers from Isar.
  Stream<List<DealerEntity>> watchAllDealers() {
    return _dbService.dealers
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .watch(fireImmediately: true);
  }

  /// Get dealers by status
  Future<List<DealerEntity>> getDealersByStatus(String status) async {
    return _dbService.dealers
        .filter()
        .statusEqualTo(status)
        .and()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  /// Get dealers by territory
  Future<List<DealerEntity>> getDealersByTerritory(String territory) async {
    return _dbService.dealers
        .filter()
        .territoryEqualTo(territory)
        .and()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  /// Returns dealers for a route from Isar only.
  Future<List<DealerEntity>> getDealersByRoute(String routeId) async {
    return _dbService.dealers
        .filter()
        .assignedRouteIdEqualTo(routeId)
        .and()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  /// Get single dealer by ID
  Future<DealerEntity?> getDealerById(String id) async {
    return _dbService.dealers
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Search dealers by name, contact person, or mobile
  Future<List<DealerEntity>> searchDealers(String query) async {
    final lowerQuery = query.toLowerCase();
    return _dbService.dealers
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .group(
          (builder) => builder
              .nameContains(lowerQuery, caseSensitive: false)
              .or()
              .contactPersonContains(lowerQuery, caseSensitive: false)
              .or()
              .mobileContains(query),
        )
        .sortByName()
        .findAll();
  }

  // ==================== WRITE OPERATIONS ====================

  void _ensureCreatedAt(DealerEntity dealer, DateTime now) {
    try {
      final current = dealer.createdAt.trim();
      if (current.isNotEmpty) {
        return;
      }
    } catch (_) {
      // Late initialization fallback.
    }
    dealer.createdAt = now.toIso8601String();
  }

  String _ensureId(DealerEntity dealer) {
    try {
      final current = dealer.id.trim();
      if (current.isNotEmpty) {
        return current;
      }
    } catch (_) {
      // Late initialization fallback.
    }
    final generated = _uuid.v4();
    dealer.id = generated;
    return generated;
  }

  /// Create or Update Dealer - Local Commit
  Future<void> saveDealer(DealerEntity dealer) async {
    final now = DateTime.now();
    final existing = await _dbService.dealers.getById(_ensureId(dealer));
    _ensureCreatedAt(dealer, now);

    dealer
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..deletedAt = null
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.dealers.put(dealer);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.dealers,
      documentId: dealer.id,
      operation: existing == null ? 'create' : 'update',
      payload: dealer.toJson(),
    );

    await _syncIfOnline();
  }

  /// Update dealer status
  Future<void> updateStatus(String dealerId, String status) async {
    final dealer = await getDealerById(dealerId);
    if (dealer == null) {
      return;
    }

    dealer
      ..status = status
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.dealers.put(dealer);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.dealers,
      documentId: dealer.id,
      operation: 'update',
      payload: dealer.toJson(),
    );

    await _syncIfOnline();
  }

  /// Bulk update dealer status
  Future<void> bulkUpdateStatus(List<String> dealerIds, String status) async {
    final dealers = <DealerEntity>[];
    final deviceId = await _deviceIdService.getDeviceId();
    final now = DateTime.now();

    await _dbService.db.writeTxn(() async {
      for (final id in dealerIds) {
        final dealer = await _dbService.dealers.getById(id);
        if (dealer == null || dealer.isDeleted) {
          continue;
        }
        dealer
          ..status = status
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending
          ..isSynced = false
          ..lastSynced = null
          ..version += 1
          ..deviceId = deviceId;
        dealers.add(dealer);
        await _dbService.dealers.put(dealer);
      }
    });

    for (final dealer in dealers) {
      await _syncQueueService.addToQueue(
        collectionName: CollectionRegistry.dealers,
        documentId: dealer.id,
        operation: 'update',
        payload: dealer.toJson(),
      );
    }

    await _syncIfOnline();
  }

  /// Soft delete dealer
  Future<void> deleteDealer(String dealerId) async {
    final dealer = await getDealerById(dealerId);
    if (dealer == null) {
      return;
    }

    final now = DateTime.now();
    dealer
      ..isDeleted = true
      ..deletedAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await _dbService.dealers.put(dealer);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.dealers,
      documentId: dealer.id,
      operation: 'delete',
      payload: dealer.toJson(),
    );

    await _syncIfOnline();
  }

  // ==================== SYNC SUPPORT ====================

  /// Get all pending dealers (for sync)
  Future<List<DealerEntity>> getPendingDealers() async {
    return _dbService.dealers
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
  }

  /// Mark dealer as synced
  Future<void> markAsSynced(String dealerId) async {
    final dealer = await _dbService.dealers.getById(dealerId);
    if (dealer == null) {
      return;
    }

    dealer
      ..syncStatus = SyncStatus.synced
      ..isSynced = true
      ..lastSynced = DateTime.now();

    await _dbService.db.writeTxn(() async {
      await _dbService.dealers.put(dealer);
    });
  }

  /// Batch save dealers (used during sync pull)
  Future<void> saveAllDealers(List<DealerEntity> dealers) async {
    await _dbService.db.writeTxn(() async {
      await _dbService.dealers.putAll(dealers);
    });
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
