import 'dart:convert';

import 'package:flutter_app/data/local/base_entity.dart';

class OutboxDecodedPayload {
  final Map<String, dynamic> payload;
  final Map<String, dynamic> meta;
  final bool wrapped;

  const OutboxDecodedPayload({
    required this.payload,
    required this.meta,
    required this.wrapped,
  });
}

class OutboxCodec {
  static const String metaKey = '__outbox';
  static const String payloadKey = 'payload';
  static const String idempotencyKeyField = 'idempotencyKey';
  static const String commandKeyMetaField = 'commandKey';
  static const String actorIdMetaField = 'actorId';
  static const String actorUidMetaField = 'actorUid';
  static const String actorEmailMetaField = 'actorEmail';
  static const int version = 1;
  static const int defaultMaxAttempts = 8;

  static String buildCommandKey({
    required String collection,
    required String action,
    required Map<String, dynamic> payload,
    String? queueId,
  }) {
    final recordKey = _extractRecordKey(payload);
    if (recordKey != null && recordKey.isNotEmpty) {
      return '${_sanitizeKey(collection)}_${_sanitizeKey(action)}_${_sanitizeKey(recordKey)}';
    }
    if (queueId != null && queueId.trim().isNotEmpty) {
      return '${_sanitizeKey(collection)}_${_sanitizeKey(action)}_${_sanitizeKey(queueId)}';
    }
    final forHash = Map<String, dynamic>.from(payload)
      ..remove(idempotencyKeyField);
    final digest = fastHash(jsonEncode(forHash)).toString();
    return '${_sanitizeKey(collection)}_${_sanitizeKey(action)}_hash_$digest';
  }

