import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'category_entity.g.dart';

@Collection()
class CategoryEntity extends BaseEntity {
  @Index()
  late String name;

  @Index()
  late String itemType;

  late String createdAt;
}
