import 'dart:convert';

import 'package:isar/isar.dart';
import '../../../models/types/return_types.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'return_entity.g.dart';

@Collection()
class ReturnEntity extends BaseEntity {
  late String returnType; // 'stock_return' or 'sales_return'
  late String salesmanId;
  late String salesmanName;

  late List<ReturnItemEntity> items;

  late String reason;
  String? reasonCode;

  late String status; // 'pending', 'approved', 'rejected'
  String? disposition; // 'Good Stock', etc.

  late DateTime createdAt;

  String? approvedBy;
  String? originalSaleId;
  String? customerId;
  String? customerName;

  /// Converts this entity into a sync-safe json map.
  Map<String, dynamic> toJson() {
    final serializedItems =
        items.map((item) => item.toJson()).toList(growable: false);
    return <String, dynamic>{
      'id': id,
      'returnType': returnType,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'items': serializedItems,
      'itemsJson': jsonEncode(serializedItems),
      'reason': reason,
      'reasonCode': reasonCode,
      'status': status,
      'disposition': disposition,
      'createdAt': createdAt.toIso8601String(),
      'approvedBy': approvedBy,
      'originalSaleId': originalSaleId,
      'customerId': customerId,
      'customerName': customerName,
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
  static ReturnEntity fromJson(Map<String, dynamic> json) {
    return ReturnEntity()
      ..id = parseString(json['id'])
      ..returnType = parseString(json['returnType'])
      ..salesmanId = parseString(json['salesmanId'])
      ..salesmanName = parseString(json['salesmanName'])
      ..items = _decodeItems(json)
      ..reason = parseString(json['reason'])
      ..reasonCode = json['reasonCode']?.toString()
      ..status = parseString(json['status'], fallback: 'pending')
      ..disposition = json['disposition']?.toString()
      ..createdAt = parseDate(json['createdAt'])
      ..approvedBy = json['approvedBy']?.toString()
      ..originalSaleId = json['originalSaleId']?.toString()
      ..customerId = json['customerId']?.toString()
      ..customerName = json['customerName']?.toString()
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId'], fallback: '');
  }

  // Conversion to Domain Model
  ReturnRequest toDomain() {
    return ReturnRequest(
      id: id,
      returnType: returnType,
      salesmanId: salesmanId,
      salesmanName: salesmanName,
      items: items.map((e) => e.toDomain()).toList(),
      reason: reason,
      reasonCode: reasonCode,
      status: status,
      disposition: disposition,
      createdAt: createdAt.toIso8601String(),
      updatedAt: updatedAt.toIso8601String(),
      approvedBy: approvedBy,
      originalSaleId: originalSaleId,
      customerId: customerId,
      customerName: customerName,
    );
  }

  static List<ReturnItemEntity> _decodeItems(Map<String, dynamic> json) {
    dynamic rawItems = json['items'];
    if (rawItems == null && json['itemsJson'] is String) {
      final encoded = json['itemsJson']?.toString() ?? '';
      if (encoded.isNotEmpty) {
        try {
          rawItems = jsonDecode(encoded);
        } catch (_) {
          rawItems = const <dynamic>[];
        }
      }
    }
    if (rawItems is! List) {
      return const <ReturnItemEntity>[];
    }
    return rawItems
        .whereType<Object?>()
        .map((item) => ReturnItemEntity.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList(growable: false);
  }
}

@Embedded()
class ReturnItemEntity {
  late String productId;
  late String name;
  late double quantity;
  late String unit;
  double? price;

  ReturnItem toDomain() {
    return ReturnItem(
      productId: productId,
      name: name,
      quantity: quantity,
      unit: unit,
      price: price,
    );
  }

  /// Converts this embedded item into json.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price': price,
    };
  }

  /// Builds an embedded item from json.
  static ReturnItemEntity fromJson(Map<String, dynamic> json) {
    return ReturnItemEntity()
      ..productId = parseString(json['productId'])
      ..name = parseString(json['name'])
      ..quantity = parseDouble(json['quantity'])
      ..unit = parseString(json['unit'])
      ..price = json['price'] == null ? null : parseDouble(json['price']);
  }
}
