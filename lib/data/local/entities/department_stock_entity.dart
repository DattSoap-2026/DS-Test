import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../../../services/bhatti_service.dart';

part 'department_stock_entity.g.dart';

@Collection()
class DepartmentStockEntity extends BaseEntity {
  @Index()
  late String departmentName;

  @Index()
  late String productId;

  late String productName;

  late double stock;

  late String unit;

  Map<String, dynamic> toFirebaseJson() {
    return {
      'id': id,
      'departmentName': departmentName,
      'productId': productId,
      'productName': productName,
      'stock': stock,
      'unit': unit,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  DepartmentStock toDomain() {
    return DepartmentStock(
      id: id,
      departmentName: departmentName,
      productId: productId,
      productName: productName,
      stock: stock,
      unit: unit,
    );
  }

  static DepartmentStockEntity fromFirebaseJson(Map<String, dynamic> json) {
    final entity = DepartmentStockEntity()
      ..id =
          json['id'] as String? ??
          "${json['departmentName']}_${json['productId']}"
      ..departmentName = json['departmentName'] as String
      ..productId = json['productId'] as String
      ..productName = json['productName'] as String? ?? 'Unknown'
      ..stock = (json['stock'] as num?)?.toDouble() ?? 0.0
      ..unit = json['unit'] as String? ?? 'Unit'
      ..updatedAt = DateTime.parse(
        json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      )
      ..isDeleted = json['isDeleted'] == true
      ..deletedAt = DateTime.tryParse(json['deletedAt']?.toString() ?? '');

    return entity;
  }
}
