import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/isar_service.dart';
import '../network/connectivity_service.dart';
import '../sync/sync_queue_service.dart';
import '../sync/sync_service.dart';
import '../utils/device_id_service.dart';

/// Singleton Isar service provider.
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService.instance;
});

/// Singleton sync service provider.
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService.instance;
});

/// Singleton sync queue service provider.
final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  return SyncQueueService.instance;
});

/// Singleton connectivity service provider.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService.instance;
});

/// Connectivity state stream provider.
final connectivityProvider = StreamProvider<bool>((ref) {
  return ConnectivityService.instance.stream;
});

/// Stable device id service provider.
final deviceIdProvider = Provider<DeviceIdService>((ref) {
  return DeviceIdService.instance;
});

/// Shared sync status stream provider.
final coreSyncStatusProvider = StreamProvider<SyncStatusSnapshot>((ref) async* {
  yield SyncService.instance.currentStatus;
  yield* SyncService.instance.statusStream;
});

/// Shared pending sync queue count provider.
final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  return SyncQueueService.instance.getPendingCount();
});

/// Collection-specific sync status provider.
final collectionSyncStatusProvider =
    FutureProvider.family<CollectionSyncStatus, String>((ref, collection) async {
      return SyncService.instance.getSyncStatusFor(collection);
    });

/// Collection-specific pending sync count provider.
final collectionPendingCountProvider =
    FutureProvider.family<int, String>((ref, collection) async {
      return SyncQueueService.instance.getPendingCount(
        collectionName: collection,
      );
    });
