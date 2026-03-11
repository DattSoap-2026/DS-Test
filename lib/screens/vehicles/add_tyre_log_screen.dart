import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/vehicles_service.dart';
import '../../widgets/ui/animated_card.dart';
import '../../widgets/ui/glass_container.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/custom_text_field.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class AddTyreLogScreen extends StatefulWidget {
  const AddTyreLogScreen({super.key});

  @override
  State<AddTyreLogScreen> createState() => _AddTyreLogScreenState();
}

class _AddTyreLogScreenState extends State<AddTyreLogScreen> {
  late final VehiclesService _vehiclesService;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  List<Vehicle> _vehicles = [];
  List<TyreStockItem> _availableTyres = [];
  Vehicle? _selectedVehicle;
  DateTime _selectedDate = DateTime.now();
  String _reason = 'Usage Wear';

  final List<String> _reasons = [
    'Usage Wear',
    'Accidental Damage',
    'Manufacturing Defect',
    'Puncture',
  ];
  final List<String> _dispositions = ['Scrapped', 'Remolded', 'Kept as Spare'];
  final List<String> _positions = [
    'Front Right',
    'Front Left',
    'Rear Right Outer',
    'Rear Right Inner',
    'Rear Left Outer',
    'Rear Left Inner',
    'Spare',
  ];

  final List<TyreLogItem> _items = [
    TyreLogItem(
      tyrePosition: 'Front Right',
      newTyreType: 'New',
      tyreItemId: '',
      tyreBrand: '',
      tyreNumber: '',
      cost: 0,
      oldTyreDisposition: 'Scrapped',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _vehiclesService = context.read<VehiclesService>();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final vehicles = await _vehiclesService.getVehicles();
      final stock = await _vehiclesService.getAvailableTyres();
      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _availableTyres = stock;
          _isLoading = false;
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

  void _addItem() {
    setState(() {
      _items.add(
        TyreLogItem(
          tyrePosition: 'Rear Right Outer',
          newTyreType: 'New',
          tyreItemId: '',
          tyreBrand: '',
          tyreNumber: '',
          cost: 0,
          oldTyreDisposition: 'Scrapped',
        ),
      );
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() => _items.removeAt(index));
    }
  }

  double get _totalCost => _items.fold(0, (sum, item) => sum + item.cost);

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
      final log = TyreLog(
        id: '',
        vehicleId: _selectedVehicle!.id,
        vehicleNumber: _selectedVehicle!.number,
        installationDate: _selectedDate.toIso8601String(),
        reason: _reason,
        items: _items,
        totalCost: _totalCost,
      );

      await _vehiclesService.addTyreLog(log);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tyre log added successfully')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Replacement Tyre Entry'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tyre Replacements',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Tyre'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._items.asMap().entries.map(
                      (entry) => _buildTyreItemCard(entry.key),
                    ),
                    const SizedBox(height: 24),
                    _buildSummaryCard(),
                    const SizedBox(height: 32),
                    CustomButton(
                      label: 'Submit Records',
                      onPressed: _saveLog,
                      isLoading: _isSaving,
                      width: double.infinity,
                      height: 54,
                      color: Theme.of(context).colorScheme.primary,
                      textColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderSection() {
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Vehicle>(
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
                      child: Text('${v.name} (${v.number})'),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedVehicle = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _reason,
                    decoration: const InputDecoration(
                      labelText: 'Replacement Reason',
                      border: OutlineInputBorder(),
                    ),
                    items: _reasons
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setState(() => _reason = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTyreItemCard(int index) {
    final item = _items[index];

    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Tyre Selection #${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (_items.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => _removeItem(index),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: item.tyrePosition,
              decoration: const InputDecoration(
                labelText: 'Position',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: _positions
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _items[index] = TyreLogItem(
                    tyrePosition: v!,
                    newTyreType: item.newTyreType,
                    tyreItemId: item.tyreItemId,
                    tyreBrand: item.tyreBrand,
                    tyreNumber: item.tyreNumber,
                    cost: item.cost,
                    oldTyreDisposition: item.oldTyreDisposition,
                    oldTyreBrand: item.oldTyreBrand,
                    oldTyreNumber: item.oldTyreNumber,
                  );
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TyreStockItem>(
              decoration: const InputDecoration(
                labelText: 'Select from Stock',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: _availableTyres
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text('${t.brand} - ${t.serialNumber} (${t.type})'),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _items[index] = TyreLogItem(
                      tyrePosition: item.tyrePosition,
                      newTyreType: val.type,
                      tyreItemId: val.id,
                      tyreBrand: val.brand,
                      tyreNumber: val.serialNumber,
                      cost: val.cost,
                      oldTyreDisposition: item.oldTyreDisposition,
                      oldTyreBrand: item.oldTyreBrand,
                      oldTyreNumber: item.oldTyreNumber,
                    );
                  });
                }
              },
              validator: (v) =>
                  v == null && item.tyreItemId.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Brand: ${item.tyreBrand.isEmpty ? "-" : item.tyreBrand}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Cost: ₹${item.cost.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Old Tyre Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    initialValue: item.oldTyreBrand,
                    label: 'Old Brand',
                    onChanged: (v) {
                      _items[index] = TyreLogItem(
                        tyrePosition: item.tyrePosition,
                        newTyreType: item.newTyreType,
                        tyreItemId: item.tyreItemId,
                        tyreBrand: item.tyreBrand,
                        tyreNumber: item.tyreNumber,
                        cost: item.cost,
                        oldTyreDisposition: item.oldTyreDisposition,
                        oldTyreBrand: v,
                        oldTyreNumber: item.oldTyreNumber,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomTextField(
                    initialValue: item.oldTyreNumber,
                    label: 'Old S/N',
                    onChanged: (v) {
                      _items[index] = TyreLogItem(
                        tyrePosition: item.tyrePosition,
                        newTyreType: item.newTyreType,
                        tyreItemId: item.tyreItemId,
                        tyreBrand: item.tyreBrand,
                        tyreNumber: item.tyreNumber,
                        cost: item.cost,
                        oldTyreDisposition: item.oldTyreDisposition,
                        oldTyreBrand: item.oldTyreBrand,
                        oldTyreNumber: v,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: item.oldTyreDisposition,
              decoration: const InputDecoration(
                labelText: 'Disposition',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: _dispositions
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _items[index] = TyreLogItem(
                    tyrePosition: item.tyrePosition,
                    newTyreType: item.newTyreType,
                    tyreItemId: item.tyreItemId,
                    tyreBrand: item.tyreBrand,
                    tyreNumber: item.tyreNumber,
                    cost: item.cost,
                    oldTyreDisposition: v!,
                    oldTyreBrand: item.oldTyreBrand,
                    oldTyreNumber: item.oldTyreNumber,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Grand Total',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              NumberFormat.currency(
                symbol: '₹',
                decimalDigits: 0,
              ).format(_totalCost),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

