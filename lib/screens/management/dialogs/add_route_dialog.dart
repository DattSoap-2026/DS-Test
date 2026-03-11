import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/vehicles_service.dart';
import '../../../services/users_service.dart';
import '../../../models/types/user_types.dart';
import '../../../constants/maharashtra_zones.dart';
import '../../../utils/app_toast.dart';
import '../routes_management_screen.dart';
import 'package:flutter_app/utils/responsive.dart';

class AddRouteDialog extends StatefulWidget {
  const AddRouteDialog({super.key});

  @override
  State<AddRouteDialog> createState() => _AddRouteDialogState();
}

class _AddRouteDialogState extends State<AddRouteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  late final VehiclesService _vehiclesService;
  late final UsersService _usersService;

  bool _isLoading = false;
  bool _isLoadingSalesmen = true;
  List<Map<String, dynamic>> _salesmen = [];

  String? _selectedZone;
  String? _selectedDistrict;
  String? _selectedSalesmanId;
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    _vehiclesService = context.read<VehiclesService>();
    _usersService = context.read<UsersService>();
    _loadSalesmen();
  }

  String _assigneeRoleLabel(dynamic rawRole) {
    final role = rawRole?.toString().trim().toLowerCase() ?? '';
    if (role.contains('dealer')) return 'Dealer Manager';
    if (role.contains('salesman')) return 'Salesman';
    return '';
  }

  String _formatAssigneeLabel(Map<String, dynamic> assignee) {
    final name = (assignee['name'] ?? '').toString().trim();
    final roleLabel = _assigneeRoleLabel(assignee['role']);
    if (roleLabel.isEmpty) return name;
    return '$name ($roleLabel)';
  }

  Future<void> _loadSalesmen() async {
    try {
      final users = await _usersService.getUsers();
      final List<Map<String, dynamic>> salesmen = users
          .where(
            (u) =>
                u.role == UserRole.salesman || u.role == UserRole.dealerManager,
          )
          .map<Map<String, dynamic>>(
            (u) => <String, dynamic>{
              'id': u.id,
              'name': u.name,
              'role': u.role.value,
            },
          )
          .toList();
      salesmen.sort((a, b) {
        final aName = (a['name'] ?? '').toString().toLowerCase();
        final bName = (b['name'] ?? '').toString().toLowerCase();
        return aName.compareTo(bName);
      });

      if (mounted) {
        setState(() {
          _salesmen = salesmen;
          _isLoadingSalesmen = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSalesmen = false);
      }
    }
  }

  Future<void> _saveRoute() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> selectedSalesman = _selectedSalesmanId != null
          ? _salesmen.firstWhere(
              (s) => s['id'] == _selectedSalesmanId,
              orElse: () => <String, dynamic>{},
            )
          : <String, dynamic>{};
      final salesmanName = selectedSalesman['name'] ?? '';

      final route = RouteData(
        id: '',
        name: _nameController.text.trim(),
        zone: _selectedZone ?? '',
        district: _selectedDistrict ?? '',
        description: _descriptionController.text.trim(),
        salesmanId: _selectedSalesmanId ?? '',
        salesmanName: salesmanName,
        status: _status,
      );

      await _vehiclesService.addRoute(route.toJson());

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: Responsive.dialogInsetPadding(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.dialogConstraints(
            context,
            maxWidth: 560,
            maxHeightFactor: 0.92,
          ).maxWidth,
          maxHeight: Responsive.dialogConstraints(
            context,
            maxWidth: 560,
            maxHeightFactor: 0.92,
          ).maxHeight,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4f46e5).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.route,
                        color: Color(0xFF4f46e5),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Add New Route',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Zone Dropdown (Step 1)
                DropdownButtonFormField<String>(
                  initialValue: _selectedZone,
                  decoration: const InputDecoration(
                    labelText: 'Zone (Division) *',
                    hintText: 'Select zone first',
                    border: OutlineInputBorder(),
                  ),
                  items: MaharashtraZones.zones.map((zone) {
                    return DropdownMenuItem(value: zone, child: Text(zone));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedZone = val;
                      _selectedDistrict = null; // Reset district
                    });
                  },
                  validator: (val) => val == null ? 'Zone is required' : null,
                ),
                const SizedBox(height: 16),
                // District Dropdown (Step 2 - filtered)
                DropdownButtonFormField<String>(
                  initialValue: _selectedDistrict,
                  decoration: InputDecoration(
                    labelText: 'District *',
                    hintText: _selectedZone == null
                        ? 'Select zone first'
                        : 'Select district',
                    border: const OutlineInputBorder(),
                  ),
                  items: _selectedZone == null
                      ? []
                      : MaharashtraZones.getDistricts(_selectedZone!).map((
                          district,
                        ) {
                          return DropdownMenuItem(
                            value: district,
                            child: Text(district),
                          );
                        }).toList(),
                  onChanged: _selectedZone == null
                      ? null
                      : (val) => setState(() => _selectedDistrict = val),
                  validator: (val) =>
                      val == null ? 'District is required' : null,
                ),
                const SizedBox(height: 16),
                // Route Name (Step 3)
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Route Name *',
                    hintText: 'e.g., Route 1, Central Area',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val?.isEmpty ?? true ? 'Route name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Additional details about this route',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _isLoadingSalesmen
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        initialValue: _selectedSalesmanId,
                        decoration: const InputDecoration(
                          labelText: 'Assign User (Salesman/Dealer Manager)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('No Assignment'),
                          ),
                          ..._salesmen.map(
                            (s) => DropdownMenuItem(
                              value: s['id'],
                              child: Text(_formatAssigneeLabel(s)),
                            ),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedSalesmanId = val),
                      ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (val) => setState(() => _status = val!),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveRoute,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4f46e5),
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Text('Add Route'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
