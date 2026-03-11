import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'unit_entity.g.dart';

@Collection()
class UnitEntity extends BaseEntity {
  @Index(unique: true, replace: true)
  late String name;

  /// Short symbol displayed in UI (e.g., "kg", "pcs", "ltr")
  String? symbol;

  /// Number of decimal places allowed for this unit (default 2)
  int? decimalPlaces;

  late String createdAt;
}
