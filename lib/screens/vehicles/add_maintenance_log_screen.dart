import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/vehicles_service.dart';
import '../../services/suppliers_service.dart';
import '../../widgets/ui/animated_card.dart';
import '../../widgets/ui/glass_container.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../utils/normalized_number_input_formatter.dart';
import 'widgets/add_vendor_dialog.dart';
// For PartnerType import if needed

class AddMaintenanceLogScreen extends StatefulWidget {
  final MaintenanceLog? logToEdit;

  const AddMaintenanceLogScreen({super.key, this.logToEdit});

  @override
  State<AddMaintenanceLogScreen> createState() =>
      _AddMaintenanceLogScreenState();
}

class _AddMaintenanceLogScreenState extends State<AddMaintenanceLogScreen> {
  late final VehiclesService _vehiclesService;
  static const double _qtyColumnWidth = 50;
  static const double _priceColumnWidth = 70;
  static const double _totalColumnWidth = 90;
  static const double _actionColumnWidth = 28;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  List<Vehicle> _vehicles = [];
  List<String> _knownVendors = [];
  Vehicle? _selectedVehicle;
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'Repair';

  final List<String> _serviceTypes = [
    'Routine',
    'Repair',
    'Accident',
    'Oil Change',
    'General Checkup',
    'Breakdown',
    'Preventive',
  ];

  final TextEditingController _vendorController = TextEditingController();
  final TextEditingController _mechanicController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _odometerController = TextEditingController(
    text: '0',
  );
  DateTime? _nextServiceDate;

  List<MaintenanceItem> _items = [
    MaintenanceItem(partName: '', quantity: 0, price: 0),
  ];

