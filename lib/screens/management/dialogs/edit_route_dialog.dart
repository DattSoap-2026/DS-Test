import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/vehicles_service.dart';
import '../../../services/users_service.dart';
import '../../../models/types/user_types.dart';
import '../../../constants/maharashtra_zones.dart';
import '../routes_management_screen.dart';
import 'package:flutter_app/utils/responsive.dart';

class EditRouteDialog extends StatefulWidget {
  final RouteData route;

  const EditRouteDialog({super.key, required this.route});

  @override
  State<EditRouteDialog> createState() => _EditRouteDialogState();
}

class _EditRouteDialogState extends State<EditRouteDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  late final VehiclesService _vehiclesService;
  late final UsersService _usersService;

  bool _isLoading = false;
  bool _isLoadingSalesmen = true;
  List<Map<String, dynamic>> _salesmen = [];

  String? _selectedZone;
  String? _selectedDistrict;
  String? _selectedSalesmanId;
  late String _status;

  @override
  void initState() {
    super.initState();
    _vehiclesService = context.read<VehiclesService>();
    _usersService = context.read<UsersService>();

    // Initialize with existing route data
    _nameController = TextEditingController(text: widget.route.name);
    _descriptionController = TextEditingController(
      text: widget.route.description,
    );
    _selectedZone = widget.route.zone.isNotEmpty ? widget.route.zone : null;
    _selectedDistrict = widget.route.district.isNotEmpty
        ? widget.route.district
        : null;
    _selectedSalesmanId = widget.route.salesmanId.isNotEmpty
        ? widget.route.salesmanId
        : null;
    _status = widget.route.status;

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

      final selectedId = _selectedSalesmanId?.trim() ?? '';
      if (selectedId.isNotEmpty &&
          !salesmen.any(
            (entry) => (entry['id'] ?? '').toString() == selectedId,
          )) {
        salesmen.add({
          'id': selectedId,
          'name': widget.route.salesmanName,
          'role': '',
        });
      }

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

  Future<void> _updateRoute() async {
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

      final updatedRoute = RouteData(
        id: widget.route.id,
        name: _nameController.text.trim(),
        zone: _selectedZone ?? '',
        district: _selectedDistrict ?? '',
        description: _descriptionController.text.trim(),
        salesmanId: _selectedSalesmanId ?? '',
        salesmanName: salesmanName,
        status: _status,
      );

      await _vehiclesService.updateRoute(
        widget.route.id,
        updatedRoute.toJson(),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                        Icons.edit_road,
                        color: Color(0xFF4f46e5),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Edit Route',
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
                // Zone Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedZone,
                  decoration: const InputDecoration(
                    labelText: 'Zone (Division) *',
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
                // District Dropdown
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
                // Route Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Route Name *',
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
                      onPressed: _isLoading ? null : _updateRoute,
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
                          : const Text('Update Route'),
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
