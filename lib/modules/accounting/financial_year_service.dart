import 'dart:convert';

import 'package:isar/isar.dart';

import '../../core/firebase/firebase_config.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../data/local/entities/config_cache_entity.dart';
import '../../services/database_service.dart';
import '../../services/offline_first_service.dart';

const String financialYearsCollection = CollectionRegistry.financialYears;

class FinancialYearService extends OfflineFirstService {
  FinancialYearService(
    FirebaseServices firebase, {
    DatabaseService? dbService,
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance,
       super(firebase, dbService);

  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  @override
  String get localStorageKey => 'local_financial_years';

  static String financialYearIdForDate(DateTime date) {
    final startYear = date.month >= 4 ? date.year : date.year - 1;
    final endYear = startYear + 1;
    return '$startYear-$endYear';
  }

  static DateTime startDateForFinancialYearId(String financialYearId) {
    final startYear =
        int.tryParse(financialYearId.split('-').first) ?? DateTime.now().year;
    return DateTime(startYear, 4, 1);
  }

  static DateTime endDateForFinancialYearId(String financialYearId) {
    final endYear =
        int.tryParse(financialYearId.split('-').last) ?? DateTime.now().year;
    return DateTime(endYear, 3, 31, 23, 59, 59, 999);
  }

  Future<List<Map<String, dynamic>>> getFinancialYears() async {
    try {
      final cacheEntries = await dbService.configCache
          .filter()
          .collectionNameEqualTo(financialYearsCollection)
          .findAll();
      final years = cacheEntries
          .map(_decodeCachePayload)
          .where((payload) => payload.isNotEmpty)
          .toList(growable: true);
      years.sort(
        (a, b) =>
            (a['id'] ?? '').toString().compareTo((b['id'] ?? '').toString()),
      );
      return years;
    } catch (e) {
      handleError(e, 'getFinancialYears');
      return [];
    }
  }

  Future<Map<String, dynamic>> ensureFinancialYearForDate(
    DateTime date, {
    String? createdBy,
  }) async {
    final financialYearId = financialYearIdForDate(date);
    final existing = await getFinancialYear(financialYearId);
    if (existing != null) return existing;

    final now = getCurrentTimestamp();
    final start = startDateForFinancialYearId(financialYearId);
    final end = endDateForFinancialYearId(financialYearId);

    final payload = <String, dynamic>{
      'id': financialYearId,
      'startDate': start.toIso8601String(),
      'endDate': end.toIso8601String(),
      'isLocked': false,
      'createdAt': now,
      'updatedAt': now,
      if (createdBy != null && createdBy.isNotEmpty) 'createdBy': createdBy,
    };

    await _saveFinancialYearPayload(payload, operation: 'create');
    return payload;
  }

  Future<Map<String, dynamic>?> getFinancialYear(String financialYearId) async {
    final configKey = _configKey(financialYearId);
    final entry = await dbService.configCache.getByConfigKey(configKey);
    if (entry == null) {
      return null;
    }
    final payload = _decodeCachePayload(entry);
    return payload.isEmpty ? null : payload;
  }

  Future<bool> isDateLocked(DateTime date) async {
    final yearId = financialYearIdForDate(date);
    return isFinancialYearLocked(yearId);
  }

  Future<bool> isFinancialYearLocked(String financialYearId) async {
    final year = await getFinancialYear(financialYearId);
    if (year == null) return false;
    return year['isLocked'] == true;
  }

  Future<void> setFinancialYearLock({
    required String financialYearId,
    required bool isLocked,
    String? lockedBy,
  }) async {
    final year = await ensureFinancialYearForDate(
      startDateForFinancialYearId(financialYearId),
      createdBy: lockedBy,
    );

    final now = getCurrentTimestamp();
    final updated = <String, dynamic>{
      ...year,
      'id': financialYearId,
      'isLocked': isLocked,
      'updatedAt': now,
      if (lockedBy != null && lockedBy.isNotEmpty) 'lockedBy': lockedBy,
      if (isLocked) 'lockedAt': now,
    };

    await _saveFinancialYearPayload(updated, operation: 'update');
  }

  Future<void> _saveFinancialYearPayload(
    Map<String, dynamic> payload, {
    required String operation,
  }) async {
    final documentId = (payload['id'] ?? '').toString().trim();
    if (documentId.isEmpty) {
      throw ArgumentError('Financial year id is required');
    }

    final configKey = _configKey(documentId);
    final existing = await dbService.configCache.getByConfigKey(configKey);
    final now = DateTime.now();
    final entity = ConfigCacheEntity()
      ..isarId = existing?.isarId ?? 0
      ..configKey = configKey
      ..collectionName = financialYearsCollection
      ..documentId = documentId
      ..payloadJson = jsonEncode(payload)
      ..version = existing == null ? 1 : existing.version + 1
      ..lastModified = now
      ..lastSynced = null
      ..isSynced = false
      ..deviceId = await _deviceIdService.getDeviceId();

    await dbService.db.writeTxn(() async {
      await dbService.configCache.put(entity);
    });

    await _syncQueueService.addToQueue(
      collectionName: financialYearsCollection,
      documentId: documentId,
      operation: existing == null ? operation : 'update',
      payload: payload,
    );

    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }

  String _configKey(String documentId) {
    return '$financialYearsCollection/$documentId';
  }

  Map<String, dynamic> _decodeCachePayload(ConfigCacheEntity entry) {
    try {
      final decoded = jsonDecode(entry.payloadJson);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (e) {
      handleError(e, '_decodeCachePayload');
    }
    return <String, dynamic>{};
  }
}
