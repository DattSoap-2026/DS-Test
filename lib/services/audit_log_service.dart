import '../models/audit_log_model.dart';
import 'database_service.dart';
import '../data/local/entities/audit_log_entity.dart';
import 'package:isar/isar.dart';
import '../utils/app_logger.dart';

class AuditLogService {
  final DatabaseService _db;

  AuditLogService(this._db);

  // LOG AN EVENT
  Future<void> log({
    required String userId,
    required String userName,
    required String userRole,
    required AuditAction action,
    required String collectionName,
    required String documentId,
    Map<String, dynamic>? changes,
    String? notes,
  }) async {
    AppLogger.debug(
      'Skipped client audit log write for $collectionName/$documentId (${action.name}). audit_logs are pull-only.',
      tag: 'Audit',
    );
  }

  // QUERY LOGS
  Future<List<AuditLog>> getLogs({
    String? userId,
    String? collectionName,
    int limit = 100,
  }) async {
    // Get all logs using where() pattern which is well-supported
    final allLogs = await _db.auditLogs.where().findAll();

    // Apply filters in Dart (simple and reliable)
    var filtered = allLogs.where((log) {
      if (userId != null && log.userId != userId) return false;
      if (collectionName != null && log.collectionName != collectionName) {
        return false;
      }
      return true;
    }).toList();

    // Sort by createdAt descending
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply limit
    if (filtered.length > limit) {
      filtered = filtered.take(limit).toList();
    }

    return filtered.map((e) => e.toDomain()).toList();
  }

  // CLEAR OLD LOGS (Retention policy)
  Future<void> clearOldLogs(int daysOld) async {
    final expiry = DateTime.now().subtract(Duration(days: daysOld));
    await _db.db.writeTxn(() async {
      await _db.auditLogs.filter().createdAtLessThan(expiry).deleteAll();
    });
  }
}
