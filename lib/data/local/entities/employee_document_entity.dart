import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'employee_document_entity.g.dart';

@Collection()
class EmployeeDocumentEntity extends BaseEntity {
  @Index()
  late String employeeId;

  @Index()
  late String documentType; // 'Aadhar', 'PAN', 'License', 'Certificate', etc.

  late String documentName;
  String? documentNumber; // e.g., Aadhar number, PAN number

  late String filePath; // Local file path
  String? cloudUrl; // Firebase Storage URL after sync

  String? expiryDate; // For licenses, certifications
  bool isVerified = false;
  String? verifiedBy;
  String? verifiedDate;

  String? remarks;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'employeeId': employeeId,
      'documentType': documentType,
      'documentName': documentName,
      'documentNumber': documentNumber,
      'filePath': filePath,
      'cloudUrl': cloudUrl,
      'expiryDate': expiryDate,
      'isVerified': isVerified,
      'verifiedBy': verifiedBy,
      'verifiedDate': verifiedDate,
      'remarks': remarks,
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

  static EmployeeDocumentEntity fromJson(Map<String, dynamic> json) {
    final documentNumber = parseString(json['documentNumber']);
    final cloudUrl = parseString(json['cloudUrl']);
    final verifiedBy = parseString(json['verifiedBy']);
    final remarks = parseString(json['remarks']);
    final expiryDate = parseDateOrNull(json['expiryDate']);
    final verifiedDate = parseDateOrNull(json['verifiedDate']);

    return EmployeeDocumentEntity()
      ..id = parseString(json['id'])
      ..employeeId = parseString(json['employeeId'])
      ..documentType = parseString(json['documentType'])
      ..documentName = parseString(json['documentName'])
      ..documentNumber = documentNumber.isEmpty ? null : documentNumber
      ..filePath = parseString(json['filePath'])
      ..cloudUrl = cloudUrl.isEmpty ? null : cloudUrl
      ..expiryDate = expiryDate?.toIso8601String()
      ..isVerified = parseBool(json['isVerified'])
      ..verifiedBy = verifiedBy.isEmpty ? null : verifiedBy
      ..verifiedDate = verifiedDate?.toIso8601String()
      ..remarks = remarks.isEmpty ? null : remarks
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }
}
