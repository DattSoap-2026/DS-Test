import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'wastage_log_entity.g.dart';

@Collection()
class WastageLogEntity extends BaseEntity {
  @Index()
  late String returnedTo;

  @Index()
  late String productId;

  late String productName;

  late double quantity;

  late String unit;

  late String reason;

  late String reportedBy;

  late DateTime createdAt;

  Map<String, dynamic> toFirebaseJson() {
    return {
      'id': id,
      'returnedTo': returnedTo,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'reason': reason,
      'reportedBy': reportedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  static WastageLogEntity fromFirebaseJson(Map<String, dynamic> json) {
    final entity = WastageLogEntity()
      ..id = json['id'] as String
      ..returnedTo = json['returnedTo'] as String
      ..productId = json['productId'] as String
      ..productName = json['productName'] as String? ?? 'Unknown'
      ..quantity = (json['quantity'] as num?)?.toDouble() ?? 0.0
      ..unit = json['unit'] as String? ?? 'Unit'
      ..reason = json['reason'] as String? ?? ''
      ..reportedBy = json['reportedBy'] as String? ?? 'Unknown'
      ..createdAt = DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      )
      ..updatedAt = DateTime.parse(
        json['updatedAt'] as String? ??
            json['createdAt'] as String? ??
            DateTime.now().toIso8601String(),
      )
      ..isDeleted = json['isDeleted'] == true
      ..deletedAt = DateTime.tryParse(json['deletedAt']?.toString() ?? '');

    return entity;
  }
}
