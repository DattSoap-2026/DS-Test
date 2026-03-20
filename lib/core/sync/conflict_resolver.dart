import 'dart:convert';

import '../../data/local/base_entity.dart';
import '../../data/local/entities/conflict_entity.dart';
import '../database/isar_service.dart';
import '../utils/sync_logger.dart';
import 'collection_registry.dart';

/// Conflict winner metadata retained for legacy compatibility.
enum ConflictWinner { local, remote }

/// Supported sync conflict actions.
enum SyncConflictAction { pushLocal, useFirebase, inSync, manualResolution }

/// Generic conflict resolution result.
class ConflictResolution {
  const ConflictResolution({
    required this.action,
    required this.collectionName,
    required this.documentId,
    required this.reason,
    required this.timestamp,
  });

  final SyncConflictAction action;
  final String collectionName;
  final String documentId;
  final String reason;
  final DateTime timestamp;

  String get code {
    switch (action) {
      case SyncConflictAction.pushLocal:
        return 'push_local';
      case SyncConflictAction.useFirebase:
        return 'use_firebase';
      case SyncConflictAction.inSync:
        return 'in_sync';
      case SyncConflictAction.manualResolution:
        return 'manual_resolution';
    }
  }
}

/// Resolves sync conflicts across entity types.
class ConflictResolver {
  ConflictResolver._();

  static const Set<String> _serverWinsCollections = <String>{
    CollectionRegistry.units,
    CollectionRegistry.productCategories,
    CollectionRegistry.productTypes,
    CollectionRegistry.attendances,
  };

  static const Set<String> _localPendingWinsCollections = <String>{
    CollectionRegistry.sales,
  };

  static Future<ConflictResolution> resolve({
    required dynamic localRecord,
    required dynamic firebaseRecord,
    required String collectionName,
    String? documentId,
  }) async {
    final normalizedCollection = CollectionRegistry.canonical(collectionName);
    final resolvedDocumentId = documentId?.trim().isNotEmpty == true
        ? documentId!.trim()
        : _readDocumentId(firebaseRecord) ?? _readDocumentId(localRecord) ?? '';

    if (firebaseRecord == null && localRecord == null) {
      return _log(
        action: SyncConflictAction.inSync,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: 'Both local and remote records are absent.',
      );
    }

    if (firebaseRecord == null) {
      return _log(
        action: SyncConflictAction.pushLocal,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: 'Remote record is missing, so the local record wins.',
      );
    }

    if (localRecord == null) {
      return _log(
        action: SyncConflictAction.useFirebase,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: 'Local record is missing, so the remote record wins.',
      );
    }

    final recordsDiffer = _recordsDiffer(localRecord, firebaseRecord);
    final localModified = _readModifiedAt(localRecord);
    final remoteModified = _readModifiedAt(firebaseRecord);

    if (!recordsDiffer && _sameInstant(localModified, remoteModified)) {
      return _log(
        action: SyncConflictAction.inSync,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: 'Local and remote records already match.',
      );
    }

    if (_shouldServerAlwaysWin(normalizedCollection)) {
      final resolution = await _recordAndLog(
        action: SyncConflictAction.useFirebase,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: 'Server is the source of truth for this module.',
        localRecord: localRecord,
        firebaseRecord: firebaseRecord,
        shouldPersist: recordsDiffer,
      );
      return resolution;
    }

    if (_shouldKeepLocalUntilSynced(normalizedCollection, localRecord)) {
      final resolution = await _recordAndLog(
        action: SyncConflictAction.pushLocal,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: 'Unsynced local sales changes must win until push completes.',
        localRecord: localRecord,
        firebaseRecord: firebaseRecord,
        shouldPersist: recordsDiffer,
      );
      return resolution;
    }

    if (localModified != null && remoteModified != null) {
      if (localModified.isAfter(remoteModified)) {
        return _recordAndLog(
          action: SyncConflictAction.pushLocal,
          collectionName: normalizedCollection,
          documentId: resolvedDocumentId,
          reason: 'Local updatedAt is newer than remote updatedAt.',
          localRecord: localRecord,
          firebaseRecord: firebaseRecord,
          shouldPersist: recordsDiffer,
        );
      }
      return _recordAndLog(
        action: SyncConflictAction.useFirebase,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: remoteModified.isAfter(localModified)
            ? 'Remote updatedAt is newer than local updatedAt.'
            : 'Timestamps are equal, so the server wins by default.',
        localRecord: localRecord,
        firebaseRecord: firebaseRecord,
        shouldPersist: recordsDiffer,
      );
    }

    if (!recordsDiffer) {
      return _log(
        action: SyncConflictAction.inSync,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: 'Local and remote records are structurally identical.',
      );
    }

    return _recordAndLog(
      action: SyncConflictAction.useFirebase,
      collectionName: normalizedCollection,
      documentId: resolvedDocumentId,
      reason: 'Unable to compare timestamps, so the server wins safely.',
      localRecord: localRecord,
      firebaseRecord: firebaseRecord,
      shouldPersist: true,
    );
  }

