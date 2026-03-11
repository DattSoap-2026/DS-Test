import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../../../services/tank_service.dart';

part 'tank_lot_entity.g.dart';

@Collection()
class TankLotEntity extends BaseEntity {
  @Index()
  late String tankId;

  @Index()
  late String materialId;

  late String materialName;
  late String supplierId;
  late String supplierName;
  late String purchaseOrderId;

  @Index()
  late DateTime receivedDate;

  late double quantity;
  late double initialQuantity;

  @Index()
  late String status; // 'active', 'exhausted'

  TankLot toDomain() {
    return TankLot(
      id: id,
      tankId: tankId,
      materialId: materialId,
      materialName: materialName,
      supplierId: supplierId,
      supplierName: supplierName,
      purchaseOrderId: purchaseOrderId,
      receivedDate: receivedDate,
      quantity: quantity,
      initialQuantity: initialQuantity,
      status: status,
    );
  }

  static TankLotEntity fromDomain(TankLot lot) {
    return TankLotEntity()
      ..id = lot.id
      ..tankId = lot.tankId
      ..materialId = lot.materialId
      ..materialName = lot.materialName
      ..supplierId = lot.supplierId
      ..supplierName = lot.supplierName
      ..purchaseOrderId = lot.purchaseOrderId
      ..receivedDate = lot.receivedDate
      ..quantity = lot.quantity
      ..initialQuantity = lot.initialQuantity
      ..status = lot.status
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
  }
}
