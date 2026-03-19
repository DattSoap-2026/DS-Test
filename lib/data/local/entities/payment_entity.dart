import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'payment_entity.g.dart';

@collection
class PaymentEntity extends BaseEntity {
  @Index()
  late String customerId;

  String? customerName;

  @Index()
  String? saleId;

  late double amount;

  @Index()
  late String mode; // cash, cheque, transfer, online

  late String date;

  String? reference;

  String? notes;

  @Index()
  late String collectorId;

  String? collectorName;

  String? createdAt;

  /// Converts this entity into a sync-safe json map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'saleId': saleId,
      'amount': amount,
      'mode': mode,
      'date': date,
      'reference': reference,
      'notes': notes,
      'collectorId': collectorId,
      'collectorName': collectorName,
      'createdAt': createdAt,
      'updatedAt': updatedAt.toIso8601String(),
      'lastModified': updatedAt.toIso8601String(),
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
  static PaymentEntity fromJson(Map<String, dynamic> json) {
    return PaymentEntity()
      ..id = parseString(json['id'])
      ..customerId = parseString(json['customerId'])
      ..customerName = json['customerName']?.toString()
      ..saleId = json['saleId']?.toString()
      ..amount = parseDouble(json['amount'])
      ..mode = parseString(json['mode'])
      ..date = parseString(
        json['date'],
        fallback: DateTime.now().toIso8601String(),
      )
      ..reference = json['reference']?.toString()
      ..notes = json['notes']?.toString()
      ..collectorId = parseString(json['collectorId'])
      ..collectorName = json['collectorName']?.toString()
      ..createdAt = json['createdAt']?.toString()
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId'], fallback: '');
  }
}
