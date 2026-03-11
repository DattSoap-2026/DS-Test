import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/diesel_service.dart';
import '../../services/vehicles_service.dart';
import '../../services/users_service.dart';
import '../../models/types/user_types.dart';
import '../../utils/normalized_number_input_formatter.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class AddDieselLogScreen extends StatefulWidget {
  const AddDieselLogScreen({super.key});

  @override
  State<AddDieselLogScreen> createState() => _AddDieselLogScreenState();
}

class _AddDieselLogScreenState extends State<AddDieselLogScreen> {
  late final DieselService _dieselService;
  late final VehiclesService _vehiclesService;
  late final UsersService _usersService;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  List<Vehicle> _vehicles = [];
  List<AppUser> _drivers = [];

  Vehicle? _selectedVehicle;
  AppUser? _selectedDriver;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _litersController = TextEditingController(
    text: '0',
  );
  final TextEditingController _rateController = TextEditingController(text: '0');
  final TextEditingController _odometerController = TextEditingController(
    text: '0',
  );
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  bool _tankFull = true;

  @override
  void dispose() {
    _litersController.dispose();
    _rateController.dispose();
    _odometerController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _dieselService = context.read<DieselService>();
    _vehiclesService = context.read<VehiclesService>();
    _usersService = context.read<UsersService>();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final vehicles = await _vehiclesService.getVehicles(status: 'active');
      final drivers = await _usersService.getUsers(role: UserRole.driver);
      final rate = await _dieselService.getLatestDieselRate();

      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _drivers = drivers;
          _rateController.text = rate.toStringAsFixed(2);
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

  Future<void> _saveLog() async {
    if (!_formKey.currentState!.validate() ||
        _selectedVehicle == null ||
        _selectedDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final liters = double.tryParse(_litersController.text);
      final rate = double.tryParse(_rateController.text);
      final odometer = double.tryParse(_odometerController.text);
      if (liters == null || rate == null || odometer == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter valid numeric values')),
          );
          setState(() => _isSaving = false);
        }
        return;
      }

      final logData = {
        'vehicleId': _selectedVehicle!.id,
        'vehicleNumber': _selectedVehicle!.number,
        'driverName': _selectedDriver!.name,
        'fillDate': _selectedDate.toIso8601String(),
        'liters': liters,
        'rate': rate,
        'odometerReading': odometer,
        'tankFull': _tankFull,
        'journeyFrom': _fromController.text,
        'journeyTo': _toController.text,
      };

      await _dieselService.addDieselLog(logData);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diesel log added successfully')),
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
        title: const Text('Add Diesel Log'),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
                    _buildSectionHeader('Vehicle & Personnel'),
                    _buildVehicleDriverDropdowns(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Fill Details'),
                    _buildFillForm(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Trip Information'),
                    _buildTripForm(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveLog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: _isSaving
                            ? CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onPrimary,
                              )
                            : const Text(
                                'Save Log',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.info,
        ),
      ),
    );
  }

  Widget _buildVehicleDriverDropdowns() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Vehicle>(
              initialValue: _selectedVehicle,
              decoration: const InputDecoration(
                labelText: 'Vehicle',
                prefixIcon: Icon(Icons.local_shipping),
              ),
              items: _vehicles
                  .map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Text('${v.name} (${v.number})'),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _selectedVehicle = v;
                  if (v != null) {
                    _odometerController.text = v.currentOdometer
                        .toStringAsFixed(0);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AppUser>(
              initialValue: _selectedDriver,
              decoration: const InputDecoration(
                labelText: 'Driver',
                prefixIcon: Icon(Icons.person),
              ),
              items: _drivers
                  .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                  .toList(),
              onChanged: (d) => setState(() => _selectedDriver = d),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _litersController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false,
                    ),
                    inputFormatters: [
                      NormalizedNumberInputFormatter.decimal(
                        keepZeroWhenEmpty: true,
                        maxDecimalPlaces: 3,
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Liters',
                      suffixText: 'L',
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _rateController,
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
                    decoration: const InputDecoration(
                      labelText: 'Rate',
                      prefixText: '₹',
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _odometerController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                NormalizedNumberInputFormatter.integer(keepZeroWhenEmpty: true),
              ],
              decoration: const InputDecoration(
                labelText: 'Current Odometer',
                suffixText: 'km',
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Tank Full?'),
              subtitle: const Text('Used for mileage calculation'),
              value: _tankFull,
              onChanged: (v) => setState(() => _tankFull = v),
              activeTrackColor: AppColors.info,
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              leading: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _fromController,
              decoration: const InputDecoration(
                labelText: 'Journey From',
                hintText: 'e.g. Factory',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _toController,
              decoration: const InputDecoration(
                labelText: 'Journey To',
                hintText: 'e.g. Surat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

