import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/sync/collection_registry.dart';
import '../../../data/local/entities/duty_session_entity.dart';
import '../../../data/local/entities/tyre_stock_entity.dart';
import '../../../data/local/entities/vehicle_entity.dart';
import '../../../data/local/entities/vehicle_issue_entity.dart';
import '../../../data/repositories/duty_repository.dart';
import '../../../data/repositories/fleet_repository.dart';
import '../../../providers/service_providers.dart';

export '../../../data/local/entities/duty_session_entity.dart';
export '../../../data/local/entities/tyre_stock_entity.dart';
export '../../../data/local/entities/vehicle_entity.dart';
export '../../../data/local/entities/vehicle_issue_entity.dart';
export '../../../data/repositories/duty_repository.dart';
export '../../../data/repositories/fleet_repository.dart';

/// Shared fleet repository provider.
final fleetRepositoryProvider = Provider<FleetRepository>((ref) {
  return FleetRepository(
    ref.read(databaseServiceProvider),
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

/// Shared duty repository provider.
final dutyRepositoryProvider = Provider<DutyRepository>((ref) {
  return DutyRepository(
    ref.read(databaseServiceProvider),
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

/// Streams all fleet vehicles from Isar.
final allVehiclesProvider = StreamProvider<List<VehicleEntity>>((ref) {
  return ref.read(fleetRepositoryProvider).watchAllVehicles();
});

/// Streams only active fleet vehicles from Isar.
final activeVehiclesProvider = StreamProvider<List<VehicleEntity>>((ref) {
  return ref.read(fleetRepositoryProvider).watchActiveVehicles();
});

/// Streams all tyre stock from Isar.
final allTyreStockProvider = StreamProvider<List<TyreStockEntity>>((ref) {
  return ref.read(fleetRepositoryProvider).watchAllTyreStock();
});

/// Streams unresolved vehicle issues from Isar.
final openVehicleIssuesProvider = StreamProvider<List<VehicleIssueEntity>>((ref) {
  return ref.read(fleetRepositoryProvider).watchOpenIssues();
});

/// Streams the active duty session for the provided user id.
final activeSessionProvider = StreamProvider.family<DutySessionEntity?, String>((
  ref,
  userId,
) {
  return ref.read(dutyRepositoryProvider).watchActiveSession(userId);
});

/// Aggregated pending sync count for fleet and duty collections.
final pendingFleetSyncCountProvider = FutureProvider<int>((ref) async {
  final queueService = ref.read(syncQueueServiceProvider);
  var total = 0;
  for (final collection in <String>[
    CollectionRegistry.vehicles,
    CollectionRegistry.dieselLogs,
    CollectionRegistry.vehicleMaintenanceLogs,
    CollectionRegistry.tyreLogs,
    CollectionRegistry.tyreItems,
    CollectionRegistry.vehicleIssues,
    CollectionRegistry.dutySessions,
    CollectionRegistry.fuelPurchases,
  ]) {
    total += await queueService.getPendingCount(collectionName: collection);
  }
  return total;
});