  static Future<ConflictResolution> _recordAndLog({
    required SyncConflictAction action,
    required String collectionName,
    required String documentId,
    required String reason,
    required dynamic localRecord,
    required dynamic firebaseRecord,
    required bool shouldPersist,
  }) async {
    if (shouldPersist) {
      await _createConflictRecord(
        entityId: documentId,
        entityType: collectionName,
        localRecord: localRecord,
        firebaseRecord: firebaseRecord,
        action: action,
      );
    }
    return _log(
      action: action,
      collectionName: collectionName,
      documentId: documentId,
      reason: reason,
    );
  }

  static ConflictResolution _log({
    required SyncConflictAction action,
    required String collectionName,
    required String documentId,
    required String reason,
  }) {
    final result = ConflictResolution(
      action: action,
      collectionName: collectionName,
      documentId: documentId,
      reason: reason,
      timestamp: DateTime.now(),
    );
    SyncLogger.instance.i(
      'Conflict resolved for ${result.collectionName}/${result.documentId}: ${result.code} ($reason)',
      time: result.timestamp,
    );
    return result;
  }

  static Future<void> _createConflictRecord({
    required String entityId,
    required String entityType,
    required dynamic localRecord,
    required dynamic firebaseRecord,
    required SyncConflictAction action,
  }) async {
    final now = DateTime.now();
    final conflict = ConflictEntity()
      ..id = 'conflict_${entityType}_${entityId}_${now.microsecondsSinceEpoch}'
      ..entityId = entityId
      ..entityType = entityType
      ..localData = jsonEncode(_serializeRecord(localRecord))
      ..serverData = jsonEncode(_serializeRecord(firebaseRecord))
      ..conflictDate = now
      ..resolved = action != SyncConflictAction.manualResolution
      ..resolutionStrategy = _resolutionStrategyFor(action)
      ..resolvedBy = 'conflict_resolver'
      ..resolvedAt = action == SyncConflictAction.manualResolution ? null : now
      ..updatedAt = now
      ..syncStatus = SyncStatus.synced
      ..isSynced = true
      ..isDeleted = false
      ..lastSynced = now
      ..version = 1
      ..deviceId = '';

    await IsarService.instance.isar.writeTxn(() async {
      await IsarService.instance.collection<ConflictEntity>().put(conflict);
    });
  }

  static ResolutionStrategy _resolutionStrategyFor(
    SyncConflictAction action,
  ) {
    switch (action) {
      case SyncConflictAction.pushLocal:
        return ResolutionStrategy.useLocal;
      case SyncConflictAction.useFirebase:
      case SyncConflictAction.inSync:
        return ResolutionStrategy.useServer;
      case SyncConflictAction.manualResolution:
        return ResolutionStrategy.manualMerge;
    }
  }

  static bool _shouldServerAlwaysWin(String collectionName) {
    return _serverWinsCollections.contains(collectionName) ||
        CollectionRegistry.firebaseWins(collectionName);
  }

  static bool _shouldKeepLocalUntilSynced(
    String collectionName,
    dynamic localRecord,
  ) {
    return _localPendingWinsCollections.contains(collectionName) &&
        _isLocalPending(localRecord);
  }

