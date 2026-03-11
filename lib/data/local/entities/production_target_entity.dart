import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'production_target_entity.g.dart';

@Collection()
class ProductionTargetEntity extends BaseEntity {
  @Index()
  late String productId;

  late String productName;

  @Index()
  late String targetDate; // YYYY-MM-DD

  late int targetQuantity;

  late int achievedQuantity;

  late String status; // active, completed, etc.

  late DateTime createdAt;

  // Convert to Domain
  // Note: Domain model not imported here to avoid circular dep, handle in Service

  Map<String, dynamic> toFirebaseJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'targetDate': targetDate,
      'targetQuantity': targetQuantity,
      'achievedQuantity': achievedQuantity,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static ProductionTargetEntity fromFirebaseJson(Map<String, dynamic> json) {
    return ProductionTargetEntity()
      ..id = json['id'] as String
      ..productId = json['productId'] as String
      ..productName = json['productName'] as String
      ..targetDate = json['targetDate'] as String
      ..targetQuantity = (json['targetQuantity'] as num).toInt()
      ..achievedQuantity = (json['achievedQuantity'] as num).toInt()
      ..status = json['status'] as String? ?? 'active'
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..updatedAt = DateTime.parse(
        json['updatedAt'] as String? ?? json['createdAt'] as String,
      )
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
  }
}
