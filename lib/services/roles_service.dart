import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:isar/isar.dart';
import '../core/sync/sync_queue_service.dart';
import '../core/sync/sync_service.dart';
import '../models/types/user_types.dart';
import '../data/local/base_entity.dart';
import '../data/local/entities/custom_role_entity.dart';
import 'database_service.dart';
import 'base_service.dart';

const String customRolesCollection = 'custom_roles';

class RolesService extends BaseService {
  final DatabaseService _dbService;

  RolesService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance;

  Future<String> _enqueueOutbox(
    Map<String, dynamic> payload, {
    required String action,
  }) async {
    final roleId = payload['id']?.toString().trim() ?? '';
    if (roleId.isEmpty) {
      return '';
    }
    await SyncQueueService.instance.addToQueue(
      collectionName: customRolesCollection,
      documentId: roleId,
      operation: action,
      payload: payload,
    );
    return roleId;
  }

  Future<void> _dequeueOutbox(String roleId) async {
    if (roleId.trim().isEmpty) return;
    await SyncQueueService.instance.removeFromQueue(
      collectionName: customRolesCollection,
      documentId: roleId,
    );
  }

  Future<void> _setLocalRoleSyncStatus(
    String id,
    SyncStatus status, {
    bool? isDeleted,
  }) async {
    final cached = await _dbService.customRoles
        .filter()
        .idEqualTo(id)
        .findFirst();
    if (cached == null) return;
    cached.syncStatus = status;
    cached.updatedAt = DateTime.now();
    if (isDeleted != null) {
      cached.isDeleted = isDeleted;
    }
    await _dbService.db.writeTxn(() async {
      await _dbService.customRoles.put(cached);
    });
  }

  Future<void> _performImmediateWrite(
    String action,
    Map<String, dynamic> payload,
  ) async {
    if (db == null) {
      throw Exception('Offline');
    }
    await SyncService.instance.trySync();
  }

  Future<void> _upsertLocalRoleEntity(
    String id,
    Map<String, dynamic> data, {
    required SyncStatus syncStatus,
    bool? isDeleted,
  }) async {
    final existing = await _dbService.customRoles
        .filter()
        .idEqualTo(id)
        .findFirst();
    final now = DateTime.now();
    final updatedAt =
        DateTime.tryParse(data['updatedAt']?.toString() ?? '') ?? now;
    final createdAt =
        DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
        existing?.createdAt ??
        now;

    final entity = existing ?? CustomRoleEntity();
    entity.id = id;
    entity.name = data['name']?.toString() ?? existing?.name ?? '';
    entity.description = data.containsKey('description')
        ? data['description']?.toString()
        : existing?.description;

    if (data.containsKey('permissions')) {
      final perms = data['permissions'];
      entity.permissionsJson = perms is List
          ? jsonEncode(perms)
          : existing?.permissionsJson ?? jsonEncode([]);
    } else {
      entity.permissionsJson = existing?.permissionsJson ?? jsonEncode([]);
    }

    entity.isActive = data['isActive'] as bool? ?? existing?.isActive ?? true;
    entity.createdAt = createdAt;
    entity.createdBy = data.containsKey('createdBy')
        ? data['createdBy']?.toString()
        : existing?.createdBy;
    entity.updatedAt = updatedAt;
    entity.syncStatus = syncStatus;
    entity.isDeleted = isDeleted ?? (data['isDeleted'] == true);

    await _dbService.db.writeTxn(() async {
      await _dbService.customRoles.put(entity);
    });
  }

  Future<void> _queueRoleWrite({
    required String action,
    required String roleId,
    required Map<String, dynamic> payload,
    bool? deletedOnSuccess,
  }) async {
    final normalizedPayload = Map<String, dynamic>.from(payload);
    final queueId = await _enqueueOutbox(normalizedPayload, action: action);

    final firestore = db;
    if (firestore == null) return;

    try {
      await _performImmediateWrite(action, normalizedPayload);
      final hasPending = await SyncQueueService.instance.hasPendingItem(
        collectionName: customRolesCollection,
        documentId: roleId,
      );
      if (hasPending) {
        return;
      }
      await _dequeueOutbox(queueId);
      await _setLocalRoleSyncStatus(
        roleId,
        SyncStatus.synced,
        isDeleted: deletedOnSuccess,
      );
    } catch (_) {
      // Keep queued outbox entry for sync coordinator retry.
    }
  }

