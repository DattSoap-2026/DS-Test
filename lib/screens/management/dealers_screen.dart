import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../../services/dealers_service.dart'; // Keep for Dealer model
import '../../data/repositories/dealer_repository.dart';
import '../../data/local/entities/dealer_entity.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../services/dealer_import_service.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/widgets/dialogs/responsive_alert_dialog.dart';

class DealersManagementScreen extends StatefulWidget {
  const DealersManagementScreen({super.key});

  @override
  State<DealersManagementScreen> createState() =>
      _DealersManagementScreenState();
}

class _DealersManagementScreenState extends State<DealersManagementScreen> {
  bool _isLoading = true;
  List<Dealer> _dealers = [];
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadDealers();
  }

  Future<void> _loadDealers() async {
    setState(() => _isLoading = true);
    try {
      // OFFLINE-FIRST: Read from local repository
      final dealerRepo = context.read<DealerRepository>();
      final dealerEntities = await dealerRepo.getAllDealers();

      final dealers = dealerEntities.map((e) => e.toDomain()).toList();

      if (mounted) {
        setState(() {
          _dealers = dealers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading dealers: $e')));
      }
    }
  }

  List<Dealer> get _filteredDealers {
    return _dealers.where((d) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.contactPerson.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.mobile.contains(_searchQuery);

      final matchesStatus = _statusFilter == 'all' || d.status == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildScreenHeader(),
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDealers.isEmpty
                ? _buildEmptyState()
                : _buildDealersTable(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dealers_fab',
        onPressed: () => _showDealerForm(),
        backgroundColor: const Color(0xFF4f46e5),
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildScreenHeader() {
    final theme = Theme.of(context);
    return MasterScreenHeader(
      title: 'Dealers',
      subtitle: 'Registered dealers and partners',
      helperText: 'Dealer data is used for sales and dispatch planning.',
      color: theme.colorScheme.primary,
      icon: Icons.handshake_outlined,
      actions: [
        FilledButton.icon(
          onPressed: _handleImport,
          icon: const Icon(Icons.upload_file_rounded, size: 18),
          label: const Text('Import'),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            foregroundColor: theme.colorScheme.primary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
          onPressed: _loadDealers,
          tooltip: 'Refresh list',
        ),
      ],
    );
  }

  Future<void> _handleImport() async {
    final importService = context.read<DealerImportService>();
    final result = await importService.importDealers();

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        _loadDealers();
      } else if (result['message'] != 'No file selected') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildDealersTable() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(
              alpha: isDark ? 0.2 : 0.1,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 900,
            headingRowHeight: 56,
            dataRowHeight: 64,
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            ),
            columns: [
              DataColumn2(
                label: _tableHeader('DEALER NAME'),
                size: ColumnSize.L,
              ),
              DataColumn2(
                label: _tableHeader('CONTACT PERSON'),
                size: ColumnSize.M,
              ),
              DataColumn2(label: _tableHeader('MOBILE'), size: ColumnSize.S),
              DataColumn2(label: _tableHeader('ADDRESS'), size: ColumnSize.L),
              DataColumn2(label: _tableHeader('STATUS'), fixedWidth: 100),
              const DataColumn2(label: Text(''), fixedWidth: 60),
            ],
            rows: _filteredDealers.map((dealer) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            dealer.name.isNotEmpty
                                ? dealer.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            dealer.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(dealer.contactPerson, style: _tableText())),
                  DataCell(Text(dealer.mobile, style: _tableText())),
                  DataCell(
                    Text(
                      dealer.address,
                      style: _tableText(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(_statusBadge(dealer.status ?? 'active')),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _showDealerForm(dealer: dealer),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
    );
  }

  TextStyle _tableText() {
    return const TextStyle(fontSize: 13);
  }

  Widget _buildFilterBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(
              alpha: isDark ? 0.2 : 0.1,
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by dealer name, mobile, or contact person...',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'STATUS:',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 12),
              _statusChip('all', 'ALL'),
              const SizedBox(width: 8),
              _statusChip('active', 'ACTIVE'),
              const SizedBox(width: 8),
              _statusChip('inactive', 'INACTIVE'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String value, String label) {
    final theme = Theme.of(context);
    final isSelected = _statusFilter == value;
    final activeColor = theme.colorScheme.primary;

    return InkWell(
      onTap: () => setState(() => _statusFilter = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? activeColor
                : theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected
                ? activeColor
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    final theme = Theme.of(context);
    final color = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showDealerForm({Dealer? dealer}) {
    showDialog(
      context: context,
      builder: (context) => DealerFormDialog(
        dealer: dealer,
        onSaved: () {
          _loadDealers();
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No dealers found'
                : 'No matches for your search',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class DealerFormDialog extends StatefulWidget {
  final Dealer? dealer;
  final VoidCallback onSaved;

  const DealerFormDialog({super.key, this.dealer, required this.onSaved});

  @override
  State<DealerFormDialog> createState() => _DealerFormDialogState();
}

class _DealerFormDialogState extends State<DealerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    if (widget.dealer != null) {
      _nameController.text = widget.dealer!.name;
      _contactPersonController.text = widget.dealer!.contactPerson;
      _mobileController.text = widget.dealer!.mobile;
      _addressController.text = widget.dealer!.address;
      _status = widget.dealer!.status ?? 'active';
      if (widget.dealer!.latitude != null) {
        _latitudeController.text = widget.dealer!.latitude!.toString();
      }
      if (widget.dealer!.longitude != null) {
        _longitudeController.text = widget.dealer!.longitude!.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Capturing GPS...')));
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        if (!mounted) return;
        setState(() {
          _latitudeController.text = position.latitude.toString();
          _longitudeController.text = position.longitude.toString();
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Location captured!')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final dealerRepo = context.read<DealerRepository>();
      final double? lat = double.tryParse(_latitudeController.text);
      final double? long = double.tryParse(_longitudeController.text);

      DealerEntity entity;
      if (widget.dealer != null) {
        // Edit existing - convert domain to entity
        entity = DealerEntity.fromDomain(widget.dealer!);
        // Update fields
        entity.name = _nameController.text;
        entity.contactPerson = _contactPersonController.text;
        entity.mobile = _mobileController.text;
        entity.address = _addressController.text;
        entity.status = _status;
        entity.latitude = lat;
        entity.longitude = long;
      } else {
        // Create new
        final newId = const Uuid().v4();
        entity = DealerEntity()
          ..id = newId
          ..name = _nameController.text
          ..contactPerson = _contactPersonController.text
          ..mobile = _mobileController.text
          ..address = _addressController.text
          ..status = _status
          ..latitude = lat
          ..longitude = long
          ..createdAt = DateTime.now().toIso8601String()
          // syncStatus & updatedAt handled by saveDealer
          ..isDeleted = false;
      }

      await dealerRepo.saveDealer(entity);
      widget.onSaved();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveAlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF5B5FEF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Text(widget.dealer == null ? 'Add Dealer' : 'Edit Dealer'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Dealer/Company Name',
                controller: _nameController,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Contact Person',
                controller: _contactPersonController,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Mobile Number',
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                validator: (v) => v?.length != 10 ? 'Enter 10 digits' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Address',
                controller: _addressController,
                maxLines: 2,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              // Location Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _captureLocation,
                        icon: const Icon(Icons.my_location, size: 16),
                        label: const Text('Capture GPS'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Latitude',
                          controller: _latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          label: 'Longitude',
                          controller: _longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (v) => setState(() => _status = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4f46e5),
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: _isSaving
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}



