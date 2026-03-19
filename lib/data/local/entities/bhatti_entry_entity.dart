import 'package:isar/isar.dart';

import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'bhatti_entry_entity.g.dart';

@Collection()
class BhattiDailyEntryEntity extends BaseEntity {
  @Index()
  late DateTime date;

  late String bhattiId;
  late String bhattiName;
  String? teamCode;
  late int batchCount;
  late int outputBoxes;
  late double fuelConsumption;
  late String createdBy;
  late String createdByName;
  late DateTime createdAt;
  String? notes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'date': date.toIso8601String(),
      'bhattiId': bhattiId,
      'bhattiName': bhattiName,
      'teamCode': teamCode,
      'batchCount': batchCount,
      'outputBoxes': outputBoxes,
      'fuelConsumption': fuelConsumption,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastModified': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus.name,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
      'notes': notes,
    };
  }

  Map<String, dynamic> toFirebaseJson() => toJson();

  static BhattiDailyEntryEntity fromJson(Map<String, dynamic> json) {
    return BhattiDailyEntryEntity()
      ..id = parseString(json['id'])
      ..date = parseDate(json['date'])
      ..bhattiId = parseString(json['bhattiId'])
      ..bhattiName = parseString(json['bhattiName'])
      ..teamCode = parseString(json['teamCode'], fallback: '')
      ..batchCount = parseInt(json['batchCount'])
      ..outputBoxes = parseInt(json['outputBoxes'])
      ..fuelConsumption = parseDouble(json['fuelConsumption'])
      ..createdBy = parseString(json['createdBy'])
      ..createdByName = parseString(json['createdByName'])
      ..createdAt = parseDate(json['createdAt'])
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId'])
      ..notes = parseString(json['notes'], fallback: '');
  }

  static BhattiDailyEntryEntity fromFirebaseJson(Map<String, dynamic> json) {
    return fromJson(<String, dynamic>{
      ...json,
      'syncStatus': SyncStatus.synced.name,
      'isSynced': true,
      'lastSynced': DateTime.now().toIso8601String(),
    });
  }
}
