import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/types/alert_types.dart';
import '../../models/types/route_order_types.dart';
import '../../models/types/user_types.dart';
import 'database_service.dart';
import '../core/firebase/firebase_config.dart';
import '../data/local/entities/alert_entity.dart';
import '../services/vehicles_service.dart';
import '../utils/app_logger.dart';
import 'package:isar/isar.dart' hide Query;
import 'package:uuid/uuid.dart';

class AlertService with ChangeNotifier {
  final DatabaseService _db;
  final FirebaseServices _firebase;
  static const Duration _permissionDeniedRetryBackoff = Duration(minutes: 10);
  static const Set<UserRole> routeOrderNotificationTargetRoles = {
    UserRole.owner,
    UserRole.admin,
    UserRole.storeIncharge,
    UserRole.productionManager,
    UserRole.productionSupervisor,
  };
  static const String _metaTargetRoles = 'targetRoles';
  static const String _metaTargetUserIds = 'targetUserIds';
  static const String _metaReadByUserIds = 'readByUserIds';
  static const String _metaReadByAuthUids = 'readByAuthUids';
  static const String _metaRouteOrderResolved = 'routeOrderResolved';
  static const String routeOrderEventTypeKey = 'eventType';
  static const String routeOrderCreatedEvent = 'route_order_created';
  static const String _alertsCollection = 'alerts';
  static const String _notificationEventsCollection = 'notification_events';
  static const String _routeOrdersCollection = 'route_orders';

  AlertService(this._db, [FirebaseServices? firebase])
    : _firebase = firebase ?? firebaseServices;

  String? _notificationEventsDeniedScope;
  DateTime? _notificationEventsDeniedAtUtc;
  String? _routeOrdersDeniedScope;
  DateTime? _routeOrdersDeniedAtUtc;
  String? _alertsCollectionDeniedScope;
  DateTime? _alertsCollectionDeniedAtUtc;

  Set<String> _extractStringSet(Map<String, dynamic>? metadata, String key) {
    final raw = metadata?[key];
    if (raw is! List) return <String>{};
    return raw
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  bool _isRouteOrderNotificationTargetRole(UserRole role) {
    return routeOrderNotificationTargetRoles.contains(role);
  }

  Set<UserRole> _extractTargetRoles(SystemAlert alert) {
    final roles = <UserRole>{};
    final rawRoles = _extractStringSet(alert.metadata, _metaTargetRoles);
    for (final raw in rawRoles) {
      try {
        roles.add(UserRole.fromString(raw));
      } catch (_) {
        // Ignore invalid/legacy role values.
      }
    }
    return roles;
  }

  List<String> _extractStringList(dynamic raw) {
    if (raw is! List) return const <String>[];
    return raw
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _normalizeRoleToken(String value) {
    return value
        .trim()
        .replaceAll(' ', '')
        .replaceAll('_', '')
        .replaceAll('-', '')
        .toLowerCase();
  }

  bool _roleListContainsUserRole(List<String> rawRoles, UserRole role) {
    if (rawRoles.isEmpty) return false;
    final expected = {
      _normalizeRoleToken(role.name),
      _normalizeRoleToken(role.value),
    };
    return rawRoles.any((raw) => expected.contains(_normalizeRoleToken(raw)));
  }

  AlertType _parseAlertType(dynamic raw) {
    final token = raw?.toString().trim();
    if (token == null || token.isEmpty) return AlertType.other;
    for (final value in AlertType.values) {
      if (value.name == token ||
          value.toString() == token ||
          value.toString().split('.').last == token) {
        return value;
      }
    }
    return AlertType.other;
  }

  AlertSeverity _parseAlertSeverity(dynamic raw) {
    final token = raw?.toString().trim();
    if (token == null || token.isEmpty) return AlertSeverity.info;
    for (final value in AlertSeverity.values) {
      if (value.name == token ||
          value.toString() == token ||
          value.toString().split('.').last == token) {
        return value;
      }
    }
    return AlertSeverity.info;
  }

  DateTime _parseCreatedAt(dynamic raw, {dynamic fallbackEpoch}) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
    }
    if (fallbackEpoch is num) {
      return DateTime.fromMillisecondsSinceEpoch(fallbackEpoch.toInt());
    }
    return DateTime.now();
  }

