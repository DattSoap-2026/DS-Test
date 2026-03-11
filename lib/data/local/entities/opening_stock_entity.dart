import 'package:isar/isar.dart';
import '../../../models/inventory/opening_stock_entry.dart';
import '../base_entity.dart';

part 'opening_stock_entity.g.dart';

@Collection()
class OpeningStockEntity extends BaseEntity {
  @Index()
  late String productId;

  late String productType;

  @Index()
  late String warehouseId;

  late double quantity;
  late String unit;

  double? openingRate;
  String? batchNumber;

  @Index()
  late DateTime entryDate;

  late String reason; // Default: "OPENING_STOCK"

  @Index()
  late String createdBy;

  late DateTime createdAt;

  OpeningStockEntry toDomain() {
    return OpeningStockEntry(
      id: id,
      productId: productId,
      productType: productType,
      warehouseId: warehouseId,
      quantity: quantity,
      unit: unit,
      openingRate: openingRate,
      batchNumber: batchNumber,
      entryDate: entryDate,
      reason: reason,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }

  static OpeningStockEntity fromDomain(OpeningStockEntry domain) {
    return OpeningStockEntity()
      ..id = domain.id
      ..productId = domain.productId
      ..productType = domain.productType
      ..warehouseId = domain.warehouseId
      ..quantity = domain.quantity
      ..unit = domain.unit
      ..openingRate = domain.openingRate
      ..batchNumber = domain.batchNumber
      ..entryDate = domain.entryDate
      ..reason = domain.reason
      ..createdBy = domain.createdBy
      ..createdAt = domain.createdAt
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.synced;
  }
}
