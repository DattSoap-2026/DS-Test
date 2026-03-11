import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/types/user_types.dart';
import '../utils/app_logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'Business Notifications';
  static const String _channelDescription =
      'Critical business workflow notifications with sound.';
  static const String _eventCollection = 'notification_events';
  static const String _androidCustomSound = 'dattsoap_notification';
  static const String _iosCustomSound = 'dattsoap_notification.aiff';
  static const Duration _notificationEventsRetryBackoff = Duration(minutes: 10);
  static const String _eventOutboxPrefsKey = 'notification_events_outbox_v1';
  static const String _eventOutboxSequencePrefsKey =
      'notification_events_outbox_seq_v1';
  static const String _eventOutboxInstancePrefsKey =
      'notification_events_outbox_instance_v1';
  static const int _maxOutboxEntries = 250;
  static const Duration _outboxDrainRetryDelay = Duration(seconds: 20);

  FirebaseMessaging? _firebaseMessaging;
  FirebaseFirestore? _firestore;
  FirebaseFunctions? _functions;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _messageSub;
  StreamSubscription<RemoteMessage>? _messageOpenedSub;
  StreamSubscription<String>? _tokenRefreshSub;

  bool _isInitialized = false;
  bool _fcmAvailable = false;
  String? _notificationEventsDeniedAuthUid;
  DateTime? _notificationEventsDeniedAtUtc;

  String? _boundUserId;
  String? _boundAuthUid;
  UserRole? _boundRole;
  final Set<String> _seenEventIds = <String>{};
  int _bindingVersion = 0;
  bool _isDrainingOutbox = false;
  Timer? _outboxDrainTimer;

  Future<FirebaseFirestore?> _resolveFirestore() async {
    if (_firestore != null) return _firestore;
    try {
      Firebase.app();
      _firestore = FirebaseFirestore.instance;
      _functions ??= FirebaseFunctions.instance;
      return _firestore;
    } catch (_) {
      return null;
    }
  }

  String _topicSafe(String value) {
    final sanitized = value.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9_-]'),
      '_',
    );
    if (sanitized.isEmpty) return 'unknown';
    return sanitized.length > 120 ? sanitized.substring(0, 120) : sanitized;
  }

  String _buildRoleTopic(UserRole role) => 'role_${_topicSafe(role.value)}';
  String _buildUserTopic(String userId) => 'user_${_topicSafe(userId)}';

  String _platformLabel() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _resolveFirestore();

    if (Platform.isWindows) {
      _isInitialized = true;
      AppLogger.info(
        'NotificationService initialized in desktop mode (FCM skipped on Windows)',
        tag: 'Notification',
      );
      return;
    }

    try {
      Firebase.app();
      _firebaseMessaging = FirebaseMessaging.instance;
      _functions ??= FirebaseFunctions.instance;
      _fcmAvailable = true;
      AppLogger.success('FCM available', tag: 'Notification');
    } catch (e) {
      AppLogger.warning(
        'FCM not available (offline mode): $e',
        tag: 'Notification',
      );
      _fcmAvailable = false;
    }

    if (_fcmAvailable) {
      await _requestPermission();
    }

    await _initLocalNotifications();

    if (_fcmAvailable && _firebaseMessaging != null) {
      _messageSub = FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
      );
      _messageOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen(
        _handleMessageOpenedApp,
      );
      _tokenRefreshSub = _firebaseMessaging!.onTokenRefresh.listen((token) {
        final userId = _boundUserId;
        final role = _boundRole;
        if (userId == null || role == null) return;
        unawaited(
          _registerToken(
            userId: userId,
            role: role,
            authUid: _boundAuthUid,
            explicitToken: token,
          ),
        );
      });

      final initialMessage = await _firebaseMessaging!.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
    }

    _isInitialized = true;
    AppLogger.success(
      'NotificationService initialized (FCM: $_fcmAvailable)',
      tag: 'Notification',
    );
    unawaited(_drainNotificationEventOutbox(trigger: 'initialize'));
  }

  Future<void> bindUser(AppUser user) async {
    final bindVersion = ++_bindingVersion;
    if (!_isInitialized) {
      await initialize();
    }
    if (bindVersion != _bindingVersion) return;

    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      await unbindUser();
      AppLogger.info(
        'bindUser skipped: no active Firebase auth session',
        tag: 'Notification',
      );
      return;
    }

    final authUid = authUser.uid;
    final nowUtc = DateTime.now().toUtc();
    if (_notificationEventsDeniedAuthUid != null &&
        _notificationEventsDeniedAuthUid != authUid) {
      _notificationEventsDeniedAuthUid = null;
      _notificationEventsDeniedAtUtc = null;
    }
    final suppressedForSameAuth =
        _notificationEventsDeniedAuthUid == authUid &&
        _notificationEventsDeniedAtUtc != null &&
        nowUtc.difference(_notificationEventsDeniedAtUtc!) <
            _notificationEventsRetryBackoff;
    if (_notificationEventsDeniedAuthUid == authUid && !suppressedForSameAuth) {
      _notificationEventsDeniedAuthUid = null;
      _notificationEventsDeniedAtUtc = null;
    }
    if (_boundUserId == user.id &&
        _boundAuthUid == authUid &&
        _boundRole == user.role) {
      return;
    }

    if (_fcmAvailable && _firebaseMessaging != null) {
      await _subscribeToTopics(user.id, user.role, authUid: authUid);
      await _registerToken(userId: user.id, role: user.role, authUid: authUid);
    }
    _boundUserId = user.id;
    _boundAuthUid = authUid;
    _boundRole = user.role;
    unawaited(_drainNotificationEventOutbox(trigger: 'bind_user'));
  }

  Future<void> unbindUser() async {
    _bindingVersion++;
    final previousUserId = _boundUserId;
    final previousAuthUid = _boundAuthUid;
    final previousRole = _boundRole;

    await _clearBindingState();

    if (_fcmAvailable &&
        _firebaseMessaging != null &&
        previousUserId != null &&
        previousRole != null) {
      await _unsubscribeFromTopics(
        previousUserId,
        previousRole,
        authUid: previousAuthUid,
      );
    }
  }

  Future<void> _clearBindingState() async {
    _boundUserId = null;
    _boundAuthUid = null;
    _boundRole = null;
    _seenEventIds.clear();
  }

  Future<void> _requestPermission() async {
    if (_firebaseMessaging == null) return;

    final settings = await _firebaseMessaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.info(
        'User granted notification permission',
        tag: 'Notification',
      );
      return;
    }
    if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      AppLogger.info(
        'User granted provisional notification permission',
        tag: 'Notification',
      );
      return;
    }
    AppLogger.info('User denied notification permission', tag: 'Notification');
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        AppLogger.info(
          'Local notification tapped: ${details.payload}',
          tag: 'Notification',
        );
      },
    );

    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidImplementation?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(_androidCustomSound),
          enableVibration: true,
        ),
      );
    }
  }

  Future<void> _subscribeToTopics(
    String userId,
    UserRole role, {
    String? authUid,
  }) async {
    final messaging = _firebaseMessaging;
    if (messaging == null) return;

    try {
      await messaging.subscribeToTopic(_buildRoleTopic(role));
      await messaging.subscribeToTopic(_buildUserTopic(userId));
      if (authUid != null && authUid.isNotEmpty && authUid != userId) {
        await messaging.subscribeToTopic(_buildUserTopic(authUid));
      }
    } catch (e) {
      AppLogger.warning('Topic subscribe failed: $e', tag: 'Notification');
    }
  }

  Future<void> _unsubscribeFromTopics(
    String userId,
    UserRole role, {
    String? authUid,
  }) async {
    final messaging = _firebaseMessaging;
    if (messaging == null) return;

    try {
      await messaging.unsubscribeFromTopic(_buildRoleTopic(role));
      await messaging.unsubscribeFromTopic(_buildUserTopic(userId));
      if (authUid != null && authUid.isNotEmpty && authUid != userId) {
        await messaging.unsubscribeFromTopic(_buildUserTopic(authUid));
      }
    } catch (e) {
      AppLogger.warning('Topic unsubscribe failed: $e', tag: 'Notification');
    }
  }

  Future<void> _registerToken({
    required String userId,
    required UserRole role,
    String? authUid,
    String? explicitToken,
  }) async {
    final messaging = _firebaseMessaging;
    final firestore = await _resolveFirestore();
    if (messaging == null || firestore == null) return;

    final token = explicitToken ?? await messaging.getToken();
    if (token == null || token.trim().isEmpty) return;

    final currentEmail = FirebaseAuth.instance.currentUser?.email
        ?.trim()
        .toLowerCase();
    final candidateDocIds = <String>{
      userId.trim(),
      if (authUid != null && authUid.trim().isNotEmpty) authUid.trim(),
      if (currentEmail != null && currentEmail.isNotEmpty) currentEmail,
    };

    for (final docId in candidateDocIds) {
      if (docId.isEmpty) continue;
      final userDoc = firestore.collection('users').doc(docId);
      try {
        final existing = await userDoc.get();
        if (!existing.exists) continue;

        await userDoc.set({
          'fcmToken': token,
          'fcmTokenPlatform': _platformLabel(),
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          'fcmTokenRole': role.value,
          'fcmTokenUserId': userId,
        }, SetOptions(merge: true));
        AppLogger.info(
          'FCM token registered on users/$docId',
          tag: 'Notification',
        );
        return;
      } catch (e) {
        AppLogger.warning(
          'Token write failed on users/$docId: $e',
          tag: 'Notification',
        );
      }
    }

    AppLogger.warning(
      'FCM token registration skipped (no writable user profile doc)',
      tag: 'Notification',
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.info('Foreground FCM message received', tag: 'Notification');

    final title =
        message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();
    final payloadRoute = message.data['route']?.toString();

    await _showLocalNotification(
      id: message.hashCode,
      title: title,
      body: body,
      payload: payloadRoute,
      forceSound: true,
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    AppLogger.info(
      'Notification tap opened app (data: ${message.data})',
      tag: 'Notification',
    );
  }

  Future<void> _showLocalNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
    bool forceSound = true,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      sound: forceSound
          ? const RawResourceAndroidNotificationSound(_androidCustomSound)
          : null,
      category: AndroidNotificationCategory.message,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: forceSound ? _iosCustomSound : null,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title ?? 'DattSoap',
      body ?? 'New notification',
      details,
      payload: payload,
    );
  }

  Future<String?> getToken() async {
    final messaging = _firebaseMessaging;
    if (messaging == null) return null;
    return messaging.getToken();
  }

  Future<void> publishNotificationEvent({
    required String title,
    required String body,
    required String eventType,
    Set<String> targetUserIds = const <String>{},
    Set<UserRole> targetRoles = const <UserRole>{},
    Map<String, dynamic>? data,
    String? route,
    bool forceSound = true,
    bool includeManagers = true,
  }) async {
    // Auto-add manager roles if enabled
    final expandedRoles = <UserRole>{...targetRoles};
    if (includeManagers) {
      expandedRoles.addAll({
        UserRole.admin,
        UserRole.owner,
        UserRole.productionManager,
        UserRole.salesManager,
        UserRole.dispatchManager,
        UserRole.dealerManager,
        UserRole.vehicleMaintenanceManager,
      });
    }

    final normalizedUserIds = targetUserIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
    final normalizedRoles = <String>{
      ...expandedRoles.map((e) => e.value.trim()),
      ...expandedRoles.map((e) => e.name.trim()),
      ...expandedRoles.map((e) => e.value.trim().toLowerCase()),
      ...expandedRoles.map((e) => e.name.trim().toLowerCase()),
    }.where((value) => value.isNotEmpty).toSet();

    if (normalizedUserIds.isEmpty && normalizedRoles.isEmpty) {
      AppLogger.warning(
        'publishNotificationEvent ignored (no target users/roles)',
        tag: 'Notification',
      );
      return;
    }

    final nowUtc = DateTime.now().toUtc();
    final eventId = await _nextNotificationEventId();
    String? createdById;
    String? createdByEmail;
    try {
      final authUser = FirebaseAuth.instance.currentUser;
      createdById = authUser?.uid;
      createdByEmail = authUser?.email;
    } catch (_) {
      createdById = null;
      createdByEmail = null;
    }
    final normalizedData = data == null || data.isEmpty
        ? null
        : _normalizeNotificationData(data);
    final payload = <String, dynamic>{
      'eventId': eventId,
      'title': title.trim(),
      'body': body.trim(),
      'eventType': eventType.trim().isEmpty ? 'general' : eventType.trim(),
      'targetUserIds': normalizedUserIds.toList()..sort(),
      'targetRoles': normalizedRoles.toList()..sort(),
      'forceSound': forceSound,
      if (route != null && route.trim().isNotEmpty) 'route': route.trim(),
      if (normalizedData != null && normalizedData.isNotEmpty)
        'data': normalizedData,
      'createdAtClientUtc': nowUtc.toIso8601String(),
      'createdById': createdById,
      'createdByEmail': createdByEmail,
    };
    final outboxEvent = <String, dynamic>{
      'eventId': eventId,
      'payload': payload,
      'queuedAtUtc': nowUtc.toIso8601String(),
      'updatedAtUtc': nowUtc.toIso8601String(),
      'attemptCount': 0,
      'nextRetryAtUtc': null,
      'lastError': null,
    };
    await _upsertOutboxEvent(outboxEvent);

    final firestore = await _resolveFirestore();
    if (firestore == null) {
      AppLogger.warning(
        'publishNotificationEvent deferred (Firestore unavailable), eventId=$eventId',
        tag: 'Notification',
      );
      _scheduleOutboxDrain();
      return;
    }

    final published = await _tryPublishOutboxEvent(
      outboxEvent,
      firestore: firestore,
      trigger: 'direct_publish',
    );
    if (published) {
      await _removeOutboxEvent(eventId);
      return;
    }
    await _markOutboxPublishFailure(
      eventId,
      reason: 'direct_publish_failed',
    );
    _scheduleOutboxDrain();
  }

  Map<String, dynamic> _normalizeNotificationData(Map<String, dynamic> data) {
    try {
      final normalized = jsonDecode(jsonEncode(data));
      if (normalized is Map) {
        return Map<String, dynamic>.from(normalized);
      }
    } catch (_) {
      // Fallback normalization below keeps all values serializable.
    }

    final normalized = <String, dynamic>{};
    data.forEach((key, value) {
      final normalizedKey = key.toString().trim();
      if (normalizedKey.isEmpty) return;
      normalized[normalizedKey] = _normalizeNotificationValue(value);
    });
    return normalized;
  }

  dynamic _normalizeNotificationValue(dynamic value) {
    if (value == null || value is num || value is bool || value is String) {
      return value;
    }
    if (value is DateTime) return value.toIso8601String();
    if (value is Map) {
      final map = <String, dynamic>{};
      value.forEach((key, val) {
        final normalizedKey = key.toString().trim();
        if (normalizedKey.isEmpty) return;
        map[normalizedKey] = _normalizeNotificationValue(val);
      });
      return map;
    }
    if (value is Iterable) {
      return value.map(_normalizeNotificationValue).toList(growable: false);
    }
    return value.toString();
  }

  Future<String> _nextNotificationEventId() async {
    final prefs = await SharedPreferences.getInstance();
    final instanceId = await _loadOutboxInstanceId(prefs);
    final next = (prefs.getInt(_eventOutboxSequencePrefsKey) ?? 0) + 1;
    await prefs.setInt(_eventOutboxSequencePrefsKey, next);
    return 'evt_${instanceId}_$next';
  }

  Future<String> _loadOutboxInstanceId(SharedPreferences prefs) async {
    final existing = prefs.getString(_eventOutboxInstancePrefsKey)?.trim();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < 10; i++) {
      buffer.write(chars[rand.nextInt(chars.length)]);
    }
    final generated = buffer.toString();
    await prefs.setString(_eventOutboxInstancePrefsKey, generated);
    return generated;
  }

  Future<List<Map<String, dynamic>>> _loadOutboxEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_eventOutboxPrefsKey);
    if (raw == null || raw.trim().isEmpty) {
      return <Map<String, dynamic>>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <Map<String, dynamic>>[];
      }
      final events = <Map<String, dynamic>>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final eventId = map['eventId']?.toString().trim();
        final payload = map['payload'];
        if (eventId == null || eventId.isEmpty || payload is! Map) continue;
        events.add(<String, dynamic>{
          'eventId': eventId,
          'payload': Map<String, dynamic>.from(payload),
          'queuedAtUtc': map['queuedAtUtc']?.toString(),
          'updatedAtUtc': map['updatedAtUtc']?.toString(),
          'attemptCount': (map['attemptCount'] as num?)?.toInt() ?? 0,
          'nextRetryAtUtc': map['nextRetryAtUtc']?.toString(),
          'lastError': map['lastError']?.toString(),
        });
      }
      return events;
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _saveOutboxEvents(List<Map<String, dynamic>> events) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = events.length <= _maxOutboxEntries
        ? events
        : events.sublist(events.length - _maxOutboxEntries);
    await prefs.setString(_eventOutboxPrefsKey, jsonEncode(normalized));
  }

  Future<void> _upsertOutboxEvent(Map<String, dynamic> event) async {
    final eventId = event['eventId']?.toString().trim();
    if (eventId == null || eventId.isEmpty) return;

    final outbox = await _loadOutboxEvents();
    outbox.removeWhere((entry) => entry['eventId'] == eventId);
    outbox.add(event);
    await _saveOutboxEvents(outbox);
  }

  Future<void> _removeOutboxEvent(String eventId) async {
    final outbox = await _loadOutboxEvents();
    final before = outbox.length;
    outbox.removeWhere((entry) => entry['eventId'] == eventId);
    if (before != outbox.length) {
      await _saveOutboxEvents(outbox);
    }
  }

  Future<void> _markOutboxPublishFailure(
    String eventId, {
    required String reason,
  }) async {
    final outbox = await _loadOutboxEvents();
    if (outbox.isEmpty) return;

    final nowUtc = DateTime.now().toUtc();
    var changed = false;
    for (var i = 0; i < outbox.length; i++) {
      final entry = outbox[i];
      if (entry['eventId']?.toString() != eventId) continue;
      outbox[i] = _markOutboxEventAttemptFailure(
        entry,
        nowUtc: nowUtc,
        reason: reason,
      );
      changed = true;
      break;
    }
    if (changed) {
      await _saveOutboxEvents(outbox);
    }
  }

  bool _shouldAttemptOutboxEventNow(
    Map<String, dynamic> entry, {
    required DateTime nowUtc,
  }) {
    final retryRaw = entry['nextRetryAtUtc']?.toString();
    if (retryRaw == null || retryRaw.isEmpty) return true;
    final retryAt = DateTime.tryParse(retryRaw);
    if (retryAt == null) return true;
    return !retryAt.isAfter(nowUtc);
  }

  Map<String, dynamic> _markOutboxEventAttemptFailure(
    Map<String, dynamic> entry, {
    required DateTime nowUtc,
    required String reason,
  }) {
    final attempt = (entry['attemptCount'] as num?)?.toInt() ?? 0;
    final nextAttempt = attempt + 1;
    final nextRetry = nowUtc.add(_outboxBackoffForAttempt(nextAttempt));
    return <String, dynamic>{
      ...entry,
      'attemptCount': nextAttempt,
      'updatedAtUtc': nowUtc.toIso8601String(),
      'nextRetryAtUtc': nextRetry.toIso8601String(),
      'lastError': reason,
    };
  }

  Duration _outboxBackoffForAttempt(int attempt) {
    final boundedAttempt = attempt.clamp(1, 9);
    final seconds = (15 * (1 << (boundedAttempt - 1))).clamp(15, 900);
    return Duration(seconds: seconds.toInt());
  }

  bool _isNotificationPublishSuppressed({
    required String? authUid,
    required DateTime nowUtc,
  }) {
    if (authUid == null || authUid.isEmpty) return false;
    if (_notificationEventsDeniedAuthUid != authUid ||
        _notificationEventsDeniedAtUtc == null) {
      return false;
    }
    return nowUtc.difference(_notificationEventsDeniedAtUtc!) <
        _notificationEventsRetryBackoff;
  }

  Future<bool> _tryPublishOutboxEvent(
    Map<String, dynamic> entry, {
    required FirebaseFirestore firestore,
    required String trigger,
  }) async {
    final eventId = entry['eventId']?.toString().trim();
    final payloadRaw = entry['payload'];
    if (eventId == null || eventId.isEmpty || payloadRaw is! Map) {
      return false;
    }
    final payload = Map<String, dynamic>.from(payloadRaw);
    final nowUtc = DateTime.now().toUtc();
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (_isNotificationPublishSuppressed(authUid: authUid, nowUtc: nowUtc)) {
      return false;
    }

    final remotePayload = <String, dynamic>{
      ...payload,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await firestore.collection(_eventCollection).doc(eventId).set(
        remotePayload,
        SetOptions(merge: true),
      );
      AppLogger.info(
        'notification_events/$eventId queued (trigger=$trigger)',
        tag: 'Notification',
      );

      try {
        final functions = _functions ?? FirebaseFunctions.instance;
        await functions.httpsCallable('dispatchNotificationEvent').call({
          'eventId': eventId,
        });
      } catch (e) {
        AppLogger.debug(
          'dispatchNotificationEvent callable not available: $e',
          tag: 'Notification',
        );
      }
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        _notificationEventsDeniedAuthUid = authUid;
        _notificationEventsDeniedAtUtc = nowUtc;
      }
      AppLogger.warning(
        'Failed to queue notification event ($trigger): ${e.code} ${e.message}',
        tag: 'Notification',
      );
      return false;
    } catch (e) {
      AppLogger.warning(
        'Failed to queue notification event ($trigger): $e',
        tag: 'Notification',
      );
      return false;
    }
  }

  void _scheduleOutboxDrain({Duration delay = _outboxDrainRetryDelay}) {
    _outboxDrainTimer?.cancel();
    _outboxDrainTimer = Timer(delay, () {
      unawaited(_drainNotificationEventOutbox(trigger: 'scheduled_retry'));
    });
  }

  Future<void> _drainNotificationEventOutbox({required String trigger}) async {
    if (_isDrainingOutbox) return;
    _isDrainingOutbox = true;

    try {
      final firestore = await _resolveFirestore();
      if (firestore == null) {
        _scheduleOutboxDrain();
        return;
      }

      var outbox = await _loadOutboxEvents();
      if (outbox.isEmpty) {
        _outboxDrainTimer?.cancel();
        _outboxDrainTimer = null;
        return;
      }

      final nowUtc = DateTime.now().toUtc();
      var changed = false;
      final remaining = <Map<String, dynamic>>[];

      for (final entry in outbox) {
        if (!_shouldAttemptOutboxEventNow(entry, nowUtc: nowUtc)) {
          remaining.add(entry);
          continue;
        }

        final published = await _tryPublishOutboxEvent(
          entry,
          firestore: firestore,
          trigger: trigger,
        );
        if (published) {
          changed = true;
          continue;
        }

        remaining.add(
          _markOutboxEventAttemptFailure(
            entry,
            nowUtc: nowUtc,
            reason: 'drain_publish_failed',
          ),
        );
        changed = true;
      }

      if (changed || remaining.length != outbox.length) {
        await _saveOutboxEvents(remaining);
      }

      if (remaining.isEmpty) {
        _outboxDrainTimer?.cancel();
        _outboxDrainTimer = null;
      } else {
        _scheduleOutboxDrain();
      }
    } finally {
      _isDrainingOutbox = false;
    }
  }

  Future<void> dispose() async {
    _outboxDrainTimer?.cancel();
    _outboxDrainTimer = null;
    await _messageSub?.cancel();
    await _messageOpenedSub?.cancel();
    await _tokenRefreshSub?.cancel();
    _messageSub = null;
    _messageOpenedSub = null;
    _tokenRefreshSub = null;
  }
}
