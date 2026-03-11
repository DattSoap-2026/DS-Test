import 'package:isar/isar.dart';

import '../base_entity.dart';

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
  bool isSynced = false;

  double get quantity => quantityBase;
  set quantity(double value) => quantityBase = value;

  String get userId => actorUid;
  set userId(String value) => actorUid = value;

  String get reason => reasonCode ?? '';
  set reason(String value) => reasonCode = value;

  DateTime get createdAt => occurredAt;
  set createdAt(DateTime value) => occurredAt = value;
}
