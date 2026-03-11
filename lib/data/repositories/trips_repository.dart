import 'package:isar/isar.dart';
import '../local/base_entity.dart';
import '../local/entities/trip_entity.dart';
import '../../services/database_service.dart';

class TripsRepository {
  final DatabaseService _dbService;

  TripsRepository(this._dbService);

  // Fetch all trips - Local First
  Future<List<TripEntity>> getAllTrips() async {
    return await _dbService.trips.where().sortByCreatedAtDesc().findAll();
  }

  // Get active trips
  Future<List<TripEntity>> getActiveTrips() async {
    return await _dbService.trips
        .filter()
        .statusEqualTo('pending')
        .or()
        .statusEqualTo('in_transit')
        .sortByCreatedAtDesc()
        .findAll();
  }

  // Get specific trip - Local First
  Future<TripEntity?> getTripById(String id) async {
    return await _dbService.trips.filter().idEqualTo(id).findFirst();
  }

  // Create or Update Trip - Local Commit
  Future<void> saveTrip(TripEntity trip) async {
    trip.updatedAt = DateTime.now();
    trip.syncStatus = SyncStatus.pending; // Mark for sync

    await _dbService.db.writeTxn(() async {
      await _dbService.trips.put(trip);
    });

    // Trigger Sync
  }
}
