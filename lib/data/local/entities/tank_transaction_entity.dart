import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'tank_transaction_entity.g.dart';

@Collection()
class TankTransactionEntity extends BaseEntity {
  @Index()
  late String tankId;

  late String tankName;
  late String type; // 'fill', 'consumption', 'adjustment'
  late double quantity;
  late double previousStock;
  late double newStock;
  late String materialId;
  late String materialName;
  late String referenceId;
  late String referenceType;
  late String operatorId;
  late String operatorName;
  String? lotId;

  @Index()
  late DateTime timestamp;

  Map<String, dynamic> toFirebaseJson() {
    return {
      'id': id,
      'tankId': tankId,
      'tankName': tankName,
      'type': type,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'materialId': materialId,
      'materialName': materialName,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'operatorId': operatorId,
      'operatorName': operatorName,
      if (lotId != null) 'lotId': lotId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Domain Mapper (Returns Map to avoid circular import with Service)
  Map<String, dynamic> toDomainMap() {
    return {
      'id': id,
      'tankId': tankId,
      'tankName': tankName,
      'type': type,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'materialId': materialId,
      'materialName': materialName,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'operatorId': operatorId,
      'operatorName': operatorName,
      if (lotId != null) 'lotId': lotId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
