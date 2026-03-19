import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'unit_entity.g.dart';

@Collection()
class UnitEntity extends BaseEntity {
  @Index(unique: true, replace: true)
  late String name;

  /// Short symbol displayed in UI (e.g., "kg", "pcs", "ltr")
  String? symbol;

  /// Number of decimal places allowed for this unit (default 2)
  int? decimalPlaces;

  late String createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'decimalPlaces': decimalPlaces,
      'createdAt': createdAt,
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'isSynced': isSynced,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  static UnitEntity fromJson(Map<String, dynamic> json) {
    return UnitEntity()
      ..id = json['id']?.toString() ?? json['name']?.toString() ?? ''
      ..name = json['name']?.toString() ?? ''
      ..symbol = json['symbol']?.toString()
      ..decimalPlaces = (json['decimalPlaces'] as num?)?.toInt()
      ..createdAt =
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String()
      ..updatedAt =
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now()
      ..deletedAt = DateTime.tryParse(json['deletedAt']?.toString() ?? '')
      ..isDeleted = json['isDeleted'] == true
      ..isSynced = json['isSynced'] == true
      ..lastSynced = DateTime.tryParse(json['lastSynced']?.toString() ?? '')
      ..version = (json['version'] as num? ?? 1).toInt()
      ..deviceId = json['deviceId']?.toString() ?? '';
  }
}
