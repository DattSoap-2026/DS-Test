import 'dart:convert';

import 'package:isar/isar.dart';

import '../../../models/types/route_order_types.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'route_order_entity.g.dart';

@Collection()
class RouteOrderEntity extends BaseEntity {
  late String orderNo;

  @Index()
  late String routeId;
  late String routeName;

  @Index()
  late String salesmanId;
  late String salesmanName;

  late String dealerId;
  late String dealerName;
  late String createdByRole;

  @Index()
  late String productionStatus;

  @Index()
  late String dispatchStatus;

  late String source;
  late bool isOrderBasedDispatch;
  late String itemsJson;
  String? dispatchBeforeDate;

  @Index()
  late DateTime createdAt;

  String? dispatchId;
  DateTime? dispatchedAt;
  String? dispatchedById;
  String? dispatchedByName;
  String? createdById;
  String? createdByName;
  DateTime? productionUpdatedAt;
  String? productionUpdatedById;
  String? productionUpdatedByName;
  String? deletedById;
  String? deletedByName;
  DateTime? cancelledAt;
  String? cancelledById;
  String? cancelledByName;
  String? cancelReason;
  String? lastEditedById;
  String? lastEditedByName;
  DateTime? lastEditedAt;

  RouteOrderEntity();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'orderNo': orderNo,
      'routeId': routeId,
      'routeName': routeName,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'dealerId': dealerId,
      'dealerName': dealerName,
      'createdByRole': createdByRole,
      'productionStatus': productionStatus,
      'dispatchStatus': dispatchStatus,
      'source': source,
      'isOrderBasedDispatch': isOrderBasedDispatch,
      'itemsJson': itemsJson,
      'dispatchBeforeDate': dispatchBeforeDate,
      'createdAt': createdAt.toIso8601String(),
      'dispatchId': dispatchId,
      'dispatchedAt': dispatchedAt?.toIso8601String(),
      'dispatchedById': dispatchedById,
      'dispatchedByName': dispatchedByName,
      'createdById': createdById,
      'createdByName': createdByName,
      'productionUpdatedAt': productionUpdatedAt?.toIso8601String(),
      'productionUpdatedById': productionUpdatedById,
      'productionUpdatedByName': productionUpdatedByName,
      'deletedById': deletedById,
      'deletedByName': deletedByName,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancelledById': cancelledById,
      'cancelledByName': cancelledByName,
      'cancelReason': cancelReason,
      'lastEditedById': lastEditedById,
      'lastEditedByName': lastEditedByName,
      'lastEditedAt': lastEditedAt?.toIso8601String(),
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

  factory RouteOrderEntity.fromDomain(RouteOrder order) {
    return RouteOrderEntity()
      ..id = order.id
      ..orderNo = order.orderNo
      ..routeId = order.routeId
      ..routeName = order.routeName
      ..salesmanId = order.salesmanId
      ..salesmanName = order.salesmanName
      ..dealerId = order.dealerId
      ..dealerName = order.dealerName
      ..createdByRole = order.createdByRole
      ..productionStatus = order.productionStatus.value
      ..dispatchStatus = order.dispatchStatus.value
      ..source = order.source.value
      ..isOrderBasedDispatch = order.isOrderBasedDispatch
      ..itemsJson = jsonEncode(order.items.map((item) => item.toJson()).toList())
      ..dispatchBeforeDate = order.dispatchBeforeDate
      ..createdAt = parseDate(order.createdAt)
      ..updatedAt = parseDate(order.updatedAt)
      ..dispatchId = order.dispatchId
      ..dispatchedAt = parseDateOrNull(order.dispatchedAt)
      ..dispatchedById = order.dispatchedById
      ..dispatchedByName = order.dispatchedByName
      ..createdById = order.createdById
      ..createdByName = order.createdByName
      ..productionUpdatedAt = parseDateOrNull(order.productionUpdatedAt)
      ..productionUpdatedById = order.productionUpdatedById
      ..productionUpdatedByName = order.productionUpdatedByName
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false;
  }

