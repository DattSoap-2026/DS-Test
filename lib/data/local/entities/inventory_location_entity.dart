import 'package:isar/isar.dart';

import '../base_entity.dart';

part 'inventory_location_entity.g.dart';

@Collection()
class InventoryLocationEntity extends BaseEntity {
  static const String warehouseType = 'warehouse';
  static const String departmentType = 'department';
  static const String salesmanVanType = 'salesman_van';
  static const String virtualType = 'virtual';

  @Index(caseSensitive: false)
  late String type;

  @Index(caseSensitive: false)
  late String name;

  @Index(unique: true, replace: true)
  late String code;

  @Index()
  String? parentLocationId;

  @Index()
  String? ownerUserUid;

  bool isActive = true;
  bool isPrimaryMainWarehouse = false;
}
