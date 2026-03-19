import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../local/base_entity.dart';
import '../local/entities/trip_entity.dart';
import '../../services/database_service.dart';

class TripsRepository {
  TripsRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  static const Uuid _uuid = Uuid();

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  Future<List<TripEntity>> getAllTrips() {
    return _dbService.trips
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<TripEntity>> getActiveTrips() {
    return _dbService.trips
        .filter()
        .group(
          (query) => query.statusEqualTo('pending').or().statusEqualTo('in_transit'),
        )
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<TripEntity?> getTripById(String id) {
    return _dbService.trips
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<List<TripEntity>> getActiveTripsByVehicle(String vehicleNumber) {
    return _dbService.trips
        .filter()
        .vehicleNumberEqualTo(vehicleNumber)
        .and()
        .group(
          (query) => query.statusEqualTo('pending').or().statusEqualTo('in_transit'),
        )
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<TripEntity>> getTripsByDriver(String driverName) {
    return _dbService.trips
        .filter()
        .driverNameEqualTo(driverName)
        .and()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Stream<List<TripEntity>> watchAllTrips() {
    return _dbService.trips
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  Future<void> saveTrip(TripEntity trip) async {
    final id = _ensureId(trip);
    final existing = await _dbService.trips.getById(id);
    trip
      ..id = id
      ..tripId = _safeString(() => trip.tripId, fallback: 'TRIP-${DateTime.now().millisecondsSinceEpoch}')
      ..createdAt = _safeString(() => trip.createdAt, fallback: DateTime.now().toIso8601String())
      ..status = _safeString(() => trip.status, fallback: 'pending');

    await _stampForSync(trip, existing);
    await _dbService.db.writeTxn(() async {
      await _dbService.trips.put(trip);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.deliveryTrips,
      documentId: trip.id,
      operation: existing == null ? 'create' : 'update',
      payload: trip.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> updateTripStatus(String tripId, String status) async {
    final trip = await _dbService.trips.getById(tripId);
    if (trip == null || trip.isDeleted) {
      return;
    }

    trip.status = status;
    if (status == 'in_transit' && (trip.startedAt == null || trip.startedAt!.isEmpty)) {
      trip.startedAt = DateTime.now().toIso8601String();
    }

    await _stampForSync(trip, trip);
    await _dbService.db.writeTxn(() async {
      await _dbService.trips.put(trip);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.deliveryTrips,
      documentId: trip.id,
      operation: 'update',
      payload: trip.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> completeTrip(String tripId, DateTime completedAt) async {
    final trip = await _dbService.trips.getById(tripId);
    if (trip == null || trip.isDeleted) {
      return;
    }

    trip
      ..status = 'completed'
      ..completedAt = completedAt.toIso8601String();

    await _stampForSync(trip, trip);
    await _dbService.db.writeTxn(() async {
      await _dbService.trips.put(trip);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.deliveryTrips,
      documentId: trip.id,
      operation: 'update',
      payload: trip.toJson(),
    );

    await _syncIfOnline();
  }

  Future<void> _stampForSync(BaseEntity entity, BaseEntity? existing) async {
    entity
      ..updatedAt = DateTime.now()
      ..deletedAt = null
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..isDeleted = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = await _deviceIdService.getDeviceId();
  }

  String _ensureId(BaseEntity entity) {
    try {
      final current = entity.id.trim();
      if (current.isNotEmpty) {
        return current;
      }
    } catch (_) {
      // Late init fallback.
    }
    final generated = _uuid.v4();
    entity.id = generated;
    return generated;
  }

  String _safeString(String Function() reader, {String fallback = ''}) {
    try {
      final value = reader().trim();
      return value.isEmpty ? fallback : value;
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _syncIfOnline() async {
    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
