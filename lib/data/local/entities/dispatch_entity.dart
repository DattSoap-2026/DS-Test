import 'package:isar/isar.dart';
import 'dart:convert';
import '../base_entity.dart';
import '../../../models/inventory/stock_dispatch.dart';

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

  // Storing items as JSON string since Isar doesn't support complex embedded objects well without their own entities
  late String itemsJson;

  @Index()
  late String status; // 'created', 'loaded', 'received', 'closed'

  late int totalQuantity;
  late double totalAmount;

  late String source; // e.g. 'direct', 'order'
  late bool isOrderBasedDispatch;

  String? orderId;
  String? orderNo;
  String? dealerId;
  String? dealerName;

  @Index()
  late DateTime createdAt;

  DateTime? receivedAt;

  // Convert to Domain Object
  StockDispatch toDomain() {
    List<DispatchItem> parsedItems = [];
    try {
      final List<dynamic> decoded = jsonDecode(itemsJson);
      parsedItems = decoded
          .map((e) => DispatchItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // print('Error decoding dispatch items json: $e');
    }

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
        (e) => e.name == status,
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

  // Create from Domain Object
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
      ..itemsJson = jsonEncode(dispatch.items.map((e) => e.toJson()).toList())
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
      // We assume it's synced if it's coming from a domain object usually loaded from network,
      // but if created locally, this should be handled by the caller.
      ..syncStatus = SyncStatus.synced;
  }
}
