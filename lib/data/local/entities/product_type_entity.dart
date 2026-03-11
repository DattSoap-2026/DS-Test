import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'product_type_entity.g.dart';

@Collection()
class ProductTypeEntity extends BaseEntity {
  @Index(unique: true, replace: true)
  late String name;

  String? description;
  String? iconName;
  String? color;
  List<String>? tabs;
  String? defaultUom;
  double? defaultGst;
  String? skuPrefix;
  String? displayUnit;
  late String createdAt;
}
