import 'dart:convert';

import 'package:isar/isar.dart';

import '../data/local/entities/audit_log_entity.dart';
import 'base_service.dart';
import 'database_service.dart';

const auditLogsCollection = 'audit_logs';

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

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      collectionName: json['collectionName'] as String? ?? '',
      docId: json['docId'] as String? ?? '',
      action: json['action'] as String? ?? '',
      changes: json['changes'] as Map<String, dynamic>? ?? {},
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}

class AuditService extends BaseService {
  final DatabaseService _dbService;

  AuditService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance;

  AuditLog _entityToAuditLog(AuditLogEntity entity) {
    Map<String, dynamic> changes = {};
    if (entity.changesJson != null) {
      try {
        changes = Map<String, dynamic>.from(jsonDecode(entity.changesJson!));
      } catch (e) {
        // debugPrint('Error decoding audit target JSON for $entity: $e');
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

  Future<List<AuditLog>> getAuditLogs({int limit = 50}) async {
    try {
      final entities = await _dbService.auditLogs.where().findAll();
      if (entities.isEmpty) return [];

      entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final limited = entities.length > limit
          ? entities.take(limit).toList()
          : entities;
      return limited.map(_entityToAuditLog).toList();
    } catch (e) {
      handleError(e, 'getAuditLogs');
      return [];
    }
  }

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
      handleError(e, 'deleteOldAuditLogs');
      return 0;
    }
  }

  Future<int> getOldAuditLogsCount(int retentionDays) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));
      return await _dbService.auditLogs
          .filter()
          .createdAtLessThan(cutoffDate)
          .count();
    } catch (e) {
      handleError(e, 'getOldAuditLogsCount');
      return 0;
    }
  }
}
