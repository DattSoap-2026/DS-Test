import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';
import '../../../models/audit_log_model.dart';
import 'dart:convert';

part 'audit_log_entity.g.dart';

@Collection()
class AuditLogEntity extends BaseEntity {
  @Index(unique: true)
  late String auditId;

  @Index()
  late String userId;

  late String userName;
  late String userRole;

  @Enumerated(EnumType.ordinal)
  late AuditAction action;

  @Index()
  String? collectionName;

  @Index()
  String? documentId;

  String? changesJson;
  String? notes;

  @Index()
  late DateTime createdAt;

  String? ipAddress;
  String? deviceInfo;

  AuditLog toDomain() {
    return AuditLog(
      id: auditId,
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: action,
      collectionName: collectionName ?? '',
      documentId: documentId ?? '',
      changes: changesJson != null ? jsonDecode(changesJson!) : null,
      notes: notes,
      createdAt: createdAt,
      ipAddress: ipAddress,
      deviceInfo: deviceInfo,
    );
  }

  static AuditLogEntity fromDomain(AuditLog model) {
    return AuditLogEntity()
      ..id = model.id
      ..auditId = model.id
      ..userId = model.userId
      ..userName = model.userName
      ..userRole = model.userRole
      ..action = model.action
      ..collectionName = model.collectionName.trim().isEmpty
          ? null
          : model.collectionName
      ..documentId = model.documentId.trim().isEmpty ? null : model.documentId
      ..changesJson = model.changes != null ? jsonEncode(model.changes) : null
      ..notes = model.notes
      ..createdAt = model.createdAt
      ..ipAddress = model.ipAddress
      ..deviceInfo = model.deviceInfo
      ..syncStatus = SyncStatus.synced
      ..updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'auditId': auditId,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'action': action.name,
      'collectionName': collectionName,
      'documentId': documentId,
      'changesJson': changesJson,
      'changes': parseJsonMap(changesJson),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'ipAddress': ipAddress,
      'deviceInfo': deviceInfo,
      'updatedAt': updatedAt.toIso8601String(),
      'lastModified': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus.name,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  static AuditLogEntity fromJson(Map<String, dynamic> json) {
    final id = parseString(json['id']);
    final auditId = parseString(json['auditId'], fallback: id).trim();
    final collectionName = _nullableString(json['collectionName']);
    final documentId = _nullableString(json['documentId'] ?? json['docId']);
    final changesJson = _normalizeChangesJson(
      json['changesJson'] ?? json['changes'],
    );

    return AuditLogEntity()
      ..id = id.isEmpty ? auditId : id
      ..auditId = auditId.isEmpty ? id : auditId
      ..userId = parseString(json['userId'])
      ..userName = parseString(json['userName'])
      ..userRole = parseString(json['userRole'])
      ..action = _parseAuditAction(json['action'])
      ..collectionName = collectionName
      ..documentId = documentId
      ..changesJson = changesJson
      ..notes = _nullableString(json['notes'])
      ..createdAt = parseDate(json['createdAt'] ?? json['timestamp'])
      ..ipAddress = _nullableString(json['ipAddress'])
      ..deviceInfo = _nullableString(json['deviceInfo'])
      ..updatedAt = parseDate(
        json['updatedAt'] ?? json['lastModified'] ?? json['createdAt'],
      )
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }

  static String? _nullableString(dynamic value) {
    final normalized = parseString(value).trim();
    return normalized.isEmpty ? null : normalized;
  }

  static String? _normalizeChangesJson(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final normalized = value.trim();
      return normalized.isEmpty ? null : normalized;
    }
    final changes = parseJsonMap(value);
    if (changes == null || changes.isEmpty) {
      return null;
    }
    return jsonEncode(changes);
  }

  static AuditAction _parseAuditAction(dynamic value) {
    final normalized = parseString(value, fallback: AuditAction.other.name)
        .trim()
        .toLowerCase()
        .replaceFirst('auditaction.', '');
    for (final candidate in AuditAction.values) {
      if (candidate.name.toLowerCase() == normalized) {
        return candidate;
      }
    }
    return AuditAction.other;
  }
}