  List<Permission> _decodePermissions(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Permission.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error decoding custom role permissions: $e');
    }
    return [];
  }

  CustomRole _entityToDomain(CustomRoleEntity entity) {
    return CustomRole(
      id: entity.id,
      name: entity.name,
      description: entity.description ?? '',
      permissions: _decodePermissions(entity.permissionsJson),
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
      createdBy: entity.createdBy ?? '',
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  CustomRoleEntity _entityFromMap(Map<String, dynamic> data) {
    final createdAtRaw = data['createdAt'] as String?;
    final updatedAtRaw = data['updatedAt'] as String?;
    final createdAt = DateTime.tryParse(createdAtRaw ?? '') ?? DateTime.now();
    final updatedAt =
        DateTime.tryParse(updatedAtRaw ?? createdAtRaw ?? '') ?? DateTime.now();

    final permissions = data['permissions'];
    final permissionsJson = permissions is List
        ? jsonEncode(permissions)
        : jsonEncode([]);

    return CustomRoleEntity()
      ..id = data['id'] as String
      ..name = data['name'] as String? ?? ''
      ..description = data['description'] as String?
      ..permissionsJson = permissionsJson
      ..isActive = data['isActive'] as bool? ?? true
      ..createdAt = createdAt
      ..createdBy = data['createdBy'] as String?
      ..updatedAt = updatedAt
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
  }

  /// Fetch all custom roles ordered by creation time
  Future<List<CustomRole>> getRoles() async {
    try {
      final cached = await _dbService.customRoles
          .filter()
          .isDeletedEqualTo(false)
          .findAll();
      if (cached.isNotEmpty) {
        cached.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return cached.map(_entityToDomain).toList();
      }

      final firestore = db;
      if (firestore == null) return [];

      final snapshot = await firestore
          .collection(customRolesCollection)
          .orderBy('createdAt', descending: true)
          .get();

      final entities = <CustomRoleEntity>[];
      final roles = <CustomRole>[];
      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        data['id'] = doc.id; // Ensure ID is part of the map
        final entity = _entityFromMap(data);
        entities.add(entity);
        roles.add(_entityToDomain(entity));
      }

      if (entities.isNotEmpty) {
        await _dbService.db.writeTxn(() async {
          await _dbService.customRoles.putAll(entities);
        });
      }

      return roles;
    } catch (e) {
      throw handleError(e, 'getRoles');
    }
  }

  /// Get a single role by ID
  Future<CustomRole?> getRole(String id) async {
    try {
      final cached = await _dbService.customRoles
          .filter()
          .idEqualTo(id)
          .findFirst();
      if (cached != null && !cached.isDeleted) {
        return _entityToDomain(cached);
      }

      final firestore = db;
      if (firestore == null) return null;

      final docSnap = await firestore
          .collection(customRolesCollection)
          .doc(id)
          .get();
      if (docSnap.exists) {
        final data = Map<String, dynamic>.from(docSnap.data() as Map);
        data['id'] = docSnap.id;
        final entity = _entityFromMap(data);
        await _dbService.db.writeTxn(() async {
          await _dbService.customRoles.put(entity);
        });
        return _entityToDomain(entity);
      }
      return null;
    } catch (e) {
      throw handleError(e, 'getRole');
    }
  }

  /// Create a new custom role
  Future<String> createRole(CustomRole role) async {
    try {
      final roleId = role.id.trim().isNotEmpty
          ? role.id
          : 'role_${DateTime.now().microsecondsSinceEpoch}';
      final now = DateTime.now().toIso8601String();

      final roleData = role.toJson();
      roleData['id'] = roleId;
      roleData['createdAt'] = now;
      roleData['updatedAt'] = now;
      roleData['isDeleted'] = false;

      await _upsertLocalRoleEntity(
        roleId,
        roleData,
        syncStatus: SyncStatus.pending,
        isDeleted: false,
      );
      await _queueRoleWrite(
        action: 'set',
        roleId: roleId,
        payload: roleData,
        deletedOnSuccess: false,
      );
      return roleId;
    } catch (e) {
      throw handleError(e, 'createRole');
    }
  }

  /// Update an existing custom role
  Future<void> updateRole(String id, Map<String, dynamic> updates) async {
    try {
      final payload = <String, dynamic>{
        ...updates,
        'id': id,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _upsertLocalRoleEntity(
        id,
        payload,
        syncStatus: SyncStatus.pending,
        isDeleted: false,
      );
      await _queueRoleWrite(
        action: 'update',
        roleId: id,
        payload: payload,
        deletedOnSuccess: false,
      );
    } catch (e) {
      throw handleError(e, 'updateRole');
    }
  }

  /// Delete a custom role
  Future<void> deleteRole(String id) async {
    try {
      final payload = <String, dynamic>{
        'id': id,
        'isDeleted': true,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _upsertLocalRoleEntity(
        id,
        payload,
        syncStatus: SyncStatus.pending,
        isDeleted: true,
      );
      await _queueRoleWrite(
        action: 'delete',
        roleId: id,
        payload: payload,
        deletedOnSuccess: true,
      );
    } catch (e) {
      throw handleError(e, 'deleteRole');
    }
  }
}
