import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/sync/collection_registry.dart';
import '../../../data/local/entities/bhatti_batch_entity.dart';
import '../../../data/local/entities/cutting_batch_entity.dart';
import '../../../providers/service_providers.dart' show bhattiRepositoryProvider;

export '../../../providers/service_providers.dart' show bhattiRepositoryProvider;

final watchBhattiBatchesProvider = StreamProvider<List<BhattiBatchEntity>>((ref) {
  return ref.watch(bhattiRepositoryProvider).watchAllBhattiBatches();
});

final watchCuttingBatchesProvider = StreamProvider<List<CuttingBatchEntity>>((ref) {
  return ref.watch(bhattiRepositoryProvider).watchAllCuttingBatches();
});

final pendingBhattiSyncCountProvider = FutureProvider<int>((ref) async {
  final queueService = ref.read(syncQueueServiceProvider);
  var total = 0;
  for (final collection in <String>[
    CollectionRegistry.bhattiBatches,
    CollectionRegistry.bhattiDailyEntries,
    CollectionRegistry.cuttingBatches,
    CollectionRegistry.wastageLogs,
  ]) {
    total += await queueService.getPendingCount(collectionName: collection);
  }
  return total;
});
