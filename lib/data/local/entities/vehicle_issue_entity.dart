import 'package:isar/isar.dart';
import '../base_entity.dart';

part 'vehicle_issue_entity.g.dart';

@Collection()
class VehicleIssueEntity extends BaseEntity {
  @Index()
  late String vehicleId;
  late String vehicleNumber;
  late String reportedBy; // Driver or User ID
  late DateTime reportedDate;
  late String description;

  String priority = 'Medium'; // Low, Medium, High, Critical
  String status = 'Open'; // Open, In Progress, Resolved, Closed

  String? resolutionNotes;
  DateTime? resolvedDate;

  List<String>? images;

  late String createdAt;
}
