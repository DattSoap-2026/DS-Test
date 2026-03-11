import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:isar/isar.dart';

import 'package:flutter_app/data/local/base_entity.dart';
import 'package:flutter_app/data/local/entities/sync_metric_entity.dart';
import 'package:flutter_app/data/local/entities/user_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';
import 'package:flutter_app/core/constants/collection_registry.dart';
import 'package:flutter_app/services/database_service.dart';
import 'package:flutter_app/services/sync_common_utils.dart';
import 'package:flutter_app/utils/app_logger.dart';

class UsersSyncDelegate {
  final DatabaseService _dbService;
  final SyncCommonUtils _utils;
  final Future<void> Function({
    required String entityType,
    required SyncOperation operation,
    required int recordCount,
    required int durationMs,
    required bool success,
    String? errorMessage,
  })
  _recordMetric;

  UsersSyncDelegate({
    required DatabaseService dbService,
    required SyncCommonUtils utils,
    required Future<void> Function({
      required String entityType,
      required SyncOperation operation,
      required int recordCount,
      required int durationMs,
      required bool success,
      String? errorMessage,
    })
    recordMetric,
  }) : _dbService = dbService,
       _utils = utils,
       _recordMetric = recordMetric;

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

  String? _encodeAllocatedStockJson(
    dynamic allocatedStock,
    dynamic allocatedStockJson,
  ) {
    if (allocatedStock is Map) {
      try {
        return jsonEncode(allocatedStock);
      } catch (_) {
        return null;
      }
    }
    if (allocatedStockJson is String && allocatedStockJson.isNotEmpty) {
      return allocatedStockJson;
    }
    return null;
  }

  Map<String, dynamic>? _decodeAllocatedStockJson(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (e) {
      AppLogger.warning('Error decoding allocated stock JSON: $e', tag: 'Sync');
    }
    return null;
  }

