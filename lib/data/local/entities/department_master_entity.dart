import 'package:isar/isar.dart';

import '../base_entity.dart';

part 'department_master_entity.g.dart';

@Collection()
class DepartmentMasterEntity extends BaseEntity {
  late String departmentId;

  @Index(unique: true, replace: true)
  late String departmentCode;

  @Index(caseSensitive: false)
  late String departmentName;

  @Index(caseSensitive: false)
  late String departmentType;

  String? sourceWarehouseId;
  bool isProductionDepartment = true;
  bool isActive = true;
}
