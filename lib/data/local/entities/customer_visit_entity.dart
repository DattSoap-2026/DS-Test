import 'package:isar/isar.dart';

import '../../../services/visit_service.dart';
import '../base_entity.dart';
import '../entity_json_utils.dart';

part 'customer_visit_entity.g.dart';

@Collection()
class CustomerVisitEntity extends BaseEntity {
  @Index()
  late String sessionId;

  @Index()
  late String customerId;

  late String customerName;

  @Index()
  late String salesmanId;

  late String salesmanName;

  @Index()
  late String status;

  late String arrivalTime;
  String? departureTime;
  double? visitDuration;
  String? saleId;
  double? saleAmount;
  double? paymentCollected;
  String? notes;
  String? photoUrl;
  String? skipReason;
  String? skipNote;

  @Index()
  late int sequenceNumber;

  late String createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sessionId': sessionId,
      'customerId': customerId,
      'customerName': customerName,
      'salesmanId': salesmanId,
      'salesmanName': salesmanName,
      'status': status,
      'arrivalTime': arrivalTime,
      'departureTime': departureTime,
      'visitDuration': visitDuration,
      'saleId': saleId,
      'saleAmount': saleAmount,
      'paymentCollected': paymentCollected,
      'notes': notes,
      'photoUrl': photoUrl,
      'skipReason': skipReason,
      'skipNote': skipNote,
      'sequenceNumber': sequenceNumber,
      'createdAt': createdAt,
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

  CustomerVisit toDomain() {
    return CustomerVisit(
      id: id,
      sessionId: sessionId,
      customerId: customerId,
      customerName: customerName,
      salesmanId: salesmanId,
      salesmanName: salesmanName,
      status: status,
      arrivalTime: arrivalTime,
      departureTime: departureTime,
      visitDuration: visitDuration,
      saleId: saleId,
      saleAmount: saleAmount,
      paymentCollected: paymentCollected,
      notes: notes,
      photoUrl: photoUrl,
      skipReason: skipReason,
      skipNote: skipNote,
      sequenceNumber: sequenceNumber,
      createdAt: createdAt,
      updatedAt: updatedAt.toIso8601String(),
    );
  }

  static CustomerVisitEntity fromJson(Map<String, dynamic> json) {
    return CustomerVisitEntity()
      ..id = parseString(json['id'])
      ..sessionId = parseString(json['sessionId'])
      ..customerId = parseString(json['customerId'])
      ..customerName = parseString(json['customerName'])
      ..salesmanId = parseString(json['salesmanId'])
      ..salesmanName = parseString(json['salesmanName'])
      ..status = parseString(json['status'], fallback: 'in_progress')
      ..arrivalTime = parseString(json['arrivalTime'])
      ..departureTime = parseString(json['departureTime'], fallback: '')
      ..visitDuration = json['visitDuration'] == null
          ? null
          : parseDouble(json['visitDuration'])
      ..saleId = parseString(json['saleId'], fallback: '')
      ..saleAmount = json['saleAmount'] == null
          ? null
          : parseDouble(json['saleAmount'])
      ..paymentCollected = json['paymentCollected'] == null
          ? null
          : parseDouble(json['paymentCollected'])
      ..notes = parseString(json['notes'], fallback: '')
      ..photoUrl = parseString(json['photoUrl'], fallback: '')
      ..skipReason = parseString(json['skipReason'], fallback: '')
      ..skipNote = parseString(json['skipNote'], fallback: '')
      ..sequenceNumber = parseInt(json['sequenceNumber'])
      ..createdAt = parseString(json['createdAt'])
      ..updatedAt = parseDate(json['updatedAt'] ?? json['lastModified'])
      ..deletedAt = parseDateOrNull(json['deletedAt'])
      ..syncStatus = parseSyncStatus(json['syncStatus'])
      ..isSynced = parseBool(json['isSynced'])
      ..isDeleted = parseBool(json['isDeleted'])
      ..lastSynced = parseDateOrNull(json['lastSynced'])
      ..version = parseInt(json['version'], fallback: 1)
      ..deviceId = parseString(json['deviceId']);
  }

  static CustomerVisitEntity fromDomain(CustomerVisit visit) {
    return CustomerVisitEntity()
      ..id = visit.id
      ..sessionId = visit.sessionId
      ..customerId = visit.customerId
      ..customerName = visit.customerName
      ..salesmanId = visit.salesmanId
      ..salesmanName = visit.salesmanName
      ..status = visit.status
      ..arrivalTime = visit.arrivalTime
      ..departureTime = visit.departureTime
      ..visitDuration = visit.visitDuration
      ..saleId = visit.saleId
      ..saleAmount = visit.saleAmount
      ..paymentCollected = visit.paymentCollected
      ..notes = visit.notes
      ..photoUrl = visit.photoUrl
      ..skipReason = visit.skipReason
      ..skipNote = visit.skipNote
      ..sequenceNumber = visit.sequenceNumber
      ..createdAt = visit.createdAt
      ..updatedAt = parseDate(visit.updatedAt)
      ..syncStatus = SyncStatus.pending
      ..isDeleted = false;
  }
}
