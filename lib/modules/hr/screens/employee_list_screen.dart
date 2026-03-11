import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/hr_service.dart';
import '../models/employee_model.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/ui/themed_tab_bar.dart';
import '../../../utils/responsive.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen>
    with SingleTickerProviderStateMixin {
  static const List<_RoleFilter> _roleTabs = [
    _RoleFilter(label: 'All', role: null),
    _RoleFilter(label: 'Worker', role: 'worker'),
    _RoleFilter(label: 'Driver', role: 'driver'),
    _RoleFilter(label: 'Salesman', role: 'salesman'),
    _RoleFilter(label: 'Staff', role: 'office_staff'),
  ];

  bool _isLoading = true;
  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  String _searchQuery = '';
  String? _selectedRole;
  late TabController _filterTabController;

  @override
  void initState() {
    super.initState();
    _filterTabController = TabController(
      length: _roleTabs.length,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _loadEmployees();
  }

  @override
  void dispose() {
    _filterTabController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      _allEmployees = await context.read<HrService>().getAllEmployees();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading employees: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredEmployees = _allEmployees.where((emp) {
        final matchesSearch =
            emp.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            emp.employeeId.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesRole =
            _selectedRole == null || emp.roleType == _selectedRole;
        return matchesSearch && matchesRole;
      }).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final filterSectionHeight = isMobile ? 116.0 : 106.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Directory'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(filterSectionHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (val) {
                    _searchQuery = val;
                    _applyFilters();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name or ID...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    // Remove hardcoded white, use Surface Container or similar
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ThemedTabBar(
                      controller: _filterTabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      indicatorPadding: EdgeInsets.zero,
                      tabs: _roleTabs
                          .map((filter) => Tab(text: filter.label))
                          .toList(),
                      onTap: _onRoleTabTapped,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredEmployees.isEmpty
          ? Center(
              child: Text(
                'No employees found',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredEmployees.length,
              itemBuilder: (context, index) {
                final emp = _filteredEmployees[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Text(
                        emp.name[0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    title: Text(
                      emp.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${emp.employeeId} | ${emp.department}'),
                        Text(
                          'Role: ${emp.roleType.toUpperCase()}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () {
                      context.pushNamed(
                        'hr_employee_edit',
                        pathParameters: {'employeeId': emp.employeeId},
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'employee_list_fab',
        onPressed: () => context.pushNamed('hr_employee_add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onRoleTabTapped(int index) {
    _selectedRole = _roleTabs[index].role;
    _applyFilters();
  }
}

class _RoleFilter {
  final String label;
  final String? role;

  const _RoleFilter({required this.label, required this.role});
}
