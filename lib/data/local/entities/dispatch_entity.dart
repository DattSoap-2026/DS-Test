import 'dart:convert';

import 'package:isar/isar.dart';

import '../../../models/inventory/stock_dispatch.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'dispatch_entity.g.dart';

@Collection()
class DispatchEntity extends BaseEntity {
  @Index()
  late String dispatchId;

  @Index()
  late String salesmanId;

  late String salesmanName;
  String? storeId;
  late String vehicleNumber;
  late String dispatchRoute;
  late String salesRoute;
  late String itemsJson;

  @Index()
  late String status;

  late int totalQuantity;
  late double totalAmount;
  late String source;
  late bool isOrderBasedDispatch;
  String? orderId;
  String? orderNo;
  String? dealerId;
  String? dealerName;

  @Index()
  late DateTime createdAt;

  DateTime? receivedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'dispatchId': dispatchId,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'storeId': storeId,
      'vehicleNumber': vehicleNumber,
      'dispatchRoute': dispatchRoute,
      'salesRoute': salesRoute,
      'itemsJson': itemsJson,
      'status': status,
      'totalQuantity': totalQuantity,
      'totalAmount': totalAmount,
      'source': source,
      'isOrderBasedDispatch': isOrderBasedDispatch,
      'orderId': orderId,
      'orderNo': orderNo,
      'dealerId': dealerId,
      'dealerName': dealerName,
      'createdAt': createdAt.toIso8601String(),
      'receivedAt': receivedAt?.toIso8601String(),
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

  StockDispatch toDomain() {
    final parsedItems = parseJsonList(itemsJson)
        .whereType<Map>()
        .map((item) => DispatchItem.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);

    return StockDispatch(
      id: id,
      dispatchId: dispatchId,
      salesmanId: salesmanId,
      salesmanName: salesmanName,
      storeId: storeId,
      vehicleNumber: vehicleNumber,
      dispatchRoute: dispatchRoute,
      salesRoute: salesRoute,
      items: parsedItems,
      status: DispatchStatus.values.firstWhere(
        (value) => value.name == status,
        orElse: () => DispatchStatus.created,
      ),
      totalQuantity: totalQuantity,
      totalAmount: totalAmount,
      source: source,
      isOrderBasedDispatch: isOrderBasedDispatch,
      orderId: orderId,
      orderNo: orderNo,
      dealerId: dealerId,
      dealerName: dealerName,
      createdAt: createdAt,
      receivedAt: receivedAt,
    );
  }

  static DispatchEntity fromJson(Map<String, dynamic> json) {
    return DispatchEntity()
      ..id = parseString(json['id'])
      ..dispatchId = parseString(json['dispatchId'])
      ..salesmanId = parseString(json['salesmanId'])
      ..salesmanName = parseString(json['salesmanName'])
      ..storeId = parseString(json['storeId'], fallback: '')
      ..vehicleNumber = parseString(json['vehicleNumber'])
      ..dispatchRoute = parseString(json['dispatchRoute'])
      ..salesRoute = parseString(json['salesRoute'])
      ..itemsJson = parseString(json['itemsJson'], fallback: '[]')
      ..status = parseString(json['status'], fallback: 'created')
      ..totalQuantity = parseInt(json['totalQuantity'])
      ..totalAmount = parseDouble(json['totalAmount'])
      ..source = parseString(json['source'])
      ..isOrderBasedDispatch = parseBool(json['isOrderBasedDispatch'])
      ..orderId = parseString(json['orderId'], fallback: '')
      ..orderNo = parseString(json['orderNo'], fallback: '')
      ..dealerId = parseString(json['dealerId'], fallback: '')
      ..dealerName = parseString(json['dealerName'], fallback: '')
      ..createdAt = parseDate(json['createdAt'])
      ..receivedAt = parseDateOrNull(json['receivedAt'])
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }

  static DispatchEntity fromDomain(StockDispatch dispatch) {
    return DispatchEntity()
      ..id = dispatch.id
      ..dispatchId = dispatch.dispatchId
      ..salesmanId = dispatch.salesmanId
      ..salesmanName = dispatch.salesmanName
      ..storeId = dispatch.storeId
      ..vehicleNumber = dispatch.vehicleNumber
      ..dispatchRoute = dispatch.dispatchRoute
      ..salesRoute = dispatch.salesRoute
      ..itemsJson = jsonEncode(dispatch.items.map((item) => item.toJson()).toList())
      ..status = dispatch.status.name
      ..totalQuantity = dispatch.totalQuantity
      ..totalAmount = dispatch.totalAmount
      ..source = dispatch.source
      ..isOrderBasedDispatch = dispatch.isOrderBasedDispatch
      ..orderId = dispatch.orderId
      ..orderNo = dispatch.orderNo
      ..dealerId = dispatch.dealerId
      ..dealerName = dispatch.dealerName
      ..createdAt = dispatch.createdAt
      ..updatedAt = dispatch.receivedAt ?? dispatch.createdAt
      ..receivedAt = dispatch.receivedAt
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false;
  }
}