  Map<String, dynamic>? _asMetadata(dynamic raw) {
    if (raw is Map<String, dynamic>) return Map<String, dynamic>.from(raw);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  SystemAlert _copyAlertWithReadState(SystemAlert source, bool isRead) {
    return SystemAlert(
      id: source.id,
      title: source.title,
      message: source.message,
      type: source.type,
      severity: source.severity,
      isRead: isRead,
      createdAt: source.createdAt,
      relatedId: source.relatedId,
      metadata: source.metadata,
    );
  }

  bool _isReadForUser(SystemAlert alert, AppUser? user) {
    if (user == null) return alert.isRead;

    final userId = user.id.trim();
    final authUid = _firebase.auth?.currentUser?.uid.trim();
    final readByUserIds = _extractStringSet(alert.metadata, _metaReadByUserIds);
    final readByAuthUids = _extractStringSet(
      alert.metadata,
      _metaReadByAuthUids,
    );

    if (userId.isNotEmpty && readByUserIds.contains(userId)) {
      return true;
    }
    if (authUid != null &&
        authUid.isNotEmpty &&
        readByAuthUids.contains(authUid)) {
      return true;
    }

    // LOCKED: never trust shared local boolean read-state for authenticated users.
    return false;
  }

  void _addMarkerToMetadata(
    Map<String, dynamic> metadata,
    String key,
    String marker,
  ) {
    final normalized = marker.trim();
    if (normalized.isEmpty) return;
    final merged = {..._extractStringSet(metadata, key), normalized}.toList()
      ..sort();
    metadata[key] = merged;
  }

  Map<String, dynamic>? _mergeMetadataWithReadMarkers(
    Map<String, dynamic>? sourceMetadata,
    Map<String, dynamic>? localMetadata,
  ) {
    final merged = <String, dynamic>{};
    if (sourceMetadata != null) merged.addAll(sourceMetadata);
    if (localMetadata != null) {
      localMetadata.forEach((key, value) {
        merged.putIfAbsent(key, () => value);
      });
    }

    final readByUsers = {
      ..._extractStringSet(sourceMetadata, _metaReadByUserIds),
      ..._extractStringSet(localMetadata, _metaReadByUserIds),
    }.toList()..sort();
    final readByAuthUids = {
      ..._extractStringSet(sourceMetadata, _metaReadByAuthUids),
      ..._extractStringSet(localMetadata, _metaReadByAuthUids),
    }.toList()..sort();

    if (readByUsers.isNotEmpty) {
      merged[_metaReadByUserIds] = readByUsers;
    }
    if (readByAuthUids.isNotEmpty) {
      merged[_metaReadByAuthUids] = readByAuthUids;
    }

    return merged.isEmpty ? null : merged;
  }

  SystemAlert _mergeAlertWithLocalReadState(
    SystemAlert source,
    SystemAlert? local,
  ) {
    final mergedMetadata = _mergeMetadataWithReadMarkers(
      source.metadata,
      local?.metadata,
    );
    return SystemAlert(
      id: source.id,
      title: source.title,
      message: source.message,
      type: source.type,
      severity: source.severity,
      isRead: local?.isRead ?? source.isRead,
      createdAt: source.createdAt,
      relatedId: source.relatedId,
      metadata: mergedMetadata,
    );
  }

  Future<List<SystemAlert>> _fetchCloudAlertsFromAlertsCollection(
    AppUser user,
  ) async {
    final authUser = _firebase.auth?.currentUser;
    if (authUser == null) return const <SystemAlert>[];

    final firestore = _firebase.db;
    if (firestore == null) return const <SystemAlert>[];

    final authUid = authUser.uid;
    final authScope = authUid.trim().isEmpty ? '__no_auth__' : authUid.trim();
    if (_alertsCollectionDeniedScope != null &&
        _alertsCollectionDeniedScope != authScope) {
      _alertsCollectionDeniedScope = null;
      _alertsCollectionDeniedAtUtc = null;
    }

    final nowUtc = DateTime.now().toUtc();
    final alertsBlockedForScope =
        _alertsCollectionDeniedScope == authScope &&
        _alertsCollectionDeniedAtUtc != null &&
        nowUtc.difference(_alertsCollectionDeniedAtUtc!) <
            _permissionDeniedRetryBackoff;

    if (alertsBlockedForScope) {
      return const <SystemAlert>[];
    }

    try {
      final snapshot = await firestore
          .collection(_alertsCollection)
          .orderBy('createdAtEpoch', descending: true)
          .limit(400)
          .get();
      final alerts = <SystemAlert>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final metadata = _asMetadata(data['metadata']) ?? <String, dynamic>{};
        final targetRoles = _extractStringList(data['targetRoles']);
        final targetUserIds = _extractStringList(data['targetUserIds']);
        if (targetRoles.isNotEmpty) {
          metadata[_metaTargetRoles] = targetRoles;
        }
        if (targetUserIds.isNotEmpty) {
          metadata[_metaTargetUserIds] = targetUserIds;
        }

        final alert = SystemAlert(
          id: (data['id']?.toString().trim().isNotEmpty == true)
              ? data['id'].toString().trim()
              : doc.id,
          title: (data['title']?.toString().trim().isNotEmpty == true)
              ? data['title'].toString().trim()
              : 'System Alert',
          message: (data['message']?.toString().trim().isNotEmpty == true)
              ? data['message'].toString().trim()
              : 'New update available',
          type: _parseAlertType(data['type']),
          severity: _parseAlertSeverity(data['severity']),
          createdAt: _parseCreatedAt(
            data['createdAt'],
            fallbackEpoch: data['createdAtEpoch'],
          ),
          relatedId: data['relatedId']?.toString(),
          metadata: metadata.isEmpty ? null : metadata,
        );

        if (_isAlertVisibleToUser(alert, user)) {
          alerts.add(alert);
        }
      }
      return alerts;
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('permission-denied') ||
          message.contains('insufficient permissions')) {
        _alertsCollectionDeniedScope = authScope;
        _alertsCollectionDeniedAtUtc = DateTime.now().toUtc();
        AppLogger.warning(
          'Alerts collection permission-denied. Backoff for 10 minutes.',
          tag: 'AlertService',
        );
      } else {
        AppLogger.warning('Cloud alerts fetch failed: $e', tag: 'AlertService');
      }
      return const <SystemAlert>[];
    }
  }

  bool _isNotificationEventVisibleForUser(
    Map<String, dynamic> data,
    AppUser user, {
    String? authUid,
  }) {
    if (user.isAdmin) return true;

    final targetUserIds = _extractStringList(data['targetUserIds']);
    final targetRoles = _extractStringList(data['targetRoles']);
    final hasUserFilter = targetUserIds.isNotEmpty;
    final hasRoleFilter = targetRoles.isNotEmpty;

    if (!hasUserFilter && !hasRoleFilter) return false;

    if (hasUserFilter) {
      final hasDirectId = targetUserIds.contains(user.id);
      final hasAuthUid =
          authUid != null &&
          authUid.trim().isNotEmpty &&
          targetUserIds.contains(authUid.trim());
      if (!hasDirectId && !hasAuthUid) return false;
    }

    if (hasRoleFilter && !_roleListContainsUserRole(targetRoles, user.role)) {
      return false;
    }

    return true;
  }

  String? _extractNotificationRelatedId(Map<String, dynamic> eventData) {
    const candidateKeys = <String>[
      'orderId',
      'taskId',
      'dispatchId',
      'returnId',
      'tripId',
      'productId',
      'materialIssueId',
      'id',
    ];
    for (final key in candidateKeys) {
      final value = eventData[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  AlertType _mapNotificationEventTypeToAlertType(String eventType) {
    switch (eventType) {
      case 'dispatch_assigned':
      case 'order_accepted':
        return AlertType.dispatchReceived;
      case 'return_approved':
      case 'return_rejected':
        return AlertType.other;
      case 'task_assigned':
      case 'task_updated':
      case 'task_reassigned':
        return AlertType.other;
      case routeOrderCreatedEvent:
        return AlertType.other;
      default:
        return AlertType.other;
    }
  }

  Future<List<SystemAlert>> _fetchNotificationEventAlerts(AppUser user) async {
    final authUser = _firebase.auth?.currentUser;
    if (authUser == null) return const <SystemAlert>[];

    final firestore = _firebase.db;
    if (firestore == null) return const <SystemAlert>[];

    final authUid = authUser.uid;
    final authScope = authUid.trim().isEmpty ? '__no_auth__' : authUid.trim();
    if (_notificationEventsDeniedScope != null &&
        _notificationEventsDeniedScope != authScope) {
      _notificationEventsDeniedScope = null;
      _notificationEventsDeniedAtUtc = null;
    }
    final nowUtc = DateTime.now().toUtc();
    final eventsBlockedForScope =
        _notificationEventsDeniedScope == authScope &&
        _notificationEventsDeniedAtUtc != null &&
        nowUtc.difference(_notificationEventsDeniedAtUtc!) <
            _permissionDeniedRetryBackoff;
    if (eventsBlockedForScope) {
      return const <SystemAlert>[];
    }

    final queries = <Query<Map<String, dynamic>>>[];
    final eventsCollection = firestore.collection(
      _notificationEventsCollection,
    );
    final seenDocIds = <String>{};
    final alerts = <SystemAlert>[];
    var permissionDenied = false;

    if (user.isAdmin) {
      queries.add(
        eventsCollection.orderBy('createdAtEpoch', descending: true).limit(400),
      );
    } else {
      // Query using auth UID first (rules commonly key on request.auth.uid).
      final normalizedAuthUid = authUid.trim();
      if (normalizedAuthUid.isNotEmpty) {
        queries.add(
          eventsCollection.where(
            'targetUserIds',
            arrayContains: normalizedAuthUid,
          ),
        );
      }
      final normalizedUserId = user.id.trim();
      if (normalizedUserId.isNotEmpty &&
          normalizedUserId != normalizedAuthUid) {
        queries.add(
          eventsCollection.where(
            'targetUserIds',
            arrayContains: normalizedUserId,
          ),
        );
      }

      // LOCKED FIX: include role name/value variants so legacy payloads remain visible.
      final roleTokens = <String>{
        user.role.value.trim(),
        user.role.name.trim(),
        user.role.value.trim().toLowerCase(),
        user.role.name.trim().toLowerCase(),
      }..removeWhere((token) => token.isEmpty);
      for (final roleToken in roleTokens) {
        queries.add(
          eventsCollection.where('targetRoles', arrayContains: roleToken),
        );
      }
    }

    for (final query in queries) {
      try {
        final snapshot = await query.get();
        for (final doc in snapshot.docs) {
          if (!seenDocIds.add(doc.id)) continue;
          final data = doc.data();
          if (!_isNotificationEventVisibleForUser(
            data,
            user,
            authUid: authUid,
          )) {
            continue;
          }

          final eventType = data['eventType']?.toString().trim() ?? '';
          final eventData = _asMetadata(data['data']) ?? <String, dynamic>{};
          final eventAlertId = data['alertId']?.toString().trim();
          final targetRoles = _extractStringList(data['targetRoles']);
          final targetUserIds = _extractStringList(data['targetUserIds']);
          final metadata = <String, dynamic>{
            ...eventData,
            routeOrderEventTypeKey: eventType,
            if (targetRoles.isNotEmpty) _metaTargetRoles: targetRoles,
            if (targetUserIds.isNotEmpty) _metaTargetUserIds: targetUserIds,
          };
          final title = (data['title']?.toString().trim().isNotEmpty == true)
              ? data['title'].toString().trim()
              : 'Notification';
          final message = (data['body']?.toString().trim().isNotEmpty == true)
              ? data['body'].toString().trim()
              : 'New update available';

          alerts.add(
            SystemAlert(
              // Use alertId when available to dedupe against alerts collection.
              id: (eventAlertId != null && eventAlertId.isNotEmpty)
                  ? eventAlertId
                  : 'evt_${doc.id}',
              title: title,
              message: message,
              type: _mapNotificationEventTypeToAlertType(eventType),
              severity: _parseAlertSeverity(data['severity']),
              createdAt: _parseCreatedAt(
                data['createdAt'],
                fallbackEpoch: data['createdAtEpoch'],
              ),
              relatedId: _extractNotificationRelatedId(eventData),
              metadata: metadata,
            ),
          );
        }
      } catch (e) {
        final message = e.toString().toLowerCase();
        if (message.contains('permission-denied') ||
            message.contains('insufficient permissions')) {
          // notification_events is best-effort; alerts collection already covers core notifications.
          permissionDenied = true;
          _notificationEventsDeniedScope = authScope;
          _notificationEventsDeniedAtUtc = DateTime.now().toUtc();
          break;
        }
        AppLogger.warning(
          'Notification event fetch failed: $e',
          tag: 'AlertService',
        );
      }
    }

    if (!permissionDenied && _notificationEventsDeniedScope == authScope) {
      _notificationEventsDeniedScope = null;
      _notificationEventsDeniedAtUtc = null;
    }

    return alerts;
  }

  Future<void> _cacheAlertsLocally(
    List<SystemAlert> alerts,
    Map<String, SystemAlert> existingLocalById,
  ) async {
    if (alerts.isEmpty) return;

    final entities = alerts.map((alert) {
      final cached = existingLocalById[alert.id];
      final merged = _mergeAlertWithLocalReadState(alert, cached);
      return AlertEntity.fromDomain(merged);
    }).toList();

    await _db.db.writeTxn(() async {
      await _db.alerts.putAll(entities);
    });
  }

  String? _extractRouteOrderId(SystemAlert alert) {
    final metadata = alert.metadata;
    final fromMetadata = metadata?['orderId']?.toString().trim();
    if (fromMetadata != null && fromMetadata.isNotEmpty) {
      return fromMetadata;
    }
    final fromRelatedId = alert.relatedId?.trim();
    if (fromRelatedId != null && fromRelatedId.isNotEmpty) {
      return fromRelatedId;
    }
    return null;
  }

  Future<bool> _isRouteOrderAlertActive({
    required SystemAlert alert,
    required Map<String, bool> orderActiveCache,
  }) async {
    if (!isRouteOrderAlert(alert)) return true;
    if (alert.metadata?[_metaRouteOrderResolved] == true) return false;

    final orderId = _extractRouteOrderId(alert);
    if (orderId == null || orderId.isEmpty) return false;

    final cached = orderActiveCache[orderId];
    if (cached != null) return cached;

    final firestore = _firebase.db;
    if (firestore == null) {
      // Offline mode fallback: keep alert visible until connectivity resumes.
      orderActiveCache[orderId] = true;
      return true;
    }
    final authUser = _firebase.auth?.currentUser;
    if (authUser == null) {
      // Auth not available: avoid permission-error loops, keep visible.
      orderActiveCache[orderId] = true;
      return true;
    }

    final authScope = authUser.uid.trim().isEmpty
        ? '__no_auth__'
        : authUser.uid.trim();
    if (_routeOrdersDeniedScope != null &&
        _routeOrdersDeniedScope != authScope) {
      _routeOrdersDeniedScope = null;
      _routeOrdersDeniedAtUtc = null;
    }
    final nowUtc = DateTime.now().toUtc();
    final routeOrderCheckBlocked =
        _routeOrdersDeniedScope == authScope &&
        _routeOrdersDeniedAtUtc != null &&
        nowUtc.difference(_routeOrdersDeniedAtUtc!) <
            _permissionDeniedRetryBackoff;
    if (routeOrderCheckBlocked) {
      orderActiveCache[orderId] = true;
      return true;
    }

    try {
      final doc = await firestore
          .collection(_routeOrdersCollection)
          .doc(orderId)
          .get();
      if (!doc.exists || doc.data() == null) {
        orderActiveCache[orderId] = false;
        return false;
      }

      final data = doc.data()!;
      final isDeleted = data['isDeleted'] == true;
      final productionStatus = RouteOrderProductionStatus.fromString(
        data['productionStatus']?.toString(),
      );
      final dispatchStatus = RouteOrderDispatchStatus.fromString(
        data['dispatchStatus']?.toString(),
      );
      final isActive =
          !isDeleted &&
          productionStatus == RouteOrderProductionStatus.pending &&
          dispatchStatus == RouteOrderDispatchStatus.pending;
      orderActiveCache[orderId] = isActive;
      if (_routeOrdersDeniedScope == authScope) {
        _routeOrdersDeniedScope = null;
        _routeOrdersDeniedAtUtc = null;
      }
      return isActive;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        _routeOrdersDeniedScope = authScope;
        _routeOrdersDeniedAtUtc = DateTime.now().toUtc();
        orderActiveCache[orderId] = true;
        return true;
      }
      AppLogger.warning(
        'Route order alert activity check failed for $orderId: $e',
        tag: 'AlertService',
      );
      // Fail-open to avoid hiding alerts on transient network/rules issues.
      orderActiveCache[orderId] = true;
      return true;
    } catch (e) {
      AppLogger.warning(
        'Route order alert activity check failed for $orderId: $e',
        tag: 'AlertService',
      );
      // Fail-open to avoid hiding alerts on transient network/rules issues.
      orderActiveCache[orderId] = true;
      return true;
    }
  }

  bool _isAlertRelevantForRole(AppUser user, SystemAlert alert) {
    if (alert.relatedId != null && alert.relatedId == user.id) {
      return true;
    }

    switch (alert.type) {
      case AlertType.criticalStock:
        return user.role == UserRole.storeIncharge ||
            user.role == UserRole.productionManager ||
            user.role == UserRole.dispatchManager;
      case AlertType.attendanceLate:
      case AlertType.attendanceMissed:
        return user.role == UserRole.productionManager ||
            user.role == UserRole.gateKeeper ||
            user.role == UserRole.dispatchManager;
      case AlertType.dispatchReceived:
        return user.role == UserRole.salesman ||
            user.role == UserRole.dealerManager ||
            user.role == UserRole.dispatchManager ||
            user.role == UserRole.salesManager;
      case AlertType.paymentPending:
        return user.role == UserRole.accountant ||
            user.role == UserRole.dealerManager ||
            user.role == UserRole.salesManager;
      case AlertType.vehicleExpiry:
        return user.role == UserRole.driver ||
            user.role == UserRole.dispatchManager ||
            user.role == UserRole.vehicleMaintenanceManager ||
            user.role == UserRole.fuelIncharge ||
            user.role == UserRole.gateKeeper;
      case AlertType.systemUpdate:
        return true;
      case AlertType.other:
        return false;
    }
  }

  bool _isAlertVisibleToUser(SystemAlert alert, AppUser? user) {
    // SECURITY FIX: Reject null users to prevent unauthorized access
    if (user == null) return false;
    // Admin and Manager see ALL alerts
    if (user.isAdminOrManager) return true;

    if (isRouteOrderAlert(alert) &&
        !_isRouteOrderNotificationTargetRole(user.role)) {
      return false;
    }

    final targetUserIds = _extractStringSet(alert.metadata, _metaTargetUserIds);
    if (targetUserIds.isNotEmpty && !targetUserIds.contains(user.id)) {
      return false;
    }

    final targetRoles = _extractTargetRoles(alert);
    if (targetRoles.isNotEmpty && !targetRoles.contains(user.role)) {
      return false;
    }

    if (targetUserIds.isNotEmpty || targetRoles.isNotEmpty) {
      return true;
    }

    return _isAlertRelevantForRole(user, alert);
  }

  // Get active (unread) alerts count
  Future<int> getUnreadCount({AppUser? user}) async {
    final all = await getAllAlerts(user: user);
    return all.where((alert) => !alert.isRead).length;
  }

  // Get all alerts (sorted by time)
  Future<List<SystemAlert>> getAllAlerts({AppUser? user}) async {
    final localList = await _db.alerts.where().sortByCreatedAtDesc().findAll();
    final localVisible = localList
        .map((e) => e.toDomain())
        .where((alert) => _isAlertVisibleToUser(alert, user))
        .toList();
    final localById = <String, SystemAlert>{
      for (final alert in localVisible) alert.id: alert,
    };

    if (user == null) {
      return localVisible;
    }

    final cloudAlerts = <SystemAlert>[
      ...await _fetchCloudAlertsFromAlertsCollection(user),
      ...await _fetchNotificationEventAlerts(user),
    ];

    final cloudById = <String, SystemAlert>{};
    for (final alert in cloudAlerts) {
      cloudById[alert.id] = _mergeAlertWithLocalReadState(
        alert,
        localById[alert.id],
      );
    }

    if (cloudById.isNotEmpty) {
      await _cacheAlertsLocally(cloudById.values.toList(), localById);
    }

    final mergedById = <String, SystemAlert>{...localById, ...cloudById};
    final merged = mergedById.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // LOCKED FIX: route-order create alerts should only stay visible while
    // the order is actionable for production (pending/pending and not deleted).
    final orderActiveCache = <String, bool>{};
    final visible = <SystemAlert>[];
    for (final alert in merged) {
      final keep = await _isRouteOrderAlertActive(
        alert: alert,
        orderActiveCache: orderActiveCache,
      );
      if (keep) {
        visible.add(alert);
      }
    }
    return visible
        .map(
          (alert) =>
              _copyAlertWithReadState(alert, _isReadForUser(alert, user)),
        )
        .toList();
  }

  bool isRouteOrderAlert(SystemAlert alert) {
    final eventType = alert.metadata?[routeOrderEventTypeKey];
    return eventType is String && eventType == routeOrderCreatedEvent;
  }

  Future<List<SystemAlert>> getUnreadAlerts({AppUser? user}) async {
    final all = await getAllAlerts(user: user);
    return all.where((alert) => !alert.isRead).toList();
  }

  Future<List<SystemAlert>> getUnreadRouteOrderAlerts({AppUser? user}) async {
    final unread = await getUnreadAlerts(user: user);
    final routeOrderAlerts = unread.where(isRouteOrderAlert).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return routeOrderAlerts;
  }

  Future<int> getUnreadRouteOrderCount({AppUser? user}) async {
    final routeOrderAlerts = await getUnreadRouteOrderAlerts(user: user);
    return routeOrderAlerts.length;
  }

  Future<SystemAlert?> getLatestUnreadRouteOrderAlert({AppUser? user}) async {
    final routeOrderAlerts = await getUnreadRouteOrderAlerts(user: user);
    return routeOrderAlerts.isEmpty ? null : routeOrderAlerts.first;
  }

  String _formatAlertMessageWithMention(String message, AppUser? user) {
    if (user == null) return message;
    return '$message\n👤 By: ${user.name} (${user.role.value})';
  }

  // Create an alert
  Future<void> createAlert({
    required String title,
    required String message,
    required AlertType type,
    AlertSeverity severity = AlertSeverity.info,
    String? relatedId,
    Set<UserRole>? targetRoles,
    Set<String>? targetUserIds,
    Map<String, dynamic>? metadata,
    AppUser? createdByUser,
  }) async {
    // Auto-add Admin and Manager roles to ALL alerts so they see everything
    final expandedTargetRoles = <UserRole>{
      ...?targetRoles,
      UserRole.admin,
      UserRole.owner,
      UserRole.productionManager,
      UserRole.salesManager,
      UserRole.dispatchManager,
      UserRole.dealerManager,
      UserRole.vehicleMaintenanceManager,
    };

    final normalizedTargetUserIds =
        (targetUserIds ?? <String>{})
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final normalizedTargetRolesByName =
        expandedTargetRoles.map((e) => e.name).toList()..sort();
    final normalizedTargetRolesByValue =
        expandedTargetRoles.map((e) => e.value).toList()..sort();
    final normalizedTargetRoles = <String>{
      ...normalizedTargetRolesByName,
      ...normalizedTargetRolesByValue,
      ...normalizedTargetRolesByName.map((role) => role.toLowerCase()),
      ...normalizedTargetRolesByValue.map((role) => role.toLowerCase()),
    }.toList()..sort();

    final mergedMetadata = <String, dynamic>{};
    if (metadata != null) {
      // SECURITY FIX: Sanitize metadata to prevent injection attacks
      final sanitized = Map<String, dynamic>.from(metadata);
      sanitized.remove('createdByUserId');
      sanitized.remove('createdByUserName');
      sanitized.remove('createdByUserRole');
      sanitized.remove(_metaTargetRoles);
      sanitized.remove(_metaTargetUserIds);
      sanitized.remove(_metaReadByUserIds);
      sanitized.remove(_metaReadByAuthUids);
      mergedMetadata.addAll(sanitized);
    }
    // Add creator info to metadata for mentions (overrides any injection attempt)
    if (createdByUser != null) {
      mergedMetadata['createdByUserId'] = createdByUser.id;
      mergedMetadata['createdByUserName'] = createdByUser.name;
      mergedMetadata['createdByUserRole'] = createdByUser.role.value;
    }
    if (normalizedTargetRoles.isNotEmpty) {
      mergedMetadata[_metaTargetRoles] = normalizedTargetRoles;
    }
    if (normalizedTargetUserIds.isNotEmpty) {
      mergedMetadata[_metaTargetUserIds] = normalizedTargetUserIds;
    }

    // Format message with user mention if creator exists
    final finalMessage = createdByUser != null
        ? _formatAlertMessageWithMention(message, createdByUser)
        : message;

    final alert = SystemAlert(
      id: const Uuid().v4(),
      title: title,
      message: finalMessage,
      type: type,
      severity: severity,
      createdAt: DateTime.now(),
      relatedId: relatedId,
      metadata: mergedMetadata.isEmpty ? null : mergedMetadata,
    );

    await _db.db.writeTxn(() async {
      await _db.alerts.put(AlertEntity.fromDomain(alert));
    });

    final firestore = _firebase.db;
    if (firestore != null) {
      try {
        await firestore.collection(_alertsCollection).doc(alert.id).set({
          'id': alert.id,
          'title': alert.title,
          'message': alert.message,
          'type': alert.type.name,
          'severity': alert.severity.name,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'createdAtEpoch': alert.createdAt.millisecondsSinceEpoch,
          if (alert.relatedId != null) 'relatedId': alert.relatedId,
          if (mergedMetadata.isNotEmpty) 'metadata': mergedMetadata,
          if (normalizedTargetRoles.isNotEmpty)
            'targetRoles': normalizedTargetRoles,
          if (normalizedTargetUserIds.isNotEmpty)
            'targetUserIds': normalizedTargetUserIds,
          'createdByUid': _firebase.auth?.currentUser?.uid,
          'createdByEmail': _firebase.auth?.currentUser?.email,
        }, SetOptions(merge: true));
      } catch (e) {
        AppLogger.warning('Cloud alert write failed: $e', tag: 'AlertService');
      }

      final eventType = mergedMetadata[routeOrderEventTypeKey]
          ?.toString()
          .trim();
      if (eventType != null &&
          eventType.isNotEmpty &&
          (normalizedTargetRoles.isNotEmpty ||
              normalizedTargetUserIds.isNotEmpty)) {
        try {
          await firestore.collection(_notificationEventsCollection).add({
            'alertId': alert.id,
            'title': alert.title,
            'body': alert.message,
            'eventType': eventType,
            'severity': alert.severity.name,
            'targetRoles': normalizedTargetRoles,
            'targetUserIds': normalizedTargetUserIds,
            'forceSound': true,
            'route': '/dashboard/orders/route-management',
            'data': mergedMetadata,
            'createdAt': FieldValue.serverTimestamp(),
            'createdAtEpoch': alert.createdAt.millisecondsSinceEpoch,
            'createdByUid': _firebase.auth?.currentUser?.uid,
            'createdByEmail': _firebase.auth?.currentUser?.email,
          });
        } catch (e) {
          AppLogger.warning(
            'notification_events write failed: $e',
            tag: 'AlertService',
          );
        }
      }
    }

    notifyListeners();
  }

  // Mark as read
  Future<void> markAsRead(String alertId, {AppUser? user}) async {
    final normalizedAlertId = alertId.trim();
    if (normalizedAlertId.isEmpty) return;

    final readerUserId = user?.id.trim();
    final readerAuthUid = _firebase.auth?.currentUser?.uid.trim();
    final now = DateTime.now();

    await _db.db.writeTxn(() async {
      final alert = await _db.alerts
          .filter()
          .alertIdEqualTo(normalizedAlertId)
          .findFirst();
      if (alert != null) {
        // LOCKED: read state is user-scoped (not global) so one user's read
        // action never clears unread badge for other roles/users.
        final metadata = <String, dynamic>{};
        final existingMetadata = alert.toDomain().metadata;
        if (existingMetadata != null) {
          metadata.addAll(existingMetadata);
        }
        if (readerUserId != null && readerUserId.isNotEmpty) {
          _addMarkerToMetadata(metadata, _metaReadByUserIds, readerUserId);
        }
        if (readerAuthUid != null && readerAuthUid.isNotEmpty) {
          _addMarkerToMetadata(metadata, _metaReadByAuthUids, readerAuthUid);
        }

        alert.isRead = true;
        alert.metadataJson = metadata.isEmpty ? null : jsonEncode(metadata);
        alert.updatedAt = now;
        await _db.alerts.put(alert);
      }
    });
    notifyListeners();
  }

  Future<void> resolveRouteOrderAlerts({required String orderId}) async {
    final normalizedOrderId = orderId.trim();
    if (normalizedOrderId.isEmpty) return;

    var didUpdate = false;
    final now = DateTime.now();
    await _db.db.writeTxn(() async {
      final linked = await _db.alerts
          .filter()
          .relatedIdEqualTo(normalizedOrderId)
          .findAll();
      for (final entity in linked) {
        final metadata = <String, dynamic>{};
        final existingMetadata = entity.toDomain().metadata;
        if (existingMetadata != null) {
          metadata.addAll(existingMetadata);
        }
        final eventType = metadata[routeOrderEventTypeKey];
        if (eventType is String && eventType == routeOrderCreatedEvent) {
          entity.isRead = true;
          metadata[_metaRouteOrderResolved] = true;
          entity.metadataJson = jsonEncode(metadata);
          entity.updatedAt = now;
          await _db.alerts.put(entity);
          didUpdate = true;
        }
      }
    });

    if (didUpdate) {
      notifyListeners();
    }
  }

  // Delete all read alerts
  Future<void> clearReadAlerts() async {
    await _db.db.writeTxn(() async {
      await _db.alerts.filter().isReadEqualTo(true).deleteAll();
    });
    notifyListeners();
  }

  // Delete ALL alerts
  Future<void> clearAllAlerts() async {
    await _db.db.writeTxn(() async {
      await _db.alerts.where().deleteAll();
    });
    notifyListeners();
  }

  // BUSINESS LOGIC: Trigger vehicle document expiry alerts
  Future<void> checkVehicleExpiryAlerts(List<Vehicle> vehicles) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    for (var v in vehicles) {
      final documents = {
        'Insurance': v.insuranceExpiryDate,
        'PUC': v.pucExpiryDate,
        'Permit': v.permitExpiryDate,
        'Fitness': v.fitnessExpiryDate,
      };

      for (var entry in documents.entries) {
        final docName = entry.key;
        final expiry = entry.value;

        if (expiry == null) continue;

        final daysUntil = expiry.difference(now).inDays;

        // User Mockup Rule: 30 days (Medium/Warning), 15 days (High/Critical)
        if (daysUntil <= 30) {
          final isCritical = daysUntil <= 15;
          final isExpired = daysUntil < 0;

          // Check if alert already exists for this vehicle + document today
          final existing = await _db.alerts
              .filter()
              .relatedIdEqualTo('${v.id}_$docName')
              .typeEqualTo(AlertType.vehicleExpiry)
              .createdAtGreaterThan(todayStart)
              .findFirst();

          if (existing == null) {
            String title;
            String message;
            AlertSeverity severity;

            if (isExpired) {
              title = 'Expired: $docName (${v.number})';
              message =
                  '$docName for vehicle ${v.number} has expired on ${expiry.toIso8601String().split('T')[0]}. Action required immediately.';
              severity = AlertSeverity.critical;
            } else {
              title =
                  '${isCritical ? 'Critical' : 'Upcoming'} Expiry: $docName';
              message =
                  '$docName for vehicle ${v.number} is expiring in $daysUntil days (${expiry.toIso8601String().split('T')[0]}).';
              severity = isCritical
                  ? AlertSeverity.critical
                  : AlertSeverity.warning;
            }

            await createAlert(
              title: title,
              message: message,
              type: AlertType.vehicleExpiry,
              severity: severity,
              relatedId: '${v.id}_$docName',
              targetRoles: const {
                UserRole.driver,
                UserRole.dispatchManager,
                UserRole.vehicleMaintenanceManager,
                UserRole.fuelIncharge,
                UserRole.gateKeeper,
              },
            );
          }
        }
      }
    }
  }

  // BUSINESS LOGIC: Trigger stock alerts
  Future<void> checkStockAlerts(List<dynamic> products) async {
    for (var p in products) {
      final stock = (p['stock'] as num?)?.toDouble() ?? 0.0;
      final reorder = (p['reorderLevel'] as num?)?.toDouble() ?? 0.0;

      if (reorder > 0 && stock <= reorder) {
        // Check if an alert already exists for this product today to avoid SPAM
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);

        final existing = await _db.alerts
            .filter()
            .relatedIdEqualTo(p['id'])
            .typeEqualTo(AlertType.criticalStock)
            .createdAtGreaterThan(startOfDay)
            .findFirst();

        if (existing == null) {
          await createAlert(
            title: 'Low Stock: ${p['name']}',
            message:
                'Item has reached reorder level. Available: $stock ${p['baseUnit']}.',
            type: AlertType.criticalStock,
            severity: stock <= (reorder * 0.5)
                ? AlertSeverity.critical
                : AlertSeverity.warning,
            relatedId: p['id'],
            targetRoles: const {
              UserRole.storeIncharge,
              UserRole.productionManager,
              UserRole.dispatchManager,
            },
          );
        }
      }
    }
  }
}
