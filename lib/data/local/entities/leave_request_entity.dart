import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'leave_request_entity.g.dart';

@Collection()
class LeaveRequestEntity extends BaseEntity {
  @Index()
  late String employeeId;

  @Index()
  late String leaveType; // 'Sick', 'Casual', 'Earned', 'Unpaid'

  late String startDate; // ISO8601
  late String endDate;
  late int totalDays;

  String? reason;

  @Index()
  late String status; // 'Pending', 'Approved', 'Rejected', 'Cancelled'

  String? approvedBy;
  String? approvedAt;
  String? rejectionReason;

  late String requestedAt;
}
