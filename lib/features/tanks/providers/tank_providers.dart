import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/sync/collection_registry.dart';
import '../../../data/local/entities/tank_entity.dart';
import '../../../providers/service_providers.dart' show tankRepositoryProvider;

export '../../../providers/service_providers.dart' show tankRepositoryProvider;

final watchTanksProvider = StreamProvider<List<TankEntity>>((ref) {
  return ref.watch(tankRepositoryProvider).watchAllTanks();
});

final pendingTankSyncCountProvider = FutureProvider<int>((ref) async {
  final queueService = ref.read(syncQueueServiceProvider);
  var total = 0;
  for (final collection in <String>[
    CollectionRegistry.tanks,
    CollectionRegistry.tankTransactions,
    CollectionRegistry.tankLots,
  ]) {
    total += await queueService.getPendingCount(collectionName: collection);
  }
  return total;
});
