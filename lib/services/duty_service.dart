import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_service.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'gps_service.dart';
import 'package:isar/isar.dart';
import '../data/local/entities/duty_session_entity.dart';
import '../data/local/base_entity.dart';
import '../data/repositories/duty_repository.dart';
import '../data/local/entities/settings_cache_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import 'database_service.dart';
import 'outbox_codec.dart';
import '../utils/app_logger.dart';
import 'package:uuid/uuid.dart';

const dutySessionsCollection = 'duty_sessions';
const dutySettingsDoc = 'public_settings/duty_settings';
const vehiclesCollection = 'vehicles';

// Models
class DutySession {
  final String id;
  final String userId;
  final String? employeeId; // [NEW] Link to Employee record
  final String userName;
  final String userRole; // 'Driver' | 'Salesman'
  final String
  status; // 'active', 'completed', 'auto_closed', 'onroute_after_duty'
  final String date;
  final String loginTime;
  final double loginLatitude;
  final double loginLongitude;
  final bool gpsEnabled;
  final List<DutyAlert> alerts;
  final String createdAt;
  final String updatedAt;

  // Optional / End Data
  final String? logoutTime;
  final double? logoutLatitude;
  final double? logoutLongitude;
  final double? totalDistanceKm;
  final String? vehicleId;
  final String? vehicleNumber;
  final String? routeName;
  final double? startOdometer;
  final double? endOdometer;
  final bool? gpsAutoOff;
  final int? overtimeMinutes;
  final bool? isOvertime;
  final String? autoStopReason;
  // Advanced tracking fields
  final double? baseLatitude;
  final double? baseLongitude;
  final String? dutyEndTime;

  DutySession({
    required this.id,
    required this.userId,
    this.employeeId,
    required this.userName,
    required this.userRole,
    required this.status,
    required this.date,
    required this.loginTime,
    required this.loginLatitude,
    required this.loginLongitude,
    required this.gpsEnabled,
    required this.alerts,
    required this.createdAt,
    required this.updatedAt,
    this.logoutTime,
    this.logoutLatitude,
    this.logoutLongitude,
    this.totalDistanceKm,
    this.vehicleId,
    this.vehicleNumber,
    this.routeName,
    this.startOdometer,
    this.endOdometer,
    this.gpsAutoOff,
    this.overtimeMinutes,
    this.isOvertime,
    this.autoStopReason,
    this.baseLatitude,
    this.baseLongitude,
    this.dutyEndTime,
  });

