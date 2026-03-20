import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../data/local/base_entity.dart';
import '../../data/local/entities/sale_entity.dart';
import '../../features/inventory/models/sync_queue.dart';
import '../../services/database_service.dart';

class SalesLocalProvider {
  SalesLocalProvider(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
    Uuid? uuid,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance,
       _uuid = uuid ?? const Uuid();

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;
  final Uuid _uuid;

  static const String salesCollection = CollectionRegistry.sales;
  static const int _salesPageSize = 500;

  Future<List<SaleEntity>> fetchAllSalesPaged() async {
    final allSales = <SaleEntity>[];
    var offset = 0;
    while (true) {
      final chunk = await _dbService.sales
          .where()
          .offset(offset)
          .limit(_salesPageSize)
          .findAll();
      if (chunk.isEmpty) {
        break;
      }
      allSales.addAll(chunk);
      if (chunk.length < _salesPageSize) {
        break;
      }
      offset += _salesPageSize;
    }
    return allSales;
  }

  Future<SaleEntity?> getSaleById(String id) async {
    return _dbService.sales.filter().idEqualTo(id).findFirst();
  }

  Future<void> saveSale(SaleEntity entity) async {
    final prepared = await _prepareSaleForWrite(entity);
    await _dbService.db.writeTxn(() async {
      await _dbService.sales.put(prepared.entity);
    });
    await _syncQueueService.addToQueue(
      collectionName: salesCollection,
      documentId: prepared.entity.id,
      operation: prepared.operation,
      payload: prepared.entity.toJson(),
    );
    await _syncIfOnline();
  }

  Future<void> saveSales(List<SaleEntity> entities) async {
    final prepared = <_PreparedSaleWrite>[];
    for (final entity in entities) {
      prepared.add(await _prepareSaleForWrite(entity));
    }
    await _dbService.db.writeTxn(() async {
      await _dbService.sales.putAll(
        prepared.map((entry) => entry.entity).toList(growable: false),
      );
    });
    for (final entry in prepared) {
      await _syncQueueService.addToQueue(
        collectionName: salesCollection,
        documentId: entry.entity.id,
        operation: entry.operation,
        payload: entry.entity.toJson(),
      );
    }
    await _syncIfOnline();
  }

  Future<void> deleteSale(int isarId) async {
    final existing = await _dbService.sales.get(isarId);
    if (existing == null) {
      return;
    }

    final now = DateTime.now();
    final deviceId = await _deviceIdService.getDeviceId();
    final payload = Map<String, dynamic>.from(existing.toJson())
      ..['isDeleted'] = true
      ..['deletedAt'] = now.toIso8601String()
      ..['updatedAt'] = now.toIso8601String()
      ..['lastModified'] = now.toIso8601String()
      ..['syncStatus'] = SyncStatus.pending.name
      ..['isSynced'] = false
      ..['lastSynced'] = null
      ..['version'] = existing.version + 1
      ..['deviceId'] = deviceId;

    await _dbService.db.writeTxn(() async {
      await _dbService.sales.delete(isarId);
    });
    await _syncQueueService.addToQueue(
      collectionName: salesCollection,
      documentId: existing.id,
      operation: 'delete',
      payload: payload,
    );
    await _syncIfOnline();
  }

  Future<String> enqueueSaleForSync(
    Map<String, dynamic> saleData, {
    String action = 'add',
  }) async {
    final saleId = saleData['id']?.toString();
    if (saleId == null || saleId.isEmpty) return '';

    await _syncQueueService.addToQueue(
      collectionName: salesCollection,
      documentId: saleId,
      operation: action,
      payload: saleData,
    );
    return saleId;
  }

  Future<void> dequeueSaleForSync(String saleId) async {
    if (saleId.isEmpty) return;
    await _syncQueueService.removeFromQueue(
      collectionName: salesCollection,
      documentId: saleId,
    );
  }

  Future<List<SyncQueue>> getPendingSalesSyncQueue() async {
    final items = await _syncQueueService.getPendingQueue();
    return items
        .where((item) => item.collectionName == salesCollection)
        .toList(growable: false);
  }

  Future<_PreparedSaleWrite> _prepareSaleForWrite(SaleEntity entity) async {
    final now = DateTime.now();
    final id = _ensureId(entity);
    final existing = await _dbService.sales.getById(id);
    final createdAt = _ensureCreatedAt(entity, existing?.createdAt, now);
    final createdAtDate = DateTime.tryParse(createdAt) ?? now;

    entity
      ..id = id
      ..createdAt = createdAt
      ..month = entity.month ?? createdAtDate.month
      ..year = entity.year ?? createdAtDate.year
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..deletedAt = null
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();

    return _PreparedSaleWrite(
      entity,
      existing == null ? 'create' : 'update',
    );
  }

  String _ensureId(SaleEntity entity) {
    try {
      final normalized = entity.id.trim();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    } catch (_) {
      // Late initialization fallback.
    }

    final generated = _uuid.v4();
    entity.id = generated;
    return generated;
  }

  String _ensureCreatedAt(
    SaleEntity entity,
    String? existingCreatedAt,
    DateTime now,
  ) {
    try {
      final current = entity.createdAt.trim();
      if (current.isNotEmpty) {
        return current;
      }
    } catch (_) {
      // Late initialization fallback.
    }

    final fallback = existingCreatedAt ?? now.toIso8601String();
    entity.createdAt = fallback;
    return fallback;
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.trySync();
    }
  }
}

class _PreparedSaleWrite {
  _PreparedSaleWrite(this.entity, this.operation);

  final SaleEntity entity;
  final String operation;
}
