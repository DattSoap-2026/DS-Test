import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../models/settings_audit_log.dart';
import 'audit_logs_service.dart';
import 'base_service.dart';
import 'database_service.dart';

class SettingsAuditService extends BaseService {
  final DatabaseService _dbService;
  final AuditLogsService _auditLogsService;

  SettingsAuditService(
    super.firebase, [
    DatabaseService? dbService,
    AuditLogsService? auditLogsService,
  ]) : _dbService = dbService ?? DatabaseService.instance,
       _auditLogsService = auditLogsService ?? AuditLogsService(firebase);

  dynamic _normalizeForJson(dynamic value) {
    if (value == null) return null;
    try {
      return jsonDecode(jsonEncode(value));
    } catch (_) {
      return value.toString();
    }
  }

  SettingsAuditLog? _fromAuditChangePayload(dynamic rawPayload) {
    if (rawPayload is! Map) return null;
    final payload = Map<String, dynamic>.from(rawPayload);
    if (payload['setting_key'] == null || payload['module'] == null) {
      return null;
    }
    return SettingsAuditLog.fromMap(payload);
  }

  Future<void> logSettingsChange({
    required String userId,
    String? userName,
    required String module,
    required String settingKey,
    dynamic oldValue,
    dynamic newValue,
    String source = 'ui',
  }) async {
    final now = DateTime.now().toIso8601String();
    final log = SettingsAuditLog(
      id: const Uuid().v4(),
      timestamp: now,
      userId: userId,
      module: module,
      settingKey: settingKey,
      oldValue: _normalizeForJson(oldValue),
      newValue: _normalizeForJson(newValue),
      source: source,
    );

    final changeSet = <String, dynamic>{
      'settings_audit': log.toMap(),
      'module': module,
      'setting_key': settingKey,
      'old_value': log.oldValue,
      'new_value': log.newValue,
      'source': source,
    };

    try {
      await _auditLogsService.logAction(
        collectionName: 'settings',
        docId: settingKey,
        action: 'update',
        changes: changeSet,
        userId: userId,
        userName: userName,
      );

      await createAuditLog(
        collectionName: 'settings',
        docId: settingKey,
        action: 'update',
        changes: changeSet,
        userId: userId,
        userName: userName,
      );
    } catch (_) {
      // Audit logging must remain non-blocking for settings writes.
    }
  }

  Future<List<SettingsAuditLog>> getSettingsAuditLogs({
    DateTime? fromDate,
    DateTime? toDate,
    String? module,
    String? userId,
    int limit = 300,
  }) async {
    try {
      final entities = await _dbService.auditLogs.where().findAll();
      final entries = <SettingsAuditLog>[];

      for (final entity in entities) {
        if (entity.collectionName != 'settings') continue;

        Map<String, dynamic> changes = {};
        if (entity.changesJson != null && entity.changesJson!.isNotEmpty) {
          try {
            changes = Map<String, dynamic>.from(
              jsonDecode(entity.changesJson!),
            );
          } catch (_) {
            continue;
          }
        }

        final parsed = _fromAuditChangePayload(changes['settings_audit']);
        final row =
            parsed ??
            SettingsAuditLog(
              id: entity.auditId,
              timestamp: entity.createdAt.toIso8601String(),
              userId: entity.userId,
              module: changes['module']?.toString() ?? 'unknown',
              settingKey:
                  changes['setting_key']?.toString() ?? entity.documentId,
              oldValue: changes['old_value'],
              newValue: changes['new_value'],
              source: changes['source']?.toString() ?? 'system',
            );

        final createdAt = DateTime.tryParse(row.timestamp);
        if (fromDate != null &&
            createdAt != null &&
            createdAt.isBefore(fromDate)) {
          continue;
        }
        if (toDate != null && createdAt != null && createdAt.isAfter(toDate)) {
          continue;
        }
        if (module != null && module.isNotEmpty && row.module != module) {
          continue;
        }
        if (userId != null && userId.isNotEmpty && row.userId != userId) {
          continue;
        }

        entries.add(row);
      }

      entries.sort((a, b) {
        final aTs = DateTime.tryParse(a.timestamp);
        final bTs = DateTime.tryParse(b.timestamp);
        if (aTs == null || bTs == null) {
          return b.timestamp.compareTo(a.timestamp);
        }
        return bTs.compareTo(aTs);
      });

      if (limit > 0 && entries.length > limit) {
        return entries.take(limit).toList();
      }
      return entries;
    } catch (e) {
      throw handleError(e, 'getSettingsAuditLogs');
    }
  }

  Future<List<String>> getKnownModules() async {
    final logs = await getSettingsAuditLogs(limit: 1000);
    final modules =
        logs
            .map((e) => e.module.trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return modules;
  }

  Future<List<String>> getKnownUsers() async {
    final logs = await getSettingsAuditLogs(limit: 1000);
    final users =
        logs
            .map((e) => e.userId.trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return users;
  }
}
