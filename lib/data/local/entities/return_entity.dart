import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../../../models/types/return_types.dart';

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
}