  static RouteOrderEntity fromJson(Map<String, dynamic> json) {
    return RouteOrderEntity()
      ..id = parseString(json['id'])
      ..orderNo = parseString(json['orderNo'])
      ..routeId = parseString(json['routeId'])
      ..routeName = parseString(json['routeName'])
      ..salesmanId = parseString(json['salesmanId'])
      ..salesmanName = parseString(json['salesmanName'])
      ..dealerId = parseString(json['dealerId'])
      ..dealerName = parseString(json['dealerName'])
      ..createdByRole = parseString(json['createdByRole'])
      ..productionStatus = parseString(json['productionStatus'])
      ..dispatchStatus = parseString(json['dispatchStatus'])
      ..source = parseString(json['source'])
      ..isOrderBasedDispatch = parseBool(json['isOrderBasedDispatch'])
      ..itemsJson = parseString(json['itemsJson'], fallback: '[]')
      ..dispatchBeforeDate = parseString(json['dispatchBeforeDate'], fallback: '')
      ..createdAt = parseDate(json['createdAt'])
      ..dispatchId = parseString(json['dispatchId'], fallback: '')
      ..dispatchedAt = parseDateOrNull(json['dispatchedAt'])
      ..dispatchedById = parseString(json['dispatchedById'], fallback: '')
      ..dispatchedByName = parseString(json['dispatchedByName'], fallback: '')
      ..createdById = parseString(json['createdById'], fallback: '')
      ..createdByName = parseString(json['createdByName'], fallback: '')
      ..productionUpdatedAt = parseDateOrNull(json['productionUpdatedAt'])
      ..productionUpdatedById = parseString(json['productionUpdatedById'], fallback: '')
      ..productionUpdatedByName = parseString(json['productionUpdatedByName'], fallback: '')
      ..deletedById = parseString(json['deletedById'], fallback: '')
      ..deletedByName = parseString(json['deletedByName'], fallback: '')
      ..cancelledAt = parseDateOrNull(json['cancelledAt'])
      ..cancelledById = parseString(json['cancelledById'], fallback: '')
      ..cancelledByName = parseString(json['cancelledByName'], fallback: '')
      ..cancelReason = parseString(json['cancelReason'], fallback: '')
      ..lastEditedById = parseString(json['lastEditedById'], fallback: '')
      ..lastEditedByName = parseString(json['lastEditedByName'], fallback: '')
      ..lastEditedAt = parseDateOrNull(json['lastEditedAt'])
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }

  RouteOrder toDomain() {
    final parsedItems = parseJsonList(itemsJson)
        .whereType<Map>()
        .map((item) => RouteOrderItem.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);

    return RouteOrder(
      id: id,
      orderNo: orderNo,
      routeId: routeId,
      routeName: routeName,
      salesmanId: salesmanId,
      salesmanName: salesmanName,
      dealerId: dealerId,
      dealerName: dealerName,
      createdByRole: createdByRole,
      productionStatus: RouteOrderProductionStatus.fromString(productionStatus),
      dispatchStatus: RouteOrderDispatchStatus.fromString(dispatchStatus),
      source: RouteOrderSource.fromString(source),
      isOrderBasedDispatch: isOrderBasedDispatch,
      items: parsedItems,
      dispatchBeforeDate: dispatchBeforeDate,
      createdAt: createdAt.toIso8601String(),
      updatedAt: updatedAt.toIso8601String(),
      dispatchId: dispatchId,
      dispatchedAt: dispatchedAt?.toIso8601String(),
      dispatchedById: dispatchedById,
      dispatchedByName: dispatchedByName,
      createdById: createdById,
      createdByName: createdByName,
      productionUpdatedAt: productionUpdatedAt?.toIso8601String(),
      productionUpdatedById: productionUpdatedById,
      productionUpdatedByName: productionUpdatedByName,
    );
  }
}
