import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:isar/isar.dart';

import 'offline_first_service.dart';
import '../core/firebase/firebase_config.dart';
import '../models/types/user_types.dart';
import '../data/local/entities/user_entity.dart';
import '../data/local/base_entity.dart';
import '../utils/app_logger.dart';

const usersCollection = 'users';
const customRolesCollection = 'custom_roles';

class UsersService extends OfflineFirstService {
  UsersService(super.firebase, [super.dbService]);
  Future<void> Function()? _centralUsersSync;

  void bindCentralUsersSync(Future<void> Function() callback) {
    _centralUsersSync = callback;
  }

  @override
  String get localStorageKey => 'local_users';

  @override
  bool get useIsar => true;

  String _normalizeRoleString(String? value) {
    if (value == null) return '';
    return value
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .trim()
        .toLowerCase();
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  String _normalizeAccountStatus(
    dynamic rawStatus, {
    required bool fallbackIsActive,
  }) {
    final token = rawStatus?.toString().trim().toLowerCase() ?? '';
    if (token.isEmpty) return fallbackIsActive ? 'active' : 'inactive';
    if (token == 'active' || token == 'enabled' || token == 'approved') {
      return 'active';
    }
    if (token == 'inactive' ||
        token == 'disabled' ||
        token == 'blocked' ||
        token == 'suspended') {
      return 'inactive';
    }
    return token;
  }

  bool _resolveIsActive(dynamic rawIsActive, dynamic rawStatus) {
    if (rawIsActive is bool) return rawIsActive;
    final normalized = _normalizeAccountStatus(
      rawStatus,
      fallbackIsActive: true,
    );
    return normalized == 'active';
  }

  bool get _hideDiagnosticUsersInThisBuild => kReleaseMode || kProfileMode;

  String _normalizedUserToken(String? value) {
    return value?.trim().toLowerCase() ?? '';
  }

  bool _isDiagnosticUserIdentifier(String? value) {
    final token = _normalizedUserToken(value);
    if (token.isEmpty) return false;

    return token.startsWith('qa.') ||
        token.startsWith('qa_') ||
        token.startsWith('qa.role.') ||
        token.startsWith('live.scenario.') ||
        token.endsWith('@erp.local');
  }

  bool _isDiagnosticUserName(String? value) {
    final name = _normalizedUserToken(value);
    return name.startsWith('qa ') || name.startsWith('live scenario');
  }

  bool _isDiagnosticUserMap(Map<String, dynamic> data) {
    return _isDiagnosticUserIdentifier(data['id']?.toString()) ||
        _isDiagnosticUserIdentifier(data['email']?.toString()) ||
        _isDiagnosticUserName(data['name']?.toString());
  }

  bool _isDiagnosticUserEntity(UserEntity entity) {
    return _isDiagnosticUserIdentifier(entity.id) ||
        _isDiagnosticUserIdentifier(entity.email) ||
        _isDiagnosticUserName(entity.name);
  }

  bool _isDiagnosticAppUser(AppUser user) {
    return _isDiagnosticUserIdentifier(user.id) ||
        _isDiagnosticUserIdentifier(user.email) ||
        _isDiagnosticUserName(user.name);
  }

  Future<void> _cleanupLocalDiagnosticUsers() async {
    if (!_hideDiagnosticUsersInThisBuild) return;

    final localUsers = await dbService.users.where().findAll();
    final toHide = localUsers
        .where((u) => !u.isDeleted && _isDiagnosticUserEntity(u))
        .toList();
    if (toHide.isEmpty) return;

    final now = DateTime.now();
    await dbService.db.writeTxn(() async {
      for (final user in toHide) {
        user
          ..isDeleted = true
          ..deletedAt = now
          ..updatedAt = now
          ..syncStatus = SyncStatus.synced;
        await dbService.users.put(user);
      }
    });

    AppLogger.warning(
      'Release cleanup: hidden ${toHide.length} diagnostic QA/test user(s) from local cache.',
      tag: 'Users',
    );
  }

  bool _matchesRole(UserEntity entity, AppUser user, UserRole requestedRole) {
    if (user.role == requestedRole) return true;

    final normalizedRaw = _normalizeRoleString(entity.role);
    final normalizedRequested = _normalizeRoleString(requestedRole.value);
    final normalizedRequestedName = _normalizeRoleString(requestedRole.name);

    if (normalizedRaw == normalizedRequested ||
        normalizedRaw == normalizedRequestedName) {
      return true;
    }

    // Driver fallback for legacy/dirty role values
    if (requestedRole == UserRole.driver) {
      if (normalizedRaw.contains('driver')) return true;
      if (_hasText(user.assignedVehicleId) ||
          _hasText(user.assignedVehicleNumber) ||
          _hasText(user.assignedVehicleName)) {
        return true;
      }
      final dept = (user.department ?? '').toLowerCase();
      if (dept.contains('vehicle') || dept.contains('fuel')) return true;
    }

    return false;
  }

  UserEntity _mapFirebaseUserToEntity(Map<String, dynamic> item) {
    final isActive = _resolveIsActive(item['isActive'], item['status']);
    final normalizedStatus = _normalizeAccountStatus(
      item['status'],
      fallbackIsActive: isActive,
    );
    final rawStatus = item['status']?.toString().trim() ?? '';
    final shouldRepairRemote = rawStatus.isEmpty || item['isActive'] == null;

    return UserEntity()
      ..id = item['id'] as String
      ..name = item['name'] as String?
      ..email = item['email'] as String?
      ..role = item['role'] as String?
      ..phone = item['phone'] as String?
      ..status = normalizedStatus
      ..isActive = isActive
      ..assignedRoutes = (item['assignedRoutes'] as List?)?.cast<String>()
      ..allocatedStockJson = item['allocatedStock'] != null
          ? jsonEncode(item['allocatedStock'])
          : null
      ..assignedBhatti = item['assignedBhatti'] as String?
      ..assignedBaseProductId = item['assignedBaseProductId'] as String?
      ..assignedBaseProductName = item['assignedBaseProductName'] as String?
      ..assignedVehicleId = item['assignedVehicleId'] as String?
      ..assignedVehicleName = item['assignedVehicleName'] as String?
      ..assignedVehicleNumber = item['assignedVehicleNumber'] as String?
      ..assignedDeliveryRoute = item['assignedDeliveryRoute'] as String?
      ..assignedSalesRoute = item['assignedSalesRoute'] as String?
      ..department = item['department'] as String?
      ..updatedAt = DateTime.now()
      ..syncStatus = shouldRepairRemote
          ? SyncStatus.pending
          : SyncStatus.synced;
  }

  Future<void> _upsertUsersToIsar(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return;
    await dbService.db.writeTxn(() async {
      for (final item in items) {
        if (_hideDiagnosticUsersInThisBuild && _isDiagnosticUserMap(item)) {
          continue;
        }
        final id = item['id']?.toString();
        if (id == null || id.isEmpty) continue;
        final existing = await dbService.users.getById(id);
        final entity = _mapFirebaseUserToEntity(item);
        if (existing != null && item['allocatedStock'] == null) {
          entity.allocatedStockJson = existing.allocatedStockJson;
        }
        if (existing != null && item['assignedSalesRoute'] == null) {
          entity.assignedSalesRoute = existing.assignedSalesRoute;
        }
        await dbService.users.put(entity);
      }
    });
  }

  List<Map<String, dynamic>> _filterUserDocsByRole(
    List<Map<String, dynamic>> docs,
    UserRole role,
  ) {
    if (docs.isEmpty) return const [];

    final targetA = _normalizeRoleString(role.value);
    final targetB = _normalizeRoleString(role.name);

    return docs.where((doc) {
      if (_hideDiagnosticUsersInThisBuild && _isDiagnosticUserMap(doc)) {
        return false;
      }

      final rawRole = _normalizeRoleString(doc['role']?.toString());
      if (rawRole == targetA || rawRole == targetB) return true;

      if (role == UserRole.driver) {
        if (rawRole.contains('driver')) return true;
        final assignedVehicleId = doc['assignedVehicleId']?.toString();
        final assignedVehicleName = doc['assignedVehicleName']?.toString();
        final assignedVehicleNumber = doc['assignedVehicleNumber']?.toString();
        if (_hasText(assignedVehicleId) ||
            _hasText(assignedVehicleName) ||
            _hasText(assignedVehicleNumber)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchRemoteUsersByRole(
    UserRole role,
  ) async {
    final firestore = db;
    if (firestore == null) return const [];

    try {
      // First try a targeted whereIn query for common role variants.
      final roleVariants = <String>{
        role.value,
        role.value.toLowerCase(),
        role.value.toUpperCase(),
        role.name,
        role.name.toLowerCase(),
        role.name.toUpperCase(),
      }.toList();

      final snap = await firestore
          .collection(usersCollection)
          .where('role', whereIn: roleVariants)
          .get()
          .timeout(const Duration(seconds: 3));

      var docs = snap.docs
          .map((d) => <String, dynamic>{...d.data(), 'id': d.id})
          .toList();

      // Fallback: full scan + robust filtering for legacy role text.
      if (docs.isEmpty) {
        final full = await firestore
            .collection(usersCollection)
            .get()
            .timeout(const Duration(seconds: 3));
        docs = full.docs
            .map((d) => <String, dynamic>{...d.data(), 'id': d.id})
            .toList();
      }

      return _filterUserDocsByRole(docs, role);
    } catch (_) {
      return const [];
    }
  }

  // Get users with filters (offline-first via Isar)
  Future<List<AppUser>> getUsers({UserRole? role, int? limitCount}) async {
    try {
      await _cleanupLocalDiagnosticUsers();

      // 1. ALWAYS read from ISAR first
      var entities = await dbService.users
          .filter()
          .isDeletedEqualTo(false)
          .findAll();

      // 2. If local is empty, try to bootstrap from Firebase ONCE
      if (entities.isEmpty) {
        final items = await bootstrapFromFirebase(
          collectionName: usersCollection,
        );
        if (items.isNotEmpty) {
          await _upsertUsersToIsar(items);
          // Refresh entities
          entities = await dbService.users
              .filter()
              .isDeletedEqualTo(false)
              .findAll();
        }
      }

      // 3. Convert to Domain objects, apply robust role filtering, and deduplicate by ID
      final userMap = <String, AppUser>{};
      for (final entity in entities) {
        final user = entity.toDomain();
        if (_hideDiagnosticUsersInThisBuild && _isDiagnosticAppUser(user)) {
          continue;
        }
        if (role != null && !_matchesRole(entity, user, role)) continue;
        userMap[user.id] = user; // This ensures only one user per ID
      }

      // 3.1 Fallback refill for role-based queries when local is stale/incomplete.
      if (role != null && userMap.isEmpty) {
        // Try one fresh sync cycle first.
        await syncUsers();
        entities = await dbService.users
            .filter()
            .isDeletedEqualTo(false)
            .findAll();
        for (final entity in entities) {
          final user = entity.toDomain();
          if (_hideDiagnosticUsersInThisBuild && _isDiagnosticAppUser(user)) {
            continue;
          }
          if (!_matchesRole(entity, user, role)) continue;
          userMap[user.id] = user;
        }
      }

      if (role != null && userMap.isEmpty) {
        final remoteRoleItems = await _fetchRemoteUsersByRole(role);
        if (remoteRoleItems.isNotEmpty) {
          await _upsertUsersToIsar(remoteRoleItems);
          entities = await dbService.users
              .filter()
              .isDeletedEqualTo(false)
              .findAll();
          for (final entity in entities) {
            final user = entity.toDomain();
            if (_hideDiagnosticUsersInThisBuild && _isDiagnosticAppUser(user)) {
              continue;
            }
            if (!_matchesRole(entity, user, role)) continue;
            userMap[user.id] = user;
          }
        }
      }

      if (role != null && userMap.isEmpty) {
        // Last fallback: include soft-deleted/local-mismatched rows if they still
        // look active, because some legacy migrations incorrectly marked users.
        final allEntities = await dbService.users.where().findAll();
        for (final entity in allEntities) {
          final user = entity.toDomain();
          if (_hideDiagnosticUsersInThisBuild && _isDiagnosticAppUser(user)) {
            continue;
          }
          if (!_matchesRole(entity, user, role)) continue;

          final status = (entity.status ?? user.status ?? '')
              .toString()
              .toLowerCase();
          final looksActive =
              entity.isActive &&
              (status.isEmpty ||
                  status == 'active' ||
                  status == 'enabled' ||
                  status == 'approved');
          if (!looksActive) continue;

          userMap[user.id] = user;
        }
      }

      // 4. Apply limit
      var users = userMap.values.toList();
      if (limitCount != null && users.length > limitCount) {
        users = users.take(limitCount).toList();
      }
      return users;
    } catch (e) {
      throw handleError(e, 'getUsers');
    }
  }

  // Sync users from Firestore to Local DB (Handle Deletions)
  Future<void> syncUsers() async {
    if (_centralUsersSync != null) {
      await _centralUsersSync!.call();
      return;
    }
    await _syncUsersLegacy();
  }

  Future<void> _syncUsersLegacy() async {
    try {
      await _cleanupLocalDiagnosticUsers();

      // 1. Fetch all from Firestore
      var items = await bootstrapFromFirebase(collectionName: usersCollection);
      if (_hideDiagnosticUsersInThisBuild) {
        items = items.where((item) => !_isDiagnosticUserMap(item)).toList();
      }

      // 2. Fetch all from Local
      final localEntities = await dbService.users.where().findAll();
      // final localIds = localEntities.map((e) => e.id).toSet(); // Unused
      final remoteIds = items.map((e) => e['id'] as String).toSet();

      await dbService.db.writeTxn(() async {
        // 3. Update/Insert Remote Items
        for (final item in items) {
          final id = item['id']?.toString();
          if (id == null || id.isEmpty) continue;
          final existing = localEntities.firstWhere(
            (e) => e.id == id,
            orElse: () => UserEntity()..id = id,
          );
          final hasExisting = existing.name != null || existing.email != null;
          final entity = _mapFirebaseUserToEntity(item);
          if (hasExisting && item['allocatedStock'] == null) {
            entity.allocatedStockJson = existing.allocatedStockJson;
          }
          if (hasExisting && item['assignedSalesRoute'] == null) {
            entity.assignedSalesRoute = existing.assignedSalesRoute;
          }
          await dbService.users.put(entity);
        }

        // 4. Delete Ghosts (Local IDs not in Remote IDs)
        // Only delete if they are marked as SYNCED (don't delete pending local creates if any)
        for (final entity in localEntities) {
          if (!remoteIds.contains(entity.id) &&
              entity.syncStatus == SyncStatus.synced) {
            entity
              ..isDeleted = true
              ..deletedAt = DateTime.now()
              ..updatedAt = DateTime.now()
              ..syncStatus = SyncStatus.synced;
            await dbService.users.put(entity);
          }
        }
      });
    } catch (e) {
      throw handleError(e, 'syncUsers');
    }
  }

  Future<bool> ensureAccountantBootstrapUser({
    String email = 'accountant@dattsoap.local',
    String name = 'Default Accountant',
    String? bootstrapByUserId,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final firestore = db;
      if (firestore == null) {
        AppLogger.warning(
          'Skipping accountant bootstrap: Firestore unavailable',
          tag: 'Users',
        );
        return false;
      }

      final localAccountants = await getUsers(
        role: UserRole.accountant,
        limitCount: 1,
      );
      if (localAccountants.isNotEmpty) {
        return false;
      }

      final byDoc = await firestore
          .collection(usersCollection)
          .doc(normalizedEmail)
          .get()
          .timeout(const Duration(seconds: 3));
      if (byDoc.exists) {
        await _upsertUsersToIsar([
          {...?byDoc.data(), 'id': byDoc.id},
        ]);
        return false;
      }

      final existingRemoteAccountants = await _fetchRemoteUsersByRole(
        UserRole.accountant,
      );
      if (existingRemoteAccountants.isNotEmpty) {
        await _upsertUsersToIsar(existingRemoteAccountants);
        return false;
      }

      final now = DateTime.now().toIso8601String();
      final payload = <String, dynamic>{
        'id': normalizedEmail,
        'email': normalizedEmail,
        'name': name,
        'role': UserRole.accountant.value,
        'status': 'active',
        'isActive': true,
        'department': 'accounts',
        'createdAt': now,
        'updatedAt': now,
        'createdBy': bootstrapByUserId ?? 'system',
      };

      await firestore
          .collection(usersCollection)
          .doc(normalizedEmail)
          .set(payload);
      await _upsertUsersToIsar([payload]);
      await createAuditLog(
        collectionName: usersCollection,
        docId: normalizedEmail,
        action: 'bootstrap_accountant',
        changes: payload,
        userId: bootstrapByUserId ?? 'system',
        userName: 'System',
      );
      AppLogger.success(
        'Accountant bootstrap user ensured: $normalizedEmail',
        tag: 'Users',
      );
      return true;
    } catch (e) {
      handleError(e, 'ensureAccountantBootstrapUser');
      return false;
    }
  }

  // Create new user (Initial Firestore record)
  Future<bool> createUser(Map<String, dynamic> userData) async {
    try {
      final firestore = db;
      if (firestore == null) return false;

      final normalizedEmail = (userData['email'] as String)
          .trim()
          .toLowerCase();
      final docRef = firestore.collection(usersCollection).doc(normalizedEmail);
      final now = DateTime.now().toIso8601String();

      final data = Map<String, dynamic>.from(userData);
      data['id'] = normalizedEmail;
      if (!data.containsKey('createdAt')) data['createdAt'] = now;
      if (!data.containsKey('updatedAt')) data['updatedAt'] = now;
      final isActive = _resolveIsActive(data['isActive'], data['status']);
      data['status'] = _normalizeAccountStatus(
        data['status'],
        fallbackIsActive: isActive,
      );
      data['isActive'] = isActive;

      await docRef.set(data);

      // 1.5 Update Local ISAR
      final entity = UserEntity()
        ..id = normalizedEmail
        ..name = data['name']
        ..email = data['email']
        ..role = data['role']
        ..status = data['status']
        ..isActive = data['isActive'] as bool? ?? true
        ..syncStatus = SyncStatus.synced; // Already pushed to Firestore

      await dbService.db.writeTxn(() async {
        await dbService.users.put(entity);
      });

      final currentUser = FirebaseAuth.instance.currentUser;
      await createAuditLog(
        collectionName: usersCollection,
        docId: docRef.id,
        action: 'create',
        changes: {
          'all': {'oldValue': null, 'newValue': data},
        },
        userId: currentUser?.uid ?? 'system',
        userName: currentUser?.displayName ?? 'System',
      );

      return true;
    } catch (e) {
      throw handleError(e, 'createUser');
    }
  }

  // Update user (same complex logic as React updateUserClient with role-based cleanup)
  Future<bool> updateUser(
    String userId,
    Map<String, dynamic> updates,
    String currentUserId,
  ) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Authentication Error');
      }

      final firestore = db;
      if (firestore == null) return false;

      final userRef = firestore.collection(usersCollection).doc(userId);
      final userDoc = await userRef.get().timeout(const Duration(seconds: 3));

      if (!userDoc.exists) {
        throw Exception('User to be updated not found.');
      }

      final originalUserData = Map<String, dynamic>.from(userDoc.data() as Map);
      final dataToUpdate = <String, dynamic>{};
      final changes = <String, Map<String, dynamic>>{};

      // Compare and stage only changed fields (same as React lines 130-209)
      if (updates.containsKey('name') &&
          updates['name'] != originalUserData['name']) {
        dataToUpdate['name'] = updates['name'];
        changes['name'] = {
          'oldValue': originalUserData['name'],
          'newValue': updates['name'],
        };
      }

      if (updates.containsKey('department') &&
          updates['department'] != originalUserData['department']) {
        dataToUpdate['department'] = updates['department'];
        changes['department'] = {
          'oldValue': originalUserData['department'],
          'newValue': updates['department'],
        };
      }

      if (updates.containsKey('status') &&
          updates['status'] != originalUserData['status']) {
        final currentIsActive = _resolveIsActive(
          originalUserData['isActive'],
          originalUserData['status'],
        );
        final normalizedStatus = _normalizeAccountStatus(
          updates['status'],
          fallbackIsActive: currentIsActive,
        );
        dataToUpdate['status'] = normalizedStatus;
        dataToUpdate['isActive'] = normalizedStatus == 'active';
        changes['status'] = {
          'oldValue': originalUserData['status'],
          'newValue': normalizedStatus,
        };
      }

      // Handle assignedRoutes (same as React lines 139-152)
      if (updates.containsKey('assignedRoutes')) {
        final newRoutes = (updates['assignedRoutes'] as List? ?? [])
            .cast<String>();
        final oldRoutes = (originalUserData['assignedRoutes'] as List? ?? [])
            .cast<String>();

        final newRoutesSorted = List<String>.from(newRoutes)..sort();
        final oldRoutesSorted = List<String>.from(oldRoutes)..sort();

        if (newRoutesSorted.toString() != oldRoutesSorted.toString()) {
          dataToUpdate['assignedRoutes'] = newRoutes;
          changes['assignedRoutes'] = {
            'oldValue': oldRoutes,
            'newValue': newRoutes,
          };
        }
      }

      // Handle departments update (same as React lines 155-168)
      if (updates.containsKey('departments')) {
        final newDepts = (updates['departments'] as List? ?? []);
        final oldDepts = (originalUserData['departments'] as List? ?? []);

        // Compare (order-independent)
        if (newDepts.toString() != oldDepts.toString()) {
          dataToUpdate['departments'] = newDepts;
          changes['departments'] = {'oldValue': oldDepts, 'newValue': newDepts};
        }
      }

      // Handle assignedBhatti (same as React lines 170-173)
      if (updates.containsKey('assignedBhatti') &&
          updates['assignedBhatti'] != originalUserData['assignedBhatti']) {
        dataToUpdate['assignedBhatti'] = updates['assignedBhatti'];
        changes['assignedBhatti'] = {
          'oldValue': originalUserData['assignedBhatti'],
          'newValue': updates['assignedBhatti'],
        };
      }

      // Handle assignedBaseProductId (same as React lines 175-179)
      if (updates.containsKey('assignedBaseProductId') &&
          updates['assignedBaseProductId'] !=
              originalUserData['assignedBaseProductId']) {
        dataToUpdate['assignedBaseProductId'] =
            updates['assignedBaseProductId'];
        dataToUpdate['assignedBaseProductName'] =
            updates['assignedBaseProductName'];
        changes['assignedBaseProductId'] = {
          'oldValue': originalUserData['assignedBaseProductId'],
          'newValue': updates['assignedBaseProductId'],
        };
      }

      // Handle customRoleId (same as React lines 182-185)
      if (updates.containsKey('customRoleId') &&
          updates['customRoleId'] != originalUserData['customRoleId']) {
        dataToUpdate['customRoleId'] = updates['customRoleId'];
        changes['customRoleId'] = {
          'oldValue': originalUserData['customRoleId'],
          'newValue': updates['customRoleId'],
        };
      }

      // Vehicle & Route Assignment (same as React lines 188-198)
      if (updates.containsKey('assignedVehicleId') &&
          updates['assignedVehicleId'] !=
              originalUserData['assignedVehicleId']) {
        dataToUpdate['assignedVehicleId'] = updates['assignedVehicleId'];
        dataToUpdate['assignedVehicleName'] = updates['assignedVehicleName'];
        dataToUpdate['assignedVehicleNumber'] =
            updates['assignedVehicleNumber'];
        changes['assignedVehicleId'] = {
          'oldValue': originalUserData['assignedVehicleId'],
          'newValue': updates['assignedVehicleId'],
        };
      }

      if (updates.containsKey('assignedDeliveryRoute') &&
          updates['assignedDeliveryRoute'] !=
              originalUserData['assignedDeliveryRoute']) {
        dataToUpdate['assignedDeliveryRoute'] =
            updates['assignedDeliveryRoute'];
        changes['assignedDeliveryRoute'] = {
          'oldValue': originalUserData['assignedDeliveryRoute'],
          'newValue': updates['assignedDeliveryRoute'],
        };
      }

      // Phone numbers (same as React lines 200-208)
      if (updates.containsKey('phone') &&
          updates['phone'] != originalUserData['phone']) {
        dataToUpdate['phone'] = updates['phone'];
        changes['phone'] = {
          'oldValue': originalUserData['phone'],
          'newValue': updates['phone'],
        };
      }

      if (updates.containsKey('secondaryPhone') &&
          updates['secondaryPhone'] != originalUserData['secondaryPhone']) {
        dataToUpdate['secondaryPhone'] = updates['secondaryPhone'];
        changes['secondaryPhone'] = {
          'oldValue': originalUserData['secondaryPhone'],
          'newValue': updates['secondaryPhone'],
        };
      }

      // Role-based cleanup logic (same as React lines 211-245)
      // If role changes FROM Driver TO something else, clear vehicle assignment
      if (updates.containsKey('role') &&
          updates['role'] != 'Driver' &&
          originalUserData['role'] == 'Driver') {
        if (originalUserData['assignedVehicleId'] != null) {
          dataToUpdate['assignedVehicleId'] = null;
          dataToUpdate['assignedVehicleName'] = null;
          dataToUpdate['assignedVehicleNumber'] = null;
          changes['assignedVehicleId'] = {
            'oldValue': originalUserData['assignedVehicleId'],
            'newValue': null,
          };
        }
        if (originalUserData['assignedDeliveryRoute'] != null) {
          dataToUpdate['assignedDeliveryRoute'] = null;
          changes['assignedDeliveryRoute'] = {
            'oldValue': originalUserData['assignedDeliveryRoute'],
            'newValue': null,
          };
        }
      }

      // If role changes FROM Salesman TO something else, clear routes
      if (updates.containsKey('role') &&
          updates['role'] != 'Salesman' &&
          originalUserData['role'] == 'Salesman') {
        final oldRoutes = originalUserData['assignedRoutes'] as List?;
        if (oldRoutes != null && oldRoutes.isNotEmpty) {
          dataToUpdate['assignedRoutes'] = [];
          changes['assignedRoutes'] = {'oldValue': oldRoutes, 'newValue': []};
        }
      }

      // If role changes TO Salesman, ensure assignedRoutes exists
      if (updates.containsKey('role') &&
          updates['role'] == 'Salesman' &&
          originalUserData['role'] != 'Salesman') {
        if (!dataToUpdate.containsKey('assignedRoutes') &&
            originalUserData['assignedRoutes'] == null) {
          dataToUpdate['assignedRoutes'] = [];
        }
      }

      // If role changes from Bhatti Supervisor, remove bhatti assignment
      if (updates.containsKey('role') &&
          updates['role'] != 'Bhatti Supervisor' &&
          originalUserData['assignedBhatti'] != null) {
        dataToUpdate['assignedBhatti'] = null;
        dataToUpdate['assignedBaseProductId'] = null;
        dataToUpdate['assignedBaseProductName'] = null;
        changes['assignedBhatti'] = {
          'oldValue': originalUserData['assignedBhatti'],
          'newValue': null,
        };
      }

      // Update role directly in Firestore (same as React lines 249-264)
      if (updates.containsKey('role') &&
          updates['role'] != originalUserData['role']) {
        dataToUpdate['role'] = updates['role'];
        changes['role'] = {
          'oldValue': originalUserData['role'],
          'newValue': updates['role'],
        };

        // Note: Cloud Function call for custom claims skipped in Flutter
        // This would need to be handled differently (e.g., via backend API)
      }

      // Apply updates if there are changes (same as React lines 267-287)
      if (dataToUpdate.isNotEmpty) {
        await userRef.update(dataToUpdate);

        // SYNC WITH ISAR
        final entity = await dbService.users
            .filter()
            .idEqualTo(userId)
            .findFirst();
        if (entity != null) {
          if (dataToUpdate.containsKey('name')) {
            entity.name = dataToUpdate['name'];
          }
          if (dataToUpdate.containsKey('role')) {
            entity.role = dataToUpdate['role'];
          }
          if (dataToUpdate.containsKey('department')) {
            entity.department = dataToUpdate['department'] as String?;
          }
          if (dataToUpdate.containsKey('departments')) {
            final depts = dataToUpdate['departments'] as List? ?? [];
            entity.departmentsJson = jsonEncode(depts);
          }
          if (dataToUpdate.containsKey('status')) {
            entity.status = dataToUpdate['status'];
          }
          if (dataToUpdate.containsKey('isActive')) {
            entity.isActive = dataToUpdate['isActive'] as bool;
          }
          if (dataToUpdate.containsKey('assignedRoutes')) {
            entity.assignedRoutes = (dataToUpdate['assignedRoutes'] as List)
                .cast<String>();
          }
          if (dataToUpdate.containsKey('assignedBhatti')) {
            entity.assignedBhatti = dataToUpdate['assignedBhatti'] as String?;
          }
          entity.updatedAt = DateTime.now();
          entity.syncStatus = SyncStatus.synced;
          await dbService.db.writeTxn(() async {
            await dbService.users.put(entity);
          });
        }

        if (changes.isNotEmpty) {
          await createAuditLog(
            collectionName: usersCollection,
            docId: userId,
            action: 'update',
            changes: changes,
            userId: currentUserId,
            userName: currentUser.displayName,
          );
        }

        return true;
      }

      return true; // No changes detected
    } catch (e) {
      throw handleError(e, 'updateUser');
    }
  }

  // Bulk update user status (same logic as React bulkUpdateUserStatusClient)
  Future<bool> bulkUpdateUserStatus(List<String> userIds, String status) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Authentication Error');
      }

      final firestore = db;
      if (firestore == null) return false;

      final normalizedStatus = _normalizeAccountStatus(
        status,
        fallbackIsActive: status.toString().trim().toLowerCase() == 'active',
      );
      final isActive = normalizedStatus == 'active';

      final batch = firestore.batch();
      for (final id in userIds) {
        if (id == currentUser.uid) {
          continue; // Skip current user (same as React line 304)
        }
        final userRef = firestore.collection(usersCollection).doc(id);
        batch.update(userRef, {
          'status': normalizedStatus,
          'isActive': isActive,
        });
      }
      await batch.commit();

      // Create audit logs (same as React lines 310-318)
      for (final id in userIds) {
        if (id == currentUser.uid) continue;
        await createAuditLog(
          collectionName: usersCollection,
          docId: id,
          action: 'update',
          changes: {
            'status': {
              'oldValue': status == 'active' ? 'inactive' : 'active',
              'newValue': normalizedStatus,
            },
          },
          userId: currentUser.uid,
          userName: currentUser.displayName,
        );
      }

      return true;
    } catch (e) {
      throw handleError(e, 'bulkUpdateUserStatus');
    }
  }