  @override
  void dispose() {
    _vendorController.dispose();
    _mechanicController.dispose();
    _descriptionController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _vehiclesService = context.read<VehiclesService>();

    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadVehicles(), _loadVendors()]);
  }

  Future<void> _loadVendors() async {
    try {
      final service = context.read<SuppliersService>();
      final vendors = await service.getSuppliers(type: 'vendor');
      if (mounted) {
        setState(() {
          _knownVendors = vendors.map((v) => v.name).toList();
        });
      }
    } catch (_) {
      // Silent error for autocomplete
    }
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _vehiclesService.getVehicles();
      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _isLoading = false;
          if (widget.logToEdit != null && _selectedVehicle == null) {
            _populateForm();
          }
        });
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

  void _populateForm() {
    final log = widget.logToEdit!;
    try {
      _selectedVehicle = _vehicles.firstWhere((v) => v.id == log.vehicleId);
    } catch (_) {
      // Vehicle might not verify against current list, keep null or handle
    }

    try {
      _selectedDate = DateTime.parse(log.serviceDate);
    } catch (_) {}

    if (!_serviceTypes.contains(log.type)) {
      _serviceTypes.add(log.type);
    }
    _selectedType = log.type;

    _vendorController.text = log.vendor;
    _mechanicController.text = log.mechanicName ?? '';
    _descriptionController.text = log.description;
    _nextServiceDate = log.nextServiceDate != null
        ? DateTime.tryParse(log.nextServiceDate!)
        : null;
    if (log.odometerReading != null) {
      _odometerController.text = log.odometerReading.toString();
    }

    if (log.items.isNotEmpty) {
      _items = List.from(log.items);
    }
  }

  void _addItem() {
    setState(() {
      _items.add(MaintenanceItem(partName: '', quantity: 0, price: 0));
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() => _items.removeAt(index));
    }
  }

  double get _totalCost =>
      _items.fold(0, (sum, item) => sum + (item.quantity * item.price));

  Future<void> _saveLog() async {
    if (!_formKey.currentState!.validate() || _selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vehicle and fill all required fields'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final log = MaintenanceLog(
        id: widget.logToEdit?.id ?? '',
        vehicleId: _selectedVehicle!.id,
        vehicleNumber: _selectedVehicle!.number,
        serviceDate: _selectedDate.toIso8601String(),
        vendor: _vendorController.text,
        mechanicName: _mechanicController.text.trim().isNotEmpty ? _mechanicController.text.trim() : null,
        nextServiceDate: _nextServiceDate?.toIso8601String(),
        description: _descriptionController.text,
        totalCost: _totalCost,
        type: _selectedType,
        items: _items,
        odometerReading: double.tryParse(_odometerController.text),
        createdAt:
            widget.logToEdit?.createdAt ?? DateTime.now().toIso8601String(),
      );

      if (widget.logToEdit != null) {
        await _vehiclesService.updateMaintenanceLog(log.id, log.toJson());
      } else {
        await _vehiclesService.addMaintenanceLog(log.toJson());
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.logToEdit != null
                  ? 'Maintenance log updated successfully'
                  : 'Maintenance log added successfully',
            ),
          ),
        );
      }
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
    final isEditing = widget.logToEdit != null;
    return DefaultTabController(
      length: 2,
      animationDuration: const Duration(milliseconds: 200),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditing ? 'Edit Maintenance Log' : 'Add Maintenance Log',
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(58),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: ThemedTabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.airport_shuttle_outlined, size: 18),
                          SizedBox(width: 6),
                          Text('Service Details'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.build_circle_outlined, size: 18),
                          SizedBox(width: 6),
                          Text('Parts & Cost'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: TabBarView(
                        children: [_buildServiceDetailsTab(), _buildPartsTab()],
                      ),
                    ),
                    _buildBottomBar(isEditing),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBottomBar(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: CustomButton(
          label: isEditing
              ? 'Update Maintenance Record'
              : 'Save Maintenance Record',
          onPressed: _saveLog,
          isLoading: _isSaving,
          width: double.infinity,
          height: 50,
          color: Theme.of(context).colorScheme.primary,
          textColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildServiceDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Vehicle & Service Date
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<Vehicle>(
                          key: ValueKey(_selectedVehicle),
                          initialValue: _selectedVehicle,
                          decoration: const InputDecoration(
                            labelText: 'Select Vehicle',
                            prefixIcon: Icon(Icons.local_shipping_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: _vehicles
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(
                                    '${v.name} (${v.number})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedVehicle = v;
                              if (v != null && widget.logToEdit == null) {
                                _odometerController.text = v.currentOdometer
                                    .toStringAsFixed(0);
                              }
                            });
                          },
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _selectedDate = date);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Service Date',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              DateFormat('dd-MM-yyyy').format(_selectedDate),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 2: Vendor & Add Button
                  Row(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Autocomplete<String>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text == '') {
                                      return const Iterable<String>.empty();
                                    }
                                    return _knownVendors.where(
                                      (v) => v.toLowerCase().contains(
                                        textEditingValue.text.toLowerCase(),
                                      ),
                                    );
                                  },
                              fieldViewBuilder:
                                  (
                                    context,
                                    textEditingController,
                                    focusNode,
                                    onFieldSubmitted,
                                  ) {
                                    // Sync local controller
                                    if (_vendorController.text !=
                                        textEditingController.text) {
                                      textEditingController.text =
                                          _vendorController.text;
                                    }
                                    return CustomTextField(
                                      controller: _vendorController,
                                      focusNode: focusNode,
                                      label: 'Vendor / Service Center',
                                      hintText: 'Select or type vendor name...',
                                      prefixIcon: Icons.store_outlined,
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                                      onChanged:
                                          (v) {}, // Controller handles it
                                    );
                                  },
                              onSelected: (String selection) {
                                _vendorController.text = selection;
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Add Vendor Button
                      Container(
                        height: 56, // Match default input height
                        width: 56,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.5),
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          tooltip: 'Add New Vendor',
                          onPressed: () async {
                            final newVendor = await showDialog<String>(
                              context: context,
                              builder: (_) => const AddVendorDialog(),
                            );
                            if (newVendor != null && newVendor.isNotEmpty) {
                              setState(() {
                                _vendorController.text = newVendor;
                                _knownVendors.add(newVendor);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _mechanicController,
                    label: 'Mechanic Name (Optional)',
                    hintText: 'Enter mechanic name',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // Row 3: Service Type, Odometer, Next Service Date
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(_selectedType),
                          initialValue: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Service Type',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          items: _serviceTypes
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedType = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _odometerController,
                          label: 'Odometer',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            NormalizedNumberInputFormatter.integer(
                              keepZeroWhenEmpty: true,
                            ),
                          ],
                          suffixText: 'km',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Optional: Next Service Date
                  // For now, we can just use a simple date picker if needed,
                  // or leave it for later if not critical.
                  // Adding it as per user requirement.
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Next Service Date (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event_repeat),
                    ),
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate.add(
                            const Duration(days: 90),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 2),
                          ),
                        );
                        if (date != null) {
                          setState(() => _nextServiceDate = date);
                        }
                      },
                      child: Text(
                        _nextServiceDate != null
                            ? DateFormat('dd-MM-yyyy').format(_nextServiceDate!)
                            : 'dd-mm-yyyy',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Overall Summary / Notes',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnimatedCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Parts & Services List',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Part Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: _qtyColumnWidth,
                          child: Text(
                            'Qty',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: _priceColumnWidth,
                          child: Text(
                            'Price',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: _totalColumnWidth,
                          child: Text(
                            'Total',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(width: _actionColumnWidth),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  ..._items.asMap().entries.map(
                    (entry) => _buildItemCard(entry.key),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Item'),
                    ),
                  ),

                  if (_items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No parts added yet.\nClick "Add Item" to start.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSummaryCard(),
          const SizedBox(height: 80), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = _items[index];
    final qtyController = TextEditingController(
      text: item.quantity.toStringAsFixed(0),
    );
    final priceController = TextEditingController(
      text: item.price.toStringAsFixed(0),
    );

    // Using a simpler controller strategy for local edits to avoid losing focus
    // In production, consider a FormArray or similar state management

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: TextFormField(
              initialValue: item.partName,
              decoration: InputDecoration(
                hintText: 'Part Name',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.2,
                  ),
                ),
              ),
              style: const TextStyle(fontWeight: FontWeight.w500),
              onChanged: (v) {
                _items[index] = MaintenanceItem(
                  partName: v,
                  description: item.description,
                  quantity: item.quantity,
                  price: item.price,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: _qtyColumnWidth,
            child: TextFormField(
              controller: qtyController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                NormalizedNumberInputFormatter.integer(keepZeroWhenEmpty: true),
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.2,
                  ),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
              ),
              onChanged: (v) {
                final val = double.tryParse(v) ?? 0;
                _items[index] = MaintenanceItem(
                  partName: item.partName,
                  description: item.description,
                  quantity: val,
                  price: item.price,
                );
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: _priceColumnWidth,
            child: TextFormField(
              controller: priceController,
              textAlign: TextAlign.end,
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
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.2,
                  ),
                ),
                isDense: true,
                prefixText: 'Rs ',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
              ),
              onChanged: (v) {
                final val = double.tryParse(v) ?? 0;
                _items[index] = MaintenanceItem(
                  partName: item.partName,
                  description: item.description,
                  quantity: item.quantity,
                  price: val,
                );
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: _totalColumnWidth,
            child: Text(
              NumberFormat.currency(
                symbol: 'Rs ',
                decimalDigits: 0,
              ).format(item.quantity * item.price),
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: _actionColumnWidth,
            child: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onPressed: () => _removeItem(index),
              constraints: const BoxConstraints.tightFor(
                width: _actionColumnWidth,
                height: _actionColumnWidth,
              ),
              padding: EdgeInsets.zero,
              splashRadius: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Items: ${_items.length}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Cost',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  NumberFormat.currency(
                    symbol: 'Rs ',
                    decimalDigits: 0,
                  ).format(_totalCost),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
