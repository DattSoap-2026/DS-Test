import 'dart:async';

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../services/database_service.dart';
import '../local/base_entity.dart';
import '../local/entities/alert_entity.dart';
import '../local/entities/audit_log_entity.dart';
import '../local/entities/conflict_entity.dart';
import '../local/entities/sync_metric_entity.dart';

class AlertsRepository {
  AlertsRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService =
           connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  static const Uuid _uuid = Uuid();

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  Future<void> saveAlert(AlertEntity alert) async {
    final id = _ensureId(alert);
    final existing = await _dbService.alerts.getById(id);

    alert
      ..id = id
      ..alertId = _normalizeText(alert.alertId, fallback: id)
      ..title = _normalizeText(alert.title, fallback: 'System Alert')
      ..message = _normalizeText(alert.message, fallback: 'Notification')
      ..createdAt = existing?.createdAt ?? _resolveDate(() => alert.createdAt);

    await _saveEntity(
      entity: alert,
      existing: existing,
      collectionName: CollectionRegistry.alerts,
      payload: alert.toJson(),
      persist: () async {
        await _dbService.alerts.put(alert);
      },
    );
  }

  Future<List<AlertEntity>> getAllAlerts() async {
    final alerts = await _dbService.alerts
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortAlerts(alerts);
  }

  Future<List<AlertEntity>> getUnreadAlerts() async {
    final alerts = await _dbService.alerts
        .filter()
        .isReadEqualTo(false)
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortAlerts(alerts);
  }

  Future<List<AlertEntity>> getAlertsByType(String type) async {
    final normalized = type.trim().toLowerCase();
    final alerts = await getAllAlerts();
    return alerts
        .where((alert) => alert.type.name.toLowerCase() == normalized)
        .toList(growable: false);
  }

  Future<List<AlertEntity>> getAlertsBySeverity(String severity) async {
    final normalized = severity.trim().toLowerCase();
    final alerts = await getAllAlerts();
    return alerts
        .where((alert) => alert.severity.name.toLowerCase() == normalized)
        .toList(growable: false);
  }

  Stream<List<AlertEntity>> watchUnreadAlerts() {
    return _dbService.alerts
        .filter()
        .isReadEqualTo(false)
        .and()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map(_sortAlerts);
  }

  Stream<List<AlertEntity>> watchAllAlerts() {
    return _dbService.alerts
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map(_sortAlerts);
  }

  Future<void> markAsRead(String alertId) async {
    final alert = await _getAlertByAnyId(alertId);
    if (alert == null || alert.isDeleted) {
      return;
    }

    alert.isRead = true;

    await _saveEntity(
      entity: alert,
      existing: alert,
      collectionName: CollectionRegistry.alerts,
      payload: alert.toJson(),
      persist: () async {
        await _dbService.alerts.put(alert);
      },
    );
  }

  Future<void> markAllAsRead() async {
    final unread = await _dbService.alerts
        .filter()
        .isReadEqualTo(false)
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    if (unread.isEmpty) {
      return;
    }

    final deviceId = await _deviceIdService.getDeviceId();
    final now = DateTime.now();
    await _dbService.db.writeTxn(() async {
      for (final alert in unread) {
        _applySyncStamp(
          alert,
          existing: alert,
          deviceId: deviceId,
          now: now,
        );
        alert.isRead = true;
        await _dbService.alerts.put(alert);
      }
    });

    for (final alert in unread) {
      await _enqueue(
        CollectionRegistry.alerts,
        alert.id,
        'update',
        alert.toJson(),
      );
    }
    await _syncIfOnline();
  }

  Future<void> deleteAlert(String id) async {
    final alert = await _getAlertByAnyId(id);
    if (alert == null || alert.isDeleted) {
      return;
    }

    await _softDeleteEntity(
      entity: alert,
      collectionName: CollectionRegistry.alerts,
      payloadBuilder: alert.toJson,
      persist: () async {
        await _dbService.alerts.put(alert);
      },
    );
  }

