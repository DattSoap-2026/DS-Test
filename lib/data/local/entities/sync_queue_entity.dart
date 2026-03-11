import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'sync_queue_entity.g.dart';

@Collection()
class SyncQueueEntity extends BaseEntity {
  late String collection;
  late String action; // 'add', 'update', 'delete', ...
  late String dataJson; // Storing map as JSON String for flexibility
  late DateTime createdAt;

  @Index()
  int get timestamp => createdAt.millisecondsSinceEpoch;

  // Compatibility getter/setter for existing .g.dart and legacy code
  String get queueId => id;
  set queueId(String val) => id = val;
}
