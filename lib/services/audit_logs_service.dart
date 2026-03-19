import 'dart:convert';

import 'package:isar/isar.dart';

import '../data/local/entities/audit_log_entity.dart';
import 'base_service.dart';
import 'database_service.dart';
import '../utils/app_logger.dart';

const String auditLogsCollection = 'audit_logs';

class AuditLog {
  final String id;
  final String collectionName;
  final String docId;
  final String action;
  final Map<String, dynamic> changes;
  final String userId;
  final String userName;
  final String timestamp;

  AuditLog({
    required this.id,
    required this.collectionName,
    required this.docId,
    required this.action,
    required this.changes,
    required this.userId,
    required this.userName,
    required this.timestamp,
  });
}

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
      collectionName: entity.collectionName ?? '',
      docId: entity.documentId ?? '',
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
    AppLogger.debug(
      'Skipped client audit log write for $collectionName/$docId ($action). audit_logs are pull-only.',
      tag: 'Audit',
    );
  }

}
