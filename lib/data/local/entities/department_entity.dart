import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'department_entity.g.dart';

@Collection()
class DepartmentEntity extends BaseEntity {
  @Index(unique: true)
  late String name;

  late bool isActive;

  Map<String, dynamic> toFirebaseJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static DepartmentEntity fromFirebaseJson(Map<String, dynamic> json) {
    return DepartmentEntity()
      ..id = json['id'] as String
      ..name = json['name'] as String
      ..isActive = json['isActive'] as bool? ?? true
      ..updatedAt = DateTime.parse(
        json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      )
      ..isDeleted = json['isDeleted'] == true
      ..deletedAt = DateTime.tryParse(json['deletedAt']?.toString() ?? '');
  }
}
