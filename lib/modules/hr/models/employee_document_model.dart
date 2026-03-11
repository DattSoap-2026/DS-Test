class EmployeeDocument {
  final String id;
  final String employeeId;
  final String documentType;
  final String documentName;
  final String? documentNumber;
  final String filePath;
  final String? cloudUrl;
  final DateTime? expiryDate;
  final bool isVerified;
  final String? verifiedBy;
  final DateTime? verifiedDate;
  final String? remarks;

  String? employeeName;

  EmployeeDocument({
    required this.id,
    required this.employeeId,
    required this.documentType,
    required this.documentName,
    this.documentNumber,
    required this.filePath,
    this.cloudUrl,
    this.expiryDate,
    this.isVerified = false,
    this.verifiedBy,
    this.verifiedDate,
    this.remarks,
    this.employeeName,
  });

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry > 0 && daysUntilExpiry <= 30;
  }

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }
}

class DocumentType {
  final String name;
  final String category;
  final bool requiresExpiry;
  final bool requiresNumber;

  const DocumentType({
    required this.name,
    required this.category,
    this.requiresExpiry = false,
    this.requiresNumber = false,
  });

  static const List<DocumentType> commonTypes = [
    DocumentType(
      name: 'Aadhar Card',
      category: 'Identity',
      requiresNumber: true,
    ),
    DocumentType(name: 'PAN Card', category: 'Identity', requiresNumber: true),
    DocumentType(
      name: 'Driving License',
      category: 'Identity',
      requiresExpiry: true,
      requiresNumber: true,
    ),
    DocumentType(
      name: 'Passport',
      category: 'Identity',
      requiresExpiry: true,
      requiresNumber: true,
    ),
    DocumentType(name: 'Voter ID', category: 'Identity', requiresNumber: true),
    DocumentType(name: 'Bank Passbook', category: 'Financial'),
    DocumentType(name: 'Cancelled Cheque', category: 'Financial'),
    DocumentType(name: 'Educational Certificate', category: 'Education'),
    DocumentType(name: 'Experience Letter', category: 'Employment'),
    DocumentType(name: 'Offer Letter', category: 'Employment'),
    DocumentType(
      name: 'Contract',
      category: 'Employment',
      requiresExpiry: true,
    ),
    DocumentType(name: 'Other', category: 'Other'),
  ];
}
