import '../vehicles_service.dart';
import 'vehicle_expiry_report_models.dart';

class VehicleExpiryReportService {
  final VehiclesService _vehiclesService;

  const VehicleExpiryReportService(this._vehiclesService);

  Future<VehicleExpiryReportData> getReport({
    VehicleExpiryReportQuery query = const VehicleExpiryReportQuery(),
  }) async {
    final vehicles = await _vehiclesService.getVehicles();
    return buildFromVehicles(vehicles, query: query);
  }

  VehicleExpiryReportData buildFromVehicles(
    List<Vehicle> vehicles, {
    VehicleExpiryReportQuery query = const VehicleExpiryReportQuery(),
  }) {
    final referenceDate = (query.asOfDate ?? DateTime.now()).toLocal();
    final rows = <VehicleExpiryReportRow>[];

    for (final vehicle in vehicles) {
      if (_isVehicleFilteredOut(vehicle, query.vehicleId)) {
        continue;
      }

      final documentDates = <VehicleDocumentType, DateTime?>{
        VehicleDocumentType.insurance: vehicle.insuranceExpiryDate,
        VehicleDocumentType.puc: vehicle.pucExpiryDate,
        VehicleDocumentType.permit: vehicle.permitExpiryDate,
        VehicleDocumentType.fitness: vehicle.fitnessExpiryDate,
      };

      for (final entry in documentDates.entries) {
        if (_isDocumentFilteredOut(entry.key, query.documentType)) {
          continue;
        }

        final status = VehicleExpiryStatusClassifier.classify(
          entry.value,
          referenceDate: referenceDate,
        );
        if (status == VehicleExpiryStatus.noData && !query.includeNoData) {
          continue;
        }
        if (_isStatusFilteredOut(status, query.status)) {
          continue;
        }

        rows.add(
          VehicleExpiryReportRow(
            vehicleId: vehicle.id,
            vehicleNumber: vehicle.number,
            vehicleName: vehicle.name,
            vehicleType: vehicle.type,
            documentType: entry.key,
            expiryDate: entry.value,
            status: status,
            daysRemaining: VehicleExpiryStatusClassifier.daysUntil(
              entry.value,
              referenceDate: referenceDate,
            ),
          ),
        );
      }
    }

    rows.sort(_compareRows);

    return VehicleExpiryReportData(
      generatedAt: DateTime.now(),
      asOfDate: referenceDate,
      rows: rows,
      statusCounts: _buildStatusCounts(rows),
    );
  }

  bool _isVehicleFilteredOut(Vehicle vehicle, String? queryVehicleId) {
    final selectedVehicleId = queryVehicleId?.trim();
    return selectedVehicleId != null &&
        selectedVehicleId.isNotEmpty &&
        vehicle.id != selectedVehicleId;
  }

  bool _isDocumentFilteredOut(
    VehicleDocumentType documentType,
    VehicleDocumentType? selectedDocument,
  ) {
    return selectedDocument != null && documentType != selectedDocument;
  }

  bool _isStatusFilteredOut(
    VehicleExpiryStatus status,
    VehicleExpiryStatus? selectedStatus,
  ) {
    return selectedStatus != null && status != selectedStatus;
  }

  int _compareRows(VehicleExpiryReportRow a, VehicleExpiryReportRow b) {
    final byStatus = a.status.sortOrder.compareTo(b.status.sortOrder);
    if (byStatus != 0) return byStatus;

    final byDays = (a.daysRemaining ?? 99999).compareTo(b.daysRemaining ?? 99999);
    if (byDays != 0) return byDays;

    final byVehicleNumber = a.vehicleNumber.toLowerCase().compareTo(
      b.vehicleNumber.toLowerCase(),
    );
    if (byVehicleNumber != 0) return byVehicleNumber;

    return a.documentType.index.compareTo(b.documentType.index);
  }

  Map<VehicleExpiryStatus, int> _buildStatusCounts(
    List<VehicleExpiryReportRow> rows,
  ) {
    final counts = <VehicleExpiryStatus, int>{
      VehicleExpiryStatus.expired: 0,
      VehicleExpiryStatus.critical: 0,
      VehicleExpiryStatus.upcoming: 0,
      VehicleExpiryStatus.ok: 0,
      VehicleExpiryStatus.noData: 0,
    };

    for (final row in rows) {
      counts[row.status] = (counts[row.status] ?? 0) + 1;
    }
    return counts;
  }
}
