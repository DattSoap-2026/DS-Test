import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'advance_entity.g.dart';

@Collection()
class AdvanceEntity extends BaseEntity {
  @Index()
  late String employeeId;

  @Index()
  late String type; // 'Advance', 'Loan'

  late double amount;
  late double paidAmount; // Amount already repaid

  @Index()
  late String status; // 'Pending', 'Approved', 'Rejected', 'Active', 'Cleared'

  late String requestDate; // ISO8601
  String? approvedDate;
  String? approvedBy;
  String? rejectionReason;

  String? purpose; // Reason for advance/loan
  int? emiMonths; // For loans - number of monthly installments
  double? emiAmount; // Monthly deduction amount

  String? remarks;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'employeeId': employeeId,
      'type': type,
      'amount': amount,
      'paidAmount': paidAmount,
      'status': status,
      'requestDate': requestDate,
      'approvedDate': approvedDate,
      'approvedBy': approvedBy,
      'rejectionReason': rejectionReason,
      'purpose': purpose,
      'emiMonths': emiMonths,
      'emiAmount': emiAmount,
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

  static AdvanceEntity fromJson(Map<String, dynamic> json) {
    final approvedBy = parseString(json['approvedBy']);
    final rejectionReason = parseString(json['rejectionReason']);
    final purpose = parseString(json['purpose']);
    final remarks = parseString(json['remarks']);
    final approvedDate = parseDateOrNull(json['approvedDate']);
    final requestDate = parseDateOrNull(json['requestDate']) ?? DateTime.now();

    return AdvanceEntity()
      ..id = parseString(json['id'])
      ..employeeId = parseString(json['employeeId'])
      ..type = parseString(json['type'], fallback: 'Advance')
      ..amount = parseDouble(json['amount'])
      ..paidAmount = parseDouble(json['paidAmount'])
      ..status = parseString(json['status'], fallback: 'Pending')
      ..requestDate = requestDate.toIso8601String()
      ..approvedDate = approvedDate?.toIso8601String()
      ..approvedBy = approvedBy.isEmpty ? null : approvedBy
      ..rejectionReason = rejectionReason.isEmpty ? null : rejectionReason
      ..purpose = purpose.isEmpty ? null : purpose
      ..emiMonths = json['emiMonths'] == null
          ? null
          : parseInt(json['emiMonths'])
      ..emiAmount = json['emiAmount'] == null
          ? null
          : parseDouble(json['emiAmount'])
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