  factory DutySession.fromJson(Map<String, dynamic> json) {
    return DutySession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      employeeId: json['employeeId'] as String?,
      userName: json['userName'] as String,
      userRole: json['userRole'] as String,
      status: json['status'] as String,
      date: json['date'] as String,
      loginTime: json['loginTime'] as String,
      loginLatitude: (json['loginLatitude'] as num).toDouble(),
      loginLongitude: (json['loginLongitude'] as num).toDouble(),
      gpsEnabled: json['gpsEnabled'] as bool? ?? false,
      alerts:
          (json['alerts'] as List?)
              ?.map((a) => DutyAlert.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      logoutTime: json['logoutTime'] as String?,
      logoutLatitude: (json['logoutLatitude'] as num?)?.toDouble(),
      logoutLongitude: (json['logoutLongitude'] as num?)?.toDouble(),
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble(),
      vehicleId: json['vehicleId'] as String?,
      vehicleNumber: json['vehicleNumber'] as String?,
      routeName: json['routeName'] as String?,
      startOdometer: (json['startOdometer'] as num?)?.toDouble(),
      endOdometer: (json['endOdometer'] as num?)?.toDouble(),
      gpsAutoOff: json['gpsAutoOff'] as bool?,
      overtimeMinutes: (json['overtimeMinutes'] as num?)?.toInt(),
      isOvertime: json['isOvertime'] as bool?,
      autoStopReason: json['autoStopReason'] as String?,
      baseLatitude: (json['baseLatitude'] as num?)?.toDouble(),
      baseLongitude: (json['baseLongitude'] as num?)?.toDouble(),
      dutyEndTime: json['dutyEndTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      if (employeeId != null) 'employeeId': employeeId,
      'userName': userName,
      'userRole': userRole,
      'status': status,
      'date': date,
      'loginTime': loginTime,
      'loginLatitude': loginLatitude,
      'loginLongitude': loginLongitude,
      'gpsEnabled': gpsEnabled,
      'alerts': alerts.map((a) => a.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (logoutTime != null) 'logoutTime': logoutTime,
      if (logoutLatitude != null) 'logoutLatitude': logoutLatitude,
      if (logoutLongitude != null) 'logoutLongitude': logoutLongitude,
      if (totalDistanceKm != null) 'totalDistanceKm': totalDistanceKm,
      if (vehicleId != null) 'vehicleId': vehicleId,
      if (vehicleNumber != null) 'vehicleNumber': vehicleNumber,
      if (routeName != null) 'routeName': routeName,
      if (startOdometer != null) 'startOdometer': startOdometer,
      if (endOdometer != null) 'endOdometer': endOdometer,
      if (gpsAutoOff != null) 'gpsAutoOff': gpsAutoOff,
      if (overtimeMinutes != null) 'overtimeMinutes': overtimeMinutes,
      if (isOvertime != null) 'isOvertime': isOvertime,
      if (autoStopReason != null) 'autoStopReason': autoStopReason,
      if (baseLatitude != null) 'baseLatitude': baseLatitude,
      if (baseLongitude != null) 'baseLongitude': baseLongitude,
      if (dutyEndTime != null) 'dutyEndTime': dutyEndTime,
    };
  }
}

class DutyAlert {
  final String id;
  final String type;
  final String message;
  final String timestamp;
  final bool acknowledged;

  DutyAlert({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.acknowledged,
  });

  factory DutyAlert.fromJson(Map<String, dynamic> json) {
    return DutyAlert(
      id: json['id'] as String? ?? '',
      type: json['type'] as String,
      message: json['message'] as String,
      timestamp: json['timestamp'] as String,
      acknowledged: json['acknowledged'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'type': type,
      'message': message,
      'timestamp': timestamp,
      'acknowledged': acknowledged,
    };
  }
}

class DutySettings {
  final DutyGlobalSettings globalSettings;
  final DutyAdvancedTracking advancedTracking;
  final Map<String, RoleDutySettings> roleSettings;
  final List<SundayOverride> sundayOverrides;

  DutySettings({
    required this.globalSettings,
    required this.advancedTracking,
    required this.roleSettings,
    required this.sundayOverrides,
  });

  factory DutySettings.defaults() {
    return DutySettings(
      globalSettings: DutyGlobalSettings(),
      advancedTracking: DutyAdvancedTracking(),
      roleSettings: {},
      sundayOverrides: [],
    );
  }

  factory DutySettings.fromJson(Map<String, dynamic> json) {
    return DutySettings(
      globalSettings: DutyGlobalSettings.fromJson(
        json['globalSettings'] as Map<String, dynamic>? ?? {},
      ),
      advancedTracking: DutyAdvancedTracking.fromJson(
        json['advancedTracking'] as Map<String, dynamic>? ?? {},
      ),
      roleSettings: (json['roleSettings'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(
          key,
          RoleDutySettings.fromJson(value as Map<String, dynamic>),
        ),
      ),
      sundayOverrides:
          (json['sundayOverrides'] as List?)
              ?.map((e) => SundayOverride.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'globalSettings': globalSettings.toJson(),
      'advancedTracking': advancedTracking.toJson(),
      'roleSettings': roleSettings.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'sundayOverrides': sundayOverrides.map((e) => e.toJson()).toList(),
    };
  }
}

class DutyGlobalSettings {
  String defaultStartTime;
  String defaultEndTime;
  List<int> workingDays;
  bool autoGpsOff;
  int gpsPollingIntervalMs;
  int idleThresholdMinutes;
  int staleLocationMinutes;

  DutyGlobalSettings({
    this.defaultStartTime = '08:00',
    this.defaultEndTime = '20:00',
    this.workingDays = const [1, 2, 3, 4, 5, 6],
    this.autoGpsOff = false,
    this.gpsPollingIntervalMs = 30000,
    this.idleThresholdMinutes = 5,
    this.staleLocationMinutes = 10,
  });

  factory DutyGlobalSettings.fromJson(Map<String, dynamic> json) {
    return DutyGlobalSettings(
      defaultStartTime: json['defaultStartTime'] ?? '08:00',
      defaultEndTime: json['defaultEndTime'] ?? '20:00',
      workingDays: List<int>.from(json['workingDays'] ?? [1, 2, 3, 4, 5, 6]),
      autoGpsOff: json['autoGpsOff'] ?? false,
      gpsPollingIntervalMs: json['gpsPollingIntervalMs'] ?? 30000,
      idleThresholdMinutes: json['idleThresholdMinutes'] ?? 5,
      staleLocationMinutes: json['staleLocationMinutes'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultStartTime': defaultStartTime,
      'defaultEndTime': defaultEndTime,
      'workingDays': workingDays,
      'autoGpsOff': autoGpsOff,
      'gpsPollingIntervalMs': gpsPollingIntervalMs,
      'idleThresholdMinutes': idleThresholdMinutes,
      'staleLocationMinutes': staleLocationMinutes,
    };
  }
}

class DutyAdvancedTracking {
  int baseReturnRadiusMeters;
  double baseReturnSpeedKmh;
  int stationaryMinutesRequired;
  String maxTrackingCutoffTime;
  bool continueTrackingAfterDutyEnd;
  bool overtimeAlertEnabled;
  int maxOvertimeMinutes;
  bool enableSmartAutoStop;

  DutyAdvancedTracking({
    this.baseReturnRadiusMeters = 300,
    this.baseReturnSpeedKmh = 5.0,
    this.stationaryMinutesRequired = 10,
    this.maxTrackingCutoffTime = '23:00',
    this.continueTrackingAfterDutyEnd = true,
    this.overtimeAlertEnabled = true,
    this.maxOvertimeMinutes = 300,
    this.enableSmartAutoStop = true,
  });

  factory DutyAdvancedTracking.fromJson(Map<String, dynamic> json) {
    return DutyAdvancedTracking(
      baseReturnRadiusMeters: json['baseReturnRadiusMeters'] ?? 300,
      baseReturnSpeedKmh: (json['baseReturnSpeedKmh'] as num? ?? 5.0)
          .toDouble(),
      stationaryMinutesRequired: json['stationaryMinutesRequired'] ?? 10,
      maxTrackingCutoffTime: json['maxTrackingCutoffTime'] ?? '23:00',
      continueTrackingAfterDutyEnd:
          json['continueTrackingAfterDutyEnd'] ?? true,
      overtimeAlertEnabled: json['overtimeAlertEnabled'] ?? true,
      maxOvertimeMinutes: json['maxOvertimeMinutes'] ?? 300,
      enableSmartAutoStop: json['enableSmartAutoStop'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseReturnRadiusMeters': baseReturnRadiusMeters,
      'baseReturnSpeedKmh': baseReturnSpeedKmh,
      'stationaryMinutesRequired': stationaryMinutesRequired,
      'maxTrackingCutoffTime': maxTrackingCutoffTime,
      'continueTrackingAfterDutyEnd': continueTrackingAfterDutyEnd,
      'overtimeAlertEnabled': overtimeAlertEnabled,
      'maxOvertimeMinutes': maxOvertimeMinutes,
      'enableSmartAutoStop': enableSmartAutoStop,
    };
  }
}

class RoleDutySettings {
  String startTime;
  String endTime;
  bool? requireVehicle;
  bool? requireRoute;

  RoleDutySettings({
    this.startTime = '08:00',
    this.endTime = '20:00',
    this.requireVehicle,
    this.requireRoute,
  });

  factory RoleDutySettings.fromJson(Map<String, dynamic> json) {
    return RoleDutySettings(
      startTime: json['startTime'] ?? '08:00',
      endTime: json['endTime'] ?? '20:00',
      requireVehicle: json['requireVehicle'],
      requireRoute: json['requireRoute'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      if (requireVehicle != null) 'requireVehicle': requireVehicle,
      if (requireRoute != null) 'requireRoute': requireRoute,
    };
  }
}

class SundayOverride {
  String date;
  List<String> allowedUserIds;
  String reason;
  String? approvedBy;
  String? approvedAt;

  SundayOverride({
    required this.date,
    required this.allowedUserIds,
    required this.reason,
    this.approvedBy,
    this.approvedAt,
  });

  factory SundayOverride.fromJson(Map<String, dynamic> json) {
    return SundayOverride(
      date: json['date'] ?? '',
      allowedUserIds: List<String>.from(json['allowedUserIds'] ?? []),
      reason: json['reason'] ?? '',
      approvedBy: json['approvedBy'],
      approvedAt: json['approvedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'allowedUserIds': allowedUserIds,
      'reason': reason,
      if (approvedBy != null) 'approvedBy': approvedBy,
      if (approvedAt != null) 'approvedAt': approvedAt,
    };
  }
}

class DutyService extends BaseService {
  final GpsService _gpsService;
  final DatabaseService _dbService;
  late final DutyRepository _dutyRepository;
  static const String _collection = dutySessionsCollection;
  static const String _dutySettingsCacheKey = 'duty_settings';

  DutyService(super._firebase, this._gpsService, this._dbService) {
    _dutyRepository = DutyRepository(_dbService);
  }

  int? _parseClockToMinutes(String? value) {
    final raw = value?.trim() ?? '';
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw);
    if (match == null) return null;
    final hours = int.tryParse(match.group(1)!);
    final minutes = int.tryParse(match.group(2)!);
    if (hours == null || minutes == null) return null;
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) return null;
    return hours * 60 + minutes;
  }

  Future<void> _cacheDutySettingsData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_duty_settings', jsonEncode(data));

    final entry = SettingsCacheEntity()
      ..key = _dutySettingsCacheKey
      ..payloadJson = jsonEncode(data);
    await _dbService.db.writeTxn(() async {
      await _dbService.settingsCache.put(entry);
    });
  }

  Future<DutySettings?> _readDutySettingsFromCache() async {
    try {
      final entry = await _dbService.settingsCache
          .filter()
          .keyEqualTo(_dutySettingsCacheKey)
          .findFirst();
      if (entry != null) {
        final decoded = jsonDecode(entry.payloadJson);
        if (decoded is Map<String, dynamic>) {
          return DutySettings.fromJson(decoded);
        }
        if (decoded is Map) {
          return DutySettings.fromJson(Map<String, dynamic>.from(decoded));
        }
      }
    } catch (e) {
      AppLogger.warning(
        'DutySettings: Failed to read Isar cache ($e). Falling back.',
        tag: 'Duty',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final localJson = prefs.getString('local_duty_settings');
    if (localJson == null) return null;
    return DutySettings.fromJson(jsonDecode(localJson));
  }

  String _resolveDutyEndTimeForRole(DutySettings settings, String role) {
    return settings.roleSettings[role]?.endTime ??
        settings.globalSettings.defaultEndTime;
  }

  Future<void> _enqueueOutbox(
    Map<String, dynamic> payload, {
    String action = 'set',
    String collection = _collection,
    String? explicitRecordKey,
  }) async {
    final queueId = OutboxCodec.buildQueueId(
      collection,
      payload,
      explicitRecordKey: explicitRecordKey ?? payload['id']?.toString(),
    );
    final existing = await _dbService.syncQueue.getById(queueId);
    final now = DateTime.now();
    final existingMeta = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          ).meta;
    final queueEntity = SyncQueueEntity()
      ..id = queueId
      ..collection = collection
      ..action = action
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: payload,
        existingMeta: existingMeta,
        now: now,
        resetRetryState: true,
      )
      ..createdAt = existing?.createdAt ?? now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;
    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.put(queueEntity);
    });
  }

  Future<void> _dequeueOutbox(String queueId) async {
    final existing = await _dbService.syncQueue.getById(queueId);
    if (existing == null) return;
    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.delete(existing.isarId);
    });
  }

  Stream<List<DutySession>> subscribeToDateDutySessions(String date) {
    // Offline-first: UI listens only to local cache. Remote refresh is background best-effort.
    unawaited(_refreshDutySessionsForDateInBackground(date));
    return _dbService.dutySessions
        .filter()
        .dateEqualTo(date)
        .sortByLoginTimeDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map((e) => e.toDomain()).toList());
  }

  Future<void> _refreshDutySessionsForDateInBackground(String date) async {
    final firestore = db;
    if (firestore == null) return;

    try {
      final snapshot = await firestore
          .collection(dutySessionsCollection)
          .where('date', isEqualTo: date)
          .get();
      if (snapshot.docs.isEmpty) return;

      await _dbService.db.writeTxn(() async {
        for (final doc in snapshot.docs) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;

          try {
            final remoteModel = DutySession.fromJson(data);
            final existing = await _dbService.dutySessions.getById(
              remoteModel.id,
            );
            if (existing != null && existing.syncStatus == SyncStatus.pending) {
              // Keep local unsynced edits authoritative until SyncManager resolves them.
              continue;
            }
            final entity = DutySessionEntity.fromDomain(remoteModel);
            entity.syncStatus = SyncStatus.synced;
            await _dbService.dutySessions.put(entity);
          } catch (e) {
            AppLogger.warning(
              'Skipping malformed duty session ${doc.id}: $e',
              tag: 'Duty',
            );
          }
        }
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        AppLogger.warning(
          'Duty background refresh blocked by permissions for $date',
          tag: 'Duty',
        );
        return;
      }
      AppLogger.warning('Duty background refresh failed: $e', tag: 'Duty');
    } catch (e) {
      AppLogger.warning('Duty background refresh failed: $e', tag: 'Duty');
    }
  }

  Future<DutySettings> getDutySettings() async {
    try {
      final firestore = db;
      // 1. Try Online First
      if (firestore != null) {
        try {
          final docSnap = await firestore.doc(dutySettingsDoc).get();
          if (docSnap.exists) {
            final data = docSnap.data() ?? {};
            final settings = DutySettings.fromJson(data);

            // Cache locally
            await _cacheDutySettingsData(data);

            return settings;
          }
        } catch (e) {
          AppLogger.warning(
            'DutySettings: Failed to fetch online ($e). Trying local cache.',
            tag: 'Duty',
          );
          // Fallthrough to local
        }
      }

      // 2. Try Local Cache
      final cached = await _readDutySettingsFromCache();
      if (cached != null) {
        AppLogger.info('DutySettings: Loaded from local cache.', tag: 'Duty');
        return cached;
      }
    } catch (e) {
      handleError(e, 'getDutySettings');
    }

    // 3. Defaults
    AppLogger.warning(
      'DutySettings: No source available. Using defaults.',
      tag: 'Duty',
    );
    return DutySettings.defaults();
  }

  Future<bool> updateDutySettings(
    DutySettings settings,
    String updatedBy,
  ) async {
    try {
      final data = settings.toJson();
      data['id'] = 'duty_settings';
      data['updatedAt'] = DateTime.now().toIso8601String();
      data['updatedBy'] = updatedBy;

      // Queue durable outbox first for offline-safe persistence.
      final queueId = OutboxCodec.buildQueueId(
        'public_settings',
        data,
        explicitRecordKey: 'duty_settings',
      );
      await _enqueueOutbox(
        data,
        action: 'set',
        collection: 'public_settings',
        explicitRecordKey: 'duty_settings',
      );

      // Best-effort immediate sync when online.
      final firestore = db;
      if (firestore != null) {
        try {
          final remoteData = Map<String, dynamic>.from(data)..remove('id');
          await firestore
              .doc(dutySettingsDoc)
              .set(remoteData, SetOptions(merge: true));
          await _dequeueOutbox(queueId);
        } catch (_) {
          // Keep queued item for SyncManager retry.
        }
      }

      // Update Local Cache immediately
      await _cacheDutySettingsData(data);

      return true;
    } catch (e) {
      handleError(e, 'updateDutySettings');
      return false;
    }
  }

  // Check if user can start duty
  Future<Map<String, dynamic>> checkDutyTimeRules({
    required String userId,
    required String role,
  }) async {
    try {
      // Retrieve settings (Online -> Cache -> Defaults)
      DutySettings settings;
      try {
        settings = await getDutySettings();
      } catch (e) {
        settings = DutySettings.defaults();
      }

      final firestore = db;
      // We can skip firestore user check if offline

      // ... logic is same ... but if firestore is null?
      // 1. Check assignments (Firestore only currently)
      if (firestore != null) {
        final userDoc = await firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          if (role == 'Driver' &&
              (settings.roleSettings['Driver']?.requireVehicle ?? false)) {
            if (userData?['assignedVehicleId'] == null) {
              return {
                'canStart': false,
                'message': 'No vehicle assigned. Please contact admin.',
              };
            }
          }
          if (role == 'Salesman' &&
              (settings.roleSettings['Salesman']?.requireRoute ?? false)) {
            final assignedRoutes = (userData?['assignedRoutes'] as List? ?? [])
                .map((e) => e?.toString() ?? '')
                .where((e) => e.trim().isNotEmpty)
                .toList();
            final hasRoute =
                assignedRoutes.isNotEmpty ||
                (userData?['assignedSalesRoute']?.toString().trim().isNotEmpty ??
                    false) ||
                (userData?['assignedDeliveryRoute']?.toString().trim().isNotEmpty ??
                    false);
            if (!hasRoute) {
              return {
                'canStart': false,
                'message': 'No route assigned. Please contact admin.',
              };
            }
          }
        }
      }

      // 2. Check Working Day
      final now = DateTime.now();
      final dayOfWeek = now.weekday;
      final jsDay = dayOfWeek == 7 ? 0 : dayOfWeek;

      final isWorkingToday = settings.globalSettings.workingDays.contains(
        jsDay,
      );

      if (!isWorkingToday) {
        final todayStr = now.toIso8601String().split('T')[0];
        final override = settings.sundayOverrides.firstWhere(
          (o) => o.date == todayStr && o.allowedUserIds.contains(userId),
          orElse: () =>
              SundayOverride(date: '', allowedUserIds: [], reason: ''),
        );

        if (override.date.isNotEmpty) {
          return {
            'canStart': true,
            'message': 'Working on override: ${override.reason}',
          };
        }
        return {
          'canStart': false,
          'message': 'Today is a day off. Contact admin for override.',
        };
      }

      // 3. Check Duty Hours
      final roleSettings = settings.roleSettings[role];
      final startTimeStr =
          roleSettings?.startTime ?? settings.globalSettings.defaultStartTime;
      final endTimeStr =
          roleSettings?.endTime ?? settings.globalSettings.defaultEndTime;
      final startMinutes = _parseClockToMinutes(startTimeStr) ?? (8 * 60);
      final endMinutes = _parseClockToMinutes(endTimeStr) ?? (20 * 60);
      final currentMinutes = now.hour * 60 + now.minute;
      final crossesMidnight = startMinutes > endMinutes;
      final withinWindow = crossesMidnight
          ? currentMinutes >= startMinutes || currentMinutes <= endMinutes
          : currentMinutes >= startMinutes && currentMinutes <= endMinutes;

      if (!withinWindow) {
        final beforeStart = crossesMidnight
            ? currentMinutes > endMinutes && currentMinutes < startMinutes
            : currentMinutes < startMinutes;
        if (beforeStart) {
          return {
            'canStart': false,
            'message': 'Duty starts at $startTimeStr. Please wait.',
          };
        }
        return {'canStart': false, 'message': 'Duty has ended at $endTimeStr.'};
      }

      return {'canStart': true, 'message': 'Ready to start duty'};
    } catch (e) {
      // If error (e.g. offline), we should log but maybe allow basic duty if critical?
      // Or return error message.
      return {'canStart': false, 'message': 'Check failed: $e'};
    }
  }

