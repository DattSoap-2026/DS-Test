import 'package:isar/isar.dart';
import '../base_entity.dart';

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
}
