import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'sales_target_entity.g.dart';

@Collection()
class SalesTargetEntity extends BaseEntity {
  @Index()
  late String salesmanId;

  late String salesmanName;

  late int month;

  late int year;

  late double targetAmount;

  late double achievedAmount;

  String? createdAt;

  // Store routeTargets as a JSON string to keep it simple in Isar
  String? routeTargetsJson;

  Map<String, dynamic> toFirebaseJson() {
    return {
      'id': id,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'month': month,
      'year': year,
      'targetAmount': targetAmount,
      'achievedAmount': achievedAmount,
      'createdAt': createdAt,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static SalesTargetEntity fromFirebaseJson(Map<String, dynamic> json) {
    return SalesTargetEntity()
      ..id = json['id'] as String
      ..salesmanId = json['salesmanId'] as String
      ..salesmanName = json['salesmanName'] as String
      ..month = (json['month'] as num).toInt()
      ..year = (json['year'] as num).toInt()
      ..targetAmount = (json['targetAmount'] as num).toDouble()
      ..achievedAmount = (json['achievedAmount'] as num? ?? 0).toDouble()
      ..createdAt = json['createdAt'] as String?
      ..updatedAt = DateTime.parse(
        json['updatedAt'] as String? ??
            json['createdAt'] as String? ??
            DateTime.now().toIso8601String(),
      )
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
  }
}
