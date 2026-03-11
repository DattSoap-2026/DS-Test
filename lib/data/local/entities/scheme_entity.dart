import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../../../services/schemes_service.dart';

part 'scheme_entity.g.dart';

@Collection()
class SchemeEntity extends BaseEntity {
  @Index()
  late String name;

  String? description;
  late String type; // 'buy_x_get_y_free'

  @Index()
  late String status; // 'active', 'inactive'

  late DateTime validFrom;
  late DateTime validTo;

  late String buyProductId;
  late int buyQuantity;

  late String getProductId;
  late int getQuantity;

  late DateTime createdAt;

  // Domain Mapper
  Scheme toDomain() {
    return Scheme(
      id: id,
      name: name,
      description: description ?? '',
      type: type,
      status: status,
      validFrom: validFrom.toIso8601String(),
      validTo: validTo.toIso8601String(),
      buyProductId: buyProductId,
      buyQuantity: buyQuantity,
      getProductId: getProductId,
      getQuantity: getQuantity,
      createdAt: createdAt.toIso8601String(),
    );
  }
}
