import '../vehicles_service.dart';
import 'vehicle_yearly_detailed_report_models.dart';

class VehicleYearlyDetailedReportService {
  final VehiclesService _vehiclesService;

  const VehicleYearlyDetailedReportService(this._vehiclesService);

  Future<VehicleYearlyDetailedReportData> getReport({
    required VehicleYearlyDetailedReportQuery query,
  }) async {
    final vehicles = await _vehiclesService.getVehicles();
    final selectedVehicles = _filterVehicles(vehicles, query.vehicleId);

    final startDate = DateTime(query.year, 1, 1);
    final endDate = DateTime(query.year, 12, 31, 23, 59, 59, 999);

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

    final buckets = {
      for (final vehicle in selectedVehicles)
        vehicle.id: _VehicleYearBucket.fromVehicle(vehicle),
    };

    for (final log in maintenanceLogs) {
      final date = DateTime.tryParse(log.serviceDate)?.toLocal();
      if (date == null || date.year != query.year) continue;

      final bucket = buckets[log.vehicleId];
      if (bucket == null) continue;
      final monthBucket = bucket.months[date.month]!;
      monthBucket.maintenanceCost += log.totalCost;
      monthBucket.maintenanceEntries += 1;
    }

    for (final log in tyreLogs) {
      final date = DateTime.tryParse(log.installationDate)?.toLocal();
      if (date == null || date.year != query.year) continue;

      final bucket = buckets[log.vehicleId];
      if (bucket == null) continue;
      final monthBucket = bucket.months[date.month]!;
      monthBucket.tyreCost += log.totalCost;
      monthBucket.tyreEntries += 1;
      monthBucket.tyreReplacements += log.items.length;
    }

    final details = buckets.values.map((bucket) => bucket.toDetail()).toList()
      ..sort(_compareVehicleDetails);

    final summary = _buildSummary(details);

    return VehicleYearlyDetailedReportData(
      generatedAt: DateTime.now(),
      query: query,
      vehicles: details,
      summary: summary,
    );
  }

  List<Vehicle> _filterVehicles(List<Vehicle> vehicles, String? vehicleId) {
    final normalized = _normalizedVehicleId(vehicleId);
    if (normalized == null) return vehicles;
    return vehicles.where((vehicle) => vehicle.id == normalized).toList();
  }

  String? _normalizedVehicleId(String? rawVehicleId) {
    final trimmed = rawVehicleId?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  int _compareVehicleDetails(
    VehicleYearlyVehicleDetail a,
    VehicleYearlyVehicleDetail b,
  ) {
    final byTotal = b.totalCost.compareTo(a.totalCost);
    if (byTotal != 0) return byTotal;

    return a.vehicleNumber.toLowerCase().compareTo(b.vehicleNumber.toLowerCase());
  }

  VehicleYearlyDetailedSummary _buildSummary(
    List<VehicleYearlyVehicleDetail> vehicles,
  ) {
    var totalCost = 0.0;
    var maintenanceCost = 0.0;
    var maintenanceEntries = 0;
    var tyreCost = 0.0;
    var tyreEntries = 0;
    var tyreReplacements = 0;

    for (final vehicle in vehicles) {
      totalCost += vehicle.totalCost;
      maintenanceCost += vehicle.totalMaintenanceCost;
      maintenanceEntries += vehicle.totalMaintenanceEntries;
      tyreCost += vehicle.totalTyreCost;
      tyreEntries += vehicle.totalTyreEntries;
      tyreReplacements += vehicle.totalTyreReplacements;
    }

    return VehicleYearlyDetailedSummary(
      vehicleCount: vehicles.length,
      totalCost: totalCost,
      maintenanceCost: maintenanceCost,
      maintenanceEntries: maintenanceEntries,
      tyreCost: tyreCost,
      tyreEntries: tyreEntries,
      tyreReplacements: tyreReplacements,
    );
  }
}

class _VehicleYearBucket {
  final String vehicleId;
  final String vehicleNumber;
  final String vehicleName;
  final String vehicleType;
  final Map<int, _MonthBucket> months;

  _VehicleYearBucket({
    required this.vehicleId,
    required this.vehicleNumber,
    required this.vehicleName,
    required this.vehicleType,
    required this.months,
  });

  factory _VehicleYearBucket.fromVehicle(Vehicle vehicle) {
    final monthBuckets = {
      for (var month = 1; month <= 12; month++) month: _MonthBucket(month: month),
    };
    return _VehicleYearBucket(
      vehicleId: vehicle.id,
      vehicleNumber: vehicle.number,
      vehicleName: vehicle.name,
      vehicleType: vehicle.type,
      months: monthBuckets,
    );
  }

  VehicleYearlyVehicleDetail toDetail() {
    final monthDetails = months.values.map((month) => month.toDetail()).toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    var totalMaintenanceCost = 0.0;
    var totalMaintenanceEntries = 0;
    var totalTyreCost = 0.0;
    var totalTyreEntries = 0;
    var totalTyreReplacements = 0;

    for (final month in monthDetails) {
      totalMaintenanceCost += month.maintenanceCost;
      totalMaintenanceEntries += month.maintenanceEntries;
      totalTyreCost += month.tyreCost;
      totalTyreEntries += month.tyreEntries;
      totalTyreReplacements += month.tyreReplacements;
    }

    return VehicleYearlyVehicleDetail(
      vehicleId: vehicleId,
      vehicleNumber: vehicleNumber,
      vehicleName: vehicleName,
      vehicleType: vehicleType,
      months: monthDetails,
      totalMaintenanceCost: totalMaintenanceCost,
      totalMaintenanceEntries: totalMaintenanceEntries,
      totalTyreCost: totalTyreCost,
      totalTyreEntries: totalTyreEntries,
      totalTyreReplacements: totalTyreReplacements,
    );
  }
}

class _MonthBucket {
  final int month;

  double maintenanceCost = 0.0;
  int maintenanceEntries = 0;
  double tyreCost = 0.0;
  int tyreEntries = 0;
  int tyreReplacements = 0;

  _MonthBucket({required this.month});

  VehicleYearlyMonthDetail toDetail() {
    return VehicleYearlyMonthDetail(
      month: month,
      maintenanceCost: maintenanceCost,
      maintenanceEntries: maintenanceEntries,
      tyreCost: tyreCost,
      tyreEntries: tyreEntries,
      tyreReplacements: tyreReplacements,
    );
  }
}
