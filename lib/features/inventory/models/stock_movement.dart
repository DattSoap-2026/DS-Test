import 'package:isar/isar.dart';

part 'stock_movement.g.dart';

/// Immutable stock movement audit record.
@Collection()
class StockMovement {
  StockMovement();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String firebaseId = '';

  @Index()
  late String productFirebaseId;

  late String type;
  late int quantity;
  late String reason;
  DateTime timestamp = DateTime.now();
  bool isSynced = false;
  String deviceId = '';

  /// Returns a copy with updated values.
  StockMovement copyWith({
    Id? id,
    String? firebaseId,
    String? productFirebaseId,
    String? type,
    int? quantity,
    String? reason,
    DateTime? timestamp,
    bool? isSynced,
    String? deviceId,
  }) {
    return StockMovement()
      ..id = id ?? this.id
      ..firebaseId = firebaseId ?? this.firebaseId
      ..productFirebaseId = productFirebaseId ?? this.productFirebaseId
      ..type = type ?? this.type
      ..quantity = quantity ?? this.quantity
      ..reason = reason ?? this.reason
      ..timestamp = timestamp ?? this.timestamp
      ..isSynced = isSynced ?? this.isSynced
      ..deviceId = deviceId ?? this.deviceId;
  }

  /// Converts the movement to a Firestore-safe json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'firebaseId': firebaseId,
      'productFirebaseId': productFirebaseId,
      'type': type,
      'quantity': quantity,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
      'isSynced': isSynced,
      'deviceId': deviceId,
    };
  }

  /// Creates a movement from a json map.
  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement()
      ..firebaseId = json['firebaseId']?.toString() ?? ''
      ..productFirebaseId = json['productFirebaseId']?.toString() ?? ''
      ..type = json['type']?.toString() ?? 'IN'
      ..quantity = (json['quantity'] as num? ?? 0).toInt()
      ..reason = json['reason']?.toString() ?? ''
      ..timestamp =
          DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now()
      ..isSynced = json['isSynced'] == true
      ..deviceId = json['deviceId']?.toString() ?? '';
  }
}
