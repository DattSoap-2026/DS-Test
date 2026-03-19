import 'package:isar/isar.dart';

import '../entity_json_utils.dart';

part 'config_cache_entity.g.dart';

@Collection()
class ConfigCacheEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String configKey;

  @Index()
  late String collectionName;

  @Index()
  late String documentId;

  String payloadJson = '{}';
  int version = 1;
  DateTime? lastModified;
  DateTime? lastSynced;
  bool isSynced = false;
  String deviceId = '';

  Map<String, dynamic> toJson() {
    return {
      'isarId': isarId,
      'configKey': configKey,
      'collectionName': collectionName,
      'documentId': documentId,
      'payloadJson': payloadJson,
      'version': version,
      'lastModified': lastModified?.toIso8601String(),
      'lastSynced': lastSynced?.toIso8601String(),
      'isSynced': isSynced,
      'deviceId': deviceId,
    };
  }

  static ConfigCacheEntity fromJson(Map<String, dynamic> json) {
    return ConfigCacheEntity()
      ..isarId = parseInt(json['isarId'])
      ..configKey = parseString(json['configKey'])
      ..collectionName = parseString(json['collectionName'])
      ..documentId = parseString(json['documentId'])
      ..payloadJson = parseString(json['payloadJson'], fallback: '{}')
      ..version = parseInt(json['version'], fallback: 1)
      ..lastModified = parseDateOrNull(json['lastModified'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..isSynced = json['isSynced'] == true
      ..deviceId = parseString(json['deviceId']);
  }
}
