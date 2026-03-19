import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'settings_cache_entity.g.dart';

@Collection()
class SettingsCacheEntity {
  @Index(unique: true, replace: true)
  late String key;

  late String payloadJson;
  bool isSynced = false;
  bool isDeleted = false;
  DateTime lastModified = DateTime.now();
  DateTime? lastSynced;
  int version = 1;
  String deviceId = '';

  Id get isarId => fastHash(key);
}
