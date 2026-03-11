import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'custom_role_entity.g.dart';

@Collection()
class CustomRoleEntity extends BaseEntity {
  @Index()
  late String name;

  String? description;

  late String permissionsJson;

  late bool isActive;

  late DateTime createdAt;

  String? createdBy;
}
