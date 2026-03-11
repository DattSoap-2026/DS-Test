import '../../services/offline_first_service.dart';

const String financialYearsCollection = 'financial_years';

class FinancialYearService extends OfflineFirstService {
  FinancialYearService(super.firebase);

  @override
  String get localStorageKey => 'local_financial_years';

  static String financialYearIdForDate(DateTime date) {
    final startYear = date.month >= 4 ? date.year : date.year - 1;
    final endYear = startYear + 1;
    return '$startYear-$endYear';
  }

  static DateTime startDateForFinancialYearId(String financialYearId) {
    final startYear =
        int.tryParse(financialYearId.split('-').first) ?? DateTime.now().year;
    return DateTime(startYear, 4, 1);
  }

  static DateTime endDateForFinancialYearId(String financialYearId) {
    final endYear =
        int.tryParse(financialYearId.split('-').last) ?? DateTime.now().year;
    return DateTime(endYear, 3, 31, 23, 59, 59, 999);
  }

  Future<List<Map<String, dynamic>>> getFinancialYears() async {
    try {
      var local = await loadFromLocal();
      if (local.isEmpty) {
        local = await bootstrapFromFirebase(
          collectionName: financialYearsCollection,
        );
        if (local.isNotEmpty) {
          await saveToLocal(local);
        }
      }

      local.sort(
        (a, b) =>
            (a['id'] ?? '').toString().compareTo((b['id'] ?? '').toString()),
      );
      return local;
    } catch (e) {
      handleError(e, 'getFinancialYears');
      return [];
    }
  }

  Future<Map<String, dynamic>> ensureFinancialYearForDate(
    DateTime date, {
    String? createdBy,
  }) async {
    final financialYearId = financialYearIdForDate(date);
    final existing = await getFinancialYear(financialYearId);
    if (existing != null) return existing;

    final now = getCurrentTimestamp();
    final start = startDateForFinancialYearId(financialYearId);
    final end = endDateForFinancialYearId(financialYearId);

    final payload = <String, dynamic>{
      'id': financialYearId,
      'startDate': start.toIso8601String(),
      'endDate': end.toIso8601String(),
      'isLocked': false,
      'createdAt': now,
      'updatedAt': now,
      if (createdBy != null && createdBy.isNotEmpty) 'createdBy': createdBy,
    };

    final years = await getFinancialYears();
    years.add(payload);
    await saveToLocal(years);
    await syncToFirebase(
      'set',
      payload,
      collectionName: financialYearsCollection,
      syncImmediately: false,
    );
    return payload;
  }

  Future<Map<String, dynamic>?> getFinancialYear(String financialYearId) async {
    final years = await getFinancialYears();
    for (final year in years) {
      if ((year['id'] ?? '').toString() == financialYearId) {
        return Map<String, dynamic>.from(year);
      }
    }
    return null;
  }

  Future<bool> isDateLocked(DateTime date) async {
    final yearId = financialYearIdForDate(date);
    return isFinancialYearLocked(yearId);
  }

  Future<bool> isFinancialYearLocked(String financialYearId) async {
    final year = await getFinancialYear(financialYearId);
    if (year == null) return false;
    return year['isLocked'] == true;
  }

  Future<void> setFinancialYearLock({
    required String financialYearId,
    required bool isLocked,
    String? lockedBy,
  }) async {
    final year = await ensureFinancialYearForDate(
      startDateForFinancialYearId(financialYearId),
      createdBy: lockedBy,
    );

    final now = getCurrentTimestamp();
    final updated = <String, dynamic>{
      ...year,
      'id': financialYearId,
      'isLocked': isLocked,
      'updatedAt': now,
      if (lockedBy != null && lockedBy.isNotEmpty) 'lockedBy': lockedBy,
      if (isLocked) 'lockedAt': now,
    };

    final years = await getFinancialYears();
    final index = years.indexWhere((item) => item['id'] == financialYearId);
    if (index >= 0) {
      years[index] = {...years[index], ...updated};
    } else {
      years.add(updated);
    }

    await saveToLocal(years);
    await syncToFirebase(
      'set',
      updated,
      collectionName: financialYearsCollection,
      syncImmediately: false,
    );
  }
}
