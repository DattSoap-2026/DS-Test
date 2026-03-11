class VehicleYearlyDetailedReportQuery {
  final int year;
  final String? vehicleId;

  const VehicleYearlyDetailedReportQuery({
    required this.year,
    this.vehicleId,
  });
}

class VehicleYearlyMonthDetail {
  final int month;
  final double maintenanceCost;
  final int maintenanceEntries;
  final double tyreCost;
  final int tyreEntries;
  final int tyreReplacements;

  const VehicleYearlyMonthDetail({
    required this.month,
    required this.maintenanceCost,
    required this.maintenanceEntries,
    required this.tyreCost,
    required this.tyreEntries,
    required this.tyreReplacements,
  });

  double get totalCost => maintenanceCost + tyreCost;
}

class VehicleYearlyVehicleDetail {
  final String vehicleId;
  final String vehicleNumber;
  final String vehicleName;
  final String vehicleType;
  final List<VehicleYearlyMonthDetail> months;
  final double totalMaintenanceCost;
  final int totalMaintenanceEntries;
  final double totalTyreCost;
  final int totalTyreEntries;
  final int totalTyreReplacements;

  const VehicleYearlyVehicleDetail({
    required this.vehicleId,
    required this.vehicleNumber,
    required this.vehicleName,
    required this.vehicleType,
    required this.months,
    required this.totalMaintenanceCost,
    required this.totalMaintenanceEntries,
    required this.totalTyreCost,
    required this.totalTyreEntries,
    required this.totalTyreReplacements,
  });

  double get totalCost => totalMaintenanceCost + totalTyreCost;
}

class VehicleYearlyDetailedSummary {
  final int vehicleCount;
  final double totalCost;
  final double maintenanceCost;
  final int maintenanceEntries;
  final double tyreCost;
  final int tyreEntries;
  final int tyreReplacements;

  const VehicleYearlyDetailedSummary({
    required this.vehicleCount,
    required this.totalCost,
    required this.maintenanceCost,
    required this.maintenanceEntries,
    required this.tyreCost,
    required this.tyreEntries,
    required this.tyreReplacements,
  });
}

class VehicleYearlyDetailedReportData {
  final DateTime generatedAt;
  final VehicleYearlyDetailedReportQuery query;
  final List<VehicleYearlyVehicleDetail> vehicles;
  final VehicleYearlyDetailedSummary summary;

  const VehicleYearlyDetailedReportData({
    required this.generatedAt,
    required this.query,
    required this.vehicles,
    required this.summary,
  });
}
