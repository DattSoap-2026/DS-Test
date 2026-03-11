import 'package:isar/isar.dart';
import '../base_entity.dart';
import '../../../services/visit_service.dart';

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
  late String status; // 'in_progress', 'completed', 'skipped'

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

  // Convert to domain model
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

  // Create from domain model
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
      ..updatedAt = (visit.updatedAt != null && visit.updatedAt!.isNotEmpty)
          ? DateTime.parse(visit.updatedAt!)
          : DateTime.now()
      ..syncStatus = SyncStatus.synced
      ..isDeleted = false;
  }
}
