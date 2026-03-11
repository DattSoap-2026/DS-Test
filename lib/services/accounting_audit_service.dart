import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';
import '../data/local/entities/audit_log_entity.dart';
import '../models/audit_log_model.dart';
import 'base_service.dart';
import 'database_service.dart';

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
      final now = DateTime.now();
      final auditId = 'audit_${now.microsecondsSinceEpoch}_$userId';

      final entity = AuditLogEntity()
        ..auditId = auditId
        ..userId = userId
        ..userName = userName
        ..action = _parseAction(action)
        ..collectionName = collectionName
        ..documentId = documentId
        ..changesJson = changes != null ? _encodeChanges(changes) : null
        ..notes = notes
        ..createdAt = now;

      // Save to local Isar
      await _dbService.db.writeTxn(() async {
        await _dbService.auditLogs.put(entity);
      });

      // Sync to Firebase
      final firestore = db;
      if (firestore != null) {
        await firestore.collection('audit_logs').doc(auditId).set({
          'userId': userId,
          'userName': userName,
          'action': action,
          'collectionName': collectionName,
          'documentId': documentId,
          if (changes != null) 'changes': changes,
          if (notes != null) 'notes': notes,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      handleError(e, 'logAction');
    }
  }

  AuditAction _parseAction(String action) {
    switch (action.toLowerCase()) {
      case 'create':
        return AuditAction.create;
      case 'update':
        return AuditAction.update;
      case 'delete':
        return AuditAction.delete;
      case 'sync':
        return AuditAction.sync;
      case 'login':
        return AuditAction.login;
      case 'logout':
        return AuditAction.logout;
      default:
        return AuditAction.other;
    }
  }

  String? _encodeChanges(Map<String, dynamic> changes) {
    try {
      return changes.toString();
    } catch (_) {
      return null;
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
