import 'package:isar/isar.dart';

import '../data/local/base_entity.dart';
import '../data/local/entities/user_entity.dart';
import '../data/local/entities/sync_queue_entity.dart';
import 'base_service.dart';
import 'database_service.dart';
import 'outbox_codec.dart';

const usersCollection = 'users';

class DriverService extends BaseService {
  final DatabaseService _dbService;
  static const String _collection = usersCollection;

  DriverService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance;

  Future<void> _enqueueOutbox(
    Map<String, dynamic> payload, {
    String action = 'update',
  }) async {
    final queueId = OutboxCodec.buildQueueId(
      _collection,
      payload,
      explicitRecordKey: payload['id']?.toString(),
    );
    final existing = await _dbService.syncQueue.getById(queueId);
    final now = DateTime.now();
    final existingMeta = existing == null
        ? null
        : OutboxCodec.decode(
            existing.dataJson,
            fallbackQueuedAt: existing.createdAt,
          ).meta;
    final queueEntity = SyncQueueEntity()
      ..id = queueId
      ..collection = _collection
      ..action = action
      ..dataJson = OutboxCodec.encodeEnvelope(
        payload: payload,
        existingMeta: existingMeta,
        now: now,
        resetRetryState: true,
      )
      ..createdAt = existing?.createdAt ?? now
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending;
    await _dbService.db.writeTxn(() async {
      await _dbService.syncQueue.put(queueEntity);
    });
  }

  Map<String, dynamic> _toDriverSyncPayload(UserEntity entity) {
    final payload = <String, dynamic>{
      'id': entity.id,
      'assignedVehicleId': entity.assignedVehicleId,
      'assignedVehicleName': entity.assignedVehicleName,
      'assignedVehicleNumber': entity.assignedVehicleNumber,
      'assignedDeliveryRoute': entity.assignedDeliveryRoute,
      'updatedAt': entity.updatedAt.toIso8601String(),
    };
    payload.removeWhere((_, value) => value == null);
    return payload;
  }

  Future<bool> assignVehicleToDriver({
    required String driverId,
    required String vehicleId,
    required String vehicleName,
    required String vehicleNumber,
  }) async {
    try {
      final now = DateTime.now();

      final local = await _dbService.users
          .filter()
          .idEqualTo(driverId)
          .findFirst();
      final entity = local ?? (UserEntity()..id = driverId);
      entity.assignedVehicleId = vehicleId;
      entity.assignedVehicleName = vehicleName;
      entity.assignedVehicleNumber = vehicleNumber;
      entity.updatedAt = now;
      entity.syncStatus = SyncStatus.pending;

      await _dbService.db.writeTxn(() async {
        await _dbService.users.put(entity);
      });
      await _enqueueOutbox(_toDriverSyncPayload(entity), action: 'update');
      return true;
    } catch (e) {
      handleError(e, 'assignVehicleToDriver');
      return false;
    }
  }

  Future<bool> assignRouteToDriver({
    required String driverId,
    required String routeName,
  }) async {
    try {
      final now = DateTime.now();

      final local = await _dbService.users
          .filter()
          .idEqualTo(driverId)
          .findFirst();
      final entity = local ?? (UserEntity()..id = driverId);
      entity.assignedDeliveryRoute = routeName;
      entity.updatedAt = now;
      entity.syncStatus = SyncStatus.pending;

      await _dbService.db.writeTxn(() async {
        await _dbService.users.put(entity);
      });
      await _enqueueOutbox(_toDriverSyncPayload(entity), action: 'update');
      return true;
    } catch (e) {
      handleError(e, 'assignRouteToDriver');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getDriverDetails(String driverId) async {
    try {
      final local = await _dbService.users
          .filter()
          .idEqualTo(driverId)
          .findFirst();
      if (local != null) {
        return local.toDomain().toJson();
      }

      final firestoreDb = db;
      if (firestoreDb == null) return null;

      final userRef = firestoreDb.collection(usersCollection).doc(driverId);
      final snapshot = await userRef.get();
      if (!snapshot.exists) return null;

      final data = Map<String, dynamic>.from(snapshot.data() as Map);
      data['id'] = snapshot.id;

      // Cache locally for offline use
      final entity = UserEntity()
        ..id = snapshot.id
        ..name = data['name'] as String?
        ..email = data['email'] as String?
        ..role = data['role'] as String?
        ..phone = data['phone'] as String? ?? data['mobile'] as String?
        ..status = data['status'] as String?
        ..assignedRoutes = (data['assignedRoutes'] as List?)?.cast<String>()
        ..assignedBhatti = data['assignedBhatti'] as String?
        ..assignedBaseProductId = data['assignedBaseProductId'] as String?
        ..assignedBaseProductName = data['assignedBaseProductName'] as String?
        ..assignedVehicleId = data['assignedVehicleId'] as String?
        ..assignedVehicleName = data['assignedVehicleName'] as String?
        ..assignedVehicleNumber = data['assignedVehicleNumber'] as String?
        ..assignedDeliveryRoute = data['assignedDeliveryRoute'] as String?
        ..updatedAt = DateTime.now()
        ..syncStatus = SyncStatus.synced;

      await _dbService.db.writeTxn(() async {
        await _dbService.users.put(entity);
      });

      return data;
    } catch (e) {
      handleError(e, 'getDriverDetails');
      return null;
    }
  }
}
