import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/vehicle_form_constants.dart';
import '../../services/vehicles_service.dart';
import '../../utils/app_toast.dart';
import '../../utils/normalized_number_input_formatter.dart';
import '../../widgets/ui/themed_tab_bar.dart';

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;

  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final VehiclesService _vehiclesService;

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late final TextEditingController _modelController;
  late final TextEditingController _serialNumberController;
  DateTime? _purchaseDate;
  late String _selectedStatus;

  late String _selectedFuelType;
  late final TextEditingController _capacityController;
  late final TextEditingController _odometerController;
  late String _selectedTyreSize;
  late final TextEditingController _minAverageController;
  late final TextEditingController _maxAverageController;

  late final TextEditingController _insuranceNumberController;
  late final TextEditingController _insuranceProviderController;
  DateTime? _insuranceStartDate;
  DateTime? _insuranceExpiryDate;
  late final TextEditingController _pucNumberController;
  DateTime? _pucExpiryDate;
  late final TextEditingController _permitNumberController;
  DateTime? _permitExpiryDate;
  DateTime? _fitnessExpiryDate;
  late final TextEditingController _rcNumberController;

  late String _selectedType;
  final List<String> _types = [
    'Truck',
    'Tanker',
    'Tempo',
    'Lorry',
    'Car',
    'Other',
  ];
  final List<String> _fuelTypes = ['Diesel', 'Petrol', 'CNG', 'Electric'];
  final List<String> _statusOptions = const [
    'active',
    'inactive',
    'under_maintenance',
  ];

  @override
  void initState() {
    super.initState();
    _vehiclesService = context.read<VehiclesService>();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );

    // Pre-fill data
    _nameController = TextEditingController(text: widget.vehicle.name);
    _numberController = TextEditingController(text: widget.vehicle.number);
    _modelController = TextEditingController(text: widget.vehicle.model ?? '');
    _serialNumberController = TextEditingController(
      text: widget.vehicle.serialNumber ?? '',
    );
    _purchaseDate = widget.vehicle.purchaseDate;
    _selectedStatus = _normalizeSelection(
      widget.vehicle.status,
      _statusOptions,
      fallback: 'active',
    );
    _selectedType = _normalizeSelection(
      widget.vehicle.type,
      _types,
      fallback: 'Other',
    );

    _selectedFuelType = _normalizeSelection(
      widget.vehicle.fuelType,
      _fuelTypes,
      fallback: 'Diesel',
    );
    _capacityController = TextEditingController(
      text: widget.vehicle.capacity?.toString() ?? '0',
    );
    _odometerController = TextEditingController(
      text: widget.vehicle.currentOdometer.toString(),
    );
    _selectedTyreSize = _normalizeTyreSize(widget.vehicle.tyreSize);
    _minAverageController = TextEditingController(
      text: widget.vehicle.minAverage.toString(),
    );
    _maxAverageController = TextEditingController(
      text: widget.vehicle.maxAverage.toString(),
    );

    _insuranceNumberController = TextEditingController(
      text: widget.vehicle.policyNumber ?? '',
    );
    _insuranceProviderController = TextEditingController(
      text: widget.vehicle.insuranceProvider ?? '',
    );
    _insuranceStartDate = widget.vehicle.insuranceStartDate;
    _insuranceExpiryDate = widget.vehicle.insuranceExpiryDate;
    _pucNumberController = TextEditingController(
      text: widget.vehicle.pucNumber ?? '',
    );
    _pucExpiryDate = widget.vehicle.pucExpiryDate;
    _permitNumberController = TextEditingController(
      text: widget.vehicle.permitNumber ?? '',
    );
    _permitExpiryDate = widget.vehicle.permitExpiryDate;
    _fitnessExpiryDate = widget.vehicle.fitnessExpiryDate;
    _rcNumberController = TextEditingController(
      text: widget.vehicle.rcNumber ?? '',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _numberController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    _capacityController.dispose();
    _odometerController.dispose();
    _minAverageController.dispose();
    _maxAverageController.dispose();
    _insuranceNumberController.dispose();
    _insuranceProviderController.dispose();
    _pucNumberController.dispose();
    _permitNumberController.dispose();
    _rcNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        switch (field) {
          case 'purchase':
            _purchaseDate = picked;
            break;
          case 'insuranceStart':
            _insuranceStartDate = picked;
            break;
          case 'insuranceExpiry':
            _insuranceExpiryDate = picked;
            break;
          case 'pucExpiry':
            _pucExpiryDate = picked;
            break;
          case 'permitExpiry':
            _permitExpiryDate = picked;
            break;
          case 'fitnessExpiry':
            _fitnessExpiryDate = picked;
            break;
        }
      });
    }
  }

  Future<void> _updateVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final data = {
        'name': _nameController.text,
        'number': _numberController.text.toUpperCase(),
        'model': _modelController.text,
        'serialNumber': _serialNumberController.text,
        'purchaseDate': _purchaseDate?.toIso8601String(),
        'status': _selectedStatus,
        'type': _selectedType,
        'fuelType': _selectedFuelType,
        'capacity': double.tryParse(_capacityController.text),
        'currentOdometer': double.tryParse(_odometerController.text) ?? 0,
        'tyreSize': _selectedTyreSize == kTyreSizeNotSet
            ? null
            : _selectedTyreSize,
        'minAverage': double.tryParse(_minAverageController.text) ?? 0,
        'maxAverage': double.tryParse(_maxAverageController.text) ?? 0,
        'policyNumber': _insuranceNumberController.text,
        'insuranceProvider': _insuranceProviderController.text,
        'insuranceStartDate': _insuranceStartDate?.toIso8601String(),
        'insuranceExpiryDate': _insuranceExpiryDate?.toIso8601String(),
        'pucNumber': _pucNumberController.text,
        'pucExpiryDate': _pucExpiryDate?.toIso8601String(),
        'permitNumber': _permitNumberController.text,
        'permitExpiryDate': _permitExpiryDate?.toIso8601String(),
        'fitnessExpiryDate': _fitnessExpiryDate?.toIso8601String(),
        'rcNumber': _rcNumberController.text,
      };

      await _vehiclesService.updateVehicle(widget.vehicle.id, data);

      if (mounted) {
        setState(() => _isSaving = false);
        AppToast.showSuccess(context, 'Vehicle updated successfully');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppToast.showError(context, 'Error updating vehicle: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.vehicle.number}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: ThemedTabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Technical'),
            Tab(text: 'Compliance'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildGeneralTab(),
            _buildTechnicalTab(),
            _buildComplianceTab(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _updateVehicle,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                : const Text(
                    'UPDATE VEHICLE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null
                      ? "${value.day}/${value.month}/${value.year}"
                      : 'Select Date',
                  style: TextStyle(
                    color: value != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              dropdownColor: Theme.of(context).cardColor,
              isExpanded: true,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _normalizeSelection(
    String? value,
    List<String> options, {
    required String fallback,
  }) {
    final normalized = (value ?? '').trim();
    if (normalized.isNotEmpty && options.contains(normalized)) {
      return normalized;
    }
    return fallback;
  }

  String _normalizeTyreSize(String? value) {
    final normalized = (value ?? '').trim();
    if (normalized.isEmpty) return kTyreSizeNotSet;
    return normalized;
  }

  List<String> get _tyreSizeOptions {
    final options = List<String>.from(kStandardTyreSizes);
    if (!options.contains(_selectedTyreSize)) {
      options.add(_selectedTyreSize);
    }
    return options;
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildField(
            label: 'Vehicle Name',
            controller: _nameController,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          _buildField(
            label: 'Registration Number',
            controller: _numberController,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          _buildDropdown(
            label: 'Vehicle Type',
            value: _selectedType,
            items: _types,
            onChanged: (v) => setState(() => _selectedType = v!),
          ),
          _buildField(label: 'Model / Make', controller: _modelController),
          _buildDatePicker(
            label: 'Purchase Date',
            value: _purchaseDate,
            onTap: () => _selectDate(context, 'purchase'),
          ),
          _buildDropdown(
            label: 'Status',
            value: _selectedStatus,
            items: _statusOptions,
            onChanged: (v) => setState(() => _selectedStatus = v!),
          ),
          _buildField(label: 'Serial No.', controller: _serialNumberController),
        ],
      ),
    );
  }

  Widget _buildTechnicalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDropdown(
            label: 'Fuel Type',
            value: _selectedFuelType,
            items: _fuelTypes,
            onChanged: (v) => setState(() => _selectedFuelType = v!),
          ),
          _buildField(
            label: 'Fuel Tank Capacity (L/KG)',
            controller: _capacityController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            inputFormatters: [
              NormalizedNumberInputFormatter.decimal(
                keepZeroWhenEmpty: true,
                maxDecimalPlaces: 2,
              ),
            ],
          ),
          _buildField(
            label: 'Current Odometer',
            controller: _odometerController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              NormalizedNumberInputFormatter.integer(keepZeroWhenEmpty: true),
            ],
          ),
          _buildDropdown(
            label: 'Tyre Size',
            value: _selectedTyreSize,
            items: _tyreSizeOptions,
            onChanged: (v) => setState(() => _selectedTyreSize = v!),
          ),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  label: 'Min. Average',
                  controller: _minAverageController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  inputFormatters: [
                    NormalizedNumberInputFormatter.decimal(
                      keepZeroWhenEmpty: true,
                      maxDecimalPlaces: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildField(
                  label: 'Max. Average',
                  controller: _maxAverageController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  inputFormatters: [
                    NormalizedNumberInputFormatter.decimal(
                      keepZeroWhenEmpty: true,
                      maxDecimalPlaces: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildField(
            label: 'Insurance Number',
            controller: _insuranceNumberController,
          ),
          _buildField(
            label: 'Insurance Provider',
            controller: _insuranceProviderController,
          ),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  label: 'Insurance Start',
                  value: _insuranceStartDate,
                  onTap: () => _selectDate(context, 'insuranceStart'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDatePicker(
                  label: 'Insurance End',
                  value: _insuranceExpiryDate,
                  onTap: () => _selectDate(context, 'insuranceExpiry'),
                ),
              ),
            ],
          ),
          _buildField(label: 'PUC Number', controller: _pucNumberController),
          _buildDatePicker(
            label: 'PUC Expiry Date',
            value: _pucExpiryDate,
            onTap: () => _selectDate(context, 'pucExpiry'),
          ),
          _buildField(
            label: 'Permit Number',
            controller: _permitNumberController,
          ),
          _buildDatePicker(
            label: 'Permit Expiry Date',
            value: _permitExpiryDate,
            onTap: () => _selectDate(context, 'permitExpiry'),
          ),
          _buildDatePicker(
            label: 'Fitness Expiry Date',
            value: _fitnessExpiryDate,
            onTap: () => _selectDate(context, 'fitnessExpiry'),
          ),
          _buildField(label: 'RC Number', controller: _rcNumberController),
        ],
      ),
    );
  }
}