  // === Custom Roles Management (from roles.service.ts) ===

  // Get all custom roles (same as React getRoles)
  Future<List<CustomRole>> getCustomRoles() async {
    try {
      final firestore = db;
      if (firestore == null) return [];

      final querySnapshot = await firestore
          .collection(customRolesCollection)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 3));

      return querySnapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return CustomRole.fromJson(data);
      }).toList();
    } catch (e) {
      throw handleError(e, 'getCustomRoles');
    }
  }

  // Get single custom role (same as React getRole)
  Future<CustomRole?> getCustomRole(String id) async {
    try {
      final firestore = db;
      if (firestore == null) return null;

      final docRef = firestore.collection(customRolesCollection).doc(id);
      final docSnap = await docRef.get().timeout(const Duration(seconds: 3));

      if (docSnap.exists) {
        final data = Map<String, dynamic>.from(docSnap.data() as Map);
        data['id'] = docSnap.id;
        return CustomRole.fromJson(data);
      }

      return null;
    } catch (e) {
      throw handleError(e, 'getCustomRole');
    }
  }

  // Create custom role (same as React createRole)
  Future<String> createCustomRole({
    required String name,
    required String description,
    required List<Permission> permissions,
  }) async {
    try {
      final firestore = db;
      if (firestore == null) throw Exception('Offline');

      final docRef = firestore.collection(customRolesCollection).doc();
      final now = DateTime.now().toIso8601String();

      final roleData = {
        'id': docRef.id,
        'name': name,
        'description': description,
        'permissions': permissions.map((e) => e.toJson()).toList(),
        'isActive': true,
        'createdAt': now,
        'updatedAt': now,
        'createdBy': FirebaseAuth.instance.currentUser?.uid ?? 'system',
      };

      await docRef.set(roleData);
      return docRef.id;
    } catch (e) {
      throw handleError(e, 'createCustomRole');
    }
  }

  // Update custom role (same as React updateRole)
  Future<void> updateCustomRole(String id, Map<String, dynamic> updates) async {
    try {
      final firestore = db;
      if (firestore == null) return;

      final docRef = firestore.collection(customRolesCollection).doc(id);
      final updateData = Map<String, dynamic>.from(updates);
      updateData['updatedAt'] = DateTime.now().toIso8601String();

      await docRef.update(updateData);
    } catch (e) {
      throw handleError(e, 'updateCustomRole');
    }
  }

  // Delete custom role (same as React deleteRole)
  Future<void> deleteCustomRole(String id) async {
    try {
      final firestore = db;
      if (firestore == null) return;

      final docRef = firestore.collection(customRolesCollection).doc(id);
      final now = DateTime.now().toIso8601String();
      await docRef.set({
        'isDeleted': true,
        'deletedAt': now,
        'updatedAt': now,
      }, SetOptions(merge: true));
    } catch (e) {
      throw handleError(e, 'deleteCustomRole');
    }
  }

  // Update User Preferences
  Future<bool> updateUserPreferences(
    String userId,
    UserPreferences preferences,
  ) async {
    try {
      final firestore = db;
      if (firestore == null) return false;

      final userRef = firestore.collection(usersCollection).doc(userId);
      await userRef.update({
        'preferences': preferences.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      throw handleError(e, 'updateUserPreferences');
    }
  }

  // Toggle user status
  Future<bool> toggleUserStatus(String userId, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    return bulkUpdateUserStatus([userId], newStatus);
  }

  // Set password reset flag (for security audit/manual reset)
  Future<bool> requestPasswordReset(String userId) async {
    try {
      final firestore = db;
      if (firestore == null) return false;

      final userRef = firestore.collection(usersCollection).doc(userId);
      await userRef.update({
        'passwordResetAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      throw handleError(e, 'requestPasswordReset');
    }
  }

  // Delete user (Security: only allow deleting 'Mock' users as requested)
  Future<bool> deleteUser(String userId, String userName) async {
    try {
      final firestore = db;
      if (firestore == null) {
        // In Mock Mode, allow "deleting" if safety check passes
        if (FirebaseConfig.isMockMode) {
          if (!userName.toLowerCase().contains('mock')) {
            throw Exception('Security: Only Mock users can be deleted.');
          }
          return true; // Simulate success for UI
        }
        return false;
      }

      // Safety check: Only allow deleting if name contains 'Mock'
      if (!userName.toLowerCase().contains('mock')) {
        throw Exception(
          'Security: Only Mock users can be deleted via this action.',
        );
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (userId == currentUser?.uid) {
        throw Exception('Cannot delete yourself.');
      }

      final userRef = firestore.collection(usersCollection).doc(userId);
      final now = DateTime.now().toIso8601String();
      await userRef.set({
        'isDeleted': true,
        'deletedAt': now,
        'status': 'inactive',
        'updatedAt': now,
      }, SetOptions(merge: true));

      await createAuditLog(
        collectionName: usersCollection,
        docId: userId,
        action: 'delete',
        changes: {
          'user': {'oldValue': userName, 'newValue': null},
        },
        userId: currentUser?.uid ?? 'system',
        userName: currentUser?.displayName ?? 'System',
      );

      return true;
    } catch (e) {
      throw handleError(e, 'deleteUser');
    }
  }
}
