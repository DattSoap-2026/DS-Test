import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/isar_service.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../../features/inventory/models/sync_queue.dart';
import '../../services/database_service.dart';
import '../local/base_entity.dart';
import '../local/entities/duty_session_entity.dart';

/// Isar-first repository for duty session data.
class DutyRepository {
  DutyRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  static const Uuid _uuid = Uuid();
  static const Duration _gpsDebounce = Duration(seconds: 30);

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  /// Saves a duty session locally first, then enqueues it for sync.
  Future<void> saveDutySession(DutySessionEntity session) async {
    final now = DateTime.now();
    final id = _ensureId(session);
    final existing = await _dbService.dutySessions.getById(id);

    session
      ..id = id
      ..createdAt = _safeString(
        () => session.createdAt,
        fallback: existing?.createdAt ?? now.toIso8601String(),
      )
      ..status = _safeString(() => session.status, fallback: 'active')
      ..alerts = List<String>.from(session.alerts);

    await _stampForSync(session, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.dutySessions.put(session);
    });

    await _enqueue(
      session.id,
      existing == null ? 'create' : 'update',
      session.toJson(),
    );
    await _syncIfOnline();
  }

  /// Returns a duty session by id when it is not soft-deleted.
  Future<DutySessionEntity?> getDutySessionById(String id) {
    return _dbService.dutySessions
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Returns the active duty session for a user or null when none exists.
  Future<DutySessionEntity?> getActiveSession(String userId) {
    return _dbService.dutySessions
        .filter()
        .userIdEqualTo(userId)
        .and()
        .statusEqualTo('active')
        .and()
        .isDeletedEqualTo(false)
        .sortByLoginTimeDesc()
        .findFirst();
  }

  /// Returns duty sessions for a user from Isar only.
  Future<List<DutySessionEntity>> getSessionsByUser(String userId) {
    return _dbService.dutySessions
        .filter()
        .userIdEqualTo(userId)
        .and()
        .isDeletedEqualTo(false)
        .sortByLoginTimeDesc()
        .findAll();
  }

  /// Returns duty sessions for a date from Isar only.
  Future<List<DutySessionEntity>> getSessionsByDate(DateTime date) {
    final key = date.toIso8601String().split('T').first;
    return _dbService.dutySessions
        .filter()
        .dateEqualTo(key)
        .and()
        .isDeletedEqualTo(false)
        .sortByLoginTimeDesc()
        .findAll();
  }

  /// Returns all duty sessions from Isar only.
  Future<List<DutySessionEntity>> getAllDutySessions() {
    return _dbService.dutySessions
        .filter()
        .isDeletedEqualTo(false)
        .sortByLoginTimeDesc()
        .findAll();
  }

  /// Streams the active duty session for a user from Isar only.
  Stream<DutySessionEntity?> watchActiveSession(String userId) {
    return _dbService.dutySessions
        .filter()
        .userIdEqualTo(userId)
        .and()
        .isDeletedEqualTo(false)
        .sortByLoginTimeDesc()
        .watch(fireImmediately: true)
        .map((sessions) {
          for (final session in sessions) {
            if (session.status == 'active') {
              return session;
            }
          }
          return null;
        });
  }

  /// Starts a duty session after ensuring there is no active session for the user.
  Future<void> startDuty(DutySessionEntity session) async {
    final existing = await getActiveSession(session.userId);
    if (existing != null) {
      throw StateError('Active duty session already exists for user');
    }
    await saveDutySession(session);
  }

  /// Ends a duty session locally first, then enqueues the update.
  Future<void> endDuty(
    String sessionId,
    DateTime logoutTime,
    double? logoutLat,
    double? logoutLng,
    double totalDistanceKm,
  ) async {
    final session = await _dbService.dutySessions.getById(sessionId);
    if (session == null || session.isDeleted) {
      return;
    }

    session
      ..status = 'completed'
      ..logoutTime = logoutTime.toIso8601String()
      ..logoutLatitude = logoutLat
      ..logoutLongitude = logoutLng
      ..totalDistanceKm = totalDistanceKm;

    await _stampForSync(session, session);
    await _dbService.db.writeTxn(() async {
      await _dbService.dutySessions.put(session);
    });

    await _enqueue(session.id, 'update', session.toJson());
    await _syncIfOnline();
  }

  /// Updates the latest GPS location and debounces queue churn to 30 seconds.
  Future<void> updateGpsLocation(String sessionId, double lat, double lng) async {
    final session = await _dbService.dutySessions.getById(sessionId);
    if (session == null || session.isDeleted) {
      return;
    }

    session
      ..baseLatitude = lat
      ..baseLongitude = lng;
    await _stampForSync(session, session);
    await _dbService.db.writeTxn(() async {
      await _dbService.dutySessions.put(session);
    });

    final existingQueue = await IsarService.instance.syncQueues
        .filter()
        .collectionNameEqualTo(CollectionRegistry.dutySessions)
        .and()
        .documentIdEqualTo(sessionId)
        .and()
        .isFailedEqualTo(false)
        .findFirst();
    final withinDebounce = _isWithinGpsDebounce(existingQueue);

    await _enqueue(session.id, 'update', session.toJson());
    if (!withinDebounce) {
      await _syncIfOnline();
    }
  }

  /// Soft-deletes completed duty sessions older than the provided age.
  Future<void> deleteOldSessions(int daysOld) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysOld));
    final sessions = await _dbService.dutySessions
        .filter()
        .statusEqualTo('completed')
        .and()
        .isDeletedEqualTo(false)
        .findAll();

    final stale = sessions.where((session) {
      final endedAt = DateTime.tryParse(session.logoutTime ?? '') ??
          DateTime.tryParse(session.loginTime) ??
          session.updatedAt;
      return endedAt.isBefore(cutoff);
    }).toList(growable: false);

    if (stale.isEmpty) {
      return;
    }

    for (final session in stale) {
      session
        ..isDeleted = true
        ..deletedAt = DateTime.now();
      await _stampDeleted(session);
    }

    await _dbService.db.writeTxn(() async {
      await _dbService.dutySessions.putAll(stale);
    });

    for (final session in stale) {
      await _enqueue(session.id, 'delete', session.toJson());
    }
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

  Future<void> _stampDeleted(BaseEntity entity) async {
    entity
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1
      ..deviceId = await _deviceIdService.getDeviceId();
  }

  Future<void> _enqueue(
    String documentId,
    String operation,
    Map<String, dynamic> payload,
  ) {
    return _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.dutySessions,
      documentId: documentId,
      operation: operation,
      payload: payload,
    );
  }

  bool _isWithinGpsDebounce(SyncQueue? queueItem) {
    if (queueItem == null) {
      return false;
    }
    try {
      final payload = jsonDecode(queueItem.payload) as Map<String, dynamic>;
      final timestampRaw = payload['updatedAt'] ?? payload['lastModified'];
      final timestamp = DateTime.tryParse(timestampRaw?.toString() ?? '');
      if (timestamp == null) {
        return false;
      }
      return DateTime.now().difference(timestamp) < _gpsDebounce;
    } catch (_) {
      return false;
    }
  }

  String _ensureId(BaseEntity entity) {
    try {
      final current = entity.id.trim();
      if (current.isNotEmpty) {
        return current;
      }
    } catch (_) {
      // Late init fallback.
    }
    final generated = _uuid.v4();
    entity.id = generated;
    return generated;
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
