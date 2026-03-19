import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/firebase/firebase_config.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../services/database_service.dart';
import '../../services/inventory_service.dart';
import '../../services/production_service.dart';
import '../local/base_entity.dart';
import '../local/entities/detailed_production_log_entity.dart';
import '../local/entities/production_entry_entity.dart';
import '../local/entities/production_target_entity.dart';

/// Isar-first repository for production operations.
class ProductionRepository {
  ProductionRepository(
    this._dbService, {
    FirebaseServices? firebaseServices,
    InventoryService? inventoryService,
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance,
       _productionService = firebaseServices != null && inventoryService != null
           ? ProductionService(firebaseServices, inventoryService, _dbService)
           : null;

  static const Uuid _uuid = Uuid();

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;
  final ProductionService? _productionService;

  Future<String?> saveProductionEntry({
    required DateTime date,
    required String departmentCode,
    required String departmentName,
    required List<ProductionItemEntity> items,
    required String createdBy,
    required String createdByName,
    String? teamCode,
    String? notes,
  }) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final entryId = '${departmentCode}_${normalizedDate.toIso8601String().split('T').first}';
    final existing = await _dbService.productionEntries.getById(entryId);
    final entity = ProductionDailyEntryEntity()
      ..id = entryId
      ..date = normalizedDate
      ..departmentCode = departmentCode
      ..departmentName = departmentName
      ..teamCode = teamCode
      ..items = items
      ..createdBy = createdBy
      ..createdByName = createdByName
      ..createdAt = existing?.createdAt ?? DateTime.now()
      ..notes = notes;

    await _saveProductionEntryEntity(entity, existing: existing);
    return entryId;
  }

  Future<void> saveProductionTarget(ProductionTargetEntity target) async {
    final id = _ensureId(target);
    final existing = await _dbService.productionTargets.getById(id);
    target
      ..id = id
      ..createdAt = _ensureDate(() => target.createdAt, existing?.createdAt)
      ..status = _safeString(() => target.status, fallback: 'active');

    await _stampForSync(target, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.productionTargets.put(target);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.productionTargets,
      documentId: target.id,
      operation: existing == null ? 'create' : 'update',
      payload: target.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> saveDetailedProductionLog(DetailedProductionLogEntity log) async {
    final id = _ensureId(log);
    final existing = await _dbService.detailedProductionLogs.getById(id);
    log
      ..id = id
      ..createdAt = _ensureDate(() => log.createdAt, existing?.createdAt)
      ..semiFinishedGoodsUsed = List<ProductionMaterialItem>.from(
        log.semiFinishedGoodsUsed,
      )
      ..packagingMaterialsUsed = List<ProductionMaterialItem>.from(
        log.packagingMaterialsUsed,
      )
      ..additionalRawMaterialsUsed = List<ProductionMaterialItem>.from(
        log.additionalRawMaterialsUsed,
      );

    await _stampForSync(log, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.detailedProductionLogs.put(log);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.detailedProductionLogs,
      documentId: log.id,
      operation: existing == null ? 'create' : 'update',
      payload: log.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> updateTargetAchievement(String id, double achieved) async {
    final target = await _dbService.productionTargets.getById(id);
    if (target == null || target.isDeleted) {
      return;
    }

    target
      ..achievedQuantity = achieved.round()
      ..status = target.achievedQuantity >= target.targetQuantity
          ? 'completed'
          : 'active';

    await _stampForSync(target, target);
    await _dbService.db.writeTxn(() async {
      await _dbService.productionTargets.put(target);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.productionTargets,
      documentId: target.id,
      operation: 'update',
      payload: target.toJson(),
    );

    await _syncIfOnline();
  }

  Future<List<ProductionDailyEntryEntity>> getAllProductionEntries() {
    return _dbService.productionEntries
        .filter()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
  }

  Future<List<ProductionDailyEntryEntity>> getEntriesByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    return _dbService.productionEntries
        .filter()
        .dateBetween(start, end, includeUpper: true)
        .and()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
  }

  Future<List<ProductionDailyEntryEntity>> getEntriesByDepartment(
    String departmentCode,
  ) {
    return _dbService.productionEntries
        .filter()
        .departmentCodeEqualTo(departmentCode)
        .and()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .findAll();
  }

  Future<List<ProductionTargetEntity>> getAllProductionTargets() {
    return _dbService.productionTargets
        .filter()
        .isDeletedEqualTo(false)
        .sortByTargetDateDesc()
        .findAll();
  }

  Future<ProductionTargetEntity?> getTargetByProduct(String productId) {
    return _dbService.productionTargets
        .filter()
        .productIdEqualTo(productId)
        .and()
        .isDeletedEqualTo(false)
        .sortByTargetDateDesc()
        .findFirst();
  }

  Future<List<ProductionTargetEntity>> getTargetsByDateRange(
    DateTime from,
    DateTime to,
  ) {
    final fromKey = from.toIso8601String().split('T').first;
    final toKey = to.toIso8601String().split('T').first;
    return _dbService.productionTargets
        .filter()
        .targetDateBetween(fromKey, toKey, includeUpper: true)
        .and()
        .isDeletedEqualTo(false)
        .sortByTargetDateDesc()
        .findAll();
  }

  Future<List<DetailedProductionLogEntity>> getAllDetailedLogs() {
    return _dbService.detailedProductionLogs
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<DetailedProductionLogEntity>> getLogsByBatch(String batchNumber) {
    return _dbService.detailedProductionLogs
        .filter()
        .batchNumberEqualTo(batchNumber)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Stream<List<ProductionDailyEntryEntity>> watchAllProductionEntries() {
    return _dbService.productionEntries
        .filter()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<ProductionTargetEntity>> watchAllTargets() {
    return _dbService.productionTargets
        .filter()
        .isDeletedEqualTo(false)
        .sortByTargetDateDesc()
        .watch(fireImmediately: true);
  }

  Future<void> deleteProductionEntry(String id) async {
    final entry = await _dbService.productionEntries.getById(id);
    if (entry == null || entry.isDeleted) {
      return;
    }
    await _softDelete(
      entry,
      collectionName: CollectionRegistry.productionEntries,
      writer: () => _dbService.productionEntries.put(entry),
    );
  }

  Future<void> deleteProductionTarget(String id) async {
    final target = await _dbService.productionTargets.getById(id);
    if (target == null || target.isDeleted) {
      return;
    }
    await _softDelete(
      target,
      collectionName: CollectionRegistry.productionTargets,
      writer: () => _dbService.productionTargets.put(target),
    );
  }

  Future<void> deleteDetailedProductionLog(String id) async {
    final log = await _dbService.detailedProductionLogs.getById(id);
    if (log == null || log.isDeleted) {
      return;
    }
    await _softDelete(
      log,
      collectionName: CollectionRegistry.detailedProductionLogs,
      writer: () => _dbService.detailedProductionLogs.put(log),
    );
  }

  Future<List<ProductionDailyEntryEntity>> getProductionEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? departmentCode,
  }) async {
    var query = _dbService.productionEntries
        .filter()
        .dateBetween(startDate, endDate, includeUpper: true)
        .and()
        .isDeletedEqualTo(false);
    if (departmentCode != null && departmentCode.trim().isNotEmpty) {
      query = query.departmentCodeEqualTo(departmentCode.trim());
    }
    return query.sortByDateDesc().findAll();
  }

  Future<ProductionDailyEntryEntity?> getLatestProductionEntry(
    String departmentCode,
  ) {
    return _dbService.productionEntries
        .filter()
        .departmentCodeEqualTo(departmentCode)
        .and()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .findFirst();
  }

  Future<ProductionDailyEntryEntity?> getProductionEntryByDate({
    required DateTime date,
    required String departmentCode,
  }) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    return _dbService.productionEntries
        .filter()
        .departmentCodeEqualTo(departmentCode)
        .and()
        .dateBetween(start, end, includeUpper: true)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<void> fetchAndCacheProductionEntries({
    required DateTime startDate,
    required DateTime endDate,
    String? departmentCode,
  }) async {
    final service = _productionService;
    if (service == null) {
      return;
    }
    final remoteEntries = await service.getDailyEntries(
      startDate: startDate,
      endDate: endDate,
      departmentCode: departmentCode,
    );
    if (remoteEntries.isEmpty) {
      return;
    }
    final entities = remoteEntries
        .map(ProductionDailyEntryEntity.fromFirebaseJson)
        .toList(growable: false);
    await _dbService.db.writeTxn(() async {
      await _dbService.productionEntries.putAll(entities);
    });
  }

  Future<void> _saveProductionEntryEntity(
    ProductionDailyEntryEntity entity, {
    ProductionDailyEntryEntity? existing,
  }) async {
    entity
      ..createdAt = existing?.createdAt ?? entity.createdAt
      ..items = List<ProductionItemEntity>.from(entity.items);

    await _stampForSync(entity, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.productionEntries.put(entity);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.productionEntries,
      documentId: entity.id,
      operation: existing == null ? 'create' : 'update',
      payload: entity.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> _stampForSync(BaseEntity entity, BaseEntity? existing) async {
    entity
      ..updatedAt = DateTime.now()
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();
  }

  Future<void> _softDelete(
    BaseEntity entity, {
    required String collectionName,
    required Future<void> Function() writer,
  }) async {
    entity
      ..isDeleted = true
      ..deletedAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();

    await _dbService.db.writeTxn(() async {
      await writer();
    });

    await _syncQueueService.addToQueue(
      collectionName: collectionName,
      documentId: entity.id,
      operation: 'delete',
      payload: (entity as dynamic).toJson(),
    );

    await _syncIfOnline();
  }

  String _ensureId(BaseEntity entity) {
    try {
      final id = entity.id.trim();
      if (id.isNotEmpty) {
        return id;
      }
    } catch (_) {
      // Late init fallback.
    }
    final generated = _uuid.v4();
    entity.id = generated;
    return generated;
  }

  DateTime _ensureDate(DateTime Function() reader, DateTime? fallback) {
    try {
      return reader();
    } catch (_) {
      return fallback ?? DateTime.now();
    }
  }

  String _safeString(String Function() reader, {String fallback = ''}) {
    try {
      final value = reader().trim();
      return value.isEmpty ? fallback : value;
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
