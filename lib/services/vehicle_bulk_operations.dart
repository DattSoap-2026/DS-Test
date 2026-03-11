import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'vehicles_service.dart';

class VehicleBulkOperations {
  final VehiclesService _vehiclesService;

  VehicleBulkOperations(this._vehiclesService);

  // Export vehicles to CSV
  Future<String> exportVehiclesToCSV(List<Vehicle> vehicles) async {
    final rows = <List<dynamic>>[
      [
        'Vehicle Number',
        'Name',
        'Type',
        'Status',
        'Model',
        'Fuel Type',
        'Current Odometer',
        'Total Distance',
        'Total Maintenance Cost',
        'Total Diesel Cost',
        'Total Tyre Cost',
        'Cost Per Km',
        'Insurance Expiry',
        'PUC Expiry',
        'Permit Expiry',
        'Fitness Expiry',
      ],
    ];

    for (final vehicle in vehicles) {
      rows.add([
        vehicle.number,
        vehicle.name,
        vehicle.type,
        vehicle.status,
        vehicle.model ?? '',
        vehicle.fuelType ?? '',
        vehicle.currentOdometer,
        vehicle.totalDistance,
        vehicle.totalMaintenanceCost,
        vehicle.totalDieselCost,
        vehicle.totalTyreCost,
        vehicle.costPerKm,
        vehicle.insuranceExpiryDate != null ? DateFormat('yyyy-MM-dd').format(vehicle.insuranceExpiryDate!) : '',
        vehicle.pucExpiryDate != null ? DateFormat('yyyy-MM-dd').format(vehicle.pucExpiryDate!) : '',
        vehicle.permitExpiryDate != null ? DateFormat('yyyy-MM-dd').format(vehicle.permitExpiryDate!) : '',
        vehicle.fitnessExpiryDate != null ? DateFormat('yyyy-MM-dd').format(vehicle.fitnessExpiryDate!) : '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  // Import vehicles from CSV
  Future<Map<String, dynamic>> importVehiclesFromCSV(String csvContent) async {
    final rows = const CsvToListConverter().convert(csvContent);
    if (rows.isEmpty) {
      throw Exception('CSV file is empty');
    }

    final headers = rows.first.map((e) => e.toString().toLowerCase()).toList();
    final dataRows = rows.skip(1).toList();

    int successCount = 0;
    int errorCount = 0;
    final errors = <String>[];

    for (var i = 0; i < dataRows.length; i++) {
      try {
        final row = dataRows[i];
        final data = <String, dynamic>{};

        for (var j = 0; j < headers.length && j < row.length; j++) {
          final header = headers[j];
          final value = row[j]?.toString().trim() ?? '';

          if (header.contains('number')) {
            data['number'] = value;
          } else if (header.contains('name')) {
            data['name'] = value;
          } else if (header.contains('type')) {
            data['type'] = value;
          } else if (header.contains('status')) {
            data['status'] = value;
          } else if (header.contains('model')) {
            data['model'] = value;
          } else if (header.contains('fuel')) {
            data['fuelType'] = value;
          } else if (header.contains('odometer')) {
            data['currentOdometer'] = double.tryParse(value) ?? 0;
          }
        }

        if (data['number'] == null || data['number'].toString().isEmpty) {
          errors.add('Row ${i + 2}: Vehicle number is required');
          errorCount++;
          continue;
        }

        await _vehiclesService.addVehicle(data);
        successCount++;
      } catch (e) {
        errors.add('Row ${i + 2}: $e');
        errorCount++;
      }
    }

    return {
      'success': successCount,
      'errors': errorCount,
      'errorMessages': errors,
    };
  }

  // Bulk status update
  Future<int> bulkUpdateStatus(List<String> vehicleIds, String newStatus) async {
    int count = 0;
    for (final id in vehicleIds) {
      try {
        await _vehiclesService.updateVehicle(id, {'status': newStatus});
        count++;
      } catch (e) {
        // Continue with next vehicle
      }
    }
    return count;
  }
}
