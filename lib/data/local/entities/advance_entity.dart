import 'package:isar/isar.dart';
import '../base_entity.dart';

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
}
