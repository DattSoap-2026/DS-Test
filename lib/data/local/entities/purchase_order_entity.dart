import 'dart:convert';

import 'package:isar/isar.dart';

import '../../../models/types/purchase_order_types.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'purchase_order_entity.g.dart';

@Collection()
class PurchaseOrderEntity extends BaseEntity {
  @Index(unique: true, replace: true)
  String get firebaseId => id;
  set firebaseId(String value) => id = value;

  @Index()
  late String supplierId;

  late String supplierName;
  String itemsJson = '[]';
  double totalAmount = 0;
  double paidAmount = 0;

  @Index()
  String status = 'pending';

  DateTime? orderDate;
  DateTime? expectedDeliveryDate;
  DateTime? receivedDate;
  String? approvedBy;
  DateTime? approvedAt;
  String? cancelReason;
  String? warehouseId;
  String? warehouseName;
  String? notes;
  String? createdBy;
  String? createdByName;
  DateTime? createdAt;

  @ignore
  List<PurchaseOrderItem> get items {
    if (itemsJson.isEmpty) {
      return const <PurchaseOrderItem>[];
    }
    final decoded = jsonDecode(itemsJson);
    if (decoded is! List) {
      return const <PurchaseOrderItem>[];
    }
    return decoded
        .whereType<Map>()
        .map(
          (item) => PurchaseOrderItem.fromJson(
            Map<String, dynamic>.from(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          ),
        )
        .toList(growable: false);
  }

  set items(List<PurchaseOrderItem> value) {
    itemsJson = jsonEncode(
      value.map((item) => item.toJson()).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'itemsJson': itemsJson,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'status': status,
      'orderDate': orderDate?.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'receivedDate': receivedDate?.toIso8601String(),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'cancelReason': cancelReason,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'notes': notes,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'isSynced': isSynced,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
      'syncStatus': syncStatus.name,
    };
  }

  static PurchaseOrderEntity fromJson(Map<String, dynamic> json) {
    final entity = PurchaseOrderEntity()
      ..id = parseString(json['id'])
      ..supplierId = parseString(json['supplierId'])
      ..supplierName = parseString(json['supplierName'])
      ..itemsJson = parseString(json['itemsJson'], fallback: '[]')
      ..totalAmount = parseDouble(json['totalAmount'])
      ..paidAmount = parseDouble(json['paidAmount'])
      ..status = parseString(json['status'], fallback: 'pending')
      ..orderDate = parseDateOrNull(json['orderDate'])
      ..expectedDeliveryDate = parseDateOrNull(json['expectedDeliveryDate'])
      ..receivedDate = parseDateOrNull(json['receivedDate'])
      ..approvedBy = json['approvedBy']?.toString()
      ..approvedAt = parseDateOrNull(json['approvedAt'])
      ..cancelReason = json['cancelReason']?.toString()
      ..warehouseId = json['warehouseId']?.toString()
      ..warehouseName = json['warehouseName']?.toString()
      ..notes = json['notes']?.toString()
      ..createdBy = json['createdBy']?.toString()
      ..createdByName = json['createdByName']?.toString()
      ..createdAt = parseDateOrNull(json['createdAt'])
      ..updatedAt = parseDate(json['updatedAt'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..isDeleted = json['isDeleted'] == true
      ..isSynced = json['isSynced'] == true
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId'])
      ..syncStatus = parseSyncStatus(json['syncStatus']);

    if (entity.itemsJson.trim().isEmpty) {
      entity.itemsJson = '[]';
    }
    return entity;
  }
}