  static bool _isLocalPending(dynamic target) {
    final syncStatus = _readField(target, const <String>['syncStatus']);
    final statusName = syncStatus?.toString().toLowerCase();
    if (statusName != null && statusName.contains('pending')) {
      return true;
    }
    final isSynced = _readField(target, const <String>['isSynced']);
    if (isSynced is bool) {
      return !isSynced;
    }
    return false;
  }

  static bool _recordsDiffer(dynamic localRecord, dynamic remoteRecord) {
    final localSerialized = jsonEncode(_normalizeComparable(_serializeRecord(localRecord)));
    final remoteSerialized = jsonEncode(
      _normalizeComparable(_serializeRecord(remoteRecord)),
    );
    return localSerialized != remoteSerialized;
  }

  static bool _sameInstant(DateTime? left, DateTime? right) {
    if (left == null || right == null) {
      return false;
    }
    return left.isAtSameMomentAs(right);
  }

  static Object? _normalizeComparable(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList(growable: false)
        ..sort();
      return <String, Object?>{
        for (final key in keys)
          if (!_isVolatileField(key))
            key: _normalizeComparable(value[key]),
      };
    }
    if (value is List) {
      return value.map(_normalizeComparable).toList(growable: false);
    }
    return value;
  }

  static bool _isVolatileField(String field) {
    return field == 'lastSynced' ||
        field == 'syncStatus' ||
        field == 'deviceId' ||
        field == 'version';
  }

  static DateTime? _readModifiedAt(dynamic target) {
    final value = _readField(
      target,
      const <String>[
        'updatedAt',
        'lastModified',
        'timestamp',
        'occurredAt',
        'createdAt',
      ],
    );
    return _asDateTime(value);
  }

  static String? _readDocumentId(dynamic target) {
    final value = _readField(
      target,
      const <String>['firebaseId', 'id', 'movementId', 'documentId'],
    );
    final normalized = value?.toString().trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  static dynamic _readField(dynamic target, List<String> candidates) {
    for (final candidate in candidates) {
      final value = _readSingleField(target, candidate);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  static dynamic _readSingleField(dynamic target, String field) {
    if (target == null) {
      return null;
    }
    if (target is Map<String, dynamic>) {
      return target[field];
    }
    if (target is Map) {
      for (final entry in target.entries) {
        if (entry.key.toString() == field) {
          return entry.value;
        }
      }
      return null;
    }

    try {
      switch (field) {
        case 'updatedAt':
          return (target as dynamic).updatedAt;
        case 'lastModified':
          return (target as dynamic).lastModified;
        case 'timestamp':
          return (target as dynamic).timestamp;
        case 'occurredAt':
          return (target as dynamic).occurredAt;
        case 'createdAt':
          return (target as dynamic).createdAt;
        case 'syncStatus':
          return (target as dynamic).syncStatus;
        case 'isSynced':
          return (target as dynamic).isSynced;
        case 'firebaseId':
          return (target as dynamic).firebaseId;
        case 'id':
          return (target as dynamic).id;
        case 'movementId':
          return (target as dynamic).movementId;
        case 'documentId':
          return (target as dynamic).documentId;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static Object? _serializeRecord(dynamic target) {
    if (target == null) {
      return null;
    }
    if (target is Map<String, dynamic>) {
      return target.map(
        (key, value) => MapEntry(key.toString(), _serializeRecord(value)),
      );
    }
    if (target is Map) {
      return target.map(
        (key, value) => MapEntry(key.toString(), _serializeRecord(value)),
      );
    }
    if (target is List) {
      return target.map(_serializeRecord).toList(growable: false);
    }
    if (target is DateTime) {
      return target.toIso8601String();
    }
    try {
      final json = (target as dynamic).toJson();
      if (json is Map<String, dynamic>) {
        return json.map(
          (key, value) => MapEntry(key.toString(), _serializeRecord(value)),
        );
      }
      return json;
    } catch (_) {
      return target.toString();
    }
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.tryParse(value.toString());
  }
}
