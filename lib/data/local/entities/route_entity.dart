import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'route_entity.g.dart';

@Collection()
class RouteEntity extends BaseEntity {
  @Index(type: IndexType.value)
  late String name;

  String? description;

  @Index()
  bool isActive = true;

  @Index()
  late String createdAt;
}
