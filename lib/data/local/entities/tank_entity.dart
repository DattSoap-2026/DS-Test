import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../../../services/tank_service.dart';

part 'tank_entity.g.dart';

@Collection()
class TankEntity extends BaseEntity {
  @Index()
  late String name;

  late String materialId;
  late String materialName;
  late double capacity;
  late double currentStock;
  late double fillLevel;
  late String status;
  late String unit;

  @Index()
  late String department;

  String? assignedUnit;

  late String type; // 'tank' or 'godown'

  int? bags;
  int? maxBags;

  late double minStockLevel;
  late bool isBhattiSourced;
  late DateTime createdAt;

  Tank toDomain() {
    return Tank(
      id: id,
      name: name,
      materialId: materialId,
      materialName: materialName,
      capacity: capacity,
      currentStock: currentStock,
      fillLevel: fillLevel,
      status: status,
      unit: unit,
      updatedAt: updatedAt.toIso8601String(),
      createdAt: createdAt.toIso8601String(),
      department: department,
      assignedUnit: assignedUnit,
      type: type,
      bags: bags,
      maxBags: maxBags,
      minStockLevel: minStockLevel,
      isBhattiSourced: isBhattiSourced,
    );
  }

  static TankEntity fromDomain(Tank tank) {
    return TankEntity()
      ..id = tank.id
      ..name = tank.name
      ..materialId = tank.materialId
      ..materialName = tank.materialName
      ..capacity = tank.capacity
      ..currentStock = tank.currentStock
      ..fillLevel = tank.fillLevel
      ..status = tank.status
      ..unit = tank.unit
      ..department = tank.department
      ..assignedUnit = tank.assignedUnit
      ..type = tank.type
      ..bags = tank.bags
      ..maxBags = tank.maxBags
      ..minStockLevel = tank.minStockLevel
      ..isBhattiSourced = tank.isBhattiSourced
      ..createdAt = DateTime.tryParse(tank.createdAt) ?? DateTime.now()
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false;
  }
}
