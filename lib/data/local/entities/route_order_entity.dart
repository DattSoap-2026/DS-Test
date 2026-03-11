import 'package:isar/isar.dart';
import 'dart:convert';
import '../base_entity.dart';
import '../../../models/types/route_order_types.dart';

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
      ..itemsJson = jsonEncode(order.items.map((i) => i.toJson()).toList())
      ..dispatchBeforeDate = order.dispatchBeforeDate
      ..createdAt = DateTime.tryParse(order.createdAt) ?? DateTime.now()
      ..updatedAt = DateTime.tryParse(order.updatedAt) ?? DateTime.now()
      ..dispatchId = order.dispatchId
      ..dispatchedAt = order.dispatchedAt != null
          ? DateTime.tryParse(order.dispatchedAt!)
          : null
      ..dispatchedById = order.dispatchedById
      ..dispatchedByName = order.dispatchedByName
      ..createdById = order.createdById
      ..createdByName = order.createdByName
      ..productionUpdatedAt = order.productionUpdatedAt != null
          ? DateTime.tryParse(order.productionUpdatedAt!)
          : null
      ..productionUpdatedById = order.productionUpdatedById
      ..productionUpdatedByName = order.productionUpdatedByName
      ..syncStatus = SyncStatus
          .synced; // Treat as synced when first fetched from backend usually. Override on local creates.
  }

  RouteOrder toDomain() {
    List<RouteOrderItem> parsedItems = [];
    try {
      final List<dynamic> decoded = jsonDecode(itemsJson);
      parsedItems = decoded
          .map((e) => RouteOrderItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // print('Error decoding route order items json: $e');
    }

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
