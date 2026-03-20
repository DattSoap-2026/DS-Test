import 'package:flutter/foundation.dart';

@immutable
class SyncRollbackOperation {
  const SyncRollbackOperation({
    required this.collectionName,
    required this.documentId,
    required this.action,
    this.payload,
  });

  final String collectionName;
  final String documentId;
  final String action;
  final Map<String, dynamic>? payload;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'collectionName': collectionName,
      'documentId': documentId,
      'action': action,
      if (payload != null) 'payload': payload,
    };
  }

  factory SyncRollbackOperation.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];
    return SyncRollbackOperation(
      collectionName: json['collectionName']?.toString() ?? '',
      documentId: json['documentId']?.toString() ?? '',
      action: json['action']?.toString() ?? 'noop',
      payload: rawPayload is Map
          ? Map<String, dynamic>.from(
              rawPayload.map((key, value) => MapEntry(key.toString(), value)),
            )
          : null,
    );
  }
}

class OptimisticSyncEnvelope {
  OptimisticSyncEnvelope._();

  static const String _payloadKey = 'payload';
  static const String _metaKey = '__optimistic_sync';
  static const String _groupIdKey = 'groupId';
  static const String _rollbackKey = 'rollback';
  static const String _failureMessageKey = 'failureMessage';

  static Map<String, dynamic> wrap({
    required Map<String, dynamic> payload,
    required String groupId,
    required List<SyncRollbackOperation> rollbackOperations,
    String? failureMessage,
  }) {
    return <String, dynamic>{
      _payloadKey: payload,
      _metaKey: <String, dynamic>{
        'version': 1,
        _groupIdKey: groupId,
        _rollbackKey: rollbackOperations
            .map((operation) => operation.toJson())
            .toList(growable: false),
        if (failureMessage != null && failureMessage.trim().isNotEmpty)
          _failureMessageKey: failureMessage.trim(),
      },
    };
  }

  static bool isWrapped(Map<String, dynamic> decoded) {
    return decoded[_metaKey] is Map && decoded[_payloadKey] is Map;
  }

  static Map<String, dynamic> extractPayload(Map<String, dynamic> decoded) {
    if (!isWrapped(decoded)) {
      return decoded;
    }

    final rawPayload = decoded[_payloadKey] as Map<dynamic, dynamic>;
    return Map<String, dynamic>.from(
      rawPayload.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  static String? extractGroupId(Map<String, dynamic> decoded) {
    if (!isWrapped(decoded)) {
      return null;
    }
    final meta = Map<String, dynamic>.from(decoded[_metaKey] as Map);
    final groupId = meta[_groupIdKey]?.toString().trim();
    return groupId == null || groupId.isEmpty ? null : groupId;
  }

  static String? extractFailureMessage(Map<String, dynamic> decoded) {
    if (!isWrapped(decoded)) {
      return null;
    }
    final meta = Map<String, dynamic>.from(decoded[_metaKey] as Map);
    final message = meta[_failureMessageKey]?.toString().trim();
    return message == null || message.isEmpty ? null : message;
  }

  static List<SyncRollbackOperation> extractRollbackOperations(
    Map<String, dynamic> decoded,
  ) {
    if (!isWrapped(decoded)) {
      return const <SyncRollbackOperation>[];
    }

    final meta = Map<String, dynamic>.from(decoded[_metaKey] as Map);
    final rawRollback = meta[_rollbackKey];
    if (rawRollback is! List) {
      return const <SyncRollbackOperation>[];
    }

    return rawRollback
        .whereType<Map>()
        .map(
          (entry) => SyncRollbackOperation.fromJson(
            Map<String, dynamic>.from(
              entry.map((key, value) => MapEntry(key.toString(), value)),
            ),
          ),
        )
        .where(
          (operation) =>
              operation.collectionName.trim().isNotEmpty &&
              operation.documentId.trim().isNotEmpty,
        )
        .toList(growable: false);
  }
}
