import 'package:isar/isar.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/sync/collection_registry.dart';
import '../../core/sync/sync_queue_service.dart';
import '../../core/sync/sync_service.dart';
import '../../core/utils/device_id_service.dart';
import '../local/base_entity.dart';
import '../local/entities/custom_role_entity.dart';
import '../local/entities/user_entity.dart';
import '../../services/database_service.dart';

class UserRepository {
  UserRepository(
    this._dbService, {
    SyncQueueService? syncQueueService,
    SyncService? syncService,
    ConnectivityService? connectivityService,
    DeviceIdService? deviceIdService,
  }) : _syncQueueService = syncQueueService ?? SyncQueueService.instance,
       _syncService = syncService ?? SyncService.instance,
       _connectivityService = connectivityService ?? ConnectivityService.instance,
       _deviceIdService = deviceIdService ?? DeviceIdService.instance;

  final DatabaseService _dbService;
  final SyncQueueService _syncQueueService;
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final DeviceIdService _deviceIdService;

  // Fetch all users (for Admin) - Local First
  Future<List<UserEntity>> getAllUsers() async {
    return _dbService.users
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  Stream<List<UserEntity>> watchAllUsers() {
    return _dbService.users
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .watch(fireImmediately: true);
  }

  // Create new user - Local First
  Future<void> createUser(UserEntity user) async {
    await saveUser(user, operation: 'create');
  }

  // Get specific user - Local First
  Future<UserEntity?> getUserById(String id) async {
    return _dbService.users
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<UserEntity?> getUserByEmail(String email) async {
    return _dbService.users
        .filter()
        .emailEqualTo(email, caseSensitive: false)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  // Update user - Local Commit
  Future<void> updateUser(UserEntity user) async {
    await saveUser(user, operation: 'update');
  }

  Future<void> saveUser(
    UserEntity user, {
    String? operation,
    bool triggerSync = true,
  }) async {
    if (user.id.trim().isEmpty) {
      throw ArgumentError('User id is required.');
    }

    final existing = await _dbService.users.getById(user.id);
    final now = DateTime.now();
    final deviceId = await _deviceIdService.getDeviceId();

    user
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false
      ..isSynced = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = deviceId;

    await _dbService.db.writeTxn(() async {
      await _dbService.users.put(user);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.users,
      documentId: user.id,
      operation: operation ?? (existing == null ? 'create' : 'update'),
      payload: user.toJson(),
    );

    if (triggerSync && _connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }

  // Soft Delete user
  Future<void> deleteUser(String id) async {
    final user = await _dbService.users.getById(id);
    if (user == null || user.isDeleted) {
      return;
    }

    user
      ..isDeleted = true
      ..deletedAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1;

    await _dbService.db.writeTxn(() async {
      await _dbService.users.put(user);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.users,
      documentId: user.id,
      operation: 'delete',
      payload: user.toJson(),
    );

    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }

  // Delete all users locally EXCEPT the current admin
  Future<int> deleteAllUsersExcept(String currentUserId) async {
    final allUsers = await _dbService.users.where().findAll();
    final targets = allUsers
        .where((user) => user.id != currentUserId && !user.isDeleted)
        .toList(growable: false);
    if (targets.isEmpty) {
      return 0;
    }

    final now = DateTime.now();
    await _dbService.db.writeTxn(() async {
      for (final user in targets) {
        user
          ..isDeleted = true
          ..deletedAt = now
          ..updatedAt = now
          ..syncStatus = SyncStatus.pending
          ..isSynced = false
          ..lastSynced = null
          ..version += 1;
        await _dbService.users.put(user);
      }
    });

    for (final user in targets) {
      await _syncQueueService.addToQueue(
        collectionName: CollectionRegistry.users,
        documentId: user.id,
        operation: 'delete',
        payload: user.toJson(),
      );
    }

    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }

    return targets.length;
  }

  Future<List<CustomRoleEntity>> getAllCustomRoles() async {
    return _dbService.customRoles
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  Stream<List<CustomRoleEntity>> watchAllCustomRoles() {
    return _dbService.customRoles
        .filter()
        .isDeletedEqualTo(false)
        .sortByName()
        .watch(fireImmediately: true);
  }

  Future<CustomRoleEntity?> getCustomRoleById(String id) async {
    return _dbService.customRoles
        .filter()
        .idEqualTo(id)
        .and()
        .isDeletedEqualTo(false)
        .findFirst();
  }

  Future<void> saveCustomRole(CustomRoleEntity role) async {
    if (role.id.trim().isEmpty) {
      throw ArgumentError('Custom role id is required.');
    }

    final existing = await _dbService.customRoles.getById(role.id);
    final now = DateTime.now();
    final deviceId = await _deviceIdService.getDeviceId();
    role
      ..updatedAt = now
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false
      ..isSynced = false
      ..lastSynced = null
      ..version = existing == null ? 1 : existing.version + 1
      ..deviceId = deviceId;

    await _dbService.db.writeTxn(() async {
      await _dbService.customRoles.put(role);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.customRoles,
      documentId: role.id,
      operation: existing == null ? 'create' : 'update',
      payload: role.toJson(),
    );

    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }

  Future<void> deleteCustomRole(String id) async {
    final role = await _dbService.customRoles.getById(id);
    if (role == null || role.isDeleted) {
      return;
    }

    role
      ..isDeleted = true
      ..deletedAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..syncStatus = SyncStatus.pending
      ..isSynced = false
      ..lastSynced = null
      ..version += 1;

    await _dbService.db.writeTxn(() async {
      await _dbService.customRoles.put(role);
    });

    await _syncQueueService.addToQueue(
      collectionName: CollectionRegistry.customRoles,
      documentId: role.id,
      operation: 'delete',
      payload: role.toJson(),
    );

    if (_connectivityService.isOnline) {
      await _syncService.syncAllPending();
    }
  }
}