  Future<void> deleteOldReadAlerts(int daysOld) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysOld));
    final alerts = await _dbService.alerts
        .filter()
        .isReadEqualTo(true)
        .and()
        .createdAtLessThan(cutoff)
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    if (alerts.isEmpty) {
      return;
    }

    final deviceId = await _deviceIdService.getDeviceId();
    final now = DateTime.now();
    await _dbService.db.writeTxn(() async {
      for (final alert in alerts) {
        alert
          ..isDeleted = true
          ..deletedAt = now;
        _applyDeletedStamp(alert, deviceId: deviceId, now: now);
        await _dbService.alerts.put(alert);
      }
    });

    for (final alert in alerts) {
      await _enqueue(
        CollectionRegistry.alerts,
        alert.id,
        'delete',
        alert.toJson(),
      );
    }
    await _syncIfOnline();
  }

  Future<List<AuditLogEntity>> getAuditLogs() async {
    final logs = await _dbService.auditLogs
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortAuditLogs(logs);
  }

  Future<List<AuditLogEntity>> getAuditLogsByUser(String userId) async {
    final logs = await _dbService.auditLogs
        .filter()
        .userIdEqualTo(userId.trim())
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortAuditLogs(logs);
  }

  Future<List<AuditLogEntity>> getAuditLogsByCollection(
    String collectionName,
  ) async {
    final logs = await _dbService.auditLogs
        .filter()
        .collectionNameEqualTo(collectionName.trim())
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortAuditLogs(logs);
  }

  Future<List<AuditLogEntity>> getAuditLogsByAction(String action) async {
    final normalized = action.trim().toLowerCase();
    final logs = await getAuditLogs();
    return logs
        .where((entry) => entry.action.name.toLowerCase() == normalized)
        .toList(growable: false);
  }

  Future<List<AuditLogEntity>> getAuditLogsByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final logs = await _dbService.auditLogs
        .filter()
        .createdAtBetween(from, to)
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortAuditLogs(logs);
  }

  Stream<List<AuditLogEntity>> watchAuditLogs() {
    return _dbService.auditLogs
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map(_sortAuditLogs);
  }

  Future<void> saveConflict(ConflictEntity conflict) async {
    final id = _ensureId(conflict);
    final existing = await _dbService.conflicts.getById(id);

    conflict
      ..id = id
      ..entityId = _normalizeText(conflict.entityId)
      ..entityType = _normalizeText(conflict.entityType)
      ..conflictDate = existing?.conflictDate ?? _resolveDate(() => conflict.conflictDate)
      ..syncStatus = SyncStatus.synced
      ..isSynced = true
      ..isDeleted = false
      ..lastSynced = DateTime.now();

    await _dbService.db.writeTxn(() async {
      conflict.updatedAt = DateTime.now();
      await _dbService.conflicts.put(conflict);
    });
  }

  Future<List<ConflictEntity>> getUnresolvedConflicts() async {
    final conflicts = await _dbService.conflicts
        .filter()
        .resolvedEqualTo(false)
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortConflicts(conflicts);
  }

  Future<List<ConflictEntity>> getAllConflicts() async {
    final conflicts = await _dbService.conflicts
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
    return _sortConflicts(conflicts);
  }

  Stream<List<ConflictEntity>> watchUnresolvedConflicts() {
    return _dbService.conflicts
        .filter()
        .resolvedEqualTo(false)
        .and()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map(_sortConflicts);
  }

  Future<void> resolveConflict(
    String id,
    String strategy,
    String resolvedBy,
  ) async {
    final conflict = await _dbService.conflicts
        .filter()
        .idEqualTo(id.trim())
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
    if (conflict == null) {
      return;
    }

    await _dbService.db.writeTxn(() async {
      conflict
        ..resolved = true
        ..resolutionStrategy = _parseResolutionStrategy(strategy)
        ..resolvedBy = _normalizeText(resolvedBy, fallback: 'system')
        ..resolvedAt = DateTime.now()
        ..updatedAt = DateTime.now();
      await _dbService.conflicts.put(conflict);
    });
  }

  Future<void> deleteResolvedConflicts() async {
    final conflicts = await _dbService.conflicts
        .filter()
        .resolvedEqualTo(true)
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    if (conflicts.isEmpty) {
      return;
    }

    await _dbService.db.writeTxn(() async {
      for (final conflict in conflicts) {
        conflict
          ..isDeleted = true
          ..deletedAt = DateTime.now()
          ..updatedAt = DateTime.now();
        await _dbService.conflicts.put(conflict);
      }
    });
  }

  Future<void> saveSyncMetric(SyncMetricEntity metric) async {
    final id = _ensureId(metric);
    final existing = await _dbService.syncMetrics.getById(id);

    metric
      ..id = id
      ..metricId = _normalizeText(metric.metricId, fallback: id)
      ..userId = _normalizeText(metric.userId, fallback: 'system')
      ..entityType = _normalizeText(metric.entityType)
      ..timestamp = existing?.timestamp ?? _resolveDate(() => metric.timestamp)
      ..createdAt = existing?.createdAt ?? _resolveDate(() => metric.createdAt);

    await _saveEntity(
      entity: metric,
      existing: existing,
      collectionName: CollectionRegistry.syncMetrics,
      payload: metric.toJson(),
      persist: () async {
        await _dbService.syncMetrics.put(metric);
      },
    );
  }

  Future<List<SyncMetricEntity>> getRecentMetrics(int limit) async {
    final metrics = await _dbService.syncMetrics
        .filter()
        .isDeletedEqualTo(false)
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();
    return metrics;
  }

  Future<List<SyncMetricEntity>> getMetricsByEntity(String entityType) async {
    final metrics = await _dbService.syncMetrics
        .filter()
        .entityTypeEqualTo(entityType.trim())
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    metrics.sort((left, right) => right.timestamp.compareTo(left.timestamp));
    return metrics;
  }

  Future<List<SyncMetricEntity>> getFailedSyncs() async {
    final metrics = await _dbService.syncMetrics
        .filter()
        .successEqualTo(false)
        .and()
        .isDeletedEqualTo(false)
        .findAll();
    metrics.sort((left, right) => right.timestamp.compareTo(left.timestamp));
    return metrics;
  }

  Future<void> deleteOldMetrics(int daysOld) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysOld));
    final metrics = await _dbService.syncMetrics
        .filter()
        .timestampLessThan(cutoff)
        .findAll();
    if (metrics.isEmpty) {
      return;
    }

    await _dbService.db.writeTxn(() async {
      await _dbService.syncMetrics.deleteAll(
        metrics.map((metric) => metric.isarId).toList(growable: false),
      );
    });
  }

  Future<AlertEntity?> _getAlertByAnyId(String rawId) async {
    final normalizedId = rawId.trim();
    if (normalizedId.isEmpty) {
      return null;
    }

    final byId = await _dbService.alerts.getById(normalizedId);
    if (byId != null) {
      return byId;
    }

    return _dbService.alerts
        .filter()
        .alertIdEqualTo(normalizedId)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<void> _saveEntity({
    required BaseEntity entity,
    required BaseEntity? existing,
    required String collectionName,
    required Map<String, dynamic> payload,
    required Future<void> Function() persist,
  }) async {
    final deviceId = await _deviceIdService.getDeviceId();
    final now = DateTime.now();
    _applySyncStamp(entity, existing: existing, deviceId: deviceId, now: now);
    await _dbService.db.writeTxn(() async {
      await persist();
    });
    await _enqueue(
      collectionName,
      entity.id,
      existing == null ? 'create' : 'update',
      payload,
    );
    await _syncIfOnline();
  }

  Future<void> _softDeleteEntity({
    required BaseEntity entity,
    required String collectionName,
    required Map<String, dynamic> Function() payloadBuilder,
    required Future<void> Function() persist,
  }) async {
    entity
      ..isDeleted = true
      ..deletedAt = DateTime.now();

    final deviceId = await _deviceIdService.getDeviceId();
    _applyDeletedStamp(entity, deviceId: deviceId, now: DateTime.now());
    await _dbService.db.writeTxn(() async {
      await persist();
    });
    await _enqueue(collectionName, entity.id, 'delete', payloadBuilder());
    await _syncIfOnline();
  }

  void _applySyncStamp(
    BaseEntity entity, {
    required BaseEntity? existing,
    required String deviceId,
    required DateTime now,
  }) {
    entity
      ..updatedAt = now
      ..deletedAt = entity.isDeleted ? entity.deletedAt : null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = deviceId;
  }

  void _applyDeletedStamp(
    BaseEntity entity, {
    required String deviceId,
    required DateTime now,
  }) {
    entity
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = deviceId;
  }

  Future<void> _enqueue(
    String collectionName,
    String documentId,
    String operation,
    Map<String, dynamic> payload,
  ) {
    return _syncQueueService.addToQueue(
      collectionName: collectionName,
      documentId: documentId,
      operation: operation,
      payload: payload,
    );
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }

  DateTime _resolveDate(DateTime Function() reader) {
    try {
      return reader();
    } catch (_) {
      return DateTime.now();
    }
  }

  String _ensureId(BaseEntity entity) {
    final current = entity.id.trim();
    if (current.isNotEmpty) {
      return current;
    }
    final generated = _uuid.v4();
    entity.id = generated;
    return generated;
  }

  String _normalizeText(String? value, {String fallback = ''}) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? fallback : normalized;
  }

  ResolutionStrategy _parseResolutionStrategy(String value) {
    final normalized = value.trim().toLowerCase();
    for (final candidate in ResolutionStrategy.values) {
      if (candidate.name.toLowerCase() == normalized) {
        return candidate;
      }
    }
    return ResolutionStrategy.pending;
  }

  List<AlertEntity> _sortAlerts(List<AlertEntity> alerts) {
    alerts.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return alerts;
  }

  List<AuditLogEntity> _sortAuditLogs(List<AuditLogEntity> logs) {
    logs.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return logs;
  }

  List<ConflictEntity> _sortConflicts(List<ConflictEntity> conflicts) {
    conflicts.sort(
      (left, right) => right.conflictDate.compareTo(left.conflictDate),
    );
    return conflicts;
  }
}
