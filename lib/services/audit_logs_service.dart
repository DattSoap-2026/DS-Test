import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../models/types/user_types.dart';
import '../models/audit_log_model.dart' as audit_model;
import '../data/local/base_entity.dart';
import '../data/local/entities/audit_log_entity.dart';
import 'base_service.dart';
import 'database_service.dart';

const String auditLogsCollection = 'audit_logs';

class AuditLogsService extends BaseService {
  final DatabaseService _dbService;

  AuditLogsService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance;

  AuditLog _entityToAuditLog(AuditLogEntity entity) {
    Map<String, dynamic> changes = {};
    if (entity.changesJson != null) {
      try {
        changes = Map<String, dynamic>.from(jsonDecode(entity.changesJson!));
      } catch (e) {
        // debugPrint('Error decoding audit changes in AuditLogsService $entity: $e');
      }
    }

    return AuditLog(
      id: entity.auditId,
      collectionName: entity.collectionName,
      docId: entity.documentId,
      action: entity.action.name,
      changes: changes,
      userId: entity.userId,
      userName: entity.userName,
      timestamp: entity.createdAt.toIso8601String(),
    );
  }

  /// Fetch audit logs with limit
  Future<List<AuditLog>> getAuditLogs({int limitCount = 50}) async {
    try {
      final entities = await _dbService.auditLogs.where().findAll();
      if (entities.isEmpty) return [];

      entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final limited = entities.length > limitCount
          ? entities.take(limitCount).toList()
          : entities;
      return limited.map(_entityToAuditLog).toList();
    } catch (e) {
      throw handleError(e, 'getAuditLogs');
    }
  }

  /// Get count of logs older than retention days
  Future<int> getOldAuditLogsCount(int retentionDays) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));
      return await _dbService.auditLogs
          .filter()
          .createdAtLessThan(cutoffDate)
          .count();
    } catch (e) {
      throw handleError(e, 'getOldAuditLogsCount');
    }
  }

  /// Delete logs older than retention days
  Future<int> deleteOldAuditLogs(int retentionDays) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));
      final count = await _dbService.auditLogs
          .filter()
          .createdAtLessThan(cutoffDate)
          .count();
      if (count == 0) return 0;

      await _dbService.db.writeTxn(() async {
        await _dbService.auditLogs
            .filter()
            .createdAtLessThan(cutoffDate)
            .deleteAll();
      });
      return count;
    } catch (e) {
      throw handleError(e, 'deleteOldAuditLogs');
    }
  }

  /// Log an action (helper)
  Future<void> logAction({
    required String collectionName,
    required String docId,
    required String action,
    required Map<String, dynamic> changes,
    required String userId,
    String? userName,
  }) async {
    try {
      final now = DateTime.now();
      final id = const Uuid().v4();
      final entity = AuditLogEntity()
        ..id = id
        ..auditId = id
        ..userId = userId
        ..userName = userName ?? 'Unknown'
        ..userRole = 'Unknown'
        ..action = _mapAction(action)
        ..collectionName = collectionName
        ..documentId = docId
        ..changesJson = jsonEncode(changes)
        ..createdAt = now
        ..updatedAt = now
        ..syncStatus = SyncStatus.synced;

      await _dbService.db.writeTxn(() async {
        await _dbService.auditLogs.put(entity);
      });
    } catch (e) {
      // Silently fail to not block main application flow
    }
  }

  audit_model.AuditAction _mapAction(String action) {
    switch (action) {
      case 'create':
        return audit_model.AuditAction.create;
      case 'update':
        return audit_model.AuditAction.update;
      case 'delete':
        return audit_model.AuditAction.delete;
      case 'sync':
        return audit_model.AuditAction.sync;
      case 'login':
        return audit_model.AuditAction.login;
      case 'logout':
        return audit_model.AuditAction.logout;
      case 'payment':
        return audit_model.AuditAction.payment;
      default:
        return audit_model.AuditAction.other;
    }
  }
}
