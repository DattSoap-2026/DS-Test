/// Centralized Department Management Service
/// Provides canonical department list for issue/return flows
class DepartmentService {
  static final DepartmentService _instance = DepartmentService._internal();
  factory DepartmentService() => _instance;
  DepartmentService._internal();

  /// Canonical department list with IDs
  static const List<Map<String, String>> departments = [
    {'id': 'sona_bhatti', 'name': 'Sona Bhatti'},
    {'id': 'gita_bhatti', 'name': 'Gita Bhatti'},
    {'id': 'sona_production', 'name': 'Sona Production'},
    {'id': 'gita_production', 'name': 'Gita Production'},
    {'id': 'production', 'name': 'Production'},
    {'id': 'packing', 'name': 'Packing'},
    {'id': 'cutting', 'name': 'Cutting'},
    {'id': 'dispatch', 'name': 'Dispatch'},
  ];

  List<String> getDepartmentNames() {
    return departments.map((d) => d['name']!).toList();
  }

  String? getDepartmentId(String name) {
    try {
      return departments.firstWhere((d) => d['name'] == name)['id'];
    } catch (_) {
      return null;
    }
  }

  String? getDepartmentName(String id) {
    try {
      return departments.firstWhere((d) => d['id'] == id)['name'];
    } catch (_) {
      return null;
    }
  }

  bool isValidDepartment(String name) {
    return departments.any((d) => d['name'] == name);
  }
}
