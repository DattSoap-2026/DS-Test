import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'stock_movement_entity.g.dart';

@Collection()
class StockMovementEntity extends BaseEntity {
  String? _commandIdOverride;
  int? _movementIndexOverride;
  bool? _isReversalOverride;

  @Index(unique: true, replace: true)
  String get movementId => id;
  set movementId(String value) => id = value;

  String get commandId {
    final override = _commandIdOverride?.trim();
    if (override != null && override.isNotEmpty) {
      return override;
    }

    final separator = id.lastIndexOf(':');
    if (separator <= 0) {
      return id;
    }
    return id.substring(0, separator);
  }
  set commandId(String value) => _commandIdOverride = value;

  int get movementIndex {
    final override = _movementIndexOverride;
    if (override != null) {
      return override;
    }

    final separator = id.lastIndexOf(':');
    if (separator < 0 || separator == id.length - 1) {
      return 0;
    }
    return int.tryParse(id.substring(separator + 1)) ?? 0;
  }
  set movementIndex(int value) => _movementIndexOverride = value;

  @Index()
  late String productId;

  String? productName;

  double quantityBase = 0.0;

  String? get sourceLocationId => source;
  set sourceLocationId(String? value) => source = value;

  String? get destinationLocationId => referenceNumber;
  set destinationLocationId(String? value) => referenceNumber = value;

  @Index()
  late String movementType;

  String? reasonCode;

  @Index()
  String? referenceId;

  String? referenceType;

  @Index()
  late String actorUid;

  @Index()
  late DateTime occurredAt;

  bool get isReversal {
    final override = _isReversalOverride;
    if (override != null) {
      return override;
    }

    final normalizedType = movementType.trim().toLowerCase();
    return normalizedType.contains('reversal');
  }
  set isReversal(bool value) => _isReversalOverride = value;

  // Legacy compatibility fields retained for pre-T9 call sites.
  String? type;
  String? source;
  String? referenceNumber;
  String? userName;
  String? createdBy;
  String? notes;
  @Index()
  String? lotNumber;
  @Index()
  DateTime? expiryDate;
  DateTime? lastModified;

  double get quantity => quantityBase;
  set quantity(double value) => quantityBase = value;

  String get userId => actorUid;
  set userId(String value) => actorUid = value;

  String get reason => reasonCode ?? '';
  set reason(String value) => reasonCode = value;

  DateTime get createdAt => occurredAt;
  set createdAt(DateTime value) => occurredAt = value;

  /// Converts this entity into a sync-safe json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'movementId': movementId,
      'commandId': commandId,
      'movementIndex': movementIndex,
      'productId': productId,
      'productName': productName,
      'quantityBase': quantityBase,
      'sourceLocationId': sourceLocationId,
      'destinationLocationId': destinationLocationId,
      'movementType': movementType,
      'reasonCode': reasonCode,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'actorUid': actorUid,
      'occurredAt': occurredAt.toIso8601String(),
      'isReversal': isReversal,
      'type': type,
      'source': source,
      'referenceNumber': referenceNumber,
      'userName': userName,
      'createdBy': createdBy,
      'notes': notes,
      'lotNumber': lotNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'quantity': quantity,
      'userId': userId,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
      'timestamp': occurredAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastModified': (lastModified ?? updatedAt).toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus.name,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  /// Builds an entity from a sync-safe json map.
  static StockMovementEntity fromJson(Map<String, dynamic> json) {
    final entity = StockMovementEntity()
      ..id = parseString(
        json['id'] ?? json['movementId'] ?? json['firebaseId'],
        fallback: '',
      )
      ..commandId = parseString(
        json['commandId'],
        fallback: parseString(json['id'] ?? json['movementId']),
      )
      ..movementIndex = parseInt(json['movementIndex'])
      ..productId = parseString(
        json['productId'] ?? json['productFirebaseId'],
      )
      ..productName = parseString(json['productName'], fallback: '')
      ..quantityBase = parseDouble(
        json['quantityBase'] ?? json['quantity'],
      )
      ..sourceLocationId = parseString(
        json['sourceLocationId'] ?? json['source'],
        fallback: '',
      )
      ..destinationLocationId = parseString(
        json['destinationLocationId'] ?? json['referenceNumber'],
        fallback: '',
      )
      ..movementType = parseString(
        json['movementType'] ?? json['type'],
        fallback: 'IN',
      )
      ..reasonCode = parseString(
        json['reasonCode'] ?? json['reason'],
        fallback: '',
      )
      ..referenceId = parseString(json['referenceId'], fallback: '')
      ..referenceType = parseString(json['referenceType'], fallback: '')
      ..actorUid = parseString(
        json['actorUid'] ?? json['userId'],
        fallback: '',
      )
      ..occurredAt = parseDate(
        json['occurredAt'] ?? json['timestamp'] ?? json['createdAt'],
      )
      ..isReversal = parseBool(json['isReversal'])
      ..type = parseString(json['type'], fallback: '')
      ..source = parseString(json['source'], fallback: '')
      ..referenceNumber = parseString(json['referenceNumber'], fallback: '')
      ..userName = parseString(json['userName'], fallback: '')
      ..createdBy = parseString(json['createdBy'], fallback: '')
      ..notes = parseString(json['notes'], fallback: '')
      ..lotNumber = parseString(json['lotNumber'], fallback: '')
      ..expiryDate = parseDateOrNull(json['expiryDate'])
      ..lastModified = parseDateOrNull(
        json['lastModified'] ?? json['updatedAt'] ?? json['timestamp'],
      )
      ..updatedAt = parseDate(
        json['updatedAt'] ?? json['lastModified'] ?? json['timestamp'],
      )
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId'], fallback: '');

    return entity;
  }
}
