import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/sync/collection_registry.dart';
import '../../../data/local/entities/production_entry_entity.dart';
import '../../../data/local/entities/production_target_entity.dart';
import '../../../providers/service_providers.dart' show productionRepositoryProvider;

export '../../../providers/service_providers.dart' show productionRepositoryProvider;

final watchProductionEntriesProvider = StreamProvider<List<ProductionDailyEntryEntity>>((ref) {
  return ref.watch(productionRepositoryProvider).watchAllProductionEntries();
});

final watchProductionTargetsProvider = StreamProvider<List<ProductionTargetEntity>>((ref) {
  return ref.watch(productionRepositoryProvider).watchAllTargets();
});

final pendingProductionSyncCountProvider = FutureProvider<int>((ref) async {
  final queueService = ref.read(syncQueueServiceProvider);
  var total = 0;
  for (final collection in <String>[
    CollectionRegistry.productionEntries,
    CollectionRegistry.productionTargets,
    CollectionRegistry.detailedProductionLogs,
  ]) {
    total += await queueService.getPendingCount(collectionName: collection);
  }
  return total;
});
