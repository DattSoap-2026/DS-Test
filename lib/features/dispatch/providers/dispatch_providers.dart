import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/sync/collection_registry.dart';
import '../../../data/local/entities/dispatch_entity.dart';
import '../../../data/local/entities/route_order_entity.dart';
import '../../../data/repositories/dispatch_repository.dart';
import '../../../data/repositories/route_repository.dart';
import '../../../services/database_service.dart';

final dispatchRepositoryProvider = Provider<DispatchRepository>((ref) {
  return DispatchRepository(
    DatabaseService.instance,
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository(
    DatabaseService.instance,
    syncQueueService: ref.read(syncQueueServiceProvider),
    syncService: ref.read(syncServiceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
    deviceIdService: ref.read(deviceIdProvider),
  );
});

final watchDispatchesProvider = StreamProvider<List<DispatchEntity>>((ref) {
  return ref.watch(dispatchRepositoryProvider).watchAllDispatches();
});

final watchRouteOrdersProvider = StreamProvider<List<RouteOrderEntity>>((ref) {
  return ref.watch(routeRepositoryProvider).watchAllRouteOrders();
});

final pendingDispatchSyncCountProvider = FutureProvider<int>((ref) async {
  final queueService = ref.read(syncQueueServiceProvider);
  var total = 0;
  for (final collection in <String>[
    CollectionRegistry.dispatches,
    CollectionRegistry.routeOrders,
    CollectionRegistry.routeSessions,
    CollectionRegistry.customerVisits,
    CollectionRegistry.routes,
    CollectionRegistry.deliveryTrips,
  ]) {
    total += await queueService.getPendingCount(collectionName: collection);
  }
  return total;
});