  Future<void> syncUsers(
    firestore.FirebaseFirestore db, {
    required AppUser? currentUser,
    bool forceRefresh = false,
  }) async {
    final stopwatchPush = Stopwatch()..start();
    int pushedCount = 0;
    bool pushSuccess = false;
    String? pushError;

    try {
      // 1. PUSH (Local -> Firebase)
      final pendingUsers = await _dbService.users
          .filter()
          .syncStatusEqualTo(SyncStatus.pending)
          .findAll();

      if (pendingUsers.isNotEmpty) {
        final chunks = _utils.chunkList(pendingUsers, 450);

        for (final chunk in chunks) {
          final batch = db.batch();

          for (final user in chunk) {
            // T9-P5 REMOVED: Direct allocatedStock remote push from raw JSON
            final allocatedStockMap = _decodeAllocatedStockJson(
              user.allocatedStockJson,
            );
            final shouldPushAllocatedStock =
                currentUser != null && currentUser.id == user.id;
            final normalizedStatus = _normalizeAccountStatus(
              user.status,
              fallbackIsActive: user.isActive,
            );
            final isActive = normalizedStatus == 'active';
            final data = {
              'name': user.name,
              'email': user.email,
              'role': user.role,
              'phone': user.phone,
              'status': normalizedStatus,
              'isActive': isActive,
              'department': user.department,
              'assignedRoutes': user.assignedRoutes,
              'assignedBhatti': user.assignedBhatti,
              'assignedBaseProductId': user.assignedBaseProductId,
              'assignedBaseProductName': user.assignedBaseProductName,
              'assignedVehicleId': user.assignedVehicleId,
              'assignedVehicleName': user.assignedVehicleName,
              'assignedVehicleNumber': user.assignedVehicleNumber,
              'assignedDeliveryRoute': user.assignedDeliveryRoute,
              'assignedSalesRoute': user.assignedSalesRoute,
              'allocatedStockJson': user.allocatedStockJson,
              if (shouldPushAllocatedStock && allocatedStockMap != null)
                'allocatedStock': allocatedStockMap,
              'updatedAt': user.updatedAt.toIso8601String(),
            };
            final docRef = db.collection(CollectionRegistry.users).doc(user.id);
            batch.set(docRef, data, firestore.SetOptions(merge: true));
          }

          await batch.commit();

          await _dbService.db.writeTxn(() async {
            final updatedUsers = <UserEntity>[];
            for (final user in chunk) {
              user.syncStatus = SyncStatus.synced;
              updatedUsers.add(user);
            }
            if (updatedUsers.isNotEmpty) {
              await _dbService.users.putAll(updatedUsers);
            }
          });
          pushedCount += chunk.length;
        }
        AppLogger.success('Pushed $pushedCount users to Firebase', tag: 'Sync');
      }
      pushSuccess = true;
    } catch (e) {
      AppLogger.error('Error pushing users', error: e, tag: 'Sync');
      pushError = e.toString();
    } finally {
      stopwatchPush.stop();
      await _recordMetric(
        entityType: 'users',
        operation: SyncOperation.push,
        recordCount: pushedCount,
        durationMs: stopwatchPush.elapsedMilliseconds,
        success: pushSuccess,
        errorMessage: pushError,
      );
    }

    // 2. PULL (Firebase -> Local)
    final stopwatchPull = Stopwatch()..start();
    int pulledCount = 0;
    bool pullSuccess = false;
    String? pullError;

    try {
      final rawLastSync = forceRefresh
          ? null
          : await _utils.getLastSyncTimestamp('users');
      DateTime? lastSync = rawLastSync;
      final now = DateTime.now();
      if (lastSync != null &&
          lastSync.isAfter(now.add(const Duration(minutes: 5)))) {
        AppLogger.warning(
          'Users lastSync cursor is in the future ($lastSync). Falling back to full pull.',
          tag: 'Sync',
        );
        lastSync = null;
      }

      var useFullPull = forceRefresh || lastSync == null;
      firestore.Query query = db.collection(CollectionRegistry.users);

      if (!useFullPull) {
        query = query.where(
          'updatedAt',
          isGreaterThan: lastSync.toIso8601String(),
        );
      }

      firestore.QuerySnapshot snapshot;
      try {
        snapshot = await query.get();
      } catch (e) {
        if (!useFullPull) {
          AppLogger.warning(
            'Delta pull failed for users; retrying full pull. Error: $e',
            tag: 'Sync',
          );
          useFullPull = true;
          snapshot = await db.collection(CollectionRegistry.users).get();
        } else {
          rethrow;
        }
      }

      final shouldFallbackToFullPull =
          !useFullPull &&
          snapshot.docs.isEmpty &&
          now.difference(lastSync ?? now).inHours >= 6;
      if (shouldFallbackToFullPull) {
        useFullPull = true;
        snapshot = await db.collection(CollectionRegistry.users).get();
      }

      if (snapshot.docs.isNotEmpty) {
        DateTime maxUpdatedAt = lastSync ?? DateTime(2000);
        final usersToUpsert = <UserEntity>[];
        final ids = snapshot.docs.map((doc) => doc.id).toList(growable: false);
        final existingRecords = await _dbService.users
            .filter()
            .anyOf(ids, (q, String id) => q.idEqualTo(id))
            .findAll();
        final existingMap = {for (final user in existingRecords) user.id: user};

        for (final doc in snapshot.docs) {
          final data = Map<String, dynamic>.from(
            doc.data() as Map<String, dynamic>,
          );
          final updatedAt = _utils.parseRemoteDate(
            data['updatedAt'] ?? data['lastUpdatedAt'] ?? data['createdAt'],
            fallback: DateTime.fromMillisecondsSinceEpoch(0),
          );
          if (updatedAt.isAfter(maxUpdatedAt)) maxUpdatedAt = updatedAt;

          // Conflict Detection
          final existing = existingMap[doc.id];
          if (existing != null && existing.syncStatus == SyncStatus.pending) {
            await _utils.detectAndFlagConflict<UserEntity>(
              entityId: doc.id,
              entityType: 'users',
              serverData: data,
              localEntity: existing,
              localToJson: (e) => e.toDomain().toJson(),
            );
            continue;
          }
          if (existing != null && existing.syncStatus == SyncStatus.conflict) {
            continue;
          }

          final allocatedStockJson = _encodeAllocatedStockJson(
            data['allocatedStock'],
            data['allocatedStockJson'],
          );
          final assignedRoutesRaw = data['assignedRoutes'];
          final assignedRoutes = assignedRoutesRaw is List
              ? assignedRoutesRaw.map((e) => e.toString()).toList()
              : <String>[];
          final isActive = _resolveIsActive(data['isActive'], data['status']);
          final normalizedStatus = _normalizeAccountStatus(
            data['status'],
            fallbackIsActive: isActive,
          );
          final rawStatus = data['status']?.toString().trim() ?? '';
          final shouldRepairRemote = rawStatus.isEmpty || data['isActive'] == null;

          final user = UserEntity()
            ..id = doc.id
            ..name = data['name']?.toString() ?? ''
            ..email = data['email']?.toString() ?? ''
            ..role = data['role']?.toString() ?? 'Salesman'
            ..phone = data['phone']?.toString() ?? data['mobile']?.toString()
            ..status = normalizedStatus
            ..isActive = isActive
            ..department = data['department']?.toString()
            ..designation = data['designation']?.toString()
            ..assignedRoutes = assignedRoutes
            ..assignedBhatti = data['assignedBhatti']?.toString()
            ..assignedBaseProductId = data['assignedBaseProductId']?.toString()
            ..assignedBaseProductName = data['assignedBaseProductName']
                ?.toString()
            ..assignedVehicleId = data['assignedVehicleId']?.toString()
            ..assignedVehicleName = data['assignedVehicleName']?.toString()
            ..assignedVehicleNumber = data['assignedVehicleNumber']?.toString()
            ..assignedDeliveryRoute = data['assignedDeliveryRoute']?.toString()
            ..assignedSalesRoute = data['assignedSalesRoute']?.toString()
            ..allocatedStockJson = allocatedStockJson
            ..syncStatus = shouldRepairRemote
                ? SyncStatus.pending
                : SyncStatus.synced
            ..updatedAt = updatedAt;

          usersToUpsert.add(user);
        }

        if (usersToUpsert.isNotEmpty) {
          await _dbService.db.writeTxn(() async {
            await _dbService.users.putAll(usersToUpsert);
          });
        }
        await _utils.setLastSyncTimestamp('users', maxUpdatedAt);
        pulledCount = snapshot.docs.length;
        AppLogger.success('Pulled $pulledCount users from Firebase', tag: 'Sync');
      }
      pullSuccess = true;
    } catch (e) {
      AppLogger.error('Error pulling users', error: e, tag: 'Sync');
      pullError = e.toString();
    } finally {
      stopwatchPull.stop();
      await _recordMetric(
        entityType: 'users',
        operation: SyncOperation.pull,
        recordCount: pulledCount,
        durationMs: stopwatchPull.elapsedMilliseconds,
        success: pullSuccess,
        errorMessage: pullError,
      );
    }
  }
}
