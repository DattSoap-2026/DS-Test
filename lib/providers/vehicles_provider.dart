import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/vehicles_service.dart';
import 'service_providers.dart';

final vehiclesFutureProvider = FutureProvider<List<Vehicle>>((ref) async {
  final service = ref.watch(vehiclesServiceProvider);
  return service.getVehicles();
});
