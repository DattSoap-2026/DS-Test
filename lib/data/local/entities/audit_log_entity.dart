import 'package:isar/isar.dart';
import '../base_entity.dart';
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
  late String collectionName;

  @Index()
  late String documentId;

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
      collectionName: collectionName,
      documentId: documentId,
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
      ..collectionName = model.collectionName
      ..documentId = model.documentId
      ..changesJson = model.changes != null ? jsonEncode(model.changes) : null
      ..notes = model.notes
      ..createdAt = model.createdAt
      ..ipAddress = model.ipAddress
      ..deviceInfo = model.deviceInfo
      ..syncStatus = SyncStatus.synced
      ..updatedAt = DateTime.now();
  }
}
