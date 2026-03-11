import '../vehicles_service.dart';
import 'vehicle_monthly_expense_report_models.dart';

class VehicleMonthlyExpenseReportService {
  final VehiclesService _vehiclesService;

  const VehicleMonthlyExpenseReportService(this._vehiclesService);

  Future<VehicleMonthlyExpenseReportData> getReport({
    required VehicleMonthlyExpenseReportQuery query,
  }) async {
    final vehicles = await _vehiclesService.getVehicles();
    final startDate = _rangeStart(query.year, query.month);
    final endDate = _rangeEnd(query.year, query.month);

    final maintenanceLogs = await _vehiclesService.getMaintenanceLogs(
      vehicleId: _normalizedVehicleId(query.vehicleId),
      startDate: startDate,
      endDate: endDate,
    );
    final tyreLogs = await _vehiclesService.getTyreLogs(
      vehicleId: _normalizedVehicleId(query.vehicleId),
      startDate: startDate,
      endDate: endDate,
    );

    final vehicleById = {for (final v in vehicles) v.id: v};
    final grouped = <String, _MonthlyBucket>{};

    for (final log in maintenanceLogs) {
      final date = DateTime.tryParse(log.serviceDate)?.toLocal();
      if (date == null || !_matchesQueryMonth(date, query)) continue;

      final vehicle = vehicleById[log.vehicleId];
      final key = _groupKey(log.vehicleId, date.year, date.month);
      final bucket = grouped.putIfAbsent(
        key,
        () => _MonthlyBucket(
          year: date.year,
          month: date.month,
          vehicleId: log.vehicleId,
          vehicleNumber: vehicle?.number ?? log.vehicleNumber,
          vehicleName: vehicle?.name ?? '',
        ),
      );
      bucket.maintenanceCost += log.totalCost;
      bucket.maintenanceEntries += 1;
    }

    for (final log in tyreLogs) {
      final date = DateTime.tryParse(log.installationDate)?.toLocal();
      if (date == null || !_matchesQueryMonth(date, query)) continue;

      final vehicle = vehicleById[log.vehicleId];
      final key = _groupKey(log.vehicleId, date.year, date.month);
      final bucket = grouped.putIfAbsent(
        key,
        () => _MonthlyBucket(
          year: date.year,
          month: date.month,
          vehicleId: log.vehicleId,
          vehicleNumber: vehicle?.number ?? log.vehicleNumber,
          vehicleName: vehicle?.name ?? '',
        ),
      );
      bucket.tyreCost += log.totalCost;
      bucket.tyreEntries += 1;
      bucket.tyreReplacements += log.items.length;
    }

    final rows = grouped.values
        .map((bucket) => bucket.toRow())
        .toList()
      ..sort(_compareRows);

    final summary = _buildSummary(rows);

    return VehicleMonthlyExpenseReportData(
      generatedAt: DateTime.now(),
      query: query,
      rows: rows,
      summary: summary,
    );
  }

  String? _normalizedVehicleId(String? rawVehicleId) {
    final trimmed = rawVehicleId?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  DateTime _rangeStart(int year, int? month) {
    if (month == null) return DateTime(year, 1, 1);
    return DateTime(year, month, 1);
  }

  DateTime _rangeEnd(int year, int? month) {
    if (month == null) {
      return DateTime(year, 12, 31, 23, 59, 59, 999);
    }
    final nextMonthFirstDay = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    return nextMonthFirstDay.subtract(const Duration(milliseconds: 1));
  }

  bool _matchesQueryMonth(DateTime date, VehicleMonthlyExpenseReportQuery query) {
    if (date.year != query.year) return false;
    if (query.month != null && date.month != query.month) return false;
    return true;
  }

  String _groupKey(String vehicleId, int year, int month) {
    return '$vehicleId|$year|$month';
  }

  int _compareRows(VehicleMonthlyExpenseRow a, VehicleMonthlyExpenseRow b) {
    final byYear = b.year.compareTo(a.year);
    if (byYear != 0) return byYear;

    final byMonth = b.month.compareTo(a.month);
    if (byMonth != 0) return byMonth;

    final byTotal = b.totalCost.compareTo(a.totalCost);
    if (byTotal != 0) return byTotal;

    return a.vehicleNumber.toLowerCase().compareTo(b.vehicleNumber.toLowerCase());
  }

  VehicleMonthlyExpenseSummary _buildSummary(List<VehicleMonthlyExpenseRow> rows) {
    var totalCost = 0.0;
    var maintenanceCost = 0.0;
    var tyreCost = 0.0;
    var maintenanceEntries = 0;
    var tyreEntries = 0;
    var tyreReplacements = 0;

    for (final row in rows) {
      totalCost += row.totalCost;
      maintenanceCost += row.maintenanceCost;
      tyreCost += row.tyreCost;
      maintenanceEntries += row.maintenanceEntries;
      tyreEntries += row.tyreEntries;
      tyreReplacements += row.tyreReplacements;
    }

    return VehicleMonthlyExpenseSummary(
      totalCost: totalCost,
      maintenanceCost: maintenanceCost,
      tyreCost: tyreCost,
      maintenanceEntries: maintenanceEntries,
      tyreEntries: tyreEntries,
      tyreReplacements: tyreReplacements,
    );
  }
}

class _MonthlyBucket {
  final int year;
  final int month;
  final String vehicleId;
  final String vehicleNumber;
  final String vehicleName;

  double maintenanceCost = 0.0;
  int maintenanceEntries = 0;
  double tyreCost = 0.0;
  int tyreEntries = 0;
  int tyreReplacements = 0;

  _MonthlyBucket({
    required this.year,
    required this.month,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.vehicleName,
  });

  VehicleMonthlyExpenseRow toRow() {
    return VehicleMonthlyExpenseRow(
      year: year,
      month: month,
      vehicleId: vehicleId,
      vehicleNumber: vehicleNumber,
      vehicleName: vehicleName,
      maintenanceCost: maintenanceCost,
      maintenanceEntries: maintenanceEntries,
      tyreCost: tyreCost,
      tyreEntries: tyreEntries,
      tyreReplacements: tyreReplacements,
    );
  }
}