  static String? readIdempotencyKey(Map<String, dynamic> payload) {
    final raw = payload[idempotencyKeyField]?.toString().trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  static Map<String, dynamic> ensureCommandPayload({
    required String collection,
    required String action,
    required Map<String, dynamic> payload,
    Map<String, dynamic>? existingMeta,
    String? queueId,
  }) {
    final normalized = Map<String, dynamic>.from(payload);
    final existingPayloadKey = readIdempotencyKey(normalized);
    if (existingPayloadKey != null) {
      normalized[idempotencyKeyField] = existingPayloadKey;
      return normalized;
    }

    final existingMetaKey = existingMeta?[commandKeyMetaField]
        ?.toString()
        .trim();
    final commandKey = (existingMetaKey != null && existingMetaKey.isNotEmpty)
        ? existingMetaKey
        : buildCommandKey(
            collection: collection,
            action: action,
            payload: normalized,
            queueId: queueId,
          );
    normalized[idempotencyKeyField] = commandKey;
    return normalized;
  }

  static String buildQueueId(
    String collection,
    Map<String, dynamic> payload, {
    String? explicitRecordKey,
  }) {
    final key = explicitRecordKey ?? _extractRecordKey(payload);
    if (key == null || key.isEmpty) {
      final digest = fastHash(jsonEncode(payload)).toString();
      return 'outbox_${collection}_hash_$digest';
    }
    return 'outbox_${collection}_${_sanitizeKey(key)}';
  }

  static String encodeEnvelope({
    required Map<String, dynamic> payload,
    Map<String, dynamic>? existingMeta,
    DateTime? now,
    bool resetRetryState = true,
  }) {
    final ts = now ?? DateTime.now();
    final prev = existingMeta ?? const <String, dynamic>{};
    final payloadCommandKey = readIdempotencyKey(payload);
    final meta = <String, dynamic>{
      ...prev,
      'version': version,
      'firstQueuedAt':
          prev['firstQueuedAt']?.toString() ?? ts.toIso8601String(),
      'updatedAt': ts.toIso8601String(),
      'attemptCount': resetRetryState
          ? 0
          : (prev['attemptCount'] as num?)?.toInt() ?? 0,
      'maxAttempts':
          (prev['maxAttempts'] as num?)?.toInt() ?? defaultMaxAttempts,
      'lastAttemptAt': resetRetryState
          ? null
          : prev['lastAttemptAt']?.toString(),
      'lastError': resetRetryState ? null : prev['lastError']?.toString(),
      'nextRetryAt': resetRetryState ? null : prev['nextRetryAt']?.toString(),
      'permanentFailure': resetRetryState
          ? false
          : (prev['permanentFailure'] as bool? ?? false),
      commandKeyMetaField:
          payloadCommandKey ?? prev[commandKeyMetaField]?.toString(),
    };
    return jsonEncode(<String, dynamic>{metaKey: meta, payloadKey: payload});
  }

  static OutboxDecodedPayload decode(
    String dataJson, {
    DateTime? fallbackQueuedAt,
  }) {
    final fallbackMeta = _defaultMeta(fallbackQueuedAt);
    try {
      final decoded = jsonDecode(dataJson);
      if (decoded is! Map) {
        return OutboxDecodedPayload(
          payload: const <String, dynamic>{},
          meta: fallbackMeta,
          wrapped: false,
        );
      }
      final map = Map<String, dynamic>.from(decoded);
      if (map[payloadKey] is Map && map[metaKey] is Map) {
        return OutboxDecodedPayload(
          payload: Map<String, dynamic>.from(map[payloadKey] as Map),
          meta: _normalizeMeta(
            Map<String, dynamic>.from(map[metaKey] as Map),
            fallbackMeta,
          ),
          wrapped: true,
        );
      }
      return OutboxDecodedPayload(
        payload: map,
        meta: fallbackMeta,
        wrapped: false,
      );
    } catch (_) {
      return OutboxDecodedPayload(
        payload: const <String, dynamic>{},
        meta: fallbackMeta,
        wrapped: false,
      );
    }
  }

  static bool isPermanentFailure(Map<String, dynamic> meta) {
    return meta['permanentFailure'] as bool? ?? false;
  }

  static bool shouldRetryNow(Map<String, dynamic> meta, {DateTime? now}) {
    if (isPermanentFailure(meta)) return false;
    final retryAtRaw = meta['nextRetryAt']?.toString();
    if (retryAtRaw == null || retryAtRaw.isEmpty) return true;
    final retryAt = DateTime.tryParse(retryAtRaw);
    if (retryAt == null) return true;
    return !retryAt.isAfter(now ?? DateTime.now());
  }

  static Map<String, dynamic> markFailure(
    Map<String, dynamic> meta,
    Object error, {
    DateTime? now,
  }) {
    final ts = now ?? DateTime.now();
    final normalized = _normalizeMeta(meta, _defaultMeta(ts));
    final attempts = (normalized['attemptCount'] as num?)?.toInt() ?? 0;
    final maxAttempts =
        (normalized['maxAttempts'] as num?)?.toInt() ?? defaultMaxAttempts;
    final nextAttempt = attempts + 1;
    final permanent = nextAttempt >= maxAttempts;
    final delay = _backoffForAttempt(nextAttempt);
    return <String, dynamic>{
      ...normalized,
      'attemptCount': nextAttempt,
      'lastAttemptAt': ts.toIso8601String(),
      'updatedAt': ts.toIso8601String(),
      'lastError': error.toString(),
      'permanentFailure': permanent,
      'nextRetryAt': permanent ? null : ts.add(delay).toIso8601String(),
      'maxAttempts': maxAttempts,
    };
  }

  static Map<String, dynamic> markSuccess(
    Map<String, dynamic> meta, {
    DateTime? now,
  }) {
    final ts = now ?? DateTime.now();
    final normalized = _normalizeMeta(meta, _defaultMeta(ts));
    return <String, dynamic>{
      ...normalized,
      'attemptCount': 0,
      'lastError': null,
      'lastAttemptAt': ts.toIso8601String(),
      'updatedAt': ts.toIso8601String(),
      'nextRetryAt': null,
      'permanentFailure': false,
    };
  }

  static Duration _backoffForAttempt(int attempt) {
    final exponent = attempt <= 0 ? 0 : attempt - 1;
    final seconds = (15 * (1 << exponent)).clamp(15, 3600);
    return Duration(seconds: seconds);
  }

  static Map<String, dynamic> _defaultMeta(DateTime? ts) {
    final now = ts ?? DateTime.now();
    return <String, dynamic>{
      'version': version,
      'firstQueuedAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'attemptCount': 0,
      'maxAttempts': defaultMaxAttempts,
      'lastAttemptAt': null,
      'lastError': null,
      'nextRetryAt': null,
      'permanentFailure': false,
      commandKeyMetaField: null,
    };
  }

  static Map<String, dynamic> _normalizeMeta(
    Map<String, dynamic> meta,
    Map<String, dynamic> fallback,
  ) {
    return <String, dynamic>{
      ...fallback,
      ...meta,
      'version': (meta['version'] as num?)?.toInt() ?? version,
      'attemptCount': (meta['attemptCount'] as num?)?.toInt() ?? 0,
      'maxAttempts':
          (meta['maxAttempts'] as num?)?.toInt() ?? defaultMaxAttempts,
      'permanentFailure': meta['permanentFailure'] as bool? ?? false,
      'firstQueuedAt':
          meta['firstQueuedAt']?.toString() ?? fallback['firstQueuedAt'],
      'updatedAt': meta['updatedAt']?.toString() ?? fallback['updatedAt'],
      'lastAttemptAt': meta['lastAttemptAt']?.toString(),
      'lastError': meta['lastError']?.toString(),
      'nextRetryAt': meta['nextRetryAt']?.toString(),
      commandKeyMetaField:
          meta[commandKeyMetaField]?.toString() ??
          fallback[commandKeyMetaField]?.toString(),
    };
  }

  static String? _extractRecordKey(Map<String, dynamic> payload) {
    final id = payload['id']?.toString().trim();
    if (id != null && id.isNotEmpty) return id;
    final name = payload['name']?.toString().trim();
    if (name != null && name.isNotEmpty) return 'name_$name';
    final employeeDate = [
      payload['employeeId']?.toString().trim(),
      payload['date']?.toString().trim(),
    ];
    if (employeeDate.every((part) => part?.isNotEmpty ?? false)) {
      return '${employeeDate[0]}_${employeeDate[1]}';
    }
    return null;
  }

  static String _sanitizeKey(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'unknown';
    return trimmed.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
  }
}
