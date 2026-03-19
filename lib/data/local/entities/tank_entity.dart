import 'package:isar/isar.dart';

import '../../../services/tank_service.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

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
  late String type;
  int? bags;
  int? maxBags;
  late double minStockLevel;
  late bool isBhattiSourced;
  late DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'materialId': materialId,
      'materialName': materialName,
      'capacity': capacity,
      'currentStock': currentStock,
      'fillLevel': fillLevel,
      'status': status,
      'unit': unit,
      'department': department,
      'assignedUnit': assignedUnit,
      'type': type,
      'bags': bags,
      'maxBags': maxBags,
      'minStockLevel': minStockLevel,
      'isBhattiSourced': isBhattiSourced,
      'createdAt': createdAt.toIso8601String(),
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

  static TankEntity fromJson(Map<String, dynamic> json) {
    return TankEntity()
      ..id = parseString(json['id'])
      ..name = parseString(json['name'])
      ..materialId = parseString(json['materialId'])
      ..materialName = parseString(json['materialName'])
      ..capacity = parseDouble(json['capacity'])
      ..currentStock = parseDouble(json['currentStock'])
      ..fillLevel = parseDouble(json['fillLevel'])
      ..status = parseString(json['status'])
      ..unit = parseString(json['unit'])
      ..department = parseString(json['department'])
      ..assignedUnit = parseString(json['assignedUnit'], fallback: '')
      ..type = parseString(json['type'], fallback: 'tank')
      ..bags = json['bags'] == null ? null : parseInt(json['bags'])
      ..maxBags = json['maxBags'] == null ? null : parseInt(json['maxBags'])
      ..minStockLevel = parseDouble(json['minStockLevel'])
      ..isBhattiSourced = parseBool(json['isBhattiSourced'])
      ..createdAt = parseDate(json['createdAt'])
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
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
      ..createdAt = parseDate(tank.createdAt)
      ..updatedAt = parseDate(tank.updatedAt)
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false;
  }
}
