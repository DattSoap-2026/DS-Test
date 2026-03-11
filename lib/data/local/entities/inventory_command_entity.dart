import 'package:isar/isar.dart';

import '../base_entity.dart';

part 'inventory_command_entity.g.dart';

@Collection()
class InventoryCommandEntity extends BaseEntity {
  @Index(unique: true, replace: true)
  String get commandId => id;
  set commandId(String value) => id = value;

  @Index(caseSensitive: false)
  late String commandType;

  late String payload;

  @Index()
  late String actorUid;

  String? actorLegacyAppUserId;

  late DateTime createdAt;

  bool appliedLocally = false;
  bool appliedRemotely = false;
  String? retryMeta;
}