  Future<DutySession?> getActiveDutySession(String userId) async {
    try {
      // LOCAL FIRST
      final localSession = await _dbService.dutySessions
          .filter()
          .userIdEqualTo(userId)
          .statusEqualTo('active')
          .sortByLoginTimeDesc()
          .findFirst();

      if (localSession != null) {
        return localSession.toDomain();
      }

      // If nothing local, should we check remote?
      // If we are strictly offline-first, local is the truth.
      // If data was cleared, we might want to fetch from server on init.
      // But SyncManager should handle population.
      return null;
    } catch (e) {
      handleError(e, 'getActiveDutySession');
      return null;
    }
  }

  Future<bool> checkCompanyGeoFence(double lat, double lng) async {
    const double companyLat = 23.0225;
    const double companyLng = 72.5714;
    const double radiusKm = 0.5;

    final distance = _gpsService.calculateDistance(
      lat,
      lng,
      companyLat,
      companyLng,
    );
    return distance <= radiusKm;
  }

  Future<String?> startDutySession(Map<String, dynamic> sessionData) async {
    try {
      final userId = sessionData['userId'];
      final role = sessionData['userRole'];

      // Validation
      final rules = await checkDutyTimeRules(userId: userId, role: role);
      if (rules['canStart'] == false) {
        // If offline and check failed due to being offline, we might want to bypass?
        // But for now, respect the check.
        throw Exception(rules['message']);
      }

      final active = await getActiveDutySession(userId);
      if (active != null) {
        return active.id;
      }

      final now = DateTime.now().toIso8601String();
      final id = const Uuid().v4();
      String? dutyEndTime;
      try {
        final settings = await getDutySettings();
        dutyEndTime = _resolveDutyEndTimeForRole(settings, role);
      } catch (_) {
        dutyEndTime = null;
      }

      final sessionModel = DutySession(
        id: id,
        userId: userId,
        employeeId: sessionData['employeeId'],
        userName: sessionData['userName'],
        userRole: role,
        status: 'active',
        date: sessionData['date'] ?? now.split('T')[0],
        loginTime: sessionData['loginTime'] ?? now,
        loginLatitude: sessionData['loginLatitude'] ?? 0.0,
        loginLongitude: sessionData['loginLongitude'] ?? 0.0,
        gpsEnabled: sessionData['gpsEnabled'] ?? true,
        alerts: [],
        createdAt: now,
        updatedAt: now,
        vehicleId: sessionData['vehicleId'],
        vehicleNumber: sessionData['vehicleNumber'],
        routeName: sessionData['routeName'],
        dutyEndTime: dutyEndTime,
        startOdometer:
            double.tryParse(sessionData['startOdometer']?.toString() ?? '0') ??
            0.0,
      );

      // Save Local
      final entity = DutySessionEntity.fromDomain(sessionModel);
      entity.syncStatus = SyncStatus.pending;
      await _dutyRepository.startDuty(entity);

      // Attempt immediate sync push (optional, or rely on SyncManager)
      // _syncManager.triggerSync... if available.

      // Update location
      await _gpsService.updateEntityLocation(
        userId,
        PartialLocationData(
          userId: userId,
          userName: sessionData['userName'],
          role: role,
          latitude: sessionData['loginLatitude'],
          longitude: sessionData['loginLongitude'],
          isOnline: true,
        ),
      );

      return id;
    } catch (e) {
      handleError(e, 'startDutySession');
      return null;
    }
  }

