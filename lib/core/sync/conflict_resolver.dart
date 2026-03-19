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
  /// Creates an immutable conflict resolution result.
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

  /// Returns the protocol action code expected by the sync pipeline.
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

  /// Resolves a conflict between a local record and a Firebase record.
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
        reason: 'Both local and Firebase records are absent.',
      );
    }

    if (firebaseRecord == null) {
      return _log(
        action: SyncConflictAction.pushLocal,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: 'Firebase record is missing, so the local record wins.',
      );
    }

    if (localRecord == null) {
      return _log(
        action: SyncConflictAction.useFirebase,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: 'Local record is missing, so Firebase wins.',
      );
    }

    if (CollectionRegistry.isFinancial(normalizedCollection) ||
        CollectionRegistry.isFinancial(localRecord.runtimeType.toString())) {
      final localVersion = _readVersion(localRecord);
      final remoteVersion = _readVersion(firebaseRecord);
      final localModified = _readModifiedAt(localRecord);
      final remoteModified = _readModifiedAt(firebaseRecord);
      if (localVersion == remoteVersion && localModified == remoteModified) {
        return _log(
          action: SyncConflictAction.inSync,
          collectionName: normalizedCollection,
          documentId: resolvedDocumentId,
          reason: 'Financial record already matches on version and timestamp.',
        );
      }
      await _createConflictRecord(
        entityId: resolvedDocumentId,
        entityType: normalizedCollection,
        localRecord: localRecord,
        firebaseRecord: firebaseRecord,
      );
      return _log(
        action: SyncConflictAction.manualResolution,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: 'Financial records never auto-overwrite when both sides differ.',
      );
    }

    if (CollectionRegistry.firebaseWins(normalizedCollection) ||
        CollectionRegistry.firebaseWins(localRecord.runtimeType.toString())) {
      return _log(
        action: SyncConflictAction.useFirebase,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: 'Firebase is the source of truth for this master data.',
      );
    }

    final localVersion = _readVersion(localRecord);
    final remoteVersion = _readVersion(firebaseRecord);
    if (localVersion > remoteVersion) {
      return _log(
        action: SyncConflictAction.pushLocal,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: 'Local record has a higher version.',
      );
    }
    if (remoteVersion > localVersion) {
      return _log(
        action: SyncConflictAction.useFirebase,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: 'Firebase record has a higher version.',
      );
    }

    final localModified = _readModifiedAt(localRecord);
    final remoteModified = _readModifiedAt(firebaseRecord);
    if (localModified != null &&
        remoteModified != null &&
        localModified.isAfter(remoteModified)) {
      return _log(
        action: SyncConflictAction.pushLocal,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: 'Versions match and the local record is newer.',
      );
    }
    if (localModified != null &&
        remoteModified != null &&
        remoteModified.isAfter(localModified)) {
      return _log(
        action: SyncConflictAction.useFirebase,
        collectionName: normalizedCollection,
        documentId: resolvedDocumentId,
        reason: 'Versions match and the Firebase record is newer.',
      );
    }

    return _log(
      action: SyncConflictAction.inSync,
      collectionName: normalizedCollection,
      documentId: resolvedDocumentId,
      reason: 'Version and last-modified values match.',
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
  }) async {
    final now = DateTime.now();
    final conflict = ConflictEntity()
      ..id = 'conflict_${entityType}_${entityId}_${now.microsecondsSinceEpoch}'
      ..entityId = entityId
      ..entityType = entityType
      ..localData = jsonEncode(_serializeRecord(localRecord))
      ..serverData = jsonEncode(_serializeRecord(firebaseRecord))
      ..conflictDate = now
      ..resolved = false
      ..resolutionStrategy = ResolutionStrategy.manualMerge
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

  static int _readVersion(dynamic target) {
    final value = _readField(target, const <String>['version']);
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 1;
  }

  static DateTime? _readModifiedAt(dynamic target) {
    final value = _readField(
      target,
      const <String>[
        'lastModified',
        'updatedAt',
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
      return target[field];
    }

    try {
      switch (field) {
        case 'version':
          return (target as dynamic).version;
        case 'lastModified':
          return (target as dynamic).lastModified;
        case 'updatedAt':
          return (target as dynamic).updatedAt;
        case 'timestamp':
          return (target as dynamic).timestamp;
        case 'occurredAt':
          return (target as dynamic).occurredAt;
        case 'createdAt':
          return (target as dynamic).createdAt;
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
      return target;
    }
    if (target is Map) {
      return Map<String, dynamic>.from(target);
    }
    try {
      return (target as dynamic).toJson();
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
