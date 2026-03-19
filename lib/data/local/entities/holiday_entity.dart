import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';
import '../../../modules/hr/models/holiday_model.dart';

part 'holiday_entity.g.dart';

@Collection()
class HolidayEntity extends BaseEntity {
  late String name;

  @Index()
  late String date; // YYYY-MM-DD

  bool isRecurring = false;
  String? description;

  Holiday toDomain() {
    return Holiday(
      id: id,
      name: name,
      date: DateTime.parse(date),
      isRecurring: isRecurring,
      description: description,
    );
  }

  static HolidayEntity fromDomain(Holiday model) {
    return HolidayEntity()
      ..id = model.id.isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : model.id
      ..name = model.name
      ..date = model.date.toString().split(' ')[0]
      ..isRecurring = model.isRecurring
      ..description = model.description
      ..updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'date': date,
      'isRecurring': isRecurring,
      'description': description,
      'updatedAt': updatedAt.toIso8601String(),
      'lastModified': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus.name,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  static HolidayEntity fromJson(Map<String, dynamic> json) {
    final description = parseString(json['description']);

    return HolidayEntity()
      ..id = parseString(json['id'])
      ..name = parseString(json['name'])
      ..date = parseDate(json['date']).toIso8601String().split('T').first
      ..isRecurring = parseBool(json['isRecurring'])
      ..description = description.isEmpty ? null : description
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }
}
