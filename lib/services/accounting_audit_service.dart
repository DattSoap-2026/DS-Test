import 'package:isar/isar.dart';

import 'base_service.dart';
import 'database_service.dart';
import '../utils/app_logger.dart';

class AccountingAuditService extends BaseService {
  final DatabaseService _dbService;

  AccountingAuditService(super.firebase, [DatabaseService? dbService])
      : _dbService = dbService ?? DatabaseService.instance;

  Future<void> logAction({
    required String userId,
    required String userName,
    required String action,
    required String collectionName,
    required String documentId,
    Map<String, dynamic>? changes,
    String? notes,
  }) async {
    try {
      AppLogger.debug(
        'Skipped client accounting audit write for $collectionName/$documentId ($action). audit_logs are pull-only.',
        tag: 'Audit',
      );
    } catch (e) {
      handleError(e, 'logAction');
    }
  }

  Future<List<Map<String, dynamic>>> getAuditLogsForUser({
    required String userId,
    int limit = 100,
  }) async {
    try {
      final allEntities = await _dbService.auditLogs.where().findAll();
      final filtered = allEntities.where((e) => e.userId == userId).toList();
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered.take(limit).map((e) => {
        'id': e.auditId,
        'userId': e.userId,
        'userName': e.userName,
        'action': e.action.name,
        'collectionName': e.collectionName,
        'documentId': e.documentId,
        'changes': e.changesJson,
        'notes': e.notes,
        'createdAt': e.createdAt.toIso8601String(),
      }).toList();
    } catch (e) {
      handleError(e, 'getAuditLogsForUser');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentAccountingAudits({
    int limit = 50,
  }) async {
    try {
      final allEntities = await _dbService.auditLogs.where().findAll();
      final filtered = allEntities.where((e) => 
        e.collectionName == 'vouchers' || e.collectionName == 'voucher_entries'
      ).toList();
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered.take(limit).map((e) => {
        'id': e.auditId,
        'userId': e.userId,
        'userName': e.userName,
        'action': e.action.name,
        'collectionName': e.collectionName,
        'documentId': e.documentId,
        'changes': e.changesJson,
        'notes': e.notes,
        'createdAt': e.createdAt.toIso8601String(),
      }).toList();
    } catch (e) {
      handleError(e, 'getRecentAccountingAudits');
      return [];
    }
  }
}
