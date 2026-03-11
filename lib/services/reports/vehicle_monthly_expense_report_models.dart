class VehicleMonthlyExpenseReportQuery {
  final int year;
  final int? month;
  final String? vehicleId;

  const VehicleMonthlyExpenseReportQuery({
    required this.year,
    this.month,
    this.vehicleId,
  });
}

class VehicleMonthlyExpenseRow {
  final int year;
  final int month;
  final String vehicleId;
  final String vehicleNumber;
  final String vehicleName;
  final double maintenanceCost;
  final int maintenanceEntries;
  final double tyreCost;
  final int tyreEntries;
  final int tyreReplacements;

  const VehicleMonthlyExpenseRow({
    required this.year,
    required this.month,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.vehicleName,
    required this.maintenanceCost,
    required this.maintenanceEntries,
    required this.tyreCost,
    required this.tyreEntries,
    required this.tyreReplacements,
  });

  double get totalCost => maintenanceCost + tyreCost;
}

class VehicleMonthlyExpenseSummary {
  final double totalCost;
  final double maintenanceCost;
  final double tyreCost;
  final int maintenanceEntries;
  final int tyreEntries;
  final int tyreReplacements;

  const VehicleMonthlyExpenseSummary({
    required this.totalCost,
    required this.maintenanceCost,
    required this.tyreCost,
    required this.maintenanceEntries,
    required this.tyreEntries,
    required this.tyreReplacements,
  });
}

class VehicleMonthlyExpenseReportData {
  final DateTime generatedAt;
  final VehicleMonthlyExpenseReportQuery query;
  final List<VehicleMonthlyExpenseRow> rows;
  final VehicleMonthlyExpenseSummary summary;

  const VehicleMonthlyExpenseReportData({
    required this.generatedAt,
    required this.query,
    required this.rows,
    required this.summary,
  });
}