  Future<bool> endDutySession(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    try {
      final session = await _dbService.dutySessions
          .filter()
          .idEqualTo(sessionId)
          .findFirst();
      if (session != null) {
        await _dutyRepository.endDuty(
          sessionId,
          DateTime.tryParse(data['logoutTime']?.toString() ?? '') ??
              DateTime.now(),
          (data['logoutLatitude'] as num?)?.toDouble(),
          (data['logoutLongitude'] as num?)?.toDouble(),
          (data['totalDistanceKm'] as num?)?.toDouble() ?? 0.0,
        );
        final refreshed = await _dbService.dutySessions
            .filter()
            .idEqualTo(sessionId)
            .findFirst();
        if (refreshed != null) {
          refreshed.endOdometer = double.tryParse(
            data['endOdometer']?.toString() ?? '',
          );
          await _dbService.db.writeTxn(() async {
            await _dbService.dutySessions.put(refreshed);
          });

          await _gpsService.updateEntityLocation(
            refreshed.userId,
            PartialLocationData(
              userId: refreshed.userId,
              userName: refreshed.userName,
              role: refreshed.userRole,
              latitude: refreshed.logoutLatitude ?? 0.0,
              longitude: refreshed.logoutLongitude ?? 0.0,
              isOnline: false,
            ),
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      handleError(e, 'endDutySession');
      return false;
    }
  }

  Future<List<DutySession>> getCompletedSessionsForUser(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      // Ensure we cover the whole day for the end date if passing just a date
      final effectiveEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);

      final sessions = await _dbService.dutySessions
          .filter()
          .userIdEqualTo(userId)
          .statusEqualTo('completed')
          .and()
          .loginTimeBetween(
            start.toIso8601String(),
            effectiveEnd.toIso8601String(),
            includeLower: true,
            includeUpper: true,
          )
          .findAll();

      return sessions.map((e) => e.toDomain()).toList();
    } catch (e) {
      handleError(e, 'getCompletedSessionsForUser');
      return [];
    }
  }
}
