import 'package:isar/isar.dart';

import '../../../services/tank_service.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

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
  late String status;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'tankId': tankId,
      'materialId': materialId,
      'materialName': materialName,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'purchaseOrderId': purchaseOrderId,
      'receivedDate': receivedDate.toIso8601String(),
      'quantity': quantity,
      'initialQuantity': initialQuantity,
      'status': status,
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

  static TankLotEntity fromJson(Map<String, dynamic> json) {
    return TankLotEntity()
      ..id = parseString(json['id'])
      ..tankId = parseString(json['tankId'])
      ..materialId = parseString(json['materialId'])
      ..materialName = parseString(json['materialName'])
      ..supplierId = parseString(json['supplierId'])
      ..supplierName = parseString(json['supplierName'])
      ..purchaseOrderId = parseString(json['purchaseOrderId'])
      ..receivedDate = parseDate(json['receivedDate'])
      ..quantity = parseDouble(json['quantity'])
      ..initialQuantity = parseDouble(json['initialQuantity'])
      ..status = parseString(json['status'], fallback: 'active')
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
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
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false;
  }
}
