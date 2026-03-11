import 'package:isar/isar.dart';
import '../base_entity.dart';
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
      ..id = model.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : model.id
      ..name = model.name
      ..date = model.date.toString().split(' ')[0]
      ..isRecurring = model.isRecurring
      ..description = model.description
      ..updatedAt = DateTime.now();
  }
}
