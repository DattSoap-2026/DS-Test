import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../../services/offline_first_service.dart';
import '../models/holiday_model.dart';
import '../../../data/local/entities/holiday_entity.dart';

class HolidayService extends OfflineFirstService with ChangeNotifier {
  HolidayService(super.firebase, super.dbService);

  @override
  String get localStorageKey => 'local_holidays';

  @override
  bool get useIsar => true;

  Future<List<Holiday>> getAllHolidays() async {
    final entities = await dbService.db.holidayEntitys.where().findAll();
    return entities.map((e) => e.toDomain()).toList();
  }

  Future<List<Holiday>> getHolidaysForMonth(int year, int month) async {
    final startStr = '$year-${month.toString().padLeft(2, '0')}-01';
    final lastDay = DateTime(year, month + 1, 0).day;
    final endStr = '$year-${month.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';

    final entities = await dbService.db.holidayEntitys
        .filter()
        .dateBetween(startStr, endStr)
        .findAll();
    
    return entities.map((e) => e.toDomain()).toList();
  }

  Future<void> addHoliday(Holiday holiday) async {
    final entity = HolidayEntity.fromDomain(holiday);
    await dbService.db.writeTxn(() async {
      await dbService.db.holidayEntitys.put(entity);
    });

    await syncToFirebase(
      'set',
      holiday.toMap(),
      collectionName: 'holidays',
    );
    
    notifyListeners();
  }

  Future<void> deleteHoliday(String id) async {
    // Find entity by business ID
    final entity = await dbService.db.holidayEntitys.filter().idEqualTo(id).findFirst();
    if (entity != null) {
      await dbService.db.writeTxn(() async {
        await dbService.db.holidayEntitys.delete(entity.isarId);
      });

      await syncToFirebase(
        'delete',
        {'id': id},
        collectionName: 'holidays',
      );
    }
    
    notifyListeners();
  }

  bool isHoliday(DateTime date, List<Holiday> holidays) {
    final dateStr = date.toString().split(' ')[0];
    return holidays.any((h) => h.date.toString().split(' ')[0] == dateStr);
  }
}
